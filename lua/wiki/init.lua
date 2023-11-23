local wiki = {}

local function get_current_file_abspath(buffer)
  -- https://neovim.io/doc/user/api.html#nvim_buf_get_name()
  -- vim.api.nvim_buf_get_namem({buffer})
  -- Gets the full file name for the buffer, and 0 for current buffer.
  local full_file_name = vim.api.nvim_buf_get_name(buffer)
  local pattern = "(/.+/)"
  local current_file_abspath = string.match(full_file_name, pattern)
  return current_file_abspath
end

local function Create_Open()
  local ts_utils = require("nvim-treesitter.ts_utils")
  -- https://github.com/nvim-treesitter/nvim-treesitter/blob/2a5f6c9eb733a5a847bb1890f620658547033515/doc/nvim-treesitter.txt#L457
  -- ts_utils.get_node_at_cursor(winnr)
  -- `winnr` will be 0 if nil. Returns the node under the cursor.
  local node = ts_utils.get_node_at_cursor()
  -- https://www.cnblogs.com/dst5650/p/8762192.html#pattern解析
  -- %[ and %] represent [ and ], %. represents .
  local pattern_filename = ".+/([^)]+)%.md"
  local pattern_path = "([^(]+/)"
  -- https://neovim.io/doc/user/api.html#nvim_get_current_line()
  -- nvim.api.nvim_get_current_line()
  -- Gets the currnet line string.
  local current_line = vim.api.nvim_get_current_line()
  local abspath = ""
  local filename = ""
  if node:type() == "inline" then
    filename = current_line
    abspath = get_current_file_abspath(0)
    -- https://neovim.io/doc/user/api.html#nvim_set_current_line()
    -- nvim.api.nvim_set_current_line({line})
    -- Sets the current line.
    vim.api.nvim_set_current_line("* [" .. filename .. "](./" .. filename .. ".md)")
  elseif node:type() == "link_text" then
    local target_path = string.match(current_line, pattern_path)
    if target_path == nil then
      -- There is no link_destination, i.e. [link_text]()
      abspath = get_current_file_abspath(0)
      filename = string.match(current_line, "%[(.+)%]")
      vim.api.nvim_set_current_line("* [" .. filename .. "](./" .. filename .. ".md)")
    else
      -- The link_destination exists.
      filename = string.match(current_line, pattern_filename)
      if string.find(target_path, "%./") ~= nil then
        -- The link_destination is relative path.
        abspath = get_current_file_abspath(0) .. target_path
      else
        -- The link_destination is absolute path.
        abspath = target_path
      end
    end
  elseif node:type() == "link_destination" then
    -- If the type of node is link_destination, the node of link_text must exist!
    -- So filename must exist, i.e., filename ~= nil
    filename = string.match(current_line, pattern_filename)
    local target_path = string.match(current_line, pattern_path) -- target_path not nil
    if string.find(target_path, "%./") ~= nil then
      -- The text_destination is relative path.
      abspath = get_current_file_abspath(0) .. target_path
    else
      -- The text_destination is absolute path.
      abspath = target_path
    end
    -- link_text is nil, i.e. [](link_destination)
    if string.match(current_line, "%[(.+)%]") == nil then
      -- fill in [] with filename
      local new_line = string.gsub(current_line, "%[%]", "["..filename.."]")
      vim.api.nvim_set_current_line("* " .. new_line)
    end
  else
    return
  end
  -- https://neovim.io/doc/user/lua.html#vim.fn
  -- vim.fn.{func}({...})
  -- Invokes vim-function or user-function {func} with arguments {...}.
  vim.fn.mkdir(abspath, "p")
  -- https://neovim.io/doc/user/api.html#nvim_command()
  -- nvim_command({command})
  -- Executes an Ex command
  vim.api.nvim_command("edit " .. abspath .. filename .. ".md")
end

local function setup(opt)
  wiki = vim.tbl_extend('force', {
    wiki_file = "<leader>ww",
  }, opt or {})
  vim.api.nvim_create_autocmd({"BufRead", "BufNew"}, {
    pattern = "*.md",
    callback = function ()
      vim.keymap.set({"n", "v"}, wiki.wiki_file, Create_Open, {})
    end
  })
end

return {
  setup = setup
}

