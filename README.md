# wiki.nvim

My personal wiki plugin for Neovim.

Learn how to write Neovim's plugin from [[nvim] 0基础nvim插件开发教程](https://www.bilibili.com/video/BV1Qb4y1g7fU).

For me, I just need to convert some text to link, create the note file and open it for all markdown files. So I just write the function `Create_Open()`.

## Installation

Install the plugin with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "RunfengTsui/wiki.nvim",
  lazy = true,
  ft = "markdown",
}
```

## Usage

After installing it, write `reuqire("wiki").setup({})` in the `init.lua` file and then you can use it in your markdown file.

## Configuration

Now I just provide one key to create and open markdown note file, you can modify it in `setup`:

```lua
require("wiki").setup({
  open_file = "<leader>ww",
})
```

