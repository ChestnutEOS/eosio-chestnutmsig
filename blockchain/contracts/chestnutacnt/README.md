# chestnutacnt


## Tables

### chestnutacnt::tokensmax
   - **asset**: **balance** amount of tokens deposited in account
   - **name**: **contract_account** amount of tokens deposited in account
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice tokensmax
```

### chestnutacnt::xfrmax    [ TODO ]
   - **symbol**: **sym** token symbol to be protected
   - **uint64_t**: **current_tx** current amount of transactions within time frame
   - **uint64_t**: **max_tx** maximum amount of transactions within time frame
   - **uint64_t**: **minutes** time frame in minutes
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice xfrmax
```

### chestnutacnt::whitelist     [ TODO ]
   - **name[]**: **whitelisted_account** maximum amount of transactions within time frame
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice whitelist
```

### chestnutacnt::unstaketime   [ TODO ]
    - **uint32_t**: **days** 0, 1, 3, 7, or 30 days
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice unstaketime
```

## Actions

### chestnutacnt::create    user chestnut_public_key
   - **user** the smart account user
   - **chestnut_public_key** smart account `chestnut` public key

   - creates new smart account

ex:
```
cleos push action chestnutacnt create '["alice","EOS_ACTIVE_PUBILC_KEY"]' -p alice@chestnut
```

### chestnutacnt::transfer    from to quantity memo
   - **from** sender
   - **to** receiver
   - **quantity** amount and symbol
   - **memo** optional memo

   - transfer tokens (smart contract will send if security check passes)

ex:
```
cleos push action chestnutacnt transfer '["alice","bob","100.0000 EOS","memo"]' -p alice@chestnut
```

### chestnutacnt::unstake    todo
   - **from** sender

ex:
```
cleos push action chestnutacnt unstake '["",""]' -p alice@chestnut
```

Token Security Settings
### chestnutacnt::addtokenmax
   - **user** user
   - **quantity** maximum token quantity that can be transfered at once
   - **contract_account** account name running the token

   - Set maximum single token transfer

### chestnutacnt::addxfrmax     [ TODO ]
   - **user** user
   - **sym** token symbol to protect
   - **max_tx** maximum amount of transactions within time frame
   - **minutes** time in minutes

   - Set a maxium amount of transfers that can take place within a give time frame

### chestnutacnt::rmxfrmax      [ TODO ]

### chestnutacnt::addwhitelist  [ TODO ]
   - **user** user
   - **account_to_whitelist** account to whitelist

   - Whitelist receiving accounts

### chestnutacnt::rmwhitelist   [ TODO ]
   - **user** user
   - **account_to_remove_from_whitelist**

   - Remove account from whitelist

### chestnutacnt::setunstake    [ TODO ]
   - **user** user
   - **days** 0, 1, 3, 7, or 30 days

   - Set unstaking time


### User Story

A new user `daniel` creates a transfer limit of 100.0000 EOS
to pervent him from ever spending more than 100.0000 EOS

1. `daniel` turns his normal eos account into a smart account by
adding the `chestnutacnt@eosio.code` (chestnut smart contract) to
 the acitve permission and calling the `create` action.

`daniel` first adds `chestnutact@eosio.code` to his active permission
```bash
cleos set account permission daniel active \
'{"threshold": 1,"keys": [{"key": "EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b","weight": 1}],"accounts": [{"permission":{"actor":"chestnutacnt","permission":"eosio.code"},"weight":1}], "waits":[]}' \
owner -p daniel

```

`daniel` can either use his active key or create a new key to use with his smart account
```bash
# for 'chestnut' permission
cleos create key --to-console
Private key: 5KXKxwkmvFHffqLVMcopKvJiGArQLUtZfZj5LV43Un3yX2t5kMQ
Public key: EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
```

Finally `daniel` creates the smart account.

```bash
cleos push action chestnutacnt create '["daniel","EOS8GK..."]' -p daniel@active
```

Now `daniel`'s smart account should look like

```bash
cleos get account daniel

permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b, 1 chestnutacnt@eosio.code
           chestnut     1:    1 EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
```

`chestnutacnt@eosio.code` was added to the active permission of the account, meaning
the smart contract can sign transactions for `daniel`s account.

A new permission called `chestnut` has been created that can only be accessed by the
 new private key `daniel` created.  This permission also gets linked to all the
 actions on the chestnut smart contracts.

2. `daniel` now sets up a spending limit of 100.0000 EOS with his `chestnut` key

```bash
cleos push action chestnutacnt addtokenmax '["daniel","100.0000 EOS","eosio.token"]' -p daniel@chestnut
```

3. `daniel` can now send transfers from the chestnutsmart contract using the `chestnut` key

```bash
cleos push action chestnutacnt transfer '["daniel","sally","49.0000 EOS","finding memo"]' -p daniel@chestnut
```

the chestnutacnt contract will check the transfer quantity against the spending limit of 100.0000 EOS
that `daniel` previously setup.  If the quantity is over the limit, the contract will fail the transfer.
If it is successfull the smart contract will the sign the eosio.token::transfer action with
chestnutacnt@eosio.code and the transfer will succeed.

