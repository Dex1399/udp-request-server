# UDP Request Server

Servidor UDP tunnel para usar con la app **SocksIP** en Android. Permite navegar libremente saltando restricciones de red mediante un protocolo UDP propietario sin firma reconocible por DPI.

## Requisitos

- Ubuntu 20.04 o superior
- Acceso root
- VPS con IP pública

## Instalación

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Dex1399/udp-request-server/main/install.sh)
```

## Gestión de usuarios

**Agregar usuario:**
```bash
python3 /opt/udp-request/udpru.py manage add USUARIO PASSWORD FECHA
```

Ejemplo:
```bash
python3 /opt/udp-request/udpru.py manage add christian MiPass2027! 2027-12-31
```

**Eliminar usuario:**
```bash
python3 /opt/udp-request/udpru.py manage del USUARIO
```

## Configurar SocksIP

| Campo      | Valor                  |
|------------|------------------------|
| Host       | IP de tu VPS           |
| Puerto     | 8989 (o cualquier otro)|
| Usuario    | El que creaste         |
| Contraseña | La que configuraste    |

## Gestión del servicio

```bash
# Ver estado
systemctl status udp-request

# Reiniciar
systemctl restart udp-request

# Ver logs
journalctl -u udp-request -f
```
