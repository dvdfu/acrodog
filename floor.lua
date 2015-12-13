local Class = require('middleclass')
local Floor = Class('Floor')

local sprFloor = love.graphics.newImage('assets/floor.png')

function Floor:initialize(world)
    local supportHeight = 32

    self.base = {}
    self.base.body = love.physics.newBody(world, sw / 2, sh, 'static')
    self.base.fixture = love.physics.newFixture(self.base.body, love.physics.newCircleShape(4))
    self.base.fixture:setUserData({
        name = 'base',
        body = self.base.body
    })

    self.floor = {}
    self.floor.body = love.physics.newBody(world, sw / 2, sh - supportHeight, 'dynamic')
    self.floor.shape = love.physics.newRectangleShape(320, 8)
    self.floor.fixture = love.physics.newFixture(self.floor.body, self.floor.shape)
    self.floor.fixture:setFriction(1)
    self.floor.fixture:setUserData({
        name = 'floor',
        body = self.floor.body
    })

    self.fulcrum = {}
    self.fulcrum.body = love.physics.newBody(world, sw / 2, sh - supportHeight, 'dynamic')
    self.fulcrum.fixture = love.physics.newFixture(self.fulcrum.body, love.physics.newCircleShape(4))
    self.fulcrum.fixture:setUserData({
        name = 'fulcrum',
        body = self.fulcrum.body
    })

    local supportShape = love.physics.newRectangleShape(8, supportHeight)

    self.lsupport = {}
    self.lsupport.body = love.physics.newBody(world, sw / 2 - 80, sh - supportHeight / 2, 'dynamic')
    self.lsupport.body:setGravityScale(0)
    self.lsupport.body:setFixedRotation(true)
    self.lsupport.fixture = love.physics.newFixture(self.lsupport.body, supportShape)
    self.lsupport.fixture:setUserData({
        name = 'lsupport',
        body = self.lsupport.body
    })

    self.rsupport = {}
    self.rsupport.body = love.physics.newBody(world, sw / 2 + 80, sh - supportHeight / 2, 'dynamic')
    self.rsupport.body:setGravityScale(0)
    self.rsupport.body:setFixedRotation(true)
    self.rsupport.fixture = love.physics.newFixture(self.rsupport.body, supportShape)
    self.rsupport.fixture:setUserData({
        name = 'rsupport',
        body = self.rsupport.body
    })

    love.physics.newWheelJoint(self.floor.body, self.lsupport.body, self.lsupport.body:getX(), self.floor.body:getY(), -1, 0)
    love.physics.newWheelJoint(self.floor.body, self.rsupport.body, self.rsupport.body:getX(), self.floor.body:getY(), 1, 0)
    love.physics.newRevoluteJoint(self.floor.body, self.fulcrum.body, self.floor.body:getX(), self.floor.body:getY())
    love.physics.newPrismaticJoint(self.fulcrum.body, self.base.body, sw / 2, sh, 0, 1)
    self.lprism = love.physics.newPrismaticJoint(self.base.body, self.lsupport.body, self.lsupport.body:getX(), sh, 0, -1)
    self.lprism:setLimitsEnabled(true)
    self.lprism:setLimits(0, 54)
    self.rprism = love.physics.newPrismaticJoint(self.base.body, self.rsupport.body, self.rsupport.body:getX(), sh, 0, -1)
    self.rprism:setLimitsEnabled(true)
    self.rprism:setLimits(0, 54)
end

function Floor:update(dt)
    local force = 1200
    if love.keyboard.isDown('z') then
        self.lsupport.body:applyForce(0, force)
    else
        self.lsupport.body:applyForce(0, -force)
    end
    if love.keyboard.isDown('m') then
        self.rsupport.body:applyForce(0, force)
    else
        self.rsupport.body:applyForce(0, -force)
    end
end

function Floor:draw()
    love.graphics.setColor(255, 255, 255, 64)
    love.graphics.line(sw / 2 - 160, sh - 36, sw / 2 + 160, sh - 36)
    love.graphics.line(sw / 2 - 160, sh - 90, sw / 2 + 160, sh - 90)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(sprFloor, self.floor.body:getX(), self.floor.body:getY(), self.floor.body:getAngle(), 1, 1, 160, 4)
end

return Floor