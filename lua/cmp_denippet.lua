local cmp = require("cmp")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_keyword_pattern()
  return "."
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local completion_items = {}
  for _, item in ipairs(vim.fn["denippet#get_complete_items"]()) do
    local text_edit = self:_get_text_edit(params, item.word, item.user_data.denippet.body)
    if text_edit then
      table.insert(completion_items, {
        label = item.word,
        filterText = item.word,
        insertTextFormat = cmp.lsp.InsertTextFormat.Snippet,
        textEdit = text_edit,
        kind = cmp.lsp.CompletionItemKind.Snippet,
        data = {
          filetype = params.context.filetype,
          snippet = item.user_data.denippet,
        },
      })
    end
  end
  callback(completion_items)
end

function source:resolve(completion_item, callback)
  local snippet = completion_item.data.snippet
  local body = vim.fn["denippet#to_string"](snippet.body) --[[@as string]]
  local documentation = vim.split(body:gsub("\r\n?", "\n"), "\n")
  if #documentation > 0 then
    table.insert(documentation, 1, "```" .. completion_item.data.filetype)
    table.insert(documentation, "```")
  end
  if snippet.description ~= "" then
    table.insert(documentation, 1, snippet.description)
  end
  completion_item.documentation = {
    kind = cmp.lsp.MarkupKind.Markdown,
    value = table.concat(documentation, "\n"),
  }
  callback(completion_item)
end

function source:_get_text_edit(params, prefix, body)
  local chars = vim.fn.split(vim.fn.escape(prefix, [[\/?]]), [[\zs]])
  local chars_pattern = [[\%(\V]] .. table.concat(chars, [[\m\|\V]]) .. [[\m\)]]
  local separator = chars[1]:match("%a") and [[\<]] or ""
  local whole_pattern = ([[%s\V%s\m%s*$]]):format(separator, chars[1], chars_pattern)
  local regex = vim.regex(whole_pattern)
  local s, e = regex:match_str(params.context.cursor_before_line)
  if not s then
    return
  end
  return {
    newText = body,
    range = {
      start = {
        line = params.context.cursor.line,
        character = s,
      },
      ["end"] = {
        line = params.context.cursor.line,
        character = e,
      },
    },
  }
end

return source
