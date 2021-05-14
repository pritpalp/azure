#!/bin/bash -e

# This script will check the redis password for non URL safe characters and regenerate if any are found.
# You need to have logged in via Azure CommandLine (az-cli)
#
# Required parameters: resource group name, name of Redis cache
#
# Example: ./redis_password.sh myresourcegroup my-redis

key=$(az redis list-keys -g $1 -n $2 -o tsv| awk -F ' ' '{print $1}')

if [[ "$key" =~ [^0-9A-Za-z\=]+ ]] ; then
  echo "We need a new password, regenerating now"
  while [[ "$key" =~ [^0-9A-Za-z\=]+ ]]
  do
    key=$(az redis regenerate-keys --key-type Primary -g $1 -n $2 -o tsv| awk -F ' ' '{print $1}')
  done
  echo "Primary Redis key is now: $key"
else
  echo "Password is ok, nothing done"
fi