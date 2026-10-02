# =============================================================================
# Labs de CML como código.
#
# Cada lab (clase DCExperts o fabric NaC) es una carpeta con topology.yaml.
# El Makefile selecciona un workspace por lab, así cada uno tiene su propio
# estado y se puede encender/apagar/destruir sin afectar a los demás.
#
#   make lab-up   LAB=labs/nxos/03-ospf
#   make lab-down LAB=labs/nxos/03-ospf     # STOPPED: conserva la config
#   make lab-destroy LAB=labs/nxos/03-ospf  # borra el lab de CML
# =============================================================================
locals {
  topology = replace(
    file("${path.root}/../../${var.lab_path}/topology.yaml"),
    "__ADMIN_PASSWORD__",
    var.device_password,
  )
}

resource "cml2_lifecycle" "lab" {
  topology = local.topology
  state    = var.lab_state
  wait     = var.wait_for_boot

  timeouts = {
    create = "60m"
    update = "60m"
  }

  lifecycle {
    # Un cambio de topología recrea el lab. Si ya trabajaste en él a mano
    # (clases), exporta antes las configs desde CML.
    precondition {
      condition     = !strcontains(local.topology, "__ADMIN_PASSWORD__")
      error_message = "Quedaron placeholders sin reemplazar en la topología."
    }
  }
}
