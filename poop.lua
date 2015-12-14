local Class = require('middleclass')
local Poop = Class('Poop')

local sprPoop = love.graphics.newImage('assets/poop.png')

function Poop:initialize(world, x, y)
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'dynamic')
    self.circle.body:setLinearDamping(0.4)
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(3))
    self.circle.fixture:setUserData({
        name = 'poop',
        body = self.circle.body
    })

    self.dead = false
end

function Poop:draw()
    love.graphics.draw(sprPoop, self.circle.body:getX(), self.circle.body:getY(), self.circle.body:getAngle(), 1, 1, 4, 4)

    if self.circle.body:getY() - 8 > sh then
        self.dead = true
    end
end

return Poop
