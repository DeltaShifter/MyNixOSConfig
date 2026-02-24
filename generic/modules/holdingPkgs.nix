{ lib, pkgs-stable , ...}:
  {
    nixpkgs.overlays = [
      (final: prev: {
        khal = pkgs-stable.khal;
        dwarfs = pkgs-stable.dwarfs;
      })
    ];
  }
