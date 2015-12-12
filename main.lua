local function beginContact(a, b, coll) end

local function endContact(a, b, coll) end

local function preSolve(a, b, coll) end

local function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
    local dataA, dataB = a:getUserData(), b:getUserData()
    if dataA and dataA.callback then dataA.callback(b) end
    if dataB and dataB.callback then dataB.callback(a) end
end

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

local sw, sh = 768, 480

function love.load()
    love.physics.setMeter(64) --pixels per meter
    world = love.physics.newWorld(0, 640, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    floor = {}
    floor.body = love.physics.newBody(world, sw / 2, sh / 2, 'dynamic')
    floor.shape = love.physics.newRectangleShape(640, 8)
    floor.fixture = love.physics.newFixture(floor.body, floor.shape)
    floor.fixture:setUserData({
        name = 'floor',
        body = floor.body
    })

    fulcrum = {}
    fulcrum.body = love.physics.newBody(world, sw / 2, sh / 2, 'static')
    fulcrum.shape = love.physics.newCircleShape(4)
    fulcrum.fixture = love.physics.newFixture(fulcrum.body, fulcrum.shape)
    fulcrum.fixture:setUserData({
        name = 'fulcrum',
        body = fulcrum.body
    })

    lsupport = {}
    lsupport.body = love.physics.newBody(world, sw / 2 - 160, sh / 2 + 80, 'dynamic')
    lsupport.body:setFixedRotation(true)
    lsupport.shape = love.physics.newRectangleShape(8, 160)
    lsupport.fixture = love.physics.newFixture(lsupport.body, lsupport.shape)
    lsupport.fixture:setUserData({
        name = 'lsupport',
        body = lsupport.body
    })

    rsupport = {}
    rsupport.body = love.physics.newBody(world, sw / 2 + 160, sh / 2 + 80, 'dynamic')
    rsupport.body:setFixedRotation(true)
    rsupport.shape = love.physics.newRectangleShape(8, 160)
    rsupport.fixture = love.physics.newFixture(rsupport.body, rsupport.shape)
    rsupport.fixture:setUserData({
        name = 'rsupport',
        body = rsupport.body
    })

    love.physics.newRevoluteJoint(fulcrum.body, floor.body, fulcrum.body:getX(), fulcrum.body:getY(), false)
    love.physics.newRevoluteJoint(lsupport.body, floor.body, lsupport.body:getX(), lsupport.body:getY() - 80, false)
    love.physics.newRevoluteJoint(rsupport.body, floor.body, rsupport.body:getX(), rsupport.body:getY() - 80, false)

    ball = {}
    ball.body = love.physics.newBody(world, sw / 2 - 100, sh / 2 - 100, 'dynamic')
    ball.body:setLinearDamping(0.1)
    ball.shape = love.physics.newCircleShape(16)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setUserData({
        name = 'ball',
        body = ball.body
    })
end

function love.update(dt)
    world:update(dt)
    if love.keyboard.isDown('z') then
        lsupport.body:applyForce(0, 1000)
    end
    if love.keyboard.isDown('m') then
        rsupport.body:applyForce(0, 1000)
    end
end

function love.draw()
    drawPhysics()
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end
end
