SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../.. && pwd )"

if [ ! -e "${SOURCE_DIR}/first_time_setup.sh" ]
then
   printf "\n\tScript moved from blockchain/scripts directory.\n\n"
   exit -1
fi

# Make Data Directory
mkdir -p "${SOURCE_DIR}/blockchain/data"

curl --output /dev/null \
    --silent \
    --head \
    --fail \
    localhost:8888

retval=$?
if [ $retval == 0 ]; then
    echo "You have a process already using port 8888, which is preventing nodeos from starting"
    exit 1
fi

# Start Nodeos
nodeos -e -p eosio -d "${SOURCE_DIR}/blockchain/data" \
    --config-dir "${SOURCE_DIR}/blockchain/data/config" \
    --delete-all-blocks \
    --http-validate-host=false \
    --plugin eosio::chain_plugin \
    --plugin eosio::producer_plugin \
    --plugin eosio::chain_api_plugin \
    --plugin eosio::http_plugin \
    --http-server-address=0.0.0.0:8888 \
    --access-control-allow-origin=* \
    --max-transaction-time=1000 \
    --contracts-console \
    --verbose-http-errors > "${SOURCE_DIR}/blockchain/data/nodeos.log" 2>&1 </dev/null &

until $(curl --output /dev/null \
            --silent \
            --head \
            --fail \
            localhost:8888/v1/chain/get_info)
do
    echo "Waiting for EOSIO blockchain to be started..."
    sleep 2s
done

echo "EOSIO Blockchain Started"

# Sleep for 2 to allow time 4 blocks to be created so we have blocks to reference when sending transactions
sleep 2s
echo "=== setup wallet: eosiomain ==="
# First key import is for eosio system account
if [ -e ~/eosio-wallet/eosiomain.wallet ]
then
   rm ~/eosio-wallet/eosiomain.wallet
fi
cleos wallet create -n eosiomain --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > "${SOURCE_DIR}/blockchain/data/eosiomain_wallet_password.txt"
cleos wallet import -n eosiomain --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

echo "=== setup wallet: appwallet ==="
# key for eosio account and export the generated password to a file for unlocking wallet later
if [ -e ~/eosio-wallet/appwallet.wallet ]
then
   rm ~/eosio-wallet/appwallet.wallet
fi
cleos wallet create -n appwallet --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > "${SOURCE_DIR}/blockchain/data/appwallet_wallet_password.txt"

# Keys
#   EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B : 5JpWT4ehouB2FF9aCfdfnZ5AwbQbTtHBAwebRXt94FmjyhXwL4K
#   EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9 : 5JD9AGTuTeD5BXZwGQ5AtwBqHK21aHmYnTetHgk1B3pjj7krT8N

# Owner key for appwallet wallet
cleos wallet import -n appwallet --private-key 5JpWT4ehouB2FF9aCfdfnZ5AwbQbTtHBAwebRXt94FmjyhXwL4K
# Active key for appwallet wallet
cleos wallet import -n appwallet --private-key 5JD9AGTuTeD5BXZwGQ5AtwBqHK21aHmYnTetHgk1B3pjj7krT8N

# `daniels` active/owner private key (see accounts.json)
cleos wallet import -n appwallet --private-key 5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5

# `danels` new chestnut private key
# Private key: 5KXKxwkmvFHffqLVMcopKvJiGArQLUtZfZj5LV43Un3yX2t5kMQ
# Public key: EOS8GKMDqyr9MveUE7RKx11vj2HfS3sMqzn97QtDXd2Fo9X87iB39
cleos wallet import -n appwallet --private-key 5KXKxwkmvFHffqLVMcopKvJiGArQLUtZfZj5LV43Un3yX2t5kMQ

# * Replace "appwallet" by your own wallet name when you start your own project

###############################################################################
#
#   Replace the following: 
#       account name "chestnutacnt" with the account name for your contract
#       contract name "chestnutacnt" with the smart contract name
#
###############################################################################

# create account for eosio.token
cleos create account eosio eosio.token EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9

# create the EOS token
${SOURCE_DIR}/blockchain/scripts/deploy_system_contract.sh eosio.token eosio.token appwallet $(cat "${SOURCE_DIR}/blockchain/data/appwallet_wallet_password.txt")
cleos push action eosio.token create '[ "eosio", "1000000000.0000 EOS"]' -p eosio.token; sleep 1
cleos push action eosio.token issue '[ "eosio", "1000000000.0000 EOS", "init" ]' -p eosio eosio.token; sleep 1

# create account for chestnutacnt with above wallet's public keys
cleos create account eosio chestnutacnt EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9

# * Replace "chestnutacnt" by your own account name when you start your own project

echo "=== deploy smart contract ==="
# $1 smart contract name
# $2 account holder name of the smart contract
# $3 wallet for unlock the account
# $4 password for unlocking the wallet
${SOURCE_DIR}/blockchain/scripts/deploy_contract.sh chestnutacnt chestnutacnt appwallet $(cat "${SOURCE_DIR}/blockchain/data/appwallet_wallet_password.txt")

echo "=== create user accounts ==="
# script for create data into blockchain
${SOURCE_DIR}/blockchain/scripts/create_accounts.sh

# * Replace the script with different form of data that you would pushed into the blockchain when you start your own project
${SOURCE_DIR}/blockchain/scripts/run_chestnutacnt.sh

echo "=== end of setup blockchain accounts and smart contract ==="
# create a file to indicate the blockchain has been initialized
touch "${SOURCE_DIR}/blockchain/data/initialized"

tail -f "${SOURCE_DIR}/blockchain/data/nodeos.log"
