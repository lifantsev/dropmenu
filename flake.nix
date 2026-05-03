{
    description = "wm-agnostic dmenu program utilizing a dropdown window with fzf";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

        lg.url = "github:lifantsev/lg";
        lg.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, ... }@args: {
        packages = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: {
            dropmenu = import ./src/dropmenu.nix args system;
            dropmenu-ui = import ./src/dropmenu-ui.nix args system;
        });

        nixosModules.default = { pkgs, ... }: {
            nixpkgs.overlays = [(final: prev: {
                dropmenu = self.packages.${final.system}.dropmenu;
                dropmenu-ui = self.packages.${final.system}.dropmenu-ui;
            })];

            environment.systemPackages = with pkgs; [ dropmenu dropmenu-ui ];
        };

        homeManagerModules = {};
    };
}
