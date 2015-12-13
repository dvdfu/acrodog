require('AnAL')
local Class = require('middleclass')
local Tomato = Class('Tomato')

local sprTomato = love.graphics.newImage('assets/tomato.png')

function Tomato:initialize(world, left)
    local x, y = left and -16 or sw + 16, math.random(sh / 2)
    self.circle = {}
    self.circle.body = love.physics.newBody(world, x, y, 'dynamic')
    self.circle.body:setLinearDamping(0.4)
    self.circle.fixture = love.physics.newFixture(self.circle.body, love.physics.newCircleShape(8))
    self.circle.fixture:setRestitution(0.7)
    self.circle.fixture:setUserData({
        name = 'tomato',
        body = self.circle.body,
        draw = function() self:draw() end,
        beginContact = function(other)
            local data = other:getUserData()
            if data and data.name then
                if data.name == 'floor' then
                    game.tomatoChunks:setPosition(self.circle.body:getX(), self.circle.body:getY())
                    game.tomatoChunks:emit(9)
                    self.dead = true
                elseif data.name == 'player' then
                    game.tomatoChunks:setPosition(self.circle.body:getX(), self.circle.body:getY())
                    game.tomatoChunks:emit(9)
                    self.dead = true
                    data.player.red = true
                    game:endGame()
                end
            end
        end
    })

    self.dead = false
    self.anim = newAnimation(sprTomato, 16, 16, 0.1, 3)

    if left then
        self.circle.body:applyLinearImpulse(12, -math.random(12))
    else
        self.circle.body:applyLinearImpulse(-12, -math.random(12))
    end
end

function Tomato:draw()

    local vx, vy = self.circle.body:getLinearVelocity()
    local speed = vx + vy
    self.anim:update(1/60)
    self.anim:setSpeed(math.abs(speed / 140))
    self.anim:draw(self.circle.body:getX(), self.circle.body:getY(), 0, 1, 1, 8, 8)

    if self.circle.body:getY() - 8 > sh then
        self.dead = true
    end
end

return Tomato
