return {
  "ThePrimeagen/harpoon",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  keys = {
    {
      "<leader>a",
      function()
        require("harpoon.mark").add_file()
      end,
      desc = "Add to Harpoon",
    },
    {
      "<C-e>",
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      desc = "Toggle Harpoon Quick Menu",
    },
    {
      "<C-h>",
      function()
        require("harpoon.ui").nav_file(1)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-t>",
      function()
        require("harpoon.ui").nav_file(2)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-n>",
      function()
        require("harpoon.ui").nav_file(3)
      end,
      desc = "which_key_ignore",
    },
    {
      "<C-s>",
      function()
        require("harpoon.ui").nav_file(4)
      end,
      desc = "which_key_ignore",
    },
  },
}
