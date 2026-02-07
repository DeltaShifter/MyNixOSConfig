
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "xorriso-tui";
      desktopName = "xorriso刻录";
      exec = "alacritty -e ${pkgs.bash}/bin/bash ${../../scripts/xorrisoBurn.sh}";
      icon = "xorriso";
      categories = [ "Utility" ];
      terminal = false;
    })
  ];
}
