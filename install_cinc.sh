#!/usr/bin/env bash
# ==============================================================================
# Script de Instalación Rápida: Cinc Client (Chef Infra 100% Open Source)
# ==============================================================================
# Este script descarga e instala el cliente oficial de Chef/Cinc en cualquier
# distribución basada en Debian/Ubuntu (Codespaces, Cloud Shell, WSL, VM o VPS).
# ==============================================================================

set -e

echo "=========================================================="
echo "🍳 Instalando Cinc Infra Client (Chef Open Source)..."
echo "=========================================================="

if command -v cinc-client &>/dev/null; then
    echo "✓ Cinc Client ya está instalado en el sistema:"
    cinc-client --version
    exit 0
fi

if command -v chef-client &>/dev/null; then
    echo "✓ Chef Client ya está instalado en el sistema:"
    chef-client --version
    exit 0
fi

# Asegurar que curl esté instalado (Debian 12 minimal no incluye curl por defecto)
if ! command -v curl &>/dev/null; then
    echo "=> 'curl' no encontrado en el sistema base. Instalando curl y certificados..."
    sudo apt-get update -y
    sudo apt-get install -y curl ca-certificates
fi

# Descarga e instalación oficial y segura desde omnitruck
echo "=> Descargando e instalando Cinc Client vía omnitruck..."
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash

echo ""
echo "=========================================================="
echo "✓ Instalación completada exitosamente:"
cinc-client --version
echo "=========================================================="
echo "Ahora puedes ejecutar tu receta con: ./run_demo.sh"
