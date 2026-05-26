resource "kubernetes_namespace" "fiap" {
  metadata {
    name = "fiap-mecanica"
  }
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      region      = var.aws_region
      vpcId       = module.networking.vpc_id
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.alb_controller.metadata[0].name
      }
    })
  ]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.38.0"

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = module.eks.cluster_name
      }
      awsRegion = var.aws_region
      rbac = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.cluster_autoscaler.metadata[0].name
        }
      }
      extraArgs = {
        balance-similar-node-groups = "true"
        skip-nodes-with-system-pods = "false"
      }
    })
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.10.3"

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.external_secrets.metadata[0].name
      }
    })
  ]
}

resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = kubernetes_service_account.external_secrets.metadata[0].name
                namespace = kubernetes_namespace.external_secrets.metadata[0].name
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
}

resource "helm_release" "datadog" {
  count      = var.enable_datadog ? 1 : 0
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = kubernetes_namespace.datadog.metadata[0].name
  version    = "3.56.0"

  set_sensitive {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  set {
    name  = "logs.enabled"
    value = "true"
  }

  set {
    name  = "apm.enabled"
    value = "true"
  }

  set {
    name  = "kubeStateMetricsEnabled"
    value = "true"
  }
}
