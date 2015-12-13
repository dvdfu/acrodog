local Beachball = require('beachball')
local Player = require('player')
local Score = require('score')
local Spotlight = require('spotlight')

local sprSky = love.graphics.newImage('assets/sky.png')
local sprFloor = love.graphics.newImage('assets/floor.png')
local song = love.audio.newSource('assets/song.mp3')

local Game = {}

local function beginContact(a, b, coll)
    local dataA, dataB = a:getUserData(), b:getUserData()
    if dataA and dataA.beginContact then dataA.beginContact(b) end
    if dataB and dataB.beginContact then dataB.beginContact(a) end
end

local function endContact(a, b, coll)
    local dataA, dataB = a:getUserData(), b:getUserData()
    if dataA and dataA.endContact then dataA.endContact(b) end
    if dataB and dataB.endContact then dataB.endContact(a) end
end

local function preSolve(a, b, coll) end

local function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2) end

local function drawPhysics()
    local bodies = world:getBodyList()
    for _, body in pairs(bodies) do
        for _, fixture in pairs(body:getFixtureList()) do
            local shape = fixture:getShape()
            if shape:getType() == 'circle' then
                love.graphics.circle('line', body:getX(), body:getY(), shape:getRadius())
            elseif shape:getType() == 'polygon' then
                love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
            end
        end
    end
end

function Game:enter()
    love.physics.setMeter(64) --pixels per meter
    world = love.physics.newWorld(0, 640, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    local supportHeight = 32

    base = {}
    base.body = love.physics.newBody(world, sw / 2, sh, 'static')
    base.fixture = love.physics.newFixture(base.body, love.physics.newCircleShape(4))
    base.fixture:setUserData({
        name = 'base',
        body = base.body
    })

    floor = {}
    floor.body = love.physics.newBody(world, sw / 2, sh - supportHeight, 'dynamic')
    floor.shape = love.physics.newRectangleShape(320, 8)
    floor.fixture = love.physics.newFixture(floor.body, floor.shape)
    floor.fixture:setFriction(1)
    floor.fixture:setUserData({
        name = 'floor',
        body = floor.body,
        draw = function()
        end
    })

    fulcrum = {}
    fulcrum.body = love.physics.newBody(world, sw / 2, sh - supportHeight, 'dynamic')
    fulcrum.fixture = love.physics.newFixture(fulcrum.body, love.physics.newCircleShape(4))
    fulcrum.fixture:setUserData({
        name = 'fulcrum',
        body = fulcrum.body
    })

    local supportShape = love.physics.newRectangleShape(8, supportHeight)

    lsupport = {}
    lsupport.body = love.physics.newBody(world, sw / 2 - 80, sh - supportHeight / 2, 'dynamic')
    lsupport.body:setGravityScale(0)
    lsupport.body:setFixedRotation(true)
    lsupport.fixture = love.physics.newFixture(lsupport.body, supportShape)
    lsupport.fixture:setUserData({
        name = 'lsupport',
        body = lsupport.body
    })

    rsupport = {}
    rsupport.body = love.physics.newBody(world, sw / 2 + 80, sh - supportHeight / 2, 'dynamic')
    rsupport.body:setGravityScale(0)
    rsupport.body:setFixedRotation(true)
    rsupport.fixture = love.physics.newFixture(rsupport.body, supportShape)
    rsupport.fixture:setUserData({
        name = 'rsupport',
        body = rsupport.body
    })

    love.physics.newWheelJoint(floor.body, lsupport.body, lsupport.body:getX(), floor.body:getY(), -1, 0)
    love.physics.newWheelJoint(floor.body, rsupport.body, rsupport.body:getX(), floor.body:getY(), 1, 0)
    love.physics.newRevoluteJoint(floor.body, fulcrum.body, floor.body:getX(), floor.body:getY())
    love.physics.newPrismaticJoint(fulcrum.body, base.body, sw / 2, sh, 0, 1)
    lprism = love.physics.newPrismaticJoint(base.body, lsupport.body, lsupport.body:getX(), sh, 0, -1)
    lprism:setLimitsEnabled(true)
    lprism:setLimits(0, 54)
    rprism = love.physics.newPrismaticJoint(base.body, rsupport.body, rsupport.body:getX(), sh, 0, -1)
    rprism:setLimitsEnabled(true)
    rprism:setLimits(0, 54)

    score = Score:new()
    player = Player:new(world, sw / 2, sh / 2 - 100)
    beachball = Beachball:new(world, sw / 2, 100)
    spotlight = Spotlight:new(world)
    song:setLooping(true)
    song:play()
end

function Game:update(dt)
    score:update(dt)
    world:update(dt)
    local force = 1200
    if love.keyboard.isDown('z') then
        lsupport.body:applyForce(0, force)
    else
        lsupport.body:applyForce(0, -force)
    end
    if love.keyboard.isDown('m') then
        rsupport.body:applyForce(0, force)
    else
        rsupport.body:applyForce(0, -force)
    end
end

function Game:draw()
    love.graphics.draw(sprSky, 0, 0, 0, 2, 2)
    -- guidelines
    love.graphics.setColor(255, 255, 255, 64)
    love.graphics.line(sw / 2 - 160, sh - 36, sw / 2 + 160, sh - 36)
    love.graphics.line(sw / 2 - 160, sh - 90, sw / 2 + 160, sh - 90)
    love.graphics.setColor(255, 255, 255, 255)
    -- drawPhysics()
    love.graphics.draw(sprFloor, floor.body:getX(), floor.body:getY(), floor.body:getAngle(), 1, 1, 160, 4)
    beachball:draw()
    player:draw()
    spotlight:draw()
    score:draw()
end

return Game
