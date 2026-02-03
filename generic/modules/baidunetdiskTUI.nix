{ pkgs, ... }:

let
  baidupcs-tui = pkgs.writeShellScriptBin "baidupcs-tui" (builtins.readFile ../scripts/baiduPCS.sh);
in
{
  environment.systemPackages = [ baidupcs-tui ];

  xdg.desktopEntries.baidupcs-tui = {
    name = "百度网盘 TUI";
    exec = "alacritty bash -c baidupcs-tui";
    terminal = false;
  };
}
