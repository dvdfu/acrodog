local Class = require('middleclass')
local Stateful = require('stateful')

local GUI = Class('GUI')
GUI:include(Stateful)
local Menu = GUI:addState('Menu')
local Play = GUI:addState('Play')
local End = GUI:addState('End')

local font = love.graphics.newFont('assets/babyblue.ttf', 16)
local borderShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        pixel.rgb = vec3(0.0f);
        return pixel;
    }
]]

function GUI:initialize()
    self.timerActive = false
    self.time = 0
    self.stopped = false
    self:gotoState('Menu')
    love.graphics.setFont(font)
end

function GUI:update(dt) end

function Menu:update(dt)
    if love.keyboard.isDown('z') and love.keyboard.isDown('m') then
        self:gotoState('Play')
    end
end

function Play:update(dt)
    if self.timerActive then
        self.time = self.time + dt
    end
end

function GUI:toggleTimer(active)
    self.timerActive = active
end

function GUI:draw() end

function Menu:draw()
    self:drawText('Hold Z and M to start', 0, sh / 2, sw, 'center')
end

function Play:draw()
    local s = math.floor(self.time)
    local cs = math.floor((self.time % 1) * 100)
    if cs < 10 then cs = '0'..cs end
    local text = s..':'..cs
    self:drawText(text, sw / 2, 20, 0, 'left')
end

function GUI:drawText(text, x, y, ...)
    love.graphics.setShader(borderShader)
    love.graphics.printf(text, x + 1, y + 1, ...)
    love.graphics.setShader()
    love.graphics.printf(text, x, y, ...)
end

return GUI
