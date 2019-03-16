/**
 *  @file chestnutsecurity.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#include "chestnutacnt.hpp"
#include "abieos_numeric.hpp"


time_point chestnutacnt::current_time_point() {
   const static time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
   return ct;
}


void chestnutacnt::validate_transfer( name from, name to, asset quantity ) {
   auto sym = quantity.symbol;
   eosio_assert( sym.is_valid(), "invalid symbol name" );

   tokens_max token_max_table( _self, from.value );
   auto token_max_itr = token_max_table.find( sym.code().raw() );

   if ( token_max_itr != token_max_table.end() ) {
      // only check if token_max_itr is "unlocked"
      if ( !token_max_itr->is_locked ) {
         // eosio_assert( quantity <= token_max_itr->max_transfer,
         //               error );
         if ( quantity > token_max_itr->max_transfer ) {
            const char *error = ( "exceeded maxmimun transfer limit of "
                                  + std::to_string(
                                    token_max_itr->max_transfer.amount )
                                  + " : attempting to send "
                                  + std::to_string( quantity.amount )
                                  ).c_str();
            eosio_assert( false, error );
         }
      }
   } else {
      // print("no token limit imposed\n");
   }
}

void chestnutacnt::set_auth_with_key( const name   user,
                                      const name   permission_name,
                                      const name   permission_parent_name,
                                      const string new_owner_pubkey ) {
   abieos::set_auth_with_key( user, permission_name, permission_parent_name, new_owner_pubkey );
}

void chestnutacnt::set_auth_with_code( const name   user,
                                       const name   permission_name,
                                       const name   permission_parent_name,
                                       const name   code_account,
                                       const name   code_auth ) {
   abieos::set_auth_with_code( user, permission_name, permission_parent_name, code_account, code_auth );
}

