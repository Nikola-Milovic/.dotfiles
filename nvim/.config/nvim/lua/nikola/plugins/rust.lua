local M = {}

function M.setup()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    local rt = require("rust-tools")

    local extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb-1.8.1/"
    local codelldb_path = extension_path .. "adapter/codelldb"
    local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

    rt.setup({
        dap = {
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
        },
        tools = {
            inlay_hints = {
                only_current_line = true,
            },
        },
        server = {
            on_attach = function(client, bufnr)
                vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })

                vim.keymap.set("n", "<Leader>o", rt.code_action_group.code_action_group, { buffer = bufnr })
            end,
            settings = {
                ["rust-analyzer"] = {
                    lens = {
                        enable = true,
                    },
                    checkonsave = {
                        command = "clippy",
                    },
                },
            },
        },
    })
end

return M
