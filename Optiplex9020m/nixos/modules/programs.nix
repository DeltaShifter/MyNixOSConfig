{ config, pkgs, ... }:

{
# Install firefox.
  programs.firefox.enable = true;
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # 为 Steam 流式传输开启防火墙
  dedicatedServer.openFirewall = true;
  package = pkgs.steam.override {  # 防止黑屏
    extraArgs = "-system-composer";
    };
  };
  programs.gamescope.enable = true; # 开启gamescope取得更好的全屏体验
  
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;
  
  services.udisks2.enable = true; # 开启USB挂载
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
    fastfetch
    obsidian
    yazi
    lsd
    xray
    gparted
    pcmanfm
    google-chrome
    qq
    wechat
    papirus-icon-theme
    wpsoffice-cn
    ouch
    file-roller    
    brave
    intel-undervolt
    nh
    brasero
    cdrtools

 ]; # ---PkgsEnd---
}
