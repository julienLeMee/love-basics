local love = require "love"

function Enemy()
    local dice = math.random(1, 4)
    local enemy_x, enemy_y
    local _radius = 10
    -- ajouter une varible pour la vie de l'ennemi:
    local _life = 10

    if dice == 1 then -- come from above --
        enemy_x = math.random(_radius, love.graphics.getWidth())
        enemy_y = -_radius * 4
    elseif dice == 2 then -- come from the left --
        enemy_x = -_radius * 4
        enemy_y = math.random(_radius, love.graphics.getHeight())
    elseif dice == 3 then -- come from the bottom --
        enemy_x = math.random(_radius, love.graphics.getWidth())
        enemy_y = love.graphics.getHeight() + (_radius * 4)
    else -- come from the right --
        enemy_x = love.graphics.getWidth() + (_radius * 4)
        enemy_y = math.random(_radius, love.graphics.getHeight())
    end

    return {
        level = 0.5,
        radius = _radius,
        x = enemy_x,
        y = enemy_y,
        life = _life,

        move = function (self, player_x, player_y)
            if player_x - self.x > 0 then
                self.x = self.x + self.level
            elseif player_x - self.x < 0 then
                self.x = self.x - self.level
            end

            if player_y - self.y > 0 then
                self.y = self.y + self.level
            elseif player_y - self.y < 0 then
                self.y = self.y - self.level
            end
        end,

        draw = function (self)
            love.graphics.setColor(1, 0.5, 0.7)
            love.graphics.circle("fill", self.x, self.y, self.radius)

            love.graphics.setColor(1, 1, 1)
        end,
    }
end

return Enemy
