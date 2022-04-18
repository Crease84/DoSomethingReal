function love.load()
    wf = require 'library/windfield'

    anim8 = require'library/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")  
    
    sti = require 'library/sti'
    gameMap = sti('maps/map.lua')

    camera = require'library/camera'
    cam = camera()

    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 800)

    player = {}
    player.x = 400
    player.y = 250
    player.speed = 180
    player.collider = world:newBSGRectangleCollider(300, 300, 200, 200, 14)
    ground = world:newRectangleCollider(100, 400, 600, 100)
    ground:setType('static')
    player.collider:setFixedRotation(true)

    player.spritesheet = love.graphics.newImage('sprite/player.png')
    player.grid = anim8.newGrid(32,30, player.spritesheet:getWidth(), player.spritesheet:getHeight())
    
    player.animation = {}
    player.animation.down = anim8.newAnimation(player.grid('1-4', 3), 0.01)
    player.animation.right = anim8.newAnimation(player.grid('1-4', 1), 0.1)
    player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.1)
    player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animation.left

end

function love.update(dt)
    local isMoving = false
    local px, py = player.collider:getLinearVelocity()
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

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    world:update(dt)
    
    player.x = player.collider:getX()-50
    player.y = player.collider:getY() - 30

    player.anim:update(dt)


end

function love.draw()
    player.anim:draw(player.spritesheet, player.x, player.y, nil, 6, nil, 6, 9)
    world:draw()
end

function love.keypressed(key)
    if key == 'up' then
        player.collider:applyLinearImpulse(0, -30000)
    end
end
