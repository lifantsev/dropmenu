{ self, nixpkgs, lg, ... }: system: let
    pkgs = import nixpkgs { inherit system; };
    lg_pkg = lg.packages.${system}.default;
    dropmenu-ui_pkg = self.packages.${system}.dropmenu-ui;
in pkgs.resholve.writeScriptBin "dropmenu"
{
    interpreter = "${pkgs.bash}/bin/bash";

    execer = [
        "cannot:${dropmenu-ui_pkg}/bin/dropmenu-ui"
        "cannot:${lg_pkg}/bin/lg"
    ];

    inputs = [
        pkgs.coreutils
        lg_pkg
        dropmenu-ui_pkg
    ];
} (builtins.readFile ./dropmenu.sh)
