# Homelab Traefik Reverse Proxy

A Docker-based Traefik v3 reverse proxy setup for homelab environments with automatic HTTPS using self-hosted Step CA for certificate management. Uses a custom Docker image with internal CA trust.

## Project Overview

This project provides a complete Traefik reverse proxy solution for homelab environments featuring:

- **Automatic HTTPS**: All HTTP traffic redirected to HTTPS with centralized redirect middleware
- **Custom CA Integration**: Uses Step CA (`ca.mol.lan`) for certificate management
- **Custom Docker Image**: Built with internal CA certificate trust
- **Centralized Security**: Reusable security header middlewares for internal and public services
- **Dashboard Authentication**: Protected Traefik dashboard with Basic Auth
- **File-based Configuration**: Modular dynamic routing rules via YAML files
- **Structured Logging**: File-based logging for better monitoring
- **Hot Reload**: Configuration changes applied without restart

## Project Structure

```
homelab-traefik/
├── docker-compose.yml     # Traefik container configuration
├── Dockerfile             # Custom Traefik image with internal CA
├── traefik.yml            # Main Traefik configuration with centralized redirects
├── logs/                  # Traefik log directory (excluded from git)
├── acme-LetsEncrypt.json  # ACME public certificate storage (auto-generated)
├── acme-StepCA.json       # ACME local certificate storage (auto-generated)
├── dynamic/               # Modular dynamic routing configurations
│   ├── security.yml       # Centralized security headers middleware
│   ├── proxy.yml
│   └── one.yml
|   └── ...
├── root_ca.crt            # Step CA root certificate (excluded from git)
├── .gitignore             # Git ignore rules
├── LICENSE                # MIT License
└── README.md
```

## Prerequisites

- Docker and Docker Compose installed
- Step CA server running at `ca.mol.lan`
- Step CA root certificate (`root_ca.crt`) for Docker image build
- DNS resolution for `*.mol.lan` domains (including `proxy.mol.lan`)

## Deployment Instructions

### 1. Clone and Setup

```bash
git clone https://github.com/SumonMSelim/homelab-traefik.git
cd homelab-traefik
```

### 2. Configure ACME Storage and Logs

```bash
# Create acme files with correct permissions
touch acme-LetsEncrypt.json
chmod 600 acme-LetsEncrypt.json

touch acme-StepCA.json
chmod 600 acme-StepCA.json

# Create logs directory
mkdir -p logs
```

### 3. Configure Root CA Certificate

Copy your Step CA root certificate as `root_ca.crt` to the project root directory. This will be built into the custom Traefik image to trust your internal CA.

```bash
# Copy your Step CA root certificate
cp /path/to/your/step-ca/root_ca.crt ./root_ca.crt
```

### 4. Build and Deploy Traefik

```bash
# Build custom image and start Traefik
docker compose up -d --build

# View logs
tail -f logs/traefik
```

### 5. Access Dashboard

Visit `https://proxy.mol.lan` to access the authenticated Traefik dashboard.

## Configuration Structure

### Centralized Security Headers
The project uses centralized security middleware defined in `dynamic/security.yml`:
- **`security-headers-internal`**: For internal homelab services
- **`security-headers-public`**: For public-facing services (includes HSTS)

## Adding New Services

Create a new YAML file in the `dynamic/` directory, utilizing the centralized security middleware:

```yaml
# dynamic/myservice.yml
http:
  routers:
    myservice-router:
      rule: "Host(`myservice.mol.lan`)"
      entryPoints:
        - websecure
      service: myservice-service
      middlewares:
        - security-headers-internal  # Use centralized security headers
      tls:
        certResolver: stepCA

  services:
    myservice-service:
      loadBalancer:
        servers:
          - url: "http://192.168.178.100:8080"
```

Changes are automatically detected and applied thanks to `watch: true`.

## Troubleshooting

### Common Issues

**Certificate Issues**
```bash
# Check ACME logs in container logs
docker compose logs traefik | grep -i acme

# Check ACME logs in log file
grep -i acme logs/traefik.log
```

**Routing Problems**
```bash
# Validate configuration
docker compose config

# Check routing logs
grep -i router logs/traefik.log
```

**DNS Resolution**
```bash
# Test domain resolution
nslookup one.mol.lan
```

## Useful Commands

```bash
# Restart Traefik
docker compose restart traefik

# View configuration
docker compose exec traefik cat /traefik.yml

# Check dynamic config files
docker compose exec traefik ls -la /dynamic/

# View logs (file-based logging)
docker compose logs traefik
tail -f logs/traefik.log


# Test security headers
curl -I https://proxy.mol.lan
```

## Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Step CA Documentation](https://smallstep.com/docs/step-ca/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## Notes

- Default domain: `mol.lan`
- Log directory: `logs/` (file-based logging enabled, supports rotation)
- Dynamic config directory: `./dynamic/` (modular configuration files)
- Security middleware: Centralized in `security.yml` for reusability
- Traefik version: `latest` (automatically updated)

## Licensing

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**⚠️ Security Notice**: This configuration is intended for homelab use. Additional security measures should be implemented for production environments.