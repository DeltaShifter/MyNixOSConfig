{ pkgs, lib, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  services.displayManager.dms-greeter.enable = lib.mkDefault false;
  services.displayManager.sddm = {
    enable = true;
  };
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin = {
    enable = true;
    user = "dale";
  };
}
