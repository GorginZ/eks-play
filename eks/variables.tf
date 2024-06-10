variable "account_id" {
    type = string
}
variable "region" {
  default = "ap-southeast-2"
  type = string 
}

variable "aws_availability_zones" {
  default = {
    available = {
      names = ["ap-southeast-2a", "ap-southeast-2b"]
    }
  }
}

variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
    description = "Subnets for the EKS cluster, providing the private subnets for nodes"
}

variable "control_plane_subnet_ids" {
    type = list(string)
}

variable "instance_types" {
    type = list(string)
    default = ["t2.nano" ]
}

variable "security_group_ids" {
    type = list(string)
    description = "Security group for the cluster control plane communication with worker nodes"
}
