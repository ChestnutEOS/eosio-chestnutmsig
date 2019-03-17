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

// #include "../eosio.contracts/eosio.token/include/eosio.token/eosio.token.hpp"
// #include "../eosio.contracts/eosio.token/src/eosio.token.cpp"

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

#define EOS_SYMBOL symbol("EOS", 4)
#define RAMCORE_SYMBOL symbol("RAMCORE", 4)
#define RAM_SYMBOL symbol("RAM", 0)

#define CONTRACT_ACCOUNT "chestnutacnt"_n

class [[eosio::contract("chestnutacnt")]] chestnutacnt : public eosio::contract {
private:

   /****************************************************************************
    *                            D A T A  T Y P E S
    ***************************************************************************/

   /****************************************************************************
    *                                T A B L E S
    ***************************************************************************/

   TABLE token_max {
      asset       max_transfer;
      name        contract_account;
      bool        is_locked{false};

      uint64_t primary_key() const { return max_transfer.symbol.code().raw(); }
   };

   typedef eosio::multi_index< name("tokensmax"), token_max > tokens_max;

    /****************************************************************************
     *                            F U N C T I O N S
     ***************************************************************************/

   time_point current_time_point();

   void validate_transfer( const name from, const name to, const asset quantity );

   void set_auth_with_key( const name   user,
                           const name   permission_name,
                           const name   permission_parent_name,
                           const string new_owner_pubkey );

   void set_auth_with_code( const name   user,
                            const name   permission_name,
                            const name   permission_parent_name,
                            const name   code_account,
                            const name   code_auth );

public:
   using contract::contract;

   // constructor
   chestnutacnt( name receiver, name code, datastream<const char*> ds ):
                 contract( receiver, code, ds ) {}

   /****************************************************************************
    *                              A C T I O N S
    ***************************************************************************/

   ACTION hello( void );

   ACTION create( name user,
                  const string& chestnut_public_key );

   ACTION transfer( name from, name to, asset quantity, string memo );

   ACTION addtokenmax( name  user,
                       asset quantity,
                       name  contract_account );

   ACTION rmtokenmax( name user, symbol sym );

};
