#!/bin/bash
cat <<EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Webapp Service
After=network.target

[Service]
Environment="NODE_ENV=${NODE_ENV}"
Environment="PORT=${PORT}"
Environment="DIALECT=${DIALECT}"
Environment="DB_HOST=${DB_HOST}"
Environment="DB_USERNAME=${DB_USERNAME}"
Environment="DB_PASSWORD=${DB_PASSWORD}"
Environment="DB_NAME=${DB_NAME}"
Environment="S3_BUCKET_NAME=${S3_BUCKET_NAME}"
Environment="AWS_REGION=${AWS_REGION}"

Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/webapp
ExecStart=/usr/bin/node server-listener.js
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/webapp.service
EOF

sudo systemctl daemon-reload
sudo systemctl start webapp.service
sudo systemctl enable webapp.service

echo 'export NODE_ENV=${NODE_ENV}' >> /home/ec2-user/.bashrc,
echo 'export PORT=3000' >> /home/ec2-user/.bashrc,
echo 'export PORT=${PORT}' >> /home/ec2-user/.bashrc,
echo 'export DB_HOST=${DB_HOST}' >> /home/ec2-user/.bashrc,
echo 'export DB_USERNAME=${DB_USERNAME}' >> /home/ec2-user/.bashrc,
echo 'export DB_PASSWORD=${DB_PASSWORD}' >> /home/ec2-user/.bashrc,
echo 'export DB_NAME=${DB_NAME}' >> /home/ec2-user/.bashrc,
echo 'export S3_BUCKET_NAME=${S3_BUCKET_NAME}' >> /home/ec2-user/.bashrc,
echo 'export AWS_REGION=${AWS_REGION}' >> /home/ec2-user/.bashrc,
source /home/ec2-user/.bashrc

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/tmp/config.json
