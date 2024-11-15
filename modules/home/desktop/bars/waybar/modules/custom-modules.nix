{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe';
in
{
  "custom/ellipses" = {
    format = "";
    tooltip = false;
  };

  "custom/lock" = {
    format = "󰍁";
    tooltip = false;
    on-click = "${getExe config.programs.swaylock.package}";
  };

  "custom/separator-right" = {
    format = "";
    tooltip = false;
  };

  "custom/separator-left" = {
    format = "";
    tooltip = false;
  };

  "custom/weather" = {
    exec = "${getExe pkgs.wttrbar} --location Belgrade";
    return-type = "json";
    format = "{}";
    tooltip = true;
    interval = 3600;
  };

  "custom/wlogout" = {
    format = "";
    interval = "once";
    tooltip = false;
    on-click = "${getExe' pkgs.coreutils "sleep"} 0.1 && ${getExe pkgs.wlogout} -c 5 -r 5 -p layer-shell";
  };

  "custom/vpn" = {
    interval = 3;
    exec = "${getExe pkgs.custom.waybar-vpn-status}";
    format = "{}{icon}";
    return-type = "json";
  };
}
