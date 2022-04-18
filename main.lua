function love.load()
    wf = require 'library/windfield'
    world = wf.newWorld(0, 0)

    anim8 = require'library/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")  
    
    sti = require 'library/sti'
    gameMap = sti('maps/map.lua')

    camera = require'library/camera'
    cam = camera()

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 350, 50, 30, 14)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 300
    player.speed = 300
    player.spritesheet = love.graphics.newImage('sprite/player.png')
    player.grid = anim8.newGrid(32,30, player.spritesheet:getWidth(), player.spritesheet:getHeight())

    player.animation = {}
    player.animation.down = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animation.right = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animation.left

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static') 
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animation.right
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animation.left
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        vy = player.speed *-1
        player.anim = player.animation.up
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = player.speed 
        player.anim = player.animation.down
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    world:update(dt)

    player.x = player.collider:getX()
    player.y = player.collider:getY() - 30

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local h = love.graphics.getHeight()
    local w = love.graphics.getWidth()

    if cam.x < w/2 then
        cam.x = w/2 
    end

    if cam.y < h/2 then
        cam.y = h/2 
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end


    
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        player.anim:draw(player.spritesheet, player.x, player.y, nil, 6, nil, 6, 9)
        --world:draw()
    cam:detach()

    
end
