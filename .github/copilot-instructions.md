# NixOS Configuration - AI Agent Instructions

## Architecture Overview

This is a modular NixOS flake configuration with integrated Home Manager for user-level packages and dotfiles. The system is designed around Hyprland (Wayland compositor) with custom Nix-based scripts and power management optimizations.

### Core Structure
- **`flake.nix`**: Main entry point with inputs (nixpkgs, home-manager, zen-browser, prismlauncher-cracked)
- **`configuration.nix`**: System-level imports and basic package list
- **`modules/`**: Modular configuration organized by function
- **Settings pattern**: `modules/settings/{system,desktop,home}-settings.nix` contain shared constants

### Module Organization
```
modules/
├── core/          # Essential system (boot, nix, hardware)
├── desktop/       # Window manager configs
├── home/          # Home Manager user configs
├── programs/      # System-wide programs
├── services/      # System services
├── settings/      # Shared configuration constants
└── users/         # User account definitions
```

## Home Manager Integration

Home Manager is fully integrated into the flake and organized into sub-modules:

### Home Manager Structure
- **`modules/home/jc.nix`**: Main user config that imports sub-modules
- **`modules/home/jc/`**: User-specific configurations split by function:
  - `packages.nix`: User packages with custom script imports
  - `programs.nix`: Program configurations (git, kitty, hyprlock, etc.)
  - `services.nix`: User services and systemd units
  - `launchers.nix`: Desktop entries for custom scripts
  - `files.nix`: Dotfiles and session variables

### Custom Script Pattern
Scripts in `modules/home/scripts/` follow this pattern:
```nix
# scripts/example-script.nix
{ pkgs }:
pkgs.writeShellScriptBin "script-name" ''
  # Shell script content with full paths to binaries
  ${pkgs.package}/bin/command
''
```

Scripts are imported in `packages.nix` using:
```nix
let
  scriptName = pkgs.callPackage ../scripts/script-name.nix {};
in {
  home.packages = [ scriptName ];
}
```

## Key Workflows

### System Rebuild Commands
```bash
# Test configuration without switching
sudo nixos-rebuild test --flake .

# Apply system configuration
sudo nixos-rebuild switch --flake .

# Update flake inputs and rebuild
sudo nixos-rebuild switch --recreate-lock-file --flake .
```

### Home Manager Commands
```bash
# Apply user configuration with notifications
apply-home-manager

# Manual Home Manager switch
home-manager switch --flake .
```

### Development Workflow
- **Settings changes**: Edit `modules/settings/system-settings.nix` for system-wide constants
- **Add packages**: System-wide in `modules/programs/`, user-specific in `modules/home/jc/packages.nix`
- **Custom scripts**: Create in `modules/home/scripts/`, import in `packages.nix`
- **Desktop entries**: Add to `modules/home/jc/launchers.nix` for GUI access

## Project-Specific Conventions

### Settings Management
Three settings files provide shared constants:
- **`system-settings.nix`**: User info, hostname, hardware config
- **`desktop-settings.nix`**: Hyprland config, wallpapers, theming
- **`home-settings.nix`**: Shell aliases, git config

### Script Integration
Custom scripts use the `writeShellScriptBin` pattern with:
- Full paths to all binaries (`${pkgs.package}/bin/command`)
- Notification support (swaync fallback to notify-send)
- Error handling with user feedback
- Integration with desktop launchers

### Flake Input Management
External packages are managed through flake inputs:
```nix
# In flake.nix inputs
zen-browser.url = "github:0xc000022070/zen-browser-flake";

# Used in modules as
inputs.zen-browser.packages."${pkgs.system}".default
```

### Module Import Pattern
Modules use `default.nix` files to auto-import all `.nix` files in their directory:
```nix
# modules/programs/default.nix
{
  imports = [
    ./cli.nix
    ./development.nix
    ./fonts.nix
  ];
}
```

## Hardware-Specific Features

- **NVIDIA support**: Prime configuration in `system-settings.nix`
- **Power management**: TLP + thermald (not auto-cpufreq)
- **Battery protection**: 40-80% charging thresholds
- **Thermal management**: Intel thermald integration

## Debugging & Troubleshooting

### Common Commands
```bash
# System logs
journalctl -f

# Home Manager verbose rebuild
home-manager switch --flake . --verbose

# Hyprland logs
journalctl --user -f -u hyprland

# Audio troubleshooting
wpctl status
```

### Configuration Testing
Always test configurations before switching:
```bash
sudo nixos-rebuild test --flake .
```

## Key Integration Points

- **Desktop integration**: Custom scripts appear in application menu via `launchers.nix`
- **Notification system**: Scripts use swaync/notify-send for user feedback
- **Power management**: TLP configured in `development.nix` with AC/battery profiles
- **Container support**: LXD with custom GUI manager (`lxc-gui`)
- **Multi-language support**: Fcitx5 for Vietnamese/English input

Focus on maintaining the modular structure and following the established patterns for scripts, settings, and Home Manager integration.