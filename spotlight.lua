local Class = require('middleclass')
local Timer = require('timer')

local Spotlight = Class('Spotlight')

function Spotlight:initialize(world, x, y)
    self.radius = 72
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'kinematic')
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(self.radius))
    self.circle.fixture:setSensor(true)
    self.circle.fixture:setUserData({
        name = 'spotlight',
        body = self.circle.body
    })

    self.xTarget = x
    self.yTarget = y
    self.delay = 5
    self.timer = Timer.new()
    self.timer.after(self.delay, function() self:newTarget() end)
end

function Spotlight:newTarget()
    self.xTarget = math.random(16, sw - 16)
    self.yTarget = math.random(32, sh - 32)
    self.delay = 5 - math.min(4, game.time / 7)
    self.timer.after(self.delay, function() self:newTarget() end)
end

function Spotlight:draw()
    self.timer.update(1/60)
    local x, y = self.circle.body:getX(), self.circle.body:getY()
    local dx, dy = self.xTarget - x, self.yTarget - y
    self.circle.body:setPosition(x + dx / 30, y + dy / 30)

    love.graphics.setBlendMode('additive')
    love.graphics.setColor(255, 200, 80, 100)
    love.graphics.circle('fill', x, y, self.radius, self.radius * 4)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha')
end

return Spotlight
