{ osConfig, pkgs, lib, ... }:

let
  
   # 调取主机名，方便以后的判断
    currentHostName = osConfig.networking.hostName;
  
    # 让部分主题不兼容的应用回归默认主题
    Adwaitar = pkg: pkgs.symlinkJoin {
    name = "${pkg.name}-adwaita";
    paths = [ pkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${pkg.pname or pkg.name} \
    --set XDG_CONFIG_HOME "\$HOME/.config/gtk-4.0-isolated" # 给这些应用指定一个默认的GTK配置文件
     mkdir -p $out/share/applications # 接下来我要把.desktop里面的exec指向也改到包装以后的路径
      for f in ${pkg}/share/applications/*.desktop; do # 遍历所有desktop文件
        target="$out/share/applications/$(basename "$f")"
        # 先找到原有的链接,拼好链，用$out/share/applications加切掉路径保留文件名的$f
        rm -f "$target" # 断链让symlikJoin生效
        sed "s|^Exec=[^ ]*\(.*\)|Exec=$out/bin/${pkg.pname or pkg.name}\1|g" "$f" > "$target"
        # 找到Exec=开头的行，把第一个空格之后的所有内容（也就是二进制命令后面的所有参数）抓起来
        # 内容放入寄存1，开始拼好令，替换为Exec=加包装后的路径+寄存1（也就是参数）
        # 拼完后丢入$target,大功告成
      done
    '';
    };

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

    home.packages = with pkgs;[
      
    ]
     ++ (map Adwaitar [
    #此处填写需要使用默认主题的应用
    clapper
    ghostty
    loupe
      ]);

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
