"""Tests offline: no requieren CML encendido."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "python" / "offbox"))

from nxapi_inventory import DEFAULT_DATA_DIR, load_devices  # noqa: E402


def test_inventory_comes_from_nac_source_of_truth():
    devices = {d.name: d.url for d in load_devices(DEFAULT_DATA_DIR)}
    assert set(devices) == {"spine1", "spine2", "leaf1", "leaf2", "leaf3"}
    assert all(url.startswith("https://") for url in devices.values())


def test_device_urls_are_unique():
    urls = [d.url for d in load_devices(DEFAULT_DATA_DIR)]
    assert len(urls) == len(set(urls))


def test_ansible_inventory_matches_nac_data():
    import yaml

    inv = yaml.safe_load(
        (Path(__file__).resolve().parents[1] / "ansible/inventory/nac-fabric.yml").read_text()
    )
    groups = inv["all"]["children"]["nac_fabric"]["children"]
    ansible_hosts = {h: v["ansible_host"] for g in groups.values() for h, v in g["hosts"].items()}
    nac_hosts = {d.name: d.url.removeprefix("https://") for d in load_devices(DEFAULT_DATA_DIR)}
    assert ansible_hosts == nac_hosts
