return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          prepend_args = function(_, ctx)
            -- Wrap prose in markdown files
            if vim.bo[ctx.buf].filetype == "markdown" then
              return { "--prose-wrap", "always", "--print-width", "80" }
            end
            return {}
          end,
        },
      },
    },
  },
}
