
# EKS cluster
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.0"
  cluster_name                   = "cluster"
  cluster_version                = "1.30"
  iam_role_arn                   = "arn:aws:iam::730335498446:role/my-eks-cluster-role"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  /*
    cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }*/

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    cluster_nodes = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
      node_role_arn  = "arn:aws:iam::730335498446:role/my-nodegroup-role"

      min_size     = 2
      max_size     = 2
      desired_size = 2
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {

    cluster_nodes = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::730335498446:root"

      policy_associations = {
        cluster_nodes = {
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


resource "null_resource" "setup_argocd" {
  provisioner "local-exec" {
    command = "./deploy-argocd.sh ${module.eks.cluster_name} ${var.aws_region}"
  }

  depends_on = [module.eks]
}