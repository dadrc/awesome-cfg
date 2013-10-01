-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")
-- for run once
require("lfs") 
require("whiteclock")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
home_dir = os.getenv("HOME") .. "/"
config_dir = home_dir .. ".config/awesome/"
themes_dir = config_dir .. "themes/"
beautiful.init(themes_dir .. "arrowed/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor
shutdown = "dbus-shutdown"
reboot = "dbus-reboot"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
awful.layout.suit.floating,			--  1
awful.layout.suit.tile,				--  2 
awful.layout.suit.tile.left,		--  3
awful.layout.suit.tile.bottom,		--  4
awful.layout.suit.tile.top,			--  5
awful.layout.suit.fair,				--  6
awful.layout.suit.fair.horizontal,	--  7
awful.layout.suit.spiral,			--  8
awful.layout.suit.spiral.dwindle,	--  9
awful.layout.suit.max,				-- 10
awful.layout.suit.max.fullscreen,	-- 11
awful.layout.suit.magnifier			-- 12
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
--	names  = {"⠁","⠂","⠃","⠄","⠅","⠆","⠇","⠈","⠉"},
	names = {"➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒"},
	layout = { layouts[8], layouts[6], layouts[10], layouts[2], layouts[1], layouts[2], layouts[2], layouts[2], layouts[2] }
}

for s = 1, screen.count() do
-- Each screen has its own tag table.
tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
{ "manual", terminal .. " -e man awesome" },
{ "edit config", editor_cmd .. " " .. awesome.conffile },
{ "restart", awesome.restart },
{ "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
			    { "Debian", debian.menu.Debian_menu.Debian },
			    { "open terminal", terminal },
			    { "reboot", reboot },
			    { "shutdown", shutdown }
			  }
		})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
			     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = whiteclock()
mytextclock.bg = beautiful.agrey

-- Create a systray
mysystray = widget({ type = "systray" })

updatebox = widget({ type = "textbox", name = "updatebox"})
updatebox.text = '<span color="#ffffff">— </span>'
updatebox.bg = beautiful.agrey

tempbox = widget({ type = "textbox", name = "tempbox"})
tempbox.text = '<span color="#ffffff">— </span>'
tempbox.bg = beautiful.orange

songbox = widget({ type = "textbox", name = "songbox"})
songbox.text = '<span color="#ffffff">■ </span>'
songbox.bg = beautiful.lblue

arr1 = widget ({type = "imagebox" })
arr1.image = image(beautiful.arr_bg_agrey)
arr2 = widget ({type = "imagebox" })
arr2.image = image(beautiful.arr_agrey_orange)
arr3 = widget ({type = "imagebox" })
arr3.image = image(beautiful.arr_orange_lblue)
arr4 = widget ({type = "imagebox" })
arr4.image = image(beautiful.arr_lblue_bg)
arr8 = widget ({type = "imagebox" })
arr8.image = image(beautiful.arr_agrey_bg)
spr = widget({ type = "textbox" })
spr.text = ' ' 

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	    awful.button({ }, 1, awful.tag.viewonly),
	    awful.button({ modkey }, 1, awful.client.movetotag),
	    awful.button({ }, 3, awful.tag.viewtoggle),
	    awful.button({ modkey }, 3, awful.client.toggletag),
	    awful.button({ }, 4, awful.tag.viewnext),
	    awful.button({ }, 5, awful.tag.viewprev)
	    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	     awful.button({ }, 1, function (c)
				      if c == client.focus then
					  c.minimized = true
				      else
					  if not c:isvisible() then
					      awful.tag.viewonly(c:tags()[1])
					  end
					  -- This will also un-minimize
					  -- the client, if needed
					  client.focus = c
					  c:raise()
				      end
				  end),
	     awful.button({ }, 3, function ()
				      if instance then
					  instance:hide()
					  instance = nil
				      else
					  instance = awful.menu.clients({ width=250 })
				      end
				  end),
	     awful.button({ }, 4, function ()
				      awful.client.focus.byidx(1)
				      if client.focus then client.focus:raise() end
				  end),
	     awful.button({ }, 5, function ()
				      awful.client.focus.byidx(-1)
				      if client.focus then client.focus:raise() end
				  end))

for s = 1, screen.count() do
-- Create a promptbox for each screen
mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
mylayoutbox[s] = awful.widget.layoutbox(s)
mylayoutbox[s]:buttons(awful.util.table.join(
		   awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		   awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		   awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		   awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
-- Create a taglist widget
mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

-- Create a tasklist widget
mytasklist[s] = awful.widget.tasklist(function(c)
				      return awful.widget.tasklist.label.currenttags(c, s)
				  end, mytasklist.buttons)

-- Create the wibox
mywibox[s] = awful.wibox({ position = "top", screen = s })
-- Add widgets to the wibox - order matters
mywibox[s].widgets = {
{
    mylauncher,
    mytaglist[s],
    mypromptbox[s],
    layout = awful.widget.layout.horizontal.leftright
},
mylayoutbox[s],
spr,
arr1,
mytextclock,
arr8,
s == 1 and spr or nil,
s == 1 and mysystray or nil, 
s == 1 and arr1 or nil,
s == 1 and updatebox or nil,
s == 1 and arr2 or nil,
s == 1 and tempbox or nil,
s == 1 and arr3 or nil,
s == 1 and songbox or nil,
s == 1 and arr4 or nil,
spr,
mytasklist[s],
layout = awful.widget.layout.horizontal.rightleft
}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
-- custom keys were here
awful.key({                   }, "XF86AudioPlay", function () awful.util.spawn("gmusicbrowser -ifnotrunning nocmd -cmd PlayPause") end ),
awful.key({                   }, "XF86AudioStop", function () awful.util.spawn("gmusicbrowser -cmd Stop") end ),
awful.key({                   }, "XF86AudioNext", function () awful.util.spawn("gmusicbrowser -cmd NextSong") end ),
awful.key({                   }, "XF86AudioPrev", function () awful.util.spawn("gmusicbrowser -cmd PrevSong") end ),
-- awesome default bindings
awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

awful.key({ modkey,           }, "j",
function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
awful.key({ modkey,           }, "Tab",
function ()
    awful.client.focus.history.previous()
    if client.focus then
	client.focus:raise()
    end
end),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift"   }, "q", awesome.quit),

awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

awful.key({ modkey, "Control" }, "n", awful.client.restore),

-- Prompt
awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

awful.key({ modkey }, "x",
      function ()
	  awful.prompt.run({ prompt = "Run Lua code: " },
	  mypromptbox[mouse.screen].widget,
	  awful.util.eval, nil,
	  awful.util.getdir("cache") .. "/history_eval")
      end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
awful.key({ modkey,           }, "n",
function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end),
awful.key({ modkey,           }, "m",
function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
globalkeys = awful.util.table.join(globalkeys,
awful.key({ modkey }, "#" .. i + 9,
	  function ()
		local screen = mouse.screen
		if tags[screen][i] then
		    awful.tag.viewonly(tags[screen][i])
		end
	  end),
awful.key({ modkey, "Control" }, "#" .. i + 9,
	  function ()
	      local screen = mouse.screen
	      if tags[screen][i] then
		  awful.tag.viewtoggle(tags[screen][i])
	      end
	  end),
awful.key({ modkey, "Shift" }, "#" .. i + 9,
	  function ()
	      if client.focus and tags[client.focus.screen][i] then
		  awful.client.movetotag(tags[client.focus.screen][i])
	      end
	  end),
awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	  function ()
	      if client.focus and tags[client.focus.screen][i] then
		  awful.client.toggletag(tags[client.focus.screen][i])
	      end
	  end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
-- All clients will match this rule.
{ rule = { },
properties = { border_width = beautiful.border_width,
	     border_color = beautiful.border_normal,
	     focus = true,
	     keys = clientkeys,
	     buttons = clientbuttons } },
{ rule = { class = "MPlayer" },
properties = { floating = true } },
{ rule = { class = "pinentry" },
properties = { floating = true } },
{ rule = { class = "gimp" },
properties = { floating = true } },
-- Remove window border from Torchlight
{ rule = { class = "Torchlight.bin.x86_64" },
properties = { border_width = 0,
               x = 0,
               y = 0 } },
--{rule = { class = "Pidgin", role = "conversation" },
--properties = { floating = true } },
{ rule = { name = "File Operation Progress" },
properties = { floating = true } },
{ rule = { class = "Smplayer" },
properties = { floating = true } },
-- Move windows to specific workspaces
{ rule = { class = "Firefox" },
properties = { tag = tags[1][3] } },
{ rule = { name = "JDownloader" },
properties = { tag = tags[1][4] } },
{ rule = { class ="Gmusicbrowser" },
properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
-- Add a titlebar
-- awful.titlebar.add(c, { modkey = modkey })

-- Enable sloppy focus
c:add_signal("mouse::enter", function(c)
if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
end
end)

if not startup then
-- Set the windows at the slave,
-- i.e. put it at the end of others instead of setting it master.
-- awful.client.setslave(c)

-- Put windows in a smart way, only if they does not set an initial position.
if not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end
end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- {{{ Run programm once
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
        -- All directories in /proc containing a number, represent a process
        if tonumber(dir) ~= nil then
          local f, err = io.open("/proc/"..dir.."/cmdline")
          if f then
            local cmdline = f:read("*all")
            f:close()
            if cmdline ~= "" then
              coroutine.yield(cmdline)
            end
          end
        end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
   assert(type(process) == "string")
   local regex_killer = {
      ["+"]  = "%+", ["-"] = "%-",
      ["*"]  = "%*", ["?"]  = "%?" }

   for p in processwalker() do
      if p:find(process:gsub("[-+?*]", regex_killer)) then
	 return
      end
   end
   return awful.util.spawn_with_shell(cmd or process)
end
-- }}}

-- {{{ Autostart
awful.util.spawn_with_shell("setxkbmap -option compose:caps")
run_once("awesome-updater")
run_once("tomboy")
run_once("gtk-redshift","gtk-redshift -l 52.2:10.5 -t 6500:5500 -m randr")
run_once("xfce4-volumed")
run_once("ubuntuone-syncdaemon","/usr/bin/python /usr/lib/ubuntuone-client/ubuntuone-syncdaemon")
-- }}}
