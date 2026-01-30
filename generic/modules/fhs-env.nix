{ config, pkgs, ... }:

let
  my-fhs = pkgs.buildFHSEnv {
    name = "custom-fhs-env";
    targetPkgs = pkgs: (with pkgs; [
      udev
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libpulseaudio
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxshmfence
      zlib
      libxml2
      libgbm
      fontconfig
      freetype
      wqy_zenhei
      noto-fonts-cjk-sans
      libthai
      libpulseaudio
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ]);
    runScript = "bash";

  };
in
{
  environment.systemPackages = [ my-fhs ];
}
