# cmp-denippet

nvim-cmp source for [denippet.vim](https://github.com/uga-rosa/denippet.vim)

# Setup

```lua
require("cmp")({
  snippet = {
    expand = function(args)
      vim.fn["denippet#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "denippet" },
  },
})
```
