# chestnutacnt

```bash
cleos get account chestnutacnt
created: 2019-03-21T00:52:28.500
permissions: 
     owner     1:    1 EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B
        active     1:    1 EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9, 1 chestnutacnt@eosio.code
memory: 
     quota:     19.42 MiB    used:     402.9 KiB  

net bandwidth: 
     staked:          1.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             14.95 KiB  
     available:        18.26 GiB  
     limit:            18.26 GiB  

cpu bandwidth:
     staked:         10.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             1.773 ms   
     available:        5.467 hr   
     limit:            5.467 hr   

producers:     <not voted>
```
```bash
cleos get account daniel
created: 2019-03-21T00:52:35.500
permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     2:    1 chestnutacnt@active, 1 daniel@chestnut
        chestnut     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
memory: 
     quota:     9.321 KiB    used:     4.975 KiB  

net bandwidth: 
     staked:          1.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             1.438 KiB  
     available:        18.26 GiB  
     limit:            18.26 GiB  

cpu bandwidth:
     staked:          1.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             1.916 ms   
     available:         32.8 min  
     limit:             32.8 min  

EOS balances: 
     liquid:         1000.0000 EOS
     staked:            2.0000 EOS
     unstaking:         0.0000 EOS
     total:          1002.0000 EOS

producers:     <not voted>
```

## Tables

### chestnutacnt::tokensmax
   - **asset**: **balance** amount of tokens deposited in account
   - **name**: **contract_account** amount of tokens deposited in account
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice tokensmax
```

### chestnutacnt::xfrmax
   - **asset**: **total_tokens_allowed_to_spend** maximum amount of tokens that can be spent within the time frame
   - **asset**: **current_EOS_spent** current amount of tokens spent
   - **uint64_t**: **minutes**
   - **time_point**: **end_time**
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice xfrmax
```

### chestnutacnt::whitelist
   - **name**: **whitelisted_account** maximum amount of transactions within time frame

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
   - **max_tx** total tokens allowed to spend in given time frame
   - **minutes** time in minutes

   - Set a maxium amount of transfers that can take place within a give time frame

### chestnutacnt::rmxfrmax      [ TODO ]

### chestnutacnt::addwhitelist  [ TODO ]
   - **user** user
   - **account_to_add** account to whitelist

   - Whitelist receiving accounts

### chestnutacnt::rmwhitelist   [ TODO ]
   - **user** user
   - **account_to_remove**

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

