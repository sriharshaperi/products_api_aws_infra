data "aws_ami" "latest_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["webapp-ami-*"]
  }
}

resource "aws_instance" "ec2-webapp-dev" {
  # count                       = 1
  ami                         = data.aws_ami.latest_ami.id
  key_name                    = var.aws_keypair_dev
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.application.id]
  ebs_optimized               = false
  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }
  disable_api_termination = false
  tags = {
    Name = var.ec2_tag_name
  }
  iam_instance_profile = aws_iam_instance_profile.s3_access_instance_profile.name

  ebs_block_device {
    device_name           = "/dev/xvda"
    encrypted             = true
    kms_key_id            = aws_kms_key.encryption_key_ebs.arn
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  #Sending User Data to EC2
  #   user_data = <<EOT
  # #!/bin/bash
  # cat <<EOF > /etc/systemd/system/webapp.service
  # [Unit]
  # Description=Webapp Service
  # After=network.target

  # [Service]
  # Environment="NODE_ENV=dev"
  # Environment="PORT=3000"
  # Environment="DIALECT=mysql"
  # Environment="DB_HOST=${element(split(":", aws_db_instance.rds_instance.endpoint), 0)}"
  # Environment="DB_USERNAME=${aws_db_instance.rds_instance.username}"
  # Environment="DB_PASSWORD=${aws_db_instance.rds_instance.password}"
  # Environment="DB_NAME=${aws_db_instance.rds_instance.db_name}"
  # Environment="S3_BUCKET_NAME=${aws_s3_bucket.webapp-s3.bucket}"
  # Environment="AWS_REGION=${var.aws_region}"

  # Type=simple
  # User=ec2-user
  # WorkingDirectory=/home/ec2-user/webapp
  # ExecStart=/usr/bin/node server-listener.js
  # Restart=on-failure

  # [Install]
  # WantedBy=multi-user.target" > /etc/systemd/system/webapp.service
  # EOF

  # sudo systemctl daemon-reload
  # sudo systemctl start webapp.service
  # sudo systemctl enable webapp.service

  # echo 'export NODE_ENV=dev' >> /home/ec2-user/.bashrc,
  # echo 'export PORT=3000' >> /home/ec2-user/.bashrc,
  # echo 'export DIALECT=mysql' >> /home/ec2-user/.bashrc,
  # echo 'export DB_HOST=${element(split(":", aws_db_instance.rds_instance.endpoint), 0)}' >> /home/ec2-user/.bashrc,
  # echo 'export DB_USERNAME=${aws_db_instance.rds_instance.username}' >> /home/ec2-user/.bashrc,
  # echo 'export DB_PASSWORD=${aws_db_instance.rds_instance.password}' >> /home/ec2-user/.bashrc,
  # echo 'export DB_NAME=${aws_db_instance.rds_instance.db_name}' >> /home/ec2-user/.bashrc,
  # echo 'export S3_BUCKET_NAME=${aws_s3_bucket.webapp-s3.bucket}' >> /home/ec2-user/.bashrc,
  # echo 'export AWS_REGION=${var.aws_region}' >> /home/ec2-user/.bashrc,
  # source /home/ec2-user/.bashrc

  # sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/tmp/config.json

  # EOT

  user_data = local.user_data
}
