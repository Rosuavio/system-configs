{
  imports = [
    secrets/passwords.nix
    secrets/users.nix
  ];

  users.mutableUsers = true;

  users.users = {
    rosario = {
      description = "Rosario Pulella";
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
    };
  };
}
