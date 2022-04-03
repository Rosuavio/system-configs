{
  imports = [
    secrets/passwords.nix
  ];

  users.mutableUsers = false;

  users.users = {
    rosario = {
      description = "Rosario Pulella";
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
    };
  };
}
