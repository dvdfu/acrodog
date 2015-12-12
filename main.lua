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

    base = {}
    base.body = love.physics.newBody(world, sw / 2, sh, 'static')
    base.shape = love.physics.newCircleShape(4)
    base.fixture = love.physics.newFixture(base.body, base.shape)
    base.fixture:setUserData({
        name = 'base',
        body = base.body
    })

    floor = {}
    floor.body = love.physics.newBody(world, sw / 2, sh - 80, 'dynamic')
    floor.shape = love.physics.newRectangleShape(640, 8)
    floor.fixture = love.physics.newFixture(floor.body, floor.shape)
    floor.fixture:setUserData({
        name = 'floor',
        body = floor.body
    })

    fulcrum = {}
    fulcrum.body = love.physics.newBody(world, sw / 2, sh - 80, 'dynamic')
    fulcrum.shape = love.physics.newCircleShape(4)
    fulcrum.fixture = love.physics.newFixture(fulcrum.body, fulcrum.shape)
    fulcrum.fixture:setUserData({
        name = 'fulcrum',
        body = fulcrum.body
    })

    lsupport = {}
    lsupport.body = love.physics.newBody(world, sw / 2 - 160, sh - 40, 'dynamic')
    lsupport.body:setGravityScale(0)
    lsupport.shape = love.physics.newRectangleShape(8, 80)
    lsupport.fixture = love.physics.newFixture(lsupport.body, lsupport.shape)
    lsupport.fixture:setUserData({
        name = 'lsupport',
        body = lsupport.body
    })

    rsupport = {}
    rsupport.body = love.physics.newBody(world, sw / 2 + 160, sh - 40, 'dynamic')
    rsupport.body:setGravityScale(0)
    rsupport.shape = love.physics.newRectangleShape(8, 80)
    rsupport.fixture = love.physics.newFixture(rsupport.body, rsupport.shape)
    rsupport.fixture:setUserData({
        name = 'rsupport',
        body = rsupport.body
    })

    ball = {}
    ball.body = love.physics.newBody(world, sw / 2 - 100, sh / 2 - 100, 'dynamic')
    ball.body:setLinearDamping(0.1)
    ball.shape = love.physics.newCircleShape(16)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setRestitution(0.2)
    ball.fixture:setUserData({
        name = 'ball',
        body = ball.body
    })

    love.physics.newWheelJoint(floor.body, lsupport.body, lsupport.body:getX(), floor.body:getY(), -1, 0)
    love.physics.newWheelJoint(floor.body, rsupport.body, rsupport.body:getX(), floor.body:getY(), 1, 0)
    love.physics.newRevoluteJoint(floor.body, fulcrum.body, floor.body:getX(), floor.body:getY())
    love.physics.newPrismaticJoint(fulcrum.body, base.body, sw / 2, sh, 0, 1)
    lprism = love.physics.newPrismaticJoint(base.body, lsupport.body, lsupport.body:getX(), sh, 0, -1)
    lprism:setLimitsEnabled(true)
    lprism:setLimits(0, 160)
    rprism = love.physics.newPrismaticJoint(base.body, rsupport.body, rsupport.body:getX(), sh, 0, -1)
    rprism:setLimitsEnabled(true)
    rprism:setLimits(0, 160)
end

function love.update(dt)
    world:update(dt)
    local force = 1000
    if love.keyboard.isDown('z') then
        lsupport.body:applyForce(0, force)
    else
        lsupport.body:applyForce(0, -force)
    end
    if love.keyboard.isDown('m') then
        rsupport.body:applyForce(0, force)
    else
        rsupport.body:applyForce(0, -force)
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
