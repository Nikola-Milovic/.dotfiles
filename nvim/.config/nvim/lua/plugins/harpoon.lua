return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  keys = {
    {
      "<leader>a",
      function()
        local harpoon = require("harpoon")
        harpoon:list():append()
      end,
      desc = "Add to Harpoon",
    },
    {
      "<C-e>",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Toggle Harpoon Quick Menu",
    },
    {
      "<C-h>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():select(1)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-t>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():select(2)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-n>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():select(3)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-s>",
      function()
        local harpoon = require("harpoon")
        harpoon:list():select(4)
      end,
      desc = "which_key_ignore",
    },
  },
}
