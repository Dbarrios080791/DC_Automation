# =============================================================================
# Network as Code - Cisco NX-OS (VXLAN EVPN fabric)
#
# Toda la intención de red vive en ./data/*.nac.yaml. Este archivo solo
# conecta los datos con el módulo oficial de Cisco: no hay lógica aquí.
#
# Credenciales (nunca en el repo):
#   export NXOS_USERNAME=admin
#   export NXOS_PASSWORD=...
# =============================================================================
module "nxos" {
  source  = "netascode/nac-nxos/nxos"
  version = "0.3.0"

  yaml_directories = ["data"]

  # Despliegue selectivo: limita el apply a ciertos grupos/equipos.
  # make nxos-plan GROUPS='["spines"]'
  managed_device_groups = var.managed_device_groups
  managed_devices       = var.managed_devices

  save_config      = var.save_config
  write_model_file = var.write_model_file
}
