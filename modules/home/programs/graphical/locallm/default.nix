{
  config,
  namespace,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkEnableOption
    mkOption
    ;
  cfg = config.${namespace}.programs.graphical.locallm;
in
{
  options.${namespace}.programs.graphical.locallm = {
    enable = mkEnableOption "locallm - Local LLM interface";

    defaultModel = mkOption {
      type = types.str;
      default = "llama3.2:3b";
      description = "Default Ollama model to use";
    };

    ollamaUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:11434";
      description = "URL of the Ollama API";
    };

    autoCopy = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically copy responses to clipboard";
    };

    showGpuStats = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to show GPU statistics";
    };

    systemPrompt = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional system prompt for the model";
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence.directories = [ ".config/locallm" ];

    # Enable the upstream locallm module
    programs.locallm = {
      enable = true;
      inherit (cfg)
        defaultModel
        ollamaUrl
        autoCopy
        showGpuStats
        systemPrompt
        ;
    };
  };
}

