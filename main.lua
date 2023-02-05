local Enemy = require "objects/Enemy"
local enemies = {}

function love.load()
  anim8 = require 'libraries/anim8'
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- MAP
  sti = require "libraries/sti"
  gameMap = sti("maps/medusaMap.lua")

  -- PLAYER
  player = {}
  player.x = 400
  player.y = 200
  player.radius = 10
  player.speed = 1
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
  -- attack.spriteSheet2 = love.graphics.newImage("sprites/effects/slash-effect-left.png")
  -- attack.spriteSheet3 = love.graphics.newImage("sprites/effects/slash-effect-up.png")
  -- attack.spriteSheet4 = love.graphics.newImage("sprites/effects/slash-effect-down.png")
  attack.grid = anim8.newGrid(16, 16, attack.spriteSheet:getWidth(), attack.spriteSheet:getHeight())
  -- attack.grid2 = anim8.newGrid(16, 16, attack.spriteSheet2:getWidth(), attack.spriteSheet2:getHeight())
  -- attack.grid3 = anim8.newGrid(16, 16, attack.spriteSheet3:getWidth(), attack.spriteSheet3:getHeight())
  -- attack.grid4 = anim8.newGrid(16, 16, attack.spriteSheet4:getWidth(), attack.spriteSheet4:getHeight())

  attack.animation = {}
  attack.animation.right = anim8.newAnimation(attack.grid('1-3', 1), 0.2)
  -- attack.animation.left = anim8.newAnimation(attack.grid2('3-1', 1), 0.2)
  -- attack.animation.up = anim8.newAnimation(attack.grid3('1-3', 1), 0.2)
  -- attack.animation.down = anim8.newAnimation(attack.grid4('1-3', 1), 0.2)

  attack.anim = attack.animation.right

  --ENEMY
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())

  -- BAT
  bat = {}
  bat.x = 400
  bat.y = 200
  bat.spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet.png")
  bat.grid = anim8.newGrid(16, 16, bat.spriteSheet:getWidth(), bat.spriteSheet:getHeight())

  bat.animation = {}
  bat.animation.right = anim8.newAnimation(bat.grid('1-4', 1), 0.2)

  bat.anim = bat.animation.right
end

function love.update(dt)

  gameMap:update(dt)

  local isMoving = false
  local isAttack = false

  if love.keyboard.isDown("right") then
      player.x = player.x + player.speed
      player.anim = player.animation.right
      isMoving = true

      -- if love.keyboard.isDown("space") then
      --   attack.anim = attack.animation.right
      --   isAttack = true
      -- end
  end

  if love.keyboard.isDown("left") then
      player.x = player.x - player.speed
      player.anim = player.animation.left
      isMoving = true

      -- if love.keyboard.isDown("space") then
      --   attack.anim = attack.animation.left
      --   isAttack = true
      -- end
  end

  if love.keyboard.isDown("down") then
      player.y = player.y + player.speed
      player.anim = player.animation.down
      isMoving = true

      -- if love.keyboard.isDown("space") then
      --   attack.anim = attack.animation.down
      --   isAttack = true
      -- end
  end

  if love.keyboard.isDown("up") then
      player.y = player.y - player.speed
      player.anim = player.animation.up
      isMoving = true

      -- if love.keyboard.isDown("space") then
      --   attack.anim = attack.animation.up
      --   isAttack = true
      -- end
  end

  if love.keyboard.isDown("space") then
    attack.anim:gotoFrame(1)
    attack.anim:update(dt)
    isAttack = true
  end

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  if isAttack == false then
    attack.anim:gotoFrame(3)
  end

  player.anim:update(dt)
  attack.anim:update(dt)
  bat.anim:update(dt)

  --through window

  --  make sure the ship can't go off screen on x axis
  if player.x + player.radius < 0 then
    player.x = love.graphics.getWidth() + player.radius
  elseif player.x - player.radius > love.graphics.getWidth() then
    player.x = -player.radius
  end

  -- make sure the ship can't go off screen on y axis
  if player.y + player.radius < 0 then
    player.y = love.graphics.getHeight() + player.radius
  elseif player.y - player.radius > love.graphics.getHeight() then
    player.y = -player.radius
  end


  for i = 1, #enemies do
    enemies[i]:move(player.x, player.y)
  end

  

end

function love.draw()
  -- for i = 0, love.graphics.getWidth(), floor:getWidth() do
  --   for j = 0, love.graphics.getHeight(), floor:getHeight() do
  --     love.graphics.draw(floor, i, j)
  --   end
  -- end

  -- MAP
  -- Map:draw(tx, ty, sx, sy)
  gameMap:draw(80, 8, 2, 2)

  player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, 2)

  attack.anim:draw(attack.spriteSheet, player.x, player.y, nil, 2, 2)

  bat.anim:draw(bat.spriteSheet, 100, 100, nil, 2, 2)


  for i = 1, #enemies do
    enemies[i]:draw()
  end
end
