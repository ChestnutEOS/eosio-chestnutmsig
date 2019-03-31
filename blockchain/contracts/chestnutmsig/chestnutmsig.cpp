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
   auto token_max_itr = user_tokens_max.find( sym.code().raw() );

   if ( token_max_itr == user_tokens_max.end() ) {
      token_max_itr = user_tokens_max.emplace( user, [&]( auto& tk ) {
         tk.max_transfer      = quantity;
         tk.contract_account  = contract_account;
      });
   } else {
      user_tokens_max.modify( token_max_itr, same_payer, [&]( auto& tk ) {
         tk.max_transfer      = quantity;
        });
   }

}


void chestnutmsig::rmtokenmax( name user, symbol sym ) {
   require_auth( user );
   eosio::check( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, user.value );
   auto token_max_to_delete = user_tokens_max.find( sym.code().raw() );

   eosio::check( token_max_to_delete != user_tokens_max.end(),
                 "can not find token max to delete" );

   user_tokens_max.erase( token_max_to_delete );
}


void chestnutmsig::addxfrmax( name user,
                              asset max_tx,
                              uint64_t minutes ) {
   require_auth( user );
   eosio::check( max_tx.symbol.is_valid(), "invalid symbol name" );

   time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
   time_point duration{ microseconds{ static_cast<int64_t>( minutes * useconds_per_minute ) } };

   xfr_max_table xfr_table( _self, user.value );
   auto xfr = xfr_table.find( max_tx.symbol.code().raw() );

   if ( xfr == xfr_table.end() ) {
      xfr = xfr_table.emplace( user /*RAM payer*/ , [&]( auto& x ) {
         x.total_tokens_allowed_to_spend  = max_tx;
         x.current_tokens_spent           = asset(0, max_tx.symbol);
         x.minutes                        = minutes;
         x.end_time                       = ct + duration;
      });
   } else {
      xfr_table.modify( xfr, same_payer, [&]( auto& x ) {
         x.total_tokens_allowed_to_spend  = max_tx;
         x.current_tokens_spent           = asset(0, max_tx.symbol);
         x.minutes                        = minutes;
         x.end_time                       = ct + duration;
      });
   }
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
   validate_single_transfer( action_data.from, action_data.quantity);
   validate_total_transfer_limit( action_data.from, action_data.quantity );

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


EOSIO_DISPATCH( chestnutmsig, (hello)(giveauth)(transfer)(addtokenmax)(rmtokenmax)(addxfrmax)(addwhitelist)(rmwhitelist) )
