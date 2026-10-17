# ==============================================================================
# Receta Principal de Chef: web_server::default
# ==============================================================================
# Esta receta demuestra los 4 recursos fundamentales de la gestión de
# configuración en Chef:
#   1. apt_update : Asegura que la lista de paquetes esté fresca.
#   2. package    : Instala el software requerido (Nginx).
#   3. directory  : Garantiza que la ruta destino exista con permisos correctos.
#   4. template   : Renderiza un archivo dinámico con variables del sistema.
#   5. service    : Administra el ciclo de vida del servicio (habilitar y arrancar).
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Actualización de Repositorios (Solo si es plataforma basada en Debian/Ubuntu)
# ------------------------------------------------------------------------------
apt_update 'actualizar_repositorios' do
  frequency 86_400 # 1 día de vigencia en caché
  action :periodic
end

# ------------------------------------------------------------------------------
# 2. Recurso 'package': Instalar el servidor web Nginx
# ------------------------------------------------------------------------------
# Chef verifica si el paquete ya está instalado en el sistema operativo.
# Si ya existe, NO hace nada (Principio de Idempotencia).
# ------------------------------------------------------------------------------
package node['web_server']['package_name'] do
  action :install
end

# ------------------------------------------------------------------------------
# 3. Recurso 'directory': Crear el directorio raíz para la aplicación web
# ------------------------------------------------------------------------------
directory node['web_server']['doc_root'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# ------------------------------------------------------------------------------
# 4. Recurso 'service': Declarar el servicio Nginx
# ------------------------------------------------------------------------------
# Definimos el servicio antes de la plantilla para que podamos enviarle
# notificaciones cuando los archivos de configuración cambien.
# ------------------------------------------------------------------------------
service node['web_server']['service_name'] do
  supports status: true, restart: true, reload: true
  action [:enable, :start] # Se habilita para iniciar con el SO y se arranca
end

# ------------------------------------------------------------------------------
# 5. Recurso 'template': Desplegar la página de inicio desde index.html.erb
# ------------------------------------------------------------------------------
# Chef compila la plantilla sustituyendo los valores de Ohai y los atributos.
# Si el archivo en disco ya es idéntico al resultado compilado, Chef NO lo toca.
# Si el archivo cambió, lo sobreescribe y le envía un 'notifies' al servicio.
# ------------------------------------------------------------------------------
template "#{node['web_server']['doc_root']}/index.html" do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :reload, "service[#{node['web_server']['service_name']}]", :delayed
end

# ------------------------------------------------------------------------------
# 6. Recursos 'cookbook_file' y 'remote_directory': Recursos estáticos y fuentes
# ------------------------------------------------------------------------------
# Copia las imágenes y la familia tipográfica local (Ranade) desde files/default/
# hacia el directorio raíz del servidor web.
# ------------------------------------------------------------------------------
%w(roman-1.jpg roman-2.jpg roman-art.jpg editorial-art.png).each do |asset|
  cookbook_file "#{node['web_server']['doc_root']}/#{asset}" do
    source asset
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

remote_directory "#{node['web_server']['doc_root']}/Fonts" do
  source 'Fonts'
  owner 'root'
  group 'root'
  mode '0755'
  files_owner 'root'
  files_group 'root'
  files_mode '0644'
  action :create
end

# ------------------------------------------------------------------------------
# 7. ZONA DEL RETO FINAL: El Monumento Oculto
# ------------------------------------------------------------------------------
# Agrega aquí abajo el recurso 'template' para compilar y desplegar la plantilla
# 'easter_egg.html.erb' en "#{node['web_server']['doc_root']}/easter_egg.html".
# (Guíate del paso 5 de arriba donde se despliega index.html.erb).
# Puedes usar 'sensitive true' para evitar spoilers en la terminal.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Mensaje informativo en el log de Chef al finalizar la convergencia
# ------------------------------------------------------------------------------
log 'mensaje_exito' do
  message "=> [Chef] El servidor web ha convergido exitosamente en el puerto #{node['web_server']['port']}."
  level :info
end
