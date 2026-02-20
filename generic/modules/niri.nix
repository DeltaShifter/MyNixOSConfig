{ config, pkgs, niri, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = niri.packages.${pkgs.system}.niri; 
}
