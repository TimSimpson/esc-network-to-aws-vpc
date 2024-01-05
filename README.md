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


### AWS Key Pair

You'll need to register an SSH key with AWS so you can log into your the "application" ec2 instance. Click [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) for more info.

Set the value of `TF_VAR_key_pair` to the name of the key pair:

```bash
export TF_VAR_key_pair=app-key-pair
```

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
```

Make note of the public IP and the cluster DNS name.

Ssh into the created ec2 instance using the public IP (use the user ubuntu and the key from the key pair you provided) and then do the following (here `cmc68fto0aeg0jihug10.mesdb.eventstore.cloud` is the cluster's DNS name):

```bash
curl https://cmc68fto0aeg0jihug10.mesdb.eventstore.cloud:2113/gossip
```
