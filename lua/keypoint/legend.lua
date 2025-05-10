local legend = {
	n = {
		-- Left-right
		h = { description = "Move left" },
		l = { description = "Move right" },

		-- Up-down
		j = { description = "Move down" },
		k = { description = "Move up" },

		-- Text Objects
		aw = { description = "Text object: a word" },
		iw = { description = "Text object: inner word" },

		-- Pattern searches
		["*"] = { description = "Search forward for word under cursor" },
		["#"] = { description = "Search backward for word under cursor" },

		-- Marks
		m = { description = "Set mark" },
		["`"] = { description = "Jump to mark" },

		-- Various motions
		w = { description = "Move forward by word" },
		e = { description = "Move to end of word" },
		b = { description = "Move backward by word" },

		-- Scrolling
		["<C-d>"] = { description = "Scroll down half a page" },
		["<C-u>"] = { description = "Scroll up half a page" },

		-- Inserting
		i = { description = "Insert at cursor" },
		I = { description = "Insert at the start of the line" },

		-- Deleting
		d = { description = "Delete" },

		-- Copy Move (yank)
		y = { description = "Yank (copy)" },

		-- Changing
		c = { description = "Change" },

		-- Complex Changes
		D = { description = "Delete to the end of the line" },
		C = { description = "Change to the end of the line" },

		-- Repeating Commands
		["."] = { description = "Repeat last command" },

		-- Undo Redo Commands
		u = { description = "Undo" },
		["<C-r>"] = { description = "Redo" },

		-- External Commands
		["!"] = { description = "Execute external command" },

		-- Various Commands
		["@"] = { description = "Execute macro" },
		["="] = { description = "Re-indent lines" },

		-- Editing a file
		gf = { description = "Go to file under cursor" },
		["gF"] = { description = "Go to file and line under cursor" },

		-- Writing Quitting
		ZZ = { description = "Save and quit" },
		ZQ = { description = "Quit without saving" },

		-- Multi-window
		["<C-w>"] = { description = "Window commands" },

		-- Digraphs
		["<C-k>"] = { description = "Insert digraph" },

		-- Folding
		za = { description = "Toggle fold" },
	},
}

return legend
