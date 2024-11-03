{
  options,
  inputs,
  system,
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;
  cfg = config.${namespace}.programs.terminal.neovim;
in
{
  options.${namespace}.programs.terminal.neovim = {
    enable = mkBoolOpt false "Enable Neovim";
  };

  config = mkIf cfg.enable {
    # Until the config is migrated to nix, we need to persist this
    ${namespace}.impermanence.directories = [ ".local/share/nvim" ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      package = inputs.neovim-nightly.packages.${system}.default;
      defaultEditor = true;
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink (lib.snowfall.fs.get-file "configs/nvim");
      recursive = true;
    };
  };
}
