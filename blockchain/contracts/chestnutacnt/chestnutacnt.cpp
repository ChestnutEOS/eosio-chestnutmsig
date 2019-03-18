/**
 *  @file chestnutacnt.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#include "chestnutsecurity.cpp"


void chestnutacnt::hello( void ) {
   print("hello world\n");
}

void chestnutacnt::create( name user,
                           const string& chestnut_public_key ) {
   require_auth( user );

   set_auth_with_key( user, "chestnut"_n, "active"_n, chestnut_public_key );

   // link auth of user@chestnut to
   //   config::addtokenmax
   //   config::rmtokenmax
   name action_names[4] = { "addtokenmax"_n,
                            "rmtokenmax"_n,
                            "addxfrmax"_n,
                            "transfer"_n };

   for ( int i = 0; i < sizeof(action_names)/sizeof(name); i++ ) {
      action(
         permission_level{ user, "active"_n },
         "eosio"_n,
         "linkauth"_n,
         std::make_tuple( user,
                          CONTRACT_ACCOUNT,
                          action_names[i],
                          "chestnut"_n )
      ).send();
   }

}


void chestnutacnt::addtokenmax( name  user,
                                asset quantity,
                                name  contract_account ) {
   require_auth( user );

   auto sym = quantity.symbol;
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max token_max_table( _self, user.value );
   auto token_max_itr = token_max_table.find( sym.code().raw() );

   if ( token_max_itr == token_max_table.end() ) {
      token_max_itr = token_max_table.emplace( user, [&]( auto& tk ) {
         tk.max_transfer      = quantity;
         tk.contract_account  = contract_account;
      });
   } else {
      token_max_table.modify( token_max_itr, same_payer, [&]( auto& tk ) {
         tk.max_transfer      = quantity;
        });
   }

}


void chestnutacnt::rmtokenmax( name user, symbol sym ) {
   require_auth( user );
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max token_max_table( _self, user.value );
   auto token_max_to_delete = token_max_table.find( sym.code().raw() );

   eosio_assert( token_max_to_delete != token_max_table.end(),
                 "can not find token max to delete" );

   token_max_table.erase( token_max_to_delete );
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


void chestnutacnt::transfer( name      from,
                             name      to,
                             asset     quantity,
                             string    memo ) {
   require_auth( from );

   validate_total_transfer_limit( from, quantity );
   validate_transfer( from, to, quantity);

   /****/
   auto sym = quantity.symbol;
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max token_max_table( _self, from.value );
   auto token_max_itr = token_max_table.find( sym.code().raw() );

   eosio_assert( token_max_itr != token_max_table.end(),
                 "token not protected. please addtokenmax" );
   /****/

   action(
      permission_level{ from, "active"_n },
      token_max_itr->contract_account,
      "transfer"_n,
      std::make_tuple( from, to, quantity, memo )
   ).send();
}


EOSIO_DISPATCH( chestnutacnt, (hello)(transfer)(create)(addtokenmax)(rmtokenmax)(addxfrmax) )
