local M = {}

function M.setup()
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
        return
    end
    -- TODO switch to new syntax https://www.youtube.com/watch?v=9gUatBHuXE0 
    -- vim.api.nvim_create_autocmd("BufRead,BufEnter", {
    --   
    -- })

    local enable = true

    vim.cmd([[
      augroup _astro
      autocmd!
      autocmd BufRead,BufEnter *.astro set filetype=astro 
      augroup end
    ]])

    configs.setup({
        ensure_installed = "all", -- "all" (parsers with maintainers), or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "" }, -- List of parsers to ignore installing
        autopairs = {
            enable = true,
        },
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = { "" }, -- list of language that will be disabled
            additional_vim_regex_highlighting = true,
        },
        indent = { enable = true, disable = { "yaml" } },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
        incremental_selection = {
            enable = enable,
            keymaps = {
                -- mappings for incremental selection (visual mappings)
                init_selection = "gnn", -- maps in normal mode to init the node/scope selection
                node_incremental = "grn", -- increment to the upper named parent
                scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
                node_decremental = "grm", -- decrement to the previous node
            },
        },
        textobjects = {
            -- syntax-aware textobjects
            enable = enable,
            lsp_interop = {
                enable = enable,
                peek_definition_code = {
                    ["DF"] = "@function.outer",
                    ["DC"] = "@class.outer",
                },
            },
            keymaps = {
                ["iL"] = {
                    -- you can define your own textobjects directly here
                    go = "(function_definition) @function",
                },
                -- or you use the queries from supported languages with textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["aC"] = "@class.outer",
                ["iC"] = "@class.inner",
                ["ac"] = "@conditional.outer",
                ["ic"] = "@conditional.inner",
                ["ae"] = "@block.outer",
                ["ie"] = "@block.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["is"] = "@statement.inner",
                ["as"] = "@statement.outer",
                ["ad"] = "@comment.outer",
                ["am"] = "@call.outer",
                ["im"] = "@call.inner",
            },
            move = {
                enable = enable,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                },
                goto_next_end = {
                    ["]M"] = "@function.outer",
                    ["]["] = "@class.outer",
                },
                goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                },
                goto_previous_end = {
                    ["[M"] = "@function.outer",
                    ["[]"] = "@class.outer",
                },
            },
            select = {
                enable = enable,
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    -- Or you can define your own textobjects like this
                    --https://github.com/nvim-treesitter/nvim-treesitter/issues/1004
                    -- ["iF"] = {
                    -- 	python = "(function_definition) @function",
                    -- 	cpp = "(function_definition) @function",
                    -- 	c = "(function_definition) @function",
                    -- 	java = "(method_declaration) @function",
                    -- 	go = "(method_declaration) @function",
                    -- },
                },
            },
            swap = {
                enable = enable,
                swap_next = {
                    ["<leader>q"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>Q"] = "@parameter.inner",
                },
            },
        },
    })
end

return M
