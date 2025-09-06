{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  # Define the configuration variable
  cfg = config.${namespace}.system.keyboard;

  # Define a list of available keyboard layouts.
  # This makes it easy to add new layouts in the future.
  availableLayouts = [
    "real-prog-dvorak"
    "lemi-dvorak"
  ];

  # Define the extra layouts that can be enabled.
  # This is a map where the keys are the layout names and the values
  # are their corresponding definitions.
  extraLayouts = {
    real-prog-dvorak = {
      description = "Real programmers dvorak";
      languages = [ "eng" ];
      symbolsFile = ./keyboards/real-prog-dvorak;
    };
    lemi-dvorak = {
      description = "Lemi dvorak variant";
      languages = [ "eng" ];
      symbolsFile = ./keyboards/lemi-dvorak;
    };
  };

in
{
  options.${namespace}.system.keyboard = with types; {
    layout = mkOption {
      # Use an enum type to restrict the selection to our predefined list.
      type = enum availableLayouts;
      default = "real-prog-dvorak";
      description = "Selects the custom keyboard layout to be used.";
    };
  };

  config = mkIf (lib.elem cfg.layout availableLayouts) {
    services.xserver = {
      # Enable the specified extra layout by selecting it from the map.
      xkb.extraLayouts = {
        ${cfg.layout} = extraLayouts.${cfg.layout};
      };

      # Set the xserver layout and variant based on the user's choice.
      xkb.layout = "us";
      xkb.variant = cfg.layout;
    };

    console.useXkbConfig = true;
  };
}
