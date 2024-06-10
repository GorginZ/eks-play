
locals {
  name            = "eks-play"
  cluster_version = "1.29"
#   region          = "ap-southeast-2"
#   azs      = slice(var.aws_availability_zones.available.names, 0, 2)

  tags = {
    Example    = local.name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name 
  cluster_version = local.cluster_version

  cluster_endpoint_public_access  = false #CIS
  cluster_endpoint_public_access_cidrs = [] #ah none thanks

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

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids 
#   cluster_service_ipv4_cidr = let's see what it gives me first 
#   control_plane_subnet_ids = var.control_plane_subnet_ids  if ommitted uses subnet_ids
  cluster_additional_security_group_ids = var.security_group_ids 

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
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${var.account_id}:group/Administrators" #idk if this takes a group but let's see

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
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