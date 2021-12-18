local configHome = os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config'
local configDir = configHome .. '/nvim'

local M = {}

M.loaded = false

local separator = '----'

function M.global_config(dir)
  return configDir .. '/projects/' .. dir:gsub('^' .. os.getenv('HOME') .. '/', ''):gsub('/+$', ''):gsub('/', separator)
end

function M.local_config(dir)
  return dir .. '/.vim'
end

function M.find_config(gen)
  local pattern = '%:p'

  while true do
    pattern = pattern .. ':h'
    local dir = vim.fn.expand(pattern)

    if dir == '/' then
      return
    end

    for _, conf_dir_fn in pairs(gen) do
      local conf_dir = conf_dir_fn(dir)
      for _, ext in pairs({ '.lua', '.vim' }) do
        if vim.fn.filereadable(conf_dir .. '/init' .. ext) ~= 0 then
          return conf_dir .. '/init' .. ext
        end
      end
    end
  end
end

function M.load_config(force)
  if M.loaded and not force then
    return
  end

  local config = M.find_config({ M.local_config, M.global_config })
  if config then
    vim.cmd('source ' .. config)
    M.loaded = true
  end
end

function M.setup()
  vim.cmd([[
    augroup 'jg.project-config'
      autocmd!
      autocmd VimEnter * lua require('jg.project-config').load_config()
    augroup END
  ]])
end

return M
