{ config, pkgs, ... }:

let
  lyrics-src = pkgs.fetchFromGitHub {
    owner = "KangweiZhu";
    repo = "lyrics-on-panel";
    rev = "main";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; 
  };

  lyrics-python = pkgs.python3.withPackages (ps: with ps; [
    dbus-python
    websockets
    pygobject3
    requests
  ]);

  start-script = pkgs.writeShellScriptBin "lyrics-on-panel-start" ''
    exec ${lyrics-python}/bin/python ${lyrics-src}/backend/src/server.py
  '';

in
{
  systemd.user.services.lyrics-on-panel-backend = {
    Unit = {
      Description = "Lyrics-on-Panel MPRIS2 Backend";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${start-script}/bin/lyrics-on-panel-start";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
