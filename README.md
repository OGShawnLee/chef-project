# Proyecto: Automatización y Despliegue de Servidores con Chef Infra y Vagrant

[![Universidad Veracruzana](https://img.shields.io/badge/Universidad-Veracruzana-0072CE?style=flat-square)](https://www.uv.mx/)
[![Materia](https://img.shields.io/badge/Materia-Despliegue%20de%20Software-10b981?style=flat-square)](#)
[![Semestre](https://img.shields.io/badge/Semestre-7%C2%B0%20Semestre-f59e0b?style=flat-square)](#)
[![Herramienta](https://img.shields.io/badge/Herramienta-Chef%20Infra%20(Cinc)-f38020?style=flat-square)](https://cinc.sh/)
[![OS](https://img.shields.io/badge/OS-Debian%2012%20(Bookworm)-d70a53?style=flat-square)](https://www.debian.org/)

Este repositorio contiene la investigación técnica, el código de infraestructura como código (IaC), los scripts de aprovisionamiento automatizado y los recursos de laboratorio para la presentación de la herramienta **Chef** en la experiencia educativa de **Despliegue de Software**.

---

## 🎯 Propósito del Proyecto

Demostrar de forma práctica y reproducible cómo **Chef Infra** (mediante su distribución abierta **Cinc Client**) resuelve el problema de la **deriva de configuración** (*configuration drift*) y garantiza la **idempotencia** al aprovisionar y configurar de manera desatendida un servidor web **Nginx** con una página dinámica inyectada con métricas en tiempo real recopiladas por el motor **Ohai**.

Todo el entorno se ejecuta de manera aislada y limpia sobre una máquina virtual **Debian 12 Bookworm** gestionada por **Vagrant** y **VirtualBox**, asegurando que no se requiera instalar paquetes ni ensuciar el sistema operativo anfitrión.

---

## 🛠️ Stack Tecnológico

* **Hipervisor & Virtualización:** [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://www.vagrantup.com/)
* **Sistema Operativo Invitado:** Debian 12 64-bit (`debian/bookworm64`)
* **Motor de Configuración:** Chef Infra / Cinc Client (Modo Local / Chef-Zero)
* **Motor de Telemetría:** Ohai (Descubrimiento automático de hardware, IP, RAM y kernel)
* **Servicio Web Desplegado:** Nginx con plantilla dinámica en Embedded Ruby (`.erb`)

---

## 📋 Requisitos Previos

Para ejecutar este proyecto en tu computadora únicamente necesitas tener instalado:

1. **VirtualBox** (versión 6.1 o 7.x): [Descargar VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. **Vagrant** (versión 2.2 o superior): [Descargar Vagrant](https://developer.hashicorp.com/vagrant/install)
3. **Git**: [Descargar Git](https://git-scm.com/)

---

## 🚀 Inicio Rápido (En 3 Pasos)

### 1. Clonar el repositorio
Abre una terminal (PowerShell o Git Bash) y clona el proyecto:
```bash
git clone <URL_DE_TU_REPOSITORIO>
cd chef-project
```

### 2. Encender y aprovisionar la máquina virtual
Ejecuta el siguiente comando:
```bash
vagrant up
```
> *Vagrant descargará la caja oficial de Debian 12 Bookworm, encenderá la máquina virtual, instalará Chef Infra Client y convergerá la receta de Nginx automáticamente en aproximadamente 1 minuto.*

### 3. Verificar en el navegador
Una vez concluido el aprovisionamiento, abre tu navegador web en:
👉 **[http://localhost:8080](http://localhost:8080)**

Verás el dashboard web interactivo con los datos del servidor (nombre de host, memoria RAM, IP interna y fecha de última convergencia) recopilados por Ohai.

---

## 🔁 Comprobación de Idempotencia

Para demostrar en vivo la **idempotencia** de Chef ante el profesor o compañeros:

Vuelve a ejecutar el aprovisionador sobre la máquina ya encendida:
```bash
vagrant provision
```
**Resultado:** Chef inspeccionará el sistema en 2 segundos y reportará `0 resources updated` (0 recursos modificados), demostrando que el servidor ya se encuentra en su **estado deseado** y evitando reinicios o modificaciones innecesarias.

---

## 💻 Comandos Útiles de Vagrant

| Comando | Descripción |
| :--- | :--- |
| `vagrant up` | Enciende la máquina virtual y ejecuta Chef por primera vez. |
| `vagrant provision` | Vuelve a ejecutar Chef sobre la VM para aplicar cambios en la receta. |
| `vagrant ssh` | Abre una sesión de terminal SSH dentro de la máquina virtual Debian. |
| `vagrant status` | Muestra el estado actual de la máquina virtual. |
| `vagrant halt` | Apaga la máquina virtual guardando su estado. |
| `vagrant destroy -f` | **Elimina por completo la máquina virtual** liberando espacio en disco. |

---

## 📂 Estructura del Repositorio

```
chef-project/
├── Vagrantfile                 # Definición de la VM (Debian 12, red, RAM, provisionador)
├── install_cinc.sh             # Script de instalación automática de Cinc Client
├── run_demo.sh                 # Script de ejecución de Chef en Modo Local
├── cookbooks/
│   └── web_server/             # Cookbook principal de la demostración
│       ├── metadata.rb         # Metadatos del cookbook (versión, soporte)
│       ├── attributes/
│       │   └── default.rb      # Variables configurables (puerto, título, autor)
│       ├── files/
│       │   └── default/        # Recursos estáticos y tipografías locales (WOFF2)
│       ├── recipes/
│       │   └── default.rb      # Receta en Ruby DSL (apt, package, directory, template, service)
│       └── templates/
│           └── default/
│               ├── index.html.erb      # Dashboard principal inyectado con métricas de Ohai
│               └── easter_egg.html.erb # Plantilla secreta del Reto Final (Easter Egg)
├── LAB_GUIDE.md                # Guía práctica del laboratorio (Antes -> Auto -> Resultado)
├── MONOGRAFIA_CHEF.md          # Monografía técnica exhaustiva en prosa continua
├── ARQUITECTURA_Y_FLUJO.md     # Explicación del ciclo de vida y modelo de capas
└── GUIA_ACTIVIDAD.md           # Guía íntegra de requerimientos y evaluación de la actividad
```

---

## 📚 Documentación de Consulta

* 🧪 **[Guía Práctica de Laboratorio](LAB_GUIDE.md):** Manual paso a paso para estudiantes con la dinámica *Antes $\rightarrow$ Automatización $\rightarrow$ Resultado* y evidencias.
* 📖 **[Monografía Técnica Completa](MONOGRAFIA_CHEF.md):** Historia, problemas que resuelve, filosofía declarativa/imperativa, ciclo de compilación/convergencia y comparativa con Ansible y Terraform.
* 🧭 **[Guía de Arquitectura y Ciclo de Vida](ARQUITECTURA_Y_FLUJO.md):** Diagrama de secuencia, modelo de capas, Chef-Zero y el rol de Chef vs Docker en la industria.
* 📋 **[Guía Oficial de la Actividad](GUIA_ACTIVIDAD.md):** Los 10 puntos clave de la exposición oral, estructura del laboratorio y requisitos de los entregables.
