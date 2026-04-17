#!/bin/bash
set -euxo pipefail

dnf update -y

# Make /tmp disk-backed instead of tmpfs
systemctl stop tmp.mount || true
systemctl disable tmp.mount || true
systemctl mask tmp.mount || true

sed -i '\|[[:space:]]/tmp[[:space:]]|d' /etc/fstab || true

umount /tmp || true
rm -rf /tmp
mkdir -p /tmp
chmod 1777 /tmp

dnf install -y java-21-amazon-corretto nginx git wget

wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key

dnf install -y jenkins

dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf install -y terraform

mkdir -p /etc/systemd/system/jenkins.service.d

cat >/etc/systemd/system/jenkins.service.d/override.conf <<'EOF'
[Service]
Environment="JENKINS_PORT=8080"
Environment="JENKINS_LISTEN_ADDRESS=127.0.0.1"
Environment="JAVA_OPTS=-Xms256m -Xmx512m"
EOF

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

cat >/etc/nginx/conf.d/jenkins.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_buffering off;
        proxy_request_buffering off;
    }
}
EOF

rm -f /etc/nginx/conf.d/default.conf || true

systemctl enable nginx
systemctl restart nginx

terraform version
df -h /tmp
mount | grep ' /tmp ' || true
