{ lib, appimageTools, fetchurl, copyDesktopItems, makeDesktopItem }:

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
    # 自动安装 AppImage 内部的 .desktop 文件
    install -m 444 -D ${appimageContents}/*.desktop $out/share/applications/${pname}.desktop

    # 将 Desktop 文件中的启动入口修正为 Nix 包装后的真实可执行文件名
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}" \
      --replace-fail "Exec=ghost-downloader-3" "Exec=${pname}"

    # 安装图标到系统图标目录 (hicolor)
    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp ${appimageContents}/*.png $out/share/icons/hicolor/512x512/apps/${pname}.png || true
  '';
  meta = with lib; {
    description = "A multi-threading async downloader based on PySide6";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ghost-downloader";
  };
}
