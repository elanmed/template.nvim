# Misc Principles

## Expose window/buffer options via a user event

```lua
-- plugin
vim.api.nvim_exec_autocmds("User", {
  pattern = "FFInputOpen",
    data = {
      winnr = input_win,
      bufnr = input_buf,
  },
})

-- config
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFWinOpts", { clear = true }),
  pattern = "FFResultsOpen",
  callback = function(ev)
    local winnr = ev.data.winnr
    vim.api.nvim_win_set_config(winnr, {
      border = "single",
    })
    vim.wo[winnr].number = true
    vim.wo[winnr].scrolloff = 0
  end,
})
```
