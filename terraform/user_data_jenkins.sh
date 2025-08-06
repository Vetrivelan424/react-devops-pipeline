#!/bin/bash
# User data script for Jenkins server
# This script installs Jenkins, Docker, and other required tools

# Update system packages
yum update -y

# Install Java 11 (required for Jenkins)
yum install -y java-11-amazon-corretto

# Add Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
yum install -y jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add jenkins user to docker group
usermod -a -G docker jenkins

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
yum install -y git

# Install Node.js and npm
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Terraform
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform

# Install AWS CLI
yum install -y awscli

# Install kubectl (for Kubernetes deployments if needed)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm (for Kubernetes package management if needed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Configure firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=8443/tcp
firewall-cmd --reload

# Create Jenkins configuration directory
mkdir -p /var/lib/jenkins/init.groovy.d

# Create initial Jenkins configuration script
cat > /var/lib/jenkins/init.groovy.d/basic-security.groovy << 'EOF'
#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Disable CLI over remoting
instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Enable Agent to master security subsystem
instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// Save configuration
instance.save()
EOF

# Create Jenkins plugins installation script
cat > /var/lib/jenkins/plugins.txt << 'EOF'
ant:latest
build-timeout:latest
credentials-binding:latest
timestamper:latest
ws-cleanup:latest
github:latest
github-branch-source:latest
pipeline-github-lib:latest
pipeline-stage-view:latest
git:latest
docker-workflow:latest
docker-plugin:latest
terraform:latest
aws-credentials:latest
pipeline-aws:latest
nodejs:latest
workflow-aggregator:latest
EOF

# Install Jenkins plugins
chown jenkins:jenkins /var/lib/jenkins/plugins.txt
chown jenkins:jenkins /var/lib/jenkins/init.groovy.d/basic-security.groovy

# Create plugin installation script
cat > /tmp/install-plugins.sh << 'EOF'
#!/bin/bash
JENKINS_HOME=/var/lib/jenkins
PLUGIN_DIR=$JENKINS_HOME/plugins

# Wait for Jenkins to start
while ! curl -s http://localhost:8080 > /dev/null; do
    echo "Waiting for Jenkins to start..."
    sleep 10
done

# Install plugins
while read plugin; do
    echo "Installing plugin: $plugin"
    curl -L -o $PLUGIN_DIR/${plugin%:*}.hpi "https://updates.jenkins.io/latest/${plugin%:*}.hpi"
done < /var/lib/jenkins/plugins.txt

# Restart Jenkins to load plugins
systemctl restart jenkins
EOF

chmod +x /tmp/install-plugins.sh

# Create systemd service to install plugins after Jenkins starts
cat > /etc/systemd/system/jenkins-plugin-installer.service << 'EOF'
[Unit]
Description=Jenkins Plugin Installer
After=jenkins.service
Requires=jenkins.service

[Service]
Type=oneshot
ExecStart=/tmp/install-plugins.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable jenkins-plugin-installer.service

# Create Jenkins job configuration directory
mkdir -p /var/lib/jenkins/jobs/react-app-pipeline/
chown -R jenkins:jenkins /var/lib/jenkins/jobs/

# Create sample pipeline job configuration
cat > /var/lib/jenkins/jobs/react-app-pipeline/config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>React Application CI/CD Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <com.cloudbees.jenkins.GitHubPushTrigger plugin="github@1.34.1">
          <spec></spec>
        </com.cloudbees.jenkins.GitHubPushTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.92">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.8.3">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/your-username/react-app.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

chown jenkins:jenkins /var/lib/jenkins/jobs/react-app-pipeline/config.xml

# Create SSH key for Jenkins to access application servers
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa*

# Set up log rotation for Jenkins
cat > /etc/logrotate.d/jenkins << 'EOF'
/var/log/jenkins/jenkins.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 jenkins jenkins
}
EOF

echo "Jenkins server setup completed" > /var/log/user-data.log

# Display initial admin password location
echo "Jenkins initial admin password can be found at: /var/lib/jenkins/secrets/initialAdminPassword" >> /var/log/user-data.log

