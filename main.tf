# ============================================
# PHASE 1: VPC + API Gateway (Bridge to VPC)
# ============================================

# Networking Module - VPC con subnets públicas y privadas
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# API Gateway Module - REST API como puente público
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name = var.project_name

  depends_on = [module.networking]
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name                  = var.project_name
  enable_point_in_time_recovery = false
  enable_streams                = false
}

//PONER NUeVOS CAMBIOS AQUI