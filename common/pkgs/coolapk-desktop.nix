{ lib, appimageTools, fetchurl, }:

let

  pname = "coolapk-desktop";
  version = "1.32.0";

  src = fetchurl {
    url = "https://github.com/daimiaopeng/coolapk-desktop/releases/download/v${version}/coolapk-desktop_${version}_amd64.AppImage";
    hash = "sha256-JexM1urOVgu6aMXecBdf6Ojvf+mqmGVmEf0khEXxaXw=";
  };
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in

appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    zstd
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/coolapk-desktop.desktop $out/share/applications/coolapk-desktop.desktop
    install -m 444 -D ${appimageContents}/coolapk-desktop.png $out/share/icons/hicolor/512x512/apps/coolapk-desktop.png
  '';
}
