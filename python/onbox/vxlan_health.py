#!/usr/bin/env python3
"""Chequeo de salud VXLAN EVPN ejecutado DENTRO del switch Nexus (on-box).

Usa la API nativa `cli` del intérprete Python de NX-OS: no necesita SSH,
credenciales ni librerías externas.

Uso en el switch:
    copy scp://<usuario>@<mac>/ruta/vxlan_health.py bootflash: vrf management
    python3 bootflash:vxlan_health.py

Programarlo con EEM (cada 5 min, deja el resultado en el log del switch):
    event manager applet VXLAN-HEALTH
      event timer watchdog time 300 name vxlan
      action 1.0 cli python3 bootflash:vxlan_health.py --syslog

Nota: escrito compatible con el Python incluido en NX-OS (sin dependencias
de versiones recientes de Python).
"""

import json
import sys

from cli import cli, clid  # módulo disponible solo en NX-OS


def rows(data, table, row):
    """NX-OS devuelve un dict si hay 1 fila y una lista si hay varias."""
    item = (data or {}).get(table, {}).get(row, [])
    return item if isinstance(item, list) else [item]


def nve_peers():
    data = json.loads(clid("show nve peers") or "{}")
    return [(p.get("peer-ip"), p.get("peer-state")) for p in rows(data, "TABLE_nve_peers", "ROW_nve_peers")]


def nve_vnis():
    data = json.loads(clid("show nve vni") or "{}")
    return [(v.get("vni"), v.get("type"), v.get("vni-state")) for v in rows(data, "TABLE_nve_vni", "ROW_nve_vni")]


def main():
    to_syslog = "--syslog" in sys.argv
    problems = []

    peers = nve_peers()
    vnis = nve_vnis()
    problems += ["peer {} {}".format(ip, st) for ip, st in peers if st != "Up"]
    problems += ["vni {} {}".format(vni, st) for vni, _, st in vnis if st != "Up"]

    summary = "VXLAN-HEALTH peers={} vnis={} problemas={}".format(len(peers), len(vnis), len(problems))
    if to_syslog:
        level = 3 if problems else 6
        detail = "; ".join(problems) if problems else "OK"
        cli('logging message "{} {}" level {}'.format(summary, detail, level))
    else:
        print(summary)
        for ip, state in peers:
            print("  peer {:<15} {}".format(ip, state))
        for vni, kind, state in vnis:
            print("  vni  {:<8} {:<10} {}".format(vni, kind, state))
        for p in problems:
            print("  !! " + p)

    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
