variable "lab_path" {
  description = "Carpeta (relativa a la raíz del repo) que contiene topology.yaml. Ej: labs/nxos/03-ospf"
  type        = string

  validation {
    condition     = fileexists("${path.root}/../../${var.lab_path}/topology.yaml")
    error_message = "No existe <lab_path>/topology.yaml en el repo."
  }
}

variable "lab_state" {
  description = "Estado deseado del lab en CML."
  type        = string
  default     = "STARTED"

  validation {
    condition     = contains(["STARTED", "STOPPED", "DEFINED_ON_CORE"], var.lab_state)
    error_message = "lab_state debe ser STARTED, STOPPED o DEFINED_ON_CORE."
  }
}

variable "device_password" {
  description = "Password de laboratorio inyectada en los day-0 (reemplaza __ADMIN_PASSWORD__). Usa TF_VAR_device_password."
  type        = string
  sensitive   = true
}

variable "wait_for_boot" {
  description = "Esperar a que todos los nodos estén BOOTED (N9Kv tarda ~10-15 min)."
  type        = bool
  default     = false
}

variable "cml_skip_verify" {
  description = "No verificar el certificado TLS de CML (autofirmado en home lab)."
  type        = bool
  default     = true
}

variable "cml_address" {
  description = "URL del controlador CML, debe empezar por https://"
  type        = string
}

variable "cml_username" {
  description = "Usuario de CML."
  type        = string
}

variable "cml_password" {
  description = "Password de CML."
  type        = string
  sensitive   = true
}
