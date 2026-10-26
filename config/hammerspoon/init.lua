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

-- Hold ctrl + cmd and drag anywhere inside a window to resize it from the nearest corner or edge.
-- Added 2026-10-23: emacs-mac 29.4 (built for macOS 26) ignores edge drags on macOS 27, while
-- resizing it through accessibility works, so Hammerspoon does the resize.
local types = hs.eventtap.event.types
resizeDebug = false  -- set to true to print each mouse-down to the Hammerspoon console (tuning only)
local resizing = nil

local function windowAt(p)
  for _, w in ipairs(hs.window.orderedWindows()) do
    local f = w:frame()
    if p.x >= f.x and p.x <= f.x + f.w and p.y >= f.y and p.y <= f.y + f.h then return w end
  end
end

local function side(v, lo, len)
  if v < lo + len / 3 then return -1 elseif v > lo + 2 * len / 3 then return 1 else return 0 end
end

-- ctrl+click can arrive as a right click (trackpad and mouse settings), so both buttons count.
local downT = { [types.leftMouseDown] = true, [types.rightMouseDown] = true }
local dragT = { [types.leftMouseDragged] = true, [types.rightMouseDragged] = true }
local upT = { [types.leftMouseUp] = true, [types.rightMouseUp] = true }

resizeTap = hs.eventtap.new({ types.leftMouseDown, types.leftMouseDragged, types.leftMouseUp,
                              types.rightMouseDown, types.rightMouseDragged, types.rightMouseUp }, function(e)
  local t = e:getType()
  if downT[t] then
    local m = e:getFlags()
    if resizeDebug then print("resize: down type " .. t .. " flags " .. hs.inspect(m)) end
    if not (m.ctrl and m.cmd) or m.alt or m.shift then return false end
    local p = hs.mouse.absolutePosition()
    local win = windowAt(p)
    if not win then return false end
    local f = win:frame()
    local sx, sy = side(p.x, f.x, f.w), side(p.y, f.y, f.h)
    if sx == 0 and sy == 0 then sx, sy = 1, 1 end
    resizing = { win = win, f = f, p = p, sx = sx, sy = sy }
    return true
  elseif dragT[t] and resizing then
    local r, p = resizing, hs.mouse.absolutePosition()
    local dx, dy = p.x - r.p.x, p.y - r.p.y
    local x, y, w, h = r.f.x, r.f.y, r.f.w, r.f.h
    if r.sx == 1 then w = w + dx elseif r.sx == -1 then x, w = x + dx, w - dx end
    if r.sy == 1 then h = h + dy elseif r.sy == -1 then y, h = y + dy, h - dy end
    if w >= 200 and h >= 120 then r.win:setFrame({ x = x, y = y, w = w, h = h }) end
    return true
  elseif upT[t] and resizing then
    resizing = nil
    return true
  end
  return false
end)
resizeTap:start()
-- macOS switches off a tap that is slow to answer (Hammerspoon busy); switch it back on.
resizeWatch = hs.timer.doEvery(5, function()
  if not resizeTap:isEnabled() then resizeTap:start() end
end)

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
