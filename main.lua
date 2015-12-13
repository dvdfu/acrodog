math.randomseed(os.time())
love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setLineStyle('rough')

local Gamestate = require('gamestate')
local Game = require('game')

sw, sh = 384, 240

function love.load()
    Gamestate.registerEvents({ 'update' })
    Gamestate.switch(Game)

    canvas = love.graphics.newCanvas(sw, sh)
    scaleShader = love.graphics.newShader[[
        extern float scale;
        vec4 position(mat4 transform_projection, vec4 vertex_position) {
            vertex_position.xy *= scale;
            return transform_projection * vertex_position;
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            return Texel(texture, texture_coords);
        }
    ]]
    scaleShader:send('scale', 2)
end

function love.draw()
    canvas:clear()
    love.graphics.setCanvas(canvas)
    love.graphics.push()
    Gamestate.draw()
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.setShader(scaleShader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    elseif k == ' ' then
        Gamestate.switch(Game)
    end
end
