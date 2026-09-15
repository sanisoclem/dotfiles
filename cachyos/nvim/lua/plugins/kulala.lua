-- kulala.nvim -- HTTP/GraphQL/gRPC/WebSocket client for Neovim (Postman replacement).
-- Requests live in plain `.http` files (JetBrains spec), so they're git-friendly.
--
-- Entry points:
--   <leader>Rb   scratchpad (throwaway request, no file needed)
--   <leader>Ro   open the response pane
--   <leader>Ru   Auth Manager  -- add/acquire/refresh/revoke OAuth tokens
--   <leader>Re   Environment Manager  -- switch dev/prod
-- Inside a .http buffer: <CR> send, <leader>Ra send all, <leader>Rf find,
-- <leader>Rn/<leader>Rp jump between requests, <leader>Rc copy as cURL.
-- In the response pane: ? for the full keymap list.
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>R", "", desc = "+rest/http" },
      { "<leader>Rb", desc = "Open scratchpad" },
      { "<leader>Ro", desc = "Open kulala" },
      { "<leader>Rs", desc = "Send request", mode = { "n", "v" } },
      { "<leader>Ra", desc = "Send all requests", mode = { "n", "v" } },
      { "<leader>Rr", desc = "Replay last request" },
      { "<leader>Ru", desc = "Manage auth config" },
    },
    -- load before session save/restore hooks so request history survives
    event = { "SessionLoadPost", "VimLeavePre" },
    init = function()
      vim.filetype.add({ extension = { http = "http", rest = "rest" } })
      -- required for kulala's request history to restore with the session
      vim.opt.sessionoptions:append("globals")
    end,
    opts = {
      -- full default keymap set under <leader>R
      global_keymaps = true,
      global_keymaps_prefix = "<leader>R",
      kulala_keymaps = true,
      kulala_keymaps_prefix = "",

      default_env = "qa1",
      environment_scope = "b", -- env selection is per-buffer

      ui = {
        display_mode = "split",
        split_direction = "right",
        default_view = "body",
        winbar = true,
      },

      -- `{{$random.email}}` & friends -- see lua/kulala_faker.lua
      custom_dynamic_variables = require("kulala_faker").vars,
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>R", group = "rest/http", icon = "󱂛 " },
      },
    },
  },
}
