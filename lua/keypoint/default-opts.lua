local default_bind = {
	dry_run = false, -- Dry-run mode is disabled by default
	mappings = {
		n = { -- Example normal mode mappings
			-- Left-right
			h = "h",
			l = "l",

			-- Up-down
			j = "j",
			k = "k",

			-- Text Objects
			aw = "aw", -- "a word"
			iw = "iw", -- "inner word"

			-- Pattern searches
			["*"] = "*",
			["#"] = "#",

			-- Marks
			m = "m",
			["`"] = "`",

			-- Various motions
			w = "w",
			e = "e",
			b = "b",

			-- Scrolling
			["<C-d>"] = "<C-d>",
			["<C-u>"] = "<C-u>",

			-- Inserting
			i = "i",
			I = "I",

			-- Deleting
			d = "d",

			-- Copy Move (yank)
			y = "y",

			-- Changing
			c = "c",

			-- Complex Changes
			D = "D",
			C = "C",

			-- Repeating Commands
			["."] = ".",

			-- Undo Redo Commands
			u = "u",
			["<C-r>"] = "<C-r>",

			-- External Commands
			["!"] = "!",

			-- Various Commands
			["@"] = "@",
			["="] = "=",

			-- Editing a file
			gf = "gf",
			["gF"] = "gF",

			-- Writing Quitting
			ZZ = "ZZ",
			ZQ = "ZQ",

			-- Multi-window
			["<C-w>"] = "<C-w>",

			-- Digraphs
			["<C-k>"] = "<C-k>",

			-- Folding
			za = "za",
		},
		-- Add categories for other modes (Visual, Insert, etc.)
		v = {}, -- Visual mode (example empty for now)
		i = {}, -- Insert mode
		t = {}, -- Terminal mode
	},
}
return default_bind
