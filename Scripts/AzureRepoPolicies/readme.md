# Branch Policies

## Prerequisites
 * Azure CLI
 * Azure CLI Devops Extension

## Use/How it Works

The script copyPolicies.sh will set the Merge type on the branch to "Squash Merge only" as well as copy all the build validation policies from one branch to another.

As the project progresses the number of unit/integration tests needed to run increases. These are added to the branches via the build validation to prevent code that fails these tests from being merged into the main code base.

The script first gets the repository id of the repository that you want to update. We then pull the policies that we want to copy from the source branch. Note that we only pull the values that we want here; build definition id, display name, filename pattern.
We use the "az repos policy build create" command to create the actual policies in the new branch. Only one policy can be added at a time, so this loops through using the values that were returned previously.

Steps:

1. Create the new Branch via the portal
2. In this directory (Infrastructure repo) run the following:
```bash
.\copyPolicy.sh MyRepo sprint-12 sprint-13
```
The parameters are: 
 * repository name
 * branch to copy from
 * branch to copy to

3. Check that the policies are in place

## Alternatives

You can create the policies manually via the portal, but this takes a while to do given the number of branch policies we have in place.

You can also have the policies as JSON files and add them via the following command:
```bash
az repos policy create --config ./buildvalidation.json
```

Note that the same restrictions apply here, one build validation entry per file.

Example JSON files are included in this directory but missing type id's and repository id's. You'll have to find those values from an existing branch (using something like the policy list query in the script).