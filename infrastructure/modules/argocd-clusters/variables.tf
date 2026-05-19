variable "clusters" {
  type = map(object({
    cluster_name = string
    server       = string
    ca_data      = string
    region       = string
  }))
}