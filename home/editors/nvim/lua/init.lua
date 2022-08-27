local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')
local util = lspconfig.util

-- Needed for the Lua LSP to understand the Neovim API
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

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



-- -- keys

-- Find files using Telescope command-line sugar.

map{'<leader>ff', '<cmd>Telescope find_files<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>fg', '<cmd>Telescope live_grep<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>fb', '<cmd>Telescope buffers<cr>', 'n', { noremap=true, silent=true }}
map{'<leader>fh', '<cmd>Telescope help_tags<cr>', 'n', { noremap=true, silent=true }}



require('completion')