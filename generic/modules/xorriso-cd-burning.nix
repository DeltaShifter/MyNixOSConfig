{ config, pkgs, lib, ... }:  

{
  environment.systemPackages = with pkgs; [
    xorriso 
  ];

  security.wrappers = {
    xorrecord = {
      setuid = true;
      owner = "root";
      group = "cdrom";
      permissions = "u+wrx,g+x";
      source = "${pkgs.xorriso}/bin/xorrecord";
    };
  };

}
