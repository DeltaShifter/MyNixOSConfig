{ config, pkgs, pkgs-stable, lib, ... }:


let
  wpsoffice-cn-dpi = pkgs-stable.wpsoffice-cn.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBulildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postFixup = (oldAttrs.postFixup or "") + ''
      for bin in $out/bin/*;do
      wrapProgram "$bin" --set QT_FONT_DPI "144"
      done
    '';
  });
in
{
  environment.systemPackages = [
    (if
      config.networking.hostName == "X1c"
    then
      wpsoffice-cn-dpi
    else
      pkgs-stable.wpsoffice-cn)
  ];
}
