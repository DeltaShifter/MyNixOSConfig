{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    
    shellAliases = {
      nixadd = "sudo nano +(math (grep -n '# ---PkgsEnd---' /etc/nixos/modules/programs.nix | cut -d: -f1) - 1) /etc/nixos/modules/programs.nix";
      nixupd = "sudo sh -c 'nixos-rebuild switch 2>&1| nom'";
      nixclean = "sudo nix-collect-garbage -d";
      proxyon = "export http_proxy=http://127.0.0.1:20172 https_proxy=http://127.0.0.1:20172 && curl -I --connect-timeout 3 https://www.google.com";
    };
  };

  users.users.dale.shell = pkgs.fish;
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    starship 
  ];

  programs.starship = {
    enable = true;
  };
}
