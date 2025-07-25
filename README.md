# Homelab Traefik Reverse Proxy

A Docker-based Traefik v3 reverse proxy setup for homelab environments with automatic HTTPS using self-hosted Step CA for certificate management. Uses a custom Docker image with internal CA trust.

## Project Overview

This project provides a complete Traefik reverse proxy solution for homelab environments featuring:

- **Automatic HTTPS**: All HTTP traffic redirected to HTTPS
- **Custom CA Integration**: Uses Step CA (`ca.mol.lan`) for certificate management
- **Custom Docker Image**: Built with internal CA certificate trust
- **File-based Configuration**: Dynamic routing rules via YAML files
- **Dashboard Access**: Traefik dashboard for monitoring and configuration
- **Hot Reload**: Configuration changes applied without restart

## Project Structure

```
homelab-traefik/
├── docker-compose.yml     # Traefik container configuration
├── Dockerfile             # Custom Traefik image with internal CA
├── traefik.yml            # Main Traefik configuration
├── acme.json              # ACME certificate storage (auto-generated)
├── dynamic/               # Dynamic routing configurations
│   ├── lb.yml
│   └── one.yml
├── root_ca.crt            # Step CA root certificate (excluded from git)
├── .gitignore             # Git ignore rules
├── LICENSE                # MIT License
└── README.md
```

## Prerequisites

- Docker and Docker Compose installed
- Step CA server running at `ca.mol.lan`
- Step CA root certificate (`root_ca.crt`) for Docker image build
- DNS resolution for `*.mol.lan` domains (including `lb.mol.lan`)
- SSL certificates mounted at `/etc/ssl/private`

## Deployment Instructions

### 1. Clone and Setup

```bash
git clone https://github.com/SumonMSelim/homelab-traefik.git
cd homelab-traefik
```

### 2. Configure ACME Storage

```bash
# Create acme.json with correct permissions
touch acme.json
chmod 600 acme.json
```

### 3. Configure Root CA Certificate

Copy your Step CA root certificate as `root_ca.crt` to the project root directory. This will be built into the custom Traefik image to trust your internal CA.

```bash
# Copy your Step CA root certificate
cp /path/to/your/step-ca/root_ca.crt ./root_ca.crt
```

Ensure your host has SSL certificates available at `/etc/ssl/private` or update the volume mount in `docker-compose.yml`.

### 4. Build and Deploy Traefik

```bash
# Build custom image and start Traefik
docker compose up -d --build

# View logs
docker compose logs -f traefik
```

### 5. Access Dashboard

Visit `https://lb.mol.lan` to access the authenticated Traefik dashboard.

## Adding New Services

Create a new YAML file in the `dynamic/` directory:

```yaml
# dynamic/myservice.yml
http:
  routers:
    myservice-router:
      rule: "Host(`myservice.mol.lan`)"
      entryPoints:
        - websecure
      service: myservice-service
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
# Check ACME logs
docker compose logs traefik | grep -i acme
```

**Routing Problems**
```bash
# Validate configuration
docker compose config
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

# Check dynamic config
docker compose exec traefik ls -la /dynamic/

# View ACME certificates
docker compose exec traefik cat /acme.json | jq
```

## Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Step CA Documentation](https://smallstep.com/docs/step-ca/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## Notes

- Default domain: `mol.lan`
- Certificate storage: `acme.json` (ensure proper permissions)
- Dynamic config directory: `./dynamic/`
- Traefik version: `latest` (automatically updated)

## Licensing

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**⚠️ Security Notice**: This configuration is intended for homelab use. Additional security measures should be implemented for production environments.