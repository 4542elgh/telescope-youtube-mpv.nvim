# Telescope Youtube Music integration
[Telescope](https://github.com/nvim-telescope/telescope.nvim) picker for playing youtube music via [MPV](https://mpv.io/) and [Youtube-DLP](https://github.com/yt-dlp/yt-dlp) integration.

## How does it look?
Color scheme is [Darcula](https://github.com/4542elgh/darcula.nvim) made with TJ's colorbuddy plugin<br/>
Using <img src="https://media.tenor.com/nBt6RZkFJh8AAAAi/never-gonna.gif" width="40px"> as an example<br/>
<img src="https://user-images.githubusercontent.com/17227723/210258116-fc90bf2d-59e1-4fdd-9647-b7ebc775834f.png" alt="drawing" width="500">

## Why?
One of the features I miss from Emacs is Ivy-Youtube. Able to manage youtube music from editor is very convenient. Thus I made this plugin to mimic those features.

## Installation
### Binary
Be sure to have [MPV](https://mpv.io/) and [Youtube-DLP](https://github.com/yt-dlp/yt-dlp) installed and available in `PATH` environmental variable.<br/>
You can test your binary is in `path` by open a terminal (Mac/Linux) CMD (Windows) and type `mpv`. It should show you a help page.<br/>
<br/>
Like following prompt:

<img src="https://user-images.githubusercontent.com/17227723/210284179-bde904a8-7bb2-468f-a3bb-d2b2bfccd734.png" width="400">

### Nvim
If you are using [packer.nvim](https://github.com/wbthomason/packer.nvim), use this to setup `youtube_music`
```lua
use {
    "4542elgh/telescope-youtube-music.nvim",
    requires = {{'nvim-lua/plenary.nvim'}}
}
```
If you are using [lazy.nvim](https://github.com/folke/lazy.nvim), use this to setup `youtube_music`
```lua
{
    "4542elgh/telescope-youtube-music.nvim",
    dependencies = {{'nvim-lua/plenary.nvim'}}
}
```

In Telescope setup, require `youtube_music` module
```lua
require('telescope').load_extension('youtube_music')
```

## Configuration
Obtain an <a href="https://console.developers.google.com/" target="_blank">API Key</a> and enable Youtube Data API v3. <br/>
<img src="https://user-images.githubusercontent.com/17227723/210260324-55e06ad3-ba78-4f91-a712-e66b7ce087f4.png" width="400"><br/>
Then put API Key inside environmental variable `YOUTUBE_API_KEY`

### Telescope extensions config
These are the default options of `youtube_music` extension
```lua
require("telescope").setup({
    defaults = {
        ...
    },
    extensions = {
        ...
        youtube_music = {
            volume = 40,
            -- Probably wont exhaust your quota (refresh daily) but it is here if you need it
            maxResults = 25,
            -- Save bandwidth, audio only
            noVideo = false,
            -- Only for playlist
            shuffle = false,
            -- MPV will minimize on launch
            minimized = true,
            -- This is what shows in your buffer list
            mpvInstanceName = "MPV Youtube Instance",
            -- This is what shows in your Telescope prompt, right above input box
            promptTitle = "Youtube MPV Youtube-DL",
            envar = os.getenv("Youtube_API_KEY"),
        }
    }
})
```

## Usage

The extension provides the following picker:<br/>

Lua:
```lua
-- Single song search
require('telescope').extensions.youtube_music.single()

-- Playlist
require('telescope').extensions.youtube_music.playlist()
```

## Special Thank🥳: 
Thanks to the follow projects and their author for inspiration, project structure and utility functions:
- [Telescope](https://github.com/nvim-telescope/telescope.nvim) 
- [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)
- [url-encode.lua](https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99)
