local function setUpBuffer(input, filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
  vim.api.nvim_command("sbuffer " .. buf)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(input, "\n"))
end

local function goToLineRunReturn(line, feedkeys)
    vim.api.nvim_win_set_cursor(0, {line,0})
    vim.api.nvim_feedkeys(feedkeys, "x", false)

    local result = vim.api.nvim_buf_get_lines(
    0, 0, vim.api.nvim_buf_line_count(0), false
    )
    return result
end

local function runCommandAndAssert(line, feedkeys, expected)
  local result = goToLineRunReturn(line, feedkeys)
  assert.are.same(vim.split(expected, "\n"), result)
end

describe('comment/uncomment', function()

  local input = [[
local function dummy_func()
  print("This is a dummy func")
end

local function another_dummy_func()
  print("This is a another dummy func")
end
]]

  before_each(function()
    local testModule = require('nvim_comment')
    testModule.setup({
      marker_padding = true
    })
  end)

  after_each(function()
  end)

  it("Should comment/uncomment line with dot repeatable", function()
    local expected = [[
-- local function dummy_func()
  print("This is a dummy func")
end

local function another_dummy_func()
  print("This is a another dummy func")
end
]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(1, "gcl", expected)
    -- uncomment
    runCommandAndAssert(1, "gcl", input)
     -- comment, via dot
    runCommandAndAssert(1, ".", expected)
  end)

  it("Should comment/uncomment via motion and dot", function()
    local expected = [[
-- local function dummy_func()
  print("This is a dummy func")
end

local function another_dummy_func()
  print("This is a another dummy func")
end
]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(1, "gcl", expected)
    -- uncomment
    runCommandAndAssert(1, "gcl", input)
     -- comment, via dot
    runCommandAndAssert(1, ".", expected)
  end)

  it("Should comment/uncomment motion with count and dot", function()
    local expected = [[
-- local function dummy_func()
--   print("This is a dummy func")
end

local function another_dummy_func()
  print("This is a another dummy func")
end
]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(1, "gc2l", expected)
    -- uncomment
    runCommandAndAssert(1, "gc2l", input)
     -- comment, via dot
    runCommandAndAssert(1, ".", expected)
  end)

  it("Should comment out another pararaph via dot", function()
    local first_expected = [[
-- local function dummy_func()
--   print("This is a dummy func")
-- end

local function another_dummy_func()
  print("This is a another dummy func")
end
]]

    local second_expected = [[
-- local function dummy_func()
--   print("This is a dummy func")
-- end

-- local function another_dummy_func()
--   print("This is a another dummy func")
-- end
]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(2, "gcip", first_expected)
    -- comment, via dot
    runCommandAndAssert(7, ".", second_expected)
    -- uncomment, via dot
    runCommandAndAssert(7, "gcip", first_expected)
  end)
end)

describe('padding flag', function()

  local input = [[
<note>
  <to>Tove</to>
  <from>Jani</from>
</note>
]]

  it("Should add padding", function()
    require('nvim_comment').setup({ marker_padding = true })

    local expected = [[
<note>
  <to>Tove</to>
  <!-- <from>Jani</from> -->
</note>
]]

    setUpBuffer(input, "xml")
    -- comment
    runCommandAndAssert(3, "gcl", expected)
  end)
  it("Should not add padding", function()
    require('nvim_comment').setup({ marker_padding = false })

    local expected = [[
<note>
  <to>Tove</to>
  <!--<from>Jani</from>-->
</note>
]]

    setUpBuffer(input, "xml")
    -- comment
    runCommandAndAssert(3, "gcl", expected)
  end)
end)

describe('comment empty flag', function()

  local input = [[
local function dummy_func()
  print("This is a dummy func")
end

local function another_dummy_func()
  print("This is a another dummy func")
end]]

  it("Should comment empty lines", function()
    require('nvim_comment').setup({
      marker_padding = true,
      comment_empty = true
    })

    -- luacheck: ignore
    local expected = [[
-- local function dummy_func()
--   print("This is a dummy func")
-- end
-- 
-- local function another_dummy_func()
--   print("This is a another dummy func")
-- end]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(1, "vGgc", expected)
    -- uncomment
    runCommandAndAssert(1, "vGgc", input)
  end)

  it("Should not comment empty lines", function()
    require('nvim_comment').setup({
      marker_padding = true,
      comment_empty = false
    })

    local expected = [[
-- local function dummy_func()
--   print("This is a dummy func")
-- end

-- local function another_dummy_func()
--   print("This is a another dummy func")
-- end]]

    setUpBuffer(input, "lua")
    -- comment
    runCommandAndAssert(1, "vGgc", expected)
    -- comment, via dot
    runCommandAndAssert(1, "vGgc", input)
  end)
end)

