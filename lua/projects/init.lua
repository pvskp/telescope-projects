local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


local lfs = require("lfs")

local repos_dir = "/home/paulov/Documents/repos"
local dirs = {}

local function find_dirs(path, depth)
  for entry in lfs.dir(path) do
    if entry ~= "." and entry ~= ".." then
      local full_path = path .. "/" .. entry
      local attr = lfs.attributes(full_path)
      if attr.mode == "directory" and depth >= 0 then
        table.insert(dirs, full_path)
      end
      if attr.mode == "directory" and depth < 0 then
        find_dirs(full_path, depth + 1)
      end
    end
  end
end

find_dirs(repos_dir, 0)

local projects = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Projects",

    finder = finders.new_table {
      results = dirs
    },

    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd('cd ' .. selection[1])
      end)
      return true
    end,

  }):find()
end

return projects
