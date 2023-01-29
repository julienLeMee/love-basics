function love.load()
  anim8 = require 'libraries/anim8'
  love.graphics.setDefaultFilter("nearest", "nearest")

  player = {}
  player.x = 400
  player.y = 200
  player.speed = 1

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
end

function love.update(dt)
  local isMoving = false

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

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  player.anim:update(dt)
end

function love.draw()
  for i = 0, love.graphics.getWidth(), floor2:getWidth() do
    for j = 0, love.graphics.getHeight(), floor2:getHeight() do
      love.graphics.draw(floor2, i, j)
    end
  end
  player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, 2)
end
