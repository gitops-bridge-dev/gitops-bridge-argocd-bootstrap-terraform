# gitops-bridge-argocd-bootstrap-terraform
Terraform module for gitops-bridge argocd bootstrap

It handles three aspect of ArgoCD bootstrap
1. Installs an intial deployment of argocd, this deployment (gets replaced by argocd applicationset)
2. Creates the ArgoCD cluster secret (including in-cluster)
3. Creates the intial set App of Apps (addons, workloads, etc.)

To be use with [gitops-bridge](https://github.com/gitops-bridge-dev/) project, see example [here](https://github.com/gitops-bridge-dev/gitops-bridge/blob/main/argocd/iac/terraform/examples/eks/hello-world/main.tf)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.10.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.10.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.bootstrap](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_secret_v1.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd"></a> [argocd](#input\_argocd) | argocd helm options | `any` | `{}` | no |
| <a name="input_argocd_bootstrap_app_of_apps"></a> [argocd\_bootstrap\_app\_of\_apps](#input\_argocd\_bootstrap\_app\_of\_apps) | argocd app of apps to deploy | `any` | `{}` | no |
| <a name="input_argocd_cluster"></a> [argocd\_cluster](#input\_argocd\_cluster) | argocd cluster secret | `any` | `null` | no |
| <a name="input_argocd_create_install"></a> [argocd\_create\_install](#input\_argocd\_create\_install) | Deploy argocd helm | `bool` | `true` | no |
| <a name="input_create"></a> [create](#input\_create) | Create terraform resources | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apps"></a> [apps](#output\_apps) | ArgoCD apps |
| <a name="output_argocd"></a> [argocd](#output\_argocd) | Argocd helm release |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | ArgoCD cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
