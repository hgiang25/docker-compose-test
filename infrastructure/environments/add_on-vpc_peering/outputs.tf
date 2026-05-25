output "vpc_peering_connection_id" {
  value = module.peering.vpc_peering_connection_id
}

output "management_vpc_cidr" {
  value = module.peering.requester_vpc_cidr
}

output "dev_vpc_cidr" {
  value = module.peering.accepter_vpc_cidr
}
