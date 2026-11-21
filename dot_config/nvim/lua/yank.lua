-- https://xata.io/blog/configuring-neovim-coding-agents
-- modified from:
-- https://github.com/richardgill/nix/blob/bdd30a0/modules/home-manager/dot-files/nvim/lua/custom/yank.lua
local M = {}

M.get_buffer_absolute = function()
  return vim.fn.expand '%:p'
end

M.get_buffer_git_relative = function()
  local abs = vim.fn.expand '%:p'
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(vim.fn.expand '%:p:h') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root then
    return vim.fn.expand '%:.'
  end
  if git_root:sub(-1) ~= '/' then
    git_root = git_root .. '/'
  end
  return abs:sub(#git_root + 1)
end

M.get_visual_bounds = function()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    error('get_visual_bounds must be called in visual or visual-line mode (current mode: ' .. vim.inspect(mode) .. ')')
  end
  local is_visual_line_mode = mode == 'V'
  local start_pos = vim.fn.getpos 'v'
  local end_pos = vim.fn.getpos '.'

  return {
    start_line = math.min(start_pos[2], end_pos[2]),
    end_line = math.max(start_pos[2], end_pos[2]),
    start_col = is_visual_line_mode and 0 or math.min(start_pos[3], end_pos[3]) - 1,
    end_col = is_visual_line_mode and -1 or math.max(start_pos[3], end_pos[3]),
    mode = mode,
    start_pos = start_pos,
    end_pos = end_pos,
  }
end

M.format_line_range = function(start_line, end_line)
  return start_line == end_line and tostring(start_line) or start_line .. '-' .. end_line
end

M.simulate_yank_highlight = function()
  local bounds = M.get_visual_bounds()

  local ns = vim.api.nvim_create_namespace 'simulate_yank_highlight'
  vim.hl.range(0, ns, 'IncSearch', { bounds.start_line - 1, bounds.start_col }, { bounds.end_line - 1, bounds.end_col }, { priority = 200 })
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end, 150)
end

M.exit_visual_mode = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end

local function git(dir, args)
  local out = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' ' .. args)[1]
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return out
end

-- Handles https://host/o/r.git, ssh://user@host[:port]/o/r.git, and scp-style user@host:o/r.git
M.remote_to_web = function(remote)
  local url = remote:gsub('%.git$', ''):gsub('/$', '')
  local host, repo
  local rest = url:match '^%a[%w+.-]*://(.+)$'
  if rest then
    host, repo = rest:gsub('^[^@/]*@', ''):match '^([^/:]+)[^/]*/(.+)$'
  else
    host, repo = url:match '^[^@]*@?([^:/]+):(.+)$'
  end
  if not host then
    return nil
  end
  return 'https://' .. host .. '/' .. repo
end

M.get_github_url = function(line_range)
  local dir = vim.fn.expand '%:p:h'
  local remote = git(dir, 'remote get-url origin')
  local base = remote and M.remote_to_web(remote)
  local sha = git(dir, 'rev-parse HEAD')
  if not base or not sha then
    return nil
  end
  local path = M.get_buffer_git_relative():gsub('[^%w/._~-]', function(c)
    return string.format('%%%02X', c:byte())
  end)
  local url = base .. '/blob/' .. sha .. '/' .. path
  if line_range then
    url = url .. '#L' .. line_range:gsub('-', '-L')
  end
  return url
end

M.yank_github_url = function()
  local url = M.get_github_url()
  if not url then
    return vim.notify('No git remote for this buffer', vim.log.levels.WARN)
  end
  vim.fn.setreg('+', url)
  print('Yanked ' .. url)
end

M.yank_visual_github_url = function()
  local bounds = M.get_visual_bounds()
  local url = M.get_github_url(M.format_line_range(bounds.start_line, bounds.end_line))
  if not url then
    M.exit_visual_mode()
    return vim.notify('No git remote for this buffer', vim.log.levels.WARN)
  end
  vim.fn.setreg('+', url)
  M.simulate_yank_highlight()
  M.exit_visual_mode()
  print('Yanked ' .. url)
end

M.yank_path = function(path, label)
  local result = '@' .. path
  vim.fn.setreg('+', result)
  print('Yanked ' .. label .. ' path: ' .. result)
end

M.yank_visual_with_path = function(path, label)
  local bounds = M.get_visual_bounds()

  local line_range = M.format_line_range(bounds.start_line, bounds.end_line)
  local result = '@' .. path .. '#' .. line_range
  vim.fn.setreg('+', result)

  M.simulate_yank_highlight()

  M.exit_visual_mode()

  print('Yanked ' .. label .. ' with lines ' .. line_range)
end

return M
