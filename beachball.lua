local Class = require('middleclass')
local Beachball = Class('Beachball')

local sprBall = love.graphics.newImage('assets/beachball.png')

function Beachball:initialize(world, x, y)
    self.radius = 32
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'dynamic')
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(self.radius))
    self.circle.fixture:setUserData({
        name = 'beachball',
        body = self.circle.body
    })
end

function Beachball:draw()
    love.graphics.draw(sprBall, self.circle.body:getX(), self.circle.body:getY(), self.circle.body:getAngle(), 1, 1, self.radius, self.radius)
end

return Beachball
