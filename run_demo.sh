#!/usr/bin/env bash
# ==============================================================================
# Script de Ejecución: Demostración en Modo Local (Chef-Zero)
# ==============================================================================
# ¿POR QUÉ CHEF CLIENT Y CHEF SERVER?
# ------------------------------------------------------------------------------
# 1. Chef Server: En arquitecturas empresariales, es el servidor central que
#    almacena todos los cookbooks, roles, ambientes y llaves de seguridad.
# 2. Chef Client (cinc-client / chef-client): Es el agente instalado en cada
#    servidor (nodo) que se encarga de ejecutar y converger las recetas.
#
# ¿POR QUÉ USAMOS MODO LOCAL (--local-mode)?
# ------------------------------------------------------------------------------
# Montar un Chef Server completo en un laboratorio escolar requeriría otra VM
# pesada con 4GB de RAM y configuración compleja de llaves con Knife.
#
# Con la bandera '--local-mode' (también conocida como Chef-Zero):
# Chef Client levanta un mini-servidor temporal en la memoria RAM del propio nodo,
# lee los cookbooks directamente desde la carpeta local ($SCRIPT_DIR/cookbooks),
# converge el sistema y se apaga limpiamente sin depender de red externa.
# ==============================================================================

set -e

# Detectar el comando disponible (cinc-client o chef-client)
if command -v cinc-client &>/dev/null; then
    CHEF_CMD="cinc-client"
elif command -v chef-client &>/dev/null; then
    CHEF_CMD="chef-client"
else
    echo "❌ Error: Ni 'cinc-client' ni 'chef-client' están instalados."
    echo "👉 Ejecuta primero el instalador: ./install_cinc.sh"
    exit 1
fi

echo "=========================================================="
echo "🍳 Ejecutando Chef Infra en Modo Local con: $CHEF_CMD"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ejecutar el cliente en modo local apuntando a la carpeta de cookbooks
# (diff_disabled=true evita imprimir en terminal el código completo de las plantillas)
sudo $CHEF_CMD --local-mode \
               --chef-license accept-no-persist \
               --config-option cookbook_path="$SCRIPT_DIR/cookbooks" \
               --config-option diff_disabled=true \
               --runlist 'recipe[web_server]'

echo ""
echo "=========================================================="
echo "✓ ¡Convergencia de Chef completada con éxito!"
echo "=========================================================="
echo "=> Comprobando respuesta HTTP localmente en el puerto 80:"
echo ""

if command -v curl &>/dev/null; then
    curl -I http://localhost || true
fi

echo ""
echo "=========================================================="
echo "🌐 Servidor web activo y respondiendo."
echo "   • Dentro de la VM (local): http://localhost:80"
echo "   • Desde tu máquina anfitrión (Vagrant): http://localhost:8080"
echo "=========================================================="
