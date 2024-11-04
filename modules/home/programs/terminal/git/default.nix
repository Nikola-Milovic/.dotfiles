{
  config,
  lib,
  pkgs,
  namespace,
  osConfig,
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkForce
    getExe'
    ;
  inherit (lib.${namespace}) mkOpt mkBoolOpt enabled;
  inherit (config.${namespace}) user;

  cfg = config.${namespace}.programs.terminal.tools.git;

  aliases = import ./aliases.nix;
  ignores = import ./ignores.nix;

  # tokenExports =
  #   lib.optionalString osConfig.${namespace}.security.sops.enable # Bash
  #     ''
  #       GITHUB_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
  #       export GITHUB_TOKEN
  #       GH_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
  #       export GH_TOKEN
  #     '';
in
{
  options.${namespace}.programs.terminal.tools.git = {
    enable = mkEnableOption "Git";
    includes = mkOpt (types.listOf types.attrs) [ ] "Git includeIf paths and conditions.";
    signByDefault = mkOpt types.bool false "Whether to sign commits by default.";
    signingKey =
      mkOpt types.str "${config.home.homeDirectory}/.ssh/id_ed25519"
        "The key ID to sign commits with.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bfg-repo-cleaner
      git-crypt
      git-filter-repo
      git-lfs
      gitflow
      gitleaks
      gitlint
    ];

    programs = {
      lazygit = {
        enable = true;
        settings = {
          keybinding.universal.return = "<c-l>";
          paging = {
            useConfig = true;
            colorarg = "always";
          };
        };
      };

      git = {
        enable = true;
        package = pkgs.gitFull;
        inherit (cfg) includes userName userEmail;
        inherit (aliases) aliases;
        inherit (ignores) ignores;

        delta = {
          enable = true;

          options = {
            dark = true;
            features = mkForce "decorations side-by-side navigate";
            line-numbers = true;
            navigate = true;
            side-by-side = true;
          };
        };

        extraConfig = {
          credential = {
            helper = ''${getExe' config.programs.git.package "git-credential-libsecret"}'';
            useHttpPath = true;
          };

          fetch = {
            prune = true;
          };

          init = {
            defaultBranch = "main";
          };

          lfs = enabled;

          pull = {
            rebase = true;
          };

          push = {
            autoSetupRemote = true;
            default = "current";
          };

          rebase = {
            autoStash = true;
          };

          safe = {
            directory = [
              "~/${namespace}/"
              "/etc/nixos"
            ];
          };
        };

        signing = {
          key = cfg.signingKey;
          inherit (cfg) signByDefault;
        };
      };

      gh = {
        enable = true;

        extensions = with pkgs; [
          gh-dash # dashboard with pull requests and issues
          gh-eco # explore the ecosystem
          gh-cal # contributions calender terminal viewer
          gh-poi # clean up local branches safely
        ];

        gitCredentialHelper = {
          enable = true;
        };

        settings = {
          version = "1";
        };
      };

      # bash.initExtra = tokenExports;
    };

    home = {
      inherit (aliases) shellAliases;
    };

    # TODO: sops
    # sops.secrets = lib.mkIf osConfig.${namespace}.security.sops.enable {
    #   "github/access-token" = {
    #     sopsFile = lib.snowfall.fs.get-file "secrets/khaneliman/default.yaml";
    #     path = "${config.home.homeDirectory}/.config/gh/access-token";
    #   };
    # };
  };
}
