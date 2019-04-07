/**
 *  @file chestnutmsig.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#include "chestnutsecurity.cpp"


void chestnutmsig::hello( void ) {
   print("hello world\n");
}


void chestnutmsig::addwhitelist( name user, name account_to_add ) {
   require_auth( user );
   eosio::check( is_account( account_to_add ), "account does not exist");

   whitelist_table user_whitelist( _self, user.value );

   user_whitelist.emplace( user, [&]( auto& w ) {
      w.whitelisted_account = account_to_add;
   });
}


void chestnutmsig::rmwhitelist( name user, name account_to_remove ) {
   require_auth( user );
   eosio::check( is_account( account_to_remove ), "account does not exist");

   whitelist_table user_whitelist( _self, user.value );
   auto whitelisted = user_whitelist.find( account_to_remove.value );

   eosio::check( whitelisted->whitelisted_account == account_to_remove , "cannot find account");

   user_whitelist.erase( whitelisted );
}


void chestnutmsig::addtokenmax( name  user,
                                asset quantity,
                                name  contract_account ) {
   require_auth( user );

   auto sym = quantity.symbol;
   eosio::check( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, user.value );
   uint128_t table_key = get_token_key( contract_account, sym );
   auto  token_max_itr = user_tokens_max.find( table_key );

   eosio::check( token_max_itr == user_tokens_max.end(), "limit already added for "
                 + token_max_itr->contract_account.to_string() + " " 
                 + token_max_itr->max_transfer.to_string() );

   token_max_itr = user_tokens_max.emplace( user, [&]( auto& tk ) {
      tk.id                = table_key;
      tk.max_transfer      = quantity;
      tk.contract_account  = contract_account;
   });
}


void chestnutmsig::rmtokenmax( name user, symbol sym, name contract_account ) {
   require_auth( user );
   eosio::check( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, user.value );
   uint128_t table_key = get_token_key( contract_account, sym );
   auto token_max_to_delete = user_tokens_max.find( table_key );

   eosio::check( token_max_to_delete != user_tokens_max.end(),
                 "can not find token max to delete" );

   user_tokens_max.erase( token_max_to_delete );
}


void chestnutmsig::addxfrmax( name user,
                              asset max_tx,
                              name  contract_account,
                              uint64_t minutes ) {
   require_auth( user );
   eosio::check( max_tx.symbol.is_valid(), "invalid symbol name" );
   eosio::check( is_account(contract_account), "contract account does not exist" );

   time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
   time_point duration{ microseconds{ static_cast<int64_t>( minutes * useconds_per_minute ) } };

   xfr_max_table xfr_table( _self, user.value );
   uint128_t table_key = get_token_key( contract_account, max_tx.symbol );
   auto xfr = xfr_table.find( table_key );

   eosio::check( xfr == xfr_table.end(), "spending limit already added for "
                 + xfr->contract_account.to_string() + " "
                 + xfr->total_tokens_allowed_to_spend.to_string() );

   xfr = xfr_table.emplace( user /*RAM payer*/ , [&]( auto& x ) {
      x.id                             = table_key;
      x.total_tokens_allowed_to_spend  = max_tx;
      x.current_tokens_spent           = asset(0, max_tx.symbol);
      x.contract_account               = contract_account;
      x.minutes                        = minutes;
      x.end_time                       = ct + duration;
   });
}


void chestnutmsig::rmxfrmax( name user, symbol sym, name contract_account ) {
   require_auth( user );

   xfr_max_table xfr_table( _self, user.value );
   uint128_t table_key = get_token_key( contract_account, sym );

   const char *error = ( "could not find spending limit for " 
                         + symbol_to_string(sym) + " with account " 
                         + contract_account.to_string() ).c_str();
   auto& xfr = xfr_table.get( table_key , error );

   xfr_table.erase( xfr );
}


void chestnutmsig::transfer( name proposer, name proposal_name) {
   require_auth( proposer );

   // eosio::multisig::proposals proptable( "eosio.msig"_n, proposer.value );
   proposals proptable( "eosio.msig"_n, proposer.value );
   auto& prop = proptable.get( proposal_name.value, "proposal not found" );
   //assert_sha256( prop.packed_transaction.data(), prop.packed_transaction.size(), *proposal_hash );

   eosio::action proposed_action = eosio::unpack<transaction>( prop.packed_transaction ).actions.front();
   token_transfer action_data = proposed_action.data_as<token_transfer>();

   validate_whitelist( action_data.from, action_data.to );
   validate_single_transfer( action_data.from, action_data.quantity, proposed_action.account );
   validate_total_transfer_limit( action_data.from, action_data.quantity, proposed_action.account );

   // approve
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "approve"_n,
      std::make_tuple( proposer, proposal_name, permission_level{ "chestnutmsig"_n, "security"_n } )
   ).send();

   // execute
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "exec"_n,
      std::make_tuple( proposer, proposal_name, "chestnutmsig"_n )
   ).send();

}


void chestnutmsig::leave( name proposer, name proposal_name ) {
   require_auth( proposer );

   // get proposal
   // eosio::multisig::proposals proptable( "eosio.msig"_n, proposer.value );
   proposals proptable( "eosio.msig"_n, proposer.value );
   auto& prop = proptable.get( proposal_name.value, "proposal not found" );

   // get action data
   eosio::action proposed_action = eosio::unpack<transaction>( prop.packed_transaction ).actions.front();
   eosio::check( "updateauth"_n == proposed_action.name, "only accepts linkauth proposal" );
   update_auth action_data = proposed_action.data_as<update_auth>();

   eosio::check( proposer      == action_data.account, "cannot propose for other accounts" );
   eosio::check( "owner"_n     == action_data.permission, "can only change owner permission" );
   eosio::check( ""_n          == action_data.parent, "can only change owner permission" );

   // approve
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "approve"_n,
      std::make_tuple( proposer, proposal_name, permission_level{ "chestnutmsig"_n, "security"_n } )
   ).send();

   // execute
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "exec"_n,
      std::make_tuple( proposer, proposal_name, "chestnutmsig"_n )
   ).send();
}


void chestnutmsig::giveauth( name proposer, name proposal_name ) {
   require_auth( proposer );

   // get proposal
   // eosio::multisig::proposals proptable( "eosio.msig"_n, proposer.value );
   proposals proptable( "eosio.msig"_n, proposer.value );
   auto& prop = proptable.get( proposal_name.value, "proposal not found" );

   // get action data
   eosio::action proposed_action = eosio::unpack<transaction>( prop.packed_transaction ).actions.front();
   eosio::check( "linkauth"_n == proposed_action.name, "only accepts linkauth proposal" );
   link_auth action_data = proposed_action.data_as<link_auth>();

   // account = proposer
   eosio::check( proposer     == action_data.account, "cannot propose for other accounts" );
   /*eosio::check( CONTRACT_BLACKLIST_GOES_HERE != action_data.code  );*/
   /*eosio::check( ACTION_BLACKLIST_GOES_HERE   != action_data.type  );*/
   eosio::check( "chestnut"_n  == action_data.requirement, "can only linkauth with @chestnut permission" );

   // approve
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "approve"_n,
      std::make_tuple( proposer, proposal_name, permission_level{ "chestnutmsig"_n, "security"_n } )
   ).send();

   // execute
   action(
      permission_level{ "chestnutmsig"_n, "security"_n },
      "eosio.msig"_n,
      "exec"_n,
      std::make_tuple( proposer, proposal_name, "chestnutmsig"_n )
   ).send();

}


EOSIO_DISPATCH( chestnutmsig, (hello)(leave)(giveauth)(transfer)(addtokenmax)(rmtokenmax)(addxfrmax)(rmxfrmax)(addwhitelist)(rmwhitelist) )
