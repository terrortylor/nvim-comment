# nvim-comment

Toggle comments in Neovim, using built in `commentstring` filetype option;
written in Lua. Without a doubt this plugin **is not required** and is a rip off
of [TPope's Commentary](https://github.com/tpope/vim-commentary) with less
features! What makes this plugin stand out over the numerous other comment
plugins written in Lua are:

- Comments each line, rather than adds block comments; making it easier to
  toggle code when debugging
- Uses the built in `commentstring` buffer option to define comment markers
- Where a marker doesn't have a **space** character as padding this is added,
  configurable (this can be disabled in the options, see below but is useful
  when working with numerous linters)
- Supports motions
- Dot `.` repeatable

When the plugin is called it works out the range to comment/uncomment; if all
lines in the given range are commented then it uncomments, otherwise it comments
the range. This is useful when commenting a block out for testing with a real
like comment in it; as for the plugin a comment is a comment.

## Usage

Either use the command `CommentToggle`, e.g.:

- `CommentToggle` comment/uncomment current line
- `67,69CommentToggle` comment/uncomment a range
- `'<,'>CommentToggle` comment/uncomment a visual selection

Or use the default mappings:

- `gcc` comment/uncomment current line, this does not take a count, if you want
  a count use the `gc{count}{motion}`
- `gc{motion}` comment/uncomment selection defined by a motion (as lines are
  commented, any comment toggling actions will default to a linewise):
  - `gcip` comment/uncomment a paragraph
  - `gc4w` comment/uncomment current line
  - `gc4j` comment/uncomment 4 lines below the current line
  - `dic` delete comment block
  - `gcic` uncomment commented block

### Configure

The comment plugin needs to be initialised using:

```lua
require('nvim_comment').setup()
```

However you can pass in some config options, the defaults are:

```lua
{
  -- Linters prefer comment and line to have a space in between markers
  marker_padding = true,
  -- should comment out empty or whitespace only lines
  comment_empty = true,
  -- trim empty comment whitespace
  comment_empty_trim_whitespace = true,
  -- Should key mappings be created
  create_mappings = true,
  -- Normal mode mapping left hand side
  line_mapping = "gcc",
  -- Visual/Operator mapping left hand side
  operator_mapping = "gc",
  -- text object mapping, comment chunk,,
  comment_chunk_text_object = "ic",
  -- Hook function to call before commenting takes place
  hook = nil
}
```

- Ignore Empty Lines

```lua
require('nvim_comment').setup({comment_empty = false})
```

- Don't trim trailing comment whitespace when commenting empty line
```lua
require('nvim_comment').setup({comment_empty_trim_whitespace = false})
```

The default for this is `true`, meaning that a commented empty line will not
contain any whitespace. Most `commentstring` comment prefixes have some
whitespace padding, disable this to keep that padding on empty lines.

- Disable mappings

```lua
require('nvim_comment').setup({create_mappings = false})
```

- Custom mappings

```lua
require('nvim_comment').setup({line_mapping = "<leader>cl", operator_mapping = "<leader>c", comment_chunk_text_object = "ic"})
```

- Disable marker padding

```lua
require('nvim_comment').setup({marker_padding = false})
```

- Hook function called before reading `commentstring`

You can run arbitrary function which will be called before plugin reads value of
`commentstring`. This can be used to integrate with
[JoosepAlviste/nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring):

```lua
require('nvim_comment').setup({
  hook = function()
    if vim.api.nvim_buf_get_option(0, "filetype") == "vue" then
      require("ts_context_commentstring.internal").update_commentstring()
    end
  end
})
```

- Changing/Setting `commentstring`

If you want to override the comment markers or add a new filetype just set the
`commentstring` options:

```lua
-- Assumes this is being run in the context of the filetype...
vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
```

You can also use an autocommand to automatically load your `commentstring` for
certain file types:

```vim
" when you enter a (new) buffer
augroup set-commentstring-ag
autocmd!
autocmd BufEnter *.cpp,*.h :lua vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
" when you've changed the name of a file opened in a buffer, the file type may have changed
autocmd BufFilePost *.cpp,*.h :lua vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
augroup END
```

Or add the comment string option in the relevant `filetype` file:

```vim
let commentstring="# %s"
```

```lua
vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
```

## Installation

Install just as you would a normal plugin, here are some options:

### Built in package manager

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
cd ~/.local/share/nvim/site/pack/plugins/start
git clone https://github.com/terrortylor/nvim-comment
```

### Via a plugin manager

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use "terrortylor/nvim-comment"
require('nvim_comment').setup()
```
