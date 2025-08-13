# My NixOS Configuration

A modular NixOS configuration setup with flakes support for easy maintenance and reproducibility.

## 🏗️ Structure

```
├── configuration.nix           # Main configuration file
├── flake.nix                  # Flake configuration
├── hardware-configuration.nix # Hardware-specific settings (auto-generated)
└── modules/
    ├── desktop/
    │   └── deepin.nix         # Deepin desktop environment + custom wallpaper
    ├── hardware/
    │   └── default.nix        # Hardware & firmware configs (kernel, firmware, udev rules)
    ├── home/
    │   └── jc.nix             # Home Manager: per-user packages & dotfiles
    ├── programs/
    │   └── default.nix        # System programs & packages (Firefox, auto-cpufreq, etc.)
    ├── services/
    │   ├── audio.nix          # PipeWire audio configuration
    │   ├── network.nix        # Hostname, NetworkManager, firewall
    │   └── virtualization.nix # LXD + nix-ld (FHS compat)
    ├── system/
    │   ├── boot.nix           # Bootloader settings (systemd-boot)
    │   ├── locale.nix         # Timezone & localization + Fcitx5
    │   ├── memory.nix         # Swap & zram
    │   └── nix.nix            # Nix settings, GC, unfree
    └── users/
        └── jc.nix             # User account & groups (packages via Home Manager)
```

## 🚀 Features

- Modular design with Nix flakes
- Deepin Desktop + LightDM with auto-login for user "jc"
- Home Manager integrated for per-user packages/config (modules/home/jc.nix)
- Auto CPU scaling with auto-cpufreq (charger/battery profiles)
- PipeWire (with ALSA and PulseAudio compat)
- NetworkManager enabled
- Firewall enabled (TCP 80, 443; UDP 53)
- LXD virtualization enabled; Docker commented/optional
- nix-ld (rs) enabled for running FHS/dynamic binaries (e.g., VS Code)
- Nix optimizations: auto-optimise-store and weekly GC
- Custom wallpaper installed system-wide for Deepin

## 📦 Included Software

### Desktop Environment
- Deepin Desktop Environment
- LightDM display manager
- Auto-login for user "jc"

### Development Tools
- Git
- Node.js
- Python 3.13 (python313Full) + uv (via Home Manager)
- VS Code
- nix-ld runtime for compatibility

### System/User Tools
- Firefox
- OnlyOffice Desktop Editors (via Home Manager)
- Flameshot (via Home Manager)
- Distrobox (via Home Manager)
- OpenVPN

### Input Method
- Fcitx5 with Vietnamese Bamboo input

## 🔧 Hardware Support

- Kernel: Linux 6.15 (stable pin)
- Firmware: All redistributable firmware enabled
- Bluetooth disabled by default
- USB Wi‑Fi: RTL8xxxu driver loaded
- USB mode switch rule for Realtek device (usb-modeswitch)
- ASUS laptops: battery charge limit set to 80%
- NVIDIA PRIME config available in hardware module (commented with guidance)

## 💾 Memory Management

- Swap: 4GB swapfile (priority 10)
- Zram: 30% of RAM with LZ4 (priority 100)

## 🌐 Network & Services

- Hostname: JakeClark-Sep21st
- NetworkManager enabled
- Firewall: TCP 80, 443; UDP 53 allowed
- OpenSSH server: disabled by default (SSH agent enabled for client usage)

## 🛠️ Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/JakeClark38a/my-nixos-config.git
   cd my-nixos-config
   ```
2. Copy your hardware configuration:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix .
   ```
3. Test the configuration:
   ```bash
   sudo nixos-rebuild test --flake .
   ```
4. Apply the configuration:
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

### Adding User Packages (Home Manager)
Edit `modules/home/jc.nix` under `home.packages` for user-scoped software.

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

## 📝 Notes

- This configuration targets NixOS 25.05 (stable)
- Some packages can be pulled from nixpkgs-unstable via overlays (e.g., lmstudio)
- Auto-login is enabled for user "jc"
- Vietnamese locale with US keyboard layout

---

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. Pull requests for improvements are welcome!

## 📄 License

This configuration is provided as-is for educational and personal use.