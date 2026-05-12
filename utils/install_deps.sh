#!/bin/env bash

# Este script instala las dependencias utilizadas para debian like linuxes

# Actualización del sistema
#####################################

# Actualizamos los repositorios
sudo apt update
#Primero actualizamos el sistema
sudo apt upgrade

# Instalar Docker y Docker compose
#####################################

# Primero desinstalamos lo que tengamos.
sudo apt remove docker docker-engine docker.io containerd runc

# Instalo los pre-requisitos
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Agrego las GPG key para el repositorio de instalacion de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Instalo el repositorio
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalo docker en si
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin git git-lfs

# Instalo los drivers de vulkan para tener los dos gpus.

# Instalar drivers Vulkan y utilidades
sudo apt install libvulkan1 libvulkan-dev mesa-vulkan-drivers vulkan-tools

# Instalar utilidades adicionales para desarrollo
sudo apt install glslc spirv-headers
