#!/bin/bash -e

# This script sets the diagnostic for a webapp - ending the logs to the Log Analytics workspace
# Note that the setting is in preview, so values may change
# 
# Inputs:
# Resource Group
# Subscription ID
# Workspace Name
# Workspace Resource Group
#
# Example:
# ./set_diagnostic.sh my_resource_grp sub_id workspace_name workspace_resource_grp

# Need to have four parameters, resource group, subscription id, workspace name, workspace resource group
if [[ $# -eq 0 ]]; then
  echo "Enter the following parameters in order: resource group, subscription id, workspace name, workspace resource group"
  exit 1
fi

resourcegroup=$1
subscriptionId=$2
workspaceName=$3
workspaceRG=$4

# Lets get a list of all the webapps
appList=$(az webapp list --resource-group $resourcegroup --query "[].name" --output tsv)

# Now we can go through the list and create the diagnostic setting
IFS=$'\n' 
array=($appList)
for i in "${array[@]}"
do
    settingName=$resourcegroup-$i
    webapp=$i

    resourceId=/subscriptions/$subscriptionId/resourceGroups/$resourcegroup/providers/Microsoft.Web/sites/$webapp
    workspaceId=/subscriptions/$subscriptionId/resourcegroups/$workspaceRG/providers/microsoft.operationalinsights/workspaces/$workspaceName

    # Note that the values in logs and metrics were found via the portal and the diagnostic setting is marked as "preview"
    # 30 day retention policy is set for all values, but this can be changed as required
    az monitor diagnostic-settings create \
      --name $settingName \
      --resource $resourceId \
      --workspace $workspaceId \
      --logs '[{"category": "AppServiceHTTPLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceAntivirusScanAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceConsoleLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceAppLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceFileAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServiceIPSecAuditLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}},{"category": "AppServicePlatformLogs","enabled": true,"retentionPolicy": {"enabled": true,"days": 30}}]' \
      --metrics '[{"category": "AllMetrics","enabled": true,"retentionPolicy": {"days": 30,"enabled": true}}]'
done
