# Description:

sequence of steps describing project - Jira Service Desk on GCP Platform (NGINX as reverse proxy)

## Requeriments:

```
- n1-standart-2 instance (CentOS 7) (Allow full access to all Cloud APIs for service account)

- db-n1-standart-1 Cloud SQL instance (MySQL 5.7) (Enable Cloud SQL API. Create service account and add permission to - Cloud SQL Admin)

- Cloud DNS Zone (create zone with A record - external ip of CentOS instance)

- Firewall rules that allow HTTP,HTTPS to VPC network

- VPC Network (optional)

- Register your domain name and add nameservers (my.freenom.com for example)

```
### Sequrnce of commands:
```
#Creating an instance of Cloud SQL for MySQL:
  gcloud sql instances create mysql-jira-instance --database-version MYSQL_5_6 --zone $ZONE 

#Set the password for the root@% MySQL user:
  gcloud sql users set-password root --host=% --instance=mysql-jira-instance --password=[PASSWORD]
  
#Create the Compute Engine instance:
  gcloud config set compute/zone $ZONE
  gcloud compute instances create jira-instance \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags=jira-server \
    --service-account $SA_EMAIL \
    --scopes cloud-platform
    
#Installing Jira Software:
  sudo yum update 
  sudo yum upgrade
  sudo yum -y install wget
  sudo yum -y install mysql
  wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-4.8.0-x64.bin #choose last release 
  chmod a+x atlassian-servicedesk-4.8.0-x64.bin #make executable 
  sudo ./atlassian-servicedesk-4.8.0-x64.bin 
  rm atlassian-servicedesk-4.8.0-x64.bin
  wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz #download connector at Jira instance
  tar -xzf mysql-connector-java-5.1.46.tar.gz
  sudo cp ./mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar /opt/atlassian/jira/lib/.
  rm -rf mysql-connector-java-5.1.46d mysql-connector-java-5.1.46.tar.gz
  wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy #download the Cloud SQL Proxy
  chmod +x cloud_sql_proxy #make executable
  sudo cp cloud_sql_proxy /usr/local/bin/. #Copy the proxy binary to a local directory
  
#Open sudo nano /usr/lib/systemd/system/cloud_sql_proxy.service and add the following configuration to the file:
  
  [Unit]
  Description=Google Cloud SQL Proxy
  After=network.service
  [Service]
  User=root
  Type=forking
  WorkingDirectory=/usr/local/bin
  ExecStart=/bin/sh -c '/usr/bin/nohup /usr/local/bin/cloud_sql_proxy -instances=[PROJECT_ID]:[REGION]:mysql-jira-instance=tcp:3306 &'
  RemainAfterExit=yes
  StandardOutput=journal
  KillMode=process
  [Install]
  WantedBy=multi-user.target
  
#Save and close the file.

#Create a new file called jira.service 
  sudo nano /usr/lib/systemd/system/jira.service
  
#Add the following configuration to the file

  [Unit]
  Description=JIRA Service
  Requires=cloud_sql_proxy.service
  After=network.target iptables.service firewalld.service httpd.service
  [Service]
  Type=forking
  User=root
  ExecStart=/opt/atlassian/jira/bin/start-jira.sh
  ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
  ExecReload=/opt/atlassian/jira/bin/stop-jira.sh | sleep 60 | /opt/atlassian/jira/bin/stop-jira.sh
  [Install]
  WantedBy=multi-user.target
 
#Save and close the file.

#Enable the Jira and Cloud SQL Proxy services
  sudo systemctl daemon-reload
  sudo systemctl enable jira
  sudo systemctl enable cloud_sql_proxy
  
#Start Jira service 
  sudo systemctl start jira
  
#Starting the MySQL session
  mysql -u root -p --host 127.0.0.1 -P 3306
    CREATE Database [DATABASE_NAME] CHARACTER SET utf8 COLLATE utf8_bin;
    CREATE USER '[USERNAME]'@'%' IDENTIFIED BY '[PASSWORD]';
    GRANT ALL PRIVILEGES ON [DATABASE_NAME] . * TO '[USERNAME]'@'%';
    FLUSH PRIVILEGES;
    EXIT;
    
#NGINX 
  sudo yum install epel-release mc net-tools
  sudo yum install yum-utils #installing pakets for yum-repository
  sudo nano /etc/yum.repos.d/nginx.repo 
  
#Add the following configuration to the file /etc/yum.repos.d/nginx.repo:

  [nginx-stable]
  name=nginx stable repo
  baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
  gpgcheck=1
  enabled=1
  gpgkey=https://nginx.org/keys/nginx_signing.key
  module_hotfixes=true

  [nginx-mainline]
  name=nginx mainline repo
  baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
  gpgcheck=1
  enabled=0
  gpgkey=https://nginx.org/keys/nginx_signing.key
  module_hotfixes=true

#Install NGINX 
  sudo yum install nginx
  sudo systemctl enable nginx
  sudo nano /etc/nginx/conf.d/default.conf #Configuration in file default.conf
  sudo setsebool -P httpd_can_network_connect 1 #Permit NGINX for accessing to port connect with connector 
  
#Install Certbot
  sudo yum -y install yum-utils
  sudo yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
  sudo yum install certbot python2-certbot-nginx
  sudo certbot certonly --nginx -d your_domain
  sudo systemctl restart nginx
  
  #Optional - auto renewal of the certificate
  sudo echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null
  
#Configure the Connector - /opt/atlassian/jira/conf/server.xml
    comment out "DEFAULT - Direct connector with no proxy" for this put before def connector "<!--", and at the end of the text "-->"
    uncoment "HTTP - Proxying Jira via Apache or Nginx over HTTP" add proxyName="example.com" and change proxyPort="443"/>
    you can copy "HTTP - Proxying Jira via Apache or Nginx over HTTP" and add port="8081" for troubleshooting
    
#After changes
  sudo systemctl stop jira
  sudo systemctl start jira

```
