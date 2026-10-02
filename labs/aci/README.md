# Labs ACI (simulador APIC 6.0)

El simulador ACI es un OVA independiente, no corre dentro de CML.
Úsalo para:

1. **Clases manuales**: explorar la GUI del APIC y el modelo de objetos
   (tenant → VRF → BD → EPG → contract). Toma notas aquí, un archivo por clase.
2. **Automatización**: `nac/aci` aplica el mismo modelo como código
   (`make aci-plan`, `make aci-apply`).

> El simulador no reenvía tráfico de datos: sirve para practicar políticas
> y la API, no para hacer pings entre endpoints.
