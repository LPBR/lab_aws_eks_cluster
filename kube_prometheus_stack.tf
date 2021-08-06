resource "helm_release" "prometheus" {
  name = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "17.1.1"

  create_namespace = true
  namespace = "monitoring"

  values = [file("prometheus-values.yaml")]
}
