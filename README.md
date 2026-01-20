自己的NixOS配置

NixOS+Niri+DMS
结构如下，主旨就是configuration.nix最小化通用化，modules\ 用于各种用途的配置，home-manager仅用于管理~\.config

'''.

└── nixos  
    ├── configuration.nix  
    ├── flake.lock  
    ├── flake.nix  
    ├── hardware-configuration.nix  
    ├── home.nix  # Home-Manager配置  
    ├── homeconfig # 利用home.nix的source方式管理~\.config中的一些配置  
    │   ├── Fcitx5ui.conf  
    │   ├── fuzzel.ini  
    │   └── niriConfig.kdl  
    └── modules # flake.nix中声明此文件夹下文件会自动用于构建  
        ├── dms.nix # DankMaterialShell配置  
        ├── fish.nix # sh配置  
        ├── flatpak.nix # Flatpak配置  
        ├── locale.nix # 中文环境、Fctix5输入法  
        ├── network-alter.nix # 软件源配置  
        └── programs.nix # 软件安装  
'''
