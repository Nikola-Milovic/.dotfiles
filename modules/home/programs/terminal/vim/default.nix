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

        " Keep the fzf picker readable regardless of the active highlight defaults.
        highlight FzfNormal guifg=#cad3f5 guibg=#24273a ctermfg=189 ctermbg=237
        highlight FzfSelection guifg=#cad3f5 guibg=#363a4f ctermfg=189 ctermbg=238
        highlight FzfAccent guifg=#8aadf4 guibg=#24273a ctermfg=111 ctermbg=237
        highlight FzfMuted guifg=#a5adcb guibg=#24273a ctermfg=146 ctermbg=237

        let g:fzf_colors =
        \ { 'fg':      ['fg', 'FzfNormal'],
          \ 'bg':      ['bg', 'FzfNormal'],
          \ 'query':   ['fg', 'FzfNormal'],
          \ 'hl':      ['fg', 'FzfAccent'],
          \ 'fg+':     ['fg', 'FzfSelection'],
          \ 'bg+':     ['bg', 'FzfSelection'],
          \ 'hl+':     ['fg', 'FzfAccent'],
          \ 'info':    ['fg', 'FzfMuted'],
          \ 'border':  ['fg', 'FzfMuted'],
          \ 'prompt':  ['fg', 'FzfAccent'],
          \ 'pointer': ['fg', 'FzfAccent'],
          \ 'marker':  ['fg', 'FzfAccent'],
          \ 'spinner': ['fg', 'FzfAccent'],
          \ 'header':  ['fg', 'FzfMuted'] }

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
