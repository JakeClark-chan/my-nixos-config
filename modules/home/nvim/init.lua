-- Set the leader key to space
vim.g.mapleader = ' '

-- The directory where we will store our plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Check if the lazy.nvim plugin is already installed
if not vim.loop.fs_stat(lazypath) then
  -- If not, clone it from the official GitHub repository
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
-- Add the lazy.nvim path to Neovim's runtime path
vim.opt.rtp:prepend(lazypath)
-- The plugin manager setup. This is where we will add our plugins.
require("lazy").setup({
  -- Add plugins here
    {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
      -- This is where we put our configuration for nvim-tree
      require("nvim-tree").setup({
        -- Disable the default keybindings to let us define our own
        disable_netrw = true,
        hijack_netrw = true,
        -- You can add more configuration options here later
      })
    end,
    },
    {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- We'll add the configuration here in a moment
      require("telescope").setup({})
    end,
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
          -- A plugin to help with LSP setup. It's optional but very useful.
          "williamboman/mason.nvim",
          "williamboman/mason-lspconfig.nvim",
      },
      config = function()
        -- This is where we will put our LSP configuration
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "pyright", "nil_ls" }, -- Ensure these language servers are installed
        })
        -- Additional LSP setup can go here
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "L3MON4D3/LuaSnip",
      },
      config = function()
        -- nvim-cmp configuration will go here
        -- nvim-cmp configuration
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }),
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
        })
      end,
    },
}) 


-- Keybindings for nvim-tree
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = "Toggle NvimTree" })
-- Keybinding for Telescope
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
-- Keybindings for LSP
vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, { noremap = true, silent = true, desc = "View Diagnostics" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Previous Diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Next Diagnostic" })


-- Enable relative line numbers
vim.wo.relativenumber = true
vim.wo.number = true

-- Enable mouse support
vim.o.mouse = 'a'

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Enable file type detection
vim.cmd('filetype plugin indent on')