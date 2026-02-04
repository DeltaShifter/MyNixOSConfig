{ pkgs, ... }:

let
  # 使用官方稳定的 24.11 分支链接
  oldPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    # 如果这个 sha256 报错 mismatch，请将其改为报错信息里的 "got" 值
    sha256 = "sha256:1s2gr5rcyqvpr58vxdcb095mdhblij9bfzaximrva2243aal3dgx";
  }){
    system = pkgs.stdenv.hostPlatform.system; 
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron"
      ];
    };
  };
  
  lx-music-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "lx-music-desktop";
    version = "2.12.0";

    src = pkgs.fetchurl {
      url = "https://github.com/lyswhut/lx-music-desktop/releases/download/v${version}/lx-music-desktop_${version}_x64.pacman";
      hash = "sha256-B1I42K9o0ybS2Nii+gcHEfuPd9tZl9le+J2rJValUPQ="; 
    };

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.libarchive ];

    dontBuild = true;

    unpackPhase = "bsdtar -xf $src";

    installPhase = ''
      mkdir -p $out/lib/lx-music
      cp opt/lx-music-desktop/resources/app.asar $out/lib/lx-music/
      echo '{"name":"lx-music-desktop","productName":"lx-music-desktop"}' > $out/lib/lx-music/package.json

      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp usr/share/icons/hicolor/512x512/apps/lx-music-desktop.png $out/share/icons/hicolor/512x512/apps/lx-music.png

      makeWrapper ${oldPkgs.electron}/bin/electron $out/bin/lx-music \
        --add-flags "$out/lib/lx-music/app.asar" \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--no-sandbox"
    '';

    # 桌面文件部分保持不变...
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
  environment.systemPackages = [ lx-music-pkg ];
}
