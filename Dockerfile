FROM traefik:latest

# Copy the internal root CA cert into the container
COPY root_ca.crt /usr/local/share/ca-certificates/root_ca.crt

# Update system CA trust store to include your cert
RUN update-ca-certificates
