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

    dropdownProgram = lib.mkOption {
        description = "this sets up the show/hide scripts: per window manager, which dropdown program to use to show the ui (if multiple are set, will detect which wm is currently running)";
        default = {};

        type = lib.types.submodule { options = {
            niri = lib.mkOption {
                description = "when using niri: which dropdown program to use to show/hide the ui window";
                type = lib.types.enum [ "none" "niridrop" ];
                default = "none";
                example = "niridrop";
            };

            hyprland = lib.mkOption {
                description = "when using hyprland: which dropdown program to use to show/hide the ui window";
                type = lib.types.enum [ "none" "pyprland" ];
                default = "none";
                example = "pyprland";
            };
        };};
    };
}
