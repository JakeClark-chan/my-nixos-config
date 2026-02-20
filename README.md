# My NixOS Configuration

A comprehensive, modular NixOS configuration with Nix flakes, featuring Hyprland Wayland compositor, integrated Home Manager, advanced power management with TLP, custom Plymouth boot theme, and Nix-based automation scripts for a seamless desktop experience.

## 🏗️ Architecture Overview

This is a modular NixOS flake configuration with integrated Home Manager for user-level packages and dotfiles. The system is designed around Hyprland (Wayland compositor) with custom Nix-based scripts, external config files, and power management optimizations.

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
├── docs/                      # Documentation and reference files
│   ├── STRUCTURE.md           # Project structure reference
│   ├── incus-setup.md         # Incus container setup guide
│   └── lxc-inst.md            # LXC installation guide
└── modules/
    ├── core/                  # Essential system components
    │   ├── default.nix        # Auto-imports core modules
    │   ├── boot.nix           # Systemd-boot configuration
    │   ├── hardware.nix       # Hardware support, firmware, GPU, kernel config
    │   └── nix.nix            # Nix daemon settings, flakes, garbage collection
    ├── desktop/               # Window manager configurations
    │   ├── default.nix        # Auto-imports desktop modules
    │   ├── general.nix        # Common desktop services (XDG portal, polkit, Thunar, fonts)
    │   └── hyprland.nix       # Hyprland system-level setup (greetd, packages, session vars)
    ├── fonts/                 # Custom font files
    │   └── hsr-zh-cn.ttf      # Chinese font support
    ├── home/                  # Home Manager user configurations
    │   ├── jc.nix             # Main user config importing sub-modules
    │   ├── jc/                # User-specific configurations
    │   │   ├── default.nix    # Auto-imports user modules
    │   │   ├── packages.nix   # User packages with custom script imports
    │   │   ├── programs.nix   # Program configs (git, kitty, hyprlock, neovim, direnv)
    │   │   ├── hyprland.nix   # Full Hyprland WM config (keybinds, animations, submaps)
    │   │   ├── services.nix   # User services (placeholder)
    │   │   ├── files.nix      # Dotfiles, XDG config, environment variables
    │   │   └── launchers.nix  # Desktop entries for custom scripts
    │   ├── .config/           # External application configuration files
    │   │   ├── flameshot/     # Flameshot screenshot tool config
    │   │   ├── hypr/          # Hyprland/Hyprlock/Hyprpaper configs (legacy)
    │   │   ├── kitty/         # Kitty terminal config
    │   │   ├── starship.toml  # Starship prompt configuration
    │   │   ├── swaync/        # SwayNC notification daemon config
    │   │   └── waybar/        # Waybar status bar config and style
    │   ├── nvim/              # Neovim configuration
    │   │   └── init.lua       # Lua configuration
    │   └── scripts/           # Custom Nix-based shell scripts
    │       ├── apply-home-manager.nix  # HM updates with notifications
    │       ├── brightness-control.nix  # Display brightness control
    │       ├── graceful-shutdown.nix   # Smart shutdown/reboot
    │       ├── lock-screen.nix         # Screen locking utilities
    │       ├── lxc-gui.nix            # LXC/Incus container management GUI
    │       ├── volume-control.nix      # Audio volume control
    │       ├── change-wallpaper.nix    # Dynamic wallpaper switching
    │       ├── hdmi-control.nix        # External display management
    │       └── hyprland-keybinds.nix   # Keybinding reference
    ├── programs/              # System-wide programs
    │   ├── default.nix        # Auto-imports program modules
    │   ├── cli.nix            # Command-line tools, shell, and utilities
    │   ├── development.nix    # Dev tools, languages, containers, TLP power mgmt
    │   ├── fonts.nix          # Font packages and configuration
    │   └── nvidia-autooffload.nix  # NVIDIA PRIME offloading (unused - dGPU disabled)
    ├── services/              # System services
    │   ├── default.nix        # Auto-imports service modules
    │   ├── audio.nix          # PipeWire audio stack
    │   ├── channels.nix       # NixOS unstable channel auto-setup
    │   ├── network.nix        # NetworkManager, nftables, firewall, host entries
    │   └── virtualization.nix # Docker, Incus, Waydroid, nix-ld
    ├── settings/              # Shared configuration constants
    │   ├── default.nix        # Auto-imports settings modules
    │   ├── system-settings.nix   # User info, hostname, hardware config
    │   ├── desktop-settings.nix  # Hyprland config, fonts, theming
    │   ├── home-settings.nix     # Shell aliases, git config, npm config
    │   ├── locale.nix            # Timezone, language + Fcitx5 input method
    │   ├── memory.nix            # Swap and ZRAM configuration
    │   ├── journald.nix          # Systemd journal settings
    │   ├── plymouth.nix          # Boot splash screen with custom theme
    │   └── plymouth-themes/      # Custom Plymouth theme assets
    │       └── my-theme/         # Custom boot animation theme
    └── users/
        └── jc.nix             # User account, groups, Zsh + Starship config
```

## 🚀 Key Features

### **Flake-Based Architecture**
- **Modular Design**: Clean separation with auto-importing `default.nix` files
- **Reproducible Builds**: Pinned nixpkgs-unstable with flake lock
- **Home Manager Integration**: Fully integrated user-level configuration management
- **Settings Pattern**: Shared constants across system/desktop/home configurations
- **External Package Integration**: PrismLauncher Cracked via flake inputs

### **Desktop Environment**
- **Hyprland Wayland Compositor**: Modern tiling window manager with smooth animations and power-saving optimizations
- **Waybar Status Bar**: Customizable status bar with external JSON/CSS configuration
- **Greetd Login Manager**: Auto-login display manager with Hyprland session
- **SwayNC Notifications**: External JSON config with widget customization
- **Hyprlock Screen Locking**: Native Hyprland lock screen with date/time display
- **Hyprsunset Night Light**: 3100K color temperature for eye comfort
- **SWWW Wallpaper Daemon**: Dynamic wallpaper switching with Wayland support
- **Wofi App Launcher**: Lightweight dmenu-style application launcher
- **Cliphist Clipboard**: Clipboard history manager with Wofi integration
- **Custom Scripts**: Nix-based automation with desktop launcher integration

### **Power Management & Hardware**
- **TLP Power Management**: Intelligent AC/battery profiles with detailed tuning
- **dGPU Disabled**: NVIDIA GPU completely disabled via blacklist for maximum battery life
- **Intel Graphics Only**: iHD VAAPI driver for hardware video acceleration
- **Battery Health**: 80% charge limit for ASUS laptops via udev rule
- **ZRAM Compression**: 120% of RAM with zstd algorithm
- **Platform Profiles**: Performance on AC, quiet mode on battery
- **CPU Tuning**: Performance governor on AC, powersave at max 60% on battery with boost disabled
- **VFR Enabled**: Variable frame rate in Hyprland to reduce GPU usage when idle

### **Development Environment**
- **Multi-Language Support**: Python 3 (with uv), Node.js, Java (Temurin), Rust (cargo), C/C++ (gcc)
- **Container Ecosystem**: Docker + Incus with custom GUI management and Waydroid (Android)
- **Modern Editors**: VS Code (primary), Neovim with Lua config + LSP (Pyright, nil)
- **Version Control**: Git with SSH agent and credential management
- **AI Integration**: Ollama (qwen3:1.7b) with Next.js LLM UI, Gemini CLI
- **Direnv**: Automatic environment loading with nix-direnv integration

## 📦 Software Stack

### **Desktop & Multimedia**
- **Compositor**: Hyprland with native Wayland support and dwindle/master tiling
- **Status Bar**: Waybar with custom config and CSS styling
- **Terminal**: Kitty with Cascadia Code Nerd Font (14pt) and translucent background
- **File Manager**: Thunar with GVFS, volume management, and archive plugin
- **Media Players**: VLC (universal), playerctl for media key integration
- **Image Viewer**: gThumb with basic editing capabilities
- **Screenshot Tools**: Flameshot (GUI with config), grim/slurp (Wayland-native)
- **Document Reader**: Okular for PDF/EPUB with annotation support
- **Office Suite**: OnlyOffice Desktop Editors

### **Development & Programming**
- **Code Editors**: VS Code (primary), Neovim with Lua config + LSP, GEdit (fallback)
- **Languages**: Python 3 (with uv package manager), Node.js, Java (Temurin JDK), Rust (cargo), C/C++ (gcc)
- **Version Control**: Git with credential helper and SSH agent integration
- **Containers**: Docker with Compose (custom data dir), Incus for system containers with preseed config
- **Virtualization**: Waydroid for Android apps, nix-ld for FHS compatibility, steam-run for legacy apps
- **Browsers**: Brave (primary), Tor Browser (privacy), Zen Browser (available via flake, currently disabled)
- **Gaming**: PrismLauncher Cracked for Minecraft, with Java runtime

### **System Tools & Utilities**
- **Shell**: Zsh with Starship prompt (custom config), autosuggestions, syntax highlighting, and completion
- **System Monitor**: Mission Center (htop alternative), htop, fastfetch
- **Audio System**: PipeWire with ALSA/PulseAudio compatibility
- **Input Methods**: Fcitx5 with Bamboo engine and Nord theme for Vietnamese/English
- **Power Management**: TLP with platform profiles, optimized laptop configs
- **Package Management**: Nix with flakes, Home Manager for user configs
- **AI/ML Tools**: Ollama (qwen3:1.7b) for local LLMs, Gemini CLI, n8n (available)
- **Entertainment**: ani-cli for anime streaming, yt-dlp for video downloads
- **Disk Tools**: ncdu for disk analysis, ntfs3g and exfat filesystem support
- **Archive Tools**: zip, unzip, rar, unrar, p7zip
- **Network Tools**: wget, curl, OpenVPN
- **Environment Management**: Direnv with nix-direnv for automatic project environments

## 🔧 System Configuration

### **Hardware Support**
- **Kernel**: Stable LTS Linux with all redistributable firmware enabled
- **Display**: 1920x1080@144Hz primary monitor (eDP-1) at 1x scaling
- **Graphics**: Intel-only (NVIDIA dGPU disabled via kernel blacklist for power savings)
- **Video Acceleration**: Intel Media Driver (iHD) with VAAPI support
- **Audio**: PipeWire audio server with ALSA/PulseAudio compatibility layer
- **Input**: Multi-language support via Fcitx5 with Vietnamese locale integration
- **Bluetooth**: Disabled
- **WiFi**: Realtek USB driver (rtl8xxxu) with mode-switching support

### **Power & Performance**
- **TLP Power Management**: Laptop-optimized profiles
  - AC Power: Performance governor, full CPU, performance platform profile
  - Battery: Powersave governor, max 60% CPU, quiet platform profile, boost disabled
  - Deep sleep on battery, s2idle on AC
  - GPU frequency capped at 800MHz on battery
  - USB autosuspend with deny-list for WiFi adapter and mouse
- **dGPU Power Savings**: NVIDIA GPU completely blacklisted and removed via udev rules
- **Battery Health**: 80% charge limit for ASUS laptops
- **Memory Management**:
  - ZRAM: 120% of RAM with zstd compression (priority 100)
  - Swap: 6GB swapfile for hibernation support (priority 10)

### **Custom Automation Scripts**
All scripts follow the `writeShellScriptBin` pattern with full binary paths:

- **`apply-home-manager`**: HM configuration updates with swaync notifications
- **`volume-control`**: WirePlumber integration with visual feedback
- **`brightness-control`**: Intel backlight control with percentage display
- **`lock-screen`**: Hyprlock integration with menu selection
- **`graceful-shutdown`**: Smart application closure before system shutdown/reboot
- **`lxc-gui`**: Python/Tkinter GUI for Incus container management
- **`change-wallpaper`**: Dynamic wallpaper switching with SWWW and Hyprland integration
- **`hdmi-control`**: External display management utilities
- **`hyprland-keybinds`**: Display Hyprland keybinding reference

## 🌐 Network & Connectivity

- **Hostname**: JakeClark-Sep21st with Asia/Ho_Chi_Minh timezone
- **Network Stack**: NetworkManager with nftables firewall backend
- **Firewall**: Enabled (TCP: 80, 443 | UDP: 53)
- **SSH**: Client-side SSH agent enabled, server disabled for security
- **Container Networking**: Incus bridge networking (lxdbr0, 10.0.0.1/24) with NAT and DHCP
- **Development Services**: Ollama (localhost:11434), Next.js LLM UI for AI workflows
- **DNS**: Custom host entry (target → 10.0.0.100)

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
- **Incus Containers**: Storage at `/home/jc/incus/storage-pools/default`, GUI via `lxc-gui`
- **Docker**: Custom data directory at `/home/jc/docker`
- **Waydroid (Android)**:
   * Init with `sudo waydroid init -f -s GAPPS -v https://ota.waydro.id/vendor -c https://ota.waydro.id/system` then `sudo waydroid start`

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
- **External configs**: Place in `modules/home/.config/` and reference in `files.nix` via `xdg.configFile`
- **Hyprland settings**: Edit `modules/home/jc/hyprland.nix` for keybinds and WM config
- **Desktop constants**: Edit `modules/settings/desktop-settings.nix` for fonts, themes, scaling
- **Application configs**: Add to `xdg.configFile` in `modules/home/jc/files.nix`

### **Settings Management**
- **System constants**: Edit `modules/settings/system-settings.nix` (hostname, user, hardware)
- **Desktop theming**: Modify `modules/settings/desktop-settings.nix` (fonts, themes, cursor)
- **Home environment**: Update `modules/settings/home-settings.nix` (aliases, git, npm)

## 🎮 Keybindings & Usage

### **Window Management** (Super/Win key as modifier)
- `Super + Return`: Open terminal (Kitty)
- `Super + D`: Application launcher (Wofi)
- `Super + L`: Lock screen (Hyprlock)
- `Super + Shift + L`: Lock screen menu (choose locker)
- `Super + E`: File manager (Thunar)
- `Super + Shift + Q`: Close window
- `Super + Space`: Toggle floating
- `Super + F`: Fullscreen
- `Super + T`: Toggle dwindle/master layout
- `Super + H`: Toggle split orientation (dwindle)
- `Super + R`: Enter resize mode (arrows to resize, Escape to exit)

### **Workspace Management**
- `Super + 1-0`: Switch to workspace 1-10
- `Super + Shift + 1-0`: Move window to workspace 1-10
- `Super + Ctrl + Left/Right`: Navigate workspaces
- `Super + S`: Toggle scratchpad
- `Super + Shift + S`: Move to scratchpad

### **Display Management**
- `Super + P`: Enter display submap (then press key to configure HDMI)
  - `` ` ``: Mirror laptop to HDMI
  - `1-0`: Bind workspace to HDMI display
  - `Escape`: Exit display submap
- `Super + Shift + P`: Disable all HDMI monitors

### **System Controls**
- `Super + Shift + H`: Apply Home Manager configuration
- `Super + Shift + /`: Show keybinding reference
- `Ctrl + Alt + Delete`: Graceful shutdown
- `Ctrl + Alt + Shift + Delete`: Graceful reboot
- `Super + Shift + E`: Exit Hyprland
- `Super + N`: Toggle night light (Hyprsunset)
- `Super + M`: Toggle Waybar
- `XF86 Keys`: Volume/brightness with notifications

### **Wallpaper & Clipboard**
- `Super + W`: Change wallpaper (picker)
- `Super + Shift + W`: Random wallpaper
- `Super + V`: Clipboard history (via cliphist + Wofi)

### **Screenshots**
- `Print`: Flameshot GUI capture
- `Super + Print`: Flameshot full screen capture

### **Custom Commands**
- `apply-home-manager`: Update Home Manager configuration with swaync notifications
- `lock-screen`: Activate Hyprlock screen locker
- `graceful-shutdown [shutdown|reboot]`: Smart system shutdown with application cleanup
- `volume-control [up|down|mute]`: WirePlumber audio control with visual feedback
- `brightness-control [up|down]`: Intel backlight control with percentage display
- `lxc-gui`: Python/Tkinter GUI for Incus container management
- `change-wallpaper`: Dynamic wallpaper switching utility
- `hdmi-control`: External display management tools
- `hyprland-keybinds`: Display Hyprland keybinding reference

## 📈 Recent Improvements

### **Hyprland Configuration Overhaul** (Latest)
- **Home Manager Hyprland**: Full WM config now managed via `modules/home/jc/hyprland.nix`
- **Power-Saving Optimizations**: Disabled blur and shadows, enabled VFR for battery life
- **Display Submaps**: Advanced HDMI management with mirror/extend modes per-workspace
- **SWWW Integration**: Replaced hyprpaper with swww for dynamic wallpaper transitions
- **Waybar Integration**: External config with custom CSS styling

### **External Configuration Files**
- **Config Directory**: `modules/home/.config/` with Flameshot, Waybar, Starship, SwayNC configs
- **XDG Integration**: Managed via `xdg.configFile` in `files.nix`
- **Starship Prompt**: Custom configuration with rich prompt styling

### **Virtualization Migration**
- **Incus**: Migrated from LXD to Incus with preseed configuration
- **Bridge Networking**: lxdbr0 with 10.0.0.1/24, NAT, DHCP
- **Custom Storage**: Dir-backed storage pool at `/home/jc/incus/storage-pools/default`
- **Waydroid**: Android emulation via Wayland container

### **Graphics & Power Overhaul**
- **dGPU Disabled**: NVIDIA GPU completely blacklisted for maximum battery savings
- **Intel-Only Graphics**: Using iHD VAAPI driver for hardware acceleration
- **ZRAM Upgrade**: 120% RAM with zstd compression (previously 30% with LZ4)
- **TLP Fine-Tuning**: Comprehensive AC/battery profiles with platform profiles, GPU capping, deep sleep

### **Custom Plymouth Theme**
- **Boot Animation**: Custom `my-theme` Plymouth theme built from local assets
- **Silent Boot**: Quiet kernel parameters with splash screen

### **Channel Management**
- **Auto-Setup Service**: Systemd service ensures unstable channel is always available
- **User Channels**: Auto-configures nixpkgs channel for users on login

## 📋 Troubleshooting

### **Common Issues**
- **Audio problems**: Check PipeWire status with `wpctl status`
- **Display scaling**: Verify Hyprland monitor configuration in `modules/home/jc/hyprland.nix`
- **Script permissions**: Ensure scripts are executable via Home Manager rebuild
- **Docker issues**: Data stored at `/home/jc/docker`, check with `docker info`
- **Incus issues**: Check bridge with `incus network list`, storage with `incus storage list`

### **Logs & Debugging**
```bash
# System logs
journalctl -f

# Home Manager logs
home-manager switch --flake . --verbose

# Hyprland logs
journalctl --user -f -u hyprland

# TLP status
sudo tlp-stat -c

# Incus status
incus list
```

## 🖥️ System Specifications

- **NixOS Version**: 25.05 (state version) with nixos-unstable rolling release
- **Package Manager**: Nix 2.x with flakes and unified CLI enabled
- **Display Protocol**: Wayland with Hyprland compositor
- **Login Manager**: greetd with auto-login to Hyprland session
- **Theme System**: Adwaita base theme with GTK and Qt integration
- **Localization**: Vietnamese (vi_VN) with English (en_US.UTF-8) system locale
- **Input Methods**: Fcitx5 with Bamboo engine and Nord theme for Vietnamese typing
- **Font Stack**: Cascadia Code NF (monospace), SDK_SC_Web (sans-serif/UI), Noto CJK (multilingual)
- **Boot**: Systemd-boot with custom Plymouth theme and quiet splash

---

## 🤝 Contributing

This configuration serves as a comprehensive example of modern NixOS setup. Feel free to:
- Fork and adapt for your hardware/preferences
- Submit improvements via pull requests
- Report issues or suggest enhancements
- Use as a learning resource for NixOS/Home Manager

## 📄 License

This configuration is provided as-is for educational and personal use. Individual software components retain their respective licenses.
