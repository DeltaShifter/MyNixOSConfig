{ pkgs , lib , ... }:
{
  services.sunshine = {
  enable = true;
  autoStart = true;
  capSysAdmin = true;
  openFirewall = true;
  };
  programs.regreet.enable = lib.mkForce false;
  services.displayManager.sddm = {
    enable = true;
  };
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin = {
    enable = true;
    user = "dale";
  };
}
