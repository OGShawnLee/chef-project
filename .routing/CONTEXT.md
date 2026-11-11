# CONTEXT: Panorama General del Proyecto para Agentes y Desarrolladores

> **Área:** Despliegue de Software • 7° Semestre • Universidad Veracruzana  
> **Tema Central:** Automatización de Infraestructura como Código (IaC) con **Chef Infra (Cinc Client)** y **Vagrant**  
> **Directorio Raíz:** `chef-project/`

---

## 🎯 1. Propósito y Alcance del Repositorio

Este repositorio contiene la suite completa de desarrollo, aprovisionamiento automatizado, recursos de laboratorio práctico y documentación técnica de **Chef Infra**.

El proyecto demuestra de forma reproducible y reproducible cómo resolver los problemas de:
1. **Deriva de Configuración (*Configuration Drift*):** Detección y corrección continua de desviaciones respecto al estado deseado.
2. **Idempotencia:** Ejecución repetida de recetas sin generar efectos colaterales, modificaciones redundantes ni reinicios de servicios innecesarios.
3. **Telemetría y Descubrimiento en Tiempo Real:** Uso del motor **Ohai** para auditar el sistema operativo y hardware, inyectando variables dinámicamente en plantillas `.erb`.

---

## 🛠️ 2. Stack Tecnológico

| Componente | Rol / Detalle |
| :--- | :--- |
| **Virtualización** | [Vagrant](https://www.vagrantup.com/) + [VirtualBox](https://www.virtualbox.org/) |
| **Sistema Operativo Invitado** | Debian 12 Bookworm 64-bit (`debian/bookworm64`) |
| **Motor de Configuración** | **Chef Infra** mediante su distribución comunitaria **Cinc Client** (v18+) |
| **Modo de Ejecución** | **Chef-Zero / Modo Local** (`cinc-client --local-mode`), sin servidor Chef dedicado |
| **Motor de Hechos / Telemetría** | **Ohai** (captura CPU, RAM, IP, SO, Hostname) |
| **Servicio Desplegado** | Servidor Web **Nginx** con dashboard interactivo (`http://localhost:8080`) |

---

## 🧭 3. Estructura del Proyecto y Rutas Clave

```
chef-project/
├── .routing/                       # Hub de documentación especializada (este directorio)
│   ├── CONTEXT.md                  # Mapa mental y contexto general para agentes
│   ├── CHEF_GUIA_DEFINITIVA.md     # Guía integral de arquitectura, Ansible vs Chef y Día 0 a Prod
│   ├── ARQUITECTURA_Y_FLUJO.md     # Diagramas de secuencia y separación de capas Vagrant/Chef
│   ├── LAB_GUIDE.md                # Manual práctico de laboratorio (Antes -> Auto -> Resultado)
│   ├── MONOGRAFIA_CHEF.md          # Monografía de investigación teórica en prosa continua
│   └── GUIA_ACTIVIDAD.md           # Rúbrica de evaluación y puntos clave para exposición
├── cookbooks/
│   └── web_server/                 # Cookbook principal de Chef
│       ├── metadata.rb             # Metadatos del cookbook (versión 1.0.0, licencia, compatibilidad)
│       ├── attributes/default.rb   # Atributos configurables (puerto 80, títulos, rutas)
│       ├── files/default/          # Recursos estáticos y tipografías locales (Ranade WOFF2, imágenes)
│       ├── recipes/default.rb       # Receta en Ruby DSL (apt_update, package, directory, template, service)
│       └── templates/default/
│           ├── index.html.erb      # Dashboard web principal inyectado con datos de Ohai
│           └── easter_egg.html.erb # Plantilla del reto práctico para estudiantes
├── install_cinc.sh                 # Script Bash para instalar Cinc Client vía omnitruck
├── run_demo.sh                     # Script Bash para converger la receta en Chef-Zero
├── Vagrantfile                     # Configuración de hardware virtual, red y aprovisionador
└── README.md                       # Portada y guía de inicio rápido del repositorio
```

---

## 📚 4. Índice y Enlaces a la Documentación Técnica (`.routing/`)

Para profundizar en cualquier aspecto del proyecto, consulta los documentos especializados en esta carpeta:

1. 📘 **[CHEF_GUIA_DEFINITIVA.md](CHEF_GUIA_DEFINITIVA.md)**  
   * **Contenido:** Manual exhaustivo que cubre:
     - Definición y problemas estructurales (Deriva, Idempotencia, *Pets vs. Cattle*).
     - Comparativa detallada **Chef vs. Ansible** (Push vs. Pull, YAML vs. Ruby DSL).
     - El rol exacto de **Ohai** (por qué es recolector de hechos y no un validador).
     - **Flujo completo Día Cero a Producción:** Instalación del Chef Server central (`chef-server-ctl`), generación de certificados RSA (`admin.pem`, `org-validator.pem`), configuración de la Workstation (`knife`) y proceso de *Bootstrap*.
     - Aislamiento de variables de entorno y Chef-Zero.

2. 🧭 **[ARQUITECTURA_Y_FLUJO.md](ARQUITECTURA_Y_FLUJO.md)**  
   * **Contenido:** Modelo de dos capas (Infraestructura con Vagrant vs. Configuración con Chef), diagramas de secuencia Mermaid del flujo `vagrant up` $\rightarrow$ convergencia $\rightarrow$ Nginx, y explicación de la relación legal/técnica entre `chef-client` y `cinc-client`.

3. 🧪 **[LAB_GUIDE.md](LAB_GUIDE.md)**  
   * **Contenido:** Manual paso a paso diseñado para estudiantes y evaluadores:
     - El escenario problemático.
     - El "Antes" (comandos manuales tradicionales y riesgos).
     - El "Después" (automatización reproducible en 3 pasos).
     - Demostración en vivo de la idempotencia con `vagrant provision`.
     - Reto práctico: despliegue de la página secreta *Easter Egg*.

4. 📖 **[MONOGRAFIA_CHEF.md](MONOGRAFIA_CHEF.md)**  
   * **Contenido:** Monografía técnica en prosa continua: historia de Chef Software Inc. (2008) hasta Progress Software (2020), fundamentos del DSL de Ruby, fases internas del agente (Compile Phase vs. Convergence Phase) y comparativa complementaria con Terraform y Docker.

5. 📋 **[GUIA_ACTIVIDAD.md](GUIA_ACTIVIDAD.md)**  
   * **Contenido:** Guía de requerimientos y evaluación para la experiencia educativa: los 10 puntos temáticos obligatorios de exposición, checklist de entregables y rúbrica práctica.

---

## ⚡ 5. Comandos de Operación Rápida

* **Iniciar todo el entorno:**
  ```bash
  vagrant up
  ```
* **Comprobar Idempotencia (re-ejecutar sin cambios):**
  ```bash
  vagrant provision
  ```
* **Acceso por terminal a la VM:**
  ```bash
  vagrant ssh
  ```
* **Destruir y limpiar el entorno:**
  ```bash
  vagrant destroy -f
  ```
* **URL de acceso local al servidor web:**
  `http://localhost:8080`
