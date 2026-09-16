{ lib, appimageTools, fetchurl, copyDesktopItems, makeDesktopItem }:

let

  pname = "ghost-downloader";
  version = "4.3.7";
in
appimageTools.wrapType2 {
  inherit pname version;
  src = fetchurl {
    url = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/download/v${version}/Ghost-Downloader-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-N2CYcJXIOeBWNn9LRxnCIzPVLI7O8ROBSU2rfXRMy6A=";
  };

  extraPkgs = pkgs: with pkgs; [
    zstd
  ];

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Ghost Downloader";
      comment = "A multi-threading async downloader based on PySide6";
      categories = [ "Network" "Utility" ];
    })
  ];
  meta = with lib; {
    description = "A multi-threading async downloader based on PySide6";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ghost-downloader";
  };
}
