-- local Beachball = require('beachball')
local Floor = require('floor')
local GUI = require('gui')
local Player = require('player')
local Spotlight = require('spotlight')
local Tomato = require('tomato')

local sprSky = love.graphics.newImage('assets/sky.png')
local sprTomatoChunk = love.graphics.newImage('assets/tomato-chunk.png')
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

    tomatoes = {}
    tomatoChunks = love.graphics.newParticleSystem(sprTomatoChunk)
    tomatoChunks:setParticleLifetime(0, 0.5)
    tomatoChunks:setDirection(-math.pi / 2)
    tomatoChunks:setSpread(math.pi / 2)
    tomatoChunks:setLinearAcceleration(0, 200)
    tomatoChunks:setSpeed(50, 200)
    tomatoChunks:setSizes(1, 0.3)

    gui = GUI:new()
    floor = Floor:new(world)
    player = Player:new(world, sw / 2, sh / 2 - 100)

    spotlight = Spotlight:new(world)
    song:setLooping(true)
    song:play()
end

function Game:addTomato()
    local tomato = Tomato:new(world, math.random() < 0.5)
    table.insert(tomatoes, tomato)
end

function Game:update(dt)
    gui:update(dt)
    floor:update(dt)
    world:update(dt)
    if math.random() < 0.01 then
        self:addTomato()
    end
end

function Game:draw()
    love.graphics.draw(sprSky, 0, 0, 0, 2, 2)
    floor:draw()
    -- beachball:draw()
    tomatoChunks:update(1/60)
    love.graphics.draw(tomatoChunks)
    player:draw()
    for key, tomato in pairs(tomatoes) do
        if tomato.dead then
            table.remove(tomatoes, key)
            tomato.circle.body:destroy()
        else
            tomato:draw()
        end
    end
    spotlight:draw()
    gui:draw()
end

return Game
