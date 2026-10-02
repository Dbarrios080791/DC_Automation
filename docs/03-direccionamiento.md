# 03 · Plan de direccionamiento

## Gestión (192.168.100.0/24)
| Rango | Uso |
|---|---|
| .1 | Gateway |
| .5 | CML (ejemplo) |
| .11-.12 | Fabric NaC — spines |
| .21-.23 | Fabric NaC — leafs |
| .50 | APIC simulador (ejemplo) |
| .101-.119 | Labs de clase (uno activo a la vez) |

## Fabric NaC — underlay
| Elemento | Esquema | Ejemplo |
|---|---|---|
| Loopback0 (router-id, BGP) | 10.0.0.X/32 | spine1 .1 · spine2 .2 · leaf1 .11 · leaf2 .12 · leaf3 .13 |
| Loopback1 (VTEP / NVE) | 10.0.1.X/32 | leaf1 .11 · leaf2 .12 · leaf3 .13 |
| Enlaces P2P | 10.1.S.0/24 en /31 (S = nº spine) | spine1 Eth1/1 10.1.1.0 ↔ leaf1 Eth1/1 10.1.1.1 |

**Cableado:** `spineS Eth1/L ↔ leafL Eth1/S`. Hosts en `leaf Eth1/5`.

## Fabric NaC — overlay
| Parámetro | Valor |
|---|---|
| ASN iBGP | 65001 (spines = route-reflectors l2vpn evpn) |
| Replicación BUM | Ingress replication BGP (sin multicast) |
| Anycast gateway MAC | 2020.0000.00aa |

| Tenant | VRF / L3VNI | VLAN → L2VNI | Subred (anycast GW) |
|---|---|---|---|
| A | TENANT-A / 50001 (VLAN 3001) | 10 → 10010 (WEB) | 172.16.10.1/24 |
| | | 20 → 10020 (APP) | 172.16.20.1/24 |
| B (siguiente) | TENANT-B / 50002 (VLAN 3002) | 30 → 10030 | 172.16.30.1/24 |

**Convención de VNI:** L2VNI = 10000 + VLAN · L3VNI = 50000 + nº de tenant.

## Hosts de prueba
| Host | Leaf | VLAN | IP |
|---|---|---|---|
| host1 | leaf1 | 10 | 172.16.10.11 |
| host2 | leaf2 | 10 | 172.16.10.12 |
| host3 | leaf3 | 20 | 172.16.20.13 |

host1 ↔ host2 prueba el **puenteo L2 sobre VXLAN**; host1 ↔ host3 prueba el **enrutamiento
simétrico IRB** por la L3VNI.
