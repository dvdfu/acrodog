require('AnAL')
local Class = require('middleclass')
local Tomato = Class('Tomato')

local sprTomato = love.graphics.newImage('assets/tomato.png')

function Tomato:initialize(world, x, y)
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'dynamic')
    self.circle.body:setLinearDamping(0.4)
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(8))
    self.circle.fixture:setRestitution(0.7)
    self.circle.fixture:setUserData({
        name = 'tomato',
        body = self.circle.body,
        draw = function() self:draw() end
    })

    self.anim = newAnimation(sprTomato, 16, 16, 0.1, 3)
end

function Tomato:draw()
    local vx, vy = self.circle.body:getLinearVelocity()
    local speed = vx + vy
    self.anim:update(1/60)
    self.anim:setSpeed(math.abs(speed / 140))
    self.anim:draw(self.circle.body:getX(), self.circle.body:getY(), 0, 1, 1, 8, 8)
end

return Tomato
