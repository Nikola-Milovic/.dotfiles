{
  options,
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.vim;
in
{
  options.${namespace}.programs.terminal.vim = with types; {
    enable = mkBoolOpt false "Enable vim";
  };

  config = mkIf cfg.enable {
    programs.vim = {
      enable = true;
      packageConfigurable = pkgs.vim-full;
      plugins = with pkgs.vimPlugins; [
        fzf-vim
        catppuccin-vim
      ];
      extraConfig = ''
        let mapleader = " "
        let maplocalleader = " "

        nnoremap <silent> <Space> <Nop>

        set clipboard^=unnamedplus
        set ignorecase
        set smartcase

        colorscheme catppuccin_macchiato

        let g:netrw_sort_options = "i"

        let g:fzf_colors =
        \ { 'fg':      ['fg', 'Normal'],
          \ 'bg':      ['bg', 'Normal'],
          \ 'query':   ['fg', 'Normal'],
          \ 'hl':      ['fg', 'Comment'],
          \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
          \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
          \ 'hl+':     ['fg', 'Statement'],
          \ 'info':    ['fg', 'PreProc'],
          \ 'border':  ['fg', 'Ignore'],
          \ 'prompt':  ['fg', 'Conditional'],
          \ 'pointer': ['fg', 'Exception'],
          \ 'marker':  ['fg', 'Keyword'],
          \ 'spinner': ['fg', 'Label'],
          \ 'header':  ['fg', 'Comment'] }

        function! s:OpenFilePicker() abort
          if exists(':Files') == 2
            execute 'Files'
            return
          endif

          execute 'Explore'
        endfunction

        nnoremap <silent> <leader><leader> :call <SID>OpenFilePicker()<CR>
        nnoremap <silent> <leader>e :Explore<CR>
      '';
    };
  };
}
