#!/bin/bash -e
#
# Script to update the firewalls on mysql the ip's of the webapps
#
# Note that you may need to add a firewall entry to an instance before using this script,
# otherwise the empty string can cause it to fail to add ip's
#
# Inputs:
# Resource group
#
# Example: ./set_redis_mysql.sh rgtest testwebapp testmysql

webApp=$2
gpMysql=$3

webAppOutboundIPs=$(az webapp show -g $1 -n ${webApp} --query possibleOutboundIpAddresses -o tsv)

webAppIPList=$(echo ${iwebAppOutboundIPs} | tr "," "\n")

echo "Firewall setting for ${gpMysql}"
gpFirewallList=$(az mysql server firewall-rule list -g $1 -s ${gpMysql} | grep -i startipaddress)
for ip in ${webAppIPList}
do
    if [[ ${gpFirewallList} != *"${ip}"* ]]; then
        echo "Adding rule for ${ip}"
        addRule=$(az mysql server firewall-rule create -g $1 -s ${gpMysql} --name Rule_${1}_${ip//./} --start-ip-address ${ip} --end-ip-address ${ip})
    fi
done
