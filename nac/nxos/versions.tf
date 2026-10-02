terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.14.0"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 2.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0"
    }
  }

  # Estado local por ahora. Para trabajo en equipo: backend remoto
  # (S3, Terraform Cloud, GitLab...) — ver docs/04-flujo-nac.md
  backend "local" {
    path = "terraform.tfstate"
  }
}
