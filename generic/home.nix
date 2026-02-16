{ osConfig, inputs, pkgs, lib, ... }:

let
  
   # 调取主机名，方便以后的判断
    currentHostName = osConfig.networking.hostName;

in

{
  home.stateVersion = "25.11"; 

  # 整体主题配置
  gtk = {
    enable = true;
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

  # Kitty
  xdg.configFile."kitty/kitty.conf".source = ./homeConfig/kitty/kitty.conf;
  xdg.configFile."kitty/theme.conf".source = ./homeConfig/kitty/theme.conf;

  # yazi配置
  xdg.configFile."yazi/yazi.toml".source = ./homeConfig/yazi/yazi.toml;
  xdg.configFile."yazi/keymap.toml".source = ./homeConfig/yazi/keymap.toml;

  # yazi插件
  xdg.configFile = {
    "yazi/plugins/smart-enter.yazi".source = "${inputs.yazi-plugins}/smart-enter.yazi";
  };

  # Fcitx5
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./homeConfig/fcitx5/fcitx5ui.conf;
  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = ./homeConfig/fcitx5/rime.default.custom.yaml;
  
  # Rofi
  xdg.configFile."rofi/config.rasi".source = ./homeConfig/rofi/config.rasi;
  xdg.configFile."rofi/rounded-nord-dark.rasi".source = ./homeConfig/rofi/rounded-nord-dark.rasi;
  xdg.configFile."rofi/template/rounded-template.rasi".source = ./homeConfig/rofi/rounded-template.rasi;

  # Starship
  xdg.configFile."starship.toml".source = ./homeConfig/starship.toml;

  # Helix
  xdg.configFile."helix/config.toml".source = ./homeConfig/helix.toml;
  
  # Fastfetch预设
  xdg.dataFile."fastfetch".source = inputs.fastfetch-presets;
  
  home.file.".config/GIMP/3.0".source = ./homeConfig/photoGIMP/.;
  
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
   # PhotoshopGIMP配置文件
   linkPhotoGIMP = lib.hm.dag.entryAfter ["writeBoundary"] ''
     mkdir -p $HOME/.config/GIMP/3.0
     ln -sfn "./homeConfig/photoGIMP" "$HOME/.config/GIMP/3.0"
   '';   
   };
    
}
