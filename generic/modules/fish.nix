{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = "zoxide init fish | source";
    shellAliases = {
      nixadd = "hx ~/.MyNixConf/generic/modules/programs.nix:(math (grep -n '# ---PkgsEnd---' ~/.MyNixConf/generic/modules/programs.nix | cut -d: -f1) - 1)";
      nixupd = "nh os switch ~/.MyNixConf/";
      flakeupd = "nix flake update --flake ~/.MyNixConf/";
      nixclean = "sudo nix-collect-garbage -d";
      nixsync = "git --git-dir=$HOME/.MyNixConf/.git --work-tree=$HOME/.MyNixConf add . && git --git-dir=$HOME/.MyNixConf/.git --work-tree=$HOME/.MyNixConf commit -m 'auto sync' && git --git-dir=$HOME/.MyNixConf/.git --work-tree=$HOME/.MyNixConf push";
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
