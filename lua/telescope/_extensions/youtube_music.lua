-- Check telescope is installed
local ok, telescope = pcall(require, 'telescope')

if not ok then
    error 'Install nvim-telescope/telescope.nvim to use 4542elgh/telescope-youtube-music.nvim.'
end

-- Telescope utils
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

-- Async command utilities
local job = require("plenary.job")

local default_opts = {
    volume = 40,
    maxResults = 25,
    noVideo = false,
    shuffle = false,
    minimized = true,
    envar = os.getenv("Youtube_API_KEY"),
    mpvInstanceName = "MPV Youtube Instance",
    promptTitle = "Youtube MPV Youtube-DL",
}

local opts = {}

-- Thanks to liukun for urlencode function
-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

-- Make API call to Youtube API
-- Thanks to jackMort for api call function structure
-- https://github.com/jackMort/ChatGPT.nvim/blob/main/lua/chatgpt/api.lua
function api_call(cb)
    local url = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&".. 
        "maxResults=" .. opts.maxResults .. 
        "&q=" .. opts.query .. 
        "&key=" .. opts.envar
    job:new({
        command = "curl",
        args = {
            url,
            "-H",
            "Accept: application/json",
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            handle_response(response, exit_code, cb)
        end),
    })
    :start()
end

-- Handle JSON response
function handle_response(response, exit_code, cb)
    if exit_code ~= 0 then
        vim.notify("API Error Occurred", vim.log.levels.ERROR)
    end

    local result = table.concat(response:result(), "\n")
    local json = vim.fn.json_decode(result)
    if json == nil then
        vim.notify("No Response.", vim.log.levels.ERROR)
    elseif json.error then
        vim.notify("API ERROR: " .. json.error.message, vim.log.levels.ERROR)
    else
        local res = {}
        for _, value in ipairs(json.items) do
            if value.id.videoId ~= nil then
                table.insert(res, {
                    channel = value.snippet.channelTitle, 
                    title = value.snippet.title, 
                    videoId = value.id.videoId
                })
            end
        end
        opts.results = res
        cb()
    end
end

-- This is what will be showing in Telescope
local function make_entry()
    -- Spacing
    local displayer = entry_display.create {
        separator = "",
        items = {
            { remaining = true }
        }
    }

    -- What content is displaying
    local make_display = function(entry)
        return displayer {
            entry.title,
        }
    end

    -- Internal sorting
    return function(entry)
        return {
            value   = entry,
            -- ordinal is fuzzy search engine's target
            ordinal = entry.title,
            display = make_display,
            channel = entry.channel,
            title   = entry.title,
            videoId = entry.videoId,
        }
    end
end

-- Finder will fill picker with items
local make_finder = function()
    return finders.new_table {
        results = opts.results,
        entry_maker = make_entry(),
    }
end

-- Displaying module, putting everything together
local make_picker = function()
    pickers.new({}, {
        prompt_title = opts.promptTitle,
        finder = make_finder(),
        sorter = conf.generic_sorter({}),

        -- What to do with selected item
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                vim.cmd(
                    "terminal mpv https://www.youtube.com/watch?" ..
                    "v=" .. action_state.get_selected_entry().videoId ..
                    " --window-minimized=" .. (opts.minimized and "yes" or "no") ..
                    (opts.noVideo and " --no-video --force-window" or "") .. 
                    " --volume=" .. opts.volume
                )
                vim.cmd("file " .. opts.mpvInstanceName)
            end)
            return true
        end,
    }):find()
end

-- Single song with Telescope selection
local single = function()
    opts.query = vim.fn.input("Search: ")
    opts.query = urlencode(opts.query)
    if opts.query == "" then
        vim.notify("Search query cannot be empty", vim.log.levels.ERROR)
        return
    end
    api_call(function()
        make_picker()
    end)
end

-- Playlist just dump the entire url into youtube-dlp
local playlist = function()
    opts.playlistUrl= vim.fn.input("Youtube Playlist URL(include https://): ")
    if opts.playlistUrl == "" then
        vim.notify("Play list cannot be empty", vim.log.levels.ERROR)
        return
    end
    vim.cmd(
        "terminal mpv " .. 
        opts.playlistUrl .. 
        " --window-minimized=" .. 
        (opts.minimized and "yes" or "no") .. 
        (opts.shuffle and " --shuffle" or "") .. 
        (opts.noVideo and " --no-video --force-window" or "") .. 
        " --volume=" .. 
        opts.volume
    )
    vim.cmd("file " .. opts.mpvInstanceName)
end

return require("telescope").register_extension {
    setup = function(user_opts, _)
        opts = vim.tbl_extend('force', default_opts, user_opts)
    end,
    exports = {
        single = single,
        playlist = playlist,
    }
}
