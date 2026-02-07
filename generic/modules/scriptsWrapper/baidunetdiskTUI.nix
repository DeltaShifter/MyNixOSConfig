{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "baidupcs-tui";
      desktopName = "百度网盘 TUI";
      exec = "alacritty -e ${pkgs.bash}/bin/bash ${../../scripts/baiduPCS.sh}";
      icon = "baidu";
      categories = [ "Network" ];
      terminal = false;
    })
  ];
}
