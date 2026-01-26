{ config, pkgs, ... }:

{
  programs.firefox.enable = true; # 火狐浏览器

  programs.steam = { # Steam
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
    nur.repos.chillcicada.ttf-ms-win10-sc-sup
    nur.repos.chillcicada.ttf-wps-fonts
    vim
    wget
    git
    gh
    helix
    fastfetch
    obsidian
    udiskie
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
    intel-undervolt
    nh
    thunderbird
    glide-media-player
   
 ]; # ---PkgsEnd---
}
