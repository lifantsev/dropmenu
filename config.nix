{ lib, config, ... }: let
    cfg = config.programs.dropmenu;
in lib.mkIf cfg.enable
(lib.mkMerge
    [
        {
            xdg.configFile."dropmenu/show.sh".text = cfg.show;
            xdg.configFile."dropmenu/hide.sh".text = cfg.hide;
        }

        (lib.mkIf cfg.integrations.niridrop {
            programs.niri.niridrop.windows.dropmenu-ui = {
                app_id = "dropmenu-ui";
                cmd = "kitty --class dropmenu-ui dropmenu-ui";
                lazy = false;
            };
        })

        (lib.mkIf (cfg.showhide == "niridrop") {
            programs.dropmenu.show = "niridrop --show dropmenu-ui --forget";
            programs.dropmenu.hide = "niridrop --hide dropmenu-ui --forget";
        })

        (lib.mkIf (cfg.showhide == "pyprland") {
            programs.dropmenu.show = "pypr show dropmenu-ui";
            programs.dropmenu.hide = "pypr hide dropmenu-ui";
        })
    ])
