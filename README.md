# My NixOS Configuration

A comprehensive, modular NixOS configuration with Nix flakes, featuring Hyprland Wayland compositor, integrated Home Manager, advanced power management with TLP, and custom Nix-based automation scripts for a seamless desktop experience.

## 🏗️ Architecture Overview

This is a modular NixOS flake configuration with integrated Home Manager for user-level packages and dotfiles. The system is designed around Hyprland (Wayland compositor) with custom Nix-based scripts and power management optimizations.

### Core Structure
- **`flake.nix`**: Main entry point with inputs (nixpkgs-unstable, home-manager, zen-browser, prismlauncher-cracked)
- **`configuration.nix`**: System-level imports and module organization
- **`modules/`**: Modular configuration organized by function
- **Settings pattern**: `modules/settings/{system,desktop,home}-settings.nix` contain shared constants

```
├── configuration.nix           # Main system configuration entry point
├── flake.nix                  # Flake inputs and outputs with Home Manager integration
├── hardware-configuration.nix # Hardware-specific settings (auto-generated)
├── backgrounds/               # Wallpaper collection
└── modules/
    ├── core/                  # Essential system components
    │   ├── boot.nix           # Systemd-boot configuration
    │   ├── hardware.nix       # Hardware support & firmware
    │   └── nix.nix            # Nix daemon settings, flakes, garbage collection
    ├── desktop/               # Window manager configurations
    │   ├── general.nix        # Common desktop services (greetd, polkit)
    │   └── hyprland.nix       # Hyprland Wayland compositor
    ├── fonts/                 # Custom font files
    │   └── hsr-zh-cn.ttf      # Chinese font support
    ├── home/                  # Home Manager user configurations
    │   ├── jc.nix             # Main user config importing sub-modules
    │   ├── jc/                # User-specific configurations
    │   │   ├── packages.nix   # User packages with custom script imports
    │   │   ├── programs.nix   # Program configs (git, kitty, hyprlock, etc.)
    │   │   ├── services.nix   # User services (swaync - external config)
    │   │   ├── files.nix      # Dotfiles and environment variables
    │   │   ├── launchers.nix  # Desktop entries for custom scripts
    │   │   └── config/        # Application configuration files
    │   │       └── swaync/    # SwayNC notification daemon config
    │   ├── nvim/              # Neovim configuration
    │   │   └── init.lua       # Lua configuration
    │   └── scripts/           # Custom Nix-based shell scripts
    │       ├── apply-home-manager.nix  # HM updates with notifications
    │       ├── brightness-control.nix  # Display brightness control
    │       ├── graceful-shutdown.nix   # Smart shutdown/reboot
    │       ├── lock-screen.nix         # Screen locking utilities
    │       ├── lxc-gui.nix            # LXC container management GUI
    │       ├── volume-control.nix      # Audio volume control
    │       ├── change-wallpaper.nix    # Dynamic wallpaper switching
    │       ├── hdmi-control.nix        # External display management
    │       └── hyprland-keybinds.nix   # Keybinding reference
    ├── programs/              # System-wide programs
    │   ├── cli.nix            # Command-line tools and utilities
    │   ├── development.nix    # Dev tools, languages, containers + TLP power mgmt
    │   ├── fonts.nix          # Font packages and configuration
    │   └── nvidia-autooffload.nix  # NVIDIA PRIME offloading
    ├── services/              # System services
    │   ├── audio.nix          # PipeWire audio stack
    │   ├── network.nix        # NetworkManager, firewall, host entries
    │   └── virtualization.nix # Docker, LXD, nix-ld for FHS compatibility
    ├── settings/              # Shared configuration constants
    │   ├── system-settings.nix   # User info, hostname, hardware config
    │   ├── desktop-settings.nix  # Hyprland config, wallpapers, theming
    │   ├── home-settings.nix     # Shell aliases, git config
    │   ├── locale.nix            # Timezone, language + Fcitx5 input
    │   ├── memory.nix            # Swap and zram configuration
    │   ├── journald.nix          # Systemd journal settings
    │   └── plymouth.nix          # Boot splash screen
    └── users/
        └── jc.nix             # User account definition and groups
```

## 🚀 Key Features

### **Flake-Based Architecture**
- **Modular Design**: Clean separation with auto-importing `default.nix` files
- **Reproducible Builds**: Pinned nixpkgs-unstable with flake lock
- **Home Manager Integration**: Fully integrated user-level configuration management
- **Settings Pattern**: Shared constants across system/desktop/home configurations
- **External Package Integration**: Zen Browser, PrismLauncher Cracked via flake inputs

### **Desktop Environment**
- **Hyprland Wayland Compositor**: Modern tiling window manager with smooth animations
- **Greetd Login Manager**: Lightweight display manager with TTY fallback
- **SwayNC Notifications**: External JSON config with widget customization
- **Hyprlock Screen Locking**: Native Hyprland lock screen integration
- **Custom Scripts**: Nix-based automation with desktop launcher integration

### **Power Management & Hardware**
- **TLP Power Management**: Intelligent AC/battery profiles replacing auto-cpufreq
- **Intel Thermald**: CPU thermal management for laptops
- **NVIDIA PRIME**: Hybrid graphics with proper bus configuration
- **Battery Health**: 40-80% charging thresholds for longevity
- **ZRAM Compression**: 30% memory compression with LZ4 algorithm

### **Development Environment**
- **Multi-Language Support**: Python 3, Node.js, Java (Temurin), with uv for Python environments
- **Container Ecosystem**: Docker + LXD with custom GUI management (lxc-gui)
- **Modern Editors**: VS Code, Neovim with Lua configuration
- **Version Control**: Git with SSH agent and credential management
- **AI Integration**: Ollama for local LLM, Gemini CLI tools

## 📦 Software Stack

### **Desktop & Multimedia**
- **Compositor**: Hyprland with native Wayland support and tiling
- **Terminal**: Kitty with Cascadia Code Nerd Font and ligature support
- **File Manager**: Thunar with GVFS integration for network/removable media
- **Media Players**: VLC (universal), mpv for lightweight playback
- **Image Viewer**: gThumb with basic editing capabilities
- **Screenshot Tools**: Flameshot (GUI), grim/slurp (Wayland-native)
- **Document Reader**: Okular for PDF/EPUB with annotation support

### **Development & Programming**
- **Code Editors**: VS Code (primary), Neovim with Lua config, GEdit (fallback)
- **Languages**: Python 3 (with uv package manager), Node.js, Java (Temurin JDK)
- **Version Control**: Git with credential helper and SSH agent integration
- **Containers**: Docker with Compose, LXD for system containers
- **Virtualization**: nix-ld for FHS compatibility, steam-run for legacy apps
- **Browsers**: Zen Browser (privacy-focused), built from flake input
- **Gaming**: PrismLauncher Cracked for Minecraft, with Java runtime

### **System Tools & Utilities**
- **Shell**: Zsh with Starship prompt and completion
- **System Monitor**: Mission Center (htop alternative), nvtop for GPU monitoring
- **Audio System**: PipeWire with ALSA/PulseAudio compatibility
- **Input Methods**: Fcitx5 for Vietnamese/English with intelligent switching
- **Power Management**: TLP with thermald, optimized laptop profiles
- **Package Management**: Nix with flakes, Home Manager for user configs
- **AI/ML Tools**: Ollama for local LLMs, n8n for workflow automation

## 🔧 System Configuration

### **Hardware Support**
- **Kernel**: Latest stable Linux with all redistributable firmware enabled
- **Display**: 1920x1080@144Hz primary monitor (eDP-1) with 1.2x scaling
- **Graphics**: NVIDIA PRIME hybrid graphics (Intel: PCI:0@0:2:0, NVIDIA: PCI:1@0:0:0)
- **Audio**: PipeWire audio server with ALSA/PulseAudio compatibility layer
- **Input**: Multi-language support via Fcitx5 with Vietnamese locale integration

### **Power & Performance**
- **TLP Power Management**: Laptop-optimized profiles
  - AC Power: Performance mode with full CPU utilization
  - Battery: Power-saving mode with 20% CPU limit
  - Battery Health: 40-80% charging thresholds for longevity
- **Thermal Control**: Intel thermald for proactive thermal management
- **Memory Management**: 
  - ZRAM: 30% of RAM with LZ4 compression
  - Swap: Additional swapfile for hibernation support

### **Custom Automation Scripts**
All scripts follow the `writeShellScriptBin` pattern with full binary paths:

- **`apply-home-manager`**: HM configuration updates with swaync notifications
- **`volume-control`**: WirePlumber integration with visual feedback
- **`brightness-control`**: Intel backlight control with percentage display
- **`lock-screen`**: Hyprlock integration with menu selection
- **`graceful-shutdown`**: Smart application closure before system shutdown
- **`lxc-gui`**: Python/Tkinter GUI for LXD container management
- **`change-wallpaper`**: Dynamic wallpaper switching with Hyprland integration
- **`hdmi-control`**: External display management utilities

## 🌐 Network & Connectivity

- **Hostname**: JakeClark-Sep21st with Asia/Ho_Chi_Minh timezone
- **Network Stack**: NetworkManager with WiFi power management and auto-connect
- **Firewall**: Enabled with custom host entries for development
- **SSH**: Client-side SSH agent enabled, server disabled for security
- **Container Networking**: LXD bridge networking with GUI management interface
- **Development Services**: Ollama (localhost:11434), Next.js LLM UI for AI workflows

## 🛠️ Installation & Usage

### **Initial Setup**
1. **Clone Repository**:
   ```bash
   git clone https://github.com/JakeClark38a/my-nixos-config.git nixos-config
   cd nixos-config
   ```

2. **Prepare Hardware Configuration**:
   ```
   sudo nix-generate-config --root <rootFolder, if in live environment, use /mnt>
   ```

   Then replace `hardware-configuration.nix` inside `<root-file-above>/etc/nixos/hardware-configuration.nix` with `hardware-configuration.nix` inside this folder.

3. **Test Configuration**:
   ```bash
   sudo nixos-rebuild test --flake .
   ```

4. **Apply Configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

   To apply at next boot:
   ```bash
   sudo nixos-rebuild boot --flake .
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
- **System-wide**: Edit appropriate module in `modules/programs/` (cli.nix, development.nix, fonts.nix)
- **User-specific**: Add to `home.packages` in `modules/home/jc/packages.nix`
- **External packages**: Add flake input to `flake.nix` and reference in modules

### **Custom Scripts**
- **Create script**: Add `modules/home/scripts/script-name.nix` using `writeShellScriptBin` pattern
- **Import script**: Add to `let` section in `modules/home/jc/packages.nix` with `callPackage`
- **Include in packages**: Add script variable to `home.packages` list
- **Desktop launcher**: Add entry to `modules/home/jc/launchers.nix` for GUI access

### **Configuration Files**
- **External configs**: Place in `modules/home/jc/config/` and reference in `files.nix`
- **Hyprland settings**: Edit via `desktop-settings.nix` for shared constants
- **Application configs**: Add to `xdg.configFile` in `modules/home/jc/files.nix`

### **Settings Management**
- **System constants**: Edit `modules/settings/system-settings.nix` (hostname, user, hardware)
- **Desktop theming**: Modify `modules/settings/desktop-settings.nix` (Hyprland, fonts, themes)
- **Home environment**: Update `modules/settings/home-settings.nix` (aliases, tools, git)

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
- `apply-home-manager`: Update Home Manager configuration with swaync notifications
- `lock-screen`: Activate Hyprlock screen locker
- `graceful-shutdown [shutdown|reboot]`: Smart system shutdown with application cleanup
- `volume-control [up|down|mute]`: WirePlumber audio control with visual feedback
- `brightness-control [up|down]`: Intel backlight control with percentage display
- `lxc-gui`: Python/Tkinter GUI for LXD container management
- `change-wallpaper`: Dynamic wallpaper switching utility
- `hdmi-control`: External display management tools
- `hyprland-keybinds`: Display Hyprland keybinding reference

## 📈 Recent Improvements

### **Configuration Externalization** (Latest)
- **SwayNC Config**: Moved notification settings from inline Nix to external JSON file
- **Modular Structure**: Separated all configuration files to individual modules
- **Settings Pattern**: Implemented shared constants via system/desktop/home-settings.nix
- **Home Manager Integration**: Full flake-based user configuration management

### **Script Architecture Overhaul**
- **Nix-based Scripts**: All shell scripts converted to `writeShellScriptBin` pattern
- **Desktop Integration**: Custom scripts accessible via application launcher
- **Notification System**: Integrated swaync/notify-send for user feedback
- **Modular Design**: Each script in separate `.nix` file for maintainability

### **Power Management Optimization**
- **TLP Implementation**: Replaced auto-cpufreq with native TLP + thermald solution
- **Battery Longevity**: 40-80% charging thresholds for battery health protection
- **Performance Profiles**: Intelligent AC vs battery power management
- **Thermal Control**: Intel thermald integration for proactive cooling

### **Development Environment Enhancement**
- **Container Ecosystem**: Docker + LXD with custom Python GUI management
- **Multi-Language Support**: Python (uv), Node.js, Java with modern tooling
- **External Package Integration**: Zen Browser, PrismLauncher via flake inputs
- **AI Integration**: Ollama + Next.js LLM UI for local AI workflows

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

## 🖥️ System Specifications

- **NixOS Channel**: nixos-unstable (rolling release via flake inputs)
- **Package Manager**: Nix 2.x with flakes and unified CLI enabled
- **Display Protocol**: Wayland with Hyprland compositor
- **Login Manager**: greetd with TTY1 greeter and Hyprland session
- **Theme System**: Adwaita base theme with custom font configuration
- **Localization**: Vietnamese (vi_VN) with English (en_US.UTF-8) system locale
- **Input Methods**: Fcitx5 with Bamboo engine for Vietnamese typing
- **Font Stack**: Cascadia Code NF (monospace), SDK_SC_Web (UI), Noto CJK (multilingual)

---

## 🤝 Contributing

This configuration serves as a comprehensive example of modern NixOS setup. Feel free to:
- Fork and adapt for your hardware/preferences
- Submit improvements via pull requests
- Report issues or suggest enhancements
- Use as a learning resource for NixOS/Home Manager

## 📄 License

This configuration is provided as-is for educational and personal use. Individual software components retain their respective licenses.
