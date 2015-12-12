love.graphics.setDefaultFilter('nearest', 'nearest')

Gamestate = require('gamestate')
Game = require('game')

function love.load()
    Gamestate.registerEvents({ 'update', 'draw' })
    Gamestate.switch(Game)
end

function love.update(dt)
end

function love.draw()
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end
end
