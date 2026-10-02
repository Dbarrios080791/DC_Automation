# Labs de clase (manuales)

Aquí viven los laboratorios de las clases de **DCExperts**. Se configuran **a mano**,
para aprender los protocolos, y están separados de la automatización:

- Ningún inventario de Ansible ni módulo de Terraform NaC apunta a estos equipos.
- Cada lab tiene su propio estado en CML (workspace de Terraform propio).
- Rango de gestión exclusivo: `192.168.100.101-119`. Los labs de clase comparten ese
  rango, así que **solo hay uno encendido a la vez** (además, por RAM y licencia).

## Crear un lab nuevo
```bash
make lab-new NAME=03-ospf        # copia _template -> labs/nxos/03-ospf
make lab-up  LAB=labs/nxos/03-ospf
# ... clase ...
make lab-down LAB=labs/nxos/03-ospf   # STOPPED: conserva lo que configuraste
```

## Ruta sugerida (alineada a DCExperts / CCNP Data Center)
| Carpeta | Tema |
|---|---|
| `nxos/01-l2-fundamentals` | VLAN, trunks, STP, port-channel, LACP |
| `nxos/02-vpc` | vPC, peer-link, peer-keepalive |
| `nxos/03-ospf` | OSPF underlay, tipos de red, áreas, BFD |
| `nxos/04-bgp` | eBGP/iBGP, route-reflectors, políticas |
| `nxos/05-multicast` | PIM sparse, anycast RP (underlay multicast) |
| `nxos/06-vxlan-flood-learn` | VXLAN sin control plane |
| `nxos/07-vxlan-evpn` | EVPN L2VNI/L3VNI, anycast gateway |
| `nxos/08-vxlan-multisite` | EVPN multisite / border gateways |
| `aci/` | Prácticas en el simulador APIC 6.0 (OVA aparte, no CML) |

> **Ojo con la licencia (20 nodos):** el fabric NaC usa 8 nodos y la plantilla de clase 6.
> Los dos caben a la vez en licencia, pero en RAM conviene tener encendido solo uno.
