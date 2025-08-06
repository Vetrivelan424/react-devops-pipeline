#!/bin/bash
# User data script for application servers
# This script installs Docker and sets up the environment for React app deployment

# Update system packages
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
yum install -y git

# Install Node.js and npm (for potential build processes)
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install AWS CLI
yum install -y awscli

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create application directory
mkdir -p /opt/react-app
chown ec2-user:ec2-user /opt/react-app

# Create systemd service for the React app
cat > /etc/systemd/system/react-app.service << EOF
[Unit]
Description=React Application
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker run -d --name react-app -p 80:80 --restart unless-stopped nginx:latest
ExecStop=/usr/bin/docker stop react-app
ExecStopPost=/usr/bin/docker rm react-app

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable react-app.service

# Configure log rotation for Docker
cat > /etc/logrotate.d/docker << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF

# Install and configure fail2ban for security
yum install -y epel-release
yum install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --reload

# Set up log forwarding to CloudWatch (optional)
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "${project_name}-${environment}-system-logs",
                        "log_stream_name": "{instance_id}-system"
                    },
                    {
                        "file_path": "/var/log/docker",
                        "log_group_name": "${project_name}-${environment}-docker-logs",
                        "log_stream_name": "{instance_id}-docker"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create deployment script
cat > /opt/react-app/deploy.sh << 'EOF'
#!/bin/bash
# Deployment script for React application

IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

echo "Deploying React application with image: $IMAGE_NAME"

# Stop and remove existing container
docker stop react-app 2>/dev/null || true
docker rm react-app 2>/dev/null || true

# Pull latest image
docker pull $IMAGE_NAME

# Run new container
docker run -d --name react-app -p 80:80 --restart unless-stopped $IMAGE_NAME

echo "Deployment completed successfully"
EOF

chmod +x /opt/react-app/deploy.sh
chown ec2-user:ec2-user /opt/react-app/deploy.sh

# Signal that the instance is ready
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AutoScalingGroup --region ${AWS::Region} 2>/dev/null || true

echo "Application server setup completed" > /var/log/user-data.log

