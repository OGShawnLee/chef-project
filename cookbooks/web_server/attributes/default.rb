# ==============================================================================
# Atributos por defecto del Cookbook: web_server
# ==============================================================================
# Los atributos en Chef permiten desacoplar la configuración dura del código.
# Gracias a esto, podemos cambiar el puerto, mensajes o rutas sin tener que
# modificar la receta principal (recipes/default.rb).
# ==============================================================================

# Paquete y servicio del servidor web
default['web_server']['package_name'] = 'nginx'
default['web_server']['service_name'] = 'nginx'

# Directorio raíz donde Nginx sirve los archivos estáticos
default['web_server']['doc_root']     = '/var/www/html'

# Puerto de escucha del servidor web
default['web_server']['port']         = 80

# Metadatos personalizables para la página web (Renderizados en index.html.erb)
default['web_server']['site_title']   = 'Servidor Web Automatizado con Chef Infra'
default['web_server']['author']       = 'Equipo UV - Despliegue de Software'
default['web_server']['message']      = '¡Infraestructura desplegada exitosamente mediante Código (IaC) e Idempotencia!'
default['web_server']['environment']  = 'Demostración de Laboratorio'
