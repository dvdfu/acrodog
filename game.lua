local Class = require('middleclass')
local Beachball = require('beachball')
local Floor = require('floor')
local Player = require('player')
local Poop = require('poop')
local Spotlight = require('spotlight')
local Stateful = require('stateful')
local Timer = require('timer')
local Tomato = require('tomato')

local sprBackground = love.graphics.newImage('assets/background.png')
local sprTomatoChunk = love.graphics.newImage('assets/tomato-chunk.png')
local sprTitle = love.graphics.newImage('assets/title.png')
local songMain = love.audio.newSource('assets/song-main.mp3')
local songBack = love.audio.newSource('assets/song-back.mp3')
local songEnd = love.audio.newSource('assets/song-end.mp3')
local sfxOk = love.audio.newSource('assets/ok.wav')
local sfxLose = love.audio.newSource('assets/lose.wav')
local sfxThrow = love.audio.newSource('assets/throw.wav')
local sfxLower = love.audio.newSource('assets/lower.wav')
local sfxFart = love.audio.newSource('assets/fart.mp3')
sfxHit = love.audio.newSource('assets/hit.wav')

local Game = Class('Game')
Game:include(Stateful)
local Menu = Game:addState('Menu')
local Play = Game:addState('Play')
local End = Game:addState('End')

local fontBig = love.graphics.newFont('assets/babyblue.ttf', 16)
local fontSmall = love.graphics.newFont('assets/redalert.ttf', 13)
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
    self.tomatoCount = 0

    self.beachballs = {}
    self.beachballTimer = Timer.new()
    self.beachballTimer.after(10, function() self:addBeachball() end)

    self.poops = {}
    self.floor = Floor:new(self.world)

    self.timerActive = false
    self.time = 0

    sfxLose:setVolume(0.5)
    sfxHit:setVolume(0.5)
    sfxThrow:setVolume(0.5)
    sfxLower:setVolume(0.5)
    self:gotoState('Menu')
end

function Game:endGame() end

function Menu:enteredState()
    sfxOk:stop()
    sfxOk:play()
    songMain:stop()
    songBack:stop()
    songEnd:stop()
    self.blinkTimer = 0
end

function Play:enteredState()
    sfxOk:stop()
    sfxOk:play()
    self.blinkTimer = 0
    self.player = Player:new(self.world, sw / 2, -12)
    self.spotlight = Spotlight:new(self.world, sw / 2, sh / 2)
    self.songTimer = 1
    songMain:setLooping(true)
    songMain:play()
    songBack:setLooping(true)
    songBack:play()
    songBack:setVolume(0)
end

function Play:endGame()
    self:gotoState('End')
end

function End:enteredState()
    sfxLose:stop()
    sfxLose:play()
    self.spotlight.circle.body:destroy()
    songMain:stop()
    songBack:stop()
    songEnd:play()
end

function Game:toggleTimer(active)
    self.timerActive = active
end


function Game:addPoop()
    local poop = Poop:new(self.world, self.player.ball.body:getX(), self.player.ball.body:getY())
    table.insert(self.poops, poop)
    sfxFart:setPitch(0.9 + 0.2 * math.random())
    sfxFart:stop()
    sfxFart:play()
end

function Game:addTomato()
    local tomato = Tomato:new(self.world, math.random() < 0.5)
    table.insert(self.tomatoes, tomato)
    self.tomatoCount = self.tomatoCount + 1
    sfxThrow:setPitch(0.9 + 0.2 * math.random())
    sfxThrow:stop()
    sfxThrow:play()
end

function Game:addBeachball()
    local beachball = Beachball:new(self.world, math.random() < 0.5)
    table.insert(self.beachballs, beachball)
    self.beachballTimer.after(10, function() self:addBeachball() end)
end

function Game:update(dt)
    self.floor:update(dt)
    self.world:update(dt)

    if Input:pressed('z') or Input:pressed('m') then
        sfxLower:setPitch(0.5 + 0.5 * math.random())
        sfxLower:stop()
        sfxLower:play()
    end

    if Input:pressed('p') then
        self:addPoop()
    end
end

function Menu:update(dt)
    self.blinkTimer = self.blinkTimer + 1
    Game.update(self, dt)
    if love.keyboard.isDown('z') and love.keyboard.isDown('m') then
        self:gotoState('Play')
    end
end

function Play:update(dt)
    self.blinkTimer = self.blinkTimer + 1
    Game.update(self, dt)
    self.beachballTimer.update(dt)
    if self.timerActive then
        self.tomatoTimer = 0
        if self.songTimer < 1 - dt then
            self.songTimer = self.songTimer + dt
        else
            self.songTimer = 1
        end
    else
        self.tomatoTimer = self.tomatoTimer + dt
        if self.tomatoTimer > 1 and math.random() < 0.03 then
            self:addTomato()
        end
        if self.songTimer > dt then
            self.songTimer = self.songTimer - dt
        else
            self.songTimer = 0
        end
    end
    songMain:setVolume(0.2 + 0.8 * self.songTimer)
    songBack:setVolume(1 - (0.2 + 0.8 * self.songTimer))
    if self.timerActive then
        self.time = self.time + dt
    end
    if self.player.ball.body:getY() - 12 > sh or
        self.player.ball.body:getX() < 0 or
        self.player.ball.body:getX() > sw then
        self:endGame()
    end
end

function Game:draw()
    love.graphics.draw(sprBackground)
    self.floor:draw()
    self.tomatoChunks:update(1/60)
    love.graphics.draw(self.tomatoChunks)
    if self.player then
        self.player:draw()
    end
    for key, tomato in pairs(self.tomatoes) do
        if tomato.dead then
            table.remove(self.tomatoes, key)
            tomato.circle.body:destroy()
            sfxHit:setPitch(0.9 + 0.2 * math.random())
            sfxHit:stop()
            sfxHit:play()
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
    for key, poop in pairs(self.poops) do
        if poop.dead then
            table.remove(self.poops, key)
            poop.circle.body:destroy()
        else
            poop:draw()
        end
    end
end

function Menu:draw()
    Game.draw(self)
    love.graphics.draw(sprTitle, sw / 2, 16 + 4 * math.sin(self.blinkTimer / 10), 0, 1, 1, 160)
    self:drawText(fontSmall, 'Hold Z and M to start', 0, sh / 2 + 34, sw, 'center')
    self:drawText(fontSmall, 'Made for Ludum Dare 34 by @dvdfu', 0, sh / 2 + 96, sw, 'center')
end

function Play:draw()
    Game.draw(self)
    self.spotlight:draw()
    if self.time < 4 then
        self:drawText(fontSmall, 'Stand in the light\nto please the audience!', 0, sh / 2 - 12, sw, 'center')
    end
    if not self.timerActive and self.blinkTimer % 20 < 10 then return end
    local s = math.floor(self.time)
    local cs = math.floor((self.time % 1) * 100)
    if cs < 10 then cs = '0'..cs end
    local text = s..':'..cs
    self:drawText(fontBig, text, 0, 20, sw, 'center')
end

function End:draw()
    Game.draw(self)
    local s = math.floor(self.time)
    local cs = math.floor((self.time % 1) * 100)
    if cs < 10 then cs = '0'..cs end
    local text = s..':'..cs
    local tomatoText
    if self.tomatoCount == 0 then
        tomatoText = 'Everyone loved him.'
    elseif self.tomatoCount == 1 then
        tomatoText = '1 tomato was thrown.'
    else
        tomatoText = self.tomatoCount..' tomatoes were thrown.'
    end
    self:drawText(fontBig, "Lil Houndini stole the show for "..text.."s!\n"..tomatoText, 0, sh / 2 - 64, sw, 'center')
    self:drawText(fontSmall, "Press R for an encore.", 0, sh / 2 - 16, sw, 'center')
end

function Game:drawText(font, text, x, y, ...)
    love.graphics.setFont(font)
    love.graphics.setShader(borderShader)
    love.graphics.printf(text, x + 1, y + 1, ...)
    love.graphics.setShader()
    love.graphics.printf(text, x, y, ...)
end

return Game
