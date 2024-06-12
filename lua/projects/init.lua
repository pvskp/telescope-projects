local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local project_dirs = {
	"~/Documents/repos",
	"~/.config",
}
local dirs = {}

local function find_dirs(path)
	local handle = io.popen("find " .. path .. " -maxdepth 1 -mindepth 1 -type d,l")
	if handle ~= nil then
		local result = handle:read("*a")
		handle:close()
		for dir in string.gmatch(result, "([^\n]+)") do
			table.insert(dirs, dir)
		end
	end
end

for _, v in ipairs(project_dirs) do
	find_dirs(v)
end

local projects = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Projects",

			finder = finders.new_table({
				results = dirs,
			}),

			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.cmd("cd " .. selection[1])
				end)
				return true
			end,
		})
		:find()
end

-- projects()
return projects
