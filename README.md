# Chestnut Smart Accounts

We offer a multi-signature, smart contract enabled "Smart Account" which helps you create a set of rules and safeguards so that your EOS account secures and automates your finances.

One big obstacle to widespread adoption of crypto assets is the fear users have in taking responsibility for managing and protecting their own money. Chestnut takes some of the best security practices from the traditional banking system and bridges them over to the blockchain space, With this, users can feel the same level of safety they have become accustomed to with the autonomy and transparency that the blockchain offers.

Chestnut utilizes a smart contract within a multi-sig account to enable users to set specific and customizable rules or restrictions on the activity, size or type of transactions that can be executed on the account.  Similar to security and fraud protection offerings by traditional credit card companies, Chestnut users can set spending limits, whitelist/ blacklist recipients, freeze the account or nominate beneficiaries in case of emergencies. With Chestnut, users have the benefit of setting their own account rules rather than rules being imposed by a third party institution.

Each account transaction will be cross referenced through our smart contract and if it does not fit the set parameters, Chestnut will not sign off on the transaction as a multi-sig.

At no point does Chestnut require private information and we cannot make changes to a customer’s account unless the change was initiated by the customer.

Chestnut provides the peace of mind that so many blockchain curious members of the general public desire before taking the leap into the world of crypto assets.


### How It Works

Welcome to Chestnut Smart Accounts on EOS!
Chestnut allows you to convert a normal eosio accounts' active permission into a multi-signature permission requiring signatures from both your private key and our smart contract.

Features:
* accounts' `@active` permission cannot be changed by malicious dApps
* token transfers are protected by the `chestnutacnt` Smart Contact
* you can use any other Chestnut approved dApp by linking the `@chestnut` permission with other dApps after completing a multisig request with our `chestnutacnt@security` account
* if the user decideds to keeps their owner key then they can recover their own account.  If they wanted to trust us to 
  recover as well then add `chestnutacnt@active` to the owner permission and maintain joint custody.


#### Retain admin / recovery privileges yourself by keeping your owner key
```bash
cleos get account smartaccount
created: 2019-03-21T00:52:35.500
permissions: 
     owner     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     2:    1 chestnutacnt@security, 1 smartaccount@chestnut
        chestnut     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
```

#### Multi-sig admin priviledges with the `chestnutacnt` and beneficiary
```bash
cleos get account smartaccount
created: 2019-03-21T00:52:35.500
permissions: 
     owner     2:    1 beneficiary@owner, 1 chestnutacnt@active, 1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        active     2:    1 chestnutacnt@security, 1 smartaccount@chestnut
        chestnut     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
```



### To Run Demo

To run for the first time
```bash
./first_time_setup.sh
```

after just run

```bash
./start_blockchain.sh
```

To shut down press Ctrl+C and run

```bash
./reset_everything.sh
```


See `blockchain/contracts/chestnutacnt/README.md` for contract details.
