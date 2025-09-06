return {
	{
		"milanglacier/minuet-ai.nvim",
		config = function(_, opts)
			require("minuet").setup({
				provider = "openai_fim_compatible",
				n_completions = 1, -- recommend for local model for resource saving
				-- I recommend beginning with a small context window size and incrementally
				-- expanding it, depending on your local computing power. A context window
				-- of 512, serves as an good starting point to estimate your computing
				-- power. Once you have a reliable estimate of your local computing power,
				-- you should adjust the context window to a larger value.
				context_window = 1024,
				provider_options = {
					openai_fim_compatible = {
						-- For Windows users, TERM may not be present in environment variables.
						-- Consider using APPDATA instead.
						api_key = "TERM",
						name = "Ollama",
						end_point = "http://localhost:11434/v1/completions",
						model = "qwen2.5-coder:7b",
						optional = {
							max_tokens = 56,
							top_p = 0.9,
						},
					},
				},
			})
		end,
	},
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			keymap = {
				["<C-tab>"] = {
					function(cmp)
						cmp.show({ providers = { "minuet" } })
					end,
				},
			},
			sources = {
				-- 	-- if you want to use auto-complete
				-- 	default = { "minuet" },
				providers = {
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						score_offset = 100,
					},
				},
			},
		},
	},
	-- { -- minuet nvim-cmp setup
	-- 	"nvim-cmp",
	-- 	optional = true,
	-- 	opts = function(_, opts)
	-- 		-- if you wish to use autocomplete
	-- 		table.insert(opts.sources, 1, {
	-- 			name = "minuet",
	-- 			group_index = 1,
	-- 			priority = 100,
	-- 		})
	--
	-- 		opts.performance = {
	-- 			-- It is recommended to increase the timeout duration due to
	-- 			-- the typically slower response speed of LLMs compared to
	-- 			-- other completion sources. This is not needed when you only
	-- 			-- need manual completion.
	-- 			fetching_timeout = 2000,
	-- 		}
	--
	-- 		opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
	-- 			-- if you wish to use manual complete
	-- 			["<C-tab>"] = require("minuet").make_cmp_map(),
	-- 		})
	-- 	end,
	-- },
}

-- return {
-- 	{
-- 		"zbirenbaum/copilot.lua",
-- 		branch = "create-pull-request/update-copilot-dist",
--
-- 		config = function(_, opts)
-- 			local new_opts = vim.tbl_extend("force", opts, {
-- 				server_opts_overrides = {
-- 					cmd = {
-- 						"node",
-- 						vim.api.nvim_get_runtime_file("copilot/dist/language-server.js", false)[1],
-- 						"--stdio",
-- 					},
-- 					init_options = {
-- 						copilotIntegrationId = "vscode-chat",
-- 					},
-- 				},
-- 			})
--
-- 			require("copilot").setup(new_opts)
--
-- 			local util = require("copilot.util")
-- 			local orig_get_editor_configuration = util.get_editor_configuration
--
-- 			---@diagnostic disable-next-line: duplicate-set-field
-- 			util.get_editor_configuration = function()
-- 				local config = orig_get_editor_configuration()
--
-- 				return vim.tbl_extend("force", config, {
-- 					github = {
-- 						copilot = {
-- 							selectedCompletionModel = "gpt-4o-copilot",
-- 						},
-- 					},
-- 				})
-- 			end
--
-- 			return new_opts
-- 		end,
-- 	},
-- }
