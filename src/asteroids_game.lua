local defm = require("src/app_defaults")
local ds = {}
defm.getAppDefaults(ds)

local log_m = require '../thirdparty/log_lua-master/log'

local HumpClass = require "../thirdparty/hump.class"
-- local mainTimer = require "../thirdparty/hump.timer"

require "src/spaceship"
-- local spaceship = Spaceship(80, 520)

require "src/asteroid"
-- local asteroid = Asteroid(480, 120)

-- ===========================================================================

AsteroidsGame = HumpClass{
  spaceship = nil,
  asteroids = {} ,
  mainTimer = nil,
}

function AsteroidsGame:init()
  self.mainTimer = require "../thirdparty/hump.timer"
  self.spaceship = Spaceship(80, 520)

  local asteroidsPositions = { {x=100, y=200},
                               {x= 80, y=400}}
  for i=1,#asteroidsPositions do
    self.asteroids[i] = Asteroid(asteroidsPositions[i].x, asteroidsPositions[i].y)
  end
end

-- ===========================================================================

function AsteroidsGame:processKeyPressed(key)
  self.spaceship:processKeyPressed(key, self.mainTimer)
end

function AsteroidsGame:setGameArea(x,y, width, height)
  self.spaceship:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                             ds.gameAreaWidth, ds.gameAreaHeight)
  for i = 1, #self.asteroids do
    self.asteroids[i]:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                                  ds.gameAreaWidth, ds.gameAreaHeight)
  end
end

function AsteroidsGame:drawSelf()
  local cww = love.graphics.getWidth(); -- current window width
  local cwh = love.graphics.getHeight();-- current window height

  -- clear screen
  love.graphics.setColor(ds.palette.emptyScreen)
  love.graphics.rectangle("fill", 0, 0, cww, cwh)

  -- draw objects
  self.spaceship:drawSelf()
  for i = 1, #self.asteroids do
    self.asteroids[i]:drawSelf()
  end

  -- draw (restore) large borders
  love.graphics.setColor(ds.palette.emptyScreen)
  love.graphics.rectangle("fill", 0, 0, ds.largeFrameSize, cwh)
  love.graphics.rectangle("fill", ds.largeFrameSize + ds.gameAreaWidth, 0,
                          ds.largeFrameSize, cwh)
  love.graphics.rectangle("fill", ds.largeFrameSize, 0,
                          ds.gameAreaWidth, ds.largeFrameSize)
  love.graphics.rectangle("fill", ds.largeFrameSize, ds.largeFrameSize + ds.gameAreaHeight,
                          ds.gameAreaWidth, ds.largeFrameSize)

  --draw smaller borders
  love.graphics.setColor(ds.palette.gameAreaBorder)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize - ds.smallFrameSize,
                          ds.gameAreaWidth + ds.smallFrameSize*2, ds.smallFrameSize)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize + ds.gameAreaHeight,
                          ds.gameAreaWidth + ds.smallFrameSize*2, ds.smallFrameSize)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize,
                          ds.smallFrameSize, ds.gameAreaHeight)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize + ds.gameAreaWidth, ds.largeFrameSize,
                          ds.smallFrameSize, ds.gameAreaHeight)
end

function AsteroidsGame:processUpdate(diffTime)
  self.mainTimer.update(diffTime)
end
