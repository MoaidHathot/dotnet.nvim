# dotnet.nvim
A little Neovim plugin for improving the .NET dev experience in Neovim, written completely in Lua

https://github.com/user-attachments/assets/7be996dc-3612-46dc-aeca-d8a5c1a2a418

# Features
- Cross Platform (Windows, Linux, MacOS)
- Add/Remove Nuget Windows
- Add/Remove Project Reference Windows
- Add new projects/sln/globaljson/any installed dotnet template
- Bootstrap a new cs file with a class

# Dependencies
- Neovim 0.8+ (May work with older versions, but not tested)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [.NET SDK](https://dotnet.microsoft.com/download)

# Installation
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'MoaidHathot/dotnet.nvim',
        cmd = "DotnetUI",
        opts = {},
}
```
- [Packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'MoaidHathot/dotnet.nvim',
        config = function()
            require("dotnet").setup({})
        end
}
```

# Configuration
`dotnet.nvim` comes with the following defaults:
```lua
{
  bootstrap = {
    auto_bootstrap = true, -- Automatically call "bootstrap" when creating a new file, adding a namespace and a class to the files
  },
  project_selection = {
    path_display = 'filename_first' -- Determines how file paths are displayed. All of Telescope's path_display options are supported
  }
}
```

Telescope's valid [`path_display`](https://github.com/nvim-telescope/telescope.nvim/blob/5972437de807c3bc101565175da66a1aa4f8707a/doc/telescope.txt#L269). The options may vary depending on the version of Telescope you have installed.

# Usage
- Adding new item (Project/globaljson/sln, any template you have installed)
```cmd
:DotnetUI new_item
```
- Bootstrapping a new cs file
```cmd
:DotnetUI file bootstrap
```
- Adding a Nuget package
```cmd
:DotnetUI project package add
```
- Removing a Nuget package
```cmd
:DotnetUI project package remove
```
- Adding a project reference
```cmd
:DotnetUI project reference add
```
- Removing a project reference
```cmd
:DotnetUI project reference remove
```
![image](https://github.com/user-attachments/assets/f2ea8994-869a-484c-b77e-72988a08d104)

![image](https://github.com/user-attachments/assets/0d98e570-d6d8-42a2-8af5-b84c35bd44a5)

![image](https://github.com/user-attachments/assets/04d4fc21-79c6-4376-883a-7d600837403b)
