"""Las reglas semánticas deben detectar errores típicos (tests negativos)."""

import importlib.util
from pathlib import Path

RULES = Path(__file__).resolve().parents[1] / "nac" / "nxos" / "rules"


def load(name):
    spec = importlib.util.spec_from_file_location(name, RULES / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.Rule


def test_duplicate_loopback_is_detected():
    data = {
        "nxos": {
            "devices": [
                {"name": "a", "variables": {"loopback0": "10.0.0.1"}},
                {"name": "b", "variables": {"loopback0": "10.0.0.1"}},
            ]
        }
    }
    assert load("101_unique_loopbacks").match(data)


def test_half_configured_p2p_link_is_detected():
    data = {
        "nxos": {
            "devices": [
                {
                    "name": "a",
                    "configuration": {
                        "interfaces": {"ethernets": [{"id": "1/1", "ip": {"address": "10.1.1.0/31"}}]}
                    },
                },
            ]
        }
    }
    assert load("102_p2p_links").match(data)


def test_vni_reused_for_two_vlans_is_detected():
    data = {
        "nxos": {
            "device_groups": [
                {"name": "t1", "configuration": {"vlan": {"vlans": [{"id": 10, "vn_segment": 10010}]}}},
                {"name": "t2", "configuration": {"vlan": {"vlans": [{"id": 20, "vn_segment": 10010}]}}},
            ]
        }
    }
    assert load("103_vni_consistency").match(data)
