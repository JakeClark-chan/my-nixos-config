{ config, pkgs, ... }:

{
  # Limit journald storage
  services.journald.extraConfig = ''
    # Limit journal size
    SystemMaxUse=500M
    SystemKeepFree=1G
    SystemMaxFileSize=50M
    SystemMaxFiles=10
    
    # Runtime journal limits
    RuntimeMaxUse=100M
    RuntimeKeepFree=100M
    RuntimeMaxFileSize=10M
    RuntimeMaxFiles=5
    
    # Auto-vacuum old entries
    MaxRetentionSec=1month
  '';
}