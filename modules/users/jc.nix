{ config, pkgs, systemSettings, ... }:

{
  users.users.${systemSettings.username} = {
    isNormalUser = true;
    description = systemSettings.userFullName;
    # Add common groups: network, sudo, docker
    extraGroups = [ "networkmanager" "wheel" "docker" "incus-admin" "input" ];
    shell = pkgs.zsh;
    # Set empty password for auto-login
    hashedPassword = "";
    # Allow password-less sudo for convenience (optional)
    # initialPassword = "";
  };
  # system.userActivationScripts.zshrc = "touch .zshrc";
  # ZSH
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
    ];
  };
}
