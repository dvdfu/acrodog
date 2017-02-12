package.path = '?/?.lua;'..package.path
package.path = 'modules/?/?.lua;'..package.path
package.path = 'modules/hump/?.lua;'..package.path
package.path = 'modules/love-misc-libs/?/?.lua;'..package.path

math.randomseed(os.time())
love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setLineStyle('rough')

local Game = require('game')
Input = require('input')

sw, sh = 384, 240

function love.load()
    game = Game:new()

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

function love.update(dt)
    game:update(dt)
    if Input:pressed('r') then
        game = Game:new()
    end
    if Input:pressed('escape') then
        love.event.quit()
    end
    Input:update()
end

function love.draw()
    love.graphics.clear()
    love.graphics.setCanvas(canvas)
    love.graphics.push()
    game:draw()
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.setShader(scaleShader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end
