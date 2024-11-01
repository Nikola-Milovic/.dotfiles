{
  options,
  inputs,
  system,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.neovim;
in
{
  options.${namespace}.programs.terminal.neovim = with types; {
    enable = mkBoolOpt false "Enable Neovim";
  };

  config = mkIf cfg.enable {
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
