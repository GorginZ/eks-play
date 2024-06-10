#!/usr/bin/env bash
set -euou pipefail

#stack dependencies
stackname="eks-vpc"
appname="eks-play"

aws cloudformation deploy \
      --template-file cfn/eks-vpc.yaml \
      --stack-name $stackname \
      --parameter-overrides \
        Name=$appname \
      --region ap-southeast-2 \
      --no-fail-on-empty-changeset