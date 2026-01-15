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
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;
  
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
    bat
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
 ]; # ---PkgsEnd---
}
