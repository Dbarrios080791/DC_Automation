terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.19.0"
    }
    utils = {
      source  = "netascode/utils"
      version = "~> 2.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}
