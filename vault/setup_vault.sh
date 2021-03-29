#!/bin/sh

### This script needs Vault CLI and jq installed. All other tools are sh native.

_vault=$(which vault)
if [ $? != 0 ]
then
  echo "This script needs the vault cli tool, please install it for your OS: https://www.vaultproject.io/docs/install" 
fi

_jq=$(which jq)
if [ $? != 0 ]
then
  echo "This script needs the jq tool, please install it for your OS." 
fi

### export environment variables and initialize variables.

export VAULT_SKIP_VERIFY=TRUE
export VAULT_ADDR=http://localhost:8200
output_file="vault-setup-output-$(date +'%m-%d-%y-%T').txt"

vault_policy='path "/sys/mounts" {
  capabilities = ["create", "read", "update", "list"]
}

path "/sys/mounts/*" {
  capabilities = ["create", "read", "update", "list"]
}

path "/sys/policy/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/auth/jwt/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}'

### Begin interactive vault setup ###

echo "Welcome to vault quick set-up for Garden Enterprise"
echo "Did you already create a JWT public key with openssl in preperation? [y/n]"
read cert

if [ $cert == "y" ]
then
  echo "Please make sure to copy your private and public key to the directory this script runs in."
  echo "Press Enter to confirm and continue"
  read 
elif [ $cert == "n" ]
then
  echo "Creating a public and private key for you in this directory."
  echo "Please make sure to upload these keys to the replicated console."
  openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365
else
  echo "Invalid answer. Exiting.."
  exit 1
fi

kubectl --namespace garden-enterprise port-forward svc/prod-charts-vault 8200:8200 &
vault_port_forward_pid=$!

sleep 5

vault_status=$(vault status --format json)
echo $vault_status | jq .


if [ $(echo $vault_status | jq .initialized) == "false" ]
then 
  echo "Initializing Vault..."
  vault_init=$(vault operator init --format json)
  echo $vault_init
  echo $vault_init >> $output_file
  vault_root_token=$(echo $vault_init | jq .root_token | tr -d '"')
else
  echo "Vault seems to be already initialized. Please enter Vault root token:"
  read vault_root_token
fi
  
export VAULT_TOKEN=$vault_root_token
echo $VAULT_TOKEN

echo "Enabling and setting JWT auth..."
vault auth enable jwt
vault write auth/jwt/config jwt_validation_pubkeys=@cert.pem
echo "$vault_policy" | vault policy write garden-enterprise -
vault auth enable approle
vault_write_approle=$(curl -v --insecure -X PUT \
  ${VAULT_ADDR}/v1/auth/approle/role/garden-enterprise-approle \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -H "x-vault-token: ${vault_root_token}" \
  -d '{
    "role_name":"garden-enterprise-approle",
    "bind_secret_id": true,
    "token_no_default_policy": true,
    "policies":["garden-enterprise"]
    }')

vault_get_app_role_id=$(curl -v --insecure -X GET \
  ${VAULT_ADDR}/v1/auth/approle/role/garden-enterprise-approle/role-id \
  -H 'cache-control: no-cache' \
  -H "x-vault-token: ${vault_root_token}")
vault_app_role_id=$(echo "$vault_get_app_role_id" | jq .data.role_id)
echo "app role ID: $vault_app_role_id" >> $output_file

vault_create_secret=$(curl -v --insecure -X POST \
  ${VAULT_ADDR}/v1/auth/approle/role/garden-enterprise-approle/secret-id \
  -H 'cache-control: no-cache' \
  -H "x-vault-token: ${vault_root_token}")

vault_secret_id=$(echo "$vault_create_secret" | jq .data.secret_id)
echo "secret ID: $vault_secret_id" >> $output_file

echo "Please note the following values for entering them into the Garden Enterprise admin console."
echo "app role ID: $vault_app_role_id"
echo "secret ID: $vault_secret_id"

echo "Please also take note of your vault root token and recovery keys, which are all written to a file $output_file in this directory"

kill $vault_port_forward_pid
