import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'board'
import 'cursor'
import 'tools'

local gfx <const> = playdate.graphics
score = 0

gameState = 2
movingPositions = {}

function setup()
    math.randomseed(playdate.getSecondsSinceEpoch())

    font = gfx.font.new('Font/dpaint_8')
    gfx.setFont(font)

    cursor = Cursor:new()
    cursor:moveTo(98, 30)
    cursor:addSprite()

    board = Board:new()
    gem = Gem:new()
    tools = Tools:new()
    -- 28x28px size for gems

    local backgroundImage = gfx.image.new('Images/background.png')
    assert(backgroundImage)
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
            backgroundImage:draw( 0, 0 )
            gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
        end
    )
    --initial board population
    board:populateBoard()
    board:drawGemsOnBoard()

end

setup()

function printPos(pos)
    print(pos[1] .. ',' .. pos[2])
end

function playdate.update()

    if gameState == 1 then
        --display the start screen&menu
    elseif gameState == 2 then
        if playdate.buttonJustPressed(playdate.kButtonA) then
            cursor.grabbed = 1
            tempPos = {cursor.position[1], cursor.position[2]}
        end

        if playdate.buttonJustPressed(playdate.kButtonB) then
            cursor.grabbed = 0
        end
        
        gemMove(tempPos)
        matches,specialGem,special = board:checkForMatches()
        
        
        if matches ~= nil then
            processMatches(newPos, initialPos)
            -- logic for creating special gems
            if specialGem ~= "none" then
                --arbitrarily set the special gem to spawn at the position of the 3rd element in the match? who cares!
                board:setGemAtPosition(specialGem, matches[3])
            end
            -- run logic for using special gems
            if special ~= nil and #special ~= 0 then 
                chainReactions = processSpecials(special,matches[3])
                special = ""
                if chainReactions ~= nil then
                    for i=1,#chainReactions do
                        if string.match(chainReactions[i][2],"P") then
                           special = special.."P" 
                        end
                        if string.match(chainReactions[i][2],"S") then
                           special = special.."S" 
                        end
                    end
                end
                
                while string.match(special, "S") or string.match(special,"P") do
                    chainReactions = processSpecials(special, chainReactions[1][1])
                    special = ""
                    if chainReactions == nil then break end
                    for i=1,#chainReactions do
                        if string.match(chainReactions[i][2],"P") then
                           special = special.."P" 
                        end
                        if string.match(chainReactions[i][2],"S") then
                           special = special.."S" 
                        end
                    end
                end
            end
            tools:removeAllTimers()
            playdate.timer.updateTimers()
            board:cascadeGemsAfterMatch()
            board:fillEmptySpaces()
            board:drawGemsOnBoard()
        end
    elseif gameState == 3 then
        --game over
    end
    
    gfx.sprite.update()
    debug()
    playdate.timer.updateTimers()
end

function processMatches(newPos, initialPos)
    for i, match in ipairs(matches) do
        board:setGemAtPosition(0, match)
    end

    board:drawGemsOnBoard()
    movingPositions = {}
end

function processChainReaction(tempPos, chainReactions)
    if string.match(board:getGemFromPosition(tempPos),"P") then
       table.insert(chainReactions,{tempPos,"P"})
    end
    if string.match(board:getGemFromPosition(tempPos),"S") then
        table.insert(chainReactions,{tempPos,"S"})
    end
    board:setGemAtPosition(0, tempPos)
    scoreMod += 0.03
end

function processSpecials(specialString,pos)
    scoreMod = 0.00
    chainReactions = {}
    for i = 1, #specialString do
        local char = specialString:sub(i,i)
        
        if char == "P" then
            -- top row
            if pos[1]-1 >= 1 then
                if pos[2]-1 >= 1 then
                    tempPos = {pos[1]-1,pos[2]-1}
                    processChainReaction(tempPos, chainReactions)
                end
                if pos[2]+1 <= 8 then
                    tempPos = {pos[1]-1,pos[2]+1}
                    processChainReaction(tempPos, chainReactions)
                end
                tempPos = {pos[1]-1,pos[2]}
                processChainReaction(tempPos, chainReactions)
            end
            
            -- bottom row
            if pos[1]+1 <= 8 then
                if pos[2]-1 >= 1 then
                    tempPos = {pos[1]+1,pos[2]-1}
                    processChainReaction(tempPos, chainReactions)
                end
                if pos[2]+1 <= 8 then
                    tempPos = {pos[1]+1,pos[2]+1}
                    processChainReaction(tempPos, chainReactions)
                end
                tempPos = {pos[1]+1,pos[2]}
                processChainReaction(tempPos, chainReactions)
            end
            
            -- middle row
            if pos[2]-1 >= 1 then
                tempPos = {pos[1],pos[2]-1}
                processChainReaction(tempPos, chainReactions)
            end
            if pos[2]+1 <= 8 then
                tempPos = {pos[1],pos[2]+1}
                processChainReaction(tempPos, chainReactions)
            end
            processChainReaction(pos, chainReactions)
            score += 2400 * scoreMod
            score = math.floor(score)
            return chainReactions
        elseif char == "S" then
            for i=1, 8 do
                board:setGemAtPosition(0, {pos[1],i})
                board:setGemAtPosition(0, {i,pos[1]})
            end
            score += 5000
            return chainReactions
        end
    end
end

function processGemMove(newPos, initialPos)
    if not tools:isPosInList(movingPositions, newPos) then
        board:swapValues(initialPos, newPos)
        board:drawGemsOnBoard()
        table.insert(movingPositions, initialPos)
        table.insert(movingPositions, newPos)
        
        playdate.timer.performAfterDelay(2000, processGemMoveAfter, newPos, initialPos)
    end
end

function processGemMoveAfter(newPos, initialPos)
    board:swapValues(initialPos, newPos)
    board:drawGemsOnBoard()
    tools:removeFromList(movingPositions, initialPos)
    tools:removeFromList(movingPositions, newPos)
end

function gemMove(initialPos)
    if tools:isPosInList(movingPositions, initialPos) then
        cursor.grabbed = 0
    end
    
    if cursor.grabbed == 1 then
        if playdate.buttonJustPressed(playdate.kButtonDown) then
            if initialPos[2] < 8 then
                newPos = {cursor.position[1],cursor.position[2]+1}
                processGemMove(newPos, initialPos)
            end
            cursor.grabbed = 0
        end
    
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            if initialPos[2] > 1 then
                newPos = {cursor.position[1],cursor.position[2]-1}
                processGemMove(newPos, initialPos)
            end
            cursor.grabbed = 0
        end

        if playdate.buttonJustPressed(playdate.kButtonLeft) then
            if initialPos[1] > 1 then
                newPos = {cursor.position[1]-1,cursor.position[2]}
                processGemMove(newPos, initialPos)
            end
            cursor.grabbed = 0
        end

        if playdate.buttonJustPressed(playdate.kButtonRight) then
            if initialPos[1] < 8 then
                newPos = {cursor.position[1]+1,cursor.position[2]}
                processGemMove(newPos, initialPos)
            end
            cursor.grabbed = 0
        end
    end
end

function debug()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('pos', 28, 50) -- current position
    gfx.drawText('[' .. tostring(cursor.position[1]) .. ',' .. tostring(cursor.position[2]) .. ']',26, 60)
    board:printBoardToScreen()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    --log if we are grabbing a gem or not
    gfx.drawText(cursor.grabbed, 28, 200)
    
    --temporarily show score like this....
    --TODO: add this to GUI
    gfx.drawText("score", 340, 10)
    gfx.drawText(score, 350, 20)
    
    -- log the moving gems on the screen
    startY = 20
    for i = #movingPositions, 1, -1 do
        gfx.drawText(movingPositions[i][1] .. ',' .. movingPositions[i][2], 320, startY)
        startY += 10
    end
end