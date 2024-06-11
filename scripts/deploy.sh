#!/usr/bin/env bash
set -euou pipefail

#need these to populate eks-play.tfvars file
get_vpc_stack_outputs() {
  vpc_id=$(docker compose run aws cloudformation describe-stacks --region ap-southeast-2 \
    --stack-name eks-vpc \
    --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' \
    --output text)
  echo "VpcId: $vpc_id"
  subnet_ids=$(docker compose run aws cloudformation describe-stacks --region ap-southeast-2 \
    --stack-name eks-vpc \
    --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' \
    --output text)
  private_subnet_ids=$(docker compose run aws cloudformation describe-stacks --region ap-southeast-2 \
    --stack-name eks-vpc \
    --query 'Stacks[0].Outputs[?OutputKey==`PrivateSubnetIds`].OutputValue' \
    --output text)
  echo "PrivateSubnetIds: $private_subnet_ids"
  public_subnet_ids=$(docker compose run aws cloudformation describe-stacks --region ap-southeast-2 \
    --stack-name eks-vpc \
    --query 'Stacks[0].Outputs[?OutputKey==`PublicSubnetIds`].OutputValue' \
    --output text)
  echo "PublicSubnetIds: $public_subnet_ids"
  security_groups=$(docker compose run aws cloudformation describe-stacks --region ap-southeast-2 \
    --stack-name eks-vpc \
    --query 'Stacks[0].Outputs[?OutputKey==`SecurityGroups`].OutputValue' \
    --output text)
  echo "SecurityGroups: $security_groups"
}

action=$1
case $action in
  "deploy-eks-vpc")
    stackname="eks-vpc"
    appname="eks-play"
    docker compose run aws cloudformation deploy \
          --template-file ./00-vpc/cfn/eks-vpc.yaml \
          --stack-name $stackname \
          --parameter-overrides \
            Name=$appname \
          --region ap-southeast-2 \
          --no-fail-on-empty-changeset
    echo "Deployed $stackname stack"
    ;;
  "seed-eks-play-tfvars-file")
    get_vpc_stack_outputs
    echo vpc_id = \"$vpc_id\" >> ./eks/eks-play.tfvars
    #need to split these so it can be used as a list in terraform like ["subnet-1", "subnet-2"] ugly but make things faster us when tearing down/bringing up
    echo private_subnet_ids = [\"$(echo $private_subnet_ids | sed 's/,/\",\"/g')\"] >> ./eks/eks-play.tfvars
    echo public_subnet_ids = [\"$(echo $public_subnet_ids | sed 's/,/\",\"/g')\"] >> ./eks/eks-play.tfvars
    echo subnet_ids = [\"$(echo $subnet_ids | sed 's/,/\",\"/g')\"] >> ./eks/eks-play.tfvars
    echo security_group_ids = [\"$(echo $security_groups | sed 's/,/\",\"/g')\"] >> ./eks/eks-play.tfvars
    docker compose run terraform -chdir=eks fmt
    echo "#### NOW UPDATE eks-play.tfvars WITH THE OTHER REQUIRED VALUES" 
    ;;
  "deploy-eks-cluster")
    docker compose run terraform -chdir=eks apply -var-file eks-play.tfvars;
    ;;
  *)
    echo "Invalid component to deploy"
    exit 1
    ;;
esac


