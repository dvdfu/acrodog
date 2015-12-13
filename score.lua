local Class = require('middleclass')
local Score = Class('Score)')

function Score:initialize()
    self.score = 0
    self.time = 0
    self.stopped = false
end

function Score:update(dt)
    self.time = self.time + dt
    while self.time > 1 do
        self.time = self.time - 1
        self.score = self.score + 1
    end
end

function Score:draw()
    love.graphics.printf(self.score, sw / 2, 20, 0, 'center')
end

return Score
