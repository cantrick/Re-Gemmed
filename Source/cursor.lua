import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'board'

local gfx <const> = playdate.graphics

Cursor = {}
Cursor.__index = Cursor

function Cursor:new()
    local cursorImage = gfx.image.new("Images/cursor2.png")
    local self = gfx.sprite.new(cursorImage)
    self.position = {1,1}
    self.grabbed = 0

    function self:update(gameState)
        -- TODO: add condition in each movement for moving grabbed gem?
        if playdate.buttonJustPressed(playdate.kButtonDown) and self.y < 226 then
            self:moveBy(0, 28)
            self.position[2] += 1
        end
    
        if playdate.buttonJustPressed(playdate.kButtonUp) and self.y > 30 then
            self:moveBy(0, -28)
            self.position[2] -= 1
        end

        if playdate.buttonJustPressed(playdate.kButtonLeft) and self.x > 98 then
            self:moveBy(-28, 0)
            self.position[1] -= 1
        end

        if playdate.buttonJustPressed(playdate.kButtonRight) and self.x < 294 then
            self:moveBy(28, 0)
            self.position[1] += 1
        end
    end

    return self
end