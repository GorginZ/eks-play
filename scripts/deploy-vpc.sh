#!/usr/bin/env bash
set -euou pipefail

#stack dependencies
stackname="eks-vpc"
appname="eks-play"

docker compose run aws cloudformation deploy \
      --template-file ../00-vpc/cfn/eks-vpc.yaml \
      --stack-name $stackname \
      --parameter-overrides \
        Name=$appname \
      --region ap-southeast-2 \
      --no-fail-on-empty-changeset