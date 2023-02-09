-- local Enemy = require "objects/Enemy"
-- local enemies = {}
local bats = {}

function love.load()

  -- PARTICLE
  -- local img = love.graphics.newImage("sprites/particles.png")
  -- pSystem = love.graphics.newParticleSystem(img, 32)
  -- pSystem:setParticleLifetime(1,5)
  -- pSystem:setLinearAcceleration(-20, -20, 20, 20)
  -- pSystem:setSpeed(20)
  -- -- pSystem:setRotation(10,20)
  -- pSystem:setSpin(20, 50)

  -- COMMAND INFOS
  text = " f = fullscreen, q = quit, space = attack, arrow keys = move "

  -- CAMERA
  camera = require 'libraries/camera'
  -- cam = camera(400, 300)
  cam = camera()

  -- COLLIDER
  wf = require 'libraries/windfield'
  world = wf.newWorld(0, 0)

  -- ANIM
  anim8 = require 'libraries/anim8'
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- MAP
  sti = require "libraries/sti"
  -- gameMap = sti("maps/medusaMap.lua")
  gameMap = sti("maps/testMap.lua")

  -- SOUNDS
  sounds = {}
  sounds.blip = love.audio.newSource("sounds/blip.wav", "static")
  sounds.music = love.audio.newSource("sounds/music.mp3", "stream")
  sounds.music:setLooping(true)

  sounds.music:play()

  -- PLAYER
  player = {}
  player.x = 400
  player.y = 200
  player.collider = world:newBSGRectangleCollider(400, 200, 22, 33, 20) -- (x, y, width, height, mass)
  player.collider:setFixedRotation(true)
  player.radius = 10
  player.speed = 200
  player.life = 10

  player.spriteSheet = love.graphics.newImage("sprites/player-sheet.png")
  player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

  player.animation = {}
  player.animation.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
  player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
  player.animation.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
  player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

  player.anim = player.animation.up

  -- ATTACK
  attack = {}
  attack.spriteSheet = love.graphics.newImage("sprites/effects/slash-effect-right.png")
  attack.grid = anim8.newGrid(16, 16, attack.spriteSheet:getWidth(), attack.spriteSheet:getHeight())

  attack.animation = {}
  attack.animation.right = anim8.newAnimation(attack.grid('1-3', 1), 0.2)

  attack.anim = attack.animation.right

  --ENEMY
  -- table.insert(enemies, 1, Enemy())
  -- table.insert(enemies, 1, Enemy())
  -- table.insert(enemies, 1, Enemy())
  -- table.insert(enemies, 1, Enemy())

  -- BAT

  for i = 1, 10 do
    bat = {}
    bat.x = love.math.random(0, 800)
    bat.y = love.math.random(0, 800)
    -- bat.collider = world:newBSGRectangleCollider(bat.x, bat.y, 22, 33, 20) -- (x, y, width, height, mass)
    -- bat.collider:setFixedRotation(true)
    bat.spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet.png")
    bat.grid = anim8.newGrid(16, 16, bat.spriteSheet:getWidth(), bat.spriteSheet:getHeight())

    bat.animation = {}
    bat.animation.right = anim8.newAnimation(bat.grid('1-4', 1), 0.2)

    bat.anim = bat.animation.right

    table.insert(bats, i, bat)
  end

  -- WALL
  walls = {}
  if gameMap.layers["Walls"] then
    for i, obj in pairs(gameMap.layers["Walls"].objects) do
      local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height) -- (x, y, width, height, mass)
      wall:setType("static")
      table.insert(walls, wall)
    end
  end

  -- local wall = world:newRectangleCollider(100, 200, 120, 300) -- (x, y, width, height)
  -- wall:setType("static")
end

function love.update(dt)

  if love.keyboard.isDown("f") then
    love.window.setFullscreen(true, "desktop")
  elseif love.keyboard.isDown("q") then
    love.window.setFullscreen(false, "desktop")
  end

  local isMoving = false
  local isAttack = false

  -- PLAYER MOVE

  -- velocity
  local velocityX = 0
  local velocityY = 0

  if love.keyboard.isDown("right") then
    velocityX = player.speed
    player.anim = player.animation.right
    isMoving = true
  end

  if love.keyboard.isDown("left") then
    velocityX = -player.speed
    player.anim = player.animation.left
    isMoving = true
  end

  if love.keyboard.isDown("down") then
    velocityY = player.speed
    player.anim = player.animation.down
    isMoving = true
  end

  if love.keyboard.isDown("up") then
    velocityY = -player.speed
    player.anim = player.animation.up
    isMoving = true
  end

  player.collider:setLinearVelocity(velocityX, velocityY)

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  -- PLAYER ATTACK

  if love.keyboard.isDown("space") then
    sounds.blip:play()
    attack.anim:gotoFrame(1)
    attack.anim:update(dt)
    isAttack = true
  end

  if isAttack == false then
    attack.anim:gotoFrame(3)
  end

 -- PARTICLE EFFECT
  -- if love.keyboard.isDown("s") then
  --   pSystem:emit(32)
  -- end
  -- pSystem:update(dt)

  -- UPDATE

  gameMap:update(dt)
  world:update(dt)
  player.anim:update(dt)
  attack.anim:update(dt)
  for i = 1, #bats do
    bats[i].anim:update(dt)
  end
  player.x = (player.collider:getX()) - 12
  player.y = (player.collider:getY()) - 18

  -- bat move
  for i = 1, #bats do
    if bats[i].x < player.x then
      bats[i].x = bats[i].x + 0.3
    end

    if bats[i].y < player.y then
      bats[i].y = bats[i].y + 0.3
    end

    if bats[i].x > player.x then
      bats[i].x = bats[i].x - 0.3
    end

    if bats[i].y > player.y then
      bats[i].y = bats[i].y - 0.3
    end
  end

  -- BATS COLLIDER
  -- for i = 1, #bats do
  --   bat = bats[i]
  --   bat.x = (bat.collider:getX()) - 16
  --   bat.y = (bat.collider:getY()) - 16
  -- end

  cam:lookAt(player.x, player.y)

  --through window

  -- --  make sure the ship can't go off screen on x axis
  -- if player.x + player.radius < 0 then
  --   player.x = love.graphics.getWidth() + player.radius
  -- elseif player.x - player.radius > love.graphics.getWidth() then
  --   player.x = -player.radius
  -- end

  -- -- make sure the ship can't go off screen on y axis
  -- if player.y + player.radius < 0 then
  --   player.y = love.graphics.getHeight() + player.radius
  -- elseif player.y - player.radius > love.graphics.getHeight() then
  --   player.y = -player.radius
  -- end


  -- for i = 1, #enemies do
  --   enemies[i]:move(player.x, player.y)
  -- end


  -- knock back
  for i = 1, #bats do
    local bat = bats[i]
    if bat.x < player.x + 10 and bat.x > player.x - 10 and bat.y < player.y + 10 and bat.y > player.y - 10 then
      if love.keyboard.isDown("space") then
      bat.x = player.x - 25
      bat.y = player.y - 25
      bat.spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet2.png")
      end
    else
      bat.spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet.png")
    end
  end

  -- love.mousePressed()

end

function love.draw()

  cam:attach()
    -- MAP
    -- Map:draw(tx, ty, sx, sy)
    gameMap:drawLayer(gameMap.layers["Ground"])
    gameMap:drawLayer(gameMap.layers["Trees"])

    -- PLAYER
    -- Player:draw(spriteSheet, x, y, r, sx, sy)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, 2)
    attack.anim:draw(attack.spriteSheet, player.x + 10, player.y, nil, 2, 2)

    -- BAT
    -- bat.anim:draw(bat.spriteSheet, bat.x, bat.y, nil, 2, 2)
    for i = 1, #bats do
      bats[i].anim:draw(bats[i].spriteSheet, bats[i].x, bats[i].y, nil, 2, 2)
    end

    -- COLLIDER
    -- world:draw()

    -- for i = 1, #enemies do
    --   enemies[i]:draw()
    -- end
    cam:detach()

    -- COMMAND INFOS
    love.graphics.printf(text, 0, 0, love.graphics.getWidth(), "center")

    -- PARTICLES
    -- love.graphics.draw(pSystem, love.mouse.getX(), love.mouse.getY())
end

-- function love.mousePressed()
--   --this checks if you are left clicking, and if you are it runs the code under it
--   if love.mouse.isDown(1) then
--     --this says if the user is left clicking then emit 32 particles and since the particles are drawn where the mouse is they come out of the mouse
--     pSystem:emit(32)
--   end
-- end
