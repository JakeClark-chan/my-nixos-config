# My NixOS Configuration

A comprehensive, modular NixOS configuration with Nix flakes, featuring Niri Wayland compositor, COSMIC desktop applications, integrated Home Manager, advanced power management with TLP, custom Plymouth boot theme, and Nix-based automation scripts for a seamless desktop experience.

## 🏗️ Architecture Overview

This is a modular NixOS flake configuration with integrated Home Manager for user-level packages and dotfiles. The system is designed around Niri (scrollable tiling Wayland compositor) with COSMIC desktop apps, custom Nix-based scripts, external config files, and power management optimizations.

### Core Structure
- **`flake.nix`**: Main entry point with inputs (nixos-25.11, home-manager, niri-flake, awww, zen-browser, prismlauncher-cracked)
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
    │   ├── boot.nix           # GRUB bootloader configuration
    │   ├── hardware.nix       # Hardware support, firmware, GPU, kernel config
    │   └── nix.nix            # Nix daemon settings, flakes, garbage collection
    ├── desktop/               # Window manager configurations
    │   ├── default.nix        # Auto-imports desktop modules
    │   ├── general.nix        # Common desktop services (XDG portal, polkit, Thunar, fonts)
    │   └── niri.nix           # Niri system-level setup (greetd, COSMIC apps, session vars)
    ├── fonts/                 # Custom font files
    │   └── hsr-zh-cn.ttf      # Chinese font support
    ├── home/                  # Home Manager user configurations
    │   ├── jc.nix             # Main user config importing sub-modules
    │   ├── jc/                # User-specific configurations
    │   │   ├── default.nix    # Auto-imports user modules
    │   │   ├── packages.nix   # User packages with custom script imports
    │   │   ├── programs.nix   # Program configs (git, kitty, neovim, direnv)
    │   │   ├── niri.nix       # Niri compositor config (loads config.kdl via niri-flake)
    │   │   ├── services.nix   # User services (placeholder)
    │   │   ├── files.nix      # Dotfiles, XDG config, environment variables
    │   │   └── launchers.nix  # Desktop entries for custom scripts
    │   ├── .config/           # External application configuration files
    │   │   ├── niri/          # Niri compositor config (config.kdl)
    │   │   ├── kitty/         # Kitty terminal config
    │   │   ├── starship.toml  # Starship prompt configuration
    │   │   ├── swaync/        # SwayNC notification daemon config
    │   │   └── waybar/        # Waybar status bar config and style
    │   ├── nvim/              # Neovim configuration
    │   │   └── init.lua       # Lua configuration
    │   └── scripts/           # Custom Nix-based shell scripts
    │       ├── apply-home-manager.nix  # HM updates with notifications
    │       ├── brightness-control.nix  # Display brightness control
    │       ├── graceful-shutdown.nix   # Smart shutdown/reboot (niri msg)
    │       ├── lock-screen.nix         # Screen locking (loginctl)
    │       ├── volume-control.nix      # Audio volume control
    │       └── change-wallpaper.nix    # Dynamic wallpaper switching (awww)
    ├── programs/              # System-wide programs
    │   ├── default.nix        # Auto-imports program modules
    │   ├── cli.nix            # Command-line tools, shell, and utilities
    │   ├── development.nix    # Dev tools, languages, containers, TLP power mgmt
    │   ├── fonts.nix          # Font packages and configuration
    │   └── nvidia-autooffload.nix  # NVIDIA PRIME offloading (unused - dGPU disabled)
    ├── services/              # System services
    │   ├── default.nix        # Auto-imports service modules
    │   ├── audio.nix          # PipeWire audio stack
    │   ├── channels.nix       # NixOS channel auto-setup
    │   ├── network.nix        # NetworkManager, nftables, firewall (disabled)
    │   └── virtualization.nix # Docker, Incus, Waydroid, nix-ld
    ├── settings/              # Shared configuration constants
    │   ├── default.nix        # Auto-imports settings modules
    │   ├── system-settings.nix   # User info, hostname, hardware config
    │   ├── desktop-settings.nix  # WM config (COSMIC apps), fonts, theming
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
- **Reproducible Builds**: Pinned NixOS 25.11 stable release
- **Home Manager Integration**: Fully integrated user-level configuration management
- **Settings Pattern**: Shared constants across system/desktop/home configurations
- **External Flake Inputs**: niri-flake (compositor), awww (wallpapers), Zen Browser, PrismLauncher

### **Desktop Environment**
- **Niri Wayland Compositor**: Scrollable tiling compositor with focus ring, custom animations, and power-saving defaults
- **COSMIC Applications**: cosmic-term (terminal), cosmic-files (file manager), cosmic-launcher (app launcher)
- **Waybar Status Bar**: Customizable status bar with external JSON/CSS configuration
- **Greetd Login Manager**: Auto-login display manager with niri-session
- **SwayNC Notifications**: External JSON config with widget customization
- **Wlsunset Night Light**: Color temperature management for eye comfort
- **Awww Wallpaper Daemon**: Dynamic wallpaper switching with animated transitions (successor to swww)
- **Wofi App Launcher**: Lightweight dmenu-style application launcher
- **Cliphist Clipboard**: Clipboard history manager with Wofi integration
- **XWayland Satellite**: X11 compatibility layer for legacy applications
- **Custom Scripts**: Nix-based automation with desktop launcher integration

### **Power Management & Hardware**
- **TLP Power Management**: Intelligent AC/battery profiles with detailed tuning
- **dGPU Disabled**: NVIDIA GPU completely disabled via blacklist for maximum battery life
- **Intel Graphics Only**: iHD VAAPI driver for hardware video acceleration
- **Battery Health**: 80% charge limit for ASUS laptops via udev rule
- **ZRAM Compression**: 120% of RAM with zstd algorithm
- **Platform Profiles**: Performance on AC, quiet mode on battery
- **CPU Tuning**: Performance governor on AC, powersave at max 60% on battery with boost disabled
- **Shadows Disabled**: Power-saving default in Niri config

### **Development Environment**
- **Multi-Language Support**: Python 3 (with uv), Node.js, Java (Temurin), Rust (cargo), C/C++ (gcc)
- **Container Ecosystem**: Docker + Incus with custom GUI management and Waydroid (Android)
- **Modern Editors**: Neovim with Lua config + LSP (Pyright, nil), GEdit (fallback)
- **Version Control**: Git with SSH agent and credential management
- **AI Integration**: Gemini CLI
- **Direnv**: Automatic environment loading with nix-direnv integration

## 📦 Software Stack

### **Desktop & Multimedia**
- **Compositor**: Niri with native Wayland support and scrollable tiling layout
- **Terminal**: COSMIC Terminal (primary), Kitty (fallback, Cascadia Code NF 14pt)
- **File Manager**: COSMIC Files (primary), Thunar with GVFS (fallback)
- **App Launcher**: COSMIC Launcher (primary), Wofi (dmenu-style)
- **Status Bar**: Waybar with custom config and CSS styling
- **Media Players**: VLC (universal), playerctl for media key integration
- **Image Viewer**: gThumb with basic editing capabilities
- **Screenshot Tools**: Niri built-in screenshots, grim/slurp (Wayland-native)
- **Document Reader**: Okular for PDF/EPUB with annotation support
- **Office Suite**: OnlyOffice Desktop Editors
- **Color Picker**: wl-color-picker (Wayland native)

### **Development & Programming**
- **Code Editors**: Neovim with Lua config + LSP, GEdit (fallback)
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
- **AI Tools**: Gemini CLI
- **Entertainment**: ani-cli for anime streaming, yt-dlp for video downloads
- **Disk Tools**: ncdu for disk analysis, ntfs3g and exfat filesystem support
- **Archive Tools**: zip, unzip, rar, unrar, p7zip
- **Network Tools**: wget, curl, OpenVPN
- **Environment Management**: Direnv with nix-direnv for automatic project environments

## 🔧 System Configuration

### **Hardware Support**
- **Kernel**: Stable LTS Linux with all redistributable firmware enabled
- **Display**: 1920x1080@144Hz primary monitor (eDP-1) at 1.25x scaling
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
- **`lock-screen`**: Screen locking via loginctl with menu selection
- **`graceful-shutdown`**: Smart application closure before system shutdown/reboot (uses `niri msg`)
- **`change-wallpaper`**: Dynamic wallpaper switching with awww transitions

## 🌐 Network & Connectivity

- **Hostname**: JakeClark-Sep21st with Asia/Ho_Chi_Minh timezone
- **Network Stack**: NetworkManager with nftables firewall backend
- **Firewall**: Disabled
- **SSH**: Client-side SSH agent enabled, server disabled for security
- **Container Networking**: Incus bridge networking (lxdbr0, 10.0.0.1/24) with NAT and DHCP
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
- **Incus Containers**: Storage at `/home/jc/incus/storage-pools/default`, managed via incus-ui-canonical
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
- **Niri settings**: Edit `modules/home/.config/niri/config.kdl` for keybinds and WM config
- **Desktop constants**: Edit `modules/settings/desktop-settings.nix` for fonts, themes, scaling
- **Application configs**: Add to `xdg.configFile` in `modules/home/jc/files.nix`

### **Settings Management**
- **System constants**: Edit `modules/settings/system-settings.nix` (hostname, user, hardware)
- **Desktop theming**: Modify `modules/settings/desktop-settings.nix` (fonts, themes, cursor)
- **Home environment**: Update `modules/settings/home-settings.nix` (aliases, git, npm)

## 🎮 Keybindings & Usage

### **Window Management** (Super key as modifier)
- `Super + Return`: Open terminal (COSMIC Terminal)
- `Super + D`: Application launcher (COSMIC Launcher)
- `Super + Shift + L`: Lock screen (loginctl)
- `Super + E`: File manager (COSMIC Files)
- `Super + Q`: Close window
- `Super + Space`: Toggle floating
- `Super + Shift + F` / `Super + F`: Toggle fullscreen
- `Super + R`: Switch preset column widths
- `Super + Shift + R`: Reset window height
- `Super + C`: Center focused column

### **Workspace Management**
- `Super + 1-9`: Switch to workspace 1-9
- `Super + Shift + 1-9`: Move window to workspace 1-9
- `Super + Page_Up/Page_Down`: Navigate workspaces
- `Super + U/I`: Switch between workspaces vertically
- `Super + Tab`: Toggle previous workspace

### **Column & Window Movement**
- `Super + H/J/K/L` or `Super + Arrows`: Move focus between columns/windows
- `Super + Shift + H/J/K/L`: Move windows/columns
- `Super + Ctrl + H/J/K/L`: Resize columns/windows
- `Super + BracketLeft/BracketRight`: Consume/expel windows from column
- `Super + Comma/Period`: Switch between columns in a workspace

### **Display Management**
- `Super + Shift + P`: Power off all monitors
- `Super + P`: Enter display submap for HDMI configuration
  - `Grave`: Mirror laptop to HDMI
  - `1-9`: Bind workspace to HDMI
  - `Backspace`: Disable HDMI
  - `Escape`: Exit submap

### **System Controls**
- `Super + Shift + E`: Quit Niri
- `Ctrl + Super + Delete`: Quit Niri (alternative)
- `Super + N`: Toggle night light (wlsunset)
- `Super + M`: Toggle Waybar
- `XF86 Keys`: Volume/brightness with wpctl/brightnessctl
- `XF86 Media Keys`: Playerctl integration (play/pause, next, previous)

### **Screenshots**
- `Print`: Screenshot (Niri built-in)
- `Ctrl + Print`: Screenshot screen
- `Alt + Print`: Screenshot window

### **Wallpaper & Clipboard**
- `Super + W`: Change wallpaper (next)
- `Super + Shift + W`: Random wallpaper
- `Super + V`: Clipboard history (via cliphist + Wofi)

### **Custom Commands**
- `apply-home-manager`: Update Home Manager configuration with swaync notifications
- `lock-screen`: Lock screen via loginctl
- `graceful-shutdown [shutdown|reboot]`: Smart system shutdown with application cleanup
- `volume-control [up|down|mute]`: WirePlumber audio control with visual feedback
- `brightness-control [up|down]`: Intel backlight control with percentage display
- `change-wallpaper [linear|random]`: Dynamic wallpaper switching with awww

## 📈 Recent Improvements

### **Niri Migration** (Latest)
- **Window Manager**: Migrated from Hyprland to Niri scrollable tiling compositor
- **COSMIC Apps**: Terminal, file manager, and launcher replaced with COSMIC suite
- **Niri-Flake**: System-level integration via `sodiboo/niri-flake` with binary cache
- **Config KDL**: Full Niri configuration managed via `config.kdl` with `programs.niri.config`
- **Awww Wallpapers**: Replaced swww with awww (successor from Codeberg)
- **NixOS 25.11**: Switched from rolling unstable to stable 25.11 release
- **Cleanup**: Removed VS Code (commented), Ollama/UI, disabled firewall
- **Script Updates**: All scripts updated to use `niri msg`, `loginctl`, and `awww`

### **External Configuration Files**
- **Config Directory**: `modules/home/.config/` with Niri, Waybar, Starship, SwayNC configs
- **XDG Integration**: Managed via `xdg.configFile` in `files.nix`
- **Starship Prompt**: Custom configuration with rich prompt styling

### **Virtualization**
- **Incus**: Migrated from LXD to Incus with preseed configuration
- **Bridge Networking**: lxdbr0 with 10.0.0.1/24, NAT, DHCP
- **Custom Storage**: Dir-backed storage pool at `/home/jc/incus/storage-pools/default`
- **Waydroid**: Android emulation via Wayland container

### **Graphics & Power**
- **dGPU Disabled**: NVIDIA GPU completely blacklisted for maximum battery savings
- **Intel-Only Graphics**: Using iHD VAAPI driver for hardware acceleration
- **ZRAM**: 120% RAM with zstd compression
- **TLP**: Comprehensive AC/battery profiles with platform profiles, GPU capping, deep sleep

### **Custom Plymouth Theme**
- **Boot Animation**: Custom `my-theme` Plymouth theme built from local assets
- **Silent Boot**: Quiet kernel parameters with splash screen

## 📋 Troubleshooting

### **Common Issues**
- **Audio problems**: Check PipeWire status with `wpctl status`
- **Display scaling**: Verify Niri output config in `modules/home/.config/niri/config.kdl`
- **Script permissions**: Ensure scripts are executable via Home Manager rebuild
- **Docker issues**: Data stored at `/home/jc/docker`, check with `docker info`
- **Incus issues**: Check bridge with `incus network list`, storage with `incus storage list`
- **Niri config errors**: Run `niri validate` to check config syntax

### **Logs & Debugging**
```bash
# System logs
journalctl -f

# Home Manager logs
home-manager switch --flake . --verbose

# Niri logs
journalctl --user -f -u niri

# TLP status
sudo tlp-stat -c

# Incus status
incus list
```

## 🖥️ System Specifications

- **NixOS Version**: 25.11 (stable release)
- **Package Manager**: Nix 2.x with flakes and unified CLI enabled
- **Display Protocol**: Wayland with Niri scrollable tiling compositor
- **Login Manager**: greetd with auto-login to niri-session
- **Theme System**: Adwaita base theme with GTK and Qt integration
- **Localization**: Vietnamese (vi_VN) with English (en_US.UTF-8) system locale
- **Input Methods**: Fcitx5 with Bamboo engine and Nord theme for Vietnamese typing
- **Font Stack**: Cascadia Code NF (monospace), SDK_SC_Web (sans-serif/UI), Noto CJK (multilingual)
- **Boot**: GRUB with custom Plymouth theme and quiet splash

---

## 🤝 Contributing

This configuration serves as a comprehensive example of modern NixOS setup. Feel free to:
- Fork and adapt for your hardware/preferences
- Submit improvements via pull requests
- Report issues or suggest enhancements
- Use as a learning resource for NixOS/Home Manager

## 📄 License

This configuration is provided as-is for educational and personal use. Individual software components retain their respective licenses.

---

## 📚 Niri Migration

```bash
# 1. On your NixOS machine, switch to the niri branch
git checkout niri
git pull
# 2. First, just test that it evaluates correctly
sudo nixos-rebuild dry-build --flake .
# 3. If that's clean, apply with "test" (doesn't persist across reboot)
sudo nixos-rebuild test --flake .
# 4. If niri works well, make it permanent
sudo nixos-rebuild switch --flake .
```