{ nixpkgs, lg, ... }: system: let
    pkgs = import nixpkgs { inherit system; };
    lga = lg.packages.${system}.lga;
    lge = lg.packages.${system}.lge;
in pkgs.resholve.writeScriptBin "dropmenu-ui"
{
    interpreter = "${pkgs.bash}/bin/bash";

    execer = [
        "cannot:${pkgs.fzf}/bin/fzf"
        "cannot:${lga}/bin/lga"
        "cannot:${lge}/bin/lge"
    ];

    keep.source = [ "$show_sh" "$hide_sh" ];

    inputs = [
        pkgs.coreutils
        lga lge
        pkgs.fzf
        pkgs.gnugrep
        pkgs.gnused
        pkgs.gawk
    ];
} (builtins.readFile ./dropmenu-ui.sh)
