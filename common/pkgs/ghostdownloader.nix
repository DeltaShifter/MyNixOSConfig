{ lib, appimageTools, fetchurl, }:

let

  pname = "ghost-downloader";
  version = "4.3.7";

  src = fetchurl {
    url = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/download/v${version}/Ghost-Downloader-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-N2CYcJXIOeBWNn9LRxnCIzPVLI7O8ROBSU2rfXRMy6A=";
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

  extraInstall = ''
    install -m 444 -D ${appimageContents}/ghost-downloader.desktop $out/share/applications/ghost-downloader.desktop
    install -m 444 -D ${appimageContents}/ghost-downloader.png $out/share/icons/hicolor/512x512/apps/ghost-downloader.png
    ls -a 
  '';

  meta = with lib; {
    description = "A multi-threading async downloader based on PySide6";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ghost-downloader";
  };
}
