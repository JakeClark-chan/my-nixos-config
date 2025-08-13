#!/usr/bin/env python3
"""
Standalone LXC GUI Application Demo
This script runs without virtual environment dependencies
"""

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog, scrolledtext
import subprocess
import json
import threading
import time
import os
from pathlib import Path
from typing import List, Optional
import re
import threading
import time
from typing import List, Dict, Optional


class LXCManager:
    """Manages LXC container operations"""
    
    def __init__(self):
        self.default_image = "ubuntu:noble"
    
    def run_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a command and return the result"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False
            )
            return result
        except Exception as e:
            raise Exception(f"Failed to run command {' '.join(command)}: {str(e)}")
    
    def list_containers(self) -> List[Dict]:
        """List all LXC containers"""
        try:
            result = self.run_command(['lxc', 'list', '--format', 'json'])
            if result.returncode == 0:
                containers = json.loads(result.stdout)
                return containers
            else:
                raise Exception(f"Failed to list containers: {result.stderr}")
        except json.JSONDecodeError:
            raise Exception("Failed to parse container list")
    
    def create_container(self, name: str, image: str = None, enable_nesting: bool = True) -> bool:
        """Create a new LXC container"""
        if not name or not re.match(r'^[a-zA-Z0-9][a-zA-Z0-9-]*$', name):
            raise Exception("Invalid container name. Use alphanumeric characters and hyphens only.")
        
        if image is None:
            image = self.default_image
        
        command = ['lxc', 'launch', image, name]
        if enable_nesting:
            command.extend(['-c', 'security.nesting=true'])
        
        result = self.run_command(command)
        if result.returncode == 0:
            return True
        else:
            raise Exception(f"Failed to create container: {result.stderr}")
    
    def start_container(self, name: str) -> bool:
        """Start a container"""
        result = self.run_command(['lxc', 'start', name])
        if result.returncode == 0:
            return True
        else:
            raise Exception(f"Failed to start container: {result.stderr}")
    
    def stop_container(self, name: str) -> bool:
        """Stop a container"""
        result = self.run_command(['lxc', 'stop', name])
        if result.returncode == 0:
            return True
        else:
            raise Exception(f"Failed to stop container: {result.stderr}")
    
    def delete_container(self, name: str, force: bool = False) -> bool:
        """Delete a container"""
        command = ['lxc', 'delete', name]
        if force:
            command.append('--force')
        
        result = self.run_command(command)
        if result.returncode == 0:
            return True
        else:
            raise Exception(f"Failed to delete container: {result.stderr}")
    
    def get_container_info(self, name: str) -> Optional[str]:
        """Get detailed information about a specific container"""
        try:
            result = self.run_command(['lxc', 'info', name])
            if result.returncode == 0:
                return result.stdout
            else:
                return None
        except Exception:
            return None
    
    def exec_command(self, container_name: str, command: str) -> str:
        """Execute a command inside a container"""
        cmd = ['lxc', 'exec', container_name, '--'] + command.split()
        result = self.run_command(cmd)
        if result.returncode == 0:
            return result.stdout
        else:
            raise Exception(f"Failed to execute command: {result.stderr}")
    
    def container_exists(self, name: str) -> bool:
        """Check if a container exists"""
        containers = self.list_containers()
        return any(container['name'] == name for container in containers)
    
    def get_container_status(self, name: str) -> Optional[str]:
        """Get the status of a container"""
        containers = self.list_containers()
        for container in containers:
            if container['name'] == name:
                return container['status']
        return None
    
    def is_container_running(self, name: str) -> bool:
        """Check if a container is running"""
        status = self.get_container_status(name)
        return status == "Running" if status else False
    
    def create_user_in_container(self, container_name: str, username: str, password: str, sudo_access: bool = True) -> bool:
        """Create a user in the container with optional sudo access"""
        try:
            # Create user non-interactively
            cmd = ['lxc', 'exec', container_name, '--', 'useradd', '-m', '-s', '/bin/bash']
            if sudo_access:
                cmd.extend(['-G', 'sudo'])
            cmd.append(username)
            
            result = self.run_command(cmd)
            if result.returncode != 0:
                return False
            
            # Set password
            passwd_cmd = ['lxc', 'exec', container_name, '--', 'bash', '-c', 
                        f'echo "{username}:{password}" | chpasswd']
            result = self.run_command(passwd_cmd)
            return result.returncode == 0
        except Exception:
            return False
    
    def list_users_in_container(self, container_name: str) -> List[str]:
        """List users in the container"""
        try:
            result = self.run_command(['lxc', 'exec', container_name, '--', 'cut', '-d:', '-f1', '/etc/passwd'])
            if result.returncode == 0:
                users = [user.strip() for user in result.stdout.split('\n') if user.strip()]
                # Filter out system users (UID < 1000)
                human_users = []
                for user in users:
                    uid_result = self.run_command(['lxc', 'exec', container_name, '--', 'id', '-u', user])
                    if uid_result.returncode == 0:
                        try:
                            uid = int(uid_result.stdout.strip())
                            if uid >= 1000 or user == 'root':
                                human_users.append(user)
                        except ValueError:
                            continue
                return human_users
            return []
        except Exception:
            return []
    
    def list_users(self, container_name: str) -> List[str]:
        """Alias for list_users_in_container for compatibility"""
        return self.list_users_in_container(container_name)
    
    def attach_network_interface(self, container_name: str, network_name: str = "lxdbr0", 
                                device_name: str = "eth0") -> bool:
        """Attach network interface to container"""
        try:
            result = self.run_command(['lxc', 'network', 'attach', network_name, container_name, device_name])
            return result.returncode == 0
        except Exception:
            return False
    
    def configure_static_ip(self, container_name: str, ip_address: str, gateway: str = "10.0.0.1",
                          dns_servers: List[str] = None, device_name: str = "eth0") -> bool:
        """Configure static IP in container using netplan"""
        if dns_servers is None:
            dns_servers = ["8.8.8.8", "8.8.4.4"]
        
        netplan_config = f"""network:
  version: 2
  ethernets:
    {device_name}:
      addresses:
        - {ip_address}
      routes:
        - to: default
          via: {gateway}
      nameservers:
        addresses:
          - {dns_servers[0]}
          - {dns_servers[1]}
        search:
          - local
"""
        
        try:
            # Create netplan config file
            create_config_cmd = ['lxc', 'exec', container_name, '--', 'bash', '-c',
                               f'cat > /etc/netplan/01-netcfg.yaml << \'EOF\'\n{netplan_config}EOF']
            result = self.run_command(create_config_cmd)
            if result.returncode != 0:
                return False
            
            # Apply netplan configuration
            apply_cmd = ['lxc', 'exec', container_name, '--', 'netplan', 'apply']
            result = self.run_command(apply_cmd)
            return result.returncode == 0
        except Exception:
            return False
    
    def configure_dhcp(self, container_name: str, device_name: str = "eth0") -> bool:
        """Configure DHCP in container using netplan"""
        netplan_config = f"""network:
  version: 2
  ethernets:
    {device_name}:
      dhcp4: true
      dhcp6: false
"""
        
        try:
            # Create netplan config file
            create_config_cmd = ['lxc', 'exec', container_name, '--', 'bash', '-c',
                               f'cat > /etc/netplan/01-netcfg.yaml << \'EOF\'\n{netplan_config}EOF']
            result = self.run_command(create_config_cmd)
            if result.returncode != 0:
                return False
            
            # Apply netplan configuration
            apply_cmd = ['lxc', 'exec', container_name, '--', 'netplan', 'apply']
            result = self.run_command(apply_cmd)
            return result.returncode == 0
        except Exception:
            return False
    
    def list_networks(self) -> List[Dict]:
        """List available LXC networks"""
        try:
            result = self.run_command(['lxc', 'network', 'list', '--format', 'json'])
            if result.returncode == 0:
                return json.loads(result.stdout)
            return []
        except (json.JSONDecodeError, Exception):
            return []
    
    def get_network_info(self, network_name: str) -> Optional[str]:
        """Get detailed information about a network"""
        try:
            result = self.run_command(['lxc', 'network', 'show', network_name])
            if result.returncode == 0:
                return result.stdout
            return None
        except Exception:
            return None
    
    def get_default_terminal(self) -> str:
        """Detect the default terminal emulator"""
        # List of common terminal emulators to try
        terminals = [
            'deepin-terminal',
            'gnome-terminal',
            'konsole',
            'xfce4-terminal',
            'lxterminal',
            'mate-terminal',
            'terminator',
            'alacritty',
            'kitty',
            'urxvt',
            'rxvt',
            'xterm'
        ]
        
        # Check TERMINAL environment variable first
        if 'TERMINAL' in os.environ:
            terminal = os.environ['TERMINAL']
            if self._command_exists(terminal):
                return terminal
        
        # Try each terminal in order
        for terminal in terminals:
            if self._command_exists(terminal):
                return terminal
        
        return 'xterm'  # Fallback
    
    def _command_exists(self, command: str) -> bool:
        """Check if a command exists in PATH"""
        try:
            result = subprocess.run(['which', command], capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def open_external_terminal(self, container_name: str, username: str = "root", shell: str = "/bin/bash") -> bool:
        """Open external terminal with LXC exec"""
        try:
            terminal = self.get_default_terminal()
            
            # Build the LXC exec command
            if username == "root":
                lxc_cmd = f"lxc exec {container_name} -- {shell}"
            else:
                lxc_cmd = f"lxc exec {container_name} -- su - {username}"
            
            # Terminal-specific command formats
            terminal_commands = {
                'deepin-terminal': [terminal, '-e', lxc_cmd],
                'gnome-terminal': [terminal, '--', 'bash', '-c', lxc_cmd],
                'konsole': [terminal, '-e', 'bash', '-c', lxc_cmd],
                'xfce4-terminal': [terminal, '-e', lxc_cmd],
                'lxterminal': [terminal, '-e', lxc_cmd],
                'mate-terminal': [terminal, '-e', lxc_cmd],
                'terminator': [terminal, '-x', lxc_cmd],
                'alacritty': [terminal, '-e', 'bash', '-c', lxc_cmd],
                'kitty': [terminal, 'bash', '-c', lxc_cmd],
                'urxvt': [terminal, '-e', 'bash', '-c', lxc_cmd],
                'rxvt': [terminal, '-e', 'bash', '-c', lxc_cmd],
                'xterm': [terminal, '-e', lxc_cmd]
            }
            
            # Get the base terminal name (without path)
            terminal_name = os.path.basename(terminal)
            
            if terminal_name in terminal_commands:
                cmd = terminal_commands[terminal_name]
            else:
                # Fallback: try with -e flag
                cmd = [terminal, '-e', lxc_cmd]
            
            # Start the terminal in background
            subprocess.Popen(cmd, start_new_session=True)
            return True
            
        except Exception as e:
            raise Exception(f"Failed to open terminal: {str(e)}")
    
    def get_available_shells(self, container_name: str) -> List[str]:
        """Get available shells in the container"""
        try:
            result = self.run_command(['lxc', 'exec', container_name, '--', 'cat', '/etc/shells'])
            if result.returncode == 0:
                shells = []
                for line in result.stdout.split('\n'):
                    line = line.strip()
                    if line and not line.startswith('#') and line.startswith('/'):
                        shells.append(line)
                return shells
            return ['/bin/bash', '/bin/sh']
        except Exception:
            return ['/bin/bash', '/bin/sh']
    
    def setup_application_mirroring(self, container_name: str) -> bool:
        """Setup application mirroring for a container"""
        try:
            import os
            import threading
            import time
            from pathlib import Path
            
            # Check if container is running
            if not self.is_container_running(container_name):
                raise Exception(f"Container '{container_name}' is not running")
            
            # Create host applications directory if it doesn't exist
            host_apps_dir = Path.home() / ".local" / "share" / "applications"
            host_apps_dir.mkdir(parents=True, exist_ok=True)
            
            # Create container-specific directory for tracking
            container_apps_dir = host_apps_dir / f"lxc-{container_name}"
            container_apps_dir.mkdir(exist_ok=True)
            
            # Install inotify-tools in container if not present
            self._ensure_inotify_tools(container_name)
            
            # Start monitoring thread
            monitor_thread = threading.Thread(
                target=self._monitor_container_applications,
                args=(container_name,),
                daemon=True
            )
            monitor_thread.start()
            
            # Perform initial sync
            self._sync_container_applications(container_name)
            
            return True
            
        except Exception as e:
            raise Exception(f"Failed to setup application mirroring: {str(e)}")
    
    def _ensure_inotify_tools(self, container_name: str):
        """Ensure inotify-tools is installed in the container"""
        try:
            # Check if inotifywait is available
            result = self.run_command(['lxc', 'exec', container_name, '--', 'which', 'inotifywait'])
            
            if result.returncode != 0:
                # Install inotify-tools
                self.run_command(['lxc', 'exec', container_name, '--', 'apt', 'update'])
                self.run_command(['lxc', 'exec', container_name, '--', 'apt', 'install', '-y', 'inotify-tools'])
                
        except Exception as e:
            # If we can't install inotify-tools, we'll fall back to periodic checking
            pass
    
    def _monitor_container_applications(self, container_name: str):
        """Monitor container applications in a background thread"""
        import time
        import subprocess
        
        # Application directories to monitor
        app_dirs = [
            '/usr/share/applications',
            '/usr/local/share/applications'
        ]
        
        # Try to get user home directories and monitor their applications too
        try:
            result = self.run_command(['lxc', 'exec', container_name, '--', 'find', '/home', '-name', 'applications', '-type', 'd'])
            if result.returncode == 0:
                for line in result.stdout.strip().split('\n'):
                    if line.strip():
                        app_dirs.append(line.strip())
        except:
            pass
        
        while True:
            try:
                # Check if container is still running
                if not self.is_container_running(container_name):
                    break
                
                # Use inotifywait if available, otherwise periodic check
                try:
                    # Build inotifywait command
                    cmd = ['lxc', 'exec', container_name, '--', 'inotifywait', '-m', '-r', '-e', 'create,delete,moved_to,moved_from']
                    cmd.extend(app_dirs)
                    
                    # Start inotifywait process
                    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                    
                    while True:
                        line = process.stdout.readline()
                        if not line:
                            break
                        
                        # Parse inotifywait output: directory, event, filename
                        parts = line.strip().split(' ', 2)
                        if len(parts) >= 3 and parts[2].endswith('.desktop'):
                            self._sync_container_applications(container_name)
                            time.sleep(1)  # Debounce rapid changes
                        
                        # Check if container is still running
                        if not self.is_container_running(container_name):
                            process.terminate()
                            break
                    
                except Exception:
                    # Fallback to periodic checking
                    time.sleep(30)  # Check every 30 seconds
                    self._sync_container_applications(container_name)
                
            except Exception:
                time.sleep(30)  # Wait before retrying
    
    def _sync_container_applications(self, container_name: str):
        """Sync applications from container to host"""
        try:
            import os
            from pathlib import Path
            import configparser
            
            # Application directories to check
            app_dirs = [
                '/usr/share/applications',
                '/usr/local/share/applications'
            ]
            
            # Add user-specific directories
            try:
                result = self.run_command(['lxc', 'exec', container_name, '--', 'find', '/home', '-name', 'applications', '-type', 'd'])
                if result.returncode == 0:
                    for line in result.stdout.strip().split('\n'):
                        if line.strip():
                            app_dirs.append(line.strip())
            except:
                pass
            
            # Host directories
            host_apps_dir = Path.home() / ".local" / "share" / "applications"
            container_apps_dir = host_apps_dir / f"lxc-{container_name}"
            
            # Get list of desktop files in container
            container_apps = set()
            for app_dir in app_dirs:
                try:
                    result = self.run_command(['lxc', 'exec', container_name, '--', 'find', app_dir, '-name', '*.desktop', '-type', 'f'])
                    if result.returncode == 0:
                        for line in result.stdout.strip().split('\n'):
                            if line.strip():
                                container_apps.add(line.strip())
                except:
                    continue
            
            # Get existing mirrored apps
            existing_apps = set()
            if container_apps_dir.exists():
                for app_file in container_apps_dir.glob('*.desktop'):
                    existing_apps.add(app_file.name)
            
            # Process each application
            for app_path in container_apps:
                app_name = os.path.basename(app_path)
                host_app_path = container_apps_dir / app_name
                
                # Copy and modify desktop file
                self._mirror_desktop_file(container_name, app_path, host_app_path)
            
            # Remove applications that no longer exist in container
            container_app_names = {os.path.basename(app) for app in container_apps}
            for existing_app in existing_apps:
                if existing_app not in container_app_names:
                    (container_apps_dir / existing_app).unlink(missing_ok=True)
            
            # Create symlinks in main applications directory
            for app_file in container_apps_dir.glob('*.desktop'):
                symlink_path = host_apps_dir / f"lxc-{container_name}-{app_file.name}"
                if symlink_path.exists() or symlink_path.is_symlink():
                    symlink_path.unlink()
                symlink_path.symlink_to(app_file)
                
        except Exception as e:
            # Silently fail to avoid interrupting other operations
            pass
    
    def _mirror_desktop_file(self, container_name: str, source_path: str, dest_path: Path):
        """Mirror a desktop file from container to host with modifications"""
        try:
            import configparser
            import os
            
            # Read the desktop file from container
            result = self.run_command(['lxc', 'exec', container_name, '--', 'cat', source_path])
            if result.returncode != 0:
                return
            
            content = result.stdout
            
            # Parse desktop file
            config = configparser.ConfigParser()
            config.read_string(content)
            
            if 'Desktop Entry' not in config:
                return
            
            entry = config['Desktop Entry']
            
            # Modify the application name
            original_name = entry.get('Name', os.path.splitext(os.path.basename(source_path))[0])
            entry['Name'] = f"{original_name} (from {container_name})"
            
            # Modify the command to run through LXC
            if 'Exec' in entry:
                original_exec = entry['Exec']
                # Remove field codes (%f, %F, %u, %U, etc.)
                import re
                clean_exec = re.sub(r'%[a-zA-Z]', '', original_exec).strip()
                entry['Exec'] = f"lxc exec {container_name} -- {clean_exec}"
            
            # Add comment about container origin
            entry['Comment'] = f"Application from LXC container '{container_name}'"
            
            # Ensure directory exists
            dest_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write modified desktop file
            with open(dest_path, 'w') as f:
                config.write(f, space_around_delimiters=False)
            
            # Make executable
            dest_path.chmod(0o755)
            
        except Exception:
            # Silently fail
            pass
    
    def stop_application_mirroring(self, container_name: str) -> bool:
        """Stop application mirroring for a container and clean up"""
        try:
            import os
            from pathlib import Path
            
            # Host directories
            host_apps_dir = Path.home() / ".local" / "share" / "applications"
            container_apps_dir = host_apps_dir / f"lxc-{container_name}"
            
            # Remove symlinks from main applications directory
            for symlink in host_apps_dir.glob(f"lxc-{container_name}-*.desktop"):
                symlink.unlink(missing_ok=True)
            
            # Remove container-specific directory
            if container_apps_dir.exists():
                import shutil
                shutil.rmtree(container_apps_dir)
            
            return True
            
        except Exception as e:
            raise Exception(f"Failed to stop application mirroring: {str(e)}")
    
    def list_mirrored_applications(self, container_name: str) -> List[Dict[str, str]]:
        """List applications currently mirrored from a container"""
        try:
            from pathlib import Path
            import configparser
            
            host_apps_dir = Path.home() / ".local" / "share" / "applications"
            container_apps_dir = host_apps_dir / f"lxc-{container_name}"
            
            applications = []
            
            if not container_apps_dir.exists():
                return applications
            
            for app_file in container_apps_dir.glob('*.desktop'):
                try:
                    config = configparser.ConfigParser()
                    config.read(app_file)
                    
                    if 'Desktop Entry' in config:
                        entry = config['Desktop Entry']
                        app_info = {
                            'file': app_file.name,
                            'name': entry.get('Name', app_file.stem),
                            'comment': entry.get('Comment', ''),
                            'exec': entry.get('Exec', ''),
                            'icon': entry.get('Icon', ''),
                            'categories': entry.get('Categories', '')
                        }
                        applications.append(app_info)
                        
                except Exception:
                    continue
            
            return applications
            
        except Exception:
            return []
    
    def is_application_mirroring_active(self, container_name: str) -> bool:
        """Check if application mirroring is active for a container"""
        try:
            from pathlib import Path
            
            host_apps_dir = Path.home() / ".local" / "share" / "applications"
            container_apps_dir = host_apps_dir / f"lxc-{container_name}"
            
            return container_apps_dir.exists() and any(container_apps_dir.glob('*.desktop'))
            
        except Exception:
            return False
    
    # Disk Management Methods
    
    def get_storage_info(self, container_name: str) -> Dict:
        """Get storage information for a container"""
        try:
            info = {}
            
            # Get container's storage pool
            pool_name = self.get_container_storage_pool(container_name)
            info['storage_pool'] = pool_name
            
            # Get storage pool information
            pool_info = self.get_storage_pool_info(pool_name)
            if pool_info:
                info['pool_driver'] = pool_info.get('driver', 'unknown')
                if 'config' in pool_info and 'size' in pool_info['config']:
                    info['pool_size'] = pool_info['config']['size']
                if 'config' in pool_info and 'source' in pool_info['config']:
                    info['pool_source'] = pool_info['config']['source']
            
            # Get disk usage inside container
            result = self.run_command(['lxc', 'exec', container_name, '--', 'df', '-h', '/'])
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    fields = lines[1].split()
                    info['container_size'] = fields[1] if len(fields) > 1 else 'Unknown'
                    info['container_used'] = fields[2] if len(fields) > 2 else 'Unknown'
                    info['container_available'] = fields[3] if len(fields) > 3 else 'Unknown'
                    info['container_use_percent'] = fields[4] if len(fields) > 4 else 'Unknown'
            
            # Get host storage info for root
            result = self.run_command(['df', '-h', '/'])
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    fields = lines[1].split()
                    info['host_root_size'] = fields[1] if len(fields) > 1 else 'Unknown'
                    info['host_root_used'] = fields[2] if len(fields) > 2 else 'Unknown'
                    info['host_root_available'] = fields[3] if len(fields) > 3 else 'Unknown'
                    info['host_root_use_percent'] = fields[4] if len(fields) > 4 else 'Unknown'
            
            # Get host storage info for home
            result = self.run_command(['df', '-h', str(Path.home())])
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    fields = lines[1].split()
                    info['host_home_size'] = fields[1] if len(fields) > 1 else 'Unknown'
                    info['host_home_used'] = fields[2] if len(fields) > 2 else 'Unknown'
                    info['host_home_available'] = fields[3] if len(fields) > 3 else 'Unknown'
                    info['host_home_use_percent'] = fields[4] if len(fields) > 4 else 'Unknown'
            
            return info
            
        except Exception as e:
            return {'error': str(e)}
    
    def get_storage_pools(self) -> List[Dict]:
        """Get list of storage pools"""
        try:
            result = self.run_command(['lxc', 'storage', 'list', '--format=json'])
            if result.returncode == 0:
                import json
                return json.loads(result.stdout)
            return []
        except Exception:
            return []
    
    def get_storage_pool_info(self, pool_name: str) -> Dict:
        """Get storage pool information"""
        try:
            result = self.run_command(['lxc', 'storage', 'show', pool_name])
            if result.returncode == 0:
                # Parse the output manually since we don't want to add yaml dependency
                info = {}
                lines = result.stdout.split('\n')
                current_section = None
                
                for line in lines:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    
                    if line.endswith(':') and not line.startswith(' '):
                        current_section = line[:-1]
                        if current_section not in info:
                            info[current_section] = {}
                    elif ':' in line and current_section:
                        key, value = line.split(':', 1)
                        key = key.strip()
                        value = value.strip()
                        if current_section == 'config':
                            if 'config' not in info:
                                info['config'] = {}
                            info['config'][key] = value
                        else:
                            info[key] = value
                    elif current_section and line.startswith('  '):
                        # Handle list items
                        if current_section not in info:
                            info[current_section] = []
                        info[current_section].append(line.strip('- '))
                
                return info
            return {}
        except Exception:
            return {}
    
    def get_container_storage_pool(self, container_name: str) -> str:
        """Get the storage pool name for a container"""
        try:
            # Get container config
            result = self.run_command(['lxc', 'config', 'show', container_name])
            if result.returncode == 0:
                # Parse manually to find storage pool
                lines = result.stdout.split('\n')
                in_devices = False
                in_root = False
                
                for line in lines:
                    line = line.strip()
                    if line == 'devices:':
                        in_devices = True
                        continue
                    elif in_devices and line == 'root:':
                        in_root = True
                        continue
                    elif in_root and line.startswith('pool:'):
                        pool = line.split(':', 1)[1].strip()
                        return pool
                    elif not line.startswith(' ') and in_devices:
                        in_devices = False
                        in_root = False
                
                # Fall back to default pool
                return 'default'
            
            return 'default'
            
        except Exception:
            return 'default'
    
    def resize_storage_pool(self, pool_name: str, new_size: str) -> bool:
        """Resize storage pool (e.g., '10GB', '20GB')"""
        try:
            # Set the new size for the storage pool
            result = self.run_command([
                'lxc', 'storage', 'set', pool_name, f'size={new_size}'
            ])
            
            return result.returncode == 0
            
        except Exception:
            return False
    
    def setup_home_symlink_storage(self, container_name: str, symlink_name: str = None) -> bool:
        """Setup symlink to home folder for additional storage"""
        try:
            if symlink_name is None:
                symlink_name = f"host_home_{container_name}"
            
            home_path = str(Path.home())
            container_mount_point = f"/mnt/{symlink_name}"
            
            # Create mount point in container
            result = self.run_command([
                'lxc', 'exec', container_name, '--', 
                'mkdir', '-p', container_mount_point
            ])
            if result.returncode != 0:
                return False
            
            # Add disk device for home folder
            result = self.run_command([
                'lxc', 'config', 'device', 'add', container_name,
                symlink_name, 'disk',
                f'source={home_path}',
                f'path={container_mount_point}'
            ])
            
            if result.returncode != 0:
                return False
            
            # Create symbolic link in container for easy access
            result = self.run_command([
                'lxc', 'exec', container_name, '--',
                'ln', '-sf', container_mount_point, f'/home/host_home'
            ])
            
            return result.returncode == 0
            
        except Exception:
            return False
    
    def remove_home_symlink_storage(self, container_name: str, symlink_name: str = None) -> bool:
        """Remove home folder symlink storage"""
        try:
            if symlink_name is None:
                symlink_name = f"host_home_{container_name}"
            
            # Remove symbolic link
            self.run_command([
                'lxc', 'exec', container_name, '--',
                'rm', '-f', '/home/host_home'
            ])
            
            # Remove device
            result = self.run_command([
                'lxc', 'config', 'device', 'remove', container_name, symlink_name
            ])
            
            return result.returncode == 0
            
        except Exception:
            return False
    
    def is_home_symlink_active(self, container_name: str, symlink_name: str = None) -> bool:
        """Check if home symlink storage is active"""
        try:
            if symlink_name is None:
                symlink_name = f"host_home_{container_name}"
            
            # Check if device exists
            result = self.run_command(['lxc', 'config', 'show', container_name])
            if result.returncode != 0:
                return False
            
            # Look for the device in config
            return symlink_name in result.stdout
            
        except Exception:
            return False
    
    def get_available_disk_space_gb(self, path: str = "/") -> float:
        """Get available disk space in GB for a given path"""
        try:
            result = self.run_command(['df', '-B1', path])
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    fields = lines[1].split()
                    if len(fields) >= 4:
                        available_bytes = int(fields[3])
                        return round(available_bytes / (1024**3), 2)  # Convert to GB
            return 0.0
        except:
            return 0.0


class LXCGui:
    """Main GUI application for LXC management"""
    
    def __init__(self):
        self.lxc_manager = LXCManager()
        self.root = tk.Tk()
        self.setup_ui()
        self.refresh_containers()
    
    def setup_ui(self):
        """Setup the user interface"""
        self.root.title("LXC Container Manager")
        self.root.geometry("900x700")
        
        # Create main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(1, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="LXC Container Manager", 
                               font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # Buttons frame
        buttons_frame = ttk.Frame(main_frame)
        buttons_frame.grid(row=1, column=0, sticky=(tk.W, tk.N), padx=(0, 10))
        
        # CRUD Buttons
        ttk.Button(buttons_frame, text="📦 Create Container", 
                  command=self.create_container_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="▶️ Start Container", 
                  command=self.start_container, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="⏹️ Stop Container", 
                  command=self.stop_container, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="🗑️ Delete Container", 
                  command=self.delete_container, width=20).pack(fill=tk.X, pady=2)
        
        ttk.Separator(buttons_frame, orient='horizontal').pack(fill=tk.X, pady=10)
        
        # Additional operations
        ttk.Button(buttons_frame, text="ℹ️ Container Info", 
                  command=self.show_container_info, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="💻 Execute Command", 
                  command=self.exec_command_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="🖥️ Open Terminal", 
                  command=self.open_terminal_dialog, width=20).pack(fill=tk.X, pady=2)
        
        ttk.Separator(buttons_frame, orient='horizontal').pack(fill=tk.X, pady=10)
        
        # Advanced operations
        ttk.Button(buttons_frame, text="👥 Manage Users", 
                  command=self.manage_users_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="🌐 Network Config", 
                  command=self.network_config_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="📡 Network Interfaces", 
                  command=self.show_network_interfaces, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="📱 App Mirroring", 
                  command=self.application_mirroring_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="💾 Disk Management", 
                  command=self.disk_management_dialog, width=20).pack(fill=tk.X, pady=2)
        ttk.Button(buttons_frame, text="🗄️ Storage Pools", 
                  command=self.storage_pool_dialog, width=20).pack(fill=tk.X, pady=2)
        
        ttk.Separator(buttons_frame, orient='horizontal').pack(fill=tk.X, pady=10)
        
        # Test operations
        ttk.Button(buttons_frame, text="🧪 Run Demo Test", 
                  command=self.run_demo_test, width=20).pack(fill=tk.X, pady=2)
        
        ttk.Separator(buttons_frame, orient='horizontal').pack(fill=tk.X, pady=10)
        
        # Refresh button
        ttk.Button(buttons_frame, text="🔄 Refresh List", 
                  command=self.refresh_containers, width=20).pack(fill=tk.X, pady=2)
        
        # Container list frame
        list_frame = ttk.Frame(main_frame)
        list_frame.grid(row=1, column=1, sticky=(tk.W, tk.E, tk.N, tk.S))
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)
        
        # Treeview for container list
        self.tree = ttk.Treeview(list_frame, columns=('Status', 'Image', 'IP'), show='tree headings')
        self.tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure columns
        self.tree.heading('#0', text='Container Name')
        self.tree.heading('Status', text='Status')
        self.tree.heading('Image', text='Image')
        self.tree.heading('IP', text='IP Address')
        
        self.tree.column('#0', width=200)
        self.tree.column('Status', width=100)
        self.tree.column('Image', width=200)
        self.tree.column('IP', width=150)
        
        # Scrollbar for treeview
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.tree.yview)
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.tree.configure(yscrollcommand=scrollbar.set)
        
        # Status bar
        self.status_var = tk.StringVar()
        self.status_var.set("Ready - LXC GUI Manager")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, 
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))
    
    def refresh_containers(self):
        """Refresh the container list"""
        try:
            self.status_var.set("Refreshing container list...")
            self.root.update()
            
            # Clear existing items
            for item in self.tree.get_children():
                self.tree.delete(item)
            
            # Get containers
            containers = self.lxc_manager.list_containers()
            
            for container in containers:
                name = container.get('name', 'Unknown')
                status = container.get('status', 'Unknown')
                
                # Get image info
                config = container.get('config', {})
                image = config.get('image.description', config.get('image.alias', 'Unknown'))
                
                # Get IP address
                state = container.get('state', {})
                network = state.get('network', {}) if state else {}
                ip_address = 'N/A'
                
                if network and 'eth0' in network:
                    addresses = network['eth0'].get('addresses', [])
                    if addresses:
                        for addr in addresses:
                            if addr and addr.get('family') == 'inet':
                                ip_address = addr.get('address', 'N/A')
                                break
                
                # Color code status
                tags = []
                if status == "Running":
                    tags = ["running"]
                elif status == "Stopped":
                    tags = ["stopped"]
                
                self.tree.insert('', tk.END, text=name, 
                               values=(status, image, ip_address), tags=tags)
            
            # Configure tags for visual feedback
            self.tree.tag_configure("running", background="#e8f5e8")
            self.tree.tag_configure("stopped", background="#f5e8e8")
            
            self.status_var.set(f"Found {len(containers)} containers")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to refresh containers: {str(e)}")
            self.status_var.set("Error refreshing containers")
    
    def get_selected_container(self):
        """Get the currently selected container name"""
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Please select a container first")
            return None
        
        item = self.tree.item(selection[0])
        return item['text']
    
    def create_container_dialog(self):
        """Show dialog to create a new container"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Create New Container")
        dialog.geometry("450x350")
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Center the dialog
        dialog.geometry("+%d+%d" % (self.root.winfo_rootx() + 50, 
                                   self.root.winfo_rooty() + 50))
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # Container name
        ttk.Label(frame, text="Container Name:", font=("Arial", 10, "bold")).pack(anchor=tk.W)
        name_var = tk.StringVar()
        name_entry = ttk.Entry(frame, textvariable=name_var, width=40, font=("Arial", 10))
        name_entry.pack(fill=tk.X, pady=(5, 15))
        
        # Image
        ttk.Label(frame, text="Image:", font=("Arial", 10, "bold")).pack(anchor=tk.W)
        image_var = tk.StringVar(value="ubuntu:noble")
        image_entry = ttk.Entry(frame, textvariable=image_var, width=40, font=("Arial", 10))
        image_entry.pack(fill=tk.X, pady=(5, 15))
        
        # Security nesting
        nesting_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(frame, text="Enable security nesting (recommended)", 
                       variable=nesting_var).pack(anchor=tk.W, pady=(0, 20))
        
        # Info label
        info_label = ttk.Label(frame, text="Note: Container creation may take a few moments", 
                              foreground="gray", font=("Arial", 9))
        info_label.pack(anchor=tk.W, pady=(0, 20))
        
        # Buttons
        button_frame = ttk.Frame(frame)
        button_frame.pack(fill=tk.X)
        
        def create_container():
            name = name_var.get().strip()
            image = image_var.get().strip()
            
            if not name:
                messagebox.showerror("Error", "Container name is required")
                return
            
            if self.lxc_manager.container_exists(name):
                messagebox.showerror("Error", f"Container '{name}' already exists")
                return
            
            try:
                self.status_var.set(f"Creating container '{name}'...")
                dialog.destroy()
                self.root.update()
                
                self.lxc_manager.create_container(name, image, nesting_var.get())
                messagebox.showinfo("Success", f"Container '{name}' created successfully!")
                self.refresh_containers()
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to create container: {str(e)}")
                self.status_var.set("Ready")
        
        ttk.Button(button_frame, text="Create", command=create_container).pack(side=tk.RIGHT, padx=(5, 0))
        ttk.Button(button_frame, text="Cancel", command=dialog.destroy).pack(side=tk.RIGHT)
        
        name_entry.focus()
    
    def start_container(self):
        """Start the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        try:
            self.status_var.set(f"Starting container '{container_name}'...")
            self.root.update()
            
            self.lxc_manager.start_container(container_name)
            messagebox.showinfo("Success", f"Container '{container_name}' started successfully!")
            self.refresh_containers()
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start container: {str(e)}")
            self.status_var.set("Ready")
    
    def stop_container(self):
        """Stop the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        try:
            self.status_var.set(f"Stopping container '{container_name}'...")
            self.root.update()
            
            self.lxc_manager.stop_container(container_name)
            messagebox.showinfo("Success", f"Container '{container_name}' stopped successfully!")
            self.refresh_containers()
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to stop container: {str(e)}")
            self.status_var.set("Ready")
    
    def delete_container(self):
        """Delete the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        # Confirm deletion
        if not messagebox.askyesno("Confirm Deletion", 
                                  f"Are you sure you want to delete container '{container_name}'?\n\n"
                                  f"This action cannot be undone."):
            return
        
        try:
            self.status_var.set(f"Deleting container '{container_name}'...")
            self.root.update()
            
            # Check if container is running and stop it first
            status = self.lxc_manager.get_container_status(container_name)
            if status == "Running":
                self.lxc_manager.stop_container(container_name)
                time.sleep(1)  # Wait for stop to complete
            
            self.lxc_manager.delete_container(container_name, force=True)
            messagebox.showinfo("Success", f"Container '{container_name}' deleted successfully!")
            self.refresh_containers()
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to delete container: {str(e)}")
            self.status_var.set("Ready")
    
    def show_container_info(self):
        """Show detailed information about the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        try:
            info = self.lxc_manager.get_container_info(container_name)
            if not info:
                messagebox.showerror("Error", f"Could not get information for container '{container_name}'")
                return
            
            # Create info window
            info_window = tk.Toplevel(self.root)
            info_window.title(f"Container Info - {container_name}")
            info_window.geometry("700x500")
            info_window.transient(self.root)
            
            frame = ttk.Frame(info_window, padding="10")
            frame.pack(fill=tk.BOTH, expand=True)
            
            # Text widget with scrollbar
            text_frame = ttk.Frame(frame)
            text_frame.pack(fill=tk.BOTH, expand=True)
            
            text_widget = tk.Text(text_frame, wrap=tk.WORD, font=("Courier", 10))
            scrollbar = ttk.Scrollbar(text_frame, orient=tk.VERTICAL, command=text_widget.yview)
            text_widget.configure(yscrollcommand=scrollbar.set)
            
            text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
            scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
            
            # Display the plain text info
            text_widget.insert(tk.END, info)
            text_widget.config(state=tk.DISABLED)
            
            ttk.Button(frame, text="Close", command=info_window.destroy).pack(pady=(10, 0))
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to get container info: {str(e)}")
    
    def exec_command_dialog(self):
        """Show dialog to execute a command in the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        # Check if container is running
        status = self.lxc_manager.get_container_status(container_name)
        if status != "Running":
            messagebox.showwarning("Warning", f"Container '{container_name}' is not running")
            return
        
        command = simpledialog.askstring("Execute Command", 
                                       f"Enter command to execute in '{container_name}':",
                                       initialvalue="ls -la")
        if command:
            try:
                self.status_var.set(f"Executing command in '{container_name}'...")
                self.root.update()
                
                output = self.lxc_manager.exec_command(container_name, command)
                
                # Show output in a new window
                output_window = tk.Toplevel(self.root)
                output_window.title(f"Command Output - {container_name}")
                output_window.geometry("700x500")
                output_window.transient(self.root)
                
                frame = ttk.Frame(output_window, padding="10")
                frame.pack(fill=tk.BOTH, expand=True)
                
                ttk.Label(frame, text=f"Command: {command}", font=("Arial", 10, "bold")).pack(anchor=tk.W, pady=(0, 10))
                
                text_frame = ttk.Frame(frame)
                text_frame.pack(fill=tk.BOTH, expand=True)
                
                text_widget = tk.Text(text_frame, wrap=tk.WORD, font=("Courier", 10))
                scrollbar = ttk.Scrollbar(text_frame, orient=tk.VERTICAL, command=text_widget.yview)
                text_widget.configure(yscrollcommand=scrollbar.set)
                
                text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
                scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
                
                text_widget.insert(tk.END, output)
                text_widget.config(state=tk.DISABLED)
                
                ttk.Button(frame, text="Close", command=output_window.destroy).pack(pady=(10, 0))
                
                self.status_var.set("Ready")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to execute command: {str(e)}")
                self.status_var.set("Ready")
    
    def run_demo_test(self):
        """Run a demo test to show CRUD operations"""
        test_name = f"gui-demo-{int(time.time())}"
        
        def run_test():
            try:
                self.status_var.set("Running demo test...")
                self.root.update()
                
                # Create container
                messagebox.showinfo("Demo Test", f"Creating test container '{test_name}'...")
                self.lxc_manager.create_container(test_name, "ubuntu:noble", True)
                self.refresh_containers()
                
                # Execute command
                messagebox.showinfo("Demo Test", f"Executing command in '{test_name}'...")
                output = self.lxc_manager.exec_command(test_name, "echo 'Hello from GUI demo!'")
                
                # Show results
                messagebox.showinfo("Demo Test Results", 
                                  f"Container '{test_name}' created and tested successfully!\n\n"
                                  f"Command output: {output.strip()}\n\n"
                                  f"The container will now be deleted.")
                
                # Clean up
                self.lxc_manager.stop_container(test_name)
                self.lxc_manager.delete_container(test_name, force=True)
                self.refresh_containers()
                
                self.status_var.set("Demo test completed successfully!")
                messagebox.showinfo("Demo Complete", "Demo test completed successfully!")
                
            except Exception as e:
                messagebox.showerror("Demo Error", f"Demo test failed: {str(e)}")
                # Cleanup on error
                try:
                    if self.lxc_manager.container_exists(test_name):
                        status = self.lxc_manager.get_container_status(test_name)
                        if status == "Running":
                            self.lxc_manager.stop_container(test_name)
                        self.lxc_manager.delete_container(test_name, force=True)
                        self.refresh_containers()
                except:
                    pass
                self.status_var.set("Demo test failed")
        
        # Run in thread to avoid blocking UI
        threading.Thread(target=run_test, daemon=True).start()
    
    def manage_users_dialog(self):
        """Show dialog to manage users in the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        # Check if container is running
        status = self.lxc_manager.get_container_status(container_name)
        if status != "Running":
            messagebox.showwarning("Warning", f"Container '{container_name}' is not running")
            return
        
        dialog = tk.Toplevel(self.root)
        dialog.title(f"User Management - {container_name}")
        dialog.geometry("500x400")
        dialog.transient(self.root)
        dialog.grab_set()
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # Current users
        ttk.Label(frame, text="Current Users:", font=("Arial", 12, "bold")).pack(anchor=tk.W)
        
        users_frame = ttk.Frame(frame)
        users_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 15))
        
        users_listbox = tk.Listbox(users_frame, height=8)
        users_scrollbar = ttk.Scrollbar(users_frame, orient=tk.VERTICAL, command=users_listbox.yview)
        users_listbox.configure(yscrollcommand=users_scrollbar.set)
        
        users_listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        users_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Load users
        def refresh_users():
            users_listbox.delete(0, tk.END)
            users = self.lxc_manager.list_users_in_container(container_name)
            for user in users:
                users_listbox.insert(tk.END, user)
        
        refresh_users()
        
        # Add new user section
        add_user_frame = ttk.LabelFrame(frame, text="Add New User", padding="10")
        add_user_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(add_user_frame, text="Username:").pack(anchor=tk.W)
        new_username_var = tk.StringVar()
        ttk.Entry(add_user_frame, textvariable=new_username_var, width=30).pack(anchor=tk.W, pady=(0, 5))
        
        ttk.Label(add_user_frame, text="Password:").pack(anchor=tk.W)
        new_password_var = tk.StringVar()
        ttk.Entry(add_user_frame, textvariable=new_password_var, width=30, show="*").pack(anchor=tk.W, pady=(0, 5))
        
        new_sudo_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(add_user_frame, text="Grant sudo privileges", 
                       variable=new_sudo_var).pack(anchor=tk.W, pady=(0, 10))
        
        def add_user():
            username = new_username_var.get().strip()
            password = new_password_var.get().strip()
            
            if not username or not password:
                messagebox.showerror("Error", "Username and password are required")
                return
            
            try:
                self.status_var.set(f"Creating user '{username}'...")
                self.root.update()
                
                success = self.lxc_manager.create_user_in_container(
                    container_name, username, password, new_sudo_var.get())
                
                if success:
                    messagebox.showinfo("Success", f"User '{username}' created successfully!")
                    new_username_var.set("")
                    new_password_var.set("")
                    refresh_users()
                else:
                    messagebox.showerror("Error", f"Failed to create user '{username}'")
                
                self.status_var.set("Ready")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to create user: {str(e)}")
                self.status_var.set("Ready")
        
        ttk.Button(add_user_frame, text="Add User", command=add_user).pack(anchor=tk.W)
        
        # Buttons
        button_frame = ttk.Frame(frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="Refresh", command=refresh_users).pack(side=tk.LEFT)
        ttk.Button(button_frame, text="Close", command=dialog.destroy).pack(side=tk.RIGHT)
    
    def network_config_dialog(self):
        """Show dialog to configure network for the selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Network Configuration - {container_name}")
        dialog.geometry("500x400")
        dialog.transient(self.root)
        dialog.grab_set()
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # Network interface attachment
        attach_frame = ttk.LabelFrame(frame, text="Network Interface", padding="10")
        attach_frame.pack(fill=tk.X, pady=(0, 15))
        
        def attach_interface():
            try:
                self.status_var.set(f"Attaching network interface...")
                self.root.update()
                
                success = self.lxc_manager.attach_network_interface(container_name)
                if success:
                    messagebox.showinfo("Success", "Network interface attached successfully!")
                else:
                    messagebox.showerror("Error", "Failed to attach network interface")
                
                self.status_var.set("Ready")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to attach interface: {str(e)}")
                self.status_var.set("Ready")
        
        ttk.Button(attach_frame, text="Attach Network Interface (eth0)", 
                  command=attach_interface).pack(anchor=tk.W)
        
        # IP configuration
        ip_frame = ttk.LabelFrame(frame, text="IP Configuration", padding="10")
        ip_frame.pack(fill=tk.X, pady=(0, 15))
        
        # DHCP configuration
        dhcp_frame = ttk.Frame(ip_frame)
        dhcp_frame.pack(fill=tk.X, pady=(0, 10))
        
        def configure_dhcp():
            try:
                self.status_var.set(f"Configuring DHCP...")
                self.root.update()
                
                success = self.lxc_manager.configure_dhcp(container_name)
                if success:
                    messagebox.showinfo("Success", "DHCP configured successfully!")
                else:
                    messagebox.showerror("Error", "Failed to configure DHCP")
                
                self.status_var.set("Ready")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to configure DHCP: {str(e)}")
                self.status_var.set("Ready")
        
        ttk.Button(dhcp_frame, text="Configure DHCP", command=configure_dhcp).pack(anchor=tk.W)
        
        # Static IP configuration
        static_frame = ttk.LabelFrame(ip_frame, text="Static IP Configuration", padding="10")
        static_frame.pack(fill=tk.X)
        
        ttk.Label(static_frame, text="IP Address (e.g., 10.0.0.100/24):").pack(anchor=tk.W)
        static_ip_var = tk.StringVar(value="10.0.0.100/24")
        ttk.Entry(static_frame, textvariable=static_ip_var, width=30).pack(anchor=tk.W, pady=(0, 5))
        
        ttk.Label(static_frame, text="Gateway:").pack(anchor=tk.W)
        static_gateway_var = tk.StringVar(value="10.0.0.1")
        ttk.Entry(static_frame, textvariable=static_gateway_var, width=30).pack(anchor=tk.W, pady=(0, 5))
        
        ttk.Label(static_frame, text="DNS Servers (comma-separated):").pack(anchor=tk.W)
        static_dns_var = tk.StringVar(value="8.8.8.8,8.8.4.4")
        ttk.Entry(static_frame, textvariable=static_dns_var, width=30).pack(anchor=tk.W, pady=(0, 10))
        
        def configure_static():
            try:
                self.status_var.set(f"Configuring static IP...")
                self.root.update()
                
                ip_address = static_ip_var.get().strip()
                gateway = static_gateway_var.get().strip()
                dns_servers = [dns.strip() for dns in static_dns_var.get().split(',')]
                
                success = self.lxc_manager.configure_static_ip(container_name, ip_address, gateway, dns_servers)
                if success:
                    messagebox.showinfo("Success", "Static IP configured successfully!")
                else:
                    messagebox.showerror("Error", "Failed to configure static IP")
                
                self.status_var.set("Ready")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to configure static IP: {str(e)}")
                self.status_var.set("Ready")
        
        ttk.Button(static_frame, text="Configure Static IP", command=configure_static).pack(anchor=tk.W)
        
        # Close button
        ttk.Button(frame, text="Close", command=dialog.destroy).pack(pady=(20, 0))
    
    def show_network_interfaces(self):
        """Show network interfaces and their configuration"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Network Interfaces")
        dialog.geometry("700x500")
        dialog.transient(self.root)
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # Networks list
        networks_frame = ttk.LabelFrame(frame, text="Available Networks", padding="10")
        networks_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 15))
        
        # Treeview for networks
        networks_tree = ttk.Treeview(networks_frame, columns=('Type', 'State', 'IPv4'), show='tree headings')
        networks_tree.pack(fill=tk.BOTH, expand=True)
        
        networks_tree.heading('#0', text='Network Name')
        networks_tree.heading('Type', text='Type')
        networks_tree.heading('State', text='State')
        networks_tree.heading('IPv4', text='IPv4 Address')
        
        def refresh_networks():
            # Clear existing items
            for item in networks_tree.get_children():
                networks_tree.delete(item)
            
            try:
                networks = self.lxc_manager.list_networks()
                for network in networks:
                    name = network.get('name', 'Unknown')
                    net_type = network.get('type', 'Unknown')
                    state = network.get('state', 'Unknown')
                    config = network.get('config', {})
                    ipv4 = config.get('ipv4.address', 'N/A')
                    
                    networks_tree.insert('', tk.END, text=name, 
                                       values=(net_type, state, ipv4))
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load networks: {str(e)}")
        
        def show_network_details():
            selection = networks_tree.selection()
            if not selection:
                messagebox.showwarning("Warning", "Please select a network first")
                return
            
            item = networks_tree.item(selection[0])
            network_name = item['text']
            
            try:
                info = self.lxc_manager.get_network_info(network_name)
                if info:
                    # Show in new window
                    info_window = tk.Toplevel(dialog)
                    info_window.title(f"Network Details - {network_name}")
                    info_window.geometry("600x400")
                    
                    info_frame = ttk.Frame(info_window, padding="10")
                    info_frame.pack(fill=tk.BOTH, expand=True)
                    
                    text_widget = tk.Text(info_frame, wrap=tk.WORD, font=("Courier", 10))
                    scrollbar = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, command=text_widget.yview)
                    text_widget.configure(yscrollcommand=scrollbar.set)
                    
                    text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
                    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
                    
                    text_widget.insert(tk.END, info)
                    text_widget.config(state=tk.DISABLED)
                    
                    ttk.Button(info_frame, text="Close", command=info_window.destroy).pack(pady=(10, 0))
                else:
                    messagebox.showerror("Error", f"Could not get information for network '{network_name}'")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to get network info: {str(e)}")
        
        refresh_networks()
        
        # Buttons
        button_frame = ttk.Frame(frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="Refresh", command=refresh_networks).pack(side=tk.LEFT)
        ttk.Button(button_frame, text="Show Details", command=show_network_details).pack(side=tk.LEFT, padx=(5, 0))
        ttk.Button(button_frame, text="Close", command=dialog.destroy).pack(side=tk.RIGHT)
    
    def open_terminal_dialog(self):
        """Open terminal emulator dialog for selected container"""
        container_name = self.get_selected_container()
        if not container_name:
            messagebox.showwarning("Warning", "Please select a container first")
            return
        
        if not self.lxc_manager.is_container_running(container_name):
            messagebox.showwarning("Warning", f"Container '{container_name}' is not running")
            return
        
        # Get available users and shells
        try:
            users = self.lxc_manager.list_users(container_name)
            shells = self.lxc_manager.get_available_shells(container_name)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to get container info: {str(e)}")
            return
        
        # Dialog for user and shell selection
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Terminal Options - {container_name}")
        dialog.geometry("400x300")
        dialog.transient(self.root)
        dialog.grab_set()
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # User selection
        ttk.Label(frame, text="Select User:").pack(anchor=tk.W, pady=(0, 5))
        user_var = tk.StringVar(value="root")
        user_combo = ttk.Combobox(frame, textvariable=user_var, values=["root"] + users, state="readonly")
        user_combo.pack(fill=tk.X, pady=(0, 15))
        
        # Shell selection
        ttk.Label(frame, text="Select Shell:").pack(anchor=tk.W, pady=(0, 5))
        shell_var = tk.StringVar(value="/bin/bash")
        shell_combo = ttk.Combobox(frame, textvariable=shell_var, values=shells, state="readonly")
        shell_combo.pack(fill=tk.X, pady=(0, 20))
        
        def open_terminal():
            username = user_var.get()
            shell = shell_var.get()
            dialog.destroy()
            
            try:
                success = self.lxc_manager.open_external_terminal(container_name, username, shell)
                if success:
                    self.status_var.set(f"Opened terminal for {container_name} as {username}")
                else:
                    messagebox.showerror("Error", "Failed to open terminal")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open terminal: {str(e)}")
        
        # Buttons
        button_frame = ttk.Frame(frame)
        button_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(button_frame, text="Open Terminal", command=open_terminal).pack(side=tk.RIGHT, padx=(5, 0))
        ttk.Button(button_frame, text="Cancel", command=dialog.destroy).pack(side=tk.RIGHT)
    
    def application_mirroring_dialog(self):
        """Show application mirroring management dialog"""
        container_name = self.get_selected_container()
        if not container_name:
            return
        
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Application Mirroring - {container_name}")
        dialog.geometry("700x500")
        dialog.transient(self.root)
        dialog.grab_set()
        
        frame = ttk.Frame(dialog, padding="20")
        frame.pack(fill=tk.BOTH, expand=True)
        
        # Status section
        status_frame = ttk.LabelFrame(frame, text="Mirroring Status", padding="10")
        status_frame.pack(fill=tk.X, pady=(0, 15))
        
        # Check current status
        is_active = self.lxc_manager.is_application_mirroring_active(container_name)
        status_text = "Active" if is_active else "Inactive"
        status_color = "green" if is_active else "red"
        
        status_label = ttk.Label(status_frame, text=f"Status: {status_text}", 
                               foreground=status_color, font=("Arial", 10, "bold"))
        status_label.pack(anchor=tk.W)
        
        # Information
        info_text = (
            "Application mirroring copies desktop applications from the container "
            "to your host system, allowing you to launch container applications "
            "directly from your desktop environment.\n\n"
            "Monitored directories:\n"
            "• /usr/share/applications\n"
            "• /usr/local/share/applications\n"
            "• ~/.local/share/applications (user directories)\n\n"
            "Applications will appear with '(from container-name)' suffix."
        )
        
        info_label = ttk.Label(status_frame, text=info_text, wraplength=600)
        info_label.pack(anchor=tk.W, pady=(10, 0))
        
        # Control buttons
        control_frame = ttk.LabelFrame(frame, text="Controls", padding="10")
        control_frame.pack(fill=tk.X, pady=(0, 15))
        
        def start_mirroring():
            try:
                # Check if container is running
                if not self.lxc_manager.is_container_running(container_name):
                    messagebox.showwarning("Warning", f"Container '{container_name}' must be running to start mirroring")
                    return
                
                self.status_var.set(f"Starting application mirroring for '{container_name}'...")
                self.root.update()
                
                success = self.lxc_manager.setup_application_mirroring(container_name)
                if success:
                    messagebox.showinfo("Success", "Application mirroring started successfully!")
                    dialog.destroy()
                    self.application_mirroring_dialog()  # Refresh dialog
                else:
                    messagebox.showerror("Error", "Failed to start application mirroring")
                
                self.status_var.set("Ready")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to start mirroring: {str(e)}")
                self.status_var.set("Ready")
        
        def stop_mirroring():
            try:
                self.status_var.set(f"Stopping application mirroring for '{container_name}'...")
                self.root.update()
                
                success = self.lxc_manager.stop_application_mirroring(container_name)
                if success:
                    messagebox.showinfo("Success", "Application mirroring stopped and cleaned up!")
                    dialog.destroy()
                    self.application_mirroring_dialog()  # Refresh dialog
                else:
                    messagebox.showerror("Error", "Failed to stop application mirroring")
                
                self.status_var.set("Ready")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to stop mirroring: {str(e)}")
                self.status_var.set("Ready")
        
        def sync_now():
            try:
                self.status_var.set(f"Synchronizing applications from '{container_name}'...")
                self.root.update()
                
                # Force a sync
                self.lxc_manager._sync_container_applications(container_name)
                messagebox.showinfo("Success", "Applications synchronized!")
                refresh_apps()
                
                self.status_var.set("Ready")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to sync applications: {str(e)}")
                self.status_var.set("Ready")
        
        button_frame = ttk.Frame(control_frame)
        button_frame.pack(fill=tk.X)
        
        if is_active:
            ttk.Button(button_frame, text="Stop Mirroring", command=stop_mirroring).pack(side=tk.LEFT, padx=(0, 5))
            ttk.Button(button_frame, text="Sync Now", command=sync_now).pack(side=tk.LEFT, padx=(0, 5))
        else:
            ttk.Button(button_frame, text="Start Mirroring", command=start_mirroring).pack(side=tk.LEFT, padx=(0, 5))
        
        # Applications list
        apps_frame = ttk.LabelFrame(frame, text="Mirrored Applications", padding="10")
        apps_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 15))
        
        # Create treeview for applications
        apps_tree = ttk.Treeview(apps_frame, columns=('Name', 'Categories', 'Command'), show='headings', height=10)
        apps_tree.pack(fill=tk.BOTH, expand=True, side=tk.LEFT)
        
        # Configure columns
        apps_tree.heading('Name', text='Application Name')
        apps_tree.heading('Categories', text='Categories')
        apps_tree.heading('Command', text='Command')
        
        apps_tree.column('Name', width=200)
        apps_tree.column('Categories', width=150)
        apps_tree.column('Command', width=300)
        
        # Scrollbar for applications tree
        apps_scrollbar = ttk.Scrollbar(apps_frame, orient=tk.VERTICAL, command=apps_tree.yview)
        apps_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        apps_tree.configure(yscrollcommand=apps_scrollbar.set)
        
        def refresh_apps():
            # Clear existing items
            for item in apps_tree.get_children():
                apps_tree.delete(item)
            
            try:
                applications = self.lxc_manager.list_mirrored_applications(container_name)
                for app in applications:
                    apps_tree.insert('', tk.END, values=(
                        app.get('name', ''),
                        app.get('categories', ''),
                        app.get('exec', '')
                    ))
            except Exception as e:
                pass  # Silently handle errors
        
        refresh_apps()
        
        # Bottom buttons
        bottom_frame = ttk.Frame(frame)
        bottom_frame.pack(fill=tk.X)
        
        ttk.Button(bottom_frame, text="Refresh List", command=refresh_apps).pack(side=tk.LEFT)
        ttk.Button(bottom_frame, text="Close", command=dialog.destroy).pack(side=tk.RIGHT)
    
    def disk_management_dialog(self):
        """Show disk management dialog"""
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Please select a container first.")
            return
        
        container_name = self.tree.item(selection[0])['text']
        
        # Create dialog window
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Disk Management - {container_name}")
        dialog.geometry("600x700")
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Main frame
        main_frame = ttk.Frame(dialog, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title_label = ttk.Label(main_frame, text=f"Disk Management for '{container_name}'", 
                               font=("Arial", 14, "bold"))
        title_label.pack(pady=(0, 20))
        
        # Storage info frame
        info_frame = ttk.LabelFrame(main_frame, text="Storage Information", padding="10")
        info_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Get storage info
        storage_info = self.lxc_manager.get_storage_info(container_name)
        
        if 'error' in storage_info:
            ttk.Label(info_frame, text=f"Error: {storage_info['error']}", 
                     foreground='red').pack()
        else:
            # Storage pool info
            pool_frame = ttk.Frame(info_frame)
            pool_frame.pack(fill=tk.X, pady=(0, 10))
            
            ttk.Label(pool_frame, text="Storage Pool:", 
                     font=("Arial", 10, "bold")).pack(anchor=tk.W)
            
            pool_name = storage_info.get('storage_pool', 'default')
            ttk.Label(pool_frame, 
                     text=f"  Name: {pool_name}").pack(anchor=tk.W)
            
            if 'pool_driver' in storage_info:
                ttk.Label(pool_frame, 
                         text=f"  Driver: {storage_info['pool_driver']}").pack(anchor=tk.W)
            
            if 'pool_size' in storage_info:
                ttk.Label(pool_frame, 
                         text=f"  Pool Size: {storage_info['pool_size']}").pack(anchor=tk.W)
            
            if 'pool_source' in storage_info:
                ttk.Label(pool_frame, 
                         text=f"  Source: {storage_info['pool_source']}").pack(anchor=tk.W)
            
            # Container storage info
            container_frame = ttk.Frame(info_frame)
            container_frame.pack(fill=tk.X, pady=(0, 10))
            
            ttk.Label(container_frame, text="Container Storage:", 
                     font=("Arial", 10, "bold")).pack(anchor=tk.W)
            
            if 'container_size' in storage_info:
                ttk.Label(container_frame, 
                         text=f"  Size: {storage_info['container_size']}").pack(anchor=tk.W)
                ttk.Label(container_frame, 
                         text=f"  Used: {storage_info['container_used']}").pack(anchor=tk.W)
                ttk.Label(container_frame, 
                         text=f"  Available: {storage_info['container_available']}").pack(anchor=tk.W)
                ttk.Label(container_frame, 
                         text=f"  Usage: {storage_info['container_use_percent']}").pack(anchor=tk.W)
            
            # Host root storage info
            root_frame = ttk.Frame(info_frame)
            root_frame.pack(fill=tk.X, pady=(0, 10))
            
            ttk.Label(root_frame, text="Host Root Storage:", 
                     font=("Arial", 10, "bold")).pack(anchor=tk.W)
            
            if 'host_root_size' in storage_info:
                ttk.Label(root_frame, 
                         text=f"  Size: {storage_info['host_root_size']}").pack(anchor=tk.W)
                ttk.Label(root_frame, 
                         text=f"  Used: {storage_info['host_root_used']}").pack(anchor=tk.W)
                ttk.Label(root_frame, 
                         text=f"  Available: {storage_info['host_root_available']}").pack(anchor=tk.W)
                ttk.Label(root_frame, 
                         text=f"  Usage: {storage_info['host_root_use_percent']}").pack(anchor=tk.W)
            
            # Host home storage info
            home_frame = ttk.Frame(info_frame)
            home_frame.pack(fill=tk.X, pady=(0, 10))
            
            ttk.Label(home_frame, text="Host Home Storage:", 
                     font=("Arial", 10, "bold")).pack(anchor=tk.W)
            
            if 'host_home_size' in storage_info:
                ttk.Label(home_frame, 
                         text=f"  Size: {storage_info['host_home_size']}").pack(anchor=tk.W)
                ttk.Label(home_frame, 
                         text=f"  Used: {storage_info['host_home_used']}").pack(anchor=tk.W)
                ttk.Label(home_frame, 
                         text=f"  Available: {storage_info['host_home_available']}").pack(anchor=tk.W)
                ttk.Label(home_frame, 
                         text=f"  Usage: {storage_info['host_home_use_percent']}").pack(anchor=tk.W)
        
        # Disk resize frame
        resize_frame = ttk.LabelFrame(main_frame, text="Resize Storage Pool", padding="10")
        resize_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Get current pool name for resizing
        current_pool = storage_info.get('storage_pool', 'default')
        
        ttk.Label(resize_frame, text=f"Resize storage pool '{current_pool}' to:").pack(anchor=tk.W)
        
        size_frame = ttk.Frame(resize_frame)
        size_frame.pack(fill=tk.X, pady=5)
        
        size_var = tk.StringVar()
        size_entry = ttk.Entry(size_frame, textvariable=size_var, width=10)
        size_entry.pack(side=tk.LEFT, padx=(0, 5))
        
        size_unit = tk.StringVar(value="GB")
        size_combo = ttk.Combobox(size_frame, textvariable=size_unit, values=["GB", "MB", "TB"], 
                                 width=5, state="readonly")
        size_combo.pack(side=tk.LEFT, padx=(0, 10))
        
        # Quick size buttons
        quick_frame = ttk.Frame(resize_frame)
        quick_frame.pack(fill=tk.X, pady=5)
        
        ttk.Label(quick_frame, text="Quick sizes:").pack(side=tk.LEFT, padx=(0, 10))
        
        def set_quick_size(size):
            size_var.set(str(size))
            size_unit.set("GB")
        
        for size in [10, 20, 50, 100]:
            ttk.Button(quick_frame, text=f"{size}GB", 
                      command=lambda s=size: set_quick_size(s)).pack(side=tk.LEFT, padx=2)
        
        # Available space button
        def set_max_size():
            available = self.lxc_manager.get_available_disk_space_gb("/")
            if available > 1:
                size_var.set(str(int(available - 1)))  # Leave 1GB free
                size_unit.set("GB")
        
        ttk.Button(quick_frame, text="Max Available", 
                  command=set_max_size).pack(side=tk.LEFT, padx=10)
        
        def resize_disk():
            try:
                size = size_var.get().strip()
                unit = size_unit.get()
                
                if not size:
                    messagebox.showerror("Error", "Please enter a size.")
                    return
                
                # Validate size is numeric and whole number
                try:
                    size_num = float(size)
                    if size_num != int(size_num):
                        messagebox.showerror("Error", "Size must be a whole number (no decimals).\nLXD storage pools don't support decimal sizes.")
                        return
                    if size_num <= 0:
                        messagebox.showerror("Error", "Size must be greater than 0.")
                        return
                except ValueError:
                    messagebox.showerror("Error", "Size must be a number.")
                    return
                
                new_size = f"{size}{unit}"
                
                # Confirm resize
                if messagebox.askyesno("Confirm Resize", 
                                     f"Resize storage pool '{current_pool}' to {new_size}?\n\n"
                                     "Note: This will affect ALL containers using this storage pool.\n"
                                     "The change takes effect immediately."):
                    
                    success = self.lxc_manager.resize_storage_pool(current_pool, new_size)
                    
                    if success:
                        messagebox.showinfo("Success", 
                                          f"Storage pool '{current_pool}' resized to {new_size}.\n\n"
                                          "All containers using this pool now have access to the new size.")
                        dialog.destroy()
                    else:
                        messagebox.showerror("Error", "Failed to resize storage pool.")
                        
            except Exception as e:
                messagebox.showerror("Error", f"Failed to resize storage pool: {str(e)}")
        
        ttk.Button(resize_frame, text="Resize Storage Pool", 
                  command=resize_disk).pack(pady=10)
        
        # Home symlink frame
        symlink_frame = ttk.LabelFrame(main_frame, text="Home Folder Access (Experimental)", padding="10")
        symlink_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(symlink_frame, text="Mount host home folder inside container for additional storage:", 
                 wraplength=500).pack(anchor=tk.W, pady=(0, 10))
        
        # Check current status
        is_symlink_active = self.lxc_manager.is_home_symlink_active(container_name)
        
        status_frame = ttk.Frame(symlink_frame)
        status_frame.pack(fill=tk.X, pady=(0, 10))
        
        status_text = "Active" if is_symlink_active else "Inactive"
        status_color = "green" if is_symlink_active else "red"
        
        ttk.Label(status_frame, text="Status:").pack(side=tk.LEFT)
        status_label = ttk.Label(status_frame, text=status_text, foreground=status_color)
        status_label.pack(side=tk.LEFT, padx=(5, 0))
        
        def toggle_symlink():
            try:
                if is_symlink_active:
                    success = self.lxc_manager.remove_home_symlink_storage(container_name)
                    if success:
                        messagebox.showinfo("Success", "Home folder access removed.")
                        dialog.destroy()
                    else:
                        messagebox.showerror("Error", "Failed to remove home folder access.")
                else:
                    success = self.lxc_manager.setup_home_symlink_storage(container_name)
                    if success:
                        messagebox.showinfo("Success", 
                                          "Home folder access enabled.\n"
                                          "Access via: /mnt/host_home_* or /home/host_home")
                        dialog.destroy()
                    else:
                        messagebox.showerror("Error", "Failed to setup home folder access.")
                        
            except Exception as e:
                messagebox.showerror("Error", f"Failed to toggle home access: {str(e)}")
        
        button_text = "Remove Home Access" if is_symlink_active else "Enable Home Access"
        ttk.Button(symlink_frame, text=button_text, 
                  command=toggle_symlink).pack(pady=10)
        
        # Warning label
        ttk.Label(symlink_frame, 
                 text="⚠️ Warning: This gives container full access to your home folder!", 
                 foreground="red", wraplength=500).pack(anchor=tk.W)
        
        # Buttons frame
        buttons_frame = ttk.Frame(main_frame)
        buttons_frame.pack(fill=tk.X, pady=20)
        
        def refresh_info():
            dialog.destroy()
            self.disk_management_dialog()
        
        ttk.Button(buttons_frame, text="Refresh", 
                  command=refresh_info).pack(side=tk.LEFT, padx=(0, 10))
        
        ttk.Button(buttons_frame, text="Close", 
                  command=dialog.destroy).pack(side=tk.RIGHT)
    
    def storage_pool_dialog(self):
        """Show storage pool management dialog"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Storage Pool Management")
        dialog.geometry("700x600")
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Main frame
        main_frame = ttk.Frame(dialog, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title_label = ttk.Label(main_frame, text="Storage Pool Management", 
                               font=("Arial", 14, "bold"))
        title_label.pack(pady=(0, 20))

        # Storage info frame
        info_frame = ttk.LabelFrame(main_frame, text="Host Storage Information", padding="10")
        info_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Get host storage info
        try:
            # Get root storage info
            result = self.lxc_manager.run_command(['df', '-h', '/'])
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    fields = lines[1].split()
                    if len(fields) >= 4:
                        root_frame = ttk.Frame(info_frame)
                        root_frame.pack(fill=tk.X, pady=(0, 10))
                        
                        ttk.Label(root_frame, text="Root Partition (/):", 
                                 font=("Arial", 10, "bold")).pack(anchor=tk.W)
                        ttk.Label(root_frame, 
                                 text=f"  Size: {fields[1]}").pack(anchor=tk.W)
                        ttk.Label(root_frame, 
                                 text=f"  Used: {fields[2]}").pack(anchor=tk.W)
                        ttk.Label(root_frame, 
                                 text=f"  Available: {fields[3]}").pack(anchor=tk.W)
                        ttk.Label(root_frame, 
                                 text=f"  Usage: {fields[4]}").pack(anchor=tk.W)
                        
        except Exception as e:
            ttk.Label(info_frame, text=f"Error getting storage info: {str(e)}", 
                     foreground='red').pack(anchor=tk.W)
        
        # Storage pools list frame
        pools_frame = ttk.LabelFrame(main_frame, text="Available Storage Pools", padding="10")
        pools_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        
        
        # Storage pools list frame
        pools_frame = ttk.LabelFrame(main_frame, text="Available Storage Pools", padding="10")
        pools_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        # Create treeview for storage pools
        pools_tree = ttk.Treeview(pools_frame, columns=('Driver', 'Size', 'Used By'), show='tree headings')
        pools_tree.pack(fill=tk.BOTH, expand=True, side=tk.LEFT)
        
        # Configure columns
        pools_tree.heading('#0', text='Pool Name')
        pools_tree.heading('Driver', text='Driver')
        pools_tree.heading('Size', text='Size')
        pools_tree.heading('Used By', text='Used By')
        
        pools_tree.column('#0', width=150)
        pools_tree.column('Driver', width=100)
        pools_tree.column('Size', width=100)
        pools_tree.column('Used By', width=80)
        
        # Scrollbar for pools tree
        pools_scrollbar = ttk.Scrollbar(pools_frame, orient=tk.VERTICAL, command=pools_tree.yview)
        pools_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        pools_tree.configure(yscrollcommand=pools_scrollbar.set)
        
        def refresh_pools():
            # Clear existing items
            for item in pools_tree.get_children():
                pools_tree.delete(item)
            
            try:
                pools = self.lxc_manager.get_storage_pools()
                for pool in pools:
                    name = pool.get('name', 'Unknown')
                    driver = pool.get('driver', 'Unknown')
                    used_by_count = len(pool.get('used_by', []))
                    
                    # Get detailed pool info for size
                    pool_info = self.lxc_manager.get_storage_pool_info(name)
                    size = 'N/A'
                    if pool_info and 'config' in pool_info and 'size' in pool_info['config']:
                        size = pool_info['config']['size']
                    
                    pools_tree.insert('', tk.END, text=name, 
                                    values=(driver, size, used_by_count))
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load storage pools: {str(e)}")
        
        refresh_pools()
        
        # Pool details frame
        details_frame = ttk.LabelFrame(main_frame, text="Pool Details & Management", padding="10")
        details_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Selected pool info
        selected_pool_label = ttk.Label(details_frame, text="Select a storage pool above to manage")
        selected_pool_label.pack(anchor=tk.W, pady=(0, 10))
        
        # Resize controls
        resize_frame = ttk.Frame(details_frame)
        resize_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(resize_frame, text="New Size:").pack(side=tk.LEFT, padx=(0, 5))
        
        size_var = tk.StringVar()
        size_entry = ttk.Entry(resize_frame, textvariable=size_var, width=10)
        size_entry.pack(side=tk.LEFT, padx=(0, 5))
        
        size_unit = tk.StringVar(value="GB")
        size_combo = ttk.Combobox(resize_frame, textvariable=size_unit, values=["GB", "TB"], 
                                 width=5, state="readonly")
        size_combo.pack(side=tk.LEFT, padx=(0, 10))
        
        # Quick size buttons
        quick_frame = ttk.Frame(resize_frame)
        quick_frame.pack(side=tk.LEFT, padx=(10, 0))
        
        def set_quick_size(size):
            size_var.set(str(size))
            size_unit.set("GB")
        
        for size in [5, 10, 20, 50]:
            ttk.Button(quick_frame, text=f"{size}GB", 
                      command=lambda s=size: set_quick_size(s)).pack(side=tk.LEFT, padx=2)
        
        # Resize button
        def resize_selected_pool():
            selection = pools_tree.selection()
            if not selection:
                messagebox.showwarning("Warning", "Please select a storage pool first")
                return
            
            pool_name = pools_tree.item(selection[0])['text']
            size = size_var.get().strip()
            unit = size_unit.get()
            
            if not size:
                messagebox.showerror("Error", "Please enter a size")
                return
            
            try:
                size_num = float(size)
                if size_num != int(size_num):
                    messagebox.showerror("Error", "Size must be a whole number (no decimals).\nLXD storage pools don't support decimal sizes.")
                    return
                if size_num <= 0:
                    messagebox.showerror("Error", "Size must be greater than 0.")
                    return
            except ValueError:
                messagebox.showerror("Error", "Size must be a number")
                return
            
            new_size = f"{size}{unit}"
            
            # Confirm resize
            if messagebox.askyesno("Confirm Resize", 
                                 f"Resize storage pool '{pool_name}' to {new_size}?\n\n"
                                 "This will affect ALL containers using this storage pool.\n"
                                 "The change takes effect immediately."):
                
                try:
                    success = self.lxc_manager.resize_storage_pool(pool_name, new_size)
                    
                    if success:
                        messagebox.showinfo("Success", 
                                          f"Storage pool '{pool_name}' resized to {new_size}")
                        refresh_pools()
                        size_var.set("")
                    else:
                        messagebox.showerror("Error", "Failed to resize storage pool")
                        
                except Exception as e:
                    messagebox.showerror("Error", f"Failed to resize storage pool: {str(e)}")
        
        ttk.Button(resize_frame, text="Resize Pool", 
                  command=resize_selected_pool).pack(side=tk.RIGHT, padx=(10, 0))
        
        # Pool selection handler
        def on_pool_select(event):
            selection = pools_tree.selection()
            if selection:
                pool_name = pools_tree.item(selection[0])['text']
                selected_pool_label.config(text=f"Managing pool: {pool_name}")
                
                # Get pool details
                try:
                    pool_info = self.lxc_manager.get_storage_pool_info(pool_name)
                    if pool_info:
                        details_text = f"Pool: {pool_name}\n"
                        details_text += f"Driver: {pool_info.get('driver', 'Unknown')}\n"
                        if 'config' in pool_info:
                            config = pool_info['config']
                            if 'size' in config:
                                details_text += f"Current Size: {config['size']}\n"
                            if 'source' in config:
                                details_text += f"Source: {config['source']}\n"
                        
                        selected_pool_label.config(text=details_text)
                except:
                    pass
        
        pools_tree.bind('<<TreeviewSelect>>', on_pool_select)
        
        # Show pool details button
        def show_pool_details():
            selection = pools_tree.selection()
            if not selection:
                messagebox.showwarning("Warning", "Please select a storage pool first")
                return
            
            pool_name = pools_tree.item(selection[0])['text']
            
            try:
                # Get detailed pool info
                result = self.lxc_manager.run_command(['lxc', 'storage', 'show', pool_name])
                if result.returncode == 0:
                    # Show in new window
                    info_window = tk.Toplevel(dialog)
                    info_window.title(f"Storage Pool Details - {pool_name}")
                    info_window.geometry("600x400")
                    
                    info_frame = ttk.Frame(info_window, padding="10")
                    info_frame.pack(fill=tk.BOTH, expand=True)
                    
                    text_widget = tk.Text(info_frame, wrap=tk.WORD, font=("Courier", 10))
                    scrollbar = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, command=text_widget.yview)
                    text_widget.configure(yscrollcommand=scrollbar.set)
                    
                    text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
                    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
                    
                    text_widget.insert(tk.END, result.stdout)
                    text_widget.config(state=tk.DISABLED)
                    
                    ttk.Button(info_frame, text="Close", command=info_window.destroy).pack(pady=(10, 0))
                else:
                    messagebox.showerror("Error", f"Could not get details for pool '{pool_name}'")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to get pool details: {str(e)}")
        
        # Bottom buttons
        bottom_frame = ttk.Frame(main_frame)
        bottom_frame.pack(fill=tk.X)
        
        ttk.Button(bottom_frame, text="Refresh Pools", command=refresh_pools).pack(side=tk.LEFT)
        ttk.Button(bottom_frame, text="Show Details", command=show_pool_details).pack(side=tk.LEFT, padx=(5, 0))
        ttk.Button(bottom_frame, text="Close", command=dialog.destroy).pack(side=tk.RIGHT)
    
    def run(self):
        """Start the GUI application"""
        try:
            # Check LXD availability on startup
            result = self.lxc_manager.run_command(['lxc', 'version'])
            if result.returncode != 0:
                messagebox.showerror("LXD Error", "LXD is not available. Please ensure LXD is installed and configured.")
                return
            
            self.status_var.set("LXC GUI Ready - Select a container and use the buttons")
            self.root.mainloop()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start application: {str(e)}")


def main():
    """Main entry point"""
    print("Starting LXC GUI Manager...")
    app = LXCGui()
    app.run()


if __name__ == "__main__":
    main()
