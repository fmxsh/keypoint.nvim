-- All Neovim key bindings (that I was able to identify)
-- Based on https://neovim.io/doc/user/quickref.html
local legend = {
	mode = {
		n = {
			-- NOTE: Finding keys
			-- Keys not immportant
			-- =
			-- -
			-- ` or ' as they are defined the same almost
			-- §
			-- z, dont use folding, and if i do, it can be in after <leader> key
			-- Keys to exchange with
			-- r - replace
			-- exchage a and z
			-- z and v
			-- , and v
			-- , and a
			--
			-- project = v,
			-- functions = r
			-- buffers = r
			--
			-- projects = ; and ; goes to =
			-- buffer = r, and r goes to q and q goes to -
			-- functions = z
			--

			left_right_motions = {
				-- Left-right motion group

				["h"] = "", -- Move cursor left N times (also: CTRL-H, <BS>, or <Left> key)
				["l"] = "", -- Move cursor right N times (also: <Space> or <Right> key)
				["0"] = "", -- Move cursor to the first character in the line (also: <Home> key)
				["^"] = "", -- Move cursor to the first non-blank character in the line
				["$"] = "", -- Move cursor to the next EOL position (also: <End> key)
				["g0"] = "", -- Move cursor to the first character in the screen line
				["g^"] = "", -- Move cursor to the first non-blank character in the screen line (wraps)
				["g$"] = "", -- Move cursor to the last character in the screen line
				["gm"] = "", -- Move cursor to the middle of the screen line
				["gM"] = "", -- Move cursor to the middle of the line
				["|"] = "", -- Move cursor to column N (default: 1)
				["f"] = "", -- Move to the Nth occurrence of {char} to the right
				["F"] = "", -- Move to the Nth occurrence of {char} to the left
				["t"] = "", -- Move till before the Nth occurrence of {char} to the right
				["T"] = "", -- Move till before the Nth occurrence of {char} to the left
				[";"] = "", -- Repeat the last "f", "F", "t", or "T" N times
				[","] = "", -- Repeat the last "f", "F", "t", or "T" N times in the opposite direction
			},

			up_down_motions = {
				-- Up-down motion group

				["k"] = "", -- Move cursor up N lines (also: CTRL-P and <Up>)
				["j"] = "", -- Move cursor down N lines (also: CTRL-J, CTRL-N, <NL>, and <Down>)
				["-"] = "", -- Move cursor up N lines, on the first non-blank character
				["+"] = "", -- Move cursor down N lines, on the first non-blank character (also: CTRL-M and <CR>)
				["_"] = "", -- Move cursor down N-1 lines, on the first non-blank character
				["G"] = "", -- Move cursor to line N (default: last line), on the first non-blank character
				["gg"] = "", -- Move cursor to line N (default: first line), on the first non-blank character
				["%"] = "", -- Move cursor to line N percentage down in the file; N must be given, otherwise it is the % command
				-- Does gk exist?
				["gk"] = "", -- Move cursor up N screen lines (differs from "k" when line wraps)
				["gj"] = "", -- Move cursor down N screen lines (differs from "j" when line wraps)
			},
			text_object_motions = {
				-- Text object motions group

				["w"] = "", -- Move N words forward
				["W"] = "", -- Move N blank-separated WORDs forward
				["e"] = "", -- Move forward to the end of the Nth word
				["E"] = "", -- Move forward to the end of the Nth blank-separated WORD
				["b"] = "", -- Move N words backward
				["B"] = "", -- Move N blank-separated WORDs backward
				["ge"] = "", -- Move backward to the end of the Nth word
				["gE"] = "", -- Move backward to the end of the Nth blank-separated WORD
				["("] = "", -- Move N sentences backward
				[")"] = "", -- Move N sentences forward
				["{"] = "", -- Move N paragraphs backward
				["}"] = "", -- Move N paragraphs forward
				["[["] = "", -- Move N sections backward, at start of section
				["]]"] = "", -- Move N sections forward, at start of section
				["[]"] = "", -- Move N sections backward, at end of section
				["]["] = "", -- Move N sections forward, at end of section
				["[("] = "", -- Move N times back to unclosed '('
				["[{"] = "", -- Move N times back to unclosed '{'
				["[m"] = "", -- Move N times back to start of method (for Java)
				["[M"] = "", -- Move N times back to end of method (for Java)
				["])"] = "", -- Move N times forward to unclosed ')'
				["]}"] = "", -- Move N times forward to unclosed '}'
				["]m"] = "", -- Move N times forward to start of method (for Java)
				["]M"] = "", -- Move N times forward to end of method (for Java)
				["[#"] = "", -- Move N times back to unclosed "#if" or "#else"
				["]#"] = "", -- Move N times forward to unclosed "#else" or "#endif"
				["[*"] = "", -- Move N times back to start of comment "/*"
				["]*"] = "", -- Move N times forward to end of comment "*/"
			},

			pattern_search = {
				-- Pattern searches group
				["/"] = "", -- Search forward for the Nth occurrence of {pattern}
				["?"] = "", -- Search backward for the Nth occurrence of {pattern}
				["/<CR>"] = "", -- Repeat last search, in the forward direction
				["?<CR>"] = "", -- Repeat last search, in the backward direction
				["n"] = "", -- Repeat last search
				["N"] = "", -- Repeat last search, in opposite direction
				["*"] = "", -- Search forward for the identifier under the cursor
				["#"] = "", -- Search backward for the identifier under the cursor
				["g*"] = "", -- Like "*", but also find partial matches
				["g#"] = "", -- Like "#", but also find partial matches
				["gd"] = "", -- Goto local declaration of identifier under the cursor
				["gD"] = "", -- Goto global declaration of identifier under the cursor
			},

			marks_and_motions = {
				-- Marks and motions group
				-- Witch key specifies `^ for ex, and its in the ref unless i missed
				-- TODO: Check all against which key
				-- dsf
				["m"] = "", -- Mark current position with mark {a-zA-Z}
				["`a"] = "", -- Go to mark {a-z} within current file
				["`A"] = "", -- Go to mark {A-Z} in any file
				["`0"] = "", -- Go to the position where Vim was previously exited
				["``"] = "", -- Go to the position before the last jump
				['`"'] = "", -- Go to the position when last editing this file
				["`[["] = "", -- Go to the start of the previously operated or put text
				["`]]"] = "", -- Go to the end of the previously operated or put text
				["`<<"] = "", -- Go to the start of the (previous) Visual area
				["`>>"] = "", -- Go to the end of the (previous) Visual area
				-- Not correct
				["`.."] = "", -- Go to the position of the last change in this file
				["'"] = "", -- Same as backtick, but goes to the first non-blank in the line
				-- Backtick not in the quickref, but i assume it is for marks: https://neovim.io/doc/user/quickref.html
				["`"] = "", -- Same as backtick, but goes to the first non-blank in the line
				["<C-O>"] = "", -- Go to Nth older position in jump list
				["<C-I>"] = "", -- Go to Nth newer position in jump list
			},

			various_motions = {
				-- Various motions group

				["%"] = "", -- Find the next brace, bracket, comment, or "#if"/"#else"/"#endif" in this line and go to its match
				["H"] = "", -- Go to the Nth line in the window, on the first non-blank
				["M"] = "", -- Go to the middle line in the window, on the first non-blank
				["L"] = "", -- Go to the Nth line from the bottom, on the first non-blank
				["go"] = "", -- Go to the Nth byte in the buffer
			},

			using_tags = {
				-- Using tags group

				["<C-]>"] = "", -- Jump to the tag under the cursor, unless changes have been made
				["<C-T>"] = "", -- Jump back from Nth older tag in tag list
				["<C-W>}"] = "", -- Like CTRL-] but show tag in preview window
				["<C-W>z"] = "", -- Close tag preview window
			},

			scrolling = {
				-- Scrolling group

				["<C-E>"] = "", -- Scroll window N lines downwards (default: 1)
				["<C-D>"] = "", -- Scroll window N lines downwards (default: 1/2 window)
				["<C-F>"] = "", -- Scroll window N pages forwards (downwards)
				["<C-Y>"] = "", -- Scroll window N lines upwards (default: 1)
				["<C-U>"] = "", -- Scroll window N lines upwards (default: 1/2 window)
				["<C-B>"] = "", -- Scroll window N pages backwards (upwards)
				["z<CR>"] = "", -- Redraw, current line at top of window (zt)
				["z."] = "", -- Redraw, current line at center of window (zz)
				["z-"] = "", -- Redraw, current line at bottom of window (zb)

				-- These only work when 'wrap' is off:
				["zh"] = "", -- Scroll screen N characters to the right
				["zl"] = "", -- Scroll screen N characters to the left
				["zH"] = "", -- Scroll screen half a screenwidth to the right
				["zL"] = "", -- Scroll screen half a screenwidth to the left
			},

			inserting_text = {
				-- Inserting text group

				["a"] = "", -- Append text after the cursor (N times)
				["A"] = "", -- Append text at the end of the line (N times)
				["i"] = "", -- Insert text before the cursor (N times) (also: <Insert>)
				-- For some reason, disabling by loop this doesn't work to do gi first and I next, but it works if done manually
				["gI"] = "", -- Insert text in column 1 (N times)
				["I"] = "", -- Insert text before the first non-blank in the line (N times)
				["o"] = "", -- Open a new line below the current line, append text (N times)
				["O"] = "", -- Open a new line above the current line, append text (N times)
			},

			deleting_text = {
				-- Deleting text group

				["x"] = "", -- Delete N characters under and after the cursor
				["<Del>"] = "", -- Delete N characters under and after the cursor
				["X"] = "", -- Delete N characters before the cursor
				["d"] = "", -- Delete the text that is moved over with {motion}
				["dd"] = "", -- Delete N lines
				["D"] = "", -- Delete to the end of the line (and N-1 more lines)
				["J"] = "", -- Join N-1 lines (delete <EOL>s)
				["gJ"] = "", -- Like "J", but without inserting spaces
			},

			copying_moving_text = {
				-- Copying and moving text group

				['"'] = "", -- Use register {char} for the next delete, yank, or put
				["y"] = "", -- Yank the text moved over with {motion} into a register
				["v_y"] = "", -- Yank the highlighted text into a register in visual mode
				["yy"] = "", -- Yank N lines into a register
				["Y"] = "", -- Yank N lines into a register (mapped to "y$" by default)
				["p"] = "", -- Put a register after the cursor position (N times)
				["P"] = "", -- Put a register before the cursor position (N times)
				["]p"] = "", -- Like p, but adjust indent to current line
				["[p"] = "", -- Like P, but adjust indent to current line
				["gp"] = "", -- Like p, but leave cursor after the new text
				["gP"] = "", -- Like P, but leave cursor after the new text
			},

			changing_text = {
				-- Changing text group

				["r"] = "", -- Replace N characters with {char}
				["gr"] = "", -- Replace N characters without affecting layout
				["R"] = "", -- Enter Replace mode (repeat the entered text N times)
				["gR"] = "", -- Enter virtual Replace mode: Like Replace mode but without affecting layout
				["c"] = "", -- Change the text that is moved over with {motion}
				["cc"] = "", -- Change N lines
				["S"] = "", -- Change N lines
				["C"] = "", -- Change to the end of the line (and N-1 more lines)
				["s"] = "", -- Change N characters
				["~"] = "", -- Switch case for N characters and advance cursor
				["g~"] = "", -- Switch case for the text that is moved over with {motion}
				["gu"] = "", -- Make the text that is moved over with {motion} lowercase
				["gU"] = "", -- Make the text that is moved over with {motion} uppercase
				["g?"] = "", -- Perform rot13 encoding on the text that is moved over with {motion}
				["<C-A>"] = "", -- Add N to the number at or after the cursor
				["<C-X>"] = "", -- Subtract N from the number at or after the cursor
				["<"] = "", -- Move the lines that are moved over with {motion} one shiftwidth left
				["<<"] = "", -- Move N lines one shiftwidth left
				[">"] = "", -- Move the lines that are moved over with {motion} one shiftwidth right
				[">>"] = "", -- Move N lines one shiftwidth right
				["gq"] = "", -- Format the lines that are moved over with {motion} to 'textwidth' length
			},

			complex_changes = {
				-- Complex changes group

				["!"] = "", -- Filter the lines that are moved over through {command}
				["!!"] = "", -- Filter N lines through {command}
				["="] = "", -- Filter the lines that are moved over through 'equalprg'
				["=="] = "", -- Filter N lines through 'equalprg'
				["&"] = "", -- Repeat previous ":s" on current line without options
			},

			repeating_commands_mappings = {
				-- Repeating commands group

				["."] = "", -- Repeat last change (with count replaced with N)
				["q"] = "", -- Record typed characters into register {a-z}
				--["q{a-z}"] = "", -- Record typed characters into register {a-z}
				--["q{A-Z}"] = "", -- Record typed characters, appended to register {a-z}
				--["q"] = "", -- Stop recording
				["Q"] = "", -- Replay last recorded macro
				["@"] = "", -- Execute the contents of register {a-z} (N times)
				["@@"] = "", -- Repeat previous @{a-z} (N times)
				["gs"] = "", -- Goto Sleep for N seconds
			},

			undo_redo_commands_mappings = {
				-- Undo/Redo commands group

				["u"] = "", -- Undo last N changes
				["<C-R>"] = "", -- Redo last N undone changes
				["U"] = "", -- Restore last changed line
			},

			external_commands_mappings = {
				-- External commands group

				["K"] = "", -- Lookup keyword under the cursor with 'keywordprg' program (default: "man")
			},

			various_commands_mappings = {
				-- Various commands group

				["<C-L>"] = "", -- Clear and redraw the screen
				["<C-G>"] = "", -- Show current file name (with path) and cursor position
				["ga"] = "", -- Show ASCII value of character under cursor in decimal, hex, and octal
				["g8"] = "", -- For UTF-8 encoding: show byte sequence for character under cursor in hex
				["g<C-G>"] = "", -- Show cursor column, line, and character position
				["<C-C>"] = "", -- Interrupt the search during searches
				["<Del>"] = "", -- While entering a count: delete last character
				["gQ"] = "", -- Switch to "Ex" mode
				-- Commands i didn't find in the quickref or somehow missed
				--[":"] = "", -- Switch to command-line mode
				["v"] = "", -- Switch to visual mode
				[" "] = "", -- Go forward one step (?)
			},

			editing_a_file_mappings = {
				-- Editing a file group

				["<C-^>"] = "", -- Edit alternate file N (equivalent to ":e #N")
				["gf"] = "", -- Edit the file whose name is under the cursor
			},

			writing_and_quitting_mappings = {
				-- Writing and quitting group

				["ZZ"] = "", -- Same as ":x"
				["ZQ"] = "", -- Same as ":q!"
				["<C-Z>"] = "", -- Same as ":stop"
			},

			multi_window_commands_mappings = {
				-- Multi-window commands group
				-- Tese are global to all modes
				["<C-W>s"] = "", -- Split window into two parts
				["<C-W>]"] = "", -- Split window and jump to tag under cursor
				["<C-W>f"] = "", -- Split window and edit file name under the cursor
				["<C-W>^"] = "", -- Split window and edit alternate file
				["<C-W>n"] = "", -- Create new empty window
				["<C-W>q"] = "", -- Quit editing and close window
				["<C-W>c"] = "", -- Make buffer hidden and close window
				["<C-W>o"] = "", -- Make current window the only one on the screen
				["<C-W>j"] = "", -- Move cursor to window below
				["<C-W>k"] = "", -- Move cursor to window above
				["<C-W><C-W>"] = "", -- Move cursor to window below (wrap)
				["<C-W>W"] = "", -- Move cursor to window above (wrap)
				["<C-W>t"] = "", -- Move cursor to top window
				["<C-W>b"] = "", -- Move cursor to bottom window
				["<C-W>p"] = "", -- Move cursor to previous active window
				["<C-W>r"] = "", -- Rotate windows downwards
				["<C-W>R"] = "", -- Rotate windows upwards
				["<C-W>x"] = "", -- Exchange current window with next one
				["<C-W>="] = "", -- Make all windows equal height & width
				["<C-W>-"] = "", -- Decrease current window height
				["<C-W>+"] = "", -- Increase current window height
				["<C-W>_"] = "", -- Set current window height (default: very high)
				["<C-W><"] = "", -- Decrease current window width
				["<C-W>>"] = "", -- Increase current window width
				["<C-W>|"] = "", -- Set current window width (default: widest possible)
			},

			folding_mappings = {
				-- Folding group

				["zf"] = "", -- Operator: Define a fold manually
				["zd"] = "", -- Delete one fold under the cursor
				["zD"] = "", -- Delete all folds under the cursor
				["zo"] = "", -- Open one fold under the cursor
				["zO"] = "", -- Open all folds under the cursor
				["zc"] = "", -- Close one fold under the cursor
				["zC"] = "", -- Close all folds under the cursor
				["zm"] = "", -- Fold more: decrease 'foldlevel'
				["zM"] = "", -- Close all folds: make 'foldlevel' zero
				["zr"] = "", -- Reduce folding: increase 'foldlevel'
				["zR"] = "", -- Open all folds: make 'foldlevel' max
				["zn"] = "", -- Fold none: reset 'foldenable'
				["zN"] = "", -- Fold normal set 'foldenable'
				["zi"] = "", -- Invert 'foldenable'
			},
		},

		i = {
			-- Insert mode and insert normal mode (the latter; CTRL-O; allows temporary access to Normal mode commands while in Insert mode.)

			general = {
				-- Insert mode: Leaving Insert mode
				["<Esc>"] = "", -- End Insert mode, back to Normal mode
				["<C-C>"] = "", -- Like <Esc>, but do not use an abbreviation
				["<C-O>"] = "", -- Execute {command} and return to Insert mode

				-- Insert mode: Moving around
				["<Up>"] = "", -- Move cursor up
				["<S-Left>"] = "", -- Move one word left
				["<S-Right>"] = "", -- Move one word right
				["<S-Up>"] = "", -- Move one screenful backward
				["<S-Down>"] = "", -- Move one screenful forward
				["<End>"] = "", -- Move cursor after last character in the line
				["<Home>"] = "", -- Move cursor to first character in the line

				-- Special keys in Insert mode

				["<C-V>"] = "", -- Insert character literally, or enter decimal byte value
				["<NL>"] = "", -- Begin new line (<NL>, <CR>, CTRL-M, or CTRL-J)
				["<C-E>"] = "", -- Insert the character from below the cursor
				["<C-Y>"] = "", -- Insert the character from above the cursor
				["<C-A>"] = "", -- Insert previously inserted text
				["<C-@>"] = "", -- Insert previously inserted text and stop Insert mode
				["<C-R>"] = "", -- Insert the contents of a register
				["<C-N>"] = "", -- Insert next match of identifier before the cursor
				["<C-P>"] = "", -- Insert previous match of identifier before the cursor
				["<C-X>"] = "", -- Complete the word before the cursor in various ways
				["<BS>"] = "", -- Delete the character before the cursor (also: CTRL-H)
				["<Del>"] = "", -- Delete the character under the cursor
				["<C-W>"] = "", -- Delete word before the cursor
				["<C-U>"] = "", -- Delete all entered characters in the current line
				["<C-T>"] = "", -- Insert one shiftwidth of indent in front of the current line
				["<C-D>"] = "", -- Delete one shiftwidth of indent in front of the current line
				["0<C-D>"] = "", -- Delete all indent in the current line
				["^<C-D>"] = "", -- Delete all indent in the current line, restore indent in next line

				-- Insert or Command-line mode

				["<C-K>"] = "", -- Enter digraph with {char1} {char2}
				--- ???
				--["{char1}<BS>{char2}"] = "", -- Enter digraph if 'digraph' option is set
			},
		},
		v = {
			-- Visual mode

			general = {
				["o"] = "", -- Exchange cursor position with start of highlighting
				["v"] = "", -- Highlight characters or stop highlighting
				["V"] = "", -- Highlight linewise or stop highlighting
				["<C-V>"] = "", -- Highlight blockwise or stop highlighting

				-- Inserting text
				["I"] = "", -- Insert the same text in front of all the selected lines
				["A"] = "", -- Append the same text after all the selected lines

				-- Deleting text
				["d"] = "", -- Delete the highlighted text in visual mode
				["J"] = "", -- Join the highlighted lines in visual mode
				["gJ"] = "", -- Like "{visual}J", but without inserting spaces

				-- Copying and moving text group
				["y"] = "", -- Yank the highlighted text into a register

				-- Changing text group
				["c"] = "", -- Change the highlighted text
				["~"] = "", -- Switch case for highlighted text
				["u"] = "", -- Make highlighted text lowercase
				["U"] = "", -- Make highlighted text uppercase
				["g?"] = "", -- Perform rot13 encoding on highlighted text

				-- Complex changes group

				["!"] = "", -- Filter the highlighted lines through {command}
				["="] = "", -- Filter the highlighted lines through 'equalprg'

				-- Text objects group (only in Visual mode or after an operator)
				["aw"] = "", -- Select "a word"
				["iw"] = "", -- Select "inner word"
				["aW"] = "", -- Select "a WORD"
				["iW"] = "", -- Select "inner WORD"
				["as"] = "", -- Select "a sentence"
				["is"] = "", -- Select "inner sentence"
				["ap"] = "", -- Select "a paragraph"
				["ip"] = "", -- Select "inner paragraph"
				["ab"] = "", -- Select "a block" (from "[(" to "])")
				["ib"] = "", -- Select "inner block" (from "[(" to "])")
				["aB"] = "", -- Select "a Block" (from [{ to ]})
				["iB"] = "", -- Select "inner Block" (from [{ to ]})
				["a>"] = "", -- Select "a <> block"
				["i>"] = "", -- Select "inner <> block"
				["at"] = "", -- Select "a tag block" (from <aaa> to </aaa>)
				["it"] = "", -- Select "inner tag block" (from <aaa> to </aaa>)
				["a'"] = "", -- Select "a single quoted string"
				["i'"] = "", -- Select "inner single quoted string"
				['a"'] = "", -- Select "a double quoted string"
				['i"'] = "", -- Select "inner double quoted string"
				["a`"] = "", -- Select "a backward quoted string"
				["i`"] = "", -- Select "inner backward quoted string"
			},
		},
		-- In Neovim, V is not a separate mode—it is a command within visual mode for linewise selection.
		--		V = {
		--			-- Visual Line mode
		--		},
		x = {

			general = {
				-- Visual Block mode
				-- Changing text group
				["r"] = "", -- In Visual block mode: Replace each char of the selected text with {char}
				["c"] = "", -- In Visual block mode: Change each of the selected lines with the entered text
				["C"] = "", -- In Visual block mode: Change each of the selected lines until end-of-line with the entered text
			},
		},
		s = {
			-- Select mode
		},
		-- ???
		--R = {
		--	-- Replace mode
		--},
		-- ??? why is this here
		--gR = {
		-- Virtual Replace mode
		--},
		o = {
			-- Operator-Pending mode is specifically for motions and text objects that are used with operators.
			-- All commands in normal mode are also available in operator-pending mode if they move the cursor.

			general = {
				-- Text objects group (only in Visual mode or after an operator)

				["aw"] = "", -- Select "a word"
				["iw"] = "", -- Select "inner word"
				["aW"] = "", -- Select "a WORD"
				["iW"] = "", -- Select "inner WORD"
				["as"] = "", -- Select "a sentence"
				["is"] = "", -- Select "inner sentence"
				["ap"] = "", -- Select "a paragraph"
				["ip"] = "", -- Select "inner paragraph"
				["ab"] = "", -- Select "a block" (from "[(" to "])")
				["ib"] = "", -- Select "inner block" (from "[(" to "])")
				["aB"] = "", -- Select "a Block" (from [{ to ]})
				["iB"] = "", -- Select "inner Block" (from [{ to ]})
				["a>"] = "", -- Select "a <> block"
				["i>"] = "", -- Select "inner <> block"
				["at"] = "", -- Select "a tag block" (from <aaa> to </aaa>)
				["it"] = "", -- Select "inner tag block" (from <aaa> to </aaa>)
				["a'"] = "", -- Select "a single quoted string"
				["i'"] = "", -- Select "inner single quoted string"
				['a"'] = "", -- Select "a double quoted string"
				['i"'] = "", -- Select "inner double quoted string"
				["a`"] = "", -- Select "a backward quoted string"
				["i`"] = "", -- Select "inner backward quoted string"
			},
		},
		c = {
			general = {

				-- Command-line mode (the : command)
				-- Insert or Command-line mode

				["<C-K>"] = "", -- Enter digraph with {char1} {char2}
				--- ???
				--["{char1}<BS>{char2}"] = "", -- Enter digraph if 'digraph' option is set

				-- Command-line editing group

				["<Esc>"] = "", -- Abandon command-line (if 'wildchar' is <Esc>, type it twice)
				["<C-V>"] = "", -- Insert {char} literally
				--["<C-V>"] = "", -- Enter decimal value of character (up to three digits)
				--defined above also: ["<C-K>"] = "", -- Enter digraph
				["<C-R>"] = "", -- Insert the contents of a register
				["<Left>"] = "", -- Cursor left
				["<Right>"] = "", -- Cursor right
				["<S-Left>"] = "", -- Cursor one word left
				["<S-Right>"] = "", -- Cursor one word right
				["<C-B>"] = "", -- Cursor to beginning of command-line
				["<C-E>"] = "", -- Cursor to end of command-line
				["<BS>"] = "", -- Delete the character in front of the cursor
				["<Del>"] = "", -- Delete the character under the cursor
				["<C-W>"] = "", -- Delete the word in front of the cursor
				["<C-U>"] = "", -- Remove all characters
				["<Up>"] = "", -- Recall older command-line that starts with current command
				["<Down>"] = "", -- Recall newer command-line that starts with current command
				["<S-Up>"] = "", -- Recall older command-line from history
				["<S-Down>"] = "", -- Recall newer command-line from history
				["<C-G>"] = "", -- Next match when 'incsearch' is active
				["<C-T>"] = "", -- Previous match when 'incsearch' is active

				-- Context-sensitive completion on the command-line
				["<Tab>"] = "", -- Default <Tab> Perform completion on the pattern in front of the cursor
				["<C-D>"] = "", -- List all names that match the pattern in front of the cursor
				["<C-A>"] = "", -- Insert all names that match pattern in front of cursor
				["<C-L>"] = "", -- Insert longest common part of names that match pattern
				["<C-N>"] = "", -- Go to next match after 'wildchar' with multiple matches
				["<C-P>"] = "", -- Go to previous match after 'wildchar' with multiple matches
			},
		},
		t = {
			-- Terminal-Normal mode
		},

		-- there are keys like ['v_b_r'] = '',
	},
}

return legend
