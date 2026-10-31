# Misc Principles

## Expose window/buffer options via a user event

```lua
-- plugin
vim.api.nvim_exec_autocmds("User", {
  pattern = "PluginNameOpen",
    data = {
      winnr = input_win,
      bufnr = input_buf,
  },
})

-- config
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("PluginNameWinOpts", { clear = true }),
  pattern = "PluginNameOpen",
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

## Global `vim.g.plugin-name.*` variables

- Global plugin config should passed through `vim.g.plugin-name.*`
- Function options still passed through the function
- Global state within the plugin can live in local variables declared at the top scope

## Use a prefixed notify helper

Prefix plugin notifications and use `string.format` arguments:

```lua
--- @param level vim.log.levels
--- @param msg string
--- @param ... any
local notify = function(level, msg, ...)
  msg = "[plugin-name.nvim]: " .. msg
  vim.notify(msg:format(...), level)
end
```

## Use a typed `nonnil` helper

Prefer a generic helper with LuaLS annotations over native non-nil assertions:

```lua
--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local nonnil = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end
```

## Wrap callback APIs for async use

Use explicit types for `vim.async.wrap` wrappers:

```lua
--- @type fun(cmd: string[], opts: vim.SystemOpts?): vim.SystemCompleted
local system_async = vim.async.wrap(3, vim.system)

--- @type fun(opts: vim.ui.input.Opts?): string?
local ui_input_async = vim.async.wrap(2, vim.ui.input)
```

Schedule callbacks in `vim.async.run` and raise errors from the async task:

```lua
--- @param callback fun(...: any): any
--- @return fun(...: any): nil
local cb_async = function(callback)
  return function(...)
    local arguments = { ... }
    vim.async
      .run("cb_async_task", function()
        callback(unpack(arguments))
      end)
      :raise_on_error()
  end
end
```

Use `vim.async.sleep(0)` to ensure execution on the main loop:

```lua
local ensure_main_loop = function()
  vim.async.sleep(0)
end
```

## Name inner callback arguments with an `_arg` suffix

When callback parameters shadow or repeat names from an enclosing function, add the `_arg` suffix and use those names inside the callback:

```lua
--- @param fn_name string
--- @param content string
local function mock_run_diff_cmd(fn_name, content)
  child.lua_func(
    --- @param fn_name_arg string
    --- @param content_arg string
    function(fn_name_arg, content_arg)
      -- Use fn_name_arg and content_arg inside this callback.
    end
  )
end
```

## Type async functions and awaited values

Annotate values returned from `vim.async.run` and use a cast when the awaited result's type cannot be inferred:

```lua
--- @return string?
return vim.async.run(function()
  local result = get_async_result()
  if not result then
    return nil
  end

  return result
end)

local value = vim.async.await(start_async_operation()) --[[@as string?]]
```
