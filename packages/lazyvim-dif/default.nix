{ pkgs, stdenv }:

pkgs.writeShellApplication {
  name = "lazyvim-diff";

  runtimeInputs = [ pkgs.ddcutil ];

  meta = with pkgs.lib; {
    description = "Script to check which plugins are required by lazyvim and which are installed";
    mainProgram = "lazyvim-diff";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };

  checkPhase = "";

  text = ''
    lazy_plugins() {
      nvim --headless -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do print(plugin.name) end' -c 'q' 2>&1 | grep -vxF 'lazy.nvim' | sort
    }

    nix_plugins() {
      dir=$(awk -F'"' '/path = / {print $2}' ~/.config/nvim/init.lua)
      ls -1 "$dir" | sort
    }

    diff -w -u --label nix <(nix_plugins) --label lazy <(lazy_plugins)
  '';
}
