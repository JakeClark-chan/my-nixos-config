# System-wide settings and constants

{
  # User settings
  username = "jc";
  userFullName = "JakeClark";
  userEmail = "jakeclark38b@gmail.com";
  homeDirectory = "/home/jc";

  # System settings
  hostname = "JakeClark-Sep21st";
  timezone = "Asia/Ho_Chi_Minh";
  locale = "en_US.UTF-8";
  extraLocaleSettings = {
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

  # Hardware settings
  nvidia = {
    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:1@0:0:0";
  };
}