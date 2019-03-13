local appdef_m = require("src/app_defaults")
local appdef = {}
appdef_m.getAppDefaults(appdef)

local log_m = require '../thirdparty/log_lua-master/log'

local Class = require "../thirdparty/hump.class"

local rktdef_m = require("src/app_defaults")
local rktdef = {}
rktdef_m.getRocketDefaults(rktdef)

-- ===========================================================================

Rocket = Class{
  angle = 0 ,
  gameAreaX = 0          ,
  gameAreaY = 0          ,
  gameAreaWidth = 0      ,
  gameAreaHeight = 0     ,
  size = 10             ,
  movingTweenHandle = nil ,
  active = 1
}

local function startMoving(ctx, mainTimer, distance)
  ctx.active = 1
  local newCX = ctx.centerX + (math.cos(ctx.angle) * distance);
  local newCY = ctx.centerY + (math.sin(ctx.angle) * distance);

  local newTimer = mainTimer.tween(rktdef.speedInterval, ctx,
                                   {centerX = newCX, centerY = newCY, active =0})
  ctx.movingTweenHandle = newTimer

  -- log_m.trace("Rocket will move to " .. newCX .. ":" .. newCY)
end

-- Should receive Spaceship object as parameters keeper
function Rocket:init(params, mainTimer)
  self.angle = params.angle
  self.centerX = params.centerX + (math.cos(self.angle)*params.size);
  self.centerY = params.centerY + (math.sin(self.angle)*params.size);

  self.gameAreaX = params.gameAreaX
  self.gameAreaY = params.gameAreaY

  self.gameAreaWidth = params.gameAreaWidth
  self.gameAreaHeight = params.gameAreaHeight

  startMoving(self, mainTimer, params.size*rktdef.moveLeapLength)
end

-- ============================================================================

function Rocket:drawSelf()
  if (self.active < 0.05) then
    -- log_m.trace("Rocket is not active " .. self.active)
    return
  end

  local cx = self.centerX + self.gameAreaX --
  local cy = self.centerY + self.gameAreaY --

  local defLineWidth = love.graphics.getLineWidth()
  love.graphics.setLineWidth(self.size)
  love.graphics.setColor(rktdef.mainColor)
  love.graphics.arc("fill", cx, cy, self.size,
                    self.angle - math.pi + (math.pi/12),
                    self.angle - math.pi - (math.pi/12))
  love.graphics.setLineWidth(defLineWidth)
end
