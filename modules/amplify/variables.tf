

variable "github_token" {
  description = "Personal Access Token de GitHub"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "URL del repositorio de GitHub"
  type        = string
  default     = "https://github.com/GuillermoDiotti/my-cloud-react-page"
}

variable "app_name" {
  description = "Nombre de la aplicación en Amplify"
  type        = string
  default     = "my-cloud-react-app"
}

variable "branch_name" {
  description = "Nombre de la rama principal"
  type        = string
  default     = "main"
}