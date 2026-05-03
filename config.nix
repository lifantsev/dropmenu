{ lib, config, ... }: let
    cfg = config.programs.dropmenu;
    dropPrograms = lib.filter (n: n != "none") (builtins.attrValues cfg.dropdownProgram);
    script = program: stem: (builtins.readFile (./scripts + "/${program}/${stem}.sh"));
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

        (with builtins; lib.mkIf (length dropPrograms == 1) {
            programs.dropmenu.show = if (length dropPrograms == 1) then
                script (head dropPrograms) "show" else "";

            programs.dropmenu.hide = if (length dropPrograms == 1) then
                script (head dropPrograms) "hide" else "";
        })

        (with builtins; lib.mkIf (length dropPrograms > 1) (let
            mkScript = showhide: /*sh*/ ''
            if false; then true
            ${lib.concatStringsSep "\n" (map (program: /*sh*/ ''
            elif ${script program "condition"}
            then
            ${script program showhide}
            '') dropPrograms)}
            else false; fi
            '';
        in {
            programs.dropmenu.show = mkScript "show";
            programs.dropmenu.hide = mkScript "hide";
        }))
    ])
