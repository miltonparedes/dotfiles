-- VSCode Dark Modern syntax colors (from vscode.nvim)
local vscode = {
  front = "#D4D4D4",
  gray = "#808080",
  blue = "#569CD6",
  accent_blue = "#4FC1FF",
  light_blue = "#9CDCFE",
  green = "#6A9955",
  blue_green = "#4EC9B0",
  light_green = "#B5CEA8",
  red = "#F44747",
  orange = "#CE9178",
  light_red = "#D16969",
  yellow_orange = "#D7BA7D",
  yellow = "#DCDCAA",
  pink = "#C586C0",
}

-- Apply VSCode syntax colors over current theme
local function apply_vscode_syntax()
  local hl = vim.api.nvim_set_hl

  -- Comments
  hl(0, "Comment", { fg = vscode.green, italic = true })
  hl(0, "@comment", { fg = vscode.green, italic = true })
  hl(0, "@comment.note", { fg = vscode.blue_green, bold = true })
  hl(0, "@comment.warning", { fg = vscode.yellow_orange, bold = true })
  hl(0, "@comment.error", { fg = vscode.red, bold = true })

  -- Strings
  hl(0, "String", { fg = vscode.orange })
  hl(0, "@string", { fg = vscode.orange })
  hl(0, "@string.escape", { fg = vscode.yellow_orange, bold = true })
  hl(0, "@string.special", { fg = vscode.yellow_orange })
  hl(0, "@string.regexp", { fg = vscode.orange })
  hl(0, "@character", { fg = vscode.orange })

  -- Keywords
  hl(0, "Keyword", { fg = vscode.blue })
  hl(0, "@keyword", { fg = vscode.blue })
  hl(0, "@keyword.conditional", { fg = vscode.pink })
  hl(0, "@keyword.repeat", { fg = vscode.pink })
  hl(0, "@keyword.return", { fg = vscode.pink })
  hl(0, "@keyword.exception", { fg = vscode.pink })
  hl(0, "@keyword.import", { fg = vscode.pink })
  hl(0, "@keyword.operator", { fg = vscode.blue })
  hl(0, "@keyword.function", { fg = vscode.blue })
  hl(0, "@keyword.storage", { fg = vscode.blue })
  hl(0, "Conditional", { fg = vscode.pink })
  hl(0, "Repeat", { fg = vscode.pink })
  hl(0, "Statement", { fg = vscode.blue })
  hl(0, "@define", { fg = vscode.pink })

  -- Functions
  hl(0, "Function", { fg = vscode.yellow })
  hl(0, "@function", { fg = vscode.yellow })
  hl(0, "@function.call", { fg = vscode.yellow })
  hl(0, "@function.builtin", { fg = vscode.yellow })
  hl(0, "@function.method", { fg = vscode.yellow })
  hl(0, "@function.method.call", { fg = vscode.yellow })
  hl(0, "@function.macro", { fg = vscode.yellow })
  hl(0, "@method", { fg = vscode.yellow })
  hl(0, "@method.call", { fg = vscode.yellow })

  -- Variables
  hl(0, "Identifier", { fg = vscode.light_blue })
  hl(0, "@variable", { fg = vscode.light_blue })
  hl(0, "@variable.builtin", { fg = vscode.blue })
  hl(0, "@variable.parameter", { fg = vscode.light_blue })
  hl(0, "@variable.parameter.reference", { fg = vscode.light_blue })
  hl(0, "@variable.member", { fg = vscode.light_blue })
  hl(0, "@parameter", { fg = vscode.light_blue })
  hl(0, "@field", { fg = vscode.light_blue })
  hl(0, "@property", { fg = vscode.light_blue })

  -- Types
  hl(0, "Type", { fg = vscode.blue_green })
  hl(0, "@type", { fg = vscode.blue_green })
  hl(0, "@type.builtin", { fg = vscode.blue })
  hl(0, "@type.definition", { fg = vscode.blue_green })
  hl(0, "@type.qualifier", { fg = vscode.blue })
  hl(0, "@storageclass", { fg = vscode.blue })
  hl(0, "StorageClass", { fg = vscode.blue })
  hl(0, "@structure", { fg = vscode.light_blue })

  -- Constants & Numbers
  hl(0, "Constant", { fg = vscode.accent_blue })
  hl(0, "Number", { fg = vscode.light_green })
  hl(0, "Boolean", { fg = vscode.blue })
  hl(0, "@constant", { fg = vscode.accent_blue })
  hl(0, "@constant.builtin", { fg = vscode.blue })
  hl(0, "@constant.macro", { fg = vscode.blue_green })
  hl(0, "@number", { fg = vscode.light_green })
  hl(0, "@number.float", { fg = vscode.light_green })
  hl(0, "@boolean", { fg = vscode.blue })

  -- Operators & Punctuation
  hl(0, "Operator", { fg = vscode.front })
  hl(0, "@operator", { fg = vscode.front })
  hl(0, "@punctuation", { fg = vscode.front })
  hl(0, "@punctuation.bracket", { fg = vscode.front })
  hl(0, "@punctuation.delimiter", { fg = vscode.front })
  hl(0, "@punctuation.special", { fg = vscode.front })

  -- Tags (HTML/JSX)
  hl(0, "@tag", { fg = vscode.blue })
  hl(0, "@tag.builtin", { fg = vscode.blue })
  hl(0, "@tag.attribute", { fg = vscode.light_blue })
  hl(0, "@tag.delimiter", { fg = vscode.gray })

  -- Namespaces & Modules
  hl(0, "@namespace", { fg = vscode.blue_green })
  hl(0, "@module", { fg = vscode.blue_green })

  -- Constructor
  hl(0, "@constructor", { fg = vscode.blue })

  -- Labels & Attributes
  hl(0, "@label", { fg = vscode.light_blue })
  hl(0, "@attribute", { fg = vscode.yellow })
  hl(0, "@attribute.builtin", { fg = vscode.blue_green })
  hl(0, "@annotation", { fg = vscode.yellow })

  -- Errors
  hl(0, "@error", { fg = vscode.red })
  hl(0, "Error", { fg = vscode.red })

  -- Markup (Markdown, etc.)
  hl(0, "@markup.strong", { fg = vscode.blue, bold = true })
  hl(0, "@markup.italic", { fg = vscode.front, italic = true })
  hl(0, "@markup.underline", { fg = vscode.yellow_orange, underline = true })
  hl(0, "@markup.strikethrough", { fg = vscode.front, strikethrough = true })
  hl(0, "@markup.heading", { fg = vscode.blue, bold = true })
  hl(0, "@markup.heading.1.markdown", { fg = vscode.blue, bold = true })
  hl(0, "@markup.heading.2.markdown", { fg = vscode.orange, bold = true })
  hl(0, "@markup.heading.3.markdown", { fg = vscode.yellow, bold = true })
  hl(0, "@markup.heading.4.markdown", { fg = vscode.green, bold = true })
  hl(0, "@markup.heading.5.markdown", { fg = vscode.blue, bold = true })
  hl(0, "@markup.heading.6.markdown", { fg = vscode.pink, bold = true })
  hl(0, "@markup.raw", { fg = vscode.front })
  hl(0, "@markup.raw.markdown", { fg = vscode.orange })
  hl(0, "@markup.raw.markdown_inline", { fg = vscode.orange })
  hl(0, "@markup.link.label", { fg = vscode.light_blue, underline = true })
  hl(0, "@markup.link.url", { fg = vscode.front, underline = true })

  -- Texto normal en markdown (paragraphs)
  hl(0, "@markup", { fg = vscode.front })
  hl(0, "@markup.raw", { fg = vscode.orange })
  hl(0, "@text", { fg = vscode.front })
  hl(0, "@text.literal", { fg = vscode.orange })
  hl(0, "@spell", { fg = vscode.front })
  hl(0, "@nospell", {})

  -- Spell checking (underline instead of color change)
  hl(0, "SpellBad", { sp = vscode.red, undercurl = true, fg = "NONE", bg = "NONE" })
  hl(0, "SpellCap", { sp = vscode.yellow, undercurl = true, fg = "NONE", bg = "NONE" })
  hl(0, "SpellLocal", { sp = vscode.blue, undercurl = true, fg = "NONE", bg = "NONE" })
  hl(0, "SpellRare", { sp = vscode.pink, undercurl = true, fg = "NONE", bg = "NONE" })

  -- Listas
  hl(0, "@markup.list", { fg = vscode.blue })
  hl(0, "@markup.list.checked", { fg = vscode.green })
  hl(0, "@markup.list.unchecked", { fg = vscode.gray })

  -- Blockquotes
  hl(0, "@markup.quote", { fg = vscode.green, italic = true })

  -- Código en bloques (fence)
  hl(0, "@markup.raw.block", { fg = vscode.orange })

  -- Enlaces (grupo padre)
  hl(0, "@markup.link", { fg = vscode.light_blue })

  -- Math y environments (LaTeX)
  hl(0, "@markup.math", { fg = vscode.accent_blue })
  hl(0, "@markup.environment", { fg = vscode.blue })

  -- Legacy markdown groups (fallback)
  hl(0, "markdownCode", { fg = vscode.orange })
  hl(0, "markdownCodeBlock", { fg = vscode.orange })
  hl(0, "markdownCodeDelimiter", { fg = vscode.gray })
  hl(0, "markdownBlockquote", { fg = vscode.green, italic = true })
  hl(0, "markdownListMarker", { fg = vscode.blue })
  hl(0, "markdownOrderedListMarker", { fg = vscode.blue })
  hl(0, "markdownRule", { fg = vscode.blue })
  hl(0, "markdownHeadingDelimiter", { fg = vscode.blue })
  hl(0, "markdownUrl", { fg = vscode.front, underline = true })
  hl(0, "markdownLinkText", { fg = vscode.light_blue, underline = true })

  -- Render-markdown.nvim highlights (respetar transparencia)
  hl(0, "RenderMarkdownCode", { bg = "NONE" })
  hl(0, "RenderMarkdownH1Bg", { bg = "NONE" })
  hl(0, "RenderMarkdownH2Bg", { bg = "NONE" })
  hl(0, "RenderMarkdownH3Bg", { bg = "NONE" })
  hl(0, "RenderMarkdownH4Bg", { bg = "NONE" })
  hl(0, "RenderMarkdownH5Bg", { bg = "NONE" })
  hl(0, "RenderMarkdownH6Bg", { bg = "NONE" })

  -- LSP Semantic Tokens
  hl(0, "@lsp.type.type", { link = "@type" })
  hl(0, "@lsp.type.typeParameter", { link = "@type" })
  hl(0, "@lsp.type.macro", { link = "@constant" })
  hl(0, "@lsp.type.enumMember", { link = "@constant" })
  hl(0, "@lsp.type.member", { link = "@function" })
  hl(0, "@lsp.type.keyword", { link = "@keyword" })
  hl(0, "@lsp.typemod.type.defaultLibrary", { link = "@type.builtin" })
  hl(0, "@lsp.typemod.variable.readonly", { link = "@constant" })
  hl(0, "@lsp.typemod.property.readonly", { link = "@constant" })
  hl(0, "@lsp.typemod.variable.constant", { link = "@constant" })
  hl(0, "@lsp.typemod.keyword.controlFlow", { fg = vscode.pink })

  -- Diff
  hl(0, "@diff.plus", { link = "DiffAdd" })
  hl(0, "@diff.minus", { link = "DiffDelete" })
  hl(0, "@diff.delta", { link = "DiffChange" })

  -- Regex
  hl(0, "@regexp", { fg = vscode.red })
end

return {
  -- Disable unused colorschemes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- Mellifluous for UI with transparency
  {
    "ramojus/mellifluous.nvim",
    priority = 1000,
    config = function()
      require("mellifluous").setup({
        dim_inactive = false,
        color_set = "mellifluous",
        styles = {
          comments = { italic = true },
        },
        transparent_background = {
          enabled = true,
          floating_windows = true,
          telescope = true,
          file_tree = true,
          cursor_line = true,
          status_line = false,
        },
      })
      vim.cmd("colorscheme mellifluous")

      -- Apply VSCode syntax colors after theme loads
      apply_vscode_syntax()

      -- Re-apply on colorscheme change (in case of reload)
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "mellifluous",
        callback = apply_vscode_syntax,
      })
    end,
  },

  -- Tell LazyVim to use mellifluous
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mellifluous",
    },
  },
}
