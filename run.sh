#!/bin/sh


# Define log files
OPENCONNECT_LOG="/var/log/openconnect.log"
TINYPROXY_LOG="/var/log/tinyproxy.log"

# Check if necessary environment variables are set
if [ -z "$VPN_SERVER" ] || [ -z "$VPN_USERNAME" ] || [ -z "$VPN_PASSWORD" ]; then
    echo "VPN_SERVER, VPN_USERNAME, VPN_PASSWORD environment variables must be set" >> "$OPENCONNECT_LOG" >&2 
    exit 1
fi

# Start OpenConnect and log output
echo "Starting OpenConnect..."
echo "$VPN_PASSWORD" | openconnect --user="$VPN_USERNAME" --passwd-on-stdin "$VPN_SERVER" >> "$OPENCONNECT_LOG" 2>&1 &
sleep 1
/usr/bin/tinyproxy >> "$TINYPROXY_LOG" >&2 &

# Monitor the OpenConnect log for a BYE packet and exit the container when detected
tail -f "$OPENCONNECT_LOG" | while IFS= read -r line; do
    echo "$line"
    if echo "$line" | grep -q "BYE"; then
        echo "BYE packet detected. Exiting container."
        # Optionally terminate background processes
        pkill openconnect
        pkill tinyproxy
        pkill tail
        exit 0
    fi
done