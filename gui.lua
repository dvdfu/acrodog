local Class = require('middleclass')
local GUI = Class('GUI')

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
    love.graphics.setFont(font)
end

function GUI:update(dt)
    if self.timerActive then
        self.time = self.time + dt
    end
end

function GUI:toggleTimer(active)
    self.timerActive = active
end

function GUI:draw()
    local s = math.floor(self.time)
    local cs = math.floor((self.time % 1) * 100)
    if cs < 10 then cs = '0'..cs end
    local text = s..':'..cs
    love.graphics.setShader(borderShader)
    love.graphics.printf(text, sw / 2 + 1, 21, 0, 'left')
    love.graphics.setShader()
    love.graphics.printf(text, sw / 2, 20, 0, 'left')
end

return GUI
