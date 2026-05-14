{ self, nixpkgs, lg, ... }: system: let
    pkgs = import nixpkgs { inherit system; };
    lga = lg.packages.${system}.lga;
    lge = lg.packages.${system}.lge;
    dropmenu-ui_pkg = self.packages.${system}.dropmenu-ui;
in pkgs.resholve.writeScriptBin "dropmenu"
{
    interpreter = "${pkgs.bash}/bin/bash";

    execer = [
        "cannot:${dropmenu-ui_pkg}/bin/dropmenu-ui"
        "cannot:${lga}/bin/lga"
        "cannot:${lge}/bin/lge"
    ];

    inputs = [
        pkgs.coreutils
        lga lge
        dropmenu-ui_pkg
    ];
} (builtins.readFile ./dropmenu.sh)
