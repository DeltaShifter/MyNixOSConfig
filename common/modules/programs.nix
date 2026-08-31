{ config, pkgs, pkgs-unstable, lib, ... }:


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
    plugins = with pkgs; [
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
    google-chrome
    microsoft-edge
    pkgs-unstable.qq
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
    # pkgs-unstable.ventoy-full
    foliate
    splayer
    (pkgs.callPackage ../pkgs/alacritty-smooth.nix { })
    gimp-with-plugins
    shotcut
    lx-music-desktop
    protonplus
    (pkgs.callPackage ../pkgs/ghostdownloader.nix { })
    _7zip-zstd-rar
    # ---PkgsEnd--- 
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.17"
    "ventoy-1.1.12"
  ];

  services.xserver.excludePackages = [ pkgs.xterm ]; # 配合上面的伪装禁用xterm

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";
  };

}
