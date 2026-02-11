{ config, pkgs, lib, ... }:

let
  # 1. 获取后端源码
  lyrics-src = pkgs.fetchFromGitHub {
    owner = "KangweiZhu";
    repo = "lyrics-on-panel";
    rev = "main"; 
    # 注意：如果构建报错，请替换为报错信息中给出的实际 hash
    sha256 = "sha256-brdHTft2DaH+0w/QoJCrUkYBiTRDakQT2lcSVwV7QuQ="; 
  };

  # 2. 构造专用的 Python 环境
  lyrics-python = pkgs.python3.withPackages (ps: with ps; [
    dbus-python
    websockets
    requests
    pygobject3
  ]);

in {
  # 3. 定义用户级 Systemd 服务
  systemd.user.services.lyrics-on-panel-backend = {
    # 单元基本描述
    description = "Lyrics-on-Panel MPRIS2 Backend";
    
    # 启动依赖：在图形界面会话准备好后再启动
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    # 服务核心配置
    serviceConfig = {
      Type = "simple";
      # 设置工作目录，确保 server.py 能找到同级的资源
      WorkingDirectory = "${lyrics-src}/backend";
      # 执行命令：使用我们构造的 python 环境运行脚本
      ExecStart = "${lyrics-python}/bin/python ${lyrics-src}/backend/src/server.py";
      
      # 故障自动重启逻辑
      Restart = "on-failure";
      RestartSec = 5;
    };

    # 环境变量注入
    environment = {
      PYTHONPATH = "${lyrics-src}/backend/src";
      PYTHONUNBUFFERED = "1"; # 确保日志能实时输出，方便 journalctl 查看
    };
  };
}
