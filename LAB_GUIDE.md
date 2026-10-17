# Guía Práctica de Laboratorio: Automatización de Servidores con Chef Infra y Vagrant

> **Experiencia Educativa:** Despliegue de Software • 7° Semestre • Universidad Veracruzana  
> **Herramienta Evaluada:** **Chef Infra** (Cinc Client v18+) sobre **Debian 12 Bookworm**  
> **Duración Estimada:** 20 a 30 minutos  
> **Modalidad:** Individual o por parejas

---

## 🎯 1. Objetivo de la Práctica

Al finalizar este laboratorio, el estudiante será capaz de:
1. Comprender la diferencia práctica entre la **administración manual de servidores** y la **Gestión de Configuración como Código (IaC)**.
2. Desplegar un entorno virtualizado idéntico y reproducible utilizando **Vagrant** con **Debian 12 Bookworm**.
3. Ejecutar y analizar el ciclo de vida de convergencia de **Chef Infra Client** en modo local (**Chef-Zero**).
4. Comprobar empíricamente el principio de **Idempotencia** mediante la herramienta `vagrant provision`.
5. Inspeccionar cómo el motor **Ohai** recopila telemetría del sistema operativo para inyectarla dinámicamente en plantillas web (**Embedded Ruby - ERB**).

---

## 🏢 2. Escenario o Problema a Resolver

Una empresa de servicios digitales necesita poner en marcha un nuevo servidor web **Nginx** para alojar un dashboard interno de monitoreo. La infraestructura debe garantizar que:
* El software esté instalado en su versión oficial de paquetes del sistema.
* La ruta `/var/www/html` cuente con los permisos de usuario y grupo correctos (`root:root`, permisos `0755`).
* La página de inicio muestre métricas del servidor en tiempo real (nombre del nodo, versión del kernel, IP y memoria RAM disponible).
* El servicio de Nginx esté habilitado para iniciar automáticamente ante cualquier reinicio del sistema operativo.
* Si un administrador entra y comete un error manual, el sistema pueda restaurarse a su **estado deseado** en segundos sin reinstalar la máquina.

---

## 📋 3. Requisitos Previos

Antes de comenzar, verifica que tu computadora anfitriona tenga instaladas las siguientes herramientas:

| Herramienta | Versión Mínima Requerida | Enlace de Descarga |
| :--- | :---: | :--- |
| **VirtualBox** | 6.1 o 7.x | [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads) |
| **Vagrant** | 2.2 o superior | [developer.hashicorp.com/vagrant/install](https://developer.hashicorp.com/vagrant/install) |
| **Git** | Cualquiera | [git-scm.com](https://git-scm.com/) |

> [!NOTE]
> No necesitas tener Ruby, Chef ni Nginx instalados en tu computadora física con Windows o Mac. Toda la ejecución ocurrirá de forma aislada dentro de la máquina virtual gestionada por Vagrant.

---

## 🧗 4. El "Antes": El Proceso Manual Tradicional (La Pesadilla del SysAdmin)

Para entender el valor de Chef, analicemos qué tendría que hacer un ingeniero si tuviera que configurar este servidor **a mano** en cada una de las máquinas de la empresa:

```
[Administrador] --(SSH)--> [Servidor 1] -> Comandos manuales paso a paso
                --(SSH)--> [Servidor 2] -> Comandos manuales paso a paso
                --(SSH)--> [Servidor N] -> Riesgo inminente de error humano
```

### Comandos manuales que se requerían:
```bash
# 1. Conectarse por SSH
ssh usuario@servidor-ip

# 2. Actualizar repositorios manualmente
sudo apt update

# 3. Instalar Nginx y confirmar dependencias
sudo apt install -y nginx

# 4. Crear carpetas y ajustar permisos a mano
sudo mkdir -p /var/www/html
sudo chown -R root:root /var/www/html
sudo chmod 755 /var/www/html

# 5. Obtener datos del sistema a mano para la página web
hostname
ip a
free -m
uname -r

# 6. Escribir a mano el archivo HTML con un editor de texto (nano o vim)
sudo nano /var/www/html/index.html
# (Pegar código HTML estático, escribiendo las IPs y datos a mano)

# 7. Habilitar y arrancar el demonio
sudo systemctl enable nginx
sudo systemctl restart nginx
```

### ¿Por qué este proceso manual es insostenible en producción?
* **Deriva de Configuración (*Configuration Drift*):** Si tienes 10 servidores, es casi seguro que en uno se te olvidará fijar los permisos `0755`, o en otro instalarás una versión distinta de paquetes.
* **Cero Idempotencia:** Si ejecutas estos comandos dos veces por error, puedes sobrescribir configuraciones en caliente o reiniciar servicios innecesariamente provocando caídas de servicio (*downtime*).
* **Falta de Trazabilidad:** Nadie sabe quién hizo qué cambio ni cuándo, porque no hay un repositorio de Git que registre la configuración del servidor.

---

## ⚡ 5. La "Automatización": Despliegue con Chef Infra y Vagrant

Con Chef Infra y Vagrant, el proceso manual de 7 pasos se reduce a **un solo comando declarativo**.

### Paso 1: Clonar el repositorio del laboratorio
Abre una terminal (PowerShell en Windows, Terminal en macOS/Linux) y clona el proyecto:
```bash
git clone https://github.com/OGShawnLee/chef-project.git
cd chef-project
```

### Paso 2: Explorar los archivos de configuración
Antes de encender el servidor, tómate un minuto para inspeccionar la estructura:
* **`Vagrantfile`**: Define que usaremos **Debian 12 Bookworm** y redirige el puerto `80` de la VM al puerto `8080` de tu PC.
* **`cookbooks/web_server/recipes/default.rb`**: La receta de Chef en Ruby DSL que declara el estado deseado:
  ```ruby
  package 'nginx' do
    action :install
  end

  directory '/var/www/html' do
    mode '0755'
    action :create
  end

  template '/var/www/html/index.html' do
    source 'index.html.erb'
    action :create
    notifies :reload, 'service[nginx]', :delayed
  end

  service 'nginx' do
    action [:enable, :start]
  end
  ```
* **`cookbooks/web_server/templates/default/index.html.erb`**: La plantilla que inyecta automáticamente variables recolectadas por **Ohai** (`<%= node['hostname'] %>`, `<%= node['memory']['total'] %>`, etc.).

### Paso 3: Desplegar el servidor automáticamente
Ejecuta el siguiente comando en la raíz del proyecto:
```bash
vagrant up
```

### ¿Qué está ocurriendo en segundo plano?
1. **Vagrant** descarga la imagen oficial de Debian 12 (si no la tenías ya) y arranca la máquina virtual en VirtualBox.
2. Vagrant monta la carpeta del proyecto dentro de la VM en `/vagrant`.
3. Se dispara el instalador [`install_cinc.sh`](install_cinc.sh), descargando el cliente oficial abierto de Chef (**Cinc Client**) en segundos.
4. Se ejecuta [`run_demo.sh`](run_demo.sh) invocando a `cinc-client --local-mode` (**Chef-Zero**).
5. **Ohai** audita el hardware del nodo.
6. Chef evalúa la receta, instala Nginx, renderiza la plantilla y arranca el servicio en `systemd`.

---

## 🌐 6. El "Resultado": Verificación y Comprobación

Una vez que la terminal devuelva el control, comprueba que el servidor esté activo:

### Comprobación A: En el Navegador Web
Abre tu navegador web favorito y entra a la siguiente dirección:
👉 **[http://localhost:8080](http://localhost:8080)**

**Resultado Esperado:**  
Verás el dashboard web interactivo con el logotipo de Chef, una alerta verde que confirma *"Estado Deseado Alcanzado"*, y tarjetas informativas con las métricas reales de tu máquina virtual Debian 12 (nombre de host, IP interna, memoria RAM y fecha de convergencia).

### Comprobación B: Vía Terminal con `curl`
Desde otra pestaña de terminal en tu computadora anfitriona:
```bash
curl -I http://localhost:8080
```
**Resultado Esperado:**
```http
HTTP/1.1 200 OK
Server: nginx/...
Content-Type: text/html
...
```

---

## 🔁 7. Demostración Práctica de Idempotencia

La idempotencia es la propiedad fundamental de Chef: **aplicar la misma configuración múltiples veces produce exactamente el mismo resultado sin efectos colaterales**.

Ejecuta el siguiente comando sobre la máquina que ya está encendida:
```bash
vagrant provision
```

### Observa detenidamente la salida en terminal:
* En la primera ejecución (`vagrant up`), Chef reportó:  
  `Chef Infra Client finished, 5/5 resources updated`
* En esta segunda ejecución (`vagrant provision`), Chef reportará:  
  `Chef Infra Client finished, 0/5 resources updated`

**Conclusión pedagógica:** Chef no desinstaló Nginx, no sobreescribió el archivo innecesariamente y no reinició el servicio. Inspeccionó el estado del servidor, verificó que ya cumplía la receta al 100% y terminó en menos de 2 segundos.

---

## 📸 8. Evidencias del Laboratorio Base

Para validar que completaste la práctica base, toma y guarda las siguientes **dos evidencias**:

1. **Evidencia 1 (Dashboard en Navegador):** Captura de pantalla de tu navegador mostrando `http://localhost:8080` con el dashboard de Chef y las métricas de tu nodo.
2. **Evidencia 2 (Log de Idempotencia):** Captura de tu terminal tras ejecutar `vagrant provision` donde se aprecie claramente el mensaje `0 resources updated`.

---

## 🏆 9. Reto Final del Laboratorio: El Monumento Oculto

Para evitar la copia mecánica y validar que has comprendido cómo Chef gestiona el **estado deseado**, las **plantillas dinámicas (`.erb`)** y la **convergencia diferencial**, deberás resolver el siguiente desafío:

---

### 🏛️ El Escenario del Reto
Dentro de la estructura del repositorio existe una plantilla secreta en formato Embedded Ruby ubicada en:  
`cookbooks/web_server/templates/default/easter_egg.html.erb`

Sin embargo, si abres tu navegador web e intentas acceder a:  
👉 **`http://localhost:8080/easter_egg.html`**

El servidor web Nginx te arrojará un error **`404 Not Found`**. Esto ocurre porque la receta actual de Chef **no tiene declarada esta plantilla** dentro de su catálogo de recursos, por lo que para el sistema operativo simplemente no existe.

> 🛡️ **Nota Antifraude (Guardia Pretoriana):**  
> No intentes renombrar el archivo `.erb` a `.html` ni abrirlo con doble clic desde tu laptop (`file://`). La plantilla requiere que **Chef Infra e inyecte los datos reales de Ohai** de tu máquina virtual y que sea servida por **Nginx**; de lo contrario, se activará el bloqueo de seguridad.

---

### 🎯 Tu Misión
1. Modificar la receta principal de Chef ([`cookbooks/web_server/recipes/default.rb`](cookbooks/web_server/recipes/default.rb)) en la **Sección 7 (Zona del Reto Final)** para declarar que la plantilla `easter_egg.html.erb` debe compilarse y desplegarse en el directorio raíz del servidor web (`/var/www/html/easter_egg.html`) con permisos `0644` y propietario `root`.
2. Converger la máquina virtual en caliente utilizando **Vagrant** (sin reiniciar ni destruir la máquina).
3. Desbloquear y descubrir la página secreta en tu navegador, verificando que aparezca el sello de autenticidad de Ohai con el Hostname e IP de tu VM.

---

### 💡 Pistas Técnicas (Sin solución regalada)

* **Pista 1: El recurso de Chef adecuado.**  
  Para compilar plantillas dinámicas `.erb` desde la carpeta `templates/default/` e inyectarles datos de Ohai (`node['hostname']`, `node['ipaddress']`), Chef utiliza el recurso **`template`**.
* **Pista 2: Tienes un ejemplo idéntico en el mismo archivo.**  
  Revisa el **Paso 5** dentro de [`cookbooks/web_server/recipes/default.rb`](cookbooks/web_server/recipes/default.rb) (líneas 60–67), donde se despliega `index.html` a partir de `index.html.erb`. ¡La estructura que necesitas es prácticamente idéntica!
* **Pista 3: La estructura canónica del recurso `template`.**  
  En el DSL de Ruby de Chef, la sintaxis declarativa sigue este patrón:
  ```ruby
  template "#{node['web_server']['doc_root']}/nombre_del_archivo_destino.html" do
    source 'nombre_de_la_plantilla_origen.html.erb'
    owner 'root'
    group 'root'
    mode '0644'
    sensitive true # Opcional: evita que Chef imprima el diff completo en terminal
    action :create
  end
  ```
* **Pista 4: Aplicar el cambio en caliente.**  
  **NO** necesitas apagar ni destruir la máquina virtual (`vagrant destroy`). Como la máquina ya está encendida, solo debes ordenarle a Vagrant que vuelva a invocar a Chef ejecutando:
  ```bash
  vagrant provision
  ```

---

### 🔍 Criterios de Aceptación y Comprobación

1. **Convergencia Diferencial en Terminal:**  
   Al ejecutar `vagrant provision`, observa la línea final de Chef. No debe tardar más de 2 segundos y deberá reportar:  
   `Chef Infra Client finished, 1/X resources updated`  
   *(Esto demuestra que Chef no reinstaló Nginx ni reescribió la página de inicio; únicamente compiló e instaló la plantilla faltante).*
2. **Carga Exitosa y Sello Ohai en Navegador:**  
   Al visitar **`http://localhost:8080/easter_egg.html`**, la pantalla de error 404 desaparecerá y se revelará el monumento oculto del servidor, mostrando en la barra superior y en el pie de página el **Hostname y la IP real de tu VM inyectados por Ohai**.

---

### 📸 Evidencia del Reto para el Profesor
Para validar tu entrega completa del laboratorio, adjunta una tercera evidencia:
* **Evidencia 3 (Reto Completado):** Captura de pantalla de la página secreta en `http://localhost:8080/easter_egg.html` donde sea visible el **Sello Ohai** con los datos de tu VM, acompañada de la captura del bloque `template` que agregaste en `recipes/default.rb`.

---

## 🧹 10. Limpieza del Entorno

Cuando concluyas la práctica o la revisión del laboratorio, puedes apagar o destruir la máquina virtual para no consumir memoria ni espacio en tu disco:

* Para **apagarla temporalmente** (manteniendo el estado):
  ```bash
  vagrant halt
  ```
* Para **eliminarla por completo** (libera el 100% del espacio en disco de la VM):
  ```bash
  vagrant destroy -f
  ```
