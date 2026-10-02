# 04 · Flujo de trabajo Network as Code

## Principios
1. **La fuente de verdad es `nac/*/data`.** Si no está en YAML, no existe.
2. **Nunca se configura a mano el fabric NaC.** Un cambio manual es *drift*:
   `make nxos-plan` lo detecta y propone revertirlo.
3. **Se valida antes y se verifica después.** `nac-validate` (antes) → `terraform plan`
   (revisión) → `apply` → `ansible verify` (después).
4. **Todo cambio entra por Git.** Rama → commit (pre-commit) → PR → CI verde → merge → deploy.

## Cómo está organizado el modelo NX-OS
```
data/
├── 00-global.nac.yaml      # features y system comunes a todos
├── 10-spines.nac.yaml      # device_group "spines": OSPF + BGP RR
├── 11-leafs.nac.yaml       # device_group "leafs": VTEP, NVE, anycast GW
├── 20-tenant-a.nac.yaml    # device_group "tenant-a": VRF, VLAN/VNI, SVI
└── devices/*.nac.yaml      # lo único por equipo: URL, hostname, variables, enlaces
```
Precedencia: **global → device_groups → device** (gana lo más específico).
Los valores `${loopback0}` se resuelven con las `variables` de cada dispositivo.

## Ciclo de un cambio (ej. Tenant B)
```bash
git switch -c feat/tenant-b
cp nac/nxos/data/20-tenant-a.nac.yaml nac/nxos/data/21-tenant-b.nac.yaml
#   editar: name tenant-b, VRF TENANT-B, VNI 50002, VLAN 30 -> 10030, 172.16.30.1/24
make nxos-validate        # reglas: VNI únicos, loopbacks únicos, enlaces /31
make nxos-plan            # revisa: solo debe AÑADIR objetos en los leafs
make nxos-apply
make verify               # OSPF/BGP/NVE siguen como se esperaba
git commit -am "feat(nxos): add tenant B" && git push   # abre PR, CI valida
```

## Despliegue selectivo
```bash
make nxos-plan GROUPS='["spines"]'     # solo spines
make nxos-plan DEVICES='["leaf3"]'     # solo un equipo (ventana de mantenimiento)
```

## Añadir una regla de validación
Crea `nac/nxos/rules/1NN_nombre.py` con una clase `Rule` (`id`, `description`, `severity`
y `match(data)` que devuelve la lista de errores) y un test negativo en `tests/test_nac_rules.py`.

## ¿Y Ansible?
Terraform es **declarativo**: describe el estado final. Ansible complementa con lo
**imperativo y operativo**: verificaciones, backups, recogida de estado y tareas de día 2
que no son "configuración" (por ejemplo, `show` + asserts, upgrades, troubleshooting).

## Estado de Terraform
Cada raíz (`nac/nxos`, `nac/aci`, `cml/terraform`) guarda su estado local (ignorado por git).
Cuando quieras simular un equipo real: backend remoto (S3/MinIO, Terraform Cloud o GitLab)
con bloqueo de estado.
