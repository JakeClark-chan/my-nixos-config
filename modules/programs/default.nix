# Auto-import all program modules
{
  imports = [
    ./cli.nix         # CLI tools and utilities
    ./development.nix # Development tools and languages
    ./fonts.nix       # Font configurations
    ./nvidia-autooffload.nix # NVIDIA auto-offload configuration
  ];
}
