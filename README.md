# EKS PLAY

Status: WIP - bastion still can't reach private endpoint

Deploy a basic EKS cluster.

- deploy VPC that meets the EKS networkign requirements with aws cloudformation
- deploy EKS cluster with terraform

Required:
- [docker](https://www.docker.com/)
- an aws account

## Usage

```00-vpc``` has resouces to deploy the VPC that meets eks network requirements

```eks``` has terraform config to spin up eks cluster.

## Set up

Most dependencies are managed in the ```compose.yaml``` and respective Dockerfile, this has a couple of services so that you don't have to install terraform or aws-cli.

We'll use the ```scripts/do-action.sh <action>``` to roll out deployment, which calls the compose service as needed.

configure programmatic access for aws-cli:
- [granting programmatic access](https://docs.aws.amazon.com/workspaces-web/latest/adminguide/getting-started-iam-user-access-keys.html)
- [setting up the aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

Verify aws cli picks up creds okay with the compose:

```bash
docker compose run aws iam list-users
```

If it works it works

---

## Deploy VPC and other EKS networking resources

```bash
./scripts/do-action.sh deploy-eks-vpc
```

This deploys a basic subnet that meets the networking requirements for an EKS cluster.


## Configure your tfvars

This will get the outputs from the VPC cloudformation stack. Fill in the rest yourself:

```bash
./scripts/do-action.sh seed-tfvars-file 
```

---

## Deploy the EKS cluster and bastion


We'll just use a local tf backend for now.
Do a plan first if you'd like:

```bash
docker compose run terraform -chdir=eks plan -var-file eks-play.tfvars
```

Deploy:

```bash
./scripts/do-action.sh deploy-eks-cluster
```
yes when prompted

---

Now you can connect to the bastion instance with Session Manager and reach the cluster once you authenticate.

Run:

```bash
aws configure
```


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