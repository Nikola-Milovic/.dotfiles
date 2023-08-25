local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local function setup_lazy_plugin(plugin)
    if plugin.config then
        plugin.config(plugin)
    end
end

local plugins = {
    require('nikola.plugins.whichkey'),
    {
        "folke/tokyonight.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("nikola.colorscheme")
        end,
    },
    {
        "nvim-lua/popup.nvim",
    },
    {
        "nvim-lua/plenary.nvim",
    },
    {
        "numToStr/Comment.nvim",
        config = function()
            require("nikola.plugins.comment").setup()
        end,
        lazy = false,
    },
    {
        "akinsho/bufferline.nvim",
        config = function()
            require("nikola.plugins.bufferline").setup()
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("nikola.plugins.lualine").setup()
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("nikola.plugins.toggleterm").setup()
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("nikola.plugins.indentline").setup()
        end,
    },
    {
        "goolord/alpha-nvim",
        config = function()
            require("nikola.plugins.alpha").setup()
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            require("nikola.plugins.cmp").setup()
        end,
    },
    {
        "ray-x/go.nvim",
        ft = "go",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "ray-x/guihua.lua",
            "ray-x/sad.nvim",
        },
        config = function()
            require("nikola.plugins.go").setup()
        end,
    },
    {
        "simrat39/rust-tools.nvim",
        config = function()
            require("nikola.plugins.rust").setup()
        end,
        ft = "rust",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
    },
    {
        "ThePrimeagen/harpoon",
        config = function()
            require("nikola.plugins.harpoon").setup()
        end,
    },
    {
        "ThePrimeagen/git-worktree.nvim",
        config = function()
            require("nikola.plugins.worktree").setup()
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        config = function()
            require("nikola.plugins.telescope").setup()
        end,
        dependencies = {
            "nvim-telescope/telescope-ui-select.nvim",
        },
        keys = {
            { "<leader>ff",  "<CMD>Telescope find_files<CR>",      desc = "Files" },
            { "<leader>fh",  "<CMD>Telescope help_tags<CR>",       desc = "Help" },
            { "<leader>fk",  "<CMD>Telescope keymaps<CR>",         desc = "Keymaps" },
            { "<leader>fS",  "<CMD>Telescope spell_suggest<CR>",   desc = "Spelling" },
            { "<leader>fg",  "<CMD>Telescope live_grep<CR>",       desc = "Grep" },
            { "<leader>fG",  "<CMD>Telescope grep_string<CR>",     desc = "Find Word Under Cursor" },
            { "<leader>fcp", "<CMD>Telescope git_commits<CR>",     desc = "Git Commits For Project" },
            { "<leader>fcb", "<CMD>Telescope git_bcommits<CR>",    desc = "Git Commits For Buffer" },
            { "<leader>fb",  "<CMD>Telescope buffers<CR>",         desc = "Buffers" },
            { "<leader>f:",  "<CMD>Telescope command_history<CR>", desc = "Command History" },
            {
                "<leader>f/",
                "<CMD>Telescope current_buffer_fuzzy_find<CR>",
                desc = "Fuzzy Find In Current Buffer",
            },
            { "<leader>fss", "<CMD>Telescope lsp_document_symbols<CR>",          desc = "Find Document Symbols" },
            { "<leader>fsw", "<CMD>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Find Workspace Symbols" },
        },
    },
    {
        "zbirenbaum/copilot.lua",
        event = "VimEnter",
        config = function()
            vim.defer_fn(function()
                require("nikola.plugins.copilot").setup()
            end, 100)
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "copilot.lua" },
        config = function()
            vim.defer_fn(function()
                require("copilot_cmp").setup()
            end, 200)
        end,
    },
    {
        "L3MON4D3/LuaSnip",
    },
    {
        "rafamadriz/friendly-snippets",
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("nikola.lsp").setup()
        end,
        dependencies = {
            "folke/neodev.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            "williamboman/mason.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "williamboman/mason-lspconfig.nvim",
            "folke/lua-dev.nvim",
            "RRethy/vim-illuminate",
            "jose-elias-alvarez/null-ls.nvim",
            "fidget.nvim",
            "b0o/schemastore.nvim",
            "jose-elias-alvarez/typescript.nvim",
        },
    },
    {
        "j-hui/fidget.nvim",
        name = "fidget.nvim",
        config = function()
            require("fidget").setup()
        end,
        tag = "legacy",
    },
    -- Trouble
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({
                use_diagnostic_signs = true,
            })
        end,
    },

    -- Debug
    {
        "mfussenegger/nvim-dap",
        config = function()
            require("nikola.dap").setup()
        end,
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            "nvim-telescope/telescope-dap.nvim",
            { "jbyuki/one-small-step-for-vimkind" },
        },
    },
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-refactor",
            "nvim-treesitter/nvim-treesitter-context",
            "JoosepAlviste/nvim-ts-context-commentstring",
            "nvim-treesitter/playground",
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require("nikola.plugins.treesitter-context").setup()
        end,
    },
    -- Git
    {
        "kdheepak/lazygit.nvim",
    },
    {
        "ThePrimeagen/git-worktree.nvim",
    },

    -- Editorconfig
    {
        "gpanders/editorconfig.nvim",
    },
}

vim.g.mapleader = ' '

require("lazy").setup(plugins, {
    defaults = {
        lazy = true,
        setup = setup_lazy_plugin,
    },
    autosync = true,
})
