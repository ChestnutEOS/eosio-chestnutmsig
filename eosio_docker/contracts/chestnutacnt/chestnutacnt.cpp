/**
 *  @file chestnutacnt.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#include "chestnutsecurity.cpp"


void chestnutacnt::hello( void ) {
   print("hello world\n");
}

void chestnutacnt::reg( name user,
                        const string& config_public_key,
                        const string& chestnut_public_key ) {
   require_auth( user );

   set_auth_with_key( user, "config"_n, "active"_n, config_public_key );
   set_auth_with_key( user, "chestnut"_n, "active"_n, chestnut_public_key );
   set_auth_with_code( user, "transfer"_n, "active"_n, CONTRACT_ACCOUNT,
                                                       "eosio.code"_n );

   // link auth of user@config to
   //   config::addtokenmax
   //   config::rmtokenmax
   name action_names[2] = { "addtokenmax"_n, "rmtokenmax"_n };

   for ( int i = 0; i < sizeof(action_names)/sizeof(name); i++ ) {
      action(
         permission_level{ user, "active"_n },
         "eosio"_n,
         "linkauth"_n,
         std::make_tuple( user,
                          CONTRACT_ACCOUNT,
                          action_names[i],
                          "config"_n )
      ).send();
   }

   // link auth of user@chestnut to
   //    chestnut::transfer
   action(
      permission_level{ user, "active"_n },
      "eosio"_n,
      "linkauth"_n,
      std::make_tuple( user, CONTRACT_ACCOUNT, "transfer"_n, "chestnut"_n )
   ).send();

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

   // link auth of user@transfer to contract_account::transfer
   action(
      permission_level{ user, "active"_n },
      "eosio"_n,
      "linkauth"_n,
      std::make_tuple( user,
                       token_max_itr->contract_account,
                       "transfer"_n,
                       "transfer"_n )
   ).send();

}


void chestnutacnt::rmtokenmax( name user, symbol sym ) {
   require_auth( user );
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max token_max_table( _self, user.value );
   auto token_max_to_delete = token_max_table.find( sym.code().raw() );

   eosio_assert( token_max_to_delete != token_max_table.end(),
                 "can not find token max to delete" );

   // unlink auth of user@transfer to contract_account::transfer
   action(
      permission_level{ user, "active"_n },
      "eosio"_n,
      "unlinkauth"_n,
      std::make_tuple( user,
                       token_max_to_delete->contract_account,
                       "transfer"_n )
   ).send();

   token_max_table.erase( token_max_to_delete );
}


void chestnutacnt::transfer( name      from,
                             name      to,
                             asset     quantity,
                             string    memo ) {
   require_auth( from );

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
      permission_level{ from, "transfer"_n },
      token_max_itr->contract_account,
      "transfer"_n,
      std::make_tuple( from, to, quantity, memo )
   ).send();
}


EOSIO_DISPATCH( chestnutacnt, (hello)(transfer)(reg)(addtokenmax)(rmtokenmax) )
