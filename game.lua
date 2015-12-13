local Class = require('middleclass')
local Beachball = require('beachball')
local Floor = require('floor')
local Player = require('player')
local Spotlight = require('spotlight')
local Stateful = require('stateful')
local Timer = require('timer')
local Tomato = require('tomato')

local sprBackground = love.graphics.newImage('assets/background.png')
local sprTomatoChunk = love.graphics.newImage('assets/tomato-chunk.png')
local songMain = love.audio.newSource('assets/song-main.mp3')
local songBack = love.audio.newSource('assets/song-back.mp3')
local songEnd = love.audio.newSource('assets/song-end.mp3')

local Game = Class('Game')
Game:include(Stateful)
local Menu = Game:addState('Menu')
local Play = Game:addState('Play')
local End = Game:addState('End')

local font = love.graphics.newFont('assets/babyblue.ttf', 16)
local borderShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        pixel.rgb = vec3(0.0f);
        return pixel;
    }
]]

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
    local bodies = self.world:getBodyList()
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

function Game:initialize()
    love.physics.setMeter(64) --pixels per meter
    self.world = love.physics.newWorld(0, 640, true)
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.tomatoes = {}
    self.tomatoChunks = love.graphics.newParticleSystem(sprTomatoChunk)
    self.tomatoChunks:setParticleLifetime(0, 0.5)
    self.tomatoChunks:setDirection(-math.pi / 2)
    self.tomatoChunks:setSpread(math.pi / 2)
    self.tomatoChunks:setLinearAcceleration(0, 200)
    self.tomatoChunks:setSpeed(50, 200)
    self.tomatoChunks:setSizes(1, 0.3)
    self.tomatoTimer = 0

    self.beachballs = {}
    self.beachballTimer = Timer.new()
    self.beachballTimer.after(10, function() self:addBeachball() end)

    self.floor = Floor:new(self.world)
    self.player = Player:new(self.world, sw / 2, -12)

    self.timerActive = false
    self.time = 0
    self:gotoState('Menu')
    love.graphics.setFont(font)
end

function Game:leave()
    songMain:stop()
    songBack:stop()
end

function Play:enteredState()
    spotlight = Spotlight:new(self.world)
    songTimer = 1
    songMain:setLooping(true)
    songMain:play()
    songBack:setLooping(true)
    songBack:play()
    songBack:setVolume(0)
end

function Game:toggleTimer(active)
    self.timerActive = active
end

function Game:addTomato()
    local tomato = Tomato:new(self.world, math.random() < 0.5)
    table.insert(self.tomatoes, tomato)
end

function Game:addBeachball()
    local beachball = Beachball:new(self.world, math.random() < 0.5)
    table.insert(self.beachballs, beachball)
    self.beachballTimer.after(10, function() self:addBeachball() end)
end

function Game:update(dt)
    self.floor:update(dt)
    self.world:update(dt)

    -- if gui.timerActive then
    --     self.tomatoTimer = 0
    --     if songTimer < 1 - dt then
    --         songTimer = songTimer + dt
    --     else
    --         songTimer = 1
    --     end
    -- else
    --     self.tomatoTimer = self.tomatoTimer + dt
    --     if self.tomatoTimer > 1 and math.random() < 0.05 then
    --         self:addTomato()
    --     end
    --     if songTimer > dt then
    --         songTimer = songTimer - dt
    --     else
    --         songTimer = 0
    --     end
    -- end
end

function Menu:update(dt)
    Game.update(self, dt)
    if love.keyboard.isDown('z') and love.keyboard.isDown('m') then
        self:gotoState('Play')
    end
end

function Play:update(dt)
    Game.update(self, dt)
    self.beachballTimer.update(dt)
    songMain:setVolume(0.2 + 0.8 * songTimer)
    songBack:setVolume(1 - (0.2 + 0.8 * songTimer))
    if self.timerActive then
        self.time = self.time + dt
    end
end

function Game:draw()
    love.graphics.draw(sprBackground)
    self.floor:draw()
    self.tomatoChunks:update(1/60)
    love.graphics.draw(self.tomatoChunks)
    self.player:draw()
    for key, tomato in pairs(self.tomatoes) do
        if tomato.dead then
            table.remove(self.tomatoes, key)
            tomato.circle.body:destroy()
        else
            tomato:draw()
        end
    end
    for key, beachball in pairs(self.beachballs) do
        if beachball.dead then
            table.remove(self.beachballs, key)
            beachball.circle.body:destroy()
        else
            beachball:draw()
        end
    end
end

function Menu:draw()
    Game.draw(self)
    self:drawText('Hold Z and M to start', 0, sh / 2, sw, 'center')
end

function Play:draw()
    Game.draw(self)
    spotlight:draw()
    local s = math.floor(self.time)
    local cs = math.floor((self.time % 1) * 100)
    if cs < 10 then cs = '0'..cs end
    local text = s..':'..cs
    self:drawText(text, sw / 2, 20, 0, 'left')
end

function Game:drawText(text, x, y, ...)
    love.graphics.setShader(borderShader)
    love.graphics.printf(text, x + 1, y + 1, ...)
    love.graphics.setShader()
    love.graphics.printf(text, x, y, ...)
end

return Game
