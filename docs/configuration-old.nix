# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running "nixos-help").

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable experimental features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  #boot.loader.grub = {
  #  enable = true;
  #  useOSProber = true;  # Enable detecting other OS like Windows
  #  device = "/dev/nvme0n1p7";    # Or set to your disk if needed (e.g., "/dev/sda")
  #};

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # Custom: Modeswitch rtl8188gu
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.kernelModules = [ "rtl8xxxu" ];
  services.udev.packages = [ pkgs.usb-modeswitch ];
  # Put the rule inside a package so it merges cleanly
  services.udev.extraRules = ''
    # Realtek USB device mode switch
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", \
      RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"

    # Set battery charge limit for ASUS laptops
    ACTION=="add", KERNEL=="asus-nb-wmi", \
      RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'"
  '';
  # Ended

  networking.hostName = "JakeClark-Sep21st"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Swap 6GB
  swapDevices = [{
  device = "/swapfile";   # Path where swapfile will be created
  size     = 4 * 1024;    # Size in MiB (4GB)
  priority = 10;  # Priority of the swap device
  }];

  # Zram Swap
  zramSwap = {
    enable = true;  # Enable zram swap
    memoryPercent = 30;
    algorithm = "lz4";  # Compression algorithm to use
    priority = 100;  # Priority of the zram swap device
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Deepin Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.deepin.enable = true;

  # Enable the Budgie Desktop environment and LightDM
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.budgie.enable = true;

  # Enable Pantheon
  #services.xserver.desktopManager.pantheon.enable = true;
  # Disable Epiphany (GNOME Web)
  #environment.pantheon.excludePackages = [ 
  #  pkgs.pantheon.epiphany
  #  pkgs.pantheon.elementary-terminal 
  #];

  # Enable COSMIC Desktop
  #services.desktopManager.cosmic.enable = true;
  #services.displayManager.cosmic-greeter.enable = true;

  # Enable Xfce
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.desktopManager.xfce.enableScreensaver = false;
  #services.xserver.desktopManager.xfce.enableWaylandSession = true;
  #programs.thunar.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jc = {
    isNormalUser = true;
    description = "JakeClark";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      onlyoffice-desktopeditors # for office work
      #vscode
      openvpn
      nodejs # for gemini cli and more
      docker
      docker-compose
      python313Packages.uv
      flameshot # for screenshot
      distrobox # for sandboxing applications
      distrobox-tui
    ];
  };

  # Fix vscode dynamic binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;

  # Virtualization
  virtualisation.docker.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jc";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Open Flatpak
  #services.flatpak.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # this script copy background to /usr/share/backgrounds - Deepin only - Copy image into /etc/nixos/___.jpg
    (pkgs.runCommand "custom-background" { } ''
	    mkdir -p $out/share/backgrounds
	    cp ${./shiho.jpg} $out/share/backgrounds/
	  '')
    wget
    curl
    usbutils # for lsusb
    usb-modeswitch # for usb_modeswitch
    zsh
    python313
    git
  ];
  # Fcitx5
  i18n.inputMethod = {
     type = "fcitx5";
     enable = true;
     fcitx5.addons = with pkgs; [
       fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
       fcitx5-bamboo  # table input method support
       fcitx5-nord            # a color theme
     ];
   };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
