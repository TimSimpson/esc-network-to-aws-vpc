# Event Store Cloud to AWS VPC Example

This example shows how to spin up an Event Store Network and AWS VPC and peer the two.

## Requirements

### Event Store Cloud Credentials

You'll need to set the following environment variables:

* ESC_ORG_ID - set this to your Event Store Cloud organization
* ESC_TOKEN - set this to your access token

You can get an access token by running `esc access token display` using the [Event Store Cloud CLI](https://github.com/Event Store/esc):

```bash
export ESC_TOKEN=$(esc access token display)
```

### AWS Credentials

You'll need to set either the traditional AWS environment variables, such as AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, or configure them in the files ~/.aws/credentials. Click [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) for more info.


### Other Settings

This project uses a stage name which must be passed as the Terraform variable "stage". To create one, select a name - such as your own - and export it to the environment variable "TF_VAR_stage", such as:

```bash
export TF_VAR_stage=$USER
```

It also requires a region, set as the Terraform variable "region". Set one like so:

```bash
export TF_VAR_region=us-east-1
```

### Running

After setting the required environment variables mentioned above, do this:

```bash
pushd terraform
terraform plan
terraform apply
popd

# View the created peerings
./scripts/check_peering.sh

```
