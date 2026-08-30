{ config, pkgs, pkgs-stable, lib, ... }:


let
  wpsoffice-cn-dpi = pkgs.wpsoffice-cn.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      for file in $out/bin/*; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
          sed -i '2i export QT_FONT_DPI=144' "$file"
        fi
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
      pkgs.wpsoffice-cn)
  ];
}
