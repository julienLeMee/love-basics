local Enemy = require "objects/Enemy"
local enemies = {}

function love.load()
  anim8 = require 'libraries/anim8'
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- PLAYER
  player = {}
  player.x = 400
  player.y = 200
  player.radius = 10
  player.speed = 1

  attack = {}

  -- floor1 = love.graphics.newImage("sprites/floor_1.png")
  floor2 = love.graphics.newImage("sprites/floor_3.png")
  -- floor3 = love.graphics.newImage("sprites/floor_6.png")
  -- floor4 = love.graphics.newImage("sprites/floor_7.png")
  -- floor5 = love.graphics.newImage("sprites/floor_8.png")

  player.spriteSheet = love.graphics.newImage("sprites/player-sheet.png")
  player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

  player.animation = {}
  player.animation.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
  player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
  player.animation.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
  player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

  player.anim = player.animation.up

  -- attack.spriteSheet = love.graphics.newImage("sprites/slash_effect.png")
  -- attack.grid = anim8.newGrid(16, 1, attack.spriteSheet:getWidth(), attack.spriteSheet:getHeight())
  -- attack.animation = {}
  -- attack.animation.down = anim8.newAnimation(attack.grid('1-3', 1), 10)
  -- attack.anim = player.animation.down


  --ENEMY
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())
  table.insert(enemies, 1, Enemy())
end

function love.update(dt)
  local isMoving = false
  -- local isAttack = false

  if love.keyboard.isDown("right") then
      player.x = player.x + player.speed
      player.anim = player.animation.right
      isMoving = true
  end

  if love.keyboard.isDown("left") then
      player.x = player.x - player.speed
      player.anim = player.animation.left
      isMoving = true
  end

  if love.keyboard.isDown("down") then
      player.y = player.y + player.speed
      player.anim = player.animation.down
      isMoving = true
  end

  if love.keyboard.isDown("up") then
      player.y = player.y - player.speed
      player.anim = player.animation.up
      isMoving = true
  end

  if love.keyboard.isDown("space") then
      attack.anim = attack.animation.down
      isAttack = true
  end

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  -- if isAttack == false then
  --   attack.anim:gotoFrame(2)
  -- end

  player.anim:update(dt)
  -- attack.anim:update(dt)

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
  for i = 0, love.graphics.getWidth(), floor2:getWidth() do
    for j = 0, love.graphics.getHeight(), floor2:getHeight() do
      love.graphics.draw(floor2, i, j)
    end
  end
  player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, 2)
  -- attack.anim:draw(player.spriteSheet, (player.x +2), (player.y +2), nil, 2, 2)

  for i = 1, #enemies do
    enemies[i]:draw()
  end
end
