{
  description = "Nixos config flake";

  inputs = rec {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs = nixpkgs-stable;

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    stylix.url = "github:danth/stylix";

    plugin-nvim-transparent.url = "github:xiyaowong/transparent.nvim";
    plugin-nvim-transparent.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let 
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {inherit system;};
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs pkgs-unstable;};
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
      ];
    };
  };
}
