# aws --version
# aws eks --region us-east-1 update-kubeconfig --name paulobusch-cluster
# Uses default VPC and Subnet. Create Your Own VPC and Private Subnets for Prod Usage.

terraform {
  backend "s3" {
    bucket = "terraform-backend-state-pbusch-123" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default" {

}

# data "aws_subnet_ids" "subnets" {
#   vpc_id = aws_default_vpc.default.id
# }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  version                = "~> 2.12"
}

module "paulobusch-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "paulobusch-cluster"

  subnet_ids         = ["subnet-01ae7e14dafdb96a1", "subnet-06056b07b4524bdf9"] #CHANGE
  #subnet_ids = data.aws_subnet_ids.subnets.ids
  
  vpc_id          = aws_default_vpc.default.id
  #vpc_id         = "vpc-1234556abcdef"
}

resource "aws_iam_role" "iam-role" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_eks_node_group" "node-group" {
  cluster_name  = module.paulobusch-cluster.cluster_id
  node_group_name = "paulobusch-node-group"
  node_role_arn  = aws_iam_role.iam-role.arn
  subnet_ids         = ["subnet-01ae7e14dafdb96a1", "subnet-06056b07b4524bdf9"] #CHANGE
  instance_types = ["t2.micro"] ## specify instance type as per your requirement
 
  scaling_config {
    desired_size = 3
    max_size   = 5
    min_size   = 1
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.paulobusch-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.paulobusch-cluster.cluster_id
}

# We will use ServiceAccount to connect to EKS Cluster in CI/CD mode
# ServiceAccount needs permissions to create deployments 
# and services in default namespace
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "fabric8-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}

# Needed to set the default region
provider "aws" {
  region  = "us-east-1"
}