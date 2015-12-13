local Class = require('middleclass')
local Spotlight = Class('Spotlight')

function Spotlight:initialize(world)
    self.radius = 48
    self.circle = {}
    self.circle.body = love.physics.newBody(world, 100, 100, 'kinematic')
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(self.radius))
    self.circle.fixture:setSensor(true)
    self.circle.fixture:setUserData({
        name = 'spotlight',
        body = self.circle.body
    })
end

function Spotlight:draw()
    love.graphics.setBlendMode('additive')
    love.graphics.setColor(255, 255, 128, 64)
    love.graphics.circle('fill', self.circle.body:getX(), self.circle.body:getY(), self.radius, self.radius * 4)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha')
end

return Spotlight
