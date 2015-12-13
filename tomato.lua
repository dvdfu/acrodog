require('AnAL')
local Class = require('middleclass')
local Tomato = Class('Tomato')

local sprTomato = love.graphics.newImage('assets/tomato.png')
local sprChunk = love.graphics.newImage('assets/tomato-chunk.png')

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
                    self.chunks:emit(5)
                    self.dead = true
                end
            end
        end
    })

    self.dead = false
    self.anim = newAnimation(sprTomato, 16, 16, 0.1, 3)

    if left then
        self.circle.body:applyLinearImpulse(10, -math.random(10))
    else
        self.circle.body:applyLinearImpulse(-10, -math.random(10))
    end

    self.chunks = love.graphics.newParticleSystem(sprChunk)
    self.chunks:setParticleLifetime(0, 0.5)
    self.chunks:setDirection(-math.pi / 2)
    self.chunks:setSpread(math.pi / 2)
    self.chunks:setLinearAcceleration(0, 200)
    self.chunks:setSpeed(50, 200)
    self.chunks:setSizes(1, 0.3)
end

function Tomato:draw()
    self.chunks:setPosition(self.circle.body:getX(), self.circle.body:getY())
    self.chunks:update(1/60)
    love.graphics.draw(self.chunks)

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
