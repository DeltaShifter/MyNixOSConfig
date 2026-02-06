{ pkgs , lib , ... }:
{
  services.sunshine = {
  enable = true;
  autoStart = true;
  capSysAdmin = true;
  openFirewall = true;
  };
  #programs.regreet.enable = lib.mkForce false;
  #services.displayManager.autoLogin = {
  #  enable = true;
  #  user = "dale";
  #};
}
