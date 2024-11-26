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
    format = "{}°C";
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

  # https://github.com/MaxVerevkin/wl-gammarelay-rs
  # wl-gammarelay temperature module
  "custom/wl-gammarelay-temperature" = {
    format = "{} 󰃝";
    exec = "${getExe pkgs.wl-gammarelay-rs} watch {t}";
    on-scroll-up = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +200
    '';
    on-scroll-down = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -200
    '';
  };

  # wl-gammarelay brightness module
  "custom/wl-gammarelay-brightness" = {
    format = "{}% ";
    exec = "${getExe pkgs.wl-gammarelay-rs} watch {bp}";
    on-scroll-up = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.04
    '';
    on-scroll-down = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.04
    '';
  };

  # wl-gammarelay gamma module
  "custom/wl-gammarelay-gamma" = {
    format = "{}% γ";
    exec = "${getExe pkgs.wl-gammarelay-rs} watch {g}";
    on-scroll-up = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateGamma d +0.02
    '';
    on-scroll-down = ''
      ${getExe' pkgs.systemd "busctl"} --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateGamma d -0.02
    '';
  };
}
