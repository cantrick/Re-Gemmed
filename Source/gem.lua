import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

local gfx <const> = playdate.graphics

Gem = {}
Gem.__index = Gem

function Gem:new()
    local self = {}
    self.allGems = {}

    function self:drawGem(type, x, y)
        sprite = gfx.sprite.new(gfx.image.new("Images/gem"..type..".png"))
        table.insert(self.allGems, sprite)
        sprite:moveTo(x,y)
        sprite:addSprite()
    end

    function self:removeAllGems()
        for i = 1, #self.allGems do
            gfx.sprite.remove(self.allGems[i])
        end
    end

    return self
end
