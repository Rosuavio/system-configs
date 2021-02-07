{
  services = {
    pcscd.enable = true;
    throttled.enable = false;
    openssh.enable = true;

    fwupd.enable = true;

    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };

  };
}
