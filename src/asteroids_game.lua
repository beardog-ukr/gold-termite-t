local defm = require("src/app_defaults")
local ds = {}
defm.getAppDefaults(ds)

local log_m = require '../thirdparty/log_lua-master/log'

local HumpClass = require "../thirdparty/hump.class"

require "src/asteroid"
require "src/rocket"
require "src/spaceship"

-- ===========================================================================

AsteroidsGame = HumpClass{
  spaceship = nil,
  asteroids = {} ,
  rockets = {} ,
  mainTimer = nil,
  asteroidsUpdateTimeAcc = 0,
}

function AsteroidsGame:init()
  self.mainTimer = require "../thirdparty/hump.timer"
  self.spaceship = Spaceship(480, 50)

  local asteroidPositions = { {x=100, y=80, a=-math.pi/2},
                              {x= 80, y=500, a=math.pi/4}}
  for i=1,#asteroidPositions do
    self.asteroids[i] = Asteroid(asteroidPositions[i])
    self.asteroids[i]:restartMoving(self.mainTimer)
  end
end

-- ===========================================================================

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
  for i = 1, #self.rockets do
    self.rockets[i]:drawSelf()
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

function AsteroidsGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
  elseif (key == "space") then
    local newIdx = #self.rockets +1
    self.rockets[newIdx] = Rocket(self.spaceship, self.mainTimer)
  else
    self.spaceship:processKeyPressed(key, self.mainTimer)
  end
end

function AsteroidsGame:processUpdate(diffTime)
  self.mainTimer.update(diffTime)
  self.asteroidsUpdateTimeAcc = self.asteroidsUpdateTimeAcc + diffTime
  if (self.asteroidsUpdateTimeAcc > 3.5) then
    -- log_m.trace("restarting asteroids")
    for i=1,#self.asteroids do
      self.asteroids[i]:restartMoving(self.mainTimer)
      self.asteroidsUpdateTimeAcc = 0
    end

    local newRockets = {}
    local newRocketsIdx = 1;
    for i=1,#self.rockets do
      if (self.rockets[i].active < 0.05) then
        self.mainTimer.cancel(self.rockets[i].movingTweenHandle)
        self.rockets[i] = nil
        log_m.trace("removed rocket #" .. i)
      else
        newRockets[newRocketsIdx] = self.rockets[i]
        newRocketsIdx = newRocketsIdx +1
      end
    end
    self.rockets = newRockets
  end
end

function AsteroidsGame:setGameArea(x,y, width, height)
  self.spaceship:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                             ds.gameAreaWidth, ds.gameAreaHeight)
  for i = 1, #self.asteroids do
    self.asteroids[i]:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                                  ds.gameAreaWidth, ds.gameAreaHeight)
  end
end
