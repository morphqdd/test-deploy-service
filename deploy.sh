#!/bin/bash
set -e

SERVICE=test-deploy-service
BINARY=/usr/local/bin/$SERVICE
PORT=${PORT:-8080}

echo "==> building..."
go build -o $BINARY .

echo "==> installing systemd unit..."
cat > /etc/systemd/system/$SERVICE.service <<EOF
[Unit]
Description=Test Deploy Service
After=network.target

[Service]
ExecStart=$BINARY
Restart=always
RestartSec=3
Environment=PORT=$PORT
Environment=ECHO_TEXT=hello from syncswarm deploy
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $SERVICE
systemctl restart $SERVICE

echo "==> done. service status:"
systemctl is-active $SERVICE
