# Chestnut - Smart EOS accounts for automation and security.

We offer a multi-signature, smart contract enabled "Smart Account" which helps you create a set of rules and safeguards so that your EOS account secures and automates your finances.

One big obstacle to widespread adoption of crypto assets is the fear users have in taking responsibility for managing and protecting their own money. Chestnut takes some of the best security practices from the traditional banking system and bridges them over to the blockchain space, With this, users can feel the same level of safety they have become accustomed to with the autonomy and transparency that the blockchain offers.

Chestnut utilizes a smart contract within a multi-sig account to enable users to set specific and customizable rules or restrictions on the activity, size or type of transactions that can be executed on the account.

Similar to security and fraud protection offerings by traditional credit card companies, Chestnut users can set spending limits, whitelist/ blacklist recipients, freeze the account or nominate beneficiaries in case of emergencies. With Chestnut, users have the benefit of setting their own account rules rather than rules being imposed by a third party institution.

Each account transaction will be cross referenced through our smart contract and if it does not fit the set parameters, Chestnut will not sign off on the transaction as a multi-sig.

At no point does Chestnut require private information and we cannot make changes to a customer’s account unless the change was initiated by the customer.

Chestnut will provide the peace of mind that so many blockchain curious members of the general public desire before taking the leap into the world of crypto assets.


### User Story

A new user `daniel` creates a transfer limit of 100.0000 EOS
to pervent him from ever spending more than 100.0000 EOS

1. `daniel` turns his normal eos account into a smart account by
adding the `chestnutacnt@eosio.code` (chestnut smart contract) to
 the acitve permission and calling the `reg` action.

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
cleos push action chestnutacnt reg '["daniel","EOS8GK..."]' -p daniel@active
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

