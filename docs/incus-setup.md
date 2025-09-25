# ssh
```bash
incus exec pristine -- apt-get update
incus exec pristine -- apt-get install -y openssh-server
incus exec pristine -- /bin/bash -c "echo 'root:toor' | chpasswd"
incus exec pristine -- sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
incus exec pristine -- systemctl restart ssh
```