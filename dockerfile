# Use the official Alpine base image
FROM alpine:edge

# Copy the script to run OpenConnect and SSH
COPY run.sh /run.sh
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY sockd.conf /etc/sockd.conf
# Update package list
RUN apk update

# Install OpenSSH, OpenSSL, and OpenConnect
RUN apk add --no-cache openssh openssl openconnect tinyproxy ca-certificates dante-server

RUN mkdir /var/run/tinyproxy
RUN mkdir /var/run/sockd

# Make the script executable
RUN chmod +x /run.sh

# Set the entrypoint to the script
ENTRYPOINT ["/bin/sh", "/run.sh"]
