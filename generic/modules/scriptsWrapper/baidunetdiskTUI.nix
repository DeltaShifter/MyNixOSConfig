{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "baidupcs-tui";
      desktopName = "百度网盘 TUI";
      exec = "env -u GIO_EXTRA_MODULES -u GDK_BACKEND alacritty -e ${pkgs.bash}/bin/bash ${../../scripts/baiduPCS.sh}";
      icon = "baidunetdisk";
      categories = [ "Network" ];
      terminal = false;
    })
  ];
}
