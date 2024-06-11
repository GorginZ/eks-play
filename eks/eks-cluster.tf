
locals {
  name            = "eks-play"
  cluster_version = "1.29"
  cluster_additional_security_group_ids = concat(var.security_group_ids, [aws_security_group.allow_vpc_all.id]) #allow all vpc for now just so I can use my bastion easily
  #   region          = "ap-southeast-2"
  #   azs      = slice(var.aws_availability_zones.available.names, 0, 2)

  tags = {
    Example = local.name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access       = false #CIS
  cluster_endpoint_public_access_cidrs = []    #ah none thanks

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  #   cluster_service_ipv4_cidr = let's see what it gives me first 
  #   control_plane_subnet_ids = var.control_plane_subnet_ids  if ommitted uses subnet_ids
  cluster_additional_security_group_ids = local.bastion_instance_security_group_ids 

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.instance_types
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${var.account_id}:role/k8s-admin" #click-opsed this role and policy will iac it after I try this out

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}