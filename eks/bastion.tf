locals {
  #the security group ids in var.security_group_ids plus the sceurity group created in this file
  bastion_instance_security_group_ids = concat(var.security_group_ids, [aws_security_group.allow_vpc_all.id])
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami                    = "ami-0e326862c8e74c0fe"
  name                   = "eks-play-bastion"
  iam_instance_profile   = aws_iam_instance_profile.bastion-host-instance-profile.name
  instance_type          = "t2.nano"
  monitoring             = true
  vpc_security_group_ids = local.bastion_instance_security_group_ids
  subnet_id              = var.subnet_ids[0] #not nicest but private sn a1 
  user_data              = <<EOF
  #!/bin/bash
  sudo su
  yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  start amazon-ssm-agent
  #install kubectl
  curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin/kubectl
  EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_vpc_all" {
  name        = "allow_vpc_all"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_vpc_ingress" {
  security_group_id = aws_security_group.allow_vpc_all.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_vpc_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#SSMEndpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.allow_vpc_all.id]
  subnet_ids         = var.private_subnet_ids
}

#SSMMessages
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.allow_vpc_all.id]
  subnet_ids         = var.private_subnet_ids
}

#EC2Messages
resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.allow_vpc_all.id]
  subnet_ids         = var.private_subnet_ids
}



resource "aws_iam_role" "bastion-host-instance-role" {
  # managed_policy_arns = var.bastion_host_policy.managed_policy_arns
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion-host-instance-profile" {
  role = aws_iam_role.bastion-host-instance-role.name
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}