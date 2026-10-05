-- Hammerspoon starter config, written 2026-10-02.
-- One hotkey opens a text prompt (an OS-level M-x). Type a few letters, Enter runs it.
-- Hotkey: ctrl + alt + cmd + space  (chosen to stay clear of Emacs and macOS defaults)

require("hs.ipc")  -- lets the "hs" command in the terminal talk to Hammerspoon (reload, checks)

hs.window.animationDuration = 0

-- Place the focused window (or the given one) in a fraction of its screen.
local function place(x, y, w, h, win)
  win = win or hs.window.focusedWindow()
  if not win then return end
  local f = win:screen():frame()
  win:setFrame({ x = f.x + f.w * x, y = f.y + f.h * y, w = f.w * w, h = f.h * h })
end

local function appWindow(name)
  local app = hs.application.get(name)
  return app and app:mainWindow() or nil
end

-- Chrome on the left half, Emacs top right, the terminal bottom right.
local function formLayout()
  local chrome, emacs = appWindow("Google Chrome"), appWindow("Emacs")
  local term = appWindow("iTerm2") or appWindow("Ghostty")
  if chrome then place(0, 0, 0.5, 1, chrome) end
  if emacs then place(0.5, 0, 0.5, 0.5, emacs) end
  if term then place(0.5, 0.5, 0.5, 0.5, term) end
end

local commands = {
  { text = "left half",            fn = function() place(0, 0, 0.5, 1) end },
  { text = "right half",           fn = function() place(0.5, 0, 0.5, 1) end },
  { text = "top half",             fn = function() place(0, 0, 1, 0.5) end },
  { text = "bottom half",          fn = function() place(0, 0.5, 1, 0.5) end },
  { text = "top left quarter",     fn = function() place(0, 0, 0.5, 0.5) end },
  { text = "top right quarter",    fn = function() place(0.5, 0, 0.5, 0.5) end },
  { text = "bottom left quarter",  fn = function() place(0, 0.5, 0.5, 0.5) end },
  { text = "bottom right quarter", fn = function() place(0.5, 0.5, 0.5, 0.5) end },
  { text = "left third",           fn = function() place(0, 0, 1/3, 1) end },
  { text = "center third",         fn = function() place(1/3, 0, 1/3, 1) end },
  { text = "right third",          fn = function() place(2/3, 0, 1/3, 1) end },
  { text = "left two thirds",      fn = function() place(0, 0, 2/3, 1) end },
  { text = "right two thirds",     fn = function() place(1/3, 0, 2/3, 1) end },
  { text = "maximize",             fn = function() place(0, 0, 1, 1) end },
  { text = "center",               fn = function() place(0.15, 0.1, 0.7, 0.8) end },
  { text = "layout: form filling (Chrome left, Emacs and terminal right)", fn = formLayout },
  { text = "focus Chrome",         fn = function() hs.application.launchOrFocus("Google Chrome") end },
  { text = "focus Emacs",          fn = function() hs.application.launchOrFocus("Emacs") end },
  { text = "focus iTerm",          fn = function() hs.application.launchOrFocus("iTerm") end },
  { text = "focus Ghostty",        fn = function() hs.application.launchOrFocus("Ghostty") end },
  { text = "focus Finder",         fn = function() hs.application.launchOrFocus("Finder") end },
  { text = "reload Hammerspoon config", fn = function() hs.reload() end },
}

local chooser = hs.chooser.new(function(choice)
  if choice then commands[choice.index].fn() end
end)
chooser:searchSubText(false)

local function showPrompt()
  local choices = {}
  for i, c in ipairs(commands) do choices[i] = { text = c.text, index = i } end
  chooser:choices(choices)
  chooser:query("")
  chooser:show()
end

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "space", showPrompt)

hs.alert.show("Hammerspoon ready: ctrl+alt+cmd+space")
