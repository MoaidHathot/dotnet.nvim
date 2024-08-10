# dotnet.nvim
A little Neovim plugin for improving the .NET dev experience in Neovim, written completely in Lua

# Features
- Cross Platform (Windows, Linux, MacOS)
- Add/Remove Nuget Window
- Add/Remove Project Reference Windows
- Bootstrap a new cs file with a class

# Dependencies
- Neovim 0.8+ (Could work with older versions, but not tested)
- Dotnet SDK (https://dotnet.microsoft.com/download)

# Installation and Usage
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
            require("dotnet").setup()
        end
}
```

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

