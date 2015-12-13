local Class = require('middleclass')
local Beachball = Class('Beachball')

local sprBall = love.graphics.newImage('assets/beachball.png')

function Beachball:initialize(world, left)
    local x, y = left and -64 or sw + 64, 0
    self.radius = 32
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'dynamic')
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(self.radius))
    self.circle.fixture:setDensity(0.01)
    self.circle.fixture:setUserData({
        name = 'beachball',
        body = self.circle.body
    })

    self.dead = false
    if left then
        self.circle.body:applyLinearImpulse(160, -math.random(160))
    else
        self.circle.body:applyLinearImpulse(-160, -math.random(160))
    end
end

function Beachball:draw()
    love.graphics.draw(sprBall, self.circle.body:getX(), self.circle.body:getY(), self.circle.body:getAngle(), 1, 1, self.radius, self.radius)
    if self.circle.body:getY() - 32 > sh then
        self.dead = true
    end
end

return Beachball
