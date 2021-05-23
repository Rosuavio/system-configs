{
  imports = [
    ./secrets/passwords.nix
    ./secrets/users.nix
  ];

  users = {
    mutableUsers = false;

    users = {
      rosario = {
        description = "Rosario Pulella";
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" ];
      };
    };
  };
}
