{ config, pkgs, pkgs-stable, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = "zoxide init fish | source";
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      nixadd = "hx ~/.MyNixConf/generic/modules/programs.nix:(math (grep -n '# ---PkgsEnd---' ~/.MyNixConf/generic/modules/programs.nix | cut -d: -f1) - 1)";
      nixupd = "nh os switch ~/.MyNixConf/ && nixsync";
      flakeupd = "nix flake update --flake ~/.MyNixConf/";
      nixclean = "sudo nix-collect-garbage -d";
      nixsync = "GEN=$(ls -1 /nix/var/nix/profiles/system-*-link | wc -l) && git -C $HOME/.MyNixConf add -A && git -C $HOME/.MyNixConf commit -m \"Update (Gen $GEN) $(date +'%Y-%m-%d %H:%M:%S')\" && git -C $HOME/.MyNixConf push";
      nixcachix =''nix path-info -r /run/current-system | cachix push dale-nix-cachix'';
      proxyon = "export http_proxy=http://127.0.0.1:20172 https_proxy=http://127.0.0.1:20172 && curl -I --connect-timeout 3 https://www.google.com";
      ff = "fastfetch --config hypr.jsonc";
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
