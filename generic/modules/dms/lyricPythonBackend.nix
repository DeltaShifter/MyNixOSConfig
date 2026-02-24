{ config, pkgs, lib, ... }:

let
  lyrics-src = pkgs.fetchFromGitHub {
    owner = "KangweiZhu";
    repo = "lyrics-on-panel";
    rev = "main"; 
    sha256 = "sha256-IRmbfNzVgHC2uEzVOdIvYqEhx1wouWTB0zKPppiNTms="; 
  };


  # 依赖处理
  lyrics-python = pkgs.python3.withPackages (ps: with ps; [
    dbus-python
    websockets
    requests
    pygobject3
  ]);
  
  # 因为自身逆天占用，设置黑名单在部分机器上禁用
  manualStart = [
    "X1c"
    "AlienwareAlpha"
  ];
  
in {
  # 定义服务
  systemd.user.services.lyrics-on-panel-backend = {
    description = "Lyrics-on-Panel MPRIS2 Backend";

    # elem 获取主机名并对比黑名单，不匹配则返回true，实现黑名单
    enable = !(builtins.elem config.networking.hostName manualStart);
    
    # 保活，跟着桌面的生命周期
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    # 服务配置
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "${lyrics-src}/backend";
      ExecStart = "${lyrics-python}/bin/python src/server.py";
      
      Restart = "on-failure";
      RestartSec = 5;

      CPUWeight = 3;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";

    };

    # 环境变量注入
    environment = {
      PYTHONPATH = "${lyrics-src}/backend/src";
      PYTHONUNBUFFERED = "1";
    };

  };
}
