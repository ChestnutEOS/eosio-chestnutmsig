/**
 *  @file chestnutacnt.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#include "chestnutsecurity.cpp"


void chestnutacnt::hello( void ) {
   print("hello world\n");
}


void chestnutacnt::addwhitelist( name user, name account_to_add ) {
   require_auth( user );
   eosio::check( is_account( account_to_add ), "account does not exist");

   whitelist_table user_whitelist( _self, user.value );

   user_whitelist.emplace( user, [&]( auto& w ) {
      w.whitelisted_account = account_to_add;
   });
}


void chestnutacnt::rmwhitelist( name user, name account_to_remove ) {
   require_auth( user );
   eosio::check( is_account( account_to_remove ), "account does not exist");

   whitelist_table user_whitelist( _self, user.value );
   auto whitelisted = user_whitelist.find( account_to_remove.value );

   eosio_assert( whitelisted->whitelisted_account == account_to_remove , "cannot find account");

   user_whitelist.erase( whitelisted );
}


void chestnutacnt::addtokenmax( name  user,
                                asset quantity,
                                name  contract_account ) {
   require_auth( user );

   auto sym = quantity.symbol;
   eosio_assert( sym.is_valid(), "invalid symbol name" );

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


void chestnutacnt::rmtokenmax( name user, symbol sym ) {
   require_auth( user );
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, user.value );
   auto token_max_to_delete = user_tokens_max.find( sym.code().raw() );

   eosio_assert( token_max_to_delete != user_tokens_max.end(),
                 "can not find token max to delete" );

   user_tokens_max.erase( token_max_to_delete );
}


void chestnutacnt::addxfrmax( name user,
                              asset max_tx,
                              uint64_t minutes ) {
   require_auth( user );
   eosio::check( max_tx.symbol.is_valid(), "invalid symbol name" );

   time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
   time_point duration{ microseconds{ static_cast<int64_t>( minutes * useconds_per_minute ) } };

   xfr_max_table xfr_table( _self, user.value );
   auto xfr = xfr_table.find( max_tx.symbol.code().raw() );

   if ( xfr == xfr_table.end() ) {
      xfr = xfr_table.emplace( user/* RAM payer */, [&]( auto& x ) {
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


void chestnutacnt::transfer( name proposer, name proposal_name) {
   // require_auth( "chestnutacnt"_n );

   struct token_transfer {
      name from;
      name to;
      asset quantity;
      string memo;
   };

   eosio::multisig::proposals proptable( "eosio.msig"_n, proposer.value );
   auto& prop = proptable.get( proposal_name.value, "proposal not found" );
   //assert_sha256( prop.packed_transaction.data(), prop.packed_transaction.size(), *proposal_hash );

   eosio::action my_action = eosio::unpack<eosio::transaction>( prop.packed_transaction ).actions.front();
   token_transfer my_action_data = my_action.data_as<token_transfer>();

   const name from      = my_action_data.from;
   const name to        = my_action_data.to;
   const asset quantity = my_action_data.quantity;
   const string memo    = my_action_data.memo;


   validate_whitelist( from, to );
   validate_total_transfer_limit( from, quantity );
   validate_single_transfer( from, quantity);

   /****/
   auto sym = quantity.symbol;
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, from.value );
   auto token_max_itr = user_tokens_max.find( sym.code().raw() );

   eosio_assert( token_max_itr != user_tokens_max.end(),
                 "token not protected. please addtokenmax" );
   /****/

   // approve the transfer
   action(
      permission_level{ "chestnutacnt"_n, "active"_n },
      "eosio.msig"_n,
      "approve"_n,
      std::make_tuple( proposer, proposal_name, permission_level{ "chestnutacnt"_n, "active"_n } )
   ).send();



   // action(
   //    permission_level{ from, "active"_n },
   //    token_max_itr->contract_account,
   //    "transfer"_n,
   //    std::make_tuple( from, to, quantity, memo )
   // ).send();
}


EOSIO_DISPATCH( chestnutacnt, (hello)(transfer)(addtokenmax)(rmtokenmax)(addxfrmax)(addwhitelist)(rmwhitelist) )
