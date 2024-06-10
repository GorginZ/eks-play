# EKS PLAY


Verify aws cli picks up creds okay:

```docker compose run aws iam list-users```

---

Deploy VPC.

```./deploy-vpc.sh```

This deploys a basic subnet that meets the networking requirements for an EKS cluster.


