# Conexión a CML vía variables de entorno (ver .env.example):
#   TF_VAR_cml_address=https://<ip-de-tu-cml>
#   TF_VAR_cml_username=...
#   TF_VAR_cml_password=...
provider "cml2" {
  address  = var.cml_address
  username = var.cml_username
  password = var.cml_password

  # El certificado de CML en un home lab es autofirmado.
  skip_verify = var.cml_skip_verify
}
