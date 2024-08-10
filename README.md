# dotnet.nvim
A little Neovim plugin for improving the .NET dev experience in Neovim, written completely in Lua

# Features
- Cross Platform (Windows, Linux, MacOS)
- Add/Remove Nuget Windows
- Add/Remove Project Reference Windows
- Add new projects/sln/globaljson/any installed dotnet template
- Bootstrap a new cs file with a class

# Dependencies
- Neovim 0.8+ (Could work with older versions, but not tested)
- Telescope
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
![image](https://github.com/user-attachments/assets/f2ea8994-869a-484c-b77e-72988a08d104)

![image](https://github.com/user-attachments/assets/0d98e570-d6d8-42a2-8af5-b84c35bd44a5)

![image](https://github.com/user-attachments/assets/04d4fc21-79c6-4376-883a-7d600837403b)
