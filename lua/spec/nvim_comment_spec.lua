local testModule
local mock = require('luassert.mock')
local api_mock

describe('nvim-comment', function()

  before_each(function()
    testModule = require('nvim_comment')
    api_mock = mock(vim.api, true)
    -- reset config to default
    testModule.config = {
      marker_padding = true
    }
  end)

  after_each(function()
    mock.revert(api_mock)
  end)

  describe('get_comment_wrapper', function()
    local commentstrings = {
      ['COMMENT %s'] = {'COMMENT ', nil},
      ['{% comment %}%s{% endcomment %}'] = {'{% comment %}', '{% endcomment %}'},
      ['c# %s'] = {'c# ', nil},
      ['dnl %s'] = {'dnl ', nil},
      ['NB. %s'] = {'NB. ', nil},
      ['! %s'] = {'! ', nil},
      ['#%s'] = {'#', nil},
      ['# %s'] = {'# ', nil},
      ['%%s'] = {'%', nil},
      ['% %s'] = {'% ', nil},
      ['(*%s*)'] = {'(*', '*)'},
      ['(;%s;)'] = {'(;', ';)'},
      ['**%s'] = {'**', nil},
      ['-# %s'] = {'-# ', nil},
      ['-- %s'] = {'-- ', nil},
      ['--  %s'] = {'--  ', nil},
      ['.. %s'] = {'.. ', nil},
      ['.\\"%s'] = {'.\\"', nil},
      ['/*%s*/'] = {'/*', '*/'},
      ['/* %s */'] = {'/* ', ' */'},
      ['//%s'] = {'//', nil},
      ['// %s'] = {'// ', nil},
      [':: %s'] = {':: ', nil},
      [';%s'] = {';', nil},
      ['; %s'] = {'; ', nil},
      ['; // %s'] = {'; // ', nil},
      ['<!--%s-->'] = {'<!--', '-->'},
      ['<%#%s%>'] = {'<%#', '%>'},
      ['> %s'] = {'> ', nil},
      ['      *%s'] = {'      *', nil},
      ['"%s'] = {'"', nil},
    }

    for string,expected in pairs(commentstrings) do
      it('Should return comment wrapper(s) for: ' .. string .. '  no left marker padding', function()
        testModule.config.marker_padding = false
        api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns(string)
        local left, right = testModule.get_comment_wrapper(string)

        assert.equals(left, expected[1])
        assert.equals(right, expected[2])
      end)
    end

    local padded_commentstrings = {
      ['COMMENT %s'] = {'COMMENT ', nil},
      ['{% comment %}%s{% endcomment %}'] = {'{% comment %} ', ' {% endcomment %}'},
      ['c# %s'] = {'c# ', nil},
      ['dnl %s'] = {'dnl ', nil},
      ['NB. %s'] = {'NB. ', nil},
      ['! %s'] = {'! ', nil},
      ['#%s'] = {'# ', nil},
      ['# %s'] = {'# ', nil},
      ['%%s'] = {'% ', nil},
      ['% %s'] = {'% ', nil},
      ['(*%s*)'] = {'(* ', ' *)'},
      ['(;%s;)'] = {'(; ', ' ;)'},
      ['**%s'] = {'** ', nil},
      ['-# %s'] = {'-# ', nil},
      ['-- %s'] = {'-- ', nil},
      ['--  %s'] = {'--  ', nil},
      ['.. %s'] = {'.. ', nil},
      ['.\\"%s'] = {'.\\" ', nil},
      ['/*%s*/'] = {'/* ', ' */'},
      ['/* %s */'] = {'/* ', ' */'},
      ['//%s'] = {'// ', nil},
      ['// %s'] = {'// ', nil},
      [':: %s'] = {':: ', nil},
      [';%s'] = {'; ', nil},
      ['; %s'] = {'; ', nil},
      ['; // %s'] = {'; // ', nil},
      ['<!--%s-->'] = {'<!-- ', ' -->'},
      ['<%#%s%>'] = {'<%# ', ' %>'},
      ['> %s'] = {'> ', nil},
      ['      *%s'] = {'      * ', nil},
      ['"%s'] = {'" ', nil},
    }

    for string,expected in pairs(padded_commentstrings) do
      it('Should return comment wrapper(s) for: ' .. string .. ' with marker padding', function()
        api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns(string)
        local left, right = testModule.get_comment_wrapper(string)

        assert.equals(left, expected[1])
        assert.equals(right, expected[2])
      end)
    end

    it('Should return nil,nil if unsuported commentstring', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('something here')
      local left, right = testModule.get_comment_wrapper('something here')

      assert.equals(left, nil)
      assert.equals(right, nil)
    end)
  end)

  describe('comment_line', function()
    local commentstrings = {
      ['COMMENT line'] = {'COMMENT ', ''},
      ['{% comment %}line{% endcomment %}'] = {'{% comment %}', '{% endcomment %}'},
      ['c# line'] = {'c# ', ''},
      ['dnl line'] = {'dnl ', ''},
      ['NB. line'] = {'NB. ', ''},
      ['! line'] = {'! ', ''},
      ['#line'] = {'#', ''},
      ['# line'] = {'# ', ''},
      ['%line'] = {'%', ''},
      ['% line'] = {'% ', ''},
      ['(*line*)'] = {'(*', '*)'},
      ['(;line;)'] = {'(;', ';)'},
      ['**line'] = {'**', ''},
      ['-# line'] = {'-# ', ''},
      ['-- line'] = {'-- ', ''},
      ['--  line'] = {'--  ', ''},
      ['.. line'] = {'.. ', ''},
      ['.\\"line'] = {'.\\"', ''},
      ['/*line*/'] = {'/*', '*/'},
      ['/* line */'] = {'/* ', ' */'},
      ['//line'] = {'//', ''},
      ['// line'] = {'// ', ''},
      [':: line'] = {':: ', ''},
      [';line'] = {';', ''},
      ['; line'] = {'; ', ''},
      ['; // line'] = {'; // ', ''},
      ['<!--line-->'] = {'<!--', '-->'},
      ['<%#line%>'] = {'<%#', '%>'},
      ['> line'] = {'> ', ''},
      ['      *line'] = {'      *', ''},
      ['"line'] = {'"', ''},
    }

    for expected,comment_parts in pairs(commentstrings) do
      it('Should comment line as expected, with no padding: ' .. expected, function()
        local actual = testModule.comment_line('line', "", comment_parts[1], comment_parts[2], true, true)

        assert.equals(expected, actual)
      end)
    end

    it("Should add comment after any whitespace, with padding", function()
      local actual = testModule.comment_line("  line", "  ",  "-- ", "", true, true)

      assert.equals("  -- line", actual)
    end)

    it("Should add comment after any whitespace, with extra padding", function()
      local actual = testModule.comment_line("    line", "  ",  "-- ", "", true, true)

      assert.equals("  --   line", actual)
    end)

    it("Should trim whitespace", function()
      local actual = testModule.comment_line("", "  ",  "-- ", "", true, true)

      assert.equals("  --", actual)
    end)

    it("Should not trim whitespace", function()
      local actual = testModule.comment_line("", "  ",  "-- ", "", true, false)

      assert.equals("  -- ", actual)
    end)

    it("Should ignore line if empty or just whitespace", function()
      local actual = testModule.comment_line("    line", "  ",  "-- ", "", false, true)

      assert.equals("  --   line", actual)

      actual = testModule.comment_line("", "  ",  "-- ", "", false, true)

      assert.equals("", actual)

      -- spaces
      actual = testModule.comment_line("  ", "  ",  "-- ", "", false, true)

      assert.equals("  ", actual)

      -- Tabs
      actual = testModule.comment_line("   ", "  ",  "-- ", "", false, true)

      assert.equals("   ", actual)
    end)
  end)

  describe('uncomment_line', function()
    local commentstrings = {
      ['COMMENT line'] = {'COMMENT ', ''},
      ['{% comment %}line{% endcomment %}'] = {'{% comment %}', '{% endcomment %}'},
      ['c# line'] = {'c# ', ''},
      ['dnl line'] = {'dnl ', ''},
      ['NB. line'] = {'NB. ', ''},
      ['! line'] = {'! ', ''},
      ['#line'] = {'#', ''},
      ['# line'] = {'# ', ''},
      ['%line'] = {'%', ''},
      ['% line'] = {'% ', ''},
      ['(*line*)'] = {'(*', '*)'},
      ['(;line;)'] = {'(;', ';)'},
      ['**line'] = {'**', ''},
      ['-# line'] = {'-# ', ''},
      ['-- line'] = {'-- ', ''},
      ['--  line'] = {'--  ', ''},
      ['.. line'] = {'.. ', ''},
      ['.\\"line'] = {'.\\"', ''},
      ['/*line*/'] = {'/*', '*/'},
      ['/* line */'] = {'/* ', ' */'},
      ['//line'] = {'//', ''},
      ['// line'] = {'// ', ''},
      [':: line'] = {':: ', ''},
      [';line'] = {';', ''},
      ['; line'] = {'; ', ''},
      ['; // line'] = {'; // ', ''},
      ['<!--line-->'] = {'<!--', '-->'},
      ['<%#line%>'] = {'<%#', '%>'},
      ['> line'] = {'> ', ''},
      -- ['      *line'] = {'      *', ''},
      ['"line'] = {'"', ''},
    }

    for input,comment_parts in pairs(commentstrings) do
      it('Should uncomment line as expected: ' .. input, function()
        local actual = testModule.uncomment_line(input, comment_parts[1], comment_parts[2], false)

        assert.equals('line', actual)
      end)
    end

    it('Should uncomment if trailing whitespace in left hand side removed, no right hand side', function()
        local actual = testModule.uncomment_line("--", "-- ", "", true)

        assert.equals('', actual)
    end)

    it('Should uncomment and not leave padding when comment_empty_trim_whitespace false, no right hand side', function()
        local actual = testModule.uncomment_line("-- test", "-- ", "", true)

        assert.equals('test', actual)
    end)
  end)

  describe('comment_toggle', function()
    it('Should add left hand side comments only on entire range', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('-- %s')
      api_mock.nvim_buf_get_lines.on_call_with(0, 0, 3, false).returns({
        "line1",
        "line2",
        "line3",
      })

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_call_function).was_called_with("setline", {1, {
        "-- line1",
        "-- line2",
        "-- line3",
      }})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'<", {0, 1, 1, 0}})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'>", {0, 3, 2147483647, 0}})

    end)

    it('Should remove left hand side comments only on entire range', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('-- %s')
      api_mock.nvim_buf_get_lines.on_call_with(0, 0, 3, false).returns({
        "-- line1",
        "-- line2",
        "-- line3",
      })

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_call_function).was_called_with("setline", {1, {
        "line1",
        "line2",
        "line3",
      }})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'<", {0, 1, 1, 0}})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'>", {0, 3, 2147483647, 0}})
    end)

    it('Should add comments on uncommented lines to entire range', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('-- %s')
      api_mock.nvim_buf_get_lines.on_call_with(0, 0, 3, false).returns({
        "line1",
        "-- line2",
        "line3",
      })

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_call_function).was_called_with("setline", {1, {
        "-- line1",
        "-- -- line2",
        "-- line3",
      }})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'<", {0, 1, 1, 0}})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'>", {0, 3, 2147483647, 0}})
    end)

    it('Should add left and right hand side comments to entire range', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('(*%s*)')
      api_mock.nvim_buf_get_lines.on_call_with(0, 0, 3, false).returns({
        "line1",
        "line2",
        "line3",
      })

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_call_function).was_called_with("setline", {1, {
        "(* line1 *)",
        "(* line2 *)",
        "(* line3 *)",
      }})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'<", {0, 1, 1, 0}})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'>", {0, 3, 2147483647, 0}})
    end)

    it('Should remove left and right hand side comments to entire range', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('(*%s*)')
      api_mock.nvim_buf_get_lines.on_call_with(0, 0, 3, false).returns({
        "(* line1 *)",
        "(* line2 *)",
        "(* line3 *)",
      })

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_call_function).was_called_with("setline", {1, {
        "line1",
        "line2",
        "line3",
      }})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'<", {0, 1, 1, 0}})
      assert.stub(api_mock.nvim_call_function).was_called_with('setpos', {"'>", {0, 3, 2147483647, 0}})
    end)

    it('Should not do anything if commentstring not supported', function()
      api_mock.nvim_buf_get_option.on_call_with(0, 'commentstring').returns('whatwhat')

      testModule.comment_toggle(1, 3)

      assert.stub(api_mock.nvim_buf_get_lines).was_not_called()
      assert.stub(api_mock.nvim_buf_set_lines).was_not_called()
    end)
  end)
end)
