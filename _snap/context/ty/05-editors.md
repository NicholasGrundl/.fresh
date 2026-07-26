# ty Editor Integration

**Source:** https://docs.astral.sh/ty/editors/

## Overview

"ty can be integrated with various editors to provide a seamless development experience."

## VS Code

The Astral team provides an official extension. Install the ty extension from the VS Code Marketplace, with setup details available in the [extension README](https://github.com/astral-sh/ty-vscode).

## Neovim

Two configuration approaches exist depending on your version:

### Neovim 0.10 or earlier (using `nvim-lspconfig`)

```lua
require('lspconfig').ty.setup({
  settings = {
    ty = {
      -- ty language server settings go here
    }
  }
})
```

### Neovim 0.11+ (using `vim.lsp.config`)

```lua
vim.lsp.config('ty', {
  settings = {
    ty = {
      -- ty language server settings go here
    }
  }
})

vim.lsp.enable('ty')
```

## Zed

"ty is included with Zed out of the box (no extension required)," though basedpyright serves as the default LSP. Enable ty via `settings.json`:

```json
{
  "languages": {
    "Python": {
      "language_servers": ["ty", "!basedpyright", "..."]
    }
  }
}
```

Override the executable path using the `lsp.ty.binary` configuration option.

## PyCharm

Starting with version 2025.3, navigate to **Python | Tools | ty** in Settings to enable native support. Choose between:
- **Interpreter** mode (searches installed packages)
- **Path** mode (searches `$PATH`)

## Other Editors

Launch the language server with `ty server` and configure any LSP-compatible editor accordingly.
