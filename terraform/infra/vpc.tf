module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"
  name    = "${var.name_prefix}-vpc"
  cidr    = var.main_network_block
  azs     = data.aws_availability_zones.available_azs.names

  private_subnets = [
    for zone_id in data.aws_availability_zones.available_azs.zone_ids :
    cidrsubnet(var.main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
    for zone_id in data.aws_availability_zones.available_azs.zone_ids :
    cidrsubnet(var.main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # add VPC/Subnet tags required by EKS
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    iac_environment                               = var.iac_environment_tag
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    iac_environment                               = var.iac_environment_tag
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    iac_environment                               = var.iac_environment_tag
  }
}
