#!/bin/bash


set -e

ip=$(ip a |grep ens32 | sed "2s/^.*inet//;2s/brd.*$//p" -n)

# 创建textfile自定义指标目录
mkdir -p /var/lib/node_exporter/textfile_collector

# 写入测试指标
echo 'metadata{role="server",datacenter="CD"} 1' |tee /var/lib/node_exporter/textfile_collector/metadata.prom

tar -zxf node_exporter-1.5.0.linux-amd64.tar.gz
mv node_exporter-1.5.0.linux-amd64 /usr/local/node_exporter
touch /usr/lib/systemd/system/node_exporter.service
cat > /usr/lib/systemd/system/node_exporter.service << "EOF"
[Unit]
Description=node_exporter
[Service]
ExecStart=/usr/local/node_exporter/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector --collector.systemd --collector.systemd.unit-whitelist="(docker|ssh|rsyslog).service"
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