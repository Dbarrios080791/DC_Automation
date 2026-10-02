# 01 · Nodo de control (macOS / Linux)

El **nodo de control** es el equipo donde se escribe el código, se valida y se ejecuta
Terraform/Ansible. Los switches corren en un servidor CML aparte.

## 1. Herramientas base (ejemplo con Homebrew en macOS)
```bash
brew install git make python@3.12 tfenv
brew install --cask visual-studio-code
tfenv install          # lee .terraform-version del repo
tfenv use
```
> `make` de macOS es GNU make 3.81 y sirve. `tfenv` permite fijar la versión de Terraform por repo.

## 2. Clonar y preparar el entorno virtual
```bash
git clone https://github.com/Dbarrios080791/DC_Automation.git
cd DC_Automation
make setup             # crea .venv, instala requirements.txt, colecciones Ansible y pre-commit
source .venv/bin/activate
```
`make setup` crea `.env` desde `.env.example`. Rellénalo con tus credenciales: está en
`.gitignore` y **nunca** se sube.

## 3. VS Code
Abre la carpeta y acepta las extensiones recomendadas (`.vscode/extensions.json`):
Terraform, Ansible, YAML, Python y Ruff.

## 4. Comprobación
```bash
make lint              # todos los linters
make test              # tests offline
make nxos-validate     # valida el modelo NaC sin tocar la red
```

## 5. Conectividad nodo de control → CML
El nodo de control debe alcanzar la red de gestión de los labs (`192.168.100.0/24`, ver
[03-direccionamiento.md](03-direccionamiento.md)):
```bash
ping 192.168.100.11    # spine1, con el fabric NaC encendido
```
