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
registering his account with the `chestnutacnt` smart contract

To do this `daniel` first creates two new key pairs that he will only
use with his smart account.  One key will be associated with the
`config` permission and can only be used to configure the spending
parameters.  The second key will be associated with the `chestnut`
permission and can only be used for token transfers with the chestnutact
smart contract.  (These key pairs can not be used with
any other eos action like voting, buying/selling ram, or
delegating cpu & net, therefore keeping the user extra secure
from accidents or malicious behavior)

```bash
# for 'chestnut' permission
cleos create key --to-console
Private key: 5JjnmnZba51EemGQudn5n9v791mfaPnSvQHiXyGei9kiiEtrMGi
Public key: EOS6XN6iTUSfW6wf87sQMTpMG4viKZpYDrRiWdQPuBmJd2jQThtcL
```

Daniel needs to allow `chestnutact@eosio.code` control over his active
permission so the contract can set up his account for him.
```bash
cleos set account permission daniel active \
'{"threshold": 1,"keys": [{"key": "EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b","weight": 1}],"accounts": [{"permission":{"actor":"chestnutacnt","permission":"eosio.code"},"weight":1}], "waits":[]}' \
owner -p daniel

```

Next `daniel` associates the new public keys and the chestnut
smart contract with his account, creating the smart account

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
           transfer     1:    1 chestnutacnt@eosio.code
```

`chestnutacnt@eosio.code` was added to the active permission of the account, meaning
the snart contract can sign transactions for `daniel`s account.  This is only necessary
durring smart parameter configuration (with the `config` permission) because when the user
adds more tokens, the transfer permission needs to link auth with the new token
contract. (See https://github.com/EOSIO/eos/issues/2438)

A new permission called `chestnut` has been created that can only be accessed by the
 new private key `daniel` created.  This permission also gets linked to all the
 actions on the chestnut smart contracts.

A new permission called `transfer` has been created that can only be accessed by the
 smart contract code running on chestnutacnt

2. `daniel` now sets up a spending limit of 100.0000 EOS with his `config` key

```bash
cleos push action chestnutacnt addtokenmax '["daniel","100.0000 EOS","eosio.token"]' -p daniel@config
```

3. `daniel` can now send transfers from the chestnutsmart contract using the `chestnut` key

```bash
cleos push action chestnutacnt transfer '["daniel","sally","49.0000 EOS","finding memo"]' -p daniel@chestnut
```

the chestnutacnt contract will check the transfer quantity against the spending limit of 100.0000 EOS
that `daniel` previously setup.  If the quantity is over the limit, the contract will fail the transfer.
If it is successfull the smart contract will the sign the eosio.token::transfer action with
chestnutacnt@eosio.code and the transfer will succeed.
