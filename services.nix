{
  services = {
    pcscd.enable = true;
    pipewire.enable = true;
    throttled.enable = false;
    openssh.enable = true;

    fwupd.enable = true;

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
  };
}
