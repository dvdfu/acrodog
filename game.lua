-- local Beachball = require('beachball')
local Floor = require('floor')
local GUI = require('gui')
local Player = require('player')
local Spotlight = require('spotlight')
local Tomato = require('tomato')

local sprSky = love.graphics.newImage('assets/sky.png')
local sprTomatoChunk = love.graphics.newImage('assets/tomato-chunk.png')
local songMain = love.audio.newSource('assets/song-main.mp3')
local songBack = love.audio.newSource('assets/song-back.mp3')
local songEnd = love.audio.newSource('assets/song-end.mp3')

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
    tomatoTimer = 0

    gui = GUI:new()
    floor = Floor:new(world)
    player = Player:new(world, sw / 2, sh / 2 - 100)

    spotlight = Spotlight:new(world)
    songTimer = 1
    songMain:setLooping(true)
    songMain:play()
    songBack:setLooping(true)
    songBack:play()
    songBack:setVolume(0)
end

function Game:leave()
    songMain:stop()
    songBack:stop()
end

function Game:addTomato()
    local tomato = Tomato:new(world, math.random() < 0.5)
    table.insert(tomatoes, tomato)
end

function Game:update(dt)
    gui:update(dt)
    floor:update(dt)
    world:update(dt)

    if gui.timerActive then
        tomatoTimer = 0
        if songTimer < 1 - dt then
            songTimer = songTimer + dt
        else
            songTimer = 1
        end
    else
        tomatoTimer = tomatoTimer + dt
        if tomatoTimer > 1 and math.random() < 0.05 then
            self:addTomato()
        end
        if songTimer > dt then
            songTimer = songTimer - dt
        else
            songTimer = 0
        end
    end
    songMain:setVolume(0.2 + 0.8 * songTimer)
    songBack:setVolume(1 - (0.2 + 0.8 * songTimer))
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
