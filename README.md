# Chestnut Smart Accounts

We offer a multi-signature, smart contract enabled "Smart Account" which helps you create a set of rules and safeguards so that your EOS account secures and automates your finances.

One big obstacle to widespread adoption of crypto assets is the fear users have in taking responsibility for managing and protecting their own money. Chestnut takes some of the best security practices from the traditional banking system and bridges them over to the blockchain space, With this, users can feel the same level of safety they have become accustomed to with the autonomy and transparency that the blockchain offers.

Chestnut utilizes a smart contract within a multi-sig account to enable users to set specific and customizable rules or restrictions on the activity, size or type of transactions that can be executed on the account.  Similar to security and fraud protection offerings by traditional credit card companies, Chestnut users can set spending limits, whitelist/ blacklist recipients, freeze the account or nominate beneficiaries in case of emergencies. With Chestnut, users have the benefit of setting their own account rules rather than rules being imposed by a third party institution.

Each account transaction will be cross referenced through our smart contract and if it does not fit the set parameters, Chestnut will not sign off on the transaction as a multi-sig.

At no point does Chestnut require private information and we cannot make changes to a customer’s account unless the change was initiated by the customer.

Chestnut provides the peace of mind that so many blockchain curious members of the general public desire before taking the leap into the world of crypto assets.


### How It Works


Full Smart Account
```bash
cleos get account daniel

permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     1:    1 chestnutacnt@eosio.code
           chestnut     1:    1 EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
```
Features:
* account is fully secured and protected by chestnut smart contact
    * all interaction with blockchain must go through the chestnut smart contract
* you as a user cannot interact with other dApps or smart contracts that chestnut has yet to integrate with


Full Smart Account + Chestnut Support
```bash
cleos get account daniel

permissions:
     owner     1:    1 chestnutacnt@support
        active     1:    1 chestnutacnt@eosio.code
           chestnut     1:    1 EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
```
Enables the following additional features:
* freeze account
* account recovery


Partial Smart Account
```bash
cleos get account daniel

permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b, 1 chestnutacnt@eosio.code
           chestnut     1:    1 EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
```
Features:
* user can switch between two account permissions
    * active: using their active key users can interact with any dApp or smart contract
        **NOTE: when using this permission, tokens can be transferred without the security of the chestnut smart contract**
    * chestnut: using their chestnut key users can only use send secure transactions through the chestnut smart contract


### To run
```bash
./start_blockchain.sh
```

To shut down press Ctrl+C and run

```bash
./reset_everything.sh
```


See `blockchain/contracts/chestnutacnt/README.md` for contract details.
