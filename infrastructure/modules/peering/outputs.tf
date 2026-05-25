output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.this.id
}

output "requester_vpc_cidr" {
  value = data.aws_vpc.requester.cidr_block
}

output "accepter_vpc_cidr" {
  value = data.aws_vpc.accepter.cidr_block
}

output "requester_node_security_group_id" {
  value = tolist(data.aws_security_groups.requester_node.ids)[0]
}

output "accepter_node_security_group_id" {
  value = tolist(data.aws_security_groups.accepter_node.ids)[0]
}

output "requester_cluster_security_group_id" {
  value = tolist(data.aws_security_groups.requester_cluster.ids)[0]
}

output "accepter_cluster_security_group_id" {
  value = tolist(data.aws_security_groups.accepter_cluster.ids)[0]
}
