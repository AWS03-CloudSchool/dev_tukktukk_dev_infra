aws_region = "ap-northeast-2"
vpc_cidr = "192.168.0.0/24"
public_subnet_cidrs = ["192.168.0.0/26", "192.168.0.64/26"]
private_subnet_cidrs =  ["192.168.0.128/26", "192.168.0.192/26"]
infra_name = "tukktukk-dev-infra"
azs = ["ap-northeast-2a", "ap-northeast-2b"]
argocd_sub_dns="argocd"