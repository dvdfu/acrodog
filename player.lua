require('AnAL')
local Class = require('middleclass')
local Player = Class('Player')

local runSprite = love.graphics.newImage('assets/dog-run.png')

function Player:initialize(world, x, y)
    self.ball = {}
    self.ball.body = love.physics.newBody(world, x, y, 'dynamic')
    self.ball.body:setLinearDamping(0.1)
    self.ball.fixture = love.physics.newFixture(self.ball.body, love.physics.newCircleShape(24))
    self.ball.fixture:setRestitution(0.25)
    self.ball.fixture:setUserData({
        name = 'ball',
        body = self.ball.body,
        draw = function() self:draw() end
    })

    self.runAnim = newAnimation(runSprite, 24, 24, 0.1, 4)
end

function Player:update(dt)
end

function Player:draw()
    self.runAnim:update(1/60)
    local vx, _ = self.ball.body:getLinearVelocity()
    self.runAnim:setSpeed(math.abs(vx / 140))
    self.runAnim:draw(self.ball.body:getX(), self.ball.body:getY(), 0, vx > 0 and 2 or -2, 2, 12, 12)
end

return Player
