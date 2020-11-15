{
  imports = [
    ./passwords.nix
  ];

  users.users = { 
    rosario = {
      description = "Rosario Pulella";
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager"];
    };
  };
}
