local defm = require("src/app_defaults")
local ds = {}
defm.getAppDefaults(ds)

-- local log_m = require '../thirdparty/log_lua-master/log'

local mainTimer = require "../thirdparty/hump.timer"

require "src/asteroids_game"
local asteroidsGame = AsteroidsGame()

-- ===========================================================================

function love.keypressed(key)
  asteroidsGame:processKeyPressed(key)
end

function love.load(arg)
  local success = love.window.setMode(ds.windowWidth, ds.windowHeight,
                                      {resizable=false, minwidth=100, minheight=300})
  if (not success) then
    log_m.error("Failed to set window mode")
  end

  asteroidsGame:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                            ds.gameAreaWidth, ds.gameAreaHeight)
end

function love.draw()
  asteroidsGame:drawSelf()
end

function love.update(diffTime)
  asteroidsGame:processUpdate(diffTime)
end
