terraform {
  required_version = ">= 1.9.0"

  required_providers {
    cml2 = {
      source  = "CiscoDevNet/cml2"
      version = "~> 0.9.1"
    }
  }

  # Un workspace de Terraform por lab => un estado independiente por lab.
  # Levantar/apagar la clase de OSPF nunca toca el estado del fabric NaC.
  backend "local" {
    workspace_dir = "terraform.tfstate.d"
  }
}
