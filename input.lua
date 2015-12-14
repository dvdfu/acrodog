local Input = {}
local keys = setmetatable({}, {
    __index = function(table, key)
        return {
            pressed = false,
            released = false,
            isDown = false
        }
    end
})

function love.keypressed(key)
    keys[key] = keys[key]
    keys[key].pressed = true
end

function love.keyreleased(key)
    keys[key] = keys[key]
    keys[key].released = true
end

function Input:update()
    for k, v in pairs(keys) do
        v.pressed = false
        v.released = false
        v.isDown = love.keyboard.isDown(k)
    end
end

function Input:pressed(key)
    return keys[key].pressed
end

function Input:released(key)
    return keys[key].released
end

function Input:isDown(key)
    return keys[key].isDown
end

return Input
