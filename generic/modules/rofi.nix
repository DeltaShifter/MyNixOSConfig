{ pkgs , ... }:
{
  programs.rofi = {
    enable = true;
      plugins = with pkgs; [
        rofi-calc
        rofi-pass
        rofi-power-menu
        rofimoji
    ];

    extraConfig = {
      modi = "drun";
      show-icons = true;
      icon-theme = "Papirus";
      terminal = "fish";
      
      # 界面微调
      drun-display-format = "{icon} {name}";
      location = 0;
      hide-scrollbar = true;
      theme = "~/.config/rofi/theme.rasi";
    };

  };
}
