{
  networking.hostId = "759df4cd";
  users.users = {
    root.password = "test";
    rosario.password = "test";
  };

  # TODO: Migrate this into the system config.
  system.stateVersion = "22.11";
}
