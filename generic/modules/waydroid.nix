{ pkgs, ... }:

{
  virtualisation.waydroid.enable = true;
  virtualisation.lxc.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  environment.systemPackages = with pkgs; [
    waydroid-helper
  ];
}
