--[[

Awesome WM configuration template
github.com/lcpz

--]]

-- {{{ Required libraries

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local mytable       = awful.util.table or gears.table -- 4.{0,1} compatibility

-- }}}

-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
        naughty.notify {
                preset = naughty.config.presets.critical,
                title = "Oops, there were errors during startup!",
                text = awesome.startup_errors
        }
end

-- Handle runtime errors after startup
do
        local in_error = false

        awesome.connect_signal("debug::error", function (err)
                if in_error then return end

                in_error = true

                naughty.notify {
                        preset = naughty.config.presets.critical,
                        title = "Oops, an error happened!",
                        text = tostring(err)
                }

                in_error = false
        end)
end

-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
        for _, cmd in ipairs(cmd_arr) do
                awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
        end
        awful.spawn("picom -b")
end

run_once({ "urxvtd", "unclutter -root" }) -- comma-separated entries

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
'xrdb -merge <<< "awesome.started:true";' ..
-- list each of your autostart commands, followed by ; inside single quotes, followed by ..
'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- {{{ Variable definitions

local themes = {
        "blackburn",       -- 1
        "copland",         -- 2
        "dremora",         -- 3
        "holo",            -- 4
        "multicolor",      -- 5
        "powerarrow",      -- 6
        "powerarrow-dark", -- 7
        "rainbow",         -- 8
        "steamburn",       -- 9
        "vertex"           -- 10
}

--local chosen_theme = themes[8]
local chosen_theme = "custom"
local modkey       = "Mod4"
local altkey       = "Mod1"
--local terminal     = "urxvtc"
local terminal	   = "xfce4-terminal"
local vi_focus     = true -- vi-like client focus https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev   = true  -- cycle with only the previously focused client or all https://github.com/lcpz/awesome-copycats/issues/274
local editor       = os.getenv("EDITOR") or "vim"
local browser      = "firefox"

awful.util.terminal = terminal

local tag_home     = "Home"
local tag_browser  = "Browser"
local tag_chat     = "Chat"
local tag_dev      = "Dev"
local tag_media    = "Media"
local tag_other    = "Misc"
local tag_game	   = "Game"
local tag_steam    = "Steam"


awful.util.tagnames = { tag_home, tag_browser, tag_chat, tag_dev, tag_media, tag_game, tag_steam }
awful.layout.layouts = {
        awful.layout.suit.tile.right,
        --awful.layout.suit.tile.left,
        --awful.layout.suit.tile,
        --awful.layout.suit.tile.bottom,
        --awful.layout.suit.tile.top,
        --awful.layout.suit.floating,
        --awful.layout.suit.fair,
        --awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        --awful.layout.suit.spiral.dwindle,
        --awful.layout.suit.max,
        --awful.layout.suit.max.fullscreen,
        --awful.layout.suit.magnifier,
        --awful.layout.suit.corner.nw,
        --awful.layout.suit.corner.ne,
        --awful.layout.suit.corner.sw,
        --awful.layout.suit.corner.se,
        --lain.layout.cascade,
        --lain.layout.cascade.tile,
        --lain.layout.centerwork,
        --lain.layout.centerwork.horizontal,
        --lain.layout.termfair,
        --lain.layout.termfair.center
}

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

awful.util.taglist_buttons = mytable.join(
awful.button({ }, 1, function(t) 
        t:view_only()
        if (type(beautiful.set_wallpaper) == "function") then
                local screen = awful.screen.focused()
                beautiful.set_wallpaper(screen)
        end
end),
awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
        if (type(beautiful.set_wallpaper) == "function") then
                local screen = awful.screen.focused()
                beautiful.set_wallpaper(screen)
        end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
        if (type(beautiful.set_wallpaper) == "function") then
                local screen = awful.screen.focused()
                beautiful.set_wallpaper(screen)
        end
end),
awful.button({ }, 4, function(t) 
        awful.tag.viewnext(t.screen) 
        if (type(beautiful.set_wallpaper) == "function") then
                local screen = awful.screen.focused()
                beautiful.set_wallpaper(screen)
        end
end),
awful.button({ }, 5, function(t) 
        awful.tag.viewprev(t.screen) 
        if (type(beautiful.set_wallpaper) == "function") then
                local screen = awful.screen.focused()
                beautiful.set_wallpaper(screen)
        end
end)
)

awful.util.tasklist_buttons = mytable.join(
awful.button({ }, 1, function(c)
        if c == client.focus then
                c.minimized = true
        else
                c:emit_signal("request::activate", "tasklist", { raise = true })
        end
end),
awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
end),
awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

-- }}}

-- {{{ Menu

-- Create a launcher widget and a main menu
local myawesomemenu = {
        { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "Manual", string.format("%s -e man awesome", terminal) },
        { "Edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
        { "Restart", awesome.restart },
        { "Quit", function() awesome.quit() end },
}

awful.util.mymainmenu = freedesktop.menu.build {
        before = {
                { "Awesome", myawesomemenu, beautiful.awesome_icon },
                -- other triads can be put here
        },
        after = {
                { "Open terminal", terminal },
                -- other triads can be put here
        }
}


-- Set the Menubar terminal for applications that require it
menubar.utils.terminal = terminal

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
        -- Wallpaper
        --[[
        if beautiful.wallpaper then
                local wallpaper = beautiful.wallpaper
                -- If wallpaper is a function, call it with the screen
                if type(wallpaper) == "function" then
                        wallpaper = wallpaper(s)
                end
                --gears.wallpaper.maximized(wallpaper, s, true)
        end
        ]]--
        --beautiful.set_wallpaper(s)
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
        local only_one = #s.tiled_clients == 1
        for _, c in pairs(s.clients) do
                if only_one and not c.floating or c.maximized or c.fullscreen then
                        c.border_width = 0
                else
                        c.border_width = beautiful.border_width
                end
        end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

-- {{{ Mouse bindings

root.buttons(mytable.join(
awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev),

awful.button({ modkey }, 4, awful.tag.viewnext),
awful.button({ modkey }, 5, awful.tag.viewprev),
awful.button({ altkey }, 4, function () lain.util.tag_view_nonempty(-1) end),
awful.button({ altkey }, 5, function () lain.util.tag_view_nonempty(1) end)
))

-- }}}

-- {{{ Key bindings

globalkeys = mytable.join(
-- Destroy all notifications
awful.key({ "Control",           }, "space", function() naughty.destroy_all_notifications() end,
{description = "destroy all notifications", group = "hotkeys"}),
-- Take a screenshot
-- https://github.com/lcpz/dots/blob/master/bin/screenshot
--awful.key({ altkey }, "p", function() os.execute("screenshot") end,
awful.key({ altkey }, "p", function() awful.util.spawn_with_shell("scrot ~/Pictures/screenshots/%b%d_%H%M%S.png") end,
{description = "take a screenshot", group = "hotkeys"}),
awful.key({ altkey, "Control" }, "p", function() awful.util.spawn_with_shell("scrot ~/Pictures/screenshots/%b%d_%H%M%S.png -d 1") end,
{description = "take a screenshot after delay", group = "hotkeys"}),
awful.key({ altkey, "Shift" }, "p", function() awful.util.spawn_with_shell("scrot ~/Pictures/screenshots/%b%d_%H%M%S.png -s") end,
{description = "take a screenshot of a selection", group = "hotkeys"}),

-- X screen locker
awful.key({ altkey, "Control" }, "l", function () os.execute(scrlocker) end,
{description = "lock screen", group = "hotkeys"}),

-- Show help
awful.key({ modkey,           }, "/",      hotkeys_popup.show_help,
{description="show help", group="awesome"}),

-- Tag browsing
awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
{description = "view previous", group = "tag"}),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
{description = "view next", group = "tag"}),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
{description = "go back", group = "tag"}),

-- Default client focus
awful.key({ altkey,           }, "j",
function ()
        awful.client.focus.byidx( 1)
end,
{description = "focus next by index", group = "client"}
),
awful.key({ altkey,           }, "k",
function ()
        awful.client.focus.byidx(-1)
end,
{description = "focus previous by index", group = "client"}
),

-- By-direction client focus
awful.key({ modkey }, "j",
function()
        awful.client.focus.global_bydirection("down")
        if client.focus then client.focus:raise() end
end,
{description = "focus down", group = "client"}),
awful.key({ modkey }, "k",
function()
        awful.client.focus.global_bydirection("up")
        if client.focus then client.focus:raise() end
end,
{description = "focus up", group = "client"}),
awful.key({ modkey }, "h",
function()
        awful.client.focus.global_bydirection("left")
        if client.focus then client.focus:raise() end
end,
{description = "focus left", group = "client"}),
awful.key({ modkey }, "l",
function()
        awful.client.focus.global_bydirection("right")
        if client.focus then client.focus:raise() end
end,
{description = "focus right", group = "client"}),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
{description = "swap with next client by index", group = "client"}),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
{description = "swap with previous client by index", group = "client"}),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
{description = "focus the next screen", group = "screen"}),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
{description = "focus the previous screen", group = "screen"}),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
{description = "jump to urgent client", group = "client"}),
awful.key({ modkey,           }, "Tab",
function ()
        if true then
                awful.client.focus.byidx(1)
        elseif cycle_prev then
                awful.client.focus.history.previous()
        else
                awful.client.focus.byidx(-1)
        end
        if client.focus then
                client.focus:raise()
        end
end,
--{description = "cycle with previous/go back", group = "client"}),
{description = "cycle window focus", group = "client"}),

-- Show/hide wibox
awful.key({ modkey }, "b", function ()
        for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                        s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
        end
end,
{description = "toggle wibox", group = "awesome"}),

-- On-the-fly useless gaps change
awful.key({ altkey, "Control" }, "=", function () lain.util.useless_gaps_resize(1) end,
{description = "increment useless gaps", group = "tag"}),
awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
{description = "decrement useless gaps", group = "tag"}),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
{description = "open a terminal", group = "launcher"}),
awful.key({ modkey, "Control" }, "r", awesome.restart,
{description = "reload awesome", group = "awesome"}),
awful.key({ modkey, "Shift"   }, "q", awesome.quit,
{description = "quit awesome", group = "awesome"}),

awful.key({ modkey,           }, "p", function () awful.layout.inc( 1)                end,
{description = "select next", group = "layout"}),
awful.key({ modkey, "Shift"   }, "p", function () awful.layout.inc(-1)                end,
{description = "select previous", group = "layout"}),

awful.key({ modkey, "Control" }, "n", function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
                c:emit_signal("request::activate", "key.unminimize", {raise = true})
        end
end, {description = "restore minimized", group = "client"}),

-- ALSA volume control
awful.key({ altkey }, "Up",
function ()
        os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
        beautiful.volume.update()
end,
{description = "volume up", group = "hotkeys"}),
awful.key({ altkey }, "Down",
function ()
        os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
        beautiful.volume.update()
end,
{description = "volume down", group = "hotkeys"}),
awful.key({ altkey }, "m",
function ()
        os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
        beautiful.volume.update()
end,
{description = "toggle mute", group = "hotkeys"}),
awful.key({ altkey, "Control" }, "m",
function ()
        os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
        beautiful.volume.update()
end,
{description = "volume 100%", group = "hotkeys"}),
awful.key({ altkey, "Control" }, "0",
function ()
        os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
        beautiful.volume.update()
end,
{description = "volume 0%", group = "hotkeys"}),

-- User programs
awful.key({ modkey }, "a", function () awful.spawn("flatpak run net.ankiweb.Anki") end,
{description = "run anki", group = "launcher"}),
awful.key({ modkey }, "s", function () awful.spawn("steam") end,
{description = "run steam", group = "launcher"}),
awful.key({ modkey }, "d", function () awful.spawn("flatpak run com.discordapp.Discord") end,
{description = "run discord", group = "launcher"}),
awful.key({ modkey }, "f", function () awful.spawn(browser) end,
{description = "run browser", group = "launcher"}),

awful.key({ modkey }, "t", function () awful.spawn("thunar") end,
{description = "run file manager", group = "launcher"}),
awful.key({ modkey }, "e", function () awful.spawn("gnome-encfs-manager") end,
{description = "run encfs manager", group = "launcher"}),


-- Default
-- Menubar
awful.key({ modkey }, "space", function() menubar.show() end,
{description = "show the menubar", group = "launcher"})
)

clientkeys = mytable.join(
awful.key({ modkey, "Shift"   }, "f",
function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
end,
{description = "toggle fullscreen", group = "client"}),
awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
{description = "close", group = "client"}),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
{description = "toggle floating", group = "client"}),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
{description = "move to master", group = "client"}),
awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
{description = "move to screen", group = "client"}),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
{description = "toggle keep on top", group = "client"}),
awful.key({ modkey,           }, "n",
function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
end ,
{description = "minimize", group = "client"}),
awful.key({ modkey,           }, "m",
function (c)
        c.maximized = not c.maximized
        c:raise()
end ,
{description = "(un)maximize", group = "client"}),
awful.key({ modkey, "Control" }, "m",
function (c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
end ,
{description = "(un)maximize vertically", group = "client"}),
awful.key({ modkey, "Shift"   }, "m",
function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
end ,
{description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 1 do
        globalkeys = mytable.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
        function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                        tag:view_only()
                        if (type(beautiful.set_wallpaper) == "function") then
                                beautiful.set_wallpaper(screen)
                        end
                end
        end,
        {description = "view tag", group = "tag"}),
        -- Toggle tag display.
        awful.key({ altkey, "Shift" }, "#" .. i + 9,
        function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                        awful.tag.viewtoggle(tag)
                end
        end,
        {description = "toggle tag", group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
        function ()
                if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                                client.focus:move_to_tag(tag)
                        end
                end
        end,
        {description = "move focused client to tag", group = "tag"})
        )
end
for i = 2, 9 do
        globalkeys = mytable.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
        function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                        tag:view_only()
                end
                if (type(beautiful.set_wallpaper) == "function") then
                        beautiful.set_wallpaper(screen)
                end
        end),
        -- Toggle tag display.
        awful.key({ altkey, "Shift" }, "#" .. i + 9,
        function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                        awful.tag.viewtoggle(tag)
                end
        end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
        function ()
                if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                                client.focus:move_to_tag(tag)
                        end
                end
        end)
        --[[ Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        function ()
        if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
        client.focus:toggle_tag(tag)
        end
        end
        end,
        {description = "toggle focused client on tag #" .. i, group = "tag"})
        --]]
        )
end

clientbuttons = mytable.join(
awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
end),
awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
end),
awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
end),
awful.button({ modkey }, 4, function(t) awful.tag.viewnext(t.screen) end,
{ description = "view previous", group = "tag"}),
awful.button({ modkey }, 5, function(t) awful.tag.viewprev(t.screen) end,
{ description = "view next", group = "tag"}),
awful.button({ altkey }, 4, function () lain.util.tag_view_nonempty(-1) end,
{ description = "view previous nonempty", group = "tag"}),
awful.button({ altkey }, 5, function () lain.util.tag_view_nonempty(1) end,
{ description = "view next nonempty", group = "tag"})
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
        -- All clients will match this rule.
        { rule = { },
        properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        callback = awful.client.setslave,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        size_hints_honor = false
}
    },

    -- Floating clients.
    { rule_any = {
            instance = {
                    "DTA",  -- Firefox addon DownThemAll.
                    "copyq",  -- Includes session name in class.
                    "pinentry",
            },
            class = {
                    "Arandr",
                    "Blueman-manager",
                    "Gpick",
                    "Kruler",
                    "MessageWin",  -- kalarm.
                    "Sxiv",
                    "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                    "Wpa_gui",
                    "veromix",
                    "xtightvncviewer"},

                    -- Note that the name property shown in xprop might be set slightly after creation of the client
                    -- and the name shown there might not match defined rules here.
                    name = {
                            "Event Tester",  -- xev.
                    },
                    role = {
                            "AlarmWindow",  -- Thunderbird's calendar.
                            "ConfigManager",  -- Thunderbird's about:config.
                            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
                    }
            }, properties = { floating = true }},

            -- Add titlebars to normal clients and dialogs
            --{ rule_any = {type = { "normal", "dialog" }
            { rule_any = {type = { "dialog" }
    }, properties = { titlebars_enabled = true }
    },

    -- Assign screens and tags to specific programs.
    { rule = { class = "anki"    },
    properties = { screen = 1, tag = tag_other } },
    { rule = { class = "Steam"   },
    properties = { screen = 1, tag = tag_steam } },
    { rule = { class = "discord" },
    properties = { screen = 1, tag = tag_chat } },
    --{ rule = { class = "firefox" },
    --properties = { screen = 1, tag = tag_browser } },


    { rule = { class = "Signal"  },
    properties = { screen = 1, tag = tag_chat } },

    { rule = { class = "steam_app*" },
    properties = { screen = 1, tag = tag_game } },
    { rule = { class = "RimWorldLinux" },
    properties = { screen = 1, tag = tag_game } },
    { rule = { class = "Slay the Spire" },
    properties = { screen = 1, tag = tag_game } },


    { rule = { class = "Hydrus Client" },
    properties = { screen = 1, tag = tag_media } },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup
                and not c.size_hints.user_position
                and not c.size_hints.program_position then
                -- Prevent clients from being unreachable after screen count changes.
                awful.placement.no_offscreen(c)
        end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
        -- Custom
        if beautiful.titlebar_fun then
                beautiful.titlebar_fun(c)
                return
        end

        -- Default
        -- buttons for the titlebar
        local buttons = mytable.join(
        awful.button({ }, 1, function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.move(c)
        end),
        awful.button({ }, 2, function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                c:kill()
        end),

        awful.button({ }, 3, function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.resize(c)
        end)
        )

        awful.titlebar(c, { size = 20 }) : setup {
                { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
        { -- Title
        align  = "left",
        --widget = awful.titlebar.widget.titlewidget(c),
        widget = wibox.widget.textbox()
},
buttons = buttons,
layout  = wibox.layout.flex.horizontal
        },
        { -- Right
        awful.titlebar.widget.floatingbutton (c),
        --awful.titlebar.widget.maximizedbutton(c),
        --awful.titlebar.widget.stickybutton   (c),
        --awful.titlebar.widget.ontopbutton    (c),
        --awful.titlebar.widget.closebutton    (c),
        layout = wibox.layout.fixed.horizontal()
},
layout = wibox.layout.align.horizontal,
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    c:emit_signal("request::activate", "mouse_enter", {raise = vi_focus})
--end)

client.connect_signal("focus", function(c) 
        c.border_color = beautiful.border_focus
        c.opacity = 1
end)
client.connect_signal("unfocus", function(c) 
        c.border_color = beautiful.border_normal 
        c.opacity=0.90
end)

-- }}}
