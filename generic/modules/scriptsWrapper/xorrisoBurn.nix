
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "xorriso-tui";
      desktopName = "xorriso刻录";
      exec = "env -u GIO_EXTRA_MODULES -u GDK_BACKEND alacritty -e ${pkgs.bash}/bin/bash ${../../scripts/xorrisoBurn.sh}";
      icon = "disk-burner";
      categories = [ "Utility" ];
      terminal = false;
    })
  ];
}
