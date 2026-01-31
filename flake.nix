{
  description = "Dale`s NixOS configuration with auto-module loading";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

      nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs,nixos-hardware,home-manager,nur, ... }@inputs: 

  let
    system = "x86_64-linux";
    # 自动扫描 modules 目录下的所有 .nix 文件
    configDir = ./generic/modules;
    generatedModules = map (file: configDir + "/${file}")  # 最终模块路径等于目录+文件名
      (builtins.filter (file: nixpkgs.lib.hasSuffix ".nix" file)  # 逐个检查扩展名是否为.nix,否则过滤
        (builtins.attrNames (builtins.readDir configDir))); # attrNames提取出最终文件名列表
    
     # HM通用设置
    homeManagerConfig = { ... }: {
      imports = [ home-manager.nixosModules.home-manager ];
           home-manager.useGlobalPkgs = true;
           home-manager.useUserPackages = true;
           home-manager.extraSpecialArgs = { inherit inputs; };# 别忘了继承变量传递inputs
           home-manager.users.dale = import ./generic/home.nix;
      };

     # NUR
     nurModule = { ... }:{
       imports = [inputs.nur.modules.nixos.default];
       };

  in
  {
    nixosConfigurations.Optiplex = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/Optiplex9020m/configuration.nix
        homeManagerConfig
        nurModule
      ] ++ generatedModules; 
    };
  

    nixosConfigurations.X1c = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/X1c/configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
        homeManagerConfig
        nurModule
      ] ++ generatedModules; 
    };
    
    nixosConfigurations.AlienwareAlpha = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/AlienwareAlpha/configuration.nix
        homeManagerConfig
        nurModule
      ] ++ generatedModules; 
    };

  };
}

