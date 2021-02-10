# nvim-comment

Toggle comments in Neovim, using built in **commentstring** filetype option; written in Lua.
Without a doubt this plugin **is not required** and is a rip off of [TPope's Commentary](https://github.com/tpope/vim-commentary)! What makes this plugin stand out over the numerous other comment plugins written in Lua are:

* Doesn't require nightly build (works on NeoVim 0.4.x)
* Comments each line, rather than adds block comments; making it easier to toggle code when debugging
* Uses the built in **commentstring** buffer option to define comment markers
* Where a marker doesn't have a **space** character as padding this is added, configurable
** This can be disabled in the options, see below but if useful when workig with numerous linters
* Supports motions, aimed to support the feature set of [TPope's Commentary](https://github.com/tpope/vim-commentary)

When the plugin is called it works out the range to comment/uncomment; if all lines in the given range are commented then it uncomments, otherwise it comments the range. This is useful when commenting a block out for testing with a real like comment in it; as for the plugin a comment is a comment.

# Usage

Either use the command `CommentToggle`, e.g.:

* `CommentToggle` comment/uncomment current line
* `67,69CommentToggle` comment/uncomment a range
* `'<,>CommentToggle` comment/uncomment a visual selection

Or use the defualt mappings:

* `gcc` comment/uncomment current line
* `gc{motion}` comment/uncomment selection defined by a motion:
** As lines are commented, any comment toggling actions will default to a linewise.
** `gcc` comment/uncomment current line
** `gcip` comment/uncomment a paragraph
** `gc4w` comment/uncomment current line

## Configure

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
  -- Should key mappings be created
  create_mappings = true,
  -- Normal mode mapping left hand side
  line_mapping = "gcc",
  -- Visual/Operator mapping left hand side
  operator_mapping = "gc"
}
```

**Ignore Empty Lines**
```lua
require('nvim_comment').setup({comment_empty = false})
```

**Disable mappings**
```lua
require('nvim_comment').setup({create_mappings = false})
```

**Custom mappings**
```lua
require('nvim_comment').setup({line_mapping = "<leader>cl", operator_mapping = "<leader>c"})
```

**Disable marker padding**
```lua
require('nvim_comment').setup({marker_padding = false})
```

**Changing/Setting commentstring**

If you want to override the comment markers or add a new filetype just set the **commentstring** options:

```lua
-- Assumes this is being run in the context of the filetype...
vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
```

# Installation

Install just as you would a normal plugin, here are some options:

**Built in package manager**

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
cd ~/.local/share/nvim/site/pack/plugins/start
git clone https://github.com/terrortylor/nvim-comment
```

**Via a plugin manager**

Using [nvim-pluginman](https://github.com/terrortylor/nvim-pluginman):
```lua
plug.add({
  url = "terrortylor/nvim-comment",
  post_handler = function()
    require('nvim_comment').setup()
  end
})
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use "terrortylor/nvim-comment"
require('nvim_comment').setup()
```
