echo '==================================================================='
echo '===                                                             ==='
echo '===         C H E S T N U T  S M A R T  A C C O U N T S         ==='
echo '===                                                             ==='
echo '==================================================================='

echo 'import `daniel`s active/owner private key'
echo 'Public key : 5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5'
echo 'Private key: EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b'
cleos wallet import -n appwallet --private-key 5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5

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
echo '
cleos get account daniel

daniel

permissions: 
     owner     4:    1 chestnutmsig@security, 3 daniel@chestnut, 1 george@active, 1 kristina@active
        active     2:    1 chestnutmsig@security, 1 daniel@chestnut
        chestnut     1:    1 EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
        '
echo 'User `daniel` will turn his eos account into a smart account'
echo 'Create @chestnut permission for `daniel` first'
cleos push action eosio updateauth '{"account":"daniel","permission":"chestnut","parent":"owner","auth":{"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}' -p daniel@owner

echo 'Create the multisig active permission with `chestnutmsig@security` and `daniel@chestnut`'
cleos push action eosio updateauth '{"account":"daniel","permission":"active","parent":"owner","auth":{"keys":[], "threshold":2
,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":1}],"waits":[]}}' -p daniel@active

echo 'linkauth of the @chestnut permisssion to `eosio.msig`'
cleos push action eosio linkauth '["daniel","eosio.msig","propose","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","approve","chestnut"]' -p daniel@owner
cleos push action eosio linkauth '["daniel","eosio.msig","cancel","chestnut"]' -p daniel@owner

echo 'linkauth of the @chestnut permission to the actions on our smart contract'
cleos push action eosio linkauth '["daniel","chestnutmsig","","chestnut"]' -p daniel@owner

echo 'Trusted Recovery'
cleos push action eosio updateauth '{"account":"daniel","permission":"owner","parent":"","auth":{"keys":[],"threshold":4,"accounts":[{"permission":{"actor":"chestnutmsig","permission":"security"},"weight":1},{"permission":{"actor":"daniel","permission":"chestnut"},"weight":3},{"permission":{"actor":"george","permission":"active"},"weight":1},{"permission":{"actor":"kristina","permission":"active"},"weight":1}],"waits":[{"wait_sec": 5, "weight": 3}]}}' -p daniel@owner


# cleos multisig propose returntonorm '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "owner"}]' eosio updateauth '{"account": "daniel", "permission": "owner", "parent": "", "auth": {"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@chestnut


# cleos --print-request push action eosio updateauth '{"account": "daniel", "permission": "owner", "parent": "", "auth": {"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@chestnut


# echo '======================================================'
# echo '===                    ACCOUNTS                    ==='
# echo '======================================================'
# echo 'cleos get account chestnutmsig'
# cleos get account chestnutmsig
# echo 'cleos get account daniel'
# cleos get account daniel
# cleos get table eosio daniel userres

# echo '============================================='
# echo '===      RETURN TO NORMAL EOS ACCOUNT     ==='
# echo '============================================='
# echo 'Return from smart account to normal account with chestnutmsig@security'
# cleos --print-request multisig propose returntonorm '[{"actor": "chestnutmsig", "permission": "security"}, {"actor": "daniel", "permission": "chestnut"}]' '[{"actor": "daniel", "permission": "owner"}]' eosio updateauth '{"account": "daniel", "permission": "owner", "parent": "", "auth": {"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@chestnut

# cleos multisig approve daniel returntonorm '{"actor":"daniel", "permission":"chestnut"}' -p daniel@chestnut

# cleos push action chestnutmsig leave '["daniel", "returntonorm"]' -p daniel@chestnut
# sleep 1

# echo 'regain @active control'
# cleos push action eosio updateauth '{"account": "daniel", "permission": "active", "parent": "owner", "auth": {"keys":[{"key":"EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b", "weight":1}],"threshold":1,"accounts":[],"waits":[]}}"}' -p daniel@owner

# echo 'unlinkauth for @chestnut'
# cleos push action eosio unlinkauth '["daniel","chestnutmsig",""]' -p daniel@owner
# cleos push action eosio unlinkauth '["daniel","eosio.msig","propose"]' -p daniel@owner
# cleos push action eosio unlinkauth '["daniel","eosio.msig","approve"]' -p daniel@owner
# cleos push action eosio unlinkauth '["daniel","eosio.msig","cancel"]' -p daniel@owner

# cleos push action eosio unlinkauth '["daniel","eosio","buyram"]' -p daniel@owner

# echo 'deleteauth of @chestnut'
# cleos push action eosio deleteauth '{"account": "daniel", "permission": "chestnut"}' -p daniel@owner
# sleep 1

# echo 'cleos get account daniel'
# cleos get account daniel


echo '==================================================================='
echo '===                                                             ==='
echo '===                            D O N E                          ==='
echo '===                                                             ==='
echo '==================================================================='
