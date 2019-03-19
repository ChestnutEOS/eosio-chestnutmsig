echo '==================================================================='
echo '===                                                             ==='
echo '===         C H E S T N U T  S M A R T  A C C O U N T S         ==='
echo '===                                                             ==='
echo '==================================================================='

echo 'Give daniel an initial EOS balance of 1000.0000 EOS'
cleos push action eosio.token transfer '[ "eosio","daniel","1000000000.0000 EOS", "starting balance" ]' -p eosio eosio.token; sleep 1

echo '============================================================'
echo '=== New User daniel turns eos account into smart account ==='
## This needs to all be done external to the smart contract
echo '===                    MODIFY  PERMISSIONS               ==='
echo '============================================================'
echo 'Give chestnutacnt@eosio.code access to daniel@active'
cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[{"permission":{"actor":"chestnutacnt","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p daniel
sleep 1
echo 'Create the smart account'
echo 'cleos push action chestnutacnt create ["daniel","EOS8GKM..."] -p daniel@active'
cleos push action chestnutacnt create '["daniel","EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39"]' -p daniel@active
sleep 1

echo '======================================================'
echo '===                    ACCOUNTS                    ==='
echo '======================================================'
echo 'cleos get account chestnutacnt'
cleos get account chestnutacnt
echo 'cleos get account daniel'
cleos get account daniel

sleep 1
echo 'Make sure normal transfers still work with the @active permission'
echo 'cleos push action eosio.token transfer ["daniel","chestnutacnt","10.0000 EOS","memo"] -p daniel@active'
cleos push action eosio.token transfer '["daniel","chestnutacnt","10.0000 EOS","memo"]' -p daniel@active
cleos push action eosio.token transfer '["chestnutacnt","daniel","10.0000 EOS","memo"]' -p chestnutacnt
sleep 1
echo 'Make sure smart transfers do NOT work with the @active permission or @chestnut permission'
echo 'cleos push action eosio.token transfer ["daniel","chestnutacnt","10.0000 EOS","memo"] -p daniel@active'
cleos push action chestnutacnt transfer '["daniel","chestnutacnt","10.0000 EOS","memo"]' -p daniel@active
echo 'cleos push action eosio.token transfer ["daniel","chestnutacnt","10.0000 EOS","memo"] -p daniel@chestnut'
cleos push action chestnutacnt transfer '["daniel","chestnutacnt","10.0000 EOS","memo"]' -p daniel@chestnut
sleep 1
echo 'Make sure other actions can not be called with the @chestnut permission'
echo 'cleos push action chestnutacnt hello'
cleos push action chestnutacnt hello '[""]' -p daniel@chestnut

echo '========================================================'
echo '===              ADD `sally` TO WHITELIST            ==='
echo '========================================================'
echo 'cleos push action chestnutacnt addwhitelist ["daniel","sally"] -p daniel@chestnut'
cleos push action chestnutacnt addwhitelist '["daniel","sally"]' -p daniel@chestnut
echo 'cleos push action chestnutacnt addwhitelist ["daniel","george"] -p daniel@chestnut'
cleos push action chestnutacnt addwhitelist '["daniel","george"]' -p daniel@chestnut
echo 'cleos push action chestnutacnt addwhitelist ["daniel","kristina"] -p daniel@chestnut'
cleos push action chestnutacnt addwhitelist '["daniel","kristina"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel whitelist'
cleos get table chestnutacnt daniel whitelist

echo '========================================================'
echo '===             ADD NEW EOS TRANSFER LIMIT           ==='
echo '========================================================'
echo 'daniel adds a new EOS token spending limit'
echo 'he does not wish to send more than 100 EOS per transfer'
echo 'cleos push action chestnutacnt addtokenmax ["daniel","100.0000 EOS","eosio.token"] -p daniel@chestnut'
cleos push action chestnutacnt addtokenmax '["daniel","100.0000 EOS","eosio.token"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

echo '========================================================'
echo '===              ADD XFR (TRANSFER) MAX              ==='
echo '========================================================'
echo 'cleos push action chestnutacnt addxfrmax ["daniel","10.0000 EOS","1"] -p daniel@chestnut'
cleos push action chestnutacnt addxfrmax '["daniel","10.0000 EOS","1"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel xfrmax'
cleos get table chestnutacnt daniel xfrmax
sleep 1

echo '========================================================'
echo '===                 SEND EOS TRANSFER                ==='
echo '========================================================'
echo '`daniel` transfers EOS tokens through chestnutacnt to sally'
# echo 'this should fail'
# echo 'cleos push action chestnutacnt transfer ["daniel","sally","100.0001 EOS","finding memo"] -p daniel@chestnut'
# cleos push action chestnutacnt transfer '["daniel","sally","100.0001 EOS","finding memo"]' -p daniel@chestnut
# sleep 1
echo 'this should pass'
echo 'before: '
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts
sleep 1
echo 'cleos push action chestnutacnt transfer ["daniel","sally","5.0000 EOS","finding memo"] -p daniel@chestnut'
cleos push action chestnutacnt transfer '["daniel","sally","5.0000 EOS","finding memo"]' -p daniel@chestnut
sleep 1
echo 'after: '
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '============================================='
echo '===           TEST MAX TRASNFERS          ==='
echo '============================================='
echo '2.'
echo 'cleos push action chestnutacnt transfer ["daniel","sally","4.0000 EOS","finding memo"] -p daniel@chestnut'
cleos push action chestnutacnt transfer '["daniel","sally","4.0000 EOS","finding memo"]' -p daniel@chestnut
sleep 1
echo 'Block the third'
echo 'cleos push action chestnutacnt transfer ["daniel","sally","2.0000 EOS","finding memo"] -p daniel@chestnut'
cleos push action chestnutacnt transfer '["daniel","sally","2.0000 EOS","finding memo"]' -p daniel@chestnut
sleep 1

# sleep 60
# echo 'transfer time reset by now'
# echo 'cleos push action chestnutacnt transfer ["daniel","sally","2.0000 EOS","finding memo"] -p daniel@chestnut'
# cleos push action chestnutacnt transfer '["daniel","sally","2.0000 EOS","finding memo"]' -p daniel@chestnut
# sleep 1
# echo 'cleos push action chestnutacnt transfer ["daniel","sally","9.0000 EOS","finding memo"] -p daniel@chestnut'
# cleos push action chestnutacnt transfer '["daniel","sally","9.0000 EOS","finding memo"]' -p daniel@chestnut
# sleep 1

echo '============================================='
echo '===               CLEAN UP                ==='
echo '============================================='
echo 'cleos push action chestnutacnt rmwhitelist'
cleos push action chestnutacnt rmwhitelist '["daniel","kristina"]' -p daniel@chestnut
cleos push action chestnutacnt rmwhitelist '["daniel","george"]' -p daniel@chestnut
cleos push action chestnutacnt rmwhitelist '["daniel","sally"]' -p daniel@chestnut
sleep 1
echo 'cleos push action chestnutacnt rmtokenmax ["daniel","4,EOS"] -p daniel@chestnut'
cleos push action chestnutacnt rmtokenmax '["daniel","4,EOS"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel whitelist'
cleos get table chestnutacnt daniel whitelist
sleep 1
echo 'cleos get table chestnutacnt daniel xfrmax'
cleos get table chestnutacnt daniel xfrmax
sleep 1
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

echo '==================================================================='
echo '===                                                             ==='
echo '===                            D O N E                          ==='
echo '===                                                             ==='
echo '==================================================================='
