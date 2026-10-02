# =============================================================================
# Network as Code - Cisco ACI (simulador APIC 6.0)
#
# Mismo principio que nac/nxos: la intención vive en ./data/*.nac.yaml y el
# módulo oficial de Cisco traduce el modelo a objetos del APIC.
# Empezamos solo con tenants; se habilitan más secciones a medida que avances.
# =============================================================================
module "aci" {
  source  = "netascode/nac-aci/aci"
  version = "2.1.0"

  yaml_directories = ["data"]

  manage_tenants         = true
  manage_access_policies = var.manage_access_policies
  manage_fabric_policies = false
  manage_pod_policies    = false
  manage_node_policies   = false
}
