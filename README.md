# chestnut smart accounts

We offer a multi-signature, smart contract enabled "Smart Account" which helps you create a set of rules and safeguards so that your EOS account secures and automates your finances.

One big obstacle to widespread adoption of crypto assets is the fear users have in taking responsibility for managing and protecting their own money. Chestnut takes some of the best security practices from the traditional banking system and bridges them over to the blockchain space, With this, users can feel the same level of safety they have become accustomed to with the autonomy and transparency that the blockchain offers.

Chestnut utilizes a smart contract within a multi-sig account to enable users to set specific and customizable rules or restrictions on the activity, size or type of transactions that can be executed on the account.  Similar to security and fraud protection offerings by traditional credit card companies, Chestnut users can set spending limits, whitelist/ blacklist recipients, freeze the account or nominate beneficiaries in case of emergencies. With Chestnut, users have the benefit of setting their own account rules rather than rules being imposed by a third party institution.

Each account transaction will be cross referenced through our smart contract and if it does not fit the set parameters, Chestnut will not sign off on the transaction as a multi-sig.

At no point does Chestnut require private information and we cannot make changes to a customer’s account unless the change was initiated by the customer.

Chestnut provides the peace of mind that so many blockchain curious members of the general public desire before taking the leap into the world of crypto assets.

### How It Works

When a new user signs up with chestnut, they receive a custom configured eosio account with four key pairs.  Two keys are associated with the owner and active permissions of the
new account and are ment to be kept safely offline and used as backup keys for the account.  The third key is associated with a new `config` permission that will be used for
setting up the parameters of the account.  This key/permission cannot transfer tokens or perform any other eosio action.  The fourth key is associated with a new `chestnut`
permission that is then linked to token transfers on the chestnut smart contract.  The `config` key can be placed into a wallet and used to configure the parameters then removed
and kept offline if the user wishes for a higher level of security.  Then the `chestnut` key can placed into any wallet and the user can safely transfer EOS through the chestnut
smart contract without ever having to worry about making a mistake.


To run
```bash
./start_eosio_docker.sh
```

To shut down press Ctrl+C and run

```bash
./stop_eosio_docker.sh
```


See eosio_docker/contracts/chestnutacnt/README.md for contract details.
