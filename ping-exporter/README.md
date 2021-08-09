# Ping-exporter prometheus serviceMonitor
## About
Creates a prometheusService monitor, based on czerwonk/ping\_exporter.
Creates the deamon set, it's configuration file, service\_account, service and serviceMonitor.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.11.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.11.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.ping-exporter](https://registry.terraform.io/providers/gavinbunney/kubectl/1.11.3/docs/resources/manifest) | resource |
| [kubernetes_cluster_role.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_daemonset.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_service.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.ping-exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | Namespace for serviceMonitor | `any` | n/a | yes |
| <a name="input_nodes_ips"></a> [nodes\_ips](#input\_nodes\_ips) | Cluster nodes | `any` | n/a | yes |

## Outputs

No outputs.
