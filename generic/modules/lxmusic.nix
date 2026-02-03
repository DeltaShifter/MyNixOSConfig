{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.lx-music;

  # 这里定义包的提取和包装逻辑
  lx-music-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "lx-music-desktop";
    version = "2.12.0";

    src = pkgs.fetchurl {
      url = "https://github.com/lyswhut/lx-music-desktop/releases/download/v${version}/lx-music-desktop_${version}_x64.pacman";
      # 如果下载慢，可以换成这个：url = "https://ghfast.top/https://github.com/lyswhut/lx-music-desktop/releases/download/v${version}/lx-music-desktop_${version}_x64.pacman";
      hash = "sha256-gpVf2mNMLByCvBHf0R4B7B+BHP59X/Xbz70B7B9zZTI="; 
    };

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.libarchive ];

    dontBuild = true;

    unpackPhase = ''
      bsdtar -xf $src
    '';

    installPhase = ''
      mkdir -p $out/lib/lx-music
      cp opt/lx-music-desktop/resources/app.asar $out/lib/lx-music/
      
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp usr/share/icons/hicolor/512x512/apps/lx-music-desktop.png $out/share/icons/hicolor/512x512/apps/lx-music.png

      # 使用系统原生的 Electron 35 驱动，彻底解决 Wayland 渲染问题
      makeWrapper ${pkgs.electron_35}/bin/electron $out/bin/lx-music \
        --add-flags "$out/lib/lx-music/app.asar" \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--no-sandbox"
    '';

    # 顺便把桌面图标也打进去
    desktopItem = pkgs.makeDesktopItem {
      name = "lx-music";
      exec = "lx-music";
      icon = "lx-music";
      desktopName = "洛雪音乐";
      categories = [ "Audio" "Music" ];
    };

    postInstall = ''
      mkdir -p $out/share/applications
      cp $desktopItem/share/applications/* $out/share/applications/
    '';
  };

in {
  # 定义模块开关
  options.myModules.lx-music.enable = mkEnableOption "洛雪音乐原生包装模块";

  config = mkIf cfg.enable {
    # 只需要开启开关，包就会自动出现在系统里
    environment.systemPackages = [
      lx-music-pkg
    ];
  };
}
