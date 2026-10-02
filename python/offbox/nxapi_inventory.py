"""Inventario del fabric vía NX-API (off-box), leyendo la fuente de verdad NaC.

Los equipos y sus URLs se toman de nac/nxos/data/devices/*.nac.yaml: el mismo
modelo de datos que usa Terraform, así no se duplica el inventario.

    make inventory          # o: python python/offbox/nxapi_inventory.py
"""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass
from pathlib import Path

import requests
import urllib3
import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DATA_DIR = REPO_ROOT / "nac" / "nxos" / "data"


@dataclass(frozen=True)
class Device:
    name: str
    url: str


def load_devices(data_dir: Path = DEFAULT_DATA_DIR) -> list[Device]:
    """Devuelve los dispositivos declarados en los YAML de NaC (nxos.devices)."""
    devices: list[Device] = []
    for path in sorted(data_dir.rglob("*.y*ml")):
        content = yaml.safe_load(path.read_text()) or {}
        for dev in (content.get("nxos") or {}).get("devices", []) or []:
            if dev.get("url"):
                devices.append(Device(name=dev["name"], url=dev["url"].rstrip("/")))
    return devices


def show(device: Device, command: str, auth: tuple[str, str]) -> dict:
    """Ejecuta un 'show' por NX-API JSON-RPC y devuelve el body."""
    payload = [{"jsonrpc": "2.0", "method": "cli", "params": {"cmd": command, "version": 1}, "id": 1}]
    resp = requests.post(
        f"{device.url}/ins",
        json=payload,
        auth=auth,
        headers={"content-type": "application/json-rpc"},
        verify=False,  # certificado autofirmado del N9Kv de laboratorio
        timeout=15,
    )
    resp.raise_for_status()
    return resp.json()["result"]["body"]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--data-dir", type=Path, default=DEFAULT_DATA_DIR)
    args = parser.parse_args()

    auth = (os.environ.get("NXOS_USERNAME", "admin"), os.environ.get("NXOS_PASSWORD", ""))
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    print(f"{'DEVICE':<10} {'MODEL':<28} {'NXOS':<12} {'SERIAL':<14} UPTIME(d)")
    failed = 0
    for dev in load_devices(args.data_dir):
        try:
            ver = show(dev, "show version", auth)
            print(
                f"{dev.name:<10} {ver.get('chassis_id', '?')[:27]:<28} {ver.get('nxos_ver_str', '?'):<12} "
                f"{ver.get('proc_board_id', '?'):<14} {ver.get('kern_uptm_days', '?')}"
            )
        except requests.RequestException as exc:
            failed += 1
            print(f"{dev.name:<10} ERROR: {exc}", file=sys.stderr)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
