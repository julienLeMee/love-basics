-- local Enemy = require "objects/Enemy"
-- local enemies = {}
local bats = {}

function love.load()


  -- COMMAND INFOS
  text = " f = fullscreen, q = quit, space = attack, arrow keys = move "

  -- CAMERA
  camera = require 'libraries/camera'
  -- cam = camera(400, 300)
  cam = camera(400, 300, 3, 0) -- (x, y, zoom, rotation)

  -- COLLIDER
  wf = require 'libraries/windfield'
  world = wf.newWorld(0, 0)

  -- ANIM
  anim8 = require 'libraries/anim8'
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- MAP
  sti = require "libraries/sti"
  -- gameMap = sti("maps/medusaMap.lua")
  gameMap = sti("maps/newMapMedusa.lua")

  -- SOUNDS
  sounds = {}
  sounds.blip = love.audio.newSource("sounds/blip.wav", "static")
  sounds.music = love.audio.newSource("sounds/music.mp3", "stream")
  sounds.music:setLooping(true)

  sounds.music:play()

  -- PLAYER
  player = {}
  player.x = 20
  player.y = 400
  player.collider = world:newBSGRectangleCollider(20, 400, 10, 15, 1) -- (x, y, width, height, mass)
  player.collider:setFixedRotation(true)
  player.radius = 10
  player.speed = 70
  player.life = 10
  player.dir = "down"

  player.spriteSheet = love.graphics.newImage("sprites/player-sheet.png")
  player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

  player.animation = {}
  player.animation.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
  player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
  player.animation.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
  player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

  player.anim = player.animation.down

  -- ATTACK
  attack = {}
  attack.spriteSheet = love.graphics.newImage("sprites/slash2.png")
  attack.grid = anim8.newGrid(16, 16, attack.spriteSheet:getWidth(), attack.spriteSheet:getHeight())

  attack.animation = {}
  attack.animation.right = anim8.newAnimation(attack.grid('1-4', 1), 0.2)

  attack.anim = attack.animation.right


  -- BAT ENEMY

  for i = 1, 10 do
    bat = {}
    bat.x = love.math.random(0, 1200)
    bat.y = love.math.random(0, 1200)
    bat.life = 10
    bat.speed = 20
    bat.spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet.png")
    bat.grid = anim8.newGrid(16, 16, bat.spriteSheet:getWidth(), bat.spriteSheet:getHeight())

    bat.animation = {}
    bat.animation.right = anim8.newAnimation(bat.grid('1-4', 1), 0.2)

    bat.anim = bat.animation.right

    table.insert(bats, i, bat)
  end

  -- WALL
  walls = {}
  if gameMap.layers["walls"] then
    for i, obj in pairs(gameMap.layers["walls"].objects) do
      local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height) -- (x, y, width, height, mass)
      wall:setType("static")
      table.insert(walls, wall)
    end
  end

    -- QUERY
    button = world:newRectangleCollider(10, 350, 20, 20)
    world:addCollisionClass('Player')
    player.collider:setCollisionClass("Player")

    world:addCollisionClass('Button')
    button:setCollisionClass("Button")


  end

  -- QUERY
function love.keypressed(key)
 if key == 'a' then
   local px, py = player.collider:getPosition()
   local colliders = world:queryCircleArea(px, py, 8, {'Button'})
   if #colliders > 0 then
     player.life = player.life + 1
   end
 end
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
    player.dir = "right"
  end

  if love.keyboard.isDown("left") then
    velocityX = -player.speed
    player.anim = player.animation.left
    isMoving = true
    player.dir = "left"
  end

  if love.keyboard.isDown("down") then
    velocityY = player.speed
    player.anim = player.animation.down
    isMoving = true
    player.dir = "down"
  end

  if love.keyboard.isDown("up") then
    velocityY = -player.speed
    player.anim = player.animation.up
    isMoving = true
    player.dir = "up"
  end

  player.collider:setLinearVelocity(velocityX, velocityY)

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  -- PLAYER ATTACK

  if love.keyboard.isDown("space") then
    attack.anim:update(dt)
    isAttack = true
  end

  if isAttack == false then
    attack.anim:gotoFrame(4)
  end

  -- UPDATE

  gameMap:update(dt)
  world:update(dt)
  player.anim:update(dt)
  attack.anim:update(dt)
  for i = 1, #bats do
    bats[i].anim:update(dt)
  end
  player.x = (player.collider:getX()) - 6
  player.y = (player.collider:getY()) - 9

   -- bat move
  for i = #bats, 1, -1 do
    if bats[i].life <= 0 then
      table.remove(bats, i)
    else
      if bats[i].x < player.x then
        bats[i].x = bats[i].x + 0.1
      end

      if bats[i].y < player.y then
        bats[i].y = bats[i].y + 0.1
      end

      if bats[i].x > player.x then
        bats[i].x = bats[i].x - 0.1
      end

      if bats[i].y > player.y then
        bats[i].y = bats[i].y - 0.1
      end
    end
  end

  cam:lookAt(player.x, player.y)

  -- knock back
  for i = 1, #bats do
    if bats[i].x < player.x + 20 and bats[i].x > player.x - 20 and bats[i].y < player.y + 20 and bats[i].y > player.y - 20 then
      if love.keyboard.isDown("space") then
        if player.dir == "left" then
          sounds.blip:play()
          bats[i].x = bats[i].x - 100
          bats[i].life = bats[i].life - 1
        elseif player.dir == "down" then
          sounds.blip:play()
          bats[i].y = player.y + 100
          bats[i].life = bats[i].life - 1
        elseif player.dir == "up" then
          sounds.blip:play()
          bats[i].y = player.y - 100
          bats[i].life = bats[i].life - 1
        elseif player.dir == "right" then
          sounds.blip:play()
          bats[i].x = bats[i].x + 100
          bats[i].life = bats[i].life - 1
        end
        attack.anim:draw(attack.spriteSheet, player.x + 30, player.y, getRadianRotation(player.dir), 1, 1)
      end
    else
      bats[i].spriteSheet = love.graphics.newImage("sprites/bat_anim_spritesheet.png")
    end
  end

end

function love.draw()

  cam:attach()
    -- MAP
    -- Map:draw(tx, ty, sx, sy)
    gameMap:drawLayer(gameMap.layers["ground"])
    gameMap:drawLayer(gameMap.layers["stone"])
    gameMap:drawLayer(gameMap.layers["house"])
    gameMap:drawLayer(gameMap.layers["object"])

    -- PLAYER
    -- Player:draw(spriteSheet, x, y, r, sx, sy)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1)

    -- ATTACK
    -- attack.anim:draw(attack.spriteSheet, player.x, player.y, rotation,scaling?, scaling?)
    if player.dir == "left" then
      attack.anim:draw(attack.spriteSheet, player.x - 2, player.y + 15, getRadianRotation(player.dir), 1, 1)
    elseif player.dir == "down" then
        attack.anim:draw(attack.spriteSheet, player.x + 15, player.y + 15, getRadianRotation(player.dir), 1, 1)
    elseif player.dir == "up" then
        attack.anim:draw(attack.spriteSheet, player.x - 2, player.y, getRadianRotation(player.dir), 1, 1)
    elseif player.dir == "right" then
        attack.anim:draw(attack.spriteSheet, player.x + 15, player.y, getRadianRotation(player.dir), 1, 1)
    end

    -- BAT
    for i = 1, #bats do
      bats[i].anim:draw(bats[i].spriteSheet, bats[i].x, bats[i].y, nil, 1, 1)
      love.graphics.rectangle("fill", bats[i].x + 3, bats[i].y - 3, bats[i].life, 0.5)
      -- love.graphics.print(bats[i].life, bats[i].x, bats[i].y - 20)
    end

    -- COLLIDER
    world:draw()

    cam:detach()

    -- COMMAND INFOS
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 35) -- x, y, width, height
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(text, 0, 10, love.graphics.getWidth(), "center")
    love.graphics.print("Life: " .. player.life, 10, 10)
    love.graphics.print("Enemies: " .. #bats, love.graphics.getWidth() - 100, 10)

end

function getRadianRotation(direction)

  if direction == "right" then
      return 0
  elseif direction == "left" then
      return math.pi
  elseif direction == "up" then
      return (math.pi/2) * 3
  elseif direction == "down" then
      return math.pi/2
  else
      return 0
  end

end
