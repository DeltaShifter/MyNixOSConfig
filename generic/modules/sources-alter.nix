{ config, pkgs, lib, ... }:

{

  nix.settings = {
    # 优先使用国内镜像站
    substituters = lib.mkForce [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://dale-nix-cachix.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];

  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "dale-nix-cachix.cachix.org-1:N+YRpTWo6H8F1VA5hNZ3Uhl3zPiNtkiKspO9UcggJzM="
  ];

    # 增大下载缓存，防止大文件下载中断 (500MB)
    download-buffer-size = 524288000;
    
    connect-timeout = 5;
    fallback = true;
    
     # 自动优化存储，节省空间
     auto-optimise-store = true;
  };
 
}
