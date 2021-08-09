# [LAB] AWS EKS cluster
A laboratory for EKS cluster.
Contains a publicly acessible grafana service, for monitoring data visualization.

The Prometheus and Grafana deployment is based o kube-prometheus-stack helm chart.
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

In adition to the community monitoring itens and dasboards, this project contains a service
monitor called ping-exporter.
https://github.com/czerwonk/ping_exporter.

The ping-exporter service monitor runs as a daemonset, sending ping requests to every node on the cluster,
collecting inter node connectivity data.

## Dependencies
- AWS CLI (https://github.com/aws/aws-cli)
  > Execute `$ aws configure ` (https://github.com/aws/aws-cli#configuration)
- Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)
- kubectl (https://kubernetes.io/docs/tasks/tools/)

## Usage
Install terraform dependencies
```
terraform init
```
Previews the execution plan and apply it
```
terraform plan
```
```
terraform apply
```
### Aply kubeconfig
```
aws eks update-kubeconfig --name eks_lab_cluster --region us-west-1
```
## Grafana
Provides several dashboards for visualizaing monitoring information.

To access it after running the `terraform apply`, get the Grafana Load Balancer URL with:
```
terraform output grafana_url
```
Paste it on your browser an use the following credentials to access it.

 > username: admin

 > password: admin123

## Clean up
To clean up created resources and avoid costs don't forget to run
```
terraform destroy
```
## References and resources

Documentation generated using terraform-docs
https://github.com/terraform-docs/terraform-docs
```
terraform-docs markdown . | tee README.md
```

### Creating a serviceMonitor for prometheus operator
https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md
https://stackoverflow.com/questions/52991038/how-to-create-a-servicemonitor-for-prometheus-operator

### Provisioning a EKS cluster
https://learn.hashicorp.com/tutorials/terraform/eks

### AWS EKS cluster with terraform - Examples
https://antonputra.com/category/aws-amazon-web-services/

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.11.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.52.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.1.0 |
| <a name="module_networking"></a> [networking](#module\_networking) | ./networking | n/a |
| <a name="module_ping-exporter"></a> [ping-exporter](#module\_ping-exporter) | ./ping-exporter | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/2.2.0/docs/resources/release) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_instances.cluster_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | `"lab_cluster"` | no |
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | Namespace for monitoring resources | `string` | `"monitoring"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_config_map_aws_auth"></a> [config\_map\_aws\_auth](#output\_config\_map\_aws\_auth) | A kubernetes configuration to authenticate to this EKS cluster. |
| <a name="output_grafana_url"></a> [grafana\_url](#output\_grafana\_url) | Grafana external URL |
| <a name="output_kubectl_config"></a> [kubectl\_config](#output\_kubectl\_config) | kubectl config as generated by the module. |
