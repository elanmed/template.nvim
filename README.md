# `template.nvim`

A minimal Neovim plugin template with an empty setup entry point.

## Features

- 1 source file (5 LOC), 1 test file (20 LOC), no runtime dependencies
- No plugin behavior yet: `setup()` is a placeholder for implementation
- A minimal `mini.test` test scaffold and Make targets for testing, linting, formatting, and generating help documentation

## Example config

The plugin loader calls `setup()` automatically when the plugin is loaded. The setup function is an empty scaffold:

```lua
require("template").setup()
```

## Plug remaps

This template defines no `<Plug>` mappings.

## API

### `require("template").setup()`

Placeholder initialization function. Add plugin configuration and initialization logic to `lua/template/init.lua`.

## Autocommand events

This template does not emit any autocommand events.
