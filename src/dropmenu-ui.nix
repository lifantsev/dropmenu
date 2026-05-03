{ nixpkgs, lg, ... }: system: let
    pkgs = import nixpkgs { inherit system; };
    lg_pkg = lg.packages.${system}.default;
in pkgs.resholve.writeScriptBin "dropmenu-ui"
{
    interpreter = "${pkgs.bash}/bin/bash";

    execer = [
        "cannot:${pkgs.fzf}/bin/fzf"
        "cannot:${lg_pkg}/bin/lg"
    ];

    keep.source = [ "$show_sh" "$hide_sh" ];

    inputs = [
        pkgs.coreutils
        lg_pkg
        pkgs.fzf
        pkgs.gnugrep
        pkgs.gnused
        pkgs.gawk
    ];
} (builtins.readFile ./dropmenu-ui.sh)
