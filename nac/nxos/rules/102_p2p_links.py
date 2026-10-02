"""Cada enlace /31 del underlay debe tener exactamente dos extremos en dispositivos distintos."""

import ipaddress
from collections import defaultdict


class Rule:
    id = "102"
    description = "Los enlaces punto a punto /31 deben tener exactamente dos extremos"
    severity = "HIGH"

    @classmethod
    def match(cls, data):
        links = defaultdict(list)
        for device in data.get("nxos", {}).get("devices", []) or []:
            interfaces = (device.get("configuration") or {}).get("interfaces") or {}
            for eth in interfaces.get("ethernets", []) or []:
                address = (eth.get("ip") or {}).get("address")
                if not address:
                    continue
                iface = ipaddress.ip_interface(address)
                if iface.network.prefixlen == 31:
                    links[iface.network].append((device["name"], f"Eth{eth['id']}", str(iface.ip)))

        results = []
        for network, ends in links.items():
            if len(ends) != 2:
                results.append(f"{network}: {len(ends)} extremo(s) {ends}")
            elif ends[0][0] == ends[1][0]:
                results.append(f"{network}: ambos extremos en {ends[0][0]}")
            elif ends[0][2] == ends[1][2]:
                results.append(f"{network}: IP duplicada {ends[0][2]}")
        return results
