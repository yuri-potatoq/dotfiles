local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')
local util = lspconfig.util

-- Needed for the Lua LSP to understand the Neovim API
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')


-- local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities


-- All servers are installed by Nix
local servers = {
    { name = 'gopls', opts = {} },
    { name = 'pyright', opts = {} },
    { name = 'rnix', opts = {} },
    { name = 'rust_analyzer', opts = {} },
    { name = 'ocamllsp', opts = {} },
}


-- Load all setups
for _, server in ipairs(servers) do
    -- Default setup
    local setup = {
        capabilities = capabilities,
    }

    -- Merge opts with default setup
    for k,v in pairs(server.opts) do
        setup[k] = v
    end

    lspconfig[server.name].setup(setup)
end


-- -- Key mapper

local map = function(params)
    setmetatable(params, { __index = { mode = 'n', opts = { noremap = true } } })
    local from, to, mode, opts =
      params[1] or params.from,
      params[2] or params.to,
      params[3] or params.mode,
      params[4] or params.opts

    vim.api.nvim_set_keymap(mode, from, to, opts)
end



-- -- key bindings

-- Find files using Telescope command-line sugar.

map{'<leader>ff', '<cmd>Telescope find_files<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>lg', '<cmd>Telescope live_grep<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>lb', '<cmd>Telescope buffers<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>ht', '<cmd>Telescope help_tags<cr>', 'n', { noremap=true, silent=true }}

-- File tree
map{'<leader>tt', '<cmd>NvimTreeToggle<cr>', 'n', { noremap=true, silent=true }}

-- -- Edit
map{'<C-S>', '<Esc>:update<cr>gi', 'i', {noremap=true, silent=false}}
map{'<C-S>', ':update<cr>', 'n', {noremap=true, silent=false}}
map{'<C-f>', ':lua vim.lsp.buf.format()<CR>', 'n', {noremap=true, silent=true}}
map{'<C-u>', ':lua vim.lsp.buf.code_action()<CR>', 'n', {noremap=true, silent=true}}
map{'<C-k>', ':lua vim.lsp.buf.signature_help<CR>', 'i', {noremap=true, silent=true}}
map{'[d', ':lua vim.lsp.diagnostic.goto_prev()<CR>', 'n', {noremap=true, silent=true}}
map{']d', ':lua vim.lsp.diagnostic.goto_next()<CR>', 'n', {noremap=true, silent=true}}

-- map{'<A-j>', ':m .+1<CR>==', 'n', {noremap=true, silent=true} }
-- map{'<A-k>', ':m .-2<CR>==', 'n', {noremap=true, silent=true} }
-- map{'<A-j>', '<ESC>:m .+1<CR>==gi ', 'i', {noremap=true, silent=true} }
-- map{'<A-k>', '<ESC>:m .-2<CR>==gi ', 'i', {noremap=true, silent=true} }
-- map{'<A-j>', ":m '>+1<CR>gv=gv", 'v', {noremap=true, silent=true} }
-- map{'<A-k>', ":m '<-2<CR>gv=gv", 'v', {noremap=true, silent=true} }
--
-- inoremap <A-j> <Esc>:m .+1<CR>==gi
-- inoremap <A-k> <Esc>:m .-2<CR>==gi
-- vnoremap <A-j> :m '>+1<CR>gv=gv
-- vnoremap <A-k> :m '<-2<CR>gv=gv


-- map{'<buffer> <expr><C-f>', 'lsp#scroll(+4)', 'i', {noremap=true, silent=true}}
-- map{'<buffer> <expr><C-d>', 'lsp#scroll(-4)', 'i', {noremap=true, silent=true}}

require("nvim-tree").setup()
require("nvim-web-devicons").setup()
require('completion').setup()
require('rust-tools').setup()
