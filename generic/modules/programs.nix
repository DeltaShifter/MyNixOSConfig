{ config, pkgs, lib, ... }:


{
  programs.dconf.enable = true;
  services.envfs.enable = true;

  programs.firefox.enable = true; # 火狐浏览器

  programs.kdeconnect.enable = true;

  programs.steam = {
    # Steam
    enable = true;
    remotePlay.openFirewall = true; # 为 Steam 流式传输开启防火墙
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      # 防止黑屏
      extraArgs = "-system-composer";
    };
  };
  programs.gamescope.enable = true; # 开启gamescope取得更好的全屏体验

  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;

  services.scx = {
    enable = true;
    scheduler = "scx_rusty";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin # 右键压缩/解压
      thunar-volman # 自动挂载U盘
      thunar-media-tags-plugin # 媒体文件标签
    ];
  };

  programs.xfconf.enable = true;
  services.udisks2.enable = true; # 开启USB挂载
  services.tumbler.enable = true; # 解决文管缩略图显示
  services.gvfs.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  programs.nh = {
    # nh更新器
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # documentation.man.generateCaches = false; #关闭man cache加快构建速度

  nixpkgs.overlays = [
    # 应用行为

    (final: prev: {
      spacedrive-wrapper = prev.symlinkJoin {
        # 修正spacedrive显示问题和路径问题
        name = "spacedrive";
        paths = [ prev.spacedrive ];
        nativeBuildInputs = [ final.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/spacedrive \
            --set GDK_BACKEND x11 \
            --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
            --prefix XDG_DATA_DIRS : "${final.gtk3}/share/gsettings-schemas"
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "xterm" ''
      exec ${pkgs.kitty}/bin/kitty "$@"
    '')
    (pkgs.writeShellScriptBin "gnome-terminal" ''
      exec kitty "$@"
    '')
    kitty
    kitty-img
    kitty-themes
    nur.repos.chillcicada.ttf-ms-win10-sc-sup
    nur.repos.chillcicada.ttf-wps-fonts
    android-tools
    btop
    vim
    wget
    git
    gh
    jq
    helix
    nixd
    nixpkgs-fmt
    fastfetch
    udiskie
    yazi
    cachix
    lsd
    loupe
    gsettings-desktop-schemas
    adwaita-icon-theme
    bibata-cursors-translucent
    xray
    gparted
    spacedrive
    google-chrome
    microsoft-edge
    gopeed
    qq
    wechat
    clapper
    papirus-icon-theme
    ouch
    unrar
    file-roller
    intel-undervolt
    thunderbird
    zenity
    glide-media-player
    gearlever
    appimage-run
    wl-clipboard
    xclip
    caligula
    nfs-utils
    baidupcs-go
    telegram-desktop
    clapper-enhancers
    ventoy-full
    foliate
    splayer
    (pkgs.callPackage ../../pkgs/yesplaymusic.nix { })
    (pkgs.callPackage ../../pkgs/alacritty-smooth.nix { })
    gimp-with-plugins
    shotcut
    lx-music-desktop
    quickemu
    quickgui
    protonplus
    bottles
    (pkgs.callPackage ../../pkgs/ghostdownloader.nix { })
    # ---PkgsEnd--- 
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  services.xserver.excludePackages = [ pkgs.xterm ]; # 配合上面的伪装禁用xterm

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";
  };

}
