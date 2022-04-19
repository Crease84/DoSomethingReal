player = {}

function player:load()
    self.x = 100
    self.y = 0
    self.width = 32
    self.height = 30
    self.xv = 0
    self.yv = 0
    self.maxSpeed = 200
    self.a = 4000
    self.f = 3500
    self.gravity = 1500
    self.jumpA = -500

    self.graceTime = 0
    self.graceDuration = 0.1

    self.ground = false
    self.hasDouble = true
    self.direction = "right"

    self.state = "idle"

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)

    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
 
    self.animation.run = {total = 4, current = 1, img = {}}
    for i=1, self.animation.run.total do
       self.animation.run.img[i] = love.graphics.newImage("assets/player/run/"..i..".png")
    end
 
    self.animation.idle = {total = 16, current = 1, img = {}}

    for i=1, self.animation.idle.total do
       self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
    end
 
    self.animation.air = {total = 4, current = 1, img = {}}
    for i=1, self.animation.air.total do
       self.animation.air.img[i] = love.graphics.newImage("assets/player/air/"..i..".png")
    end
 
    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function player:update(dt)
    self:setState()
    self:setDirection()
    self:animate(dt)
    player:syncPhysics()
    player:move(dt)
    player:applyGravity(dt)
end

function player:setState()
    if not self.ground then 
        self.state = "air"
    elseif self.xv == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
    print(self.state)
end

function player:setDirection()
    if self.xv < 0 then
       self.direction = "left"
    elseif self.xv > 0 then
       self.direction = "right"
    end
 end

function player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
       self.animation.timer = 0
       self:setNewFrame()
    end
 end

function player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
 end

function player:decreaseGraceTime(dt)
    if not self.ground then
        self.graceTime = self.graceTime - dt
    end
end

function player:applyGravity(dt)
    if not self.ground then
        self.yv = self.yv + self.gravity * dt
    end
end 
 
function player:move(dt)
    if love.keyboard.isDown("d", "right") then
       self.xv = math.min(self.xv + self.a * dt, self.maxSpeed)
    elseif love.keyboard.isDown("a", "left") then
       self.xv = math.max(self.xv - self.a * dt, -self.maxSpeed)
    else
       self:applyFriction(dt)
    end
 end

function player:applyFriction(dt)
    if self.xv > 0 then
       if self.xv - self.f * dt > 0 then
          self.xv = self.xv - self.f * dt
       else
          self.xv = 0
       end
    elseif self.xv < 0 then
       if self.xv + self.f * dt < 0 then
          self.xv = self.xv + self.f * dt
       else
          self.xv = 0
       end
    end
end

function player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xv, self.yv)
end

function player:beginContact(a, b, collision)
    if self.ground == true then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yv = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then 
            self.yv = 0
        end
    end
end

function player:land(collision)
    self.currentGroundCollision = collision
    self.yv = 0
    self.ground = true
    self.hasDouble = true
    self.graceTime = self.graceDuration
end

function player:jump(key)
    if (key == 'up' or key == 'w') then
        if self.ground or self.graceTime > 0 then
            self.yv = self.jumpA
            self.graceTime = 0
        elseif self.hasDouble then
            self.hasDouble = false
            self.yv = self.jumpA * 0.9
        end
    end
end

function player:endContact(a, b, collision)
    if a == self.physics.fixture or  b == self.physics.fixture then 
        if self.currentGroundCollision == collision then
            self.ground = false
        end
    end
end

function player:draw()
    local scaleX =  1.5
    if self.direction == "left" then
        scaleX = -1.5
    end
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1.5, self.animation.width / 1.7, self.animation.height / 1.7)
end
