{ pkgs }:

let
  # 1. 提取官方 AppImage 里的核心代码 (app.asar)
  # 你可以用之前解压出来的，或者让 Nix 处理
  srcAppImage = ./Downloads/lx-music-desktop_2.12.0_x64.AppImage;
in
pkgs.stdenv.mkDerivation {
  pname = "lx-music-native";
  version = "2.12.0";

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.p7zip ];

  # 这里的逻辑是：解压 AppImage，拿到 app.asar，然后用最新的 Electron 去跑
  unpackPhase = ''
    # 提取 AppImage 内容
    ${srcAppImage} --appimage-extract
    cp -r squashfs-root/resources/app.asar .
  '';

  installPhase = ''
    mkdir -p $out/lib/lx-music
    cp app.asar $out/lib/lx-music/

    # 使用 Nixpkgs 里的 Electron 35 (或最新版) 包装它
    makeWrapper ${pkgs.electron_35}/bin/electron $out/bin/lx-music \
      --add-flags "$out/lib/lx-music/app.asar" \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--no-sandbox"
  '';
}
