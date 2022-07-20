# GCP Org Bootstrapping and Foundations using StackQL

This project uses [StackQL](https://github.com/stackql/stackql) and [Jsonnet](https://jsonnet.org/) to deploy root level resources, including:

- Root level projects for `audit`, `terraform`, and `sharedsvc`
- Folders for environments, `Prod` and `Non Prod`
- APIs enabled for root level projects
- Backend buckets for each environment
- Service accounts for Terraform
- IAM bindings for TF service accounts and priveleged users
- Shared VPC
- Org and Folder level aggregated log sinks
- Org policy contraints

Once deployed you can use Terraform and the service accounts created to manage resource deployments into projects in the `Prod` and `Non Prod` environments.  

Service account and priveleged user and group role bindings can be managed using the StackQL, see the [IAM Guide](iam.md).

## Prerequisites
1. Must be run by an authenticated member with the following role bindings:
- `roles/resourcemanager.projectCreator`
- `roles/resourcemanager.organizationAdmin`
- `roles/billing.admin`
- `roles/resourcemanager.folderAdmin`
- `roles/storage.admin`

2. [StackQL](https://stackql.io/downloads) downloaded 

3. `google` provider installed

```bash
registry pull google v1.0.3;
```

The steps involved are detailed below:  

## 1. Create Folders

Creates root level folders (representing each environment - in this example we have `prod`, `nonprod` and `datalabs` environments).  

to perform a dryrun, use the `--dryrun` flag as shown here:

```bash
stackql exec -i ./1-create-folders/query.iql \
--iqldata ./data/vars.jsonnet \
--outfile 1-create-folders-TEMPLATED.iql \
--dryrun --output text --hideheaders
```
inspect `1-create-folders-TEMPLATED.iql`.  To deploy run:

```bash 
stackql exec -i ./1-create-folders/query.iql \
--iqldata ./data/vars.jsonnet \
--auth '{ "google": { "type": "interactive" }}'
```
or  

```bash
stackql exec -i ./1-create-folders-TEMPLATED.iql \
--auth '{ "google": { "type": "interactive" }}'
```

or  

run the commands output from the dryrun in the StackQL shell (`stackql shell --auth '{ "google": { "type": "interactive" }}'`)  

for brevity we will omit these options from the subsequent steps.  

> NOTE: You can also authenticate using a service account, see [Google Authentication](https://registry.stackql.io/providers/google/#authentication)

## 2. Root Level Projects

Creates root level projects (directly under the org if this is your root node) and enables the required APIs in each respective project, the root level projects include:  

| Project     | Description |
| ----------- | ----------- |  
| `terraform` | contains the environment (folder) scoped service accounts to used for Terraform deployment pipelines post-foundations also contains backend buckets for each environment to hold Terraform state or modules |
| `audit`     | contains all of the log sinks and associated resources |
| `sharedsvc` | host project for the Shared VPC |     

```bash 
stackql exec -i ./2-create-root-level-projects/query.iql \
--iqldata ./data/vars.jsonnet \
--auth '{ "google": { "type": "interactive" }}'
```

## 3. Create Terraform Project Resources

Create terraform service accounts for each environment (used for Terraform deployment pipelines for resources in projects within each folder).  Also creates backend buckets for each environment (to be used for Terraform state files and modules).    

```bash 
stackql exec -i ./3-create-terraform-project-resources/query.iql \
--iqldata ./data/vars.jsonnet \
--auth '{ "google": { "type": "interactive" }}'
```

## 4. Create Org and Folder Level Aggregated Log Sinks

Creates resources in the audit project, which include organization and folder level aggregated log sinks.  

> This script can also be used to setup push subscriptions to off platform logging services like SumoLogic

```bash 
stackql exec -i ./4-create-org-and-folder-level-aggregated-log-sinks/query.iql \
--iqldata ./data/vars.jsonnet \
--auth '{ "google": { "type": "interactive" }}'
```

## 5. Create or Update Org Policy Constraints

5-create-or-update-org-policy-constraints

./stackql exec -i ./5-create-or-update-org-policy-constraints/query.iql \
--iqldata ./data/vars.jsonnet \
--outfile 5-create-or-update-org-policy-constraints-TEMPLATED.iql \
--dryrun --output text --hideheaders

## 6. Create Shared VPC

6-create-shared-vpc

## 7. Create or Replace IAM Bindings

7-create-or-replace-iam-bindings
