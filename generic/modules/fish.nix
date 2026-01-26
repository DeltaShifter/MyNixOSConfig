{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = "zoxide init fish | source";
    shellAliases = {
      nixadd = "hx ~/.MyNixConf/generic/modules/programs.nix:(math (grep -n '# ---PkgsEnd---' ~/.MyNixConf/generic/modules/programs.nix | cut -d: -f1) - 1)";
      nixupd = "nh os switch ~/.MyNixConf/";
      nixclean = "sudo nix-collect-garbage -d";
      proxyon = "export http_proxy=http://127.0.0.1:20172 https_proxy=http://127.0.0.1:20172 && curl -I --connect-timeout 3 https://www.google.com";
    };
  };

  users.users.dale.shell = pkgs.fish;
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    starship 
    zoxide
    bat
    fzf
    eza
  ];

  programs.starship = {
    enable = true;
  };
}
