-- Mike Solomon @msol 2019

local log = hs.logger.new('main', 'info')
DEVELOPING_THIS = false -- set to true to ease debugging

HYPER = {'ctrl', 'shift', 'alt', 'cmd'}

-- App bindings
function setUpAppBindings()
  --hyperFocusAll('w', 'React Native Debugger', 'Simulator', 'qemu-system-x86_64')
  --hyperFocusOrOpen('e', 'Notes')
  --hyperFocus('i', 'IntelliJ IDEA', 'IntelliJ IDEA-EAP', 'Xcode', 'Android Studio', 'Atom', 'Code')
  hyperFocusOrOpen('f', 'Finder')
  hyperFocusOrOpen('m', 'Messages')
  hyperFocusOrOpen('s', 'Slack')
  hyperFocusOrOpen('b', 'Bear')
  hyperFocus('c', 'Google Chrome')
  hyperFocus('t', 'Microsoft Teams')
  --hyperFocusOrOpen(';', 'iTerm2')
  --hyperFocusOrOpen('s', 'OmniFocus')
  --hyperFocus('f', 'Google Chrome', 'Firefox')
  --hyperFocusOrOpen('space', 'Sublime Text')
end

-- Window management
function setUpWindowManagement()
  hs.window.animationDuration = 0 -- disable animations
  hs.grid.setMargins({0, 0})
  hs.grid.setGrid('2x2')

  function mkSetFocus(to)
    return function() hs.grid.set(hs.window.focusedWindow(), to) end
  end

  local fullScreen = hs.geometry("0,0 2x2")
  local leftHalf = hs.geometry("0,0 1x2")
  local rightHalf = hs.geometry("1,0 1x2")
  local upperLeft = hs.geometry("0,0 1x1")
  local lowerLeft = hs.geometry("0,1 1x1")
  local upperRight = hs.geometry("1,0 1x1")
  local lowerRight = hs.geometry("1,1 1x1")

  hs.hotkey.bind(HYPER, 'z', mkSetFocus(fullScreen))
 
 -- hs.hotkey.bind(HYPER, 'x', mkSetFocus(leftHalf))
 -- hs.hotkey.bind(HYPER, "c", mkSetFocus(rightHalf))
 -- hs.hotkey.bind(HYPER, "v", mkSetFocus(upperLeft))
 -- hs.hotkey.bind(HYPER, "b", mkSetFocus(lowerLeft))
  --hs.hotkey.bind(HYPER, "u", mkSetFocus(upperRight))
  -- hs.hotkey.bind(HYPER, "n", mkSetFocus(lowerRight))
  -- hs.hotkey.bind(HYPER, "up", hs.window.filter.focusNorth)
  -- hs.hotkey.bind(HYPER, "down", hs.window.filter.focusSouth)
  -- hs.hotkey.bind(HYPER, "left", hs.window.filter.focusWest)
  -- hs.hotkey.bind(HYPER, "right", hs.window.filter.focusEast)
  -- hs.hotkey.bind(HYPER, "v", hs.window.filter.focusNorth)
  -- hs.hotkey.bind(HYPER, "c", hs.window.filter.focusSouth)
  -- hs.hotkey.bind(HYPER, "j", hs.window.filter.focusWest)
  -- hs.hotkey.bind(HYPER, "p", hs.window.filter.focusEast)
  -- hs.hotkey.bind(HYPER, "q", hs.hints.windowHints)
  -- HYPER "d" -- Bound in Karabiner to Cmd+Tab (application switcher)
  -- HYPER "k" -- Bound in Karabiner to Cmd+` (next window of application)

  -- 2021.03.30 LF Modifications
  hs.hotkey.bind(HYPER, "q", moveWindowToDisplay(1))
  hs.hotkey.bind(HYPER, "w", moveWindowToDisplay(2))
  hs.hotkey.bind(HYPER, "e", moveWindowToDisplay(3))


  -- throw to other screen
  hs.hotkey.bind(HYPER, 'o', function()
    local window = hs.window.focusedWindow()
    window:moveToScreen(window:screen():next())
  end)
end

-- focus on the last-focused window of the application given by name, or else launch it
function hyperFocusOrOpen(key, app)
  local focus = mkFocusByPreferredApplicationTitle(true, app)
  function focusOrOpen()
    return (focus() or hs.application.launchOrFocus(app))
  end
  hs.hotkey.bind(HYPER, key, focusOrOpen)
end

-- focus on the last-focused window of the first application given by name
function hyperFocus(key, ...)
  hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(true, ...))
end


-- focus on the last-focused window of every application given by name
function hyperFocusAll(key, ...)
  hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(false, ...))
end


-- creates callback function to select application windows by application name
function mkFocusByPreferredApplicationTitle(stopOnFirst, ...)
  local arguments = {...} -- create table to close over variadic args
  return function()
    local nowFocused = hs.window.focusedWindow()
    local appFound = false
    for _, app in ipairs(arguments) do
      if stopOnFirst and appFound then break end
      log:d('Searching for app ', app)
      local application = hs.application.get(app)
      if application ~= nil then
        log:d('Found app', application)
        local window = application:mainWindow()
        if window ~= nil then
          log:d('Found main window', window)
          if window == nowFocused then
            log:d('Already focused, moving on', application)
          else
            window:focus()
            appFound = true
          end
        end
      end
    end
    return appFound
  end
end


function maybeEnableDebug()
  if DEVELOPING_THIS then
    log.setLogLevel('debug')
    log.d('Loading in development mode')
    -- automatically reload changes when we're developing
    hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
    hs.alert('Hammerspoon config reloaded')
    log:d('Hammerspoon config reloaded')
  end
end

function setUpClipboardTool()
  ClipboardTool = hs.loadSpoon('ClipboardTool')
  ClipboardTool.show_in_menubar = false
  ClipboardTool:start()
  ClipboardTool:bindHotkeys({
    toggle_clipboard = {HYPER, "p"}
  })
end



function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end



-- Main

maybeEnableDebug()
setUpAppBindings()
setUpWindowManagement()
--AsetUpClipboardTool()
