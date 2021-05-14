#!/bin/bash -e

# This script sets the diagnostic for a webapp - ending the logs to the Log Analytics workspace
# Note that the setting is in preview, so values may change
# 
# Inputs:
# Setting name
# Webapp name
# Resource Group
# Subscription Id
#
# Example:
# ./set_diagnostic.sh my_diag_logs myapp myresourcegrp subscription_id
# TODO - loop through the webapps in a resource group and aaply to all rather than individual apps

# Need to have four parameters, a name for the setting, the webapp name, resource group and the subscription id
if [[ $# -eq 0 ]]; then
  echo "Enter the following parameters in order: a name for the setting, the webapp name, resource group and the subscription id"
  exit 1
fi

settingname=$1
webapp=$2
resourcegroup=$3
subscriptionid=$4
resourceid=/subscriptions/$subscriptionid/resourceGroups/$resourcegroup/providers/Microsoft.Web/sites/$webapp
workspaceid=/subscriptions/$subscriptionid/resourcegroups/ccow-mgmt/providers/microsoft.operationalinsights/workspaces/ccow-management

az monitor diagnostic-settings create \
  --name $settingname \
  --resource $resourceid \
  --workspace $workspaceid \
  --logs '[{"category": "AppServiceHTTPLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceAntivirusScanAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceConsoleLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceAppLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceFileAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServiceIPSecAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}},{"category": "AppServicePlatformLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 90}}]' \
  --metrics '[{"category": "AllMetrics","enabled": true,"retentionPolicy": {"days": 90,"enabled": true}}]'
