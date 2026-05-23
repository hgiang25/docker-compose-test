output "argocd_management_role_arn" {
  value = module.argocd_irsa_role.iam_role_arn
}