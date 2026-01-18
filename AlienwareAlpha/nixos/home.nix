{ config, pkgs, lib, ... }:

{
  # niri配置相关
  home.stateVersion = "25.11"; 
  xdg.configFile."niri/my-custom.kdl".source = ./homeconfig/niriConfig.kdl;
  home.activation = {
    ensureNiriInclude = lib.hm.dag.entryAfter ["writeBoundary"] ''
      CONFIG_FILE="$HOME/.config/niri/config.kdl"
      INCLUDE_LINE='include "my-custom.kdl"'
      if [ -f "$CONFIG_FILE" ]; then
        if ! grep -qF "$INCLUDE_LINE" "$CONFIG_FILE"; then
          echo -e "\n$INCLUDE_LINE" >> "$CONFIG_FILE"
        fi
      fi
    '';
  };

  # Fcitx5 外观
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./homeconfig/Fcitx5ui.conf;
  # Fuzzel.ini
  xdg.configFile."fuzzel/fuzzel.ini".source = ./homeconfig/fuzzel.ini;

  programs = {

      };
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
  ];
}
