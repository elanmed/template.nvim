local new_set = MiniTest.new_set
local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.bo.readonly = false
      child.lua [[require("template").setup()]]
    end,
    post_once = child.stop,
  },
}

T["true"] = function()
  MiniTest.expect.equality(true, true)
end

return T
