sed -Ei "s/^ListenPort.+/ListenPort = \${WG_PORT}/g" /app/lib/WireGuard.js && /usr/bin/dumb-init node server.js
