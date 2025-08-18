# Improved Module Organization

## Recommended structure without modifying existing code:

```
modules/
├── core/              # NEW: Essential system settings
│   ├── default.nix    # Auto-imports all core modules
│   ├── boot.nix       # MOVE from system/
│   ├── nix.nix        # MOVE from system/
│   └── hardware.nix   # MOVE from hardware/default.nix
├── desktop/           # KEEP: Desktop environments
│   ├── default.nix    # NEW: Choose desktop via options
│   ├── deepin.nix
│   └── hyprland.nix
├── home/              # KEEP: Home Manager configs
│   └── jc.nix
├── programs/          # RESTRUCTURE: Split by purpose
│   ├── default.nix    # Auto-imports all program modules
│   ├── cli.nix        # NEW: CLI tools (git, curl, etc.)
│   ├── development.nix # NEW: Dev tools (vscode, nodejs)
│   └── fonts.nix      # NEW: Font configurations
├── services/          # KEEP: System services
│   ├── default.nix    # NEW: Auto-imports all services
│   ├── audio.nix
│   ├── network.nix
│   └── virtualization.nix
├── system/            # RENAME to settings/: Non-core settings
│   ├── default.nix    # NEW: Auto-imports all settings
│   ├── locale.nix
│   ├── memory.nix
│   ├── journald.nix
│   └── plymouth.nix
└── users/             # KEEP: User management
    └── jc.nix
```

## Benefits of this structure:

1. **core/**: Essential boot/hardware/nix settings grouped together
2. **programs/**: Split by purpose (CLI, development, fonts)
3. **default.nix**: Auto-import files in each directory
4. **Logical grouping**: Related functionality together
5. **Scalable**: Easy to add new modules in appropriate categories

## Migration Strategy:

### Phase 1: Create auto-import default.nix files
### Phase 2: Split programs/ by functionality  
### Phase 3: Move core system files to core/
### Phase 4: Update configuration.nix imports

This keeps your existing code intact while providing a cleaner structure.
