{ pkgs , ... }:
{
  services.sunshine = {
  enable = true;
  autoStart = true;
  capSysAdmin = true;
  openFirewall = true;
  };
  services.displayManager.autoLogin = {
  enable = true;
  user = "dale";
  };
}
