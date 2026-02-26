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
  
  start-script = pkgs.writeShellScript "start-lyrics-backend" ''
  cat ${lyrics-src}/backend/src/server.py | \
  ${pkgs.gnused}/bin/sed 's/self.manager = LyricsManager()/import time; self.manager = LyricsManager(); self.manager._last_poll = 0/' | \
  ${pkgs.gnused}/bin/sed '/def poll_status(self, requested_playername=None):/a \        curr = time.time()\n        if curr - getattr(self, "_last_poll", 0) < 1.0: return self.get_state()\n        self._last_poll = curr' | \
  ${lyrics-python}/bin/python -
  '';
 
in {
  # 定义服务
  systemd.user.services.lyrics-on-panel-backend = {
    description = "Lyrics-on-Panel MPRIS2 Backend";
    enable = true;
    
    # 保活，跟着桌面的生命周期
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    # 服务配置
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "${lyrics-src}/backend";
      ExecStart = start-script;
      
      Restart = "on-failure";
      RestartSec = 5;

    };

    # 环境变量注入
    environment = {
      PYTHONPATH = "${lyrics-src}/backend/src";
      PYTHONUNBUFFERED = "1";
    };

  };
}
