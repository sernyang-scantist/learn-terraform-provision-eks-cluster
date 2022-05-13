module "eks" {
  # roughly latest stable versions
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  # https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  # accepted in v17.24.0 but not in latest, moved to self-managed node groups?
  # https://aws.amazon.com/ec2/instance-types/
  # https://docs.aws.amazon.com/eks/latest/userguide/worker.html
  worker_groups = [
    {
      # asg - auto scaling group
      # https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

# module.eks.cluster_id is an output of the eks module
# https://acloudguru.com/blog/engineering/how-to-use-terraform-inputs-and-outputs
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
