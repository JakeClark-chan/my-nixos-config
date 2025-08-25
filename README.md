# My NixOS Configuration

A comprehensive, modular NixOS configuration with Nix flakes, featuring Hyprland window manager, advanced power management, and automated scripts for a seamless desktop experience.

## 🏗️ Structure

```
├── configuration.nix           # Main configuration file
├── flake.nix                  # Flake configuration
├── hardware-configuration.nix # Hardware-specific settings (auto-generated)
└── modules/
    ├── core/
    │   ├── boot.nix           # Bootloader settings (systemd-boot)
    │   ├── default.nix        # Imports for core modules
    │   ├── hardware.nix       # Hardware & firmware configs (kernel, firmware, udev rules)
    │   └── nix.nix            # Nix settings, GC, unfree
    ├── desktop/
    │   ├── deepin.nix         # Deepin desktop environment (disabled)
    │   ├── default.nix        # Imports for desktop modules
    │   └── hyprland.nix       # Hyprland window manager with Wayland ecosystem
    ├── fonts/
    │   └── hsr-zh-cn.ttf      # Custom font
    ├── home/
    │   ├── jc.nix             # Home Manager: user packages, programs & dotfiles
    │   ├── .config/           # Application dotfiles (Hyprland, Waybar, etc.)
    │   └── scripts/           # Modular Nix scripts (power management, UI, etc.)
    │       ├── apply-home-manager.nix  # Home Manager apply with notifications
    │       ├── brightness-control.nix  # Brightness control with notifications
    │       ├── graceful-shutdown.nix   # Smart shutdown/reboot handler
    │       ├── lock-screen.nix         # Multi-locker selection menu
    │       ├── lxc-gui.nix            # LXC container GUI manager
    │       └── volume-control.nix      # Volume control with notifications
    ├── programs/
    │   ├── cli.nix            # Command-line interface tools
    │   ├── default.nix        # Imports for program modules
    │   ├── development.nix    # Development tools + TLP power management
    │   └── fonts.nix          # Font configurations
    ├── services/
    │   ├── audio.nix          # PipeWire audio configuration
    │   ├── channels.nix       # Nix channels configuration
    │   ├── default.nix        # Imports for service modules
    │   ├── network.nix        # Hostname, NetworkManager, firewall
    │   └── virtualization.nix # LXD + nix-ld (FHS compat)
    ├── settings/
    │   ├── default.nix        # Imports for settings modules
    │   ├── journald.nix       # Journald configuration
    │   ├── locale.nix         # Timezone & localization + Fcitx5
    │   ├── memory.nix         # Swap & zram
    │   └── plymouth.nix       # Plymouth boot theme
    └── users/
        └── jc.nix             # User account & groups
```

## 🚀 Key Features

### **System Architecture**
- **Modular Design**: Clean separation of concerns with Nix flakes
- **Home Manager Integration**: User-level packages and configurations
- **Advanced Power Management**: TLP + thermald replacing auto-cpufreq
- **Containerization**: LXD with GUI management and application mirroring

### **Desktop Environment**
- **Hyprland**: Modern Wayland compositor with smooth animations
- **Waybar**: Customizable status bar with gradients and visual feedback
- **Dual Lock Screens**: Hyprlock (recommended) + Swaylock Effects with interactive menu
- **Smart Notifications**: Swaynotificationcenter with fallback support

### **Developer Experience**
- **Multiple Lock Screen Options**: Interactive selection between Hyprlock and Swaylock
- **Graceful Shutdown**: Intelligent application closure with user prompts
- **Custom Scripts**: Modular Nix-based scripts for system management
- **Home Manager Automation**: One-command configuration updates with notifications

## 📦 Included Software

### **Desktop & Multimedia**
- **Window Manager**: Hyprland with Waybar status bar
- **Terminals**: Kitty (primary), with Cascadia Code Nerd Font
- **File Management**: Thunar with volume management and trash support
- **Media**: VLC, gThumb image viewer
- **Screenshots**: Flameshot + grim for versatile capture options

### **Development & Productivity**
- **Editors**: VS Code, configured for optimal performance
- **Languages**: Python 3.13, Node.js, Java (OpenJDK)
- **Version Control**: Git with SSH agent
- **Package Management**: uv for Python virtual environments
- **Productivity**: OnlyOffice Desktop Editors
- **AI Tools**: Gemini CLI, ani-cli for media streaming

### **System & Utilities**
- **Power Management**: TLP with intelligent AC/battery profiles, thermald for thermal control
- **Monitoring**: Mission Center, nvtop for NVIDIA GPUs
- **Virtualization**: LXD with custom GUI manager and desktop app mirroring
- **Shell**: Zsh with Starship prompt
- **Input**: Fcitx5 for multi-language input support

## 🔧 Hardware & Performance

### **System Specifications**
- **Kernel**: Linux stable with all redistributable firmware
- **Display**: 1920x1080@144Hz with 1x scaling, optimized for laptops
- **Audio**: PipeWire with ALSA/PulseAudio compatibility
- **Graphics**: NVIDIA support with PRIME configuration options

### **Power Management**
- **TLP Configuration**: Optimized for laptop usage
  - Performance mode on AC power
  - Power-saving mode on battery (20% max CPU)
  - Battery health protection (40-80% charging thresholds)
- **Thermal Management**: thermald for Intel CPU thermal control
- **Memory**: 4GB swapfile + 30% zram with LZ4 compression

### **Custom Scripts & Automation**
- **Volume Control**: WirePlumber integration with visual notifications
- **Brightness Control**: Step-based adjustment with percentage display
- **Lock Screen Menu**: Dynamic selection between lock screen options
- **Graceful Shutdown**: Smart application management before system shutdown
- **Home Manager Updates**: Automated configuration application with status notifications

## 🌐 Network & Connectivity

## 🌐 Network & Connectivity

- **Hostname**: JakeClark-Sep21st
- **Network Management**: NetworkManager with firewall enabled
- **SSH**: Client-side SSH agent enabled (server disabled by default)
- **Virtualization**: LXD for container management with GUI interface

## 🛠️ Installation & Usage

### **Initial Setup**
1. **Clone Repository**:
   ```bash
   git clone https://github.com/JakeClark38a/my-nixos-config.git
   cd my-nixos-config
   ```

2. **Prepare Hardware Configuration**:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix .
   ```

3. **Test Configuration**:
   ```bash
   sudo nixos-rebuild test --flake .
   ```

4. **Apply Configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

### **Post-Installation**
- **Home Manager Setup**: Automatically configured via flake integration
- **Custom Scripts**: Available immediately in PATH (lock-screen, volume-control, etc.)
- **LXC Containers**: Access via `lxc-gui` command or application menu

## 🔄 Maintenance & Updates

### **System Updates**
```bash
# Update flake inputs and rebuild
sudo nix flake update
sudo nixos-rebuild switch --flake .

# One-liner update
sudo nixos-rebuild switch --recreate-lock-file --flake .
```

### **Home Manager Updates**
```bash
# Apply Home Manager changes (with notifications)
apply-home-manager

# Or manually
home-manager switch --flake .
```

### **Configuration Management**
```bash
# Test configuration without switching
sudo nixos-rebuild test --flake .

# Build without applying
sudo nixos-rebuild build --flake .

# View generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## 🎯 Customization Guide

### **Adding Packages**
- **System-wide**: Edit relevant module in `modules/programs/`
- **User-specific**: Add to `home.packages` in `modules/home/jc.nix`
- **Development tools**: Modify `modules/programs/development.nix`

### **Custom Scripts**
- **Create new script**: Add to `modules/home/scripts/script-name.nix`
- **Import in Home Manager**: Add import to `modules/home/jc.nix` let section
- **Include in packages**: Add script variable to `home.packages`

### **Desktop Customization**
- **Hyprland config**: Edit `modules/home/.config/hypr/hyprland.conf`
- **Waybar styling**: Modify `modules/home/.config/waybar/style.css`
- **Lock screens**: Configure via Home Manager in `jc.nix`

### **Power Management**
- **TLP settings**: Adjust in `modules/programs/development.nix`
- **Battery thresholds**: Modify charge limits for battery health
- **Performance profiles**: Customize AC vs battery behavior

## 🎮 Keybindings & Usage

### **Window Management** (Super/Win key as modifier)
- `Super + Enter`: Open terminal
- `Super + D`: Application launcher
- `Super + L`: Lock screen (default Hyprlock)
- `Super + Shift + L`: Lock screen menu (choose locker)
- `Super + E`: File manager
- `Super + Shift + Q`: Close window

### **System Controls**
- `Super + Shift + H`: Apply Home Manager configuration
- `Ctrl + Alt + Delete`: Graceful shutdown
- `Ctrl + Alt + R`: Graceful reboot
- `XF86 Keys`: Volume/brightness with notifications

### **Custom Commands**
- `lock-screen [hyprlock|swaylock|menu]`: Lock screen options
- `graceful-shutdown [shutdown|reboot]`: Smart system shutdown
- `volume-control [up|down|mute]`: Audio control with notifications
- `brightness-control [up|down]`: Display brightness with notifications
- `apply-home-manager`: Update Home Manager with notifications
- `lxc-gui`: LXC container management interface

## 📈 Recent Improvements

### **Script Modularization** (Latest)
- **Separated inline scripts**: Moved all shell scripts to individual `.nix` files
- **Better maintainability**: Each script in `modules/home/scripts/` for easier editing
- **Cleaner configuration**: Reduced main `jc.nix` file complexity by 250+ lines

### **Power Management Upgrade**
- **Replaced auto-cpufreq**: Switched to native TLP + thermald solution
- **Battery health protection**: Automatic 40-80% charging threshold management
- **Performance optimization**: Intelligent AC vs battery power profiles

### **Lock Screen Enhancement**
- **Dual lock screen support**: Both Hyprlock and Swaylock Effects via Home Manager
- **Interactive selection**: Menu-driven lock screen choice with Wofi integration
- **Home Manager integration**: Native configuration management for both lockers

## 📋 Troubleshooting

### **Common Issues**
- **Audio problems**: Check PipeWire status with `wpctl status`
- **Display scaling**: Verify Hyprland monitor configuration in `hyprland.conf`
- **Script permissions**: Ensure scripts are executable via Home Manager rebuild

### **Logs & Debugging**
```bash
# System logs
journalctl -f

# Home Manager logs
home-manager switch --flake . --verbose

# Hyprland logs
journalctl --user -f -u hyprland
```

## � System Specifications

- **Target NixOS Version**: 25.05 (stable channel)
- **Package Manager**: Nix with flakes enabled
- **Window Manager**: Hyprland on Wayland
- **Theme**: Adwaita with custom Waybar styling
- **Locale**: Vietnamese with US keyboard layout

---

## 🤝 Contributing

This configuration serves as a comprehensive example of modern NixOS setup. Feel free to:
- Fork and adapt for your hardware/preferences
- Submit improvements via pull requests
- Report issues or suggest enhancements
- Use as a learning resource for NixOS/Home Manager

## 📄 License

This configuration is provided as-is for educational and personal use. Individual software components retain their respective licenses.
