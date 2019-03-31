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
      bool        is_locked{false};

      auto primary_key() const { return whitelisted_account.value; }
   };

   typedef eosio::multi_index< name("whitelist"), whitelist > whitelist_table;

   /****************************************************************************
    *                            F U N C T I O N S
    ***************************************************************************/

   time_point current_time_point();

   void validate_whitelist( const name from, const name to );

   void validate_total_transfer_limit( const name from, const asset quantity );

   void validate_single_transfer( const name from, const asset quantity );

public:
   using contract::contract;

   // constructor
   chestnutmsig( name receiver, name code, datastream<const char*> ds ):
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
