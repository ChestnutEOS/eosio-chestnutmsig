echo '==================================================================='
echo '===                                                             ==='
echo '===         C H E S T N U T  S M A R T  A C C O U N T S         ==='
echo '===                                                             ==='
echo '==================================================================='

echo 'Give daniel an initial EOS balance of 1000.0000 EOS'
cleos push action eosio.token transfer '[ "eosio","daniel","1000000000.0000 EOS", "starting balance" ]' -p eosio eosio.token; sleep 1

echo 'get account chestnutacnt'
cleos get account chestnutacnt

echo '=== New User daniel ==='
## This needs to all be done external to the smart contract
echo '=== MODIFY PERMISSIONS  ==='
echo 'temporarily give chestnutacnt@eosio.code access to daniel@active'

cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[{"permission":{"actor":"chestnutacnt","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p daniel

sleep 1

# DO IT HERE
echo 'cleos push action chestnutacnt reg ["daniel","EOS8GKM..."] -p daniel@active'
cleos push action chestnutacnt reg '["daniel","EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39"]' -p daniel@active

sleep 1

# echo 'remove chestnutacnt@eosio.code from daniel@active'
# cleos set account permission daniel active \
# '{"threshold": 1,"keys": [{"key": "EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b","weight": 1}],"accounts": [], "waits":[]}' \
# owner -p daniel

sleep 1


echo 'cleos get account daniel'
cleos get account daniel

sleep 1
# echo 'make sure normal transfers do not work'
# echo 'cleos push action eosio.token transfer ["daniel","chestnutacnt","10.0000 EOS","memo"] -p daniel@chesnut'
# cleos push action eosio.token transfer '["daniel","chestnutacnt","10.0000 EOS","memo"]' -p daniel@chestnut
# cleos push action eosio.token transfer '["chestnutacnt","daniel","10.0000 EOS","memo"]' -p chestnutacnt'
# echo 'make sure other actions do not work'
# echo 'cleos push action chestnutacnt hello '
# cleos push action chestnutacnt hello '[""]' -p daniel@chestnut

echo '=== ADD NEW EOS TRANSFER LIMIT ==='
echo 'daniel adds a new EOS token spending limit'
echo 'he does not wish to send more than 100 EOS per transfer'
echo 'cleos push action chestnutacnt addtokenmax ["daniel","100.0000 EOS","eosio.token"] -p daniel@chestnut'
cleos push action chestnutacnt addtokenmax '["daniel","100.0000 EOS","eosio.token"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

echo '=== daniel transfers 99 EOS through chestnutacnt to sally ==='
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
echo 'cleos push action chestnutacnt transfer ["daniel","sally","99.0000 EOS","finding memo"] -p daniel@chestnut'
cleos push action chestnutacnt transfer '["daniel","sally","99.0000 EOS","finding memo"]' -p daniel@chestnut
sleep 1
echo 'after: '
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '=== CLEAN UP ==='
sleep 1
echo 'cleos push action chestnutacnt rmtokenmax ["daniel","4,EOS"] -p daniel@chestnut'
cleos push action chestnutacnt rmtokenmax '["daniel","4,EOS"]' -p daniel@chestnut
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

echo '==================================================================='
echo '===                                                             ==='
echo '===                            D O N E                          ==='
echo '===                                                             ==='
echo '==================================================================='
