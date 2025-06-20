{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkForce
    mkEnableOption
    ;
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.hardware.audio;
in
{
  options.${namespace}.hardware.audio = with types; {
    enable = mkEnableOption "Audio";
    alsa-monitor = mkOpt attrs { } "Alsa configuration.";
    extra-packages = mkOpt (listOf package) [
      # FIXME: broken nixpkgs
      pkgs.easyeffects
    ] "Additional packages to install.";
    modules = mkOpt (listOf attrs) [ ] "Audio modules to pass to Pipewire as `context.modules`.";
    nodes = mkOpt (listOf attrs) [ ] "Audio nodes to pass to Pipewire as `context.objects`.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        pulsemixer
        pavucontrol
      ]
      ++ cfg.extra-packages;

    hardware.pulseaudio.enable = mkForce false;

    custom = {
      user.extraGroups = [ "audio" ];
    };

    security.rtkit.enable = true;

    # Disable audio power saving to prevent crackling
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=0
    '';

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    services.pulseaudio.enable = mkForce false;
  };
}
