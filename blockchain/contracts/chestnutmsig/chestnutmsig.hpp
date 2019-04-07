/**
 *  @file chestnutmsig.hpp
 *  @author jackdisalvatore
 *  @copyright defined in LICENSE.txt
 */
#pragma once

#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/time.hpp>
#include <eosiolib/transaction.hpp>

#include <string>

using std::string;

using eosio::transaction;
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


#define CONTRACT_ACCOUNT "chestnutmsig"_n


class [[eosio::contract("chestnutmsig")]] chestnutmsig : public eosio::contract {
private:

   /****************************************************************************
    *                            D A T A  T Y P E S
    ***************************************************************************/

   // eosio.token::transfer
   struct token_transfer {
      name from;
      name to;
      asset quantity;
      string memo;
   };

   // eosio.system/include/eosio.system/native.hpp
   struct permission_level_weight {
      permission_level  permission;
      uint16_t          weight;
   };

   struct key_weight {
      eosio::public_key  key;
      uint16_t           weight;
   };

   struct wait_weight {
      uint32_t           wait_sec;
      uint16_t           weight;
   };

   struct authority {
      uint32_t                              threshold = 0;
      std::vector<key_weight>               keys;
      std::vector<permission_level_weight>  accounts;
      std::vector<wait_weight>              waits;
   };

   // eosio::updateauth
   struct update_auth {
      name  account;
      name  permission;
      name  parent;
      authority auth;
   };

   // eosio::linkauth
   struct link_auth {
      name account;
      name code;
      name type;
      name requirement;
   };

   // eosio.msig [[eosio::table]] proposal
   // #include "../eosio.contracts/eosio.msig/include/eosio.msig/eosio.msig.hpp"
   struct proposal {
      name                            proposal_name;
      std::vector<char>               packed_transaction;

      uint64_t primary_key()const { return proposal_name.value; }
   };

   typedef eosio::multi_index< "proposal"_n, proposal > proposals;

   /****************************************************************************
    *                                T A B L E S
    ***************************************************************************/

   struct [[eosio::table]] token_max {
      uint128_t   id;
      asset       max_transfer;
      name        contract_account;
      bool        is_locked{false};

      uint128_t primary_key() const { return id; }
   };

   typedef eosio::multi_index< name("tokensmax"), token_max > tokens_max_table;


   struct [[eosio::table]] xfr_max {
      uint128_t   id;
      asset       total_tokens_allowed_to_spend;
      asset       current_tokens_spent;
      name        contract_account;
      uint64_t    minutes;
      time_point  end_time;
      bool        is_locked{false};

      uint128_t primary_key() const { return id; }
   };

   typedef eosio::multi_index< name("xfrmax"), xfr_max > xfr_max_table;


   struct [[eosio::table]] whitelist {
      name        whitelisted_account;
      bool        is_locked{false};

      auto primary_key() const { return whitelisted_account.value; }
   };

   typedef eosio::multi_index< name("whitelist"), whitelist > whitelist_table;

   /****************************************************************************
    *                            F U N C T I O N S
    ***************************************************************************/

   uint128_t get_token_key( name contract_account, symbol sym ) {
      return ( (uint128_t(contract_account.value) << 64 ) | sym.code().raw() );
   }

   time_point current_time_point();

   void validate_whitelist( const name from, const name to );

   void validate_total_transfer_limit( const name from, const asset quantity, const name contract_account );

   void validate_single_transfer( const name from, const asset quantity, name contract_account );

public:
   using contract::contract;

   // constructor
   chestnutmsig( name receiver, name code, datastream<const char*> ds ):
                 contract( receiver, code, ds ) {}

   /****************************************************************************
    *                              A C T I O N S
    ***************************************************************************/

   ACTION hello( void );

   ACTION leave( name proposer, name proposal_name );

   ACTION giveauth( name proposer, name proposal_name );

   ACTION transfer( name proposer, name proposal_name );

   ACTION addtokenmax( name  user, asset quantity, name  contract_account );

   ACTION rmtokenmax( name user, symbol sym, name contract_account );

   ACTION addxfrmax( name user, asset max_tx, name contract_account, uint64_t minutes );

   ACTION rmxfrmax( name user, symbol sym, name contract_account );

   ACTION addwhitelist( name user, name account_to_add );

   ACTION rmwhitelist( name user, name account_to_remove );

};
