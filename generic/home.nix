{ osConfig, pkgs, lib, ... }:

let
  
   # 调取主机名，方便以后的判断
    currentHostName = osConfig.networking.hostName;
  
in

{
  home.stateVersion = "25.11"; 

  # 整体主题配置
  gtk = {
    enable = true;
    theme = {
      name = "Materia";
      package = pkgs.materia-theme;
      };
    iconTheme ={
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      };
    };

  # niri 配置相关
  xdg.configFile."niri/my-custom.kdl".source = ./homeConfig/niriConfig.kdl;

  # Alacritty 相关
  xdg.configFile."alacritty/alacritty.toml".source =
    if currentHostName == "X1c"
    then ./homeConfig/alacritty/alacritty-X1c.toml
    else ./homeConfig/alacritty/alacritty.toml;

  # Fcitx5 外观
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./homeConfig/fcitx5ui.conf;

  # Rofi
  xdg.configFile."rofi/config.rasi".source = ./homeConfig/rofi/config.rasi;
  xdg.configFile."rofi/rounded-nord-dark.rasi".source = ./homeConfig/rofi/rounded-nord-dark.rasi;
  xdg.configFile."rofi/template/rounded-template.rasi".source = ./homeConfig/rofi/rounded-template.rasi;

  # Starship
  xdg.configFile."starship.toml".source = ./homeConfig/starship.toml;

  # Helix
  xdg.configFile."helix/config.toml".source = ./homeConfig/helix.toml;
  
  programs.home-manager.enable = true;

  home.activation = {
    # Niri 注入include脚本,因为Niri的配置不止一个程序管理
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
