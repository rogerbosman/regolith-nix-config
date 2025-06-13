{ pkgs, inputs, ...}: 
{
    imports = [
        inputs.regolith.nixosModules.regolith
    ];
    regolith.enable = true;
    
    # enabled gnome to avoid any conflict because of gnome-dependencies required by regolith
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true; # gdm is required by gnome


    # uncomment if want to use greetd

    # services.greetd = {
    #   enable = true;
    #   vt = 3;
    #   settings = {
    #     default_session = {
    #       user = username;
    #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${inputs.regolith.packages.${pkgs.stdenv.hostPlatform.system}.regolith-session-wayland}/bin/regolith-environment"; 
    #     };
    #   };
    # };

}