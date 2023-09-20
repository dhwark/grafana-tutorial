#!/bin/bash


set -e

ip=$(ip a |grep ens32 | sed "2s/^.*inet//;2s/brd.*$//p" -n)

tar -zxf node_exporter-1.5.0.linux-amd64.tar.gz
mv node_exporter-1.5.0.linux-amd64 /usr/local/node_exporter
touch /usr/lib/systemd/system/node_exporter.service
cat > /usr/lib/systemd/system/node_exporter.service << "EOF"
[Unit]
Description=node_exporter
[Service]
ExecStart=/usr/local/node_exporter/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "now node_exporter is running on ${ip}:9100"