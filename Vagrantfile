# -*- mode: ruby -*-
# vi: set ft=ruby :
# ==============================================================================
# Vagrantfile: Despliegue de Chef Infra en Máquina Virtual Debian 12 Bookworm
# ==============================================================================
# Para compañeros que tengan VirtualBox y Vagrant instalados.
# Uso:
#   vagrant up       -> Enciende la máquina virtual y ejecuta Chef automáticamente.
#   vagrant ssh      -> Entra por SSH a la máquina virtual.
#   vagrant destroy  -> Destruye la máquina virtual cuando termines.
# ==============================================================================

Vagrant.configure("2") do |config|
  # Imagen base oficial de Debian 12 (Bookworm) 64-bit
  config.vm.box = "debian/bookworm64"

  # Desactivar la comprobación y auto-instalación de Guest Additions
  # (Evita el fallo con linux-headers)
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # Reenvío de puertos: El puerto 80 del servidor se accede en http://localhost:8080
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

  # Configuración de hardware virtual
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
    vb.name = "chef-infra-demo-uv"
  end

  # Aprovisionamiento con Chef Infra
  config.vm.provision "shell", inline: <<-SHELL
    set -e
    echo "=========================================================="
    echo "🍳 Iniciando aprovisionamiento con Chef en la VM..."
    echo "=========================================================="
    cd /vagrant
    sed -i 's/\r$//' install_cinc.sh run_demo.sh
    chmod +x install_cinc.sh run_demo.sh
    ./install_cinc.sh
    ./run_demo.sh
    echo "=========================================================="
    echo "✓ VM lista. Accede desde tu navegador en: http://localhost:8080"
    echo "=========================================================="
  SHELL
end
