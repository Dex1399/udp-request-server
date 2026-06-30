#!/bin/bash

# UDP Request Server - Installation Script
# GitHub: https://github.com/Dex1399/udp-request-server

REPO="https://raw.githubusercontent.com/Dex1399/udp-request-server/main"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "================================================"
echo "   UDP Request Server - Instalador"
echo "   github.com/Dex1399/udp-request-server"
echo "================================================"
echo -e "${NC}"

# Verificar root
if [ "$(whoami)" != "root" ]; then
    echo -e "${RED}[ERROR] Debes ejecutar como root${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] Actualizando lista de paquetes...${NC}"
apt update -y

echo -e "${YELLOW}[2/5] Instalando dependencias...${NC}"
apt install -y python3 curl wget
apt --fix-broken install -y

echo -e "${YELLOW}[3/5] Deshabilitando firewall...${NC}"
ufw disable 2>/dev/null || true

echo -e "${YELLOW}[4/5] Descargando archivos...${NC}"
mkdir -p /opt/udp-request
cd /opt/udp-request

wget -q "$REPO/udpServer" -O udpServer
wget -q "$REPO/start.sh" -O start.sh
wget -q "$REPO/useradd.sh" -O useradd.sh
wget -q "$REPO/udpru.py" -O udpru.py

chmod +x udpServer start.sh useradd.sh

echo -e "${YELLOW}[5/5] Creando servicio systemd...${NC}"

# Detectar IP de la interfaz principal
IP=$(ip addr show $(ip route | grep default | awk '{print $5}' | head -1) | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

cat > /etc/systemd/system/udp-request.service << SERVICE
[Unit]
Description=UDP Request Server
After=network.target

[Service]
ExecStart=/opt/udp-request/udpServer -ip=$IP -net=$IFACE -mode=system
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable udp-request
systemctl start udp-request

sleep 2

if systemctl is-active --quiet udp-request; then
    echo -e "${YELLOW}Configurando ruteo UDP...${NC}"
    python3 /opt/udp-request/udpru.py route $IFACE 8989
    
    PUBLIC_IP=$(curl -s ifconfig.me)
    echo -e "${GREEN}"
    echo "================================================"
    echo "   Instalacion completada!"
    echo "================================================"
    echo ""
    echo "Para agregar un usuario:"
    echo "  python3 /opt/udp-request/udpru.py manage add USUARIO PASSWORD FECHA"
    echo ""
    echo "Ejemplo:"
    echo "  python3 /opt/udp-request/udpru.py manage add miusuario MiPass2027! 2027-12-31"
    echo ""
    echo "Configurar SocksIP:"
    echo "  Host: $PUBLIC_IP"
    echo "  Puerto: 8989 (o cualquier otro puerto UDP)"
    echo "================================================"
    echo -e "${NC}"
else
    echo -e "${RED}[ERROR] El servicio no pudo iniciarse${NC}"
    journalctl -u udp-request -n 20
    exit 1
fi
