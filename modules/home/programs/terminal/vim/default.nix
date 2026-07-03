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
    home.packages = with pkgs; [
      ripgrep
      vifm
    ];

    programs.vim = {
      enable = true;
      packageConfigurable = pkgs.vim-full;
      plugins = with pkgs.vimPlugins; [
        fzf-vim
        catppuccin-vim
        vim-dirvish
        nerdtree
        vifm-vim
      ];
      extraConfig = ''
        let mapleader = " "
        let maplocalleader = " "

        nnoremap <silent> <Space> <Nop>

        set clipboard^=unnamedplus
        set ignorecase
        set smartcase

        colorscheme catppuccin_macchiato

        let g:vifm_exec = '${lib.getExe pkgs.vifm}'

        let g:loaded_netrwPlugin = 1
        command! -nargs=? -complete=dir Explore Dirvish <args>
        command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
        command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>

        " Keep the fzf picker readable regardless of the active highlight defaults.
        let s:fzf_default_opts = get(environ(), 'FZF_DEFAULT_OPTS', "")
        let $FZF_DEFAULT_OPTS = trim(s:fzf_default_opts . ' --height=80% --layout=reverse --border --color=fg:#cad3f5,bg:#24273a,hl:#8aadf4,fg+:#cad3f5,bg+:#363a4f,hl+:#8aadf4,info:#a5adcb,prompt:#8aadf4,pointer:#8aadf4,marker:#8aadf4,spinner:#8aadf4,header:#a5adcb,border:#6e738d')

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
        nnoremap <silent> <leader>/ :RG<CR>
        nnoremap <silent> <leader>e :Explore<CR>
        nnoremap <silent> <leader>E :NERDTreeToggle<CR>
        nnoremap <silent> <leader>n :NERDTreeToggle<CR>
        nnoremap <silent> <leader>N :NERDTreeFind<CR>
        nnoremap <silent> <leader>v :Vifm<CR>
      '';
    };
  };
}
