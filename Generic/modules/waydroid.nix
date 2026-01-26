{ pkgs, ... }:

{
  virtualisation.waydroid.enable = true;
  virtualisation.lxc.enable = true;
  environment.systemPackages = with pkgs; [
    waydroid-helper
  ];
}
