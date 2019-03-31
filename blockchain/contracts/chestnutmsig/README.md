# chestnutacnt

```bash
cleos get account chestnutacnt
created: 2019-03-21T00:52:28.500
permissions: 
     owner     1:    1 EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B
        active     1:    1 EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9
           security     1:    1 chestnutacnt@eosio.code
memory: 
     quota:     19.42 MiB    used:       302 KiB  

net bandwidth: 
     staked:          1.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             12.45 KiB  
     available:        18.26 GiB  
     limit:            18.26 GiB  

cpu bandwidth:
     staked:         10.0000 EOS           (total stake delegated from account to self)
     delegated:       0.0000 EOS           (total staked delegated to account from others)
     used:             2.166 ms   
     available:        5.467 hr   
     limit:            5.467 hr   

producers:     <not voted>
```
```bash
cleos get account daniel
created: 2019-03-21T00:52:35.500
permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     2:    1 chestnutacnt@security, 1 daniel@chestnut
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

   - maximum account of tokens that can be transfered at once

ex:
```
cleos get table chestnutacnt alice tokensmax
```

### chestnutacnt::whitelist
   - **name**: **whitelisted_account** maximum amount of transactions within time frame

   - whitelist of accounts that are allow to receive token transfers

ex:
```
cleos get table chestnutacnt alice whitelist
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

### chestnutacnt::unstaketime   [ TODO ]
   - **uint32_t**: **days** 0, 1, 3, 7, or 30 days
   - **bool**: **is_locked** toggles action on/off

ex:
```
cleos get table chestnutacnt alice unstaketime
```

## Actions

### chestnutacnt::transfer    proposer proposal_name
   - **proposer** user who proposed the token transfer
   - **proposal_name** proposal name of mult-sig transaction

   - transfer tokens (smart contract will send if security check passes)

ex:
```
cleos push action chestnutacnt transfer '["alice","bob","100.0000 EOS","memo"]' -p alice@chestnut
```

Token Security Settings
### chestnutacnt::addtokenmax
   - **user** user
   - **quantity** maximum token quantity that can be transfered at once
   - **contract_account** account name running the token

   - Set maximum single token transfer

### chestnutacnt::addxfrmax
   - **user** user
   - **max_tx** total tokens allowed to spend in given time frame
   - **minutes** time in minutes

   - Set a maxium amount of transfers that can take place within a give time frame

### chestnutacnt::addwhitelist
   - **user** user
   - **account_to_add** account to whitelist

   - Whitelist receiving accounts

### chestnutacnt::rmwhitelist
   - **user** user
   - **account_to_remove**

   - Remove account from whitelist

---
## How To Run

Setup:
A new user `daniel` creates a transfer limit of 100.0000 EOS
to pervent him from ever spending more than 100.0000 EOS at once

1. `daniel` turns his normal eos account into a smart account by
creating a `@chestnut` permission.  Then `daniel` uses his `@chestnut`
permission to turn his `@active` permission into a multi-sig with the
new `@chestnut` permission and our `chestnutacnt@security` permission.

*`daniel` creates `daniel@chestnut`*
```bash
cleos push action eosio updateauth '{"account":"daniel","permission":"chestnut","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}' -p daniel@owner
```

*`daniel` turns his active permission into a multi-sig between `chestnutacnt@security` and `daniel@chestnut`*
```bash
cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[], "threshold":2
,"accounts":[{"permission":{"actor":"chestnutacnt","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":1}],"waits":[]}}' -p daniel
```

2. `daniel` links the @chestnut permission with all the smart acontract actions he wishes to have access too
```bash
cleos push action eosio linkauth '["daniel","chestnutacnt","addtokenmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","rmtokenmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","addxfrmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","addwhitelist","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","rmwhitelist","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","transfer","chestnut"]' -p daniel@owner

cleos push action eosio linkauth '["daniel","eosio.msig","propose","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","approve","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","cancel","chestnut"]' -p daniel@owner
```

`daniel`'s smart account should look like
```bash
cleos get account daniel

created: 2019-03-21T00:52:35.500
permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b # NULL'ed out if no admin privileges (eosio.null@active)
        active     2:    1 chestnutacnt@security, 1 daniel@chestnut
        chestnut     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
```

3. `daniel` now imports the `@chestnut` key into his wallet

4. `daniel` sets up his whitelist
```bash
cleos push action chestnutacnt addwhitelist '["daniel","sally"]' -p daniel@chestnut
cleos push action chestnutacnt addwhitelist '["daniel","george"]' -p daniel@chestnut
```

5. `daniel` sets up a transfer limit of 100.0000 EOS
```bash
cleos push action chestnutacnt addtokenmax '["daniel","100.0000 EOS","eosio.token"]' -p daniel@chestnut
```

6. `daniel` sets up a spending limit of 1000.0000 EOS over 1 day (1440 minutes)
```bash
cleos push action chestnutacnt addxfrmax '["daniel","1000.0000 EOS","1440"]' -p daniel@chestnut
```

Token Transfers:

1. `daniel` can now propose a multi-sig token transfer
```bash
cleos multisig propose test1 '[{"actor": "chestnutacnt", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"99.0000 EOS","memo":"test multisig"}' -p daniel@chestnut

```

2. `daniel` signs his half of the transaction
```bash
cleos multisig approve daniel test1 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
```

3. `daniel`  calls our smart contract to validate the token transfer proposal
If the transfer passes the security checks then `chestnutacnt@eosio.code` will sign for `chestnutacnt@security` completing the required permission for the mutlti-sig.
Then it will automatically execute the transfer
```bash
cleos push action chestnutacnt transfer '["daniel","test1"]' -p daniel@chestnut
```

the chestnutacnt contract will check the transfer quantity against the spending limit of 100.0000 EOS
that `daniel` previously setup.  If the quantity is over the limit, the contract will fail the transfer.
If it is successfull the smart contract will the sign the multi-sig transaction with
chestnutacnt@security and will automatically execute the transfer.
