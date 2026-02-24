{ lib, pkgs-stable , ...}:
{
 environment.systemPackages = lib.mkForce[
   pkgs-stable.khal
 ]; 
}
