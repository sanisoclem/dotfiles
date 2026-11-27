return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({ extension = { wesl = "wesl" } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "wgsl", "wesl" },
        callback = function()
          vim.bo.commentstring = "// %s"
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").wesl = {
            install_info = {
              url = "https://github.com/wgsl-tooling-wg/tree-sitter-wesl",
              queries = "queries/nvim",
            },
          }
        end,
      })
    end,
    opts = { ensure_installed = { "wesl" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        wgsl_analyzer = { filetypes = { "wgsl", "wesl" } },
      },
    },
  },
}
