# 05 · Roadmap: clases DCExperts + automatización

Cada fase combina **aprender a mano** (labs/) con **expresarlo como código** (nac/).
El objetivo final: CCNP Data Center (350-601 DCCOR + 300-635 DCAUTO) y perfil de arquitecto.

| Fase | Clase manual (labs/) | Automatización (nac/, ansible/, python/) | Hito portafolio |
|---|---|---|---|
| 0 | — | `make setup`, `make lab-up LAB=nac/nxos/cml`, primer `make deploy` | Fabric EVPN levantado 100% por código |
| 1 | 01 L2: VLAN, STP, port-channel | Puertos de host en `devices/*.nac.yaml`, backup con Ansible | Primer PR con CI verde |
| 2 | 02 vPC | vPC en leaf1/leaf2 modelado en NaC (nuevo device_group) | Leafs en par vPC como código |
| 3 | 03 OSPF | BFD en el underlay, regla de validación de áreas | Regla semántica propia |
| 4 | 04 BGP | Peer-templates, route-maps, border leaf con VRF-lite | Salida externa del fabric |
| 5 | 05 Multicast | Underlay multicast (PIM/anycast RP) como alternativa a IR | Comparativa IR vs multicast documentada |
| 6 | 06-07 VXLAN / EVPN | Tenant B, `nac-test` (Robot) para tests post-cambio | Pipeline validate → plan → apply → test |
| 7 | ACI básico (simulador) | Ampliar `nac/aci`: L3Out, access policies por interfaz | Mismo servicio en NX-OS y ACI como código |
| 8 | 08 Multisite | EVPN multisite (BGW) | Diseño multi-DC documentado |
| 9 | — | Python on-box + EEM, NX-API/gNMI telemetría | Herramienta propia en `python/` |
| 10 | — | NDFC con `cisco.nac_dc_vxlan` (si consigues imagen) | NaC sobre controlador |

## Hábitos que marcan la diferencia en LinkedIn
- Un PR por cambio, con descripción del *por qué* (decisión de diseño), no solo del *qué*.
- Documenta cada fase en `docs/` con un diagrama y lo aprendido.
- Publica un post por hito con captura del pipeline verde y el `terraform plan`.
