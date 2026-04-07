module "vpc" {
  source = "./modules/vpc"

  vpc_cidr      = var.vpc_cidr
  subnet_cidrs  = var.subnet_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  subnet_ids = module.vpc.subnet_ids
  vpc_id     = module.vpc.vpc_id
  instance_type = var.instance_type
}

module "alb" {
  source = "./modules/alb"

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.subnet_ids
  instance_ids = module.ec2.instance_ids
}