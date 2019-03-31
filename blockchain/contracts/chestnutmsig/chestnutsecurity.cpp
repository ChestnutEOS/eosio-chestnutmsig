/**
 *  @file chestnutsecurity.cpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
// #include "../eosio.contracts/eosio.msig/include/eosio.msig/eosio.msig.hpp"

#include "chestnutacnt.hpp"
#include "utilities.hpp"


const int64_t  useconds_per_day      = 24 * 3600 * int64_t(1000000);
const int64_t  useconds_per_minute   = 60 * int64_t(1000000);


time_point chestnutacnt::current_time_point() {
   const static time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
   return ct;
}


void chestnutacnt::validate_whitelist( const name from, const name to ) {
      whitelist_table user_whitelist( _self, from.value );
      auto whitelisted = user_whitelist.find( to.value );

      eosio::check( whitelisted != user_whitelist.end() &&
                    whitelisted->whitelisted_account == to ,
                    "receipent is not on the whitelist. blocking transfer");
}


void chestnutacnt::validate_total_transfer_limit( const name from, const asset quantity ) {
   auto sym = quantity.symbol;

   xfr_max_table xfr_table( _self, from.value );
   auto xfr = xfr_table.find( sym.code().raw() );

   if ( xfr == xfr_table.end() ) {
      const char *error = ( "no transfer limit set for "
                            + symbol_to_string( sym )
                            + " token" ).c_str();
      eosio::check( false, error );
   } else {
      // check to see if transfer is within current time frame
      if ( current_time_point() <= xfr->end_time ) {

         const char *error = ( "exceeded maxmimun spending limit of "
                              + xfr->total_tokens_allowed_to_spend.to_string()
                              + " over " + std::to_string(xfr->minutes)
                              + " minute(s), attempted to send "
                              + quantity.to_string() ).c_str();

         eosio::check( quantity + xfr->current_tokens_spent <= xfr->total_tokens_allowed_to_spend, error );

         // increase spent tokens
         xfr_table.modify( xfr, same_payer, [&]( auto& x ) { 
            x.current_tokens_spent = x.current_tokens_spent + quantity;
         });

      } else {
         // current time frame has ended
         time_point ct{ microseconds{ static_cast<int64_t>( current_time() ) } };
         time_point duration{ microseconds{ static_cast<int64_t>( xfr->minutes * useconds_per_minute ) } };

         // reset spent tokens
         xfr_table.modify( xfr, same_payer, [&]( auto& x ) {
            x.current_tokens_spent           = quantity;
            x.end_time                       = ct + duration;
         });
      }
   }
}


void chestnutacnt::validate_single_transfer( const name from, const asset quantity ) {
   auto sym = quantity.symbol;
   eosio::check( sym.is_valid(), "invalid symbol name" );

   tokens_max_table user_tokens_max( _self, from.value );
   auto token_max_itr = user_tokens_max.find( sym.code().raw() );

   eosio::check( token_max_itr != user_tokens_max.end(),
                 "token not protected. please addtokenmax" );

   if ( token_max_itr != user_tokens_max.end() ) {
      // only check if token_max_itr is "unlocked"
      if ( !token_max_itr->is_locked ) {
         // eosio::check( quantity <= token_max_itr->max_transfer,
         //               error );
         if ( quantity > token_max_itr->max_transfer ) {
            const char *error = ( "exceeded maxmimum transfer limit of "
                                  + token_max_itr->max_transfer.to_string()
                                  + " : attempting to send "
                                  + quantity.to_string()
                                  ).c_str();
            eosio::check( false, error );
         }
      }
   } else {
      // print("no token limit imposed\n");
   }
}