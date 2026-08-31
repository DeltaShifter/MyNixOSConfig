{ config, pkgs, lib, ... }:

{

  nix.settings = {
    # 优先使用国内镜像站
    substituters = lib.mkForce [
      "https://niri.cachix.org"
      "https://helix.cachix.org"
    ];

    trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];

  };
 
}
