{ config, pkgs, lib, ... }:

{

  nix.settings = {
    # 优先使用国内镜像站
    substituters = lib.mkForce [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://dale-nix-cachix.cachix.org"
      "https://helix.cachix.org"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "dale-nix-cachix.cachix.org-1:N+YRpTWo6H8F1VA5hNZ3Uhl3zPiNtkiKspO9UcggJzM="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
    ];

    # 增大下载缓存，防止大文件下载中断
    download-buffer-size = 1024 * 1024 * 1024;

    connect-timeout = 5;
    fallback = true;

    http2 = true;
    cores = 0;

    # 自动优化存储，节省空间
    auto-optimise-store = true;
  };

}
