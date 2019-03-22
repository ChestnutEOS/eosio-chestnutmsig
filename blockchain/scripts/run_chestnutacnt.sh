echo '==================================================================='
echo '===                                                             ==='
echo '===         C H E S T N U T  S M A R T  A C C O U N T S         ==='
echo '===                                                             ==='
echo '==================================================================='

echo 'User `daniel` will turn his eos account into a smart account'
echo 'Give daniel an initial EOS balance of 1000.0000 EOS'
cleos push action eosio.token transfer '[ "eosio","daniel","1000.0000 EOS", "starting balance" ]' -p eosio eosio.token; sleep 1

echo '============================================================'
echo '=== New User daniel turns eos account into smart account ==='
echo '===                    MODIFY  PERMISSIONS               ==='
echo '============================================================'

echo 'Add @eosio.code permission to chestnutacnt@active'
cleos push action eosio updateauth '{"account":"chestnutacnt","permission":"active","parent":"owner","auth":{"keys":[{"key":"EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9", "weight":1}],"threshold":1,"accounts":[{"permission":{"actor":"chestnutacnt","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p chestnutacnt@active

echo 'Create @chestnut permission for `daniel` first'
echo '======================================================'
cleos push action eosio updateauth '{"account":"daniel","permission":"chestnut","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}' -p daniel@owner
echo '======================================================'

echo 'Create the multisig active permission with `chestnutacnt@active` and `daniel@chestnut`'
cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[], "threshold":2
,"accounts":[{"permission":{"actor":"chestnutacnt","permission":"active"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":1}],"waits":[]}}' -p daniel

sleep 1
echo 'linkauth of the @chestnut permission to the actions on our smart contract'
cleos push action eosio linkauth '["daniel","chestnutacnt","addtokenmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","rmtokenmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","addxfrmax","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","addwhitelist","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","chestnutacnt","rmwhitelist","chestnut"]' -p daniel@owner
# cleos push action eosio linkauth '["daniel","chestnutacnt","transfer","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","propose","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","approve","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","exec","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","cancel","chestnut"]' -p daniel@owner
sleep 1

echo 'Make sure normal transfers fail with the @chestnut permission'
echo 'cleos push action eosio.token transfer ["daniel","chestnutacnt","10.0000 EOS","memo"] -p daniel@chestnut'
cleos push action eosio.token transfer '["daniel","chestnutacnt","10.0000 EOS","memo"]' -p daniel@chestnut


echo '======================================================'
echo '===                    ACCOUNTS                    ==='
echo '======================================================'
echo 'cleos get account chestnutacnt'
cleos get account chestnutacnt
echo 'cleos get account daniel'
cleos get account daniel
echo '======================================================'
echo 'Make sure eosio.token transfers do NOT work with the @chestnut permission'
echo 'cleos push action eosio.token transfer ["daniel","sally","10.0000 EOS","memo"] -p daniel@chestnut'
cleos push action eosio.token transfer '["daniel","sally","10.0000 EOS","memo"]' -p daniel@chestnut
sleep 1
echo 'Make sure other actions can not be called with the @chestnut permission'
echo 'cleos push action chestnutacnt hello'
cleos push action chestnutacnt hello '[""]' -p daniel@chestnut
sleep 1

echo '========================================================'
echo '===                  ADD TO WHITELIST                ==='
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
echo '`daniel` adds a new EOS token spending limit'
echo 'he does not wish to send more than 50 EOS per transfer'
echo 'cleos push action chestnutacnt addtokenmax ["daniel","50.0000 EOS","eosio.token"] -p daniel@chestnut'
cleos push action chestnutacnt addtokenmax '["daniel","50.0000 EOS","eosio.token"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

# echo '========================================================'
# echo '===              ADD XFR (TRANSFER) MAX              ==='
# echo '========================================================'
# echo '`daniel` does not want to send more than 100 EOS in one minute'
# echo 'cleos push action chestnutacnt addxfrmax ["daniel","100.0000 EOS","1"] -p daniel@chestnut'
# cleos push action chestnutacnt addxfrmax '["daniel","100.0000 EOS","1"]' -p daniel@chestnut
# sleep 1
# echo 'cleos get table chestnutacnt daniel xfrmax'
# cleos get table chestnutacnt daniel xfrmax
# sleep 1

echo '========================================================'
echo '===                 SEND EOS TRANSFER                ==='
echo '========================================================'
echo '`daniel` transfers EOS tokens to `sally`'
echo 'BEFORE: '
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts
sleep 1
echo '========================================================'

echo 'cleos multisig propse `daniel` sends `50.0000 EOS` to `sally`'
# cleos multisig propose [OPTIONS] proposal_name requested_permissions trx_permissions contract action data [proposer] [proposal_expiration]
cleos multisig propose test1 '[{"actor": "chestnutacnt", "permission": "active"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"50.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test1 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutacnt transfer '["daniel","test1"]' -p chestnutacnt@active
sleep 1
# cleos multisig review daniel test1
# sleep 1
echo 'cleos get table eosio.msig daniel approvals2'
cleos get table eosio.msig daniel approvals2
sleep 1
cleos multisig exec daniel test1 -p daniel@chestnut
sleep 1

echo '========================================================'
echo 'AFTER: '
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '============================================='
echo '===           TEST MAX TRASNFERS          ==='
echo '============================================='
echo '2.'
echo 'transfer ["daniel","sally","25.0000 EOS","finding memo"] -p daniel@chestnut'

cleos multisig propose test2 '[{"actor": "chestnutacnt", "permission": "active"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"25.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test2 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutacnt transfer '["daniel","test2"]' -p chestnutacnt@active
sleep 1
cleos multisig exec daniel test2 -p daniel@chestnut

echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '3. Block the third - attempt to transfer 51 EOS'
cleos multisig propose test3 '[{"actor": "chestnutacnt", "permission": "active"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"51.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test3 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutacnt transfer '["daniel","test3"]' -p chestnutacnt@active
sleep 1
#cleos multisig exec daniel test3 -p daniel@chestnut
cleos multisig cancel daniel test3 daniel -p daniel@chestnut

# echo 'cleos get table chestnutacnt daniel xfrmax'
# cleos get table chestnutacnt daniel xfrmax

sleep 1
echo '4. transfer 30 more'
# echo 'transfer time reset by now'
cleos multisig propose test4 '[{"actor": "chestnutacnt", "permission": "active"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"30.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test4 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
'cleos push action chestnutacnt transfer ["daniel","test4"] -p chestnutacnt@active'
cleos push action chestnutacnt transfer '["daniel","test4"]' -p chestnutacnt@active
sleep 1
cleos multisig exec daniel test4 -p daniel@chestnut
sleep 1
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '===================================================='
echo '===  `linkauth` @chestnut with another contract  ==='
echo '===================================================='
cleos multisig propose givemeauth '[{"actor": "chestnutacnt", "permission": "active"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio linkauth '{"account": "daniel", "code": "eosio", "type": "buyram", "requirement": "chestnut"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel givemeauth '{"actor":"daniel", "permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel givemeauth '{"actor":"chestnutacnt", "permission":"active"}' -p chestnutacnt@active
sleep 1
cleos multisig exec daniel givemeauth -p daniel@chestnut
sleep 1

echo ' It works!'
cleos push action eosio buyram '["daniel","daniel","1.0000 EOS"]' -p daniel@chestnut

echo '============================================='
echo '===               CLEAN UP                ==='
echo '============================================='
echo 'cleos push action chestnutacnt rmwhitelist'
cleos push action chestnutacnt rmwhitelist '["daniel","kristina"]' -p daniel@chestnut
cleos push action chestnutacnt rmwhitelist '["daniel","george"]' -p daniel@chestnut
cleos push action chestnutacnt rmwhitelist '["daniel","sally"]' -p daniel@chestnut
sleep 1
echo ''

echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo 'cleos get table eosio.msig daniel approvals2'
cleos get table eosio.msig daniel approvals2

echo 'cleos push action chestnutacnt rmtokenmax ["daniel","4,EOS"] -p daniel@chestnut'
cleos push action chestnutacnt rmtokenmax '["daniel","4,EOS"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutacnt daniel whitelist'
cleos get table chestnutacnt daniel whitelist
sleep 1
# echo 'cleos get table chestnutacnt daniel xfrmax'
# cleos get table chestnutacnt daniel xfrmax
# sleep 1
echo 'cleos get table chestnutacnt daniel tokensmax'
cleos get table chestnutacnt daniel tokensmax

echo '==================================================================='
echo '===                                                             ==='
echo '===                            D O N E                          ==='
echo '===                                                             ==='
echo '==================================================================='
