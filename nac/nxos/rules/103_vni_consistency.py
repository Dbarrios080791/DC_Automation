"""Un VNI identifica un único segmento: no puede mapearse a dos VLAN distintas
ni reutilizarse entre tenants."""

from collections import defaultdict


def _scopes(data):
    nxos = data.get("nxos", {}) or {}
    yield "global", (nxos.get("global") or {}).get("configuration") or {}
    for group in nxos.get("device_groups", []) or []:
        yield f"group:{group['name']}", group.get("configuration") or {}
    for device in nxos.get("devices", []) or []:
        yield f"device:{device['name']}", device.get("configuration") or {}


class Rule:
    id = "103"
    description = "Cada VNI debe mapear a una sola VLAN en todo el fabric"
    severity = "HIGH"

    @classmethod
    def match(cls, data):
        vni_to_vlans = defaultdict(set)
        where = defaultdict(set)
        for scope, config in _scopes(data):
            for vlan in ((config.get("vlan") or {}).get("vlans")) or []:
                vni = vlan.get("vn_segment")
                if vni is not None:
                    vni_to_vlans[vni].add(vlan["id"])
                    where[vni].add(scope)
        return [
            f"VNI {vni} mapeado a VLANs {sorted(vlans)} en {sorted(where[vni])}"
            for vni, vlans in vni_to_vlans.items()
            if len(vlans) > 1
        ]
