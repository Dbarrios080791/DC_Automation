# Conexión al APIC (simulador ACI 6.0) vía variables de entorno:
#   ACI_URL=https://<ip-apic>
#   ACI_USERNAME=admin
#   ACI_PASSWORD=...
provider "aci" {
  insecure = true # certificado autofirmado del simulador
}
