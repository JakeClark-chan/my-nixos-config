# ssh
```bash
incus exec pristine -- apt-get update
incus exec pristine -- apt-get install -y openssh-server
incus exec pristine -- /bin/bash -c "echo 'root:toor' | chpasswd"
incus exec pristine -- sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
incus exec pristine -- systemctl restart ssh
```

# Alpine Linux MySQL Setup

## Remove MariaDB (if installed)
```bash
# Stop MariaDB service
incus exec pristine -- rc-service mariadb stop

# Remove MariaDB from startup
incus exec pristine -- rc-update del mariadb

# Remove MariaDB packages
incus exec pristine -- apk del mariadb mariadb-client mariadb-server-utils mariadb-common

# Clean up MariaDB data directory (CAUTION: This removes all data)
incus exec pristine -- rm -rf /var/lib/mysql
```

## Install MySQL (Native Alpine)
```bash
# Update package index
incus exec pristine -- apk update

# Install MySQL community server
incus exec pristine -- apk add mysql mysql-client

# Initialize MySQL data directory
incus exec pristine -- mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Add MySQL to startup
incus exec pristine -- rc-update add mysql

# Start MySQL service
incus exec pristine -- rc-service mysql start

# Secure MySQL installation (interactive - run manually)
# incus exec pristine -- mysql_secure_installation

# Set root password (replace 'newpassword' with your desired password)
incus exec pristine -- mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';"
```

## Docker Alternative (if native MySQL fails)
```bash
# Install Docker
incus exec pristine -- apk add docker docker-compose

# Add Docker to startup
incus exec pristine -- rc-update add docker

# Start Docker service
incus exec pristine -- rc-service docker start

# Create MySQL container with persistent data
incus exec pristine -- docker run -d \
  --name mysql-server \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppassword \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# Check container status
incus exec pristine -- docker ps

# Connect to MySQL (for testing)
incus exec pristine -- docker exec -it mysql-server mysql -u root -p
```

## Verification Commands
```bash
# For native MySQL
incus exec pristine -- mysql --version
incus exec pristine -- rc-status | grep mysql

# For Docker MySQL
incus exec pristine -- docker ps | grep mysql
incus exec pristine -- docker exec mysql-server mysql --version
```