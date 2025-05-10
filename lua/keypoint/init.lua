local M = {}

-- Default options with categories for normal mode
local default_opts = {}

--require("keypoint.default-opts.lua")
--
local context = "keypoint"

M.legend = require("keypoint.full-template")

-- Table to store actual key mappings
M.mappings = {}

-- Dry-run flag
M.dry_run = false

local key_mappings = {}

-- Function to handle proxy keypresses (executes command + any attached functions)
local function proxy_handler(cmd, functions)
	-- Execute custom functions attached to the key
	if functions then
		for _, func in ipairs(functions) do
			func()
		end
	end
	-- Execute the original command
	if type(cmd) == "function" then
		cmd() -- Execute the function
	else
		--	vim.cmd("normal! " .. cmd) -- Execute the normal command
		-- this way is better, it respect keysequences etc
		vim.api.nvim_feedkeys(cmd, "n", false)
	end
end

-- Function to bind keys with the proxy logic (supports dry-run and function attachment)
function M.proxy_set_keymap(mode, lhs, rhs, opts)
	-- Ensure options table exists
	opts = opts or { noremap = true, silent = true }

	-- Store the mapping and attach an empty function list if none exists
	M.mappings[mode] = M.mappings[mode] or {}
	M.mappings[mode][lhs] = { cmd = rhs, functions = {} }

	-- Debug: Show keymap being set

	-- If `rhs` is a Lua function, set it as a callback in the opts table
	if type(rhs) == "function" then
		-- Debug: Show function binding

		opts.callback = function()
			M.proxy_run(mode, lhs) -- Handle proxy execution logic
		end
		rhs = "" -- rhs becomes empty because we are using the callback instead
	else
		-- If `rhs` is a string, use the normal proxy logic
		rhs = string.format(":lua require'keypoint'.proxy_run('%s', '%s')<CR>", mode, lhs)
	end

	-- Set the keymap with the provided options (either string rhs or callback function)
	vim.api.nvim_set_keymap(mode, lhs, rhs, opts)

	-- Debug: Show successful keymap set
end

-- Function that runs the proxy and the original command
function M.proxy_run(mode, lhs)
	-- Debug: Show proxy being triggered

	-- Get the original command and attached functions
	local mapping = M.mappings[mode][lhs]
	if mapping then
		-- Check if cmd is a function
		if type(mapping.cmd) == "function" then
			-- Debug: Running function
			proxy_handler(mapping.cmd, mapping.functions)
		elseif mapping.cmd == "" then
			-- Debug: Running function for empty cmd case
			proxy_handler(lhs, mapping.functions)
		else
			-- Debug: Running command
			proxy_handler(mapping.cmd, mapping.functions)
		end
	else
		-- Debug: No command mapped
		log("-- No command mapped to " .. lhs .. " in mode " .. mode)
	end
end

-- Attach a function to a key that will be triggered on keypress
function M.attach_function_to_key(mode, lhs, func)
	if M.mappings[mode] and M.mappings[mode][lhs] then
		table.insert(M.mappings[mode][lhs].functions, func)
	else
		log("No mapping found for key '" .. lhs .. "' in mode '" .. mode .. "'")
	end
end

-- Helper function to translate a Lua table to JSON format

-- Function to generate the JSON, open a new buffer, and print the JSON inside it
function M.get_json_map()
	-- Prepare a new table to store the transformed mappings
	local transformed_mappings = {}

	-- Iterate through the mappings table and transform it
	for mode, keys in pairs(M.mappings) do
		transformed_mappings[mode] = {}

		for lhs, mapping in pairs(keys) do
			-- Create a new table for each key mapping
			local new_mapping = {
				cmd = mapping.cmd,
				callbacks = #mapping.functions > 0, -- Set functions flag based on whether functions exist
			}
			-- Insert the new mapping into the transformed table
			transformed_mappings[mode][lhs] = new_mapping
		end
	end

	-- Convert the transformed table to JSON
	local json_str = vim.fn.json_encode(transformed_mappings)

	-- Open a new buffer and set its content to the JSON string
	vim.cmd("new") -- Open a new split window with an empty buffer
	local buf = vim.api.nvim_get_current_buf() -- Get the buffer ID of the new buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(json_str, "\n")) -- Insert JSON into the buffer

	-- Optionally set the buffer to modifiable or other settings
	vim.bo[buf].modifiable = true
end

-- Setup function to initialize the plugin and merge user options
function M.setup(user_opts)
	-- Define a custom highlight group for the keys
	--vim.cmd("highlight MenuBarHighlight1 guifg=#000080 guibg=NONE")
	--vim.cmd("highlight MenuBarHighlight2 guifg=#0000FF guibg=NONE")
	--vim.cmd("highlight MenuBarHighlight3 guifg=#00FFFF guibg=NONE")

	-- Merge user options with default options
	M.opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})

	--	if M.opts.dynamic_key_prefixes then
	--		-- Iterate through the dynamic key prefixes
	--		for _, key_data in pairs(M.opts.dynamic_key_prefixes) do
	--			local mode = key_data.mode
	--			local key = key_data.key
	--			local desc = key_data.desc
	--
	--			-- Debugging: Print the key and description being set
	--			log("Setting keymap for mode: " .. mode .. ", key: " .. key .. ", description: " .. desc)
	--
	--			-- Set the proxy keymap
	--			require("keypoint").proxy_set_keymap(mode, key, function()
	--				require("keypoint").run_prefix_key(key, desc)
	--			end)
	--		end
	--	end

	if M.opts.mode then
		-- Iterate through the modes (like 'n', 'v', etc.)
		for mode, motion_groups in pairs(M.opts.mode) do
			if type(motion_groups) ~= "table" then
				log("Error: Invalid motion group for mode " .. mode)
				return
			end

			-- Iterate through the motion groups (like 'left_right_motions')
			for group_name, keys in pairs(motion_groups) do
				if type(keys) ~= "table" then
					log("Error: Invalid key mappings for group " .. group_name)
					return
				end

				-- Iterate over the individual key mappings
				for lhs, rhs in pairs(keys) do
					--if rhs is table, handle it
					if type(rhs) == "table" then
						if rhs.is_dynamic and rhs.is_dynamic then
							local dynamic_key_data = rhs

							require("keypoint").proxy_set_keymap(mode, lhs, function()
								require("keypoint").run_prefix_key(
									lhs,
									dynamic_key_data.desc,
									dynamic_key_data.key_span,
									dynamic_key_data.desc_callback or nil
								)
							end)
						else
							-- TODO: We need to default to something if the key_span is not set, don't do ... or true, because if the var is false, it is turned to true
							-- keys are given, not dynamic
							local static_key_data = rhs
							local prefix_key = lhs
							--M.proxy_set_keymap(mode, lhs, rhs.key)

							require("keypoint").proxy_set_keymap(mode, lhs, function()
								require("keypoint").run_prefix_key(
									prefix_key,
									static_key_data.desc,
									static_key_data.key_span,
									static_key_data.desc_callback or nil
								)
							end)
							--M.add_prefix_key(prefix_key, static_key_data.desc)
							for lhs_subsequent_key, action_data in pairs(static_key_data.subsequent_keys) do
								M.add_action_key(prefix_key, lhs_subsequent_key, action_data.action, action_data.desc)
							end
						end
					else
						-- It is function or something else, it will be handled by the proxy_run function so we can just proxy_set_keymap it here
						-- text string asigned for rhs
						-- Handle case where rhs is an empty string
						if rhs == "" then
							rhs = lhs -- Default to key itself
						end
						M.proxy_set_keymap(mode, lhs, rhs)
					end
				end
			end
		end
	end
end

function M.remove_all_action_keys(prefix_key)
	-- Ensure the prefix key exists
	if not key_mappings[prefix_key] then
		log("Prefix key _" .. prefix_key .. "_ does not exist")
		return
	end

	-- Remove all action keys under the given prefix key
	for action_key, _ in pairs(key_mappings[prefix_key].actions) do
		key_mappings[prefix_key].actions[action_key] = nil
	end

	-- Remove the prefix key if no actions are left (optional)
	if next(key_mappings[prefix_key].actions) == nil then
		key_mappings[prefix_key] = nil
	end
end
function M.rebind_subsequent_key_for_static_key_prefix(prefix_key, subsequent_keys)
	M.remove_all_action_keys(prefix_key)
	--M.add_prefix_key(prefix_key, static_key_data.desc)
	for lhs_subsequent_key, action_data in pairs(subsequent_keys) do
		M.add_action_key(prefix_key, lhs_subsequent_key, action_data.action, action_data.desc)
	end
end
function M.nop()
	--log("The key has been disabled")
end
-- Function to Nop all keys from legend with subcategories
function M.nop_all_default_keys()
	-- Loop through each mode in legend
	for mode, subcategories in pairs(M.legend.mode) do
		-- Loop through each subcategory in the mode
		for subcategory, keys in pairs(subcategories) do
			-- Loop through each key in the subcategory
			for key, _ in pairs(keys) do
				-- Set the key to <Nop> in the given mode
				--vim.api.nvim_set_keymap(mode, key, "<Nop>", { noremap = true, silent = true })
				vim.keymap.set(mode, key, M.nop, { noremap = true, silent = true })
				-- Optionally, print for debugging purposes
				--log("Nooping key " .. key .. " in mode " .. mode .. " under subcategory " .. subcategory)
			end
		end
	end
end

-- https://stackoverflow.com/questions/21945038/resetting-all-key-maps-in-vim
-- :mapclear | mapclear <buffer> | mapclear! | mapclear! <buffer>
-- Clear all key mappings globally and buffer-local for modes from M.legend
function M.clear_all_nondefault_keys()
	-- Clear global mappings for normal, visual, select, operator-pending modes
	vim.cmd("mapclear")

	-- Clear buffer-local mappings for those modes
	vim.cmd("mapclear <buffer>")

	-- Clear global mappings for insert and command-line modes
	vim.cmd("mapclear!")

	-- Clear buffer-local mappings for insert and command-line modes
	vim.cmd("mapclear! <buffer>")
end

-- Helper function to calculate the width of the longest key-description pair
local function get_max_width(keys)
	local max_width = 0
	for _, key in ipairs(keys) do
		local entry_width = #key[1] + 3 + #key[2] -- key + " - " + description
		if entry_width > max_width then
			max_width = entry_width
		end
	end
	return max_width
end

-- ORIGINAL
-- -- Helper function to display keys in columns in the command-line area
-- local function show_key_hints(keys, title)
-- 	-- Get the current width of the Neovim window
-- 	--local total_width = vim.api.nvim_get_option 'columns'
-- 	local total_width = vim.opt.columns:get()
--
-- 	-- Calculate the width of the longest key + description
-- 	local max_width = get_max_width(keys)
--
-- 	-- Determine how many columns we can fit in the current window
-- 	local num_columns = math.floor(total_width / (max_width + 2)) -- +2 for padding between columns
--
-- 	-- Build the message to display keys in columns
-- 	local msg = {}
-- 	local column_count = 0
--
-- 	-- Add the side decoration with the lighter highlight group
-- 	table.insert(msg, { ".-=[ ", "TitleDecorHighlight" })
--
-- 	-- Add the title with the regular TitleHighlight group
-- 	table.insert(msg, { title, "TitleHighlight" })
--
-- 	-- Add the closing side decoration with the lighter highlight group
-- 	table.insert(msg, { " ]=-.", "TitleDecorHighlight" })
-- 	table.insert(msg, { "\n", "Normal" })
-- 	for i, key in ipairs(keys) do
-- 		-- Add padding before the very first column in each row
-- 		if column_count == 0 then
-- 			local x = 1
-- 			table.insert(msg, { string.rep(" ", x), "Normal" }) -- Add x spaces before the first column
-- 		end
--
-- 		-- Format the key part and the description part
-- 		local entry_key = string.format("%s", key[1]) -- key part without padding
-- 		local entry_desc = string.format(" - %s", key[2]) -- description with dash
--
-- 		-- Add the key part with color
-- 		table.insert(msg, { entry_key, "KeyHighlight" })
--
-- 		-- Add the description part without color
-- 		table.insert(msg, { entry_desc, "Normal" })
--
-- 		column_count = column_count + 1
--
-- 		-- Add padding between columns (but not after the last column in a row)
-- 		if column_count < num_columns then
-- 			local padding = max_width - (#key[1] + 3 + #key[2])
-- 			table.insert(msg, { string.rep(" ", padding + 2), "Normal" }) -- Add spaces between columns
-- 		end
--
-- 		-- Move to the next row after filling the columns
-- 		if column_count == num_columns then
-- 			table.insert(msg, { "\n", "Normal" })
-- 			column_count = 0
-- 		end
-- 	end
--
-- 	-- Display the message in the command-line area
-- 	vim.api.nvim_echo(msg, false, {})
-- end
-- Function to add a random colored line with dark blue, blue, and cyan
-- Function to build a random colored line using the input table
local function draw_colored_line(msg, char)
	local total_width = vim.opt.columns:get()

	-- Define the colors and their associated highlight groups
	local colors = {
		{ "MenuBarHighlight1", 0.7 }, -- 70% chance to be DarkBlue
		{ "MenuBarHighlight2", 0.2 }, -- 20% chance to be Blue
		{ "MenuBarHighlight3", 0.1 }, -- 10% chance to be Cyan
	}

	-- Append a random colored line using dashes (-) with highlight groups
	for i = 1, total_width do
		local rand = math.random()
		local highlight_group

		-- Pick a highlight group based on the probabilities
		if rand <= colors[1][2] then
			highlight_group = colors[1][1]
		elseif rand <= colors[1][2] + colors[2][2] then
			highlight_group = colors[2][1]
		else
			highlight_group = colors[3][1]
		end

		-- Insert a dash with the selected highlight group
		table.insert(msg, { char, highlight_group })
	end

	return msg -- Return the modified msg table
end
-- Function to convert a string to a color (from previous code)
function M.string_to_color(seed)
	-- Convert the seed to a consistent hash value
	local hash = 0
	for i = 1, #seed do
		hash = (hash * 31 + string.byte(seed, i)) % 360 -- We only care about hue (0-360 degrees)
	end

	-- Convert the hue to RGB using full saturation (100%) and value (100%)
	local function hsv_to_rgb(h)
		local c = 255 -- Chroma (max for full saturation and value)
		local x = math.floor(c * (1 - math.abs((h / 60) % 2 - 1))) -- Intermediate color
		local r, g, b

		if h < 60 then
			r, g, b = c, x, 0
		elseif h < 120 then
			r, g, b = x, c, 0
		elseif h < 180 then
			r, g, b = 0, c, x
		elseif h < 240 then
			r, g, b = 0, x, c
		elseif h < 300 then
			r, g, b = x, 0, c
		else
			r, g, b = c, 0, x
		end

		return string.format("#%02X%02X%02X", r, g, b)
	end

	-- Use the hash to determine the hue (0 to 360) and convert it to RGB
	return hsv_to_rgb(hash)
end

-- Helper function to adjust color values
local function adjust_color_component(component, factor)
	return math.min(255, math.max(0, math.floor(component * factor)))
end

-- Function to create a lighter shade of the base color
function M.lighter_shade(color, factor)
	-- Extract RGB components from the hex color
	local r = tonumber(color:sub(2, 3), 16)
	local g = tonumber(color:sub(4, 5), 16)
	local b = tonumber(color:sub(6, 7), 16)

	-- Increase the brightness of each component
	r = adjust_color_component(r, factor)
	g = adjust_color_component(g, factor)
	b = adjust_color_component(b, factor)

	-- Return the adjusted color in hex format
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Function to create a darker shade of the base color
function M.darker_shade(color, factor)
	-- Extract RGB components from the hex color
	local r = tonumber(color:sub(2, 3), 16)
	local g = tonumber(color:sub(4, 5), 16)
	local b = tonumber(color:sub(6, 7), 16)

	-- Decrease the brightness of each component
	r = adjust_color_component(r, factor)
	g = adjust_color_component(g, factor)
	b = adjust_color_component(b, factor)

	-- Return the adjusted color in hex format
	return string.format("#%02X%02X%02X", r, g, b)
end
local function hex_to_rgb(hex)
	hex = hex:gsub("#", "") -- Remove '#' if present
	return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

-- Helper function to convert RGB components to hex color
local function rgb_to_hex(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Function to generate a complementary color
function M.complementary_color(hex_color)
	-- Convert hex to RGB
	local r, g, b = hex_to_rgb(hex_color)

	-- Calculate the complementary color (subtract from 255)
	local comp_r = 255 - r
	local comp_g = 255 - g
	local comp_b = 255 - b

	-- Return the complementary color in hex format
	return rgb_to_hex(comp_r, comp_g, comp_b)
end
local function rgb_to_hsl(r, g, b)
	r = r / 255
	g = g / 255
	b = b / 255

	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, l = 0, 0, (max + min) / 2

	if max ~= min then
		local d = max - min
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)
		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h * 360, s, l
end

local function hsl_to_rgb(h, s, l)
	local function hue_to_rgb(p, q, t)
		if t < 0 then
			t = t + 1
		end
		if t > 1 then
			t = t - 1
		end
		if t < 1 / 6 then
			return p + (q - p) * 6 * t
		end
		if t < 1 / 2 then
			return q
		end
		if t < 2 / 3 then
			return p + (q - p) * (2 / 3 - t) * 6
		end
		return p
	end

	h = h / 360
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue_to_rgb(p, q, h + 1 / 3)
		g = hue_to_rgb(p, q, h)
		b = hue_to_rgb(p, q, h - 1 / 3)
	end

	return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

-- Function to generate a triadic color scheme
function M.triadic_colors(hex_color)
	-- Convert hex to RGB
	local r, g, b = hex_to_rgb(hex_color)

	-- Convert RGB to HSL
	local h, s, l = rgb_to_hsl(r, g, b)

	-- Calculate the two other colors by shifting hue by 120 degrees
	local h1 = (h + 120) % 360
	local h2 = (h + 240) % 360

	-- Convert the two hues back to RGB
	local r1, g1, b1 = hsl_to_rgb(h1, s, l)
	local r2, g2, b2 = hsl_to_rgb(h2, s, l)

	-- Return the two complementary colors in hex format
	return rgb_to_hex(r1, g1, b1), rgb_to_hex(r2, g2, b2)
end
local function draw_colored_line_with_title(msg, title, char)
	local total_width = vim.opt.columns:get()
	-- Define the colors and their associated highlight groups
	local colors = {
		{ "MenuBarHighlight1", 0.7 }, -- 70% chance to be DarkBlue
		{ "MenuBarHighlight2", 0.2 }, -- 20% chance to be Blue
		{ "MenuBarHighlight3", 0.1 }, -- 10% chance to be Cyan
	}

	-- Calculate the length of the title with the decoration
	local decoration_length = 11 -- "▀▀▀▚" + " ]=-." (5 chars for start and 3 for end)
	local title_length = #title
	local total_text_length = decoration_length + title_length

	-- Calculate the remaining space and padding for left and right
	local remaining_space = total_width - total_text_length
	local left_padding = math.floor(remaining_space / 2)
	local right_padding = remaining_space - left_padding

	-- Left side of the random colored line
	for i = 1, left_padding do
		local rand = math.random()
		local highlight_group

		-- Pick a highlight group based on the probabilities
		if rand <= colors[1][2] then
			highlight_group = colors[1][1]
		elseif rand <= colors[1][2] + colors[2][2] then
			highlight_group = colors[2][1]
		else
			highlight_group = colors[3][1]
		end

		-- Insert random colored character on the left side
		table.insert(msg, { char, highlight_group })
	end

	-- Add the side decoration with the lighter highlight group
	--table.insert(msg, { "▀▀▀▙ ", "TitleDecorHighlight" })
	table.insert(msg, { "▀▀▀▙ ", "MenuBarHighlight1" })

	-- Add the title with the regular TitleHighlight group
	table.insert(msg, { title, "TitleHighlight" })

	-- Add the closing side decoration with the lighter highlight group
	table.insert(msg, { " ▟▀▀▀", "MenuBarHighlight1" })

	-- Right side of the random colored line
	for i = 1, right_padding do
		local rand = math.random()
		local highlight_group

		-- Pick a highlight group based on the probabilities
		if rand <= colors[1][2] then
			highlight_group = colors[1][1]
		elseif rand <= colors[1][2] + colors[2][2] then
			highlight_group = colors[2][1]
		else
			highlight_group = colors[3][1]
		end

		-- Insert random colored character on the right side
		table.insert(msg, { char, highlight_group })
	end

	-- Add a newline after the line

	return msg -- Return the modified msg table
end

local function add_centered_title(msg, title)
	local total_width = vim.opt.columns:get()

	-- Calculate the length of the decoration and title
	local decoration_length = 7 -- ".-=[ " + " ]=-." (5 characters for the start and 3 for the end)
	local title_length = #title
	local total_text_length = decoration_length + title_length

	-- Calculate the remaining space and padding
	local remaining_space = total_width - total_text_length
	local left_padding = math.floor(remaining_space / 2)
	local right_padding = remaining_space - left_padding

	-- Add left padding before the side decoration
	table.insert(msg, { string.rep(" ", left_padding), "Normal" })

	-- Add the side decoration with the lighter highlight group
	table.insert(msg, { ".-=[ ", "TitleDecorHighlight" })

	-- Add the title with the regular TitleHighlight group
	table.insert(msg, { title, "TitleHighlight" })

	-- Add the closing side decoration with the lighter highlight group
	table.insert(msg, { " ]=-.", "TitleDecorHighlight" })

	-- Add right padding after the side decoration
	table.insert(msg, { string.rep(" ", right_padding), "Normal" })

	return msg
end
--
---- Helper function to convert hex to RGB
--local function hex_to_rgb(color)
--	return tonumber(color:sub(2, 3), 16), tonumber(color:sub(4, 5), 16), tonumber(color:sub(6, 7), 16)
--end
--
---- Helper function to convert RGB to hex
--local function rgb_to_hex(r, g, b)
--	return string.format("#%02X%02X%02X", r, g, b)
--end

function M.adjust_color(hex, saturation, brightness)
	-- Convert RGB to HSV
	local function rgb_to_hsv(r, g, b)
		r, g, b = r / 255, g / 255, b / 255
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local h, s, v = 0, 0, max

		local d = max - min
		s = (max == 0) and 0 or (d / max)

		if max == min then
			h = 0 -- Achromatic
		elseif max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end

		h = h / 6
		return h * 360, s * 100, v * 100 -- Convert to degrees and percentages
	end

	-- Convert HSV to RGB
	local function hsv_to_rgb(h, s, v)
		local c = (v / 100) * (s / 100) -- Chroma
		local x = c * (1 - math.abs((h / 60) % 2 - 1))
		local m = (v / 100) - c
		local r, g, b = 0, 0, 0

		if h < 60 then
			r, g, b = c, x, 0
		elseif h < 120 then
			r, g, b = x, c, 0
		elseif h < 180 then
			r, g, b = 0, c, x
		elseif h < 240 then
			r, g, b = 0, x, c
		elseif h < 300 then
			r, g, b = x, 0, c
		else
			r, g, b = c, 0, x
		end

		r = math.floor((r + m) * 255)
		g = math.floor((g + m) * 255)
		b = math.floor((b + m) * 255)

		return r, g, b
	end

	-- Convert RGB to hex
	local function rgb_to_hex(r, g, b)
		return string.format("#%02X%02X%02X", r, g, b)
	end

	-- Get RGB values from hex
	local r, g, b = hex_to_rgb(hex)

	-- Convert RGB to HSV
	local h, s, v = rgb_to_hsv(r, g, b)

	-- Adjust saturation and brightness (clamp between 0 and 100)
	s = math.min(math.max(saturation, 0), 100)
	v = math.min(math.max(brightness, 0), 100)

	-- Convert back to RGB
	r, g, b = hsv_to_rgb(h, s, v)

	-- Return the new color in hex format
	return rgb_to_hex(r, g, b)
end
-- Function to interpolate diagonally between the defined black and white span
local function diagonal_interpolate(base_color, score, black_limit, white_limit)
	-- Default black and white RGB
	local black = "#000000"
	local white = "#FFFFFF"

	-- Extract RGB components from the base color, black, and white
	local base_r, base_g, base_b = hex_to_rgb(base_color)
	local black_r, black_g, black_b = hex_to_rgb(black)
	local white_r, white_g, white_b = hex_to_rgb(white)

	-- Calculate the limited black and white (this defines the span we're working with)
	local effective_black_r = black_r + (base_r - black_r) * black_limit
	local effective_black_g = black_g + (base_g - black_g) * black_limit
	local effective_black_b = black_b + (base_b - black_b) * black_limit

	local effective_white_r = white_r + (base_r - white_r) * white_limit
	local effective_white_g = white_g + (base_g - white_g) * white_limit
	local effective_white_b = white_b + (base_b - white_b) * white_limit

	-- Interpolate between the limited black and white based on the score (relative to this span)
	local factor = score / 100

	local r = math.floor(effective_black_r + (effective_white_r - effective_black_r) * factor)
	local g = math.floor(effective_black_g + (effective_white_g - effective_black_g) * factor)
	local b = math.floor(effective_black_b + (effective_white_b - effective_black_b) * factor)

	-- Ensure values are within the valid RGB range (0-255)
	r = math.min(math.max(r, 0), 255)
	g = math.min(math.max(g, 0), 255)
	b = math.min(math.max(b, 0), 255)

	-- Return the final interpolated color in hex format
	return rgb_to_hex(r, g, b)
end

-- Function to apply the diagonal gradient to the score table, with percentage limits for black and white
function M.apply_diagonal_shades(base_color, score_table, black_limit, white_limit)
	-- Iterate through the score table and replace scores with color shades
	for key, score in pairs(score_table) do
		score_table[key] = diagonal_interpolate(base_color, score, black_limit, white_limit)
	end

	-- Return the table with the color shades applied
	return score_table
end
local function is_color_dark(hex_color)
	-- Remove the `#` if present
	hex_color = hex_color:gsub("#", "")

	-- Extract RGB components
	local r = tonumber(hex_color:sub(1, 2), 16)
	local g = tonumber(hex_color:sub(3, 4), 16)
	local b = tonumber(hex_color:sub(5, 6), 16)

	-- Calculate perceived luminance
	local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

	-- Set threshold for darkness; you may adjust based on your perception
	local luminance_threshold = 80

	-- Check if luminance is below threshold or if color is very close to black
	return luminance < luminance_threshold or (r < 40 and g < 40 and b < 40)
end
local function is_color_in_even_segment(hex_color, segments)
	-- Remove '#' if present
	hex_color = hex_color:gsub("#", "")

	-- Convert hex to RGB
	local r = tonumber(hex_color:sub(1, 2), 16)
	local g = tonumber(hex_color:sub(3, 4), 16)
	local b = tonumber(hex_color:sub(5, 6), 16)

	-- Get hue from RGB
	local hue, _, _ = rgb_to_hsl(r, g, b)

	-- Determine the segment the hue falls into
	local segment_size = 360 / segments
	local segment = math.floor(hue / segment_size) + 1 -- +1 to start segments from 1

	-- Return true if the segment is even, false if odd
	return segment % 2 == 0
end
function M.highlight_entry_desc(entry_desc)
	local msg = {}

	-- Determine the delimiter based on whether entry_desc has '/' or '_'
	local delimiter = entry_desc:find("/") and "/" or "_"

	-- Split the entry_desc by the determined delimiter, ignoring empty segments
	local parts = vim.split(entry_desc, delimiter, { trimempty = true })

	if delimiter == "/" then
		-- Handle '/' delimiter as in the original code
		local last_part = table.remove(parts) -- Separate the last part
		local base_path = table.concat(parts, delimiter)

		-- Generate and set color for the base path
		local base_color = M.string_to_color(base_path)
		base_color = M.adjust_color(base_color, 60, 80)
		local base_highlight_group = "ItemNameHighlight_" .. base_path:gsub("%W", "_")
		vim.api.nvim_set_hl(0, base_highlight_group, { fg = base_color })

		-- Add the base path with its highlight to the message table
		table.insert(msg, { base_path, base_highlight_group })

		-- Add the separator '/' between base path and last part
		table.insert(msg, { "/", "ItemNameHighlight" })

		-- Generate and set color for the last part
		local last_color = M.complementary_color(base_color)
		local last_highlight_group = "ItemNameHighlight_" .. base_path:gsub("%W", "_") .. last_part:gsub("%W", "_")
		vim.api.nvim_set_hl(0, last_highlight_group, { fg = last_color, bg = "#000000" })

		-- Add the last part with its highlight to the message table
		table.insert(msg, { last_part, last_highlight_group })
	else
		--local text = "example_text_with_underscore (232)"

		if not (entry_desc:find("_") and entry_desc:match("%(%d+%)$")) then
			--Color normal text
			table.insert(msg, { entry_desc, "ItemNameHighlight" })
		else
			-- Color function part
			-- Handle '_' delimiter, coloring each part individually
			-- Check if the last part has (...) at the end
			local last_part = parts[#parts]
			local base_part, gray_text = last_part:match("^(.-)%s*%((.-)%)$")

			if base_part and gray_text then
				-- If (...) found, remove the last part from parts
				table.remove(parts)

				-- Process all parts except for the last one with (...)
				for _, part in ipairs(parts) do
					-- Generate a unique color for each part based on its text
					local part_color = M.string_to_color(entry_desc .. part)
					part_color_mod = M.adjust_color(part_color, 60, 80)
					local part_highlight_group = "ItemNameHighlight_" .. part:gsub("%W", "_")

					if is_color_in_even_segment(part_color_mod, 24) then
						local complement_color = M.complementary_color(part_color)
						complement_color = M.adjust_color(complement_color, 60, 20)
						vim.api.nvim_set_hl(0, part_highlight_group, { fg = part_color_mod, bg = complement_color })
					else
						vim.api.nvim_set_hl(0, part_highlight_group, { fg = part_color_mod })
					end
					--vim.api.nvim_set_hl(0, part_highlight_group, { fg = part_color })

					-- Add the part with its unique highlight to the message table
					table.insert(msg, { part, part_highlight_group })

					-- Add the separator '_' between parts if not the last part
					table.insert(msg, { "_", "ItemNameHighlight" })
				end

				-- Add the last part (base) and gray-colored (...) separately
				local base_color = M.string_to_color(entry_desc .. base_part)
				local base_color_mod = M.adjust_color(base_color, 60, 80)

				local base_highlight_group = "ItemNameHighlight_" .. base_part:gsub("%W", "_")

				if is_color_dark(base_color_mod) then
					local complement_color = M.complementary_color(base_color)
					complement_color = M.adjust_color(complement_color, 60, 20)
					vim.api.nvim_set_hl(0, base_highlight_group, { fg = base_color_mod, bg = complement_color })
				else
					vim.api.nvim_set_hl(0, base_highlight_group, { fg = base_color_mod })
				end

				vim.api.nvim_set_hl(0, "GrayHighlight", { fg = "#808080" }) -- Adjust gray as needed

				table.insert(msg, { base_part, base_highlight_group })
				gray_text = " (" .. gray_text .. ")"
				table.insert(msg, { gray_text, "GrayHighlight" })
				--NOTE: No idea why we need to add this one below for the gray text to be printed
				table.insert(msg, { "", "GrayHighlight" })
			else
				-- Process normally if (...) is not present
				for _, part in ipairs(parts) do
					-- Generate a unique color for each part based on its text
					local part_color = M.string_to_color(entry_desc .. part)
					part_color = M.adjust_color(part_color, 60, 80)
					local part_highlight_group = "ItemNameHighlight_" .. part:gsub("%W", "_")
					vim.api.nvim_set_hl(0, part_highlight_group, { fg = part_color })

					-- Add the part with its unique highlight to the message table
					table.insert(msg, { part, part_highlight_group })

					-- Add the separator '_' between parts if not the last part
					table.insert(msg, { "_", "ItemNameHighlight" })
				end
			end

			-- Remove the trailing '_' separator
			msg[#msg] = nil
		end
	end

	return msg
end
local function show_key_hints(keys, title, score_colors_map, recent_used_keys_map)
	-- Get the current width and height of the Neovim window
	local total_width = vim.opt.columns:get()
	local total_height = vim.opt.lines:get()

	-- Calculate the width of the longest key + description
	local max_width = get_max_width(keys)

	-- Determine how many columns we can fit in the current window
	local num_columns = math.floor(total_width / (max_width + 2)) -- +2 for padding between columns

	-- Build the message to display keys in columns
	local msg = {}
	local column_count = 0
	local num_lines = 1 -- Start with 1 for the title

	msg = draw_colored_line_with_title(msg, title, "▔")
	num_lines = num_lines + 1

	-- Add the side decoration with the lighter highlight group
	--msg = add_centered_title(msg, title)

	-- Add a newline and increment line count
	table.insert(msg, { "\n", "Normal" })
	num_lines = num_lines + 1

	table.sort(keys, function(a, b)
		return a[2] < b[2] -- Compare the second element of each table (entry_desc)
	end)
	for i, key in ipairs(keys) do
		-- Add padding before the very first column in each row
		if column_count == 0 then
			local x = 1
			table.insert(msg, { string.rep(" ", x), "Normal" }) -- Add x spaces before the first column
		end

		-- Format the key part and the description part
		local entry_key = string.format("%s", key[1]) -- key part without padding
		local entry_desc = string.format("%s", key[2]) -- description with dash

		-- Add the key part with color
		table.insert(msg, { entry_key, "KeyHighlight" })
		if score_colors_map[entry_key] then
			local hl_title = "ScoreHighlight" .. string.byte(entry_key)

			vim.cmd("highlight " .. hl_title .. " guifg=" .. score_colors_map[entry_key] .. " guibg=NONE")

			table.insert(msg, { " █ ", hl_title })
		else
			table.insert(msg, { " - ", "MenuBarHighlight2" })
		end
		-- Add the description part without color
		-- Disable select hl for now, fix in future
		--if is_selected_check and is_selected_check(entry_desc) then
		--table.insert(msg, { entry_desc, "SelectedHighlight" })
		--else
		--table.insert(msg, { entry_desc, "ItemNameHighlight" })
		local highlighted_entries = M.highlight_entry_desc(entry_desc)
		for _, entry in ipairs(highlighted_entries) do
			table.insert(msg, entry)
		end
		--end

		column_count = column_count + 1

		-- Add padding between columns (but not after the last column in a row)
		if column_count < num_columns then
			local padding = max_width - (#key[1] + 3 + #key[2])
			table.insert(msg, { string.rep(" ", padding + 2), "Normal" }) -- Add spaces between columns
		end

		-- Move to the next row after filling the columns
		if column_count == num_columns then
			table.insert(msg, { "\n", "Normal" })
			num_lines = num_lines + 1 -- Increment line count for each new row
			column_count = 0
		end
	end

	-- If there are remaining keys that didn't fill a row, add a newline
	if column_count > 0 then
		table.insert(msg, { "\n", "Normal" })
		num_lines = num_lines + 1
	else
		table.insert(msg, { " ", "Normal" })
	end
	--table.insert(msg, { "\n ", "Normal" })
	--num_lines = num_lines + 1

	msg = draw_colored_line(msg, "━")
	--msg = draw_colored_line(msg, "▁")

	--msg = draw_colored_line_with_title(msg, "Most recently used", "▔")
	column_count = 0
	for i, key in ipairs(recent_used_keys_map) do
		-- Add padding before the very first column in each row
		if column_count == 0 then
			local x = 1
			table.insert(msg, { string.rep(" ", x), "Normal" }) -- Add x spaces before the first column
		end

		-- Format the key part and the description part
		local entry_key = string.format("%s", key[1]) -- key part without padding
		local entry_desc = string.format("%s", key[2]) -- description with dash

		-- Add the key part with color
		table.insert(msg, { entry_key, "KeyHighlight" })
		if score_colors_map[entry_key] then
			local hl_title = "ScoreHighlight" .. string.byte(entry_key)

			vim.cmd("highlight " .. hl_title .. " guifg=" .. score_colors_map[entry_key] .. " guibg=NONE")

			table.insert(msg, { " █ ", hl_title })
		else
			table.insert(msg, { " - ", "MenuBarHighlight2" })
		end
		-- Add the description part without color
		-- Disable select hl for now, fix in future
		--if is_selected_check and is_selected_check(entry_desc) then
		--table.insert(msg, { entry_desc, "SelectedHighlight" })
		--else
		table.insert(msg, { entry_desc, "ItemNameHighlight" })
		--end

		column_count = column_count + 1

		-- Add padding between columns (but not after the last column in a row)
		if column_count < num_columns then
			local padding = max_width - (#key[1] + 3 + #key[2])
			table.insert(msg, { string.rep(" ", padding + 2), "Normal" }) -- Add spaces between columns
		end

		-- Move to the next row after filling the columns
		if column_count == num_columns then
			table.insert(msg, { "\n", "Normal" })
			num_lines = num_lines + 1 -- Increment line count for each new row
			column_count = 0
		end
	end
	if column_count > 0 then
		table.insert(msg, { "\n", "Normal" })
		num_lines = num_lines + 1
	end
	msg = draw_colored_line(msg, "▁")
	num_lines = num_lines + 1

	-- Calculate the number of newlines to center the text vertically
	local padding_lines = math.floor((total_height - num_lines) / 2)
	for _ = 1, padding_lines do
		table.insert(msg, { "\n", "Normal" })
		num_lines = num_lines + 1
	end

	-- Dynamically set cmdheight based on the total number of lines
	-- NOTE: We need to do this, or the command-line area will be too small to display the message
	-- and we will get the "Press ENTER or type command to continue" message which disrupts key reading by vim.fn.getchar()
	vim.opt.cmdheight = num_lines -- Ensure it fits the screen height

	-- Display the message in the command-line area
	vim.api.nvim_echo(msg, false, {})
end

-- -- Function to generate random key names and descriptions of variable lengths
-- local function generate_test_keys(num_keys)
--   local available_keys = {}
--   for i = 1, num_keys do
--     -- Generate a key name (a single letter + a number)
--     local key = string.char(96 + (i % 26) + 1) .. tostring(i)
--
--     -- Generate a variable-length description
--     local description_length = math.random(10, 30) -- Random length between 10 and 30 characters
--     local description = string.rep('desc' .. i, math.ceil(description_length / 4)):sub(1, description_length)
--
--     -- Insert the generated key and description into the available_keys table
--     table.insert(available_keys, { key, description })
--   end
--   return available_keys
-- end

-- Local table to store key mappings
-- function to associte with a key, like: [' '] = require('keypoint').run_prefix_key 'p',

-- Function to retrieve a table of associated action keys and their descriptions for a prefix key
local function get_key_and_desc_action_keys(prefix_key)
	-- Ensure the prefix key exists
	if not key_mappings[prefix_key] then
		log("No prefix key found for _" .. prefix_key .. "_")
		return {}
	end

	-- Table to store the key-description pairs
	local key_desc_pairs = {}

	-- Iterate over the action keys and descriptions
	for action_key, action_data in pairs(key_mappings[prefix_key].actions) do
		-- Insert the key and description pair into the table
		table.insert(key_desc_pairs, { action_key, action_data.desc })
	end

	-- Return the table of key-description pairs
	return key_desc_pairs
end
local function get_local_or_global_group_id(context, prefix_key, key_span)
	local group_id
	local project_dir = require("phxman.properties").current_project.relative_project_path or "No Project Set"
	local buffer = require("phxman.helpers").get_current_buffer_name()
	--
	-- Print the value of key_span for debugging purposes
	if key_span == "project" then
		group_id = context .. ":[project:" .. project_dir .. "]:keystats:" .. prefix_key
	elseif key_span == "buffer" then
		group_id = context .. ":[buffer:" .. buffer .. "]:keystats:" .. prefix_key
	elseif key_span == "global" then
		group_id = context .. ":" .. "[global]" .. ":keystats:" .. prefix_key
	else
		log("Invalid key_span: " .. key_span)
		return "No group id possible because of wrong input"
	end

	return group_id
end

-- TODO: Decouple, move elsewhere, not dependent on phxman...
function M.stats_calculate_key_score(prefix_key, key_span)
	local dynkey = require("dynkey")
	-- Read the table from disk for this prefix_key
	local key_stats
	local group_id

	group_id = get_local_or_global_group_id(context, prefix_key, key_span)
	key_stats = dynkey.read_shadow_from_disk(group_id)

	-- If no data exists for the group_id, return an empty result
	--
	if not key_stats then
		log("No key stats found for group_id: " .. group_id)
		return {}, {}
	end

	-- Initialize variables
	local scores = {}
	local max_score = 0

	-- Define constants for the scoring formula
	local alpha = 0.005 -- Higher decay rate for recency to give more weight to recent keys
	local beta = 0.02 -- Lower sensitivity for closeness, to de-emphasize recurrence
	local recency_boost = 2 -- Additional weight for the most recent press

	-- Get current time
	local current_time = os.time()

	-- Function to calculate recency weight
	local function recency_weight(timestamp)
		return math.exp(-alpha * (current_time - timestamp))
	end

	-- Function to calculate closeness weight between two timestamps
	local function closeness_weight(t1, t2)
		return 1 / (1 + beta * math.abs(t2 - t1))
	end

	-- Iterate over all action keys in the table
	for action_key, timestamps in pairs(key_stats) do
		local score = 0

		-- Calculate the score for this key based on recency and closeness
		for i = 1, #timestamps - 1 do
			local recency = recency_weight(timestamps[i])
			local closeness = closeness_weight(timestamps[i], timestamps[i + 1])
			-- Closeness is still considered but less impactful than recency
			score = score + (recency * closeness)
		end

		-- If the last timestamp exists, add only its recency weight
		if #timestamps > 0 then
			-- Apply a strong boost to the most recent press
			score = score + recency_weight(timestamps[#timestamps]) * recency_boost
		end

		-- Store the score for this action_key
		scores[action_key] = score

		-- Track the maximum score for normalization
		if score > max_score then
			max_score = score
		end
	end

	-- Normalize scores to percentages
	if max_score > 0 then
		for action_key, score in pairs(scores) do
			scores[action_key] = (score / max_score) * 100
		end
	end

	-- Log the calculated scores for debugging
	--	for action_key, score in pairs(scores) do
	--		log("Key: " .. action_key .. " Score: " .. string.format("%.2f", score) .. "%")
	--	end

	-- Return the normalized scores
	return scores, key_stats
end

-- ORIGINAL
-- function M.stats_calculate_key_score(prefix_key)
-- 	local project_dir = require("proman").get_relative_current_project_dir() or "Not Project"
--
-- 	local dynkey = require("dynkey")
-- 	-- Read the table from disk for this prefix_key
-- 	local group_id = context .. "/" .. project_dir .. "/keystats/" .. prefix_key
-- 	local key_stats = dynkey.read_shadow_from_disk(group_id)
--
-- 	-- If no data exists for the group_id, return an empty result
-- 	if not key_stats then
-- 		log("No key stats found for group_id: " .. group_id)
-- 		return {}
-- 	end
--
-- 	-- Initialize variables
-- 	local scores = {}
-- 	local max_score = 0
--
-- 	-- Define constants for the scoring formula
-- 	local alpha = 0.001 -- Decay rate for recency
-- 	local beta = 0.01 -- Sensitivity for closeness in time
--
-- 	-- Get current time
-- 	local current_time = os.time()
--
-- 	-- Function to calculate recency weight
-- 	local function recency_weight(timestamp)
-- 		return math.exp(-alpha * (current_time - timestamp))
-- 	end
--
-- 	-- Function to calculate closeness weight between two timestamps
-- 	local function closeness_weight(t1, t2)
-- 		return 1 / (1 + beta * (t2 - t1))
-- 	end
--
-- 	-- Iterate over all action keys in the table
-- 	for action_key, timestamps in pairs(key_stats) do
-- 		local score = 0
--
-- 		-- Calculate the score for this key based on recency and closeness
-- 		for i = 1, #timestamps - 1 do
-- 			local recency = recency_weight(timestamps[i])
-- 			local closeness = closeness_weight(timestamps[i], timestamps[i + 1])
-- 			score = score + (recency * closeness)
-- 		end
--
-- 		-- If the last timestamp exists, add only its recency weight
-- 		if #timestamps > 0 then
-- 			score = score + recency_weight(timestamps[#timestamps])
-- 		end
--
-- 		-- Store the score for this action_key
-- 		scores[action_key] = score
--
-- 		-- Track the maximum score for normalization
-- 		if score > max_score then
-- 			max_score = score
-- 		end
-- 	end
--
-- 	-- Normalize scores to percentages
-- 	if max_score > 0 then
-- 		for action_key, score in pairs(scores) do
-- 			scores[action_key] = (score / max_score) * 100
-- 		end
-- 	end
--
-- 	-- Log the calculated scores for debugging
-- 	for action_key, score in pairs(scores) do
-- 		log("Key: " .. action_key .. " Score: " .. string.format("%.2f", score) .. "%")
-- 	end
--
-- 	-- Return the normalized scores
-- 	return scores
-- end

local function stats_record_key(prefix_key, action_key, key_span)
	local dynkey = require("dynkey")
	-- Generate the group_id based on the current project and the prefix_key only
	--local group_id = context .. "/" .. project_dir .. "/keystats/" .. prefix_key

	local group_id = get_local_or_global_group_id(context, prefix_key, key_span)
	key_stats = dynkey.read_shadow_from_disk(group_id)
	-- Attempt to read the table from disk for this prefix_key
	local key_stats = dynkey.read_shadow_from_disk(group_id)

	-- If no data is found on disk, initialize an empty table
	if not key_stats then
		key_stats = {}
	end

	-- Ensure there is a sub-table for the action_key
	if not key_stats[action_key] then
		key_stats[action_key] = {}
	end

	-- Get the current Unix time
	local current_time = os.time()

	-- Add the timestamp to the top of the FIFO queue for the action_key
	table.insert(key_stats[action_key], 1, current_time)

	-- Ensure the action_key's table only contains the last 100 timestamps
	if #key_stats[action_key] > 100 then
		table.remove(key_stats[action_key], #key_stats[action_key])
	end

	-- Call the function to write the updated stats to disk
	dynkey.write_shadow_to_disk(group_id, key_stats)
end

function M.make_blue_bright(hex)
	-- Get the RGB components from the hex string
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)

	-- Convert RGB to HSV
	local r_percent = r / 255
	local g_percent = g / 255
	local b_percent = b / 255
	local max = math.max(r_percent, g_percent, b_percent)
	local min = math.min(r_percent, g_percent, b_percent)
	local delta = max - min

	local h = 0
	local s = (max == 0) and 0 or (delta / max)
	local v = max * 100 -- brightness as a percentage

	-- Calculate hue
	if delta > 0 then
		if max == r_percent then
			h = (g_percent - b_percent) / delta
			if g_percent < b_percent then
				h = h + 6
			end
		elseif max == g_percent then
			h = (b_percent - r_percent) / delta + 2
		elseif max == b_percent then
			h = (r_percent - g_percent) / delta + 4
		end
		h = h * 60
	end

	-- Check if hue is within the purple/blue range
	if h >= 240 and h <= 300 then
		v = math.min(v * 1.5, 100) -- Increase brightness, clamp to 100%
	end

	-- Convert back to RGB
	local c = (v / 100) * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = (v / 100) - c

	local r_new, g_new, b_new = 0, 0, 0
	if h < 60 then
		r_new, g_new, b_new = c, x, 0
	elseif h < 120 then
		r_new, g_new, b_new = x, c, 0
	elseif h < 180 then
		r_new, g_new, b_new = 0, c, x
	elseif h < 240 then
		r_new, g_new, b_new = 0, x, c
	elseif h < 300 then
		r_new, g_new, b_new = x, 0, c
	else
		r_new, g_new, b_new = c, 0, x
	end

	-- Adjust for final brightness
	r_new = math.floor((r_new + m) * 255)
	g_new = math.floor((g_new + m) * 255)
	b_new = math.floor((b_new + m) * 255)

	-- Return the new color as a hex string
	return string.format("#%02X%02X%02X", r_new, g_new, b_new)
end
local function sort_keys_by_most_recent_unixtimestamp(input_table)
	-- Table to store the result
	local result = {}

	-- Loop through each key-value pair in the input table
	for key, timestamps in pairs(input_table) do
		-- Since the first timestamp is always the highest, take it directly
		result[key] = timestamps[1]
	end

	-- Convert result table to a sortable array
	local sorted_result = {}
	for key, timestamp in pairs(result) do
		table.insert(sorted_result, { key = key, time = timestamp })
	end

	-- Sort by timestamp in descending order
	table.sort(sorted_result, function(a, b)
		return a.time > b.time
	end)

	-- Print sorted results
	--	print("Sorted result (as array of key-time pairs)")
	--	print(vim.inspect(sorted_result))
	return sorted_result
end
-- Function to associate a prefix key with an action key
function M.run_prefix_key(prefix_key, desc, key_span, desc_callback)
	local total_width = vim.opt.columns:get()
	local base_color = M.string_to_color(desc .. "xcxc")
	base_color = M.adjust_color(base_color, 40, 50)
	--base_color = M.make_blue_bright(base_color)
	local lighter_color = M.lighter_shade(base_color, 1.2)
	local darker_color = M.darker_shade(base_color, 0.8)
	local darker_color2 = M.darker_shade(base_color, 0.3)
	local lighter_color2 = M.lighter_shade(base_color, 1.7)
	local comp_color = M.complementary_color(base_color)
	local tri1, tri2 = M.triadic_colors(base_color)
	local lighter_tri1 = M.lighter_shade(tri1, 2.2)

	-- Use the string_to_color function to generate colors from seeds
	vim.cmd("highlight MenuBarHighlight1 guifg=" .. darker_color .. " guibg=NONE")
	vim.cmd("highlight MenuBarHighlight2 guifg=" .. base_color .. " guibg=NONE")
	vim.cmd("highlight MenuBarHighlight3 guifg=" .. lighter_color .. " guibg=NONE")

	vim.cmd("highlight TitleHighlight guifg=" .. lighter_tri1 .. " guibg=NONE")
	vim.cmd("highlight SelectedHighlight guifg=" .. lighter_color2 .. " guibg=" .. darker_color2)
	vim.cmd("highlight ItemNameHighlight guifg=" .. comp_color .. " guibg=NONE")
	vim.cmd("highlight KeyHighlight guifg=" .. lighter_color2 .. " guibg=NONE")
	--	vim.cmd("highlight ItemNameHighlight guifg=" .. tri1 .. " guibg=NONE")
	--vim.cmd("highlight ScoreBlockHighlight guifg=" .. tri2 .. " guibg=NONE")

	local keys = get_key_and_desc_action_keys(prefix_key)
	local key_score_map, key_stats_table = M.stats_calculate_key_score(prefix_key, key_span)

	-- Prepare the table needed to print the most recentkeys,
	-- Need to be same format as keys table
	local recent_used_keys_map = sort_keys_by_most_recent_unixtimestamp(key_stats_table)
	local recent_used_keys_map_with_desc = {}
	for _, entry in ipairs(recent_used_keys_map) do
		local entry_key = entry.key -- Character key part
		local entry_desc = "" -- Default description

		-- Search `keys` for a matching entry to get the description
		for _, key_entry in ipairs(keys) do
			if key_entry[1] == entry_key then
				entry_desc = key_entry[2]
				break
			end
		end
		if entry_desc ~= "" then
			table.insert(recent_used_keys_map_with_desc, { entry_key, entry_desc })
		end
		-- Insert into the result as {key, description}
	end
	--local score_colors_map = M.apply_diagonal_shades(M.string_to_color(prefix_key), key_score_map)
	local score_colors_map = M.apply_diagonal_shades(tri1, key_score_map, 0.02, 0.5)

	--TODO: If screen is too small and content wont fit, we shouldn't display the hints or we get into the "Pess ENTER or type..." mode, which disables g,b,u... keys from reaching vim.fm.getchar()
	if desc_callback ~= nil then
		desc = desc_callback() -- Set desc to desc_callback's value if it's not nil
	else
		desc = desc or "default description" -- Use desc or set a default value
	end
	show_key_hints(keys, desc, score_colors_map, recent_used_keys_map_with_desc, title)
	local next_key = vim.fn.getchar() -- Read the next input key

	--show_key_hints changes cmdheight, so we need to reset it
	vim.opt.cmdheight = 1 -- Ensure it fits the screen height
	-- Convert the key code to a string if necessary
	next_key = vim.fn.nr2char(next_key)

	M.run_associated_action_key(prefix_key, next_key, key_span)
	--require("dynkey").run_dynamic_key(prefix_key, next_key)
end

-- Function to run the function associated with a given prefix and action key
function M.run_associated_action_key(prefix_key, action_key, key_span)
	-- Fetch the action table for the prefix key
	local prefix_table = key_mappings[prefix_key]
	if prefix_table and prefix_table.actions[action_key] then
		-- Run the associated function
		--log("Running action key _" .. action_key .. "_ for prefix _" .. prefix_key .. "_")
		prefix_table.actions[action_key].func()
		-- Collect some statistics of what keys are used the most
		stats_record_key(prefix_key, action_key, key_span)
	else
		log("No action found for key: " .. action_key)
	end
end

-- Function to add an action key under a prefix key
function M.add_action_key(prefix_key, action_key, func, desc)
	-- Ensure the prefix key is set up
	if not key_mappings[prefix_key] then
		-- Create the prefix key with an empty actions table and a default description
		key_mappings[prefix_key] = { desc = "Prefix key: " .. prefix_key, actions = {} }
	end
	-- Add the action key with its function and description
	key_mappings[prefix_key].actions[action_key] = { func = func, desc = desc }
end

function M.remove_action_key(prefix_key, action_key)
	-- Ensure the prefix key exists
	if not key_mappings[prefix_key] then
		log("Prefix key _" .. prefix_key .. "_ does not exist")
		return
	end

	-- Check if the action key exists under the given prefix key
	if not key_mappings[prefix_key].actions[action_key] then
		return
	end

	-- Remove the action key (by setting it to nil, which removes it from the table)
	key_mappings[prefix_key].actions[action_key] = nil

	-- If no more action keys are left under the prefix, optionally remove the prefix key
	if next(key_mappings[prefix_key].actions) == nil then
		key_mappings[prefix_key] = nil
	end
end

-- function M.is_it_action_key(prefix_key, action_key)
-- 	-- Ensure the prefix key exists
-- 	if not key_mappings[prefix_key] then
-- 		log("Prefix key _" .. prefix_key .. "_ does not exist")
-- 		return false
-- 	end
--
-- 	-- Check if the action key exists under the given prefix key
-- 	if key_mappings[prefix_key].actions[action_key] then
-- 		log("Action key _" .. action_key .. "_ exists under prefix _" .. prefix_key .. "_")
-- 		return true
-- 	else
-- 		log("Action key _" .. action_key .. "_ does not exist under prefix _" .. prefix_key .. "_")
-- 		return false
-- 	end
-- end

return M
