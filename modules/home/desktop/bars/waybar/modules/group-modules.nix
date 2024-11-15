{
  lib,
  namespace,
  osConfig,
  ...
}:
{
  "group/audio" = {
    orientation = "horizontal";
    drawer = {
      transition-duration = 500;
      transition-left-to-right = false;
    };
    modules = [
      "pulseaudio"
      "pulseaudio/slider"
    ];
  };

  "group/power" = {
    orientation = "horizontal";
    drawer = {
      transition-duration = 500;
      children-class = "not-power";
      transition-left-to-right = false;
    };
    modules = [ "custom/wlogout" ];
  };

  "group/tray" = {
    orientation = "horizontal";
    modules = [ "tray" ];
  };

  "group/stats" = {
    orientation = "horizontal";
    modules = [
      "cpu"
      "memory"
      "temperature"
    ];
  };

  "group/tidbits" = {
    orientation = "horizontal";
    modules = [
      "pulseaudio"
			"custom/vpn"
    ];
  };
}
