filetype plugin indent on
syntax on

set ignorecase
set smartcase
set nu rnu
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set autoindent
set smartindent

" Start a Lua block to handle the LSP
lua << EOF
-- ==========================================================
-- 1. SET THE TRAPS (Visuals and Keybinds)
-- We must define these BEFORE we start the server
-- ==========================================================

-- Force Neovim to draw the error messages next to your code
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

-- Automatically bind keys ONLY when the LSP attaches to a file
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    
    -- Press Shift+K to show documentation on hover
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    
    -- Press 'gd' to jump to a function's definition
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    
    -- Enable Neovim's built-in autocompletion menu
    vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
  end,
})

-- ==========================================================
-- 2. LAUNCH THE SERVER 
-- ==========================================================
local bundle_path = vim.fn.stdpath("data") .. "/pses"

vim.lsp.config("powershell_es", {
  bundle_path = bundle_path,
  root_dir = vim.fn.getcwd(),
  settings = {
    powershell = {
      scriptAnalysis = { Enable = true }
    }
  }
})

-- Enable the server (This will now safely trigger the LspAttach event above)
vim.lsp.enable("powershell_es")

-- ==========================================================
-- 3. SETUP C/C++ LSP (clangd)
-- ==========================================================
local clangd_path = vim.fn.stdpath("data") .. "/clangd/bin/clangd.exe"

vim.lsp.config("clangd", {
  cmd = { clangd_path },
  root_dir = vim.fn.getcwd(),
})

vim.lsp.enable("clangd")
EOF
