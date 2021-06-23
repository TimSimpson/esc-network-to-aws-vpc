#!/bin/bash
set -euo pipefail

pushd terraform
readonly function_name=$(terraform output lambda_name)
popd

AWS_REGION=$TF_VAR_region aws ec2 describe-vpc-peering-connections
