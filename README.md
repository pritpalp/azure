# Azure Code Repo

## Introduction

This repo contains code examples that can be re-used.

## How to deploy via cmd line

To validate a template via the command line (after supplying all required variables):

```bash
az deployment group validate -g {resource_group} -n {name_of_deployment} --template-file {template}.json --parameters {parameters}.json --debug
```

The `--debug` switch can be left out. 

Always validate before attempting to deploy to ensure you've put in the correct variables and you are deploying what you expect.

To do the deployment:
```bash
az deployment group create -g {resource_group} -n {name_of_deployment} --template-file {template}.json --parameters {parameters}.json --debug
```