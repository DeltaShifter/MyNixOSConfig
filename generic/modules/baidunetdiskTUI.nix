{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "baidupcs-tui";
      desktopName = "百度网盘 TUI";
      exec = "alacritty -e ${../scripts/baiduPCS.sh}";
      icon = "baidu";
      categories = [ "Network" ];
      terminal = false;
    })
  ];
}
