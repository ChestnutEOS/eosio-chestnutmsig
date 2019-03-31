/**
 *  @file chestnutacnt.hpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#pragma once

#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/time.hpp>
#include <eosiolib/public_key.hpp>

#include <string>

using std::string;

using eosio::action;
using eosio::datastream;
using eosio::permission_level;
using eosio::print;
using eosio::name;
using eosio::asset;
using eosio::time_point;
using eosio::symbol;
using eosio::milliseconds;
using eosio::microseconds;
using eosio::same_payer;


#define CONTRACT_ACCOUNT "chestnutacnt"_n


class [[eosio::contract("chestnutacnt")]] chestnutacnt : public eosio::contract {
private:

   /****************************************************************************
    *                            D A T A  T Y P E S
    ***************************************************************************/

   // eosio::linkauth
   struct link_auth {
      name account;
      name code;
      name type;
      name requirement;
   };

   /****************************************************************************
    *                                T A B L E S
    ***************************************************************************/

   struct [[eosio::table]] token_max {
      asset       max_transfer;
      name        contract_account;
      bool        is_locked{false};

      uint64_t primary_key() const { return max_transfer.symbol.code().raw(); }
   };

   typedef eosio::multi_index< name("tokensmax"), token_max > tokens_max_table;


   struct [[eosio::table]] xfr_max {
      asset       total_tokens_allowed_to_spend;
      asset       current_tokens_spent;
      uint64_t    minutes;
      time_point  end_time;
      bool        is_locked{false};

      auto primary_key() const { return total_tokens_allowed_to_spend.symbol.code().raw(); }
   };

   typedef eosio::multi_index< name("xfrmax"), xfr_max > xfr_max_table;


   struct [[eosio::table]] whitelist {
      name        whitelisted_account;

      auto primary_key() const { return whitelisted_account.value; }
   };

   typedef eosio::multi_index< name("whitelist"), whitelist > whitelist_table;

   /****************************************************************************
    *                            F U N C T I O N S
    ***************************************************************************/

   time_point current_time_point();

   void set_auth_with_key( const name   user,
                           const name   permission_name,
                           const name   permission_parent_name,
                           const string new_owner_pubkey );

   void set_auth_with_code( const name   user,
                            const name   permission_name,
                            const name   permission_parent_name,
                            const name   code_account,
                            const name   code_auth );

   void validate_whitelist( const name from, const name to );

   void validate_total_transfer_limit( const name from, const asset quantity );

   void validate_single_transfer( const name from, const asset quantity );

public:
   using contract::contract;

   // constructor
   chestnutacnt( name receiver, name code, datastream<const char*> ds ):
                 contract( receiver, code, ds ) {}

   /****************************************************************************
    *                              A C T I O N S
    ***************************************************************************/

   ACTION hello( void );

   ACTION giveauth( name proposer, name proposal_name );

   ACTION transfer( name proposer, name proposal_name );

   ACTION addtokenmax( name  user,
                       asset quantity,
                       name  contract_account );

   ACTION rmtokenmax( name user, symbol sym );

   ACTION addxfrmax( name user, asset max_tx, uint64_t minutes );

   ACTION addwhitelist( name user, name account_to_add );

   ACTION rmwhitelist( name user, name account_to_remove );

};
