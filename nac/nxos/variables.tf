variable "managed_device_groups" {
  description = "Grupos de dispositivos a gestionar. Vacío = todos."
  type        = list(string)
  default     = []
}

variable "managed_devices" {
  description = "Dispositivos a gestionar. Vacío = todos."
  type        = list(string)
  default     = []
}

variable "save_config" {
  description = "Ejecuta 'copy running-config startup-config' tras el apply."
  type        = bool
  default     = true
}

variable "write_model_file" {
  description = "Ruta donde escribir el modelo renderizado (debug). Vacío = no escribir."
  type        = string
  default     = ""
}
