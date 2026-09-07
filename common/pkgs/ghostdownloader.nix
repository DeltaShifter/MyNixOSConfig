{ lib, appimageTools, fetchurl }:

appimageTools.wrapType2 {
  pname = "ghost-downloader";
  version = "3.8.2";

  src = fetchurl {
    url = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/download/v4.3.7/Ghost-Downloader-v4.3.7-Linux-x86_64.AppImage";
    hash = "sha256-N2CYcJXIOeBWNn9LRxnCIzPVLI7O8ROBSU2rfXRMy6A=";
  };

  extraPkgs = pkgs: with pkgs; [
    zstd
  ];

  meta = with lib; {
    description = "A multi-threading async downloader based on PySide6";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ghost-downloader";
  };
}
