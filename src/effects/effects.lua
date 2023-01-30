effects = {}

function effects:spawn(type, x, y, args)

    local effect = {}
    effect.x = x
    effect.y = y
    effect.rot = 0
    effect.dead = false
    effect.scaleX = 1
    effect.scaleY = 1
    effect.layer = 1
    effect.type = type

    if type == "slice" then
        effect.spriteSheet = love.graphics.newImage("sprites/slash-effect-right.png")
        effect.width = 23
        effect.height = 39
        effect.grid = anim8.newGrid(16, 16, effect.spriteSheet:getWidth(), effect.spriteSheet:getHeight())
        effect.anim = anim8.newAnimation(effect.grid('1-3', 1), 0.2, function() effect.dead = true end)
        effect.rot = 0
        effect.layer = 0

        if args then
            effect.rot = math.atan2(args.y, args.x)
            if player.comboCount % 2 == 0 then
                effect.scaleY = -1
            end
        end

        effect.x = effect.x + args.x*11
        effect.y = effect.y + args.y*11

        table.insert(effects, effect)

        if player.dir == "down" then
            effect.x = effect.x + 1
            effect.y = effect.y + 13.5
            effect.rot = math.pi/2
        elseif player.dir == "up" then
            effect.x = effect.x - 1
            effect.y = effect.y - 9.5
            effect.rot = math.pi/-2
        elseif player.dir == "right" then
            effect.x = effect.x + 13.5
            effect.y = effect.y - 2
        elseif player.dir == "left" then
            effect.x = effect.x - 13.5
            effect.y = effect.y - 2
            effect.scaleX = -1
        end
      end

      function effects:update(dt)
        for _,e in ipairs(effects) do
            if e.anim then
                e.anim:update(dt)
            end

            if e.update then
                e:update(dt)
            end
        end

        local i = #effects
        while i > 0 do
            if effects[i].dead then
                table.remove(effects, i)
            end
            i = i - 1
        end
    end

    function effects:draw(layer)
        for _,e in ipairs(effects) do
            if e.layer == layer then
                if e.anim then
                    if e.alpha then love.graphics.setColor(1,1,1,e.alpha) end
                    e.anim:draw(e.spriteSheet, e.x, e.y, e.rot, e.scaleX, e.scaleY, e.width/2, e.height/2)
                end
                if e.draw then
                    e:draw()
                end
            end
        end
    end
  end
