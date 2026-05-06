{ lib, ... }: {
    enable = lib.mkEnableOption "setup of show/hide scripts and integrations";

    show = lib.mkOption {
        description = "bash script to put into .config/dropmenu/show.sh (should show dropmenu-ui window)";
        type = lib.types.str;
        default = "";
        example = ''
            niridrop dropmenu-ui --show --forget
        '';
    };

    hide = lib.mkOption {
        description = "bash script to put into .config/dropmenu/hide.sh (should hide dropmenu-ui window)";
        type = lib.types.str;
        default = "";
        example = ''
            niridrop dropmenu-ui --hide --forget
        '';
    };

    integrations.niridrop = lib.mkEnableOption "usage of the niridrop module to create the configuration for the dropmenu-ui dropdown";

    showhide = lib.mkOption {
        description = "set up show/hide scripts using the premade scripts for this dropdown program";
        type = lib.types.enum [ "" "niridrop" "pyprland" ];
        default = "";
        example = "niridrop";
    };
}
