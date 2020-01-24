{
  imports = [
    ./passwords.nix
  ];
  
  users.users = [ 
    {
      name = "rosario";
      description = "Rosario Pulella";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    }
  ];
}
