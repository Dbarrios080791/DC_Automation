"""Cada router-id / VTEP (variables loopback0/loopback1) debe ser único en el fabric."""

from collections import defaultdict


class Rule:
    id = "101"
    description = "Las direcciones loopback0/loopback1 deben ser únicas por dispositivo"
    severity = "HIGH"

    @classmethod
    def match(cls, data):
        owners = defaultdict(list)
        for device in data.get("nxos", {}).get("devices", []) or []:
            for var in ("loopback0", "loopback1"):
                ip = (device.get("variables") or {}).get(var)
                if ip:
                    owners[ip].append(f"{device['name']}.{var}")
        return [
            f"{ip} está repetida en: {', '.join(names)}" for ip, names in owners.items() if len(names) > 1
        ]
