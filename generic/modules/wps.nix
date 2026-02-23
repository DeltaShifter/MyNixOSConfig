{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
    wpsoffice-cn = if config.networking.hostName == "X1c" 
      then prev.wpsoffice-cn.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
        postFixup = (oldAttrs.postFixup or "") + ''
          for bin in $out/bin/*; do
            wrapProgram "$bin" \
            --set QT_FONT_DPI "144" \
            --set QT_QPA_PLATFORM "xcb" \
            --set QT_IM_MODULE "fcitx" \
            --set XMODIFIERS "@im=fcitx"
          done
        '';
      })
    else prev.wpsoffice-cn;
  })
];

  environment.systemPackages = [
    pkgs.wpsoffice-cn
  ];
}
