{ lib, appimageTools, fetchurl }:

let
  pname = "yesplaymusic";
  version = "0.4.10";
  src = fetchurl {
    url = "https://github.com/qier222/YesPlayMusic/releases/download/v${version}/YesPlayMusic-${version}.AppImage";
    sha256 = "sha256-Qj9ZQbHqzKX2QBlXWtey/j/4PqrCJCObdvOans79KW4="; 
  };
  appimgContents = appimageTools.extractType2 { inherit pname version src; };
  
in

appimageTools.wrapType2 {
  inherit pname version src;


  extraPkgs = pkgs: with pkgs; [
    nss
    libxshmfence
    libappindicator-gtk3
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimgContents}/yesplaymusic.desktop $out/share/applications/yesplaymusic.desktop
    install -m 444 -D ${appimgContents}/yesplaymusic.png $out/share/icons/hicolor/512x512/apps/yesplaymusic.png

    substituteInPlace $out/share/applications/yesplaymusic.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname} --no-sandbox'
    '';
  
}
