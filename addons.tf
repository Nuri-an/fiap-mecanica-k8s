# Kubernetes add-ons disabled for infrastructure provisioning phase
# Uncomment after EKS cluster is created and kubernetes provider is re-enabled
# 
# To re-enable:
# 1. Uncomment kubernetes/helm providers in main.tf
# 2. Run terraform apply to deploy these add-ons
#
# resource "kubernetes_namespace" "fiap" {
#   metadata {
#     name = "fiap-mecanica"
#   }
# }
