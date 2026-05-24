# ---------------- Discover VPC info ----------------
data "aws_vpc" "requester" {
  id = var.requester_vpc_id
}

data "aws_vpc" "accepter" {
  id = var.accepter_vpc_id
}

# All route tables in each VPC. Peering routes will be added to every RT
# (public + private) so resources in any subnet can reach the peer CIDR.
data "aws_route_tables" "requester" {
  vpc_id = var.requester_vpc_id
}

data "aws_route_tables" "accepter" {
  vpc_id = var.accepter_vpc_id
}

# Locate node security groups created by terraform-aws-modules/eks/aws v20.
# That module tags the node SG with Name = "<cluster_name>-node".
data "aws_security_groups" "requester_node" {
  filter {
    name   = "vpc-id"
    values = [var.requester_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.requester_cluster_name}-node"]
  }
}

data "aws_security_groups" "accepter_node" {
  filter {
    name   = "vpc-id"
    values = [var.accepter_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.accepter_cluster_name}-node"]
  }
}

# ---------------- VPC Peering Connection ----------------
resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  auto_accept = var.auto_accept

  tags = merge(var.tags, {
    Name = "${var.requester_cluster_name}-to-${var.accepter_cluster_name}"
  })
}

# ---------------- Routes ----------------
resource "aws_route" "requester_to_accepter" {
  count = length(data.aws_route_tables.requester.ids)

  route_table_id            = tolist(data.aws_route_tables.requester.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter_to_requester" {
  count = length(data.aws_route_tables.accepter.ids)

  route_table_id            = tolist(data.aws_route_tables.accepter.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# ---------------- Security Group Rules ----------------
# Ingress on requester node SG: allow accepter VPC CIDR on each TCP port.
resource "aws_security_group_rule" "requester_ingress_from_accepter" {
  for_each = { for p in var.allowed_tcp_ports : tostring(p) => p }

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.accepter.cidr_block]
  security_group_id = tolist(data.aws_security_groups.requester_node.ids)[0]

  description = "Peering: allow tcp/${each.value} from ${var.accepter_cluster_name} VPC"
}

# Ingress on accepter node SG: allow requester VPC CIDR on each TCP port.
resource "aws_security_group_rule" "accepter_ingress_from_requester" {
  for_each = { for p in var.allowed_tcp_ports : tostring(p) => p }

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.requester.cidr_block]
  security_group_id = tolist(data.aws_security_groups.accepter_node.ids)[0]

  description = "Peering: allow tcp/${each.value} from ${var.requester_cluster_name} VPC"
}
