{ config, pkgs, lib, ... }:

  # niri配置相关
let
    niriRules = ''
    spawn-at-startup "dms" "run"
    window-rule {
        match app-id="Alacritty"
        draw-border-with-background false
        opacity 0.96        
      }

    window-rule {
      match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
      default-floating-position x=10 y=10 relative-to="bottom-right"
      }
  '';
in
{
  home.stateVersion = "25.11"; 
  xdg.configFile."niri/my-custom.kdl".text = niriRules;
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
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./HomeConfig/Fcitx5ui.conf;
  # Fuzzel.ini
  xdg.configFile."fuzzel/fuzzel.ini".source = ./HomeConfig/fuzzel.ini;

  programs = {
    git = {
      enable = true;
      settings.user = {
        Name = "DeltaShifter";
        Email = "dale@e.e";
         };
      };

    home-manager.enable = true;
  };

  home.packages = with pkgs; [
  ];
}
