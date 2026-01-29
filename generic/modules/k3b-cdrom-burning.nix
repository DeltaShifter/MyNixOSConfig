{ config, pkgs, ... }:  

let
  # 超级大包装，用xorriso全面接管
  wrappedCdrecord = pkgs.writeShellScript "xorrecord-wrapper" ''
    exec ${pkgs.xorriso}/bin/xorrecord "$@"
  '';
  wrappedMkisofs = pkgs.writeShellScript "xorrisofs-wrapper" ''
    exec ${pkgs.xorriso}/bin/xorrisofs "$@"
  '';

in
{
  environment.systemPackages = with pkgs; [
    kdePackages.k3b
    xorriso
    dvdplusrwtools
    ]
  # 双重包装，把xorriso交付给root
  security.wrappers = {
    cdrecord = {
      setuid = true;
      owner = "root";
      group = "cdrom";
      permissions = "u+wrx,g+x";
      source = "${wrappedCdrecord}";
    };

    mkisofs = {
      setuid = true;
      owner = "root";
      group = "cdrom";
      permissions = "u+wrx,g+x";
      source = "${wrappedMkisofs}";
    };
  };

  users.groups.cdrom = {};
}
