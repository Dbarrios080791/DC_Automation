# 02 · CML en el PC de escritorio

## Capacidad (Ryzen 7 · 8 núcleos / 16 hilos · 104 GB RAM para CML · licencia 20 nodos)

| Recurso | N9Kv (9300v) | Alpine host |
|---|---|---|
| vCPU | 2 | 1 |
| RAM | 8 GB (no bajar con NX-OS 10.x) | 512 MB |

| Escenario | N9Kv | RAM aprox. | ¿Simultáneo? |
|---|---|---|---|
| Fabric NaC (`nac/nxos/cml`) | 5 | ~41 GB | — |
| Lab de clase (plantilla) | 4 | ~33 GB | — |
| Ambos encendidos | 9 | ~75 GB | Sí, pero arranca uno, espera y luego el otro |
| Máximo práctico | ~11-12 | ~100 GB | Límite de RAM y CPU |

**Reglas prácticas**
- El N9Kv consume mucha CPU al arrancar (~10-15 min). No arranques todos a la vez.
- Lo normal: o el fabric NaC o la clase del día. Apaga (`make lab-down`) lo que no uses:
  `STOPPED` conserva la configuración, `lab-destroy` la borra.
- Licencia de 20 nodos: el fabric usa 8 nodos (5 N9Kv + 3 hosts) y la plantilla de clase 6.

## Imagen NX-OS recomendada
**Nexus 9300v 10.5(x)** — es la versión con la que Cisco prueba el provider Terraform
`CiscoDevNet/nxos`. El `node_definition` usado en las topologías es `nxosv9000`.
Si tu CML tiene otra imagen por defecto, cámbiala en la definición del nodo o en la GUI.

## Red de gestión
Todas las topologías conectan `mgmt0` a un `unmanaged_switch` y este a un
`external_connector` en modo **bridge0** (la LAN del PC de escritorio).

- Si tu LAN **no** es `192.168.100.0/24`, tienes dos opciones:
  1. **Recomendada:** en CML (Cockpit → Networking) crea un bridge dedicado para labs
     y una ruta en tu router/Mac hacia `192.168.100.0/24`.
  2. Busca y reemplaza `192.168.100.` en el repo por tu subred
     (`nac/nxos/data/devices`, `nac/nxos/cml`, `labs/nxos/_template`, `ansible/inventory`).
     `make test` verifica que el inventario Ansible y el modelo NaC siguen coincidiendo.

## Labs como código
```bash
make lab-up      LAB=nac/nxos/cml          # crea + arranca el fabric de automatización
make lab-new     NAME=03-ospf              # nuevo lab de clase desde la plantilla
make lab-up      LAB=labs/nxos/03-ospf
make lab-down    LAB=labs/nxos/03-ospf     # apaga, conserva config
make lab-list                              # labs gestionados
```
Cada lab es un **workspace** de Terraform en `cml/terraform` → estado independiente.
Las contraseñas de day-0 (`__ADMIN_PASSWORD__`) se inyectan desde `TF_VAR_device_password`;
por eso no se importan los YAML a mano en la GUI.

> **Cuidado:** cambiar `topology.yaml` de un lab ya creado lo **recrea** en CML. En labs de
> clase, guarda antes tus configs en `configs/`.
