{ pkgs, ... }:

{
  virtualisation.waydroid.enable = true;
  virtualisation.lxc.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    waydroid = pkgs.waydroid.override {
      withNftables = true;
    };
  };
  environment.systemPackages = with pkgs; [
    waydroid-helper
  ];
}
