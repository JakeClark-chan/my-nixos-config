# My NixOS Configuration

A modular NixOS configuration setup with flakes support for easy maintenance and reproducibility.

## 🏗️ Structure

```
├── configuration.nix           # Main configuration file
├── flake.nix                  # Flake configuration
├── hardware-configuration.nix # Hardware-specific settings (auto-generated)
└── modules/
    ├── desktop/
    │   └── deepin.nix         # Deepin desktop environment
    ├── hardware/
    │   └── default.nix        # Hardware & firmware configs
    ├── programs/
    │   └── default.nix        # System programs & packages
    ├── services/
    │   ├── audio.nix          # PipeWire audio configuration
    │   ├── network.nix        # NetworkManager & networking
    │   └── virtualization.nix # Docker & virtualization
    ├── system/
    │   ├── boot.nix           # Bootloader settings
    │   ├── locale.nix         # Timezone & localization
    │   ├── memory.nix         # Swap & memory management
    │   └── nix.nix            # Nix-specific settings
    └── users/
        └── jc.nix             # User account & packages
```

## 🚀 Features

- **Modular Design**: Each component is separated into logical modules
- **Flakes Support**: Modern Nix flakes for reproducible builds
- **Deepin Desktop**: Pre-configured Deepin desktop environment
- **Development Ready**: Docker, Git, Node.js, Python, and more
- **Vietnamese Locale**: Configured for Vietnam timezone and locale
- **Optimized**: Automatic garbage collection and storage optimization

## 📦 Included Software

### Desktop Environment
- Deepin Desktop Environment
- LightDM display manager
- Auto-login configured

### Development Tools
- Git
- Node.js
- Python 3.13 with uv package manager
- Docker & Docker Compose
- VS Code support (via nix-ld)

### System Tools
- Firefox
- OnlyOffice Desktop Editors
- Flameshot (screenshots)
- Distrobox (containerization)
- OpenVPN

### Input Method
- Fcitx5 with Vietnamese Bamboo input

## 🛠️ Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/JakeClark38a/my-nixos-config.git
   cd my-nixos-config
   ```

2. **Copy your hardware configuration:**
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix .
   ```

3. **Test the configuration:**
   ```bash
   sudo nixos-rebuild test --flake .
   ```

4. **Apply the configuration:**
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

## 🔄 Updates

### Update Flake Inputs
```bash
sudo nix flake update
sudo nixos-rebuild switch --flake .
```

### One-liner Update
```bash
sudo nixos-rebuild switch --recreate-lock-file --flake .
```

## 🎯 Customization

### Adding New Modules
1. Create a new `.nix` file in the appropriate `modules/` subdirectory
2. Add the module to the imports list in `configuration.nix`

### Switching Desktop Environments
1. Comment out the current desktop module in `configuration.nix`
2. Create a new desktop module in `modules/desktop/`
3. Add it to the imports

### Adding User Packages
Edit `modules/users/jc.nix` and add packages to the `packages` list.

## 📋 Common Commands

```bash
# Test configuration without switching
sudo nixos-rebuild test --flake .

# Switch to new configuration
sudo nixos-rebuild switch --flake .

# Build configuration without switching
sudo nixos-rebuild build --flake .

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Garbage collection
sudo nix-collect-garbage -d
```

## 🔧 Hardware Support

- **USB WiFi**: RTL8xxxu driver support
- **ASUS Laptops**: Battery charge limit (80%)
- **Latest Kernel**: Always uses the latest Linux kernel
- **Firmware**: All redistributable firmware enabled

## 💾 Memory Management

- **Swap**: 4GB swapfile with priority 10
- **Zram**: 30% of RAM compressed with LZ4, priority 100
- **Optimization**: Automatic Nix store optimization

## 🌐 Network & Services

- **NetworkManager**: Enabled for easy network management
- **Docker**: Ready for containerized development
- **SSH**: Ed25519 key support configured
- **Audio**: PipeWire with ALSA and PulseAudio compatibility

## 🛡️ Security

- **No Root Login**: Root login disabled
- **Key-based SSH**: Password authentication disabled
- **User Groups**: Proper group memberships for wheel, docker, networkmanager

## 📝 Notes

- This configuration is set for NixOS 25.05
- The hostname is configured as "JakeClark-Sep21st"
- Auto-login is enabled for user "jc"
- Vietnamese locale with US keyboard layout

---

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. Pull requests for improvements are welcome!

## 📄 License

This configuration is provided as-is for educational and personal use.