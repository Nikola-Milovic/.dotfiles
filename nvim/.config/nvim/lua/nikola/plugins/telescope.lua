local keys = {
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
}

local keymap = vim.keymap.set

local function telescope_keymap()
    for _, key in ipairs(keys) do
        local trigger, command, desc = unpack(key)
        print("setting keymap", trigger, command)
        keymap("n", trigger, command, { noremap = true, silent = true })
    end
end

return {
    {
        "nvim-telescope/telescope.nvim",
        priority = 100,
        dependencies = {
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local status_ok, telescope = pcall(require, "telescope")
            if not status_ok then
                return
            end

            telescope_keymap()

            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {

                    prompt_prefix = " ",
                    selection_caret = " ",
                    path_display = { "smart" },

                    file_sorter = require("telescope.sorters").get_fzy_sorter,
                    color_devicons = true,

                    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

                    mappings = {
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,

                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,

                            ["<C-c>"] = actions.close,

                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,

                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,

                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,

                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<C-l>"] = actions.complete_tag,
                            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                        },

                        n = {
                            ["<esc>"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["H"] = actions.move_to_top,
                            ["M"] = actions.move_to_middle,
                            ["L"] = actions.move_to_bottom,

                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,

                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,

                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,

                            ["?"] = actions.which_key,
                        },
                    },
                },
                find_command = { "fd", "-t=f", "-a" },
                path_display = { "truncate" },
                pickers = {
                    find_files = {
                        -- I don't like having the cwd prefix in my files
                        find_command = vim.fn.executable("fdfind") == 1
                            and { "fdfind", "--strip-cwd-prefix", "--type", "f" }
                            or nil,

                        mappings = {
                            n = {
                                ["kj"] = "close",
                            },
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
                    -- Your extension configuration goes here:
                    -- extension_name = {
                    --   extension_config_key = value,
                    -- }
                    -- please take a look at the readme of the extension you want to configure
                },
            })

            telescope.load_extension("ui-select")
            telescope.load_extension("git_worktree")
        end,
    },
}
