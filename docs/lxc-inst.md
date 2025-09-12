## Initial Setup
```bash
lxc init
```

## Getting Started with LXD
Assuming you have LXD installed, you can start using it to manage containers. Container name is `pristine` and the image is `ubuntu:noble`.
### Create a Container
```bash
lxc launch ubuntu:noble pristine -c security.nesting=true
```

### List Containers
```bash
lxc ls
```

### Stop a Container
```bash
lxc stop pristine
```

### Start a Container
```bash
lxc start pristine
```

### Delete a Container
```bash
lxc delete pristine
``` 

## Enter a Container
### Get a Shell in the Container
```bash
lxc exec pristine -- /bin/bash
```
### Create a New User in the Container with Sudo Access
Assuming you want to create a user named `srid` with sudo privileges:
```bash
lxc exec pristine -- adduser --shell /bin/bash --ingroup sudo srid
```
Ensure to set a password when prompted. This user will have sudo privileges.
### Directly Login as the New User
```bash
lxc exec pristine -- su - srid # -c 'tmux new-session -A -s main'
```
tmux is a terminal multiplexer that allows you to create and manage multiple terminal sessions from a single window.

## Attach Ethernet Interface
```bash
lxc network attach lxdbr0 pristine eth0 eth0
```
### List Network Interfaces
```bash
lxc network list
lxc network show lxdbr0
```
### Configure Network Interface
```bash
lxc network set lxdbr0 ipv4.address 10.0.0.1/24
lxc network set lxdbr0 ipv4.dhcp true
lxc network set lxdbr0 ipv4.nat true
```
### Bonus: Set static IP for the Host
```bash
lxc config device set pristine eth0 ipv4.address 10.0.0.2
```

## Configure static IP for the Container using Netplan
Inside the container, create a Netplan configuration file:
```bash
# Inside the container
cat > /etc/netplan/01-netcfg.yaml << 'EOF'
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.0.100/24
      routes:
        - to: default
          via: 10.0.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - local
EOF
```
### Apply the Netplan Configuration
```bash
# Inside the container
netplan apply
```

## Resize storage pool
https://documentation.ubuntu.com/lxd/latest/howto/storage_pools/
### View Storage Pools
```bash
lxc storage list
```
### Resize Storage Pool
```bash
lxc storage set <pool_name> size=<new_size>
# Example:
lxc storage set default size=50GB
```
### Usage Information
```bash
lxc storage info <pool_name>
lxc storage show <pool_name>
# Example:
lxc storage info default
lxc storage show default
```