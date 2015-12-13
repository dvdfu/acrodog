require('AnAL')
local Class = require('middleclass')
local Player = Class('Player')

local runSprite = love.graphics.newImage('assets/dog-run.png')
local jumpSprite = love.graphics.newImage('assets/dog-jump.png')
local idleSprite = love.graphics.newImage('assets/dog-idle.png')

function Player:initialize(world, x, y)
    self.ball = {}
    self.ball.body = love.physics.newBody(world, x, y, 'dynamic')
    self.ball.body:setLinearDamping(0.4)
    self.ball.fixture = love.physics.newFixture(self.ball.body, love.physics.newCircleShape(12))
    -- self.ball.fixture:setRestitution(0.25)
    self.ball.fixture:setUserData({
        name = 'ball',
        body = self.ball.body,
        draw = function() self:draw() end,
        callback = function(other)
            local data = other:getUserData()
            if data and data.name and data.name == 'floor' then
                self.groundTimer = 30
            end
        end
    })

    self.runAnim = newAnimation(runSprite, 24, 24, 0.1, 4)
    self.jumpAnim = newAnimation(jumpSprite, 24, 24, 0.1, 4)
    self.idleAnim = newAnimation(idleSprite, 24, 24, 0.1, 4)
    self.anim = self.runAnim
    self.groundTimer = 30
end

function Player:draw()
    -- print(self.grounded)
    local vx, vy = self.ball.body:getLinearVelocity()
    self.anim:update(1/60)
    if self.groundTimer < 0 then
        self.anim = self.jumpAnim
        self.anim:setSpeed(math.abs(vx / 140))
    else
        if (math.abs(vx) < 10) then
            self.anim:setSpeed(1)
            self.anim = self.idleAnim
        else
            self.anim:setSpeed(math.abs(vx / 140))
            self.anim = self.runAnim
        end
    end
    self.anim:draw(self.ball.body:getX(), self.ball.body:getY(), 0, vx > 0 and 1 or -1, 1, 12, 12)
end

return Player
