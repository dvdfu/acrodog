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
    self.ball.body:setAngularDamping(2)
    self.ball.fixture = love.physics.newFixture(self.ball.body, love.physics.newCircleShape(12))
    self.ball.fixture:setDensity(3)
    self.ball.fixture:setUserData({
        name = 'ball',
        body = self.ball.body,
        beginContact = function(other)
            local data = other:getUserData()
            if data and data.name then
                if data.name == 'floor' then
                    self.grounded = true
                elseif data.name == 'spotlight' then
                    gui:toggleTimer(true)
                end
            end
        end,
        endContact = function(other)
            local data = other:getUserData()
            if data and data.name then
                if data.name == 'floor' then
                    self.grounded = false
                elseif data.name == 'spotlight' then
                    gui:toggleTimer(false)
                end
            end
        end
    })

    self.runAnim = newAnimation(runSprite, 24, 24, 0.1, 4)
    self.jumpAnim = newAnimation(jumpSprite, 24, 24, 0.1, 4)
    self.idleAnim = newAnimation(idleSprite, 24, 24, 0.1, 4)
    self.anim = self.runAnim
    self.grounded = false
    self.groundTimer = 30
end

function Player:draw()
    local vx, vy = self.ball.body:getLinearVelocity()
    self.anim:update(1/60)
    if self.grounded then
        self.groundTimer = 10
    else
        self.groundTimer = self.groundTimer - 1
    end
    if self.groundTimer < 0 then
        self.anim = self.jumpAnim
        self.anim:setSpeed(math.abs(vx / 140))
    else
        if (math.abs(vx) < 20) then
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
