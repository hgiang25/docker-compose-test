output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = "ap-southeast-1"
}

output "cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}