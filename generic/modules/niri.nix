{ config, pkgs, inputs, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = inputs.niri.packages.${pkgs.system}.niri; 
}
