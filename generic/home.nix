{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.11"; 

  # niri 配置相关
  xdg.configFile."niri/my-custom.kdl".source = ./homeconfig/niriConfig.kdl;

  # Alacritty 相关
  xdg.configFile."alacritty/alacritty.toml".source = ./homeconfig/alacritty.toml;

  # Fcitx5 外观
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./homeconfig/fcitx5ui.conf;

  # Rofi
  xdg.configFile."rofi/config.rasi".source = ./homeconfig/rofi/config.rasi;
  xdg.configFile."rofi/rounded-nord-dark.rasi".source = ./homeconfig/rofi/rounded-nord-dark.rasi;
  xdg.configFile."rofi/template/rounded-template.rasi".source = ./homeconfig/rofi/rounded-template.rasi;

  # Starship
  xdg.configFile."starship.toml".source = ./homeconfig/starship.toml;

  # Helix
  xdg.configFile."helix/config.toml".source = ./homeconfig/helix.toml;
  
  programs.home-manager.enable = true;

  home.activation = {
    # Niri 注入include脚本
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
    
}
