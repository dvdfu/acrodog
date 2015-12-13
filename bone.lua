require('AnAL')
local Class = require('middleclass')
local Bone = Class('Bone')

local boneSprite = love.graphics.newImage('assets/bone.png')

function Bone:initialize(world, x, y)
    self.bar = {}
    self.bar.body = love.physics.newBody(world, x, y, 'dynamic')
    self.bar.body:setLinearDamping(0.4)
    self.bar.fixture = love.physics.newFixture(self.bar.body, love.physics.newCircleShape(8))
    self.bar.fixture:setRestitution(0.7)
    self.bar.fixture:setUserData({
        name = 'bar',
        body = self.bar.body,
        draw = function() self:draw() end
    })

    self.anim = newAnimation(boneSprite, 16, 16, 0.1, 3)
end

function Bone:draw()
    local vx, vy = self.bar.body:getLinearVelocity()
    self.anim:update(1/60)
    self.anim:setSpeed(math.abs(vx / 140))
    self.anim:draw(self.bar.body:getX(), self.bar.body:getY(), 0, 1, 1, 8, 8)
end

return Bone
