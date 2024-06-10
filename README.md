# EKS PLAY

Status: WIP - bastion still can't reach private endpoint

play around spinning up an eks cluster with terraform.

Required:
- [docker](https://www.docker.com/)
- an aws account


## Usage

```00-vpc``` has resouces to deploy the VPC that meets eks network requirements

```eks``` has terraform config to spin up eks cluster.

## Set up

create a ```eks/eks-play.tfvars``` file and populate with values as required by ```eks/variables.tf```

take a look at the ```compose.yaml```, this has a couple of services so that you don't have to install terraform or aws-cli.

configure programmatic access for aws-cli:
- [granting programmatic access](https://docs.aws.amazon.com/workspaces-web/latest/adminguide/getting-started-iam-user-access-keys.html)
- [setting up the aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

Verify aws cli picks up creds okay:

```bash
docker compose run aws iam list-users
```

If it works it works

---

## Deploy VPC and other EKS networking resources

```bash
./scripts/deploy-vpc.sh
```

This deploys a basic subnet that meets the networking requirements for an EKS cluster.

---

## Deploy the EKS cluster and bastion

We'll just use a local tf backend for now.

```bash
docker compose run terraform -chdir=eks init
```

Plan:

```bash
docker compose run terraform -chdir=eks plan -var-file eks-play.tfvars
```

review the plan

Apply:

```bash
docker compose run terraform -chdir=eks apply -var-file eks-play.tfvars
```
yes when prompted

---

# don't forget to clean up

```bash
docker compose run terraform -chdir=eks destroy -var-file eks-play.tfvars
```
say yes when prompted.

Then the VPC:

```bash
aws cloudformation delete-stack --stack-name=eks-vpc;
```

double check in console 