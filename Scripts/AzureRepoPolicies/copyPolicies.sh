#!/bin/bash -e
#
# For Azure Devops Repos
# Copy the branch policies from one branch to another - mostly for the branch policies
#
# The Azure Devops Extension (as well as the Azure CLI) must be installed for this script to work:
# https://docs.microsoft.com/en-us/cli/azure/devops/extension?view=azure-cli-latest
# 
# Parameters
# - Repo name
# - Branch to copy from
# - Branch to copy to
#
# Must be run from a git directory otherwise the az commands will need more information

repo_name=$1
copy_from=$2
copy_to=$3

echo "Parameters passed: repository name: $repo_name'; Copy from branch: $copy_from; Copy to branch: $copy_to"
# Get the repo id
repo_id=$(az repos list --query "[?name=='$repo_name'].id" -o tsv)
#echo $repo_id

echo "Creating the limit merge policy, squash merge only"
# create a merge-strategy policy for the branch (squash merge only)
limit_merge=$(az repos policy merge-strategy create --branch $copy_to --enabled true --blocking true --repository-id $repo_id --allow-squash true)

echo "Get the list of branch validation policies from the source branch"
# list the policies in the source branch
policy_list=$(az repos policy list --query "[?contains(settings.scope[].repositoryId,'$repo_id')] | [?contains(settings.scope[].refName, 'refs/heads/$copy_from')] | [].[settings.buildDefinitionId, settings.displayName, settings.filenamePatterns[0]]" --output tsv | tr '\t' ',')
# results in a tsv format, so we remove the tabs and replace with a comma

IFS=$'\n' 
array=($policy_list)
# we put the list we got back into an array split by the new line char, so we have an array of values - one for each policy
#echo "Number of elements ${#array[@]}"
for i in "${array[@]}"
do
    # some policies are not "build", so we want to ignore those
    if [[ "$i" != "None,None,None" ]]; then
        # split the element with the comma seperator, ready to use to create the policy
        IFS=$','
        vals=($i)
        if [[ "${vals[2]}" == "None" ]]; then
            echo "Create the policy for ${vals[1]}"
            create_policy=$(az repos policy build create --branch $copy_to --enabled true --blocking true --queue-on-source-update-only true --manual-queue-only false --valid-duration 720 --repository-id $repo_id --build-definition-id ${vals[0]} --display-name "${vals[1]}")
        else
            echo "Create the policy for ${vals[1]}"
            create_policy=$(az repos policy build create --branch $copy_to --enabled true --blocking true --queue-on-source-update-only true --manual-queue-only false --valid-duration 720 --repository-id $repo_id --build-definition-id ${vals[0]} --display-name "${vals[1]}" --path-filter "${vals[2]}")
        fi
    fi
done
