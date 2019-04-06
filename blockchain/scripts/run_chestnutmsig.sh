echo '==================================================================='
echo '===                                                             ==='
echo '===         C H E S T N U T  S M A R T  A C C O U N T S         ==='
echo '===                                                             ==='
echo '==================================================================='

echo 'Give `daniel` an initial EOS balance of 1000.0000 EOS'
cleos push action eosio.token transfer '[ "eosio","daniel","1000.0000 EOS", "starting balance" ]' -p eosio eosio.token; sleep 1
echo 'Give `chestnutmsig` an initial EOS balance of 1000.0000 EOS'
cleos push action eosio.token transfer '[ "eosio","chestnutmsig","1000.0000 EOS", "starting balance" ]' -p eosio eosio.token; sleep 1

echo '===================================================='
echo '===        MODIFY SMART CONTRACT ACCOUNT         ==='
echo '===          `chestnutmsig`                      ==='
echo '===================================================='
echo 'Create @security permission for `chestnutmsig`'
cleos push action eosio updateauth '{"account":"chestnutmsig","permission":"security","parent":"active","auth":{"keys":[],"threshold":1,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p chestnutmsig@active

echo 'linkauth of the @security permission to the `eosio.msig::approve` and `eosio.msig::exec`'
cleos push action eosio linkauth '["chestnutmsig","eosio.msig","approve","security"]' -p chestnutmsig@active
cleos push action eosio linkauth '["chestnutmsig","eosio.msig","exec","security"]' -p chestnutmsig@active

echo '=============================================================='
echo '=== New User `daniel` turns eos account into smart account ==='
echo '===                    MODIFY  PERMISSIONS                 ==='
echo '=============================================================='
echo 'User `daniel` will turn his eos account into a smart account'
echo 'Create @chestnut permission for `daniel` first'
cleos push action eosio updateauth '{"account":"daniel","permission":"chestnut","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}' -p daniel@owner

echo 'Create the multisig active permission with `chestnutmsig@security` and `daniel@chestnut`'
cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[], "threshold":2
,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":1}],"waits":[]}}' -p daniel

echo 'linkauth of the @chestnut permisssion to `eosio.msig`'
cleos push action eosio linkauth '["daniel","eosio.msig","propose","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","approve","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","cancel","chestnut"]' -p daniel@owner

echo 'linkauth of the @chestnut permission to the actions on our smart contract'
cleos push action eosio linkauth '["daniel","chestnutmsig","","chestnut"]' -p daniel@owner

# echo 'No Trusted Recovery'
# cleos push action eosio updateauth '{"account":"daniel","permission":"owner","parent":"","auth":{"keys":[],"threshold":2,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":1}],"waits":[]}}' -p daniel@owner

echo 'Trusted Recovery - add friends `george` and `kristina`'
cleos push action eosio updateauth '{"account":"daniel","permission":"owner","parent":"","auth":{"keys":[],"threshold":4,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":3},{"permission":{"actor":"george","permission":"active"},"weight":1},{"permission":{"actor":"kristina","permission":"active"},"weight":1}],"waits":[{"wait_sec": 7, "weight": 2}]}}' -p daniel@owner

# {"wait_sec": 5, "weight": 3}, {"wait_sec": 10, "weight": 4}

echo 'Make sure normal transfers fail with the @chestnut permission'
echo 'cleos push action eosio.token transfer ["daniel","sally","10.0000 EOS","memo"] -p daniel@chestnut'
cleos push action eosio.token transfer '["daniel","sally","10.0000 EOS","memo"]' -p daniel@chestnut

echo '======================================================'
echo '===                    ACCOUNTS                    ==='
echo '======================================================'
echo 'cleos get account chestnutmsig'
cleos get account chestnutmsig
echo 'cleos get account daniel'
cleos get account daniel

echo '========================================================'
echo '===                  ADD TO WHITELIST                ==='
echo '========================================================'
echo 'cleos push action chestnutmsig addwhitelist ["daniel","sally"] -p daniel@chestnut'
cleos push action chestnutmsig addwhitelist '["daniel","sally"]' -p daniel@chestnut
echo 'cleos push action chestnutmsig addwhitelist ["daniel","george"] -p daniel@chestnut'
cleos push action chestnutmsig addwhitelist '["daniel","george"]' -p daniel@chestnut
echo 'cleos push action chestnutmsig addwhitelist ["daniel","kristina"] -p daniel@chestnut'
cleos push action chestnutmsig addwhitelist '["daniel","kristina"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutmsig daniel whitelist'
cleos get table chestnutmsig daniel whitelist

echo '========================================================'
echo '===             ADD NEW EOS TRANSFER LIMIT           ==='
echo '========================================================'
echo '`daniel` adds a new EOS token spending limit'
echo 'he does not wish to send more than 50 EOS per transfer'
echo 'cleos push action chestnutmsig addtokenmax ["daniel","50.0000 EOS","eosio.token"] -p daniel@chestnut'
cleos push action chestnutmsig addtokenmax '["daniel","50.0000 EOS","eosio.token"]' -p daniel@chestnut
cleos push action chestnutmsig addtokenmax '["daniel","50.0000 PEOS","eosio.token"]' -p daniel@chestnut
cleos push action chestnutmsig addtokenmax '["daniel","60.0000 ABC","eosio.token"]' -p daniel@chestnut
echo 'violates uniqueness'
cleos push action chestnutmsig addtokenmax '["daniel","70.0000 EOS","chestnutmsig"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutmsig daniel tokensmax'
cleos get table chestnutmsig daniel tokensmax

echo '========================================================'
echo '===              ADD XFR (TRANSFER) MAX              ==='
echo '========================================================'
echo '`daniel` does not want to send more than 100 EOS in one minute'
echo 'cleos push action chestnutmsig addxfrmax ["daniel","100.0000 EOS","eosio.token","1"] -p daniel@chestnut'
cleos push action chestnutmsig addxfrmax '["daniel","100.0000 EOS","eosio.token","1"]' -p daniel@chestnut
cleos push action chestnutmsig addxfrmax '["daniel","2500.0000 ABC","eosio.token","1"]' -p daniel@chestnut
echo 'violates uniqueness'
cleos push action chestnutmsig addxfrmax '["daniel","25.0000 ABC","chestnutmsig","1"]' -p daniel@chestnut
sleep 1
echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax
sleep 1

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
cleos multisig propose test1 '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"50.0000 EOS","memo":"test multisig"}' -p daniel@chestnut

# HERE IS HOW TO SEND THE TRANSACTION WITHOUT CLEOS
# cleos --print-request --print-response push action eosio.msig propose '{"proposer": "daniel", "proposal_name": "test1","requested": [{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}], "trx": { "expiration": "2020-04-22T16:39:15", "ref_block_num": 0, "ref_block_prefix": 0, "max_net_usage_words": 0, "max_cpu_usage_ms": 0, "delay_sec": 0, "context_free_actions":[], "actions": [{ "account": "eosio.token", "name": "transfer", "authorization": [{ "actor": "daniel", "permission": "active" }], "data": "0000000044e5a64900000000001fa3c120a107000000000004454f53000000000d74657374206d756c7469736967" }], "transaction_extensions": []    } }' -p daniel@chestnut

# "transaction": {
#    "expiration": "2019-03-22T16:39:15",
#    "ref_block_num": 0,
#    "ref_block_prefix": 0,
#    "max_net_usage_words": 0,
#    "max_cpu_usage_ms": 0,
#    "delay_sec": 0,
#    "context_free_actions": [],
#    "actions": [{
#        "account": "eosio.token",
#        "name": "transfer",
#        "authorization": [{
#            "actor": "daniel",
#            "permission": "active"
#          }
#        ],
#        "data": {
#          "from": "daniel",
#          "to": "sally",
#          "quantity": "50.0000 EOS",
#          "memo": "test multisig"
#        },
#        "hex_data": "0000000044e5a64900000000001fa3c120a107000000000004454f53000000000d74657374206d756c7469736967"
#      }
#    ],
#    "transaction_extensions": []
#  }

sleep 1

cleos multisig approve daniel test1 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
# echo 'cleos get table eosio.msig daniel proposal'
# cleos get table eosio.msig daniel proposal
# sleep 1
# echo 'cleos get table eosio.msig daniel approvals2'
# cleos get table eosio.msig daniel approvals2
# sleep 1
# cleos multisig review daniel test1
# sleep 1
cleos push action chestnutmsig transfer '["daniel","test1"]' -p daniel@chestnut
sleep 1

echo 'AFTER: '
echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '============================================='
echo '===           TEST MAX TRASNFERS          ==='
echo '============================================='
echo '2.'
echo 'transfer ["daniel","sally","25.0000 EOS","finding memo"] -p daniel@chestnut'

cleos multisig propose test2 '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"25.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test2 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutmsig transfer '["daniel","test2"]' -p daniel@chestnut
sleep 1

echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '3. Block the third - attempt to transfer 51 EOS'
cleos multisig propose test3 '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"51.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test3 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutmsig transfer '["daniel","test3"]' -p daniel@chestnut
sleep 1

cleos multisig cancel daniel test3 daniel -p daniel@chestnut

echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax


echo '4. Exceed the 100.00 EOS per minute transfer limit'
echo '   attempt to send 30 EOS (75+30 = 105) !< 100'
cleos multisig propose test4 '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"30.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test4 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutmsig transfer '["daniel","test4"]' -p daniel@chestnut
sleep 1

cleos multisig cancel daniel test4 daniel -p daniel@chestnut


echo 'sleep 60'
sleep 60
echo '5. transfer 30 more'
echo 'transfer time reset by now'
cleos multisig propose test5 '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio.token transfer '{"from":"daniel","to":"sally","quantity":"30.0000 EOS","memo":"test multisig"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel test5 '{"actor":"daniel","permission":"chestnut"}' -p daniel@chestnut
sleep 1
echo 'cleos push action chestnutmsig transfer ["daniel","test5"] -p daniel@chestnut'
cleos push action chestnutmsig transfer '["daniel","test5"]' -p daniel@chestnut
sleep 1

echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax
echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo '===================================================='
echo '===  `linkauth` @chestnut with another contract  ==='
echo '===================================================='
cleos multisig propose givemeauth '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "active"}]' eosio linkauth '{"account": "daniel", "code": "eosio", "type": "buyram", "requirement": "chestnut"}' -p daniel@chestnut
sleep 1
cleos multisig approve daniel givemeauth '{"actor":"daniel", "permission":"chestnut"}' -p daniel@chestnut
sleep 1
cleos push action chestnutmsig giveauth '["daniel","givemeauth"]' -p daniel@chestnut
sleep 1

echo ' It works!'
cleos push action eosio buyram '["daniel","daniel","1.0000 EOS"]' -p daniel@chestnut

echo '======================================================'
echo '===                    RECOVERY                    ==='
echo '======================================================'
# `george` active private key
# Private key: 5KaqYiQzKsXXXxVvrG8Q3ECZdQAj2hNcvCgGEubRvvq7CU3LySK
cleos wallet import -n appwallet --private-key 5KaqYiQzKsXXXxVvrG8Q3ECZdQAj2hNcvCgGEubRvvq7CU3LySK
# `kristina` active private key
# Private key: 5KE2UNPCZX5QepKcLpLXVCLdAw7dBfJFJnuCHhXUf61hPRMtUZg
cleos wallet import -n appwallet --private-key 5KE2UNPCZX5QepKcLpLXVCLdAw7dBfJFJnuCHhXUf61hPRMtUZg
sleep 1

echo 'Change @chestnut key with `daniel` and `kristina`'
cleos multisig propose recoverme '[{"actor": "daniel", "permission": "chestnut"}, {"actor": "kristina", "permission": "active"}]' '[{"actor": "daniel", "permission": "owner"}]' eosio updateauth '{"account": "daniel", "permission": "chestnut", "parent": "owner", "auth": {"keys":[{"key":"EOS5yd9aufDv7MqMquGcQdD6Bfmv6umqSuh9ru3kheDBqbi6vtJ58", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@chestnut

cleos multisig approve daniel recoverme '{"actor": "daniel", "permission": "chestnut"}' -p daniel@chestnut
cleos multisig approve daniel recoverme '{"actor": "kristina", "permission": "active"}' -p kristina@active
cleos multisig exec daniel recoverme -p kristina@active
sleep 1

cleos get account daniel

# Key Pair EOS5yd9aufDv7MqMquGcQdD6Bfmv6umqSuh9ru3kheDBqbi6vtJ58 : 5K2jun7wohStgiCDSDYjk3eteRH1KaxUQsZTEmTGPH4GS9vVFb7
cleos wallet import -n appwallet --private-key 5K2jun7wohStgiCDSDYjk3eteRH1KaxUQsZTEmTGPH4GS9vVFb7

echo 'Change @chestnut key back with `daniel` and `george`'
cleos multisig propose goback '[{"actor": "daniel", "permission": "chestnut"}, {"actor": "george", "permission": "active"}]' '[{"actor": "daniel", "permission": "owner"}]' eosio updateauth '{"account": "daniel", "permission": "chestnut", "parent": "owner", "auth": {"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@chestnut

cleos multisig approve daniel goback '{"actor": "daniel", "permission": "chestnut"}' -p daniel@chestnut
cleos multisig approve daniel goback '{"actor": "george", "permission": "active"}' -p george@active
cleos multisig exec daniel goback -p george@active
sleep 1

cleos get account daniel

# TODO: figure out how "wait" times work
# echo '`george` and `kristina` try to switch @chestnut key'
# cleos multisig propose attack '[{"actor": "george", "permission": "active"}, {"actor": "kristina", "permission": "active"}]' '[{"actor": "daniel", "permission": "owner"}]' eosio updateauth '{"account": "daniel", "permission": "chestnut", "parent": "owner", "auth": {"keys":[{"key":"EOS5yd9aufDv7MqMquGcQdD6Bfmv6umqSuh9ru3kheDBqbi6vtJ58", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p george@active

# cleos multisig approve george attack '{"actor": "george", "permission": "active"}' -p george@active
# cleos multisig approve george attack '{"actor": "kristina", "permission": "active"}' -p kristina@active
# echo 'sleep 10'
# sleep 10
# cleos multisig exec george attack -p george@active
# sleep 1

echo '============================================='
echo '===               CLEAN UP                ==='
echo '============================================='
echo 'cleos push action chestnutmsig rmwhitelist'
cleos push action chestnutmsig rmwhitelist '["daniel","kristina"]' -p daniel@chestnut
cleos push action chestnutmsig rmwhitelist '["daniel","george"]' -p daniel@chestnut
cleos push action chestnutmsig rmwhitelist '["daniel","sally"]' -p daniel@chestnut
sleep 1
echo ''

echo 'cleos get table eosio.token daniel accounts'
cleos get table eosio.token daniel accounts
echo 'cleos get table eosio.token sally accounts'
cleos get table eosio.token sally accounts

echo 'cleos get table eosio.msig daniel approvals2'
cleos get table eosio.msig daniel approvals2

cleos push action chestnutmsig rmtokenmax '["daniel","4,EOS","eosio.token"]' -p daniel@chestnut
cleos push action chestnutmsig rmtokenmax '["daniel","4,ABC","eosio.token"]' -p daniel@chestnut
cleos push action chestnutmsig rmtokenmax '["daniel","4,PEOS","eosio.token"]' -p daniel@chestnut
sleep 1

echo 'cleos get table chestnutmsig daniel whitelist'
cleos get table chestnutmsig daniel whitelist
sleep 1
echo 'cleos get table chestnutmsig daniel xfrmax'
cleos get table chestnutmsig daniel xfrmax
sleep 1
echo 'cleos get table chestnutmsig daniel tokensmax'
cleos get table chestnutmsig daniel tokensmax

echo '==================================================================='
echo '===                                                             ==='
echo '===                            D O N E                          ==='
echo '===                                                             ==='
echo '==================================================================='
