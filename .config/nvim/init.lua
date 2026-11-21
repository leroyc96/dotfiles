vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.undofile = true

-- Pick up edits made outside Neovim (e.g. by Claude); checktime errors in cmdline mode
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then vim.cmd("checktime") end
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "Mofiqul/vscode.nvim", priority = 1000, config = function() vim.cmd.colorscheme("vscode") end },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Skip for `nvim <dir>`, which neo-tree already opens as a full-window tree
          if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then return end
          vim.cmd("Neotree focus")
        end,
      })
    end,
    opts = {
      close_if_last_window = true,
      commands = {
        expand_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and node:is_expanded() then
            vim.cmd("normal! j")
          else
            state.commands.open(state)
          end
        end,
        collapse_or_parent = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and node:is_expanded() then
            state.commands.close_node(state)
          elseif node:get_parent_id() then
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
      },
      window = {
        mappings = {
          ["l"] = "expand_or_open",
          ["h"] = "collapse_or_parent",
        },
      },
      filesystem = {
        commands = {
          enter_dir_or_open = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("neo-tree.sources.filesystem.commands").set_root(state)
            else
              state.commands.open(state)
            end
          end,
          clear_filter_or_cancel = function(state)
            if state.search_pattern then
              state.commands.clear_filter(state)
            else
              state.commands.cancel(state)
            end
          end,
        },
        window = {
          mappings = {
            ["<cr>"] = "enter_dir_or_open",
            ["<esc>"] = "clear_filter_or_cancel",
          },
          fuzzy_finder_mappings = {
            ["<Esc>"] = "close_keep_filter",
          },
        },
        follow_current_file = { enabled = true },
        filtered_items = { hide_dotfiles = false },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        offsets = { { filetype = "neo-tree", text = "Explorer", separator = true } },
      },
    },
  },
  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").config({
        providers = {
          "hover.providers.diagnostic",
          "hover.providers.lsp",
          "hover.providers.man",
          "hover.providers.dictionary",
        },
        preview_opts = { border = "rounded" },
      })
    end,
  },
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = { ensure_installed = { "gopls", "ts_ls", "pyright" } },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "enter" },
      completion = { documentation = { auto_show = true } },
    },
  },
  { "lewis6991/satellite.nvim", opts = {} },
  { "lewis6991/gitsigns.nvim", opts = {} },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      pickers = {
        find_files = { find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" } },
      },
    },
  },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  {
    "tpope/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
    },
    config = function()
      vim.g.github_enterprise_urls = { 'https://coinbase.ghe.com' }
      vim.api.nvim_set_keymap('n', '<leader>g', ':.GBrowse<CR>', { noremap = true, silent = true })

      -- bypass netrw#BrowseX (E118 on newer netrw/fugitive combos) and open via vim.ui.open()
      vim.api.nvim_create_user_command('Browse', function(opts)
        vim.ui.open(opts.fargs[1])
      end, { nargs = 1 })
    end,
  },
})

local function map(mode, lhs, rhs, desc, extra)
  for _, l in ipairs(type(lhs) == "table" and lhs or { lhs }) do
    vim.keymap.set(mode, l, rhs, vim.tbl_extend("force", { desc = desc }, extra or {}))
  end
end
local function tb(picker)
  return function() require("telescope.builtin")[picker]() end
end

-- Cmd+Shift combos are listed in both forms since terminals report them inconsistently
map("n", { "<D-p>", "<leader>ff" }, tb("find_files"), "Find file")
map("n", { "<D-S-f>", "<D-F>", "<leader>fg" }, tb("live_grep"), "Search in files")
map("n", { "<D-S-p>", "<D-P>", "<leader>fp" }, tb("commands"), "Command palette")
map("n", { "<D-b>", "<leader>e" }, function()
  if vim.bo.filetype ~= "neo-tree" then return vim.cmd("Neotree focus") end
  vim.cmd("wincmd p")
  if vim.bo.filetype == "neo-tree" then
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local b = vim.api.nvim_win_get_buf(w)
      if vim.api.nvim_win_get_config(w).relative == "" and vim.bo[b].filetype ~= "neo-tree" then
        return vim.api.nvim_set_current_win(w)
      end
    end
  end
end, "Toggle sidebar focus")
map("n", { "<D-S-e>", "<D-E>" }, "<cmd>Neotree reveal<cr>", "Reveal file in sidebar")
map({ "n", "i" }, "<D-s>", "<cmd>write<cr>", "Save")
map("n", "<D-w>", "<cmd>bdelete<cr>", "Close buffer")
local function close_buffer(force)
  local buf = vim.api.nvim_get_current_buf()
  if not vim.bo[buf].buflisted then return end
  if vim.bo[buf].modified and not force then
    return vim.notify("Unsaved changes: :w to save or <leader>q to discard", vim.log.levels.WARN)
  end
  -- Switch away first so :bdelete doesn't also close the window and leave only the sidebar
  vim.cmd("BufferLineCyclePrev")
  if vim.api.nvim_get_current_buf() == buf then vim.cmd("enew") end
  vim.cmd("bdelete! " .. buf)
end
map("n", "<leader>w", function() close_buffer(false) end, "Close buffer")
map("n", "<leader>q", function() close_buffer(true) end, "Close buffer, discard changes")
local function quit(force)
  local editors = 0
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(w).relative == "" and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "neo-tree" then
      editors = editors + 1
    end
  end
  -- On the last editor window quit Neovim directly; neo-tree's close_if_last_window
  -- would otherwise reopen any modified buffer instead of honouring :q!
  local in_tree = vim.bo.filetype == "neo-tree"
  if in_tree and not force then return end
  local last = in_tree or (editors <= 1 and #vim.api.nvim_list_tabpages() == 1)
  local ok, err = pcall(vim.cmd, (last and "qa" or "q") .. (force and "!" or ""))
  if not ok then vim.notify(err:match("E%d+:.*") or err, vim.log.levels.WARN) end
end
map("n", "<C-c>", function() quit(false) end, "Quit window")
map("n", "<C-c><C-c>", function() quit(true) end, "Force quit window")
map("n", "<Esc>", function()
  vim.cmd("nohlsearch | cclose")
  -- hover.close() only checks the current buffer, but gd may have jumped away from the one that opened it
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.b[b].hover_preview then require("hover").close(b) end
  end
end, "Clear search highlight, close quickfix and hover")
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
local closed = {}
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(a)
    local name = vim.api.nvim_buf_get_name(a.buf)
    if name ~= "" and vim.bo[a.buf].buflisted then table.insert(closed, name) end
  end,
})
map("n", "<leader>t", function()
  local f = table.remove(closed)
  if f then vim.cmd.edit(vim.fn.fnameescape(f)) end
end, "Reopen closed buffer")
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(a)
    local client = vim.lsp.get_client_by_id(a.data.client_id)
    if not client or not client:supports_method("textDocument/formatting") then return end
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = a.buf,
      group = vim.api.nvim_create_augroup("lsp_format_" .. a.buf, { clear = true }),
      callback = function() vim.lsp.buf.format({ bufnr = a.buf, timeout_ms = 2000 }) end,
    })
  end,
})
-- Drop the gr* defaults, otherwise gr waits for timeoutlen before firing
for _, lhs in ipairs({ "grr", "gri", "grt", "grn", "gra", "grx" }) do
  pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, "x", "gra")
map("n", "gr", vim.lsp.buf.references, "Find references")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
map("n", "gn", vim.lsp.buf.rename, "Rename symbol")
map({ "n", "x" }, "ga", vim.lsp.buf.code_action, "Code action")
map("n", "gh", function() require("hover").open() end, "Hover")
map("n", { "gd", "<F12>" }, vim.lsp.buf.definition, "Go to definition")
map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
map({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>y", function() require("yank").yank_github_url() end, "Yank GitHub URL")
map("x", "<leader>y", function() require("yank").yank_visual_github_url() end, "Yank GitHub URL with lines")
map("n", "<D-/>", "gcc", "Toggle comment", { remap = true })
map("v", "<D-/>", "gc", "Toggle comment", { remap = true })
