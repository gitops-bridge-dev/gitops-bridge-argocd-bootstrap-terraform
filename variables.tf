variable "create" {
  description = "Create terraform resources"
  type        = bool
  default     = true
}
variable "argocd" {
  description = "argocd helm options"
  type        = any
  default     = {}
}
variable "argocd_create_install" {
  description = "Deploy argocd helm"
  type        = bool
  default     = true
}

variable "argocd_cluster" {
  description = "argocd cluster secret"
  type        = any
  default     = null
}

variable "argocd_bootstrap_app_of_apps" {
  description = "argocd app of apps to deploy"
  type        = any
  default     = {}
}
