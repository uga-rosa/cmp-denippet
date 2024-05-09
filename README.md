# cmp-denippet

nvim-cmp source for [denippet.vim](https://github.com/uga-rosa/denippet.vim)

# Setup

```lua
require("cmp")({
  snippet = {
    expand = function(args)
      if args.body ~= "" then
          vim.fn["denippet#anonymous"](args.body)
      end
    end,
  },
  sources = {
    { name = "denippet" },
  },
})
```
