local api = vim.api

local M = {}

M.config = {
  -- Linters prefer comment and line to have a space in between
  marker_padding = true,
  -- should comment out empty or whitespace only lines
  comment_empty = true,
  -- Should key mappings be created
  create_mappings = true,
  -- Normal mode mapping left hand side
  line_mapping = "gcc",
  -- Visual/Operator mapping left hand side
  operator_mapping = "gc",
  -- Hook function to call before commenting takes place
  hook = nil
}

function M.get_comment_wrapper()
  local cs = api.nvim_buf_get_option(0, 'commentstring')

  -- make sure comment string is understood
  if cs:find('%%s') then
   local left, right = cs:match('^(.*)%%s(.*)')
   if right == "" then right = nil end

   -- left comment markers should have padding as linterers preffer
   if  M.config.marker_padding then
     if not left:match("%s$") then left = left .. " " end
     if right and not right:match("^%s") then right = " " .. right end
   end

   return left, right
  else
    api.nvim_command('echom "Commentstring not understood: ' .. cs .. '"')
  end
end

function M.comment_line(l, indent, left, right, comment_empty)
  if not comment_empty and l:match("^%s*$") then return l end

  -- standarise indentation before adding
  local line = l:gsub("^" .. indent, "")
  if right then line = line .. right end
  return indent .. left .. line
end

function M.uncomment_line(l, left, right)
  local line = l
  if right then line = line:gsub(vim.pesc(right) .. '$', '') end
  line = line:gsub(vim.pesc(left), '', 1)
  return line
end

function M.operator(mode)
  local line1, line2
  if not mode then
    line1 = api.nvim_win_get_cursor(0)[1]
    line2 = line1
  elseif mode:match("[vV]") then
    line1 = api.nvim_buf_get_mark(0, "<")[1]
    line2 = api.nvim_buf_get_mark(0, ">")[1]
  else
    line1 = api.nvim_buf_get_mark(0, "[")[1]
    line2 = api.nvim_buf_get_mark(0, "]")[1]
  end

  M.comment_toggle(line1, line2)
end

function M.comment_toggle(line_start, line_end)
  if type(M.config.hook) == 'function' then M.config.hook() end

  local left, right = M.get_comment_wrapper()
  if not left or (not left and not right) then return end

  local lines = api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  if not lines then return end

  -- check if any lines commented, capture indent
  local esc_left = vim.pesc(left)
  local commented_lines_counter = 0
  local empty_counter = 0
  local indent

  for _,v in pairs(lines) do
    if v:find('^%s*' .. esc_left) then
      commented_lines_counter = commented_lines_counter + 1
    elseif v:match("^%s*$") then
      empty_counter = empty_counter + 1
    end
    -- TODO what if already commented line has smallest indent?
    -- TODO no tests for this indent block
    local line_indent = v:match("^%s+") or ""
    if not indent or string.len(line_indent) < string.len(indent) then
      indent = line_indent
    end
  end

  for i,v in pairs(lines) do
    if commented_lines_counter ~= (#lines - empty_counter) then
      lines[i] = M.comment_line(v, indent, left, right, M.config.comment_empty)
    else
      lines[i] = M.uncomment_line(v, left, right)
    end
  end
  api.nvim_buf_set_lines(0, line_start - 1, line_end, false, lines)

  -- The lua call seems to clear the visual selection so reset it
  -- 2147483647 is vimL built in
  api.nvim_call_function("setpos", {"'<", {0, line_start, 1, 0}})
  api.nvim_call_function("setpos", {"'>", {0, line_end, 2147483647, 0}})
end

function M.setup(user_opts)
  M.config = vim.tbl_extend('force', M.config, user_opts or {})

  -- Messy, change with nvim_exec once merged
  local vim_func = [[
  function! CommentOperator(type) abort
    let reg_save = @@
    execute "lua require('nvim_comment').operator('" . a:type. "')"
    let @@ = reg_save
  endfunction
  ]]
  vim.api.nvim_call_function("execute", {vim_func})
  vim.api.nvim_command("command! -range CommentToggle lua require('nvim_comment').comment_toggle(<line1>, <line2>)")

  if M.config.create_mappings then
    local opts = {noremap = true, silent = true}
    api.nvim_set_keymap("n", M.config.line_mapping, "<Cmd>set operatorfunc=CommentOperator<CR>g@l", opts)
    api.nvim_set_keymap("n", M.config.operator_mapping, "<Cmd>set operatorfunc=CommentOperator<CR>g@", opts)
    api.nvim_set_keymap("v", M.config.operator_mapping, ":<C-u>call CommentOperator(visualmode())<CR>", opts)
  end
end

return M
