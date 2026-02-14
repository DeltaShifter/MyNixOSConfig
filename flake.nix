{
  description = "Dale`s NixOS configuration with auto-module loading";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
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
    
    yazi-plugins = {
      url = "git+https://github.com/yazi-rs/plugins.git";
      flake = false;
    };
  
    fastfetch-presets = {
      url = "git+https://github.com/LierB/fastfetch.git";
      flake = false;
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
   
  };

    
  outputs = { self, nixpkgs,nixpkgs-stable,yazi-plugins,fastfetch-presets,nixos-hardware,home-manager,nur, nix-index-database, ... }@inputs: 

  let
    system = "x86_64-linux";
  
    # 自动扫描 modules 目录下的所有 .nix 文件
    lib = nixpkgs.lib;
    configDir = ./generic/modules;
    findAllNixFiles = path:
      let
        content = builtins.readDir path;
      in
      lib.flatten (lib.mapAttrsToList (name: type:
        let 
          fullPath = path + "/${name}";
        in
        if type == "directory" then
          # 如果是目录，递归进去
          findAllNixFiles fullPath
        else if type == "regular" && lib.hasSuffix ".nix" name then
          # 如果是 nix 文件，返回路径列表
          [ fullPath ]
        else
          # 其他文件忽略
          [ ]
      ) content);
    # 调用函数获取所有nix
    generatedModules = findAllNixFiles configDir;
    
     # HM通用设置
    homeManagerConfig = { ... }: {
      imports = [ home-manager.nixosModules.home-manager ];
           home-manager.useGlobalPkgs = true;
           home-manager.useUserPackages = true;
           home-manager.backupFileExtension = "hmBak";
           home-manager.extraSpecialArgs = { inherit inputs; };# 别忘了继承变量传递inputs
           home-manager.users.dale = import ./generic/home.nix;
      };

     # Nix-Stable
     nixpkgs-stable = import nixpkgs-stable {
       inherit system;
       config.allowUnfree = true;
     };
      
     # NUR
     nurModule = { ... }:{
       imports = [inputs.nur.modules.nixos.default];
       };

   in
  
  {
  
    nixosConfigurations.Optiplex = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixpkgs-stable; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/Optiplex9020m/configuration.nix
        homeManagerConfig
        nurModule
        nix-index-database.nixosModules.default
      ] ++ generatedModules; 
    };
  

    nixosConfigurations.X1c = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixpkgs-stable; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/X1c/configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
        homeManagerConfig
        nurModule
      ] ++ generatedModules; 
    };
    
    nixosConfigurations.AlienwareAlpha = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixpkgs-stable; }; # 继承全部变量传递给inputs
      modules = [
        ./devices/AlienwareAlpha/configuration.nix
        homeManagerConfig
        nurModule
      ] ++ generatedModules; 
    };

  };
}

