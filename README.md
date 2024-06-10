# EKS PLAY


Verify aws cli picks up creds okay:

```docker compose run aws iam list-users```

---

Deploy VPC.

```./deploy-vpc.sh```

This deploys a basic subnet that meets the networking requirements for an EKS cluster.

---

TF init

We'll just use local backend for now.

```docker compose run terraform -chdir=eks init```

Plan:

```docker compose run terraform -chdir=eks plan -var-file eks-play.tfvars```

review the plan

Apply:

```docker compose run terraform -chdir=eks apply -var-file eks-play.tfvars```
yes when prompted

---
