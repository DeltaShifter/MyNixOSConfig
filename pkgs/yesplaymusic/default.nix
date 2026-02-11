{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, libarchive
, gtk3, nss, alsa-lib, at-spi2-atk, atk, cairo, cups, dbus, expat
, fontconfig, freetype, gdk-pixbuf, glib, libdrm, libglvnd, libnotify
, libpulseaudio, libuuid, libxkbcommon, mesa, nspr, pango, systemd
, xorg , zstd
}:

stdenv.mkDerivation rec {
  pname = "yesplaymusic";
  version = "0.4.10";

  src = fetchurl {
    url = "https://github.com/qier222/YesPlayMusic/releases/download/v${version}/YesPlayMusic-${version}.pacman";
    sha256 = "e93b279cf2e916be661586990390b272c471ba1405ff665a27246c3fa1efac9f";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper libarchive zstd ];

  buildInputs = [
    gtk3 nss alsa-lib at-spi2-atk atk cairo cups dbus expat fontconfig
    freetype gdk-pixbuf glib libdrm libglvnd libnotify libpulseaudio
    libuuid libxkbcommon mesa nspr pango systemd
    xorg.libX11 xorg.libXcomposite xorg.libXcursor xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender
    xorg.libXtst xorg.libxcb xorg.libxshmfence
  ];

  unpackPhase = ''
    tar -xvf $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    mkdir -p $out/share
    cp -r opt/YesPlayMusic $out/opt/
    cp -r usr/share/* $out/share/

    rm -f $out/opt/YesPlayMusic/{.PKGINFO,.MTREE,.INSTALL}

    chmod +x $out/opt/YesPlayMusic/yesplaymusic

    substituteInPlace $out/share/applications/yesplaymusic.desktop \
      --replace 'Exec=/opt/YesPlayMusic/yesplaymusic' "Exec=$out/bin/yesplaymusic" \
      --replace 'Categories=Music;' 'Categories=Music;AudioVideo;Player;'

    # 建立二进制软链接（对应 post_install 逻辑）
    mkdir -p $out/bin
    makeWrapper $out/opt/YesPlayMusic/yesplaymusic $out/bin/yesplaymusic \
      --argv0 "yesplaymusic" \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"

    runHook postInstall
  '';
}
