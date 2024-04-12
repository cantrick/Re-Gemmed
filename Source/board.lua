import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'gem'

local gfx <const> = playdate.graphics

Board = {}
Board.__index = Board

function Board:new()
    local self = {}

    self.firstX = 98
    self.firstY = 30

    self.board = {
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0},
    }

    self.COL_COUNT = #self.board[1]
    self.ROW_COUNT= #self.board

    function self:hasMatch()
        --Vertical check
        for i = 1, self.COL_COUNT do
            for j = 1, self.ROW_COUNT-2 do
                if self.board[j][i] == self.board[j+1][i] and self.board[j+1][i] == self.board[j+2][i] then
                    return true
                end
            end
        end

        --Horizontal check
        for i = 1, self.COL_COUNT-2 do
            for j = 1, self.ROW_COUNT do
                if self.board[j][i] == self.board[j][i+1] and self.board[j][i+1] == self.board[j][i+2] then
                    return true
                end
            end
        end
        return false
    end

    -- function self:isValidMove(pos)
    --     local returnValue = false
    --     for i = self.ROW_COUNT, 1, -1 do
    --         if self.board[i][pos] == 0 then
    --             returnValue = true
    --             return returnValue
    --         else
    --             returnValue = false
    --         end
    --     end
    --     return returnValue
    -- end

    function self:getValidMove(pos)
        for i = self.ROW_COUNT, 1, -1 do
            if self.board[i][pos] == 0 then
                return i
            end
        end
    end

    function self:printBoardToScreen()
        local startX = 8
        local startY = 80
        for i = 1, self.COL_COUNT do
            for j = 1, self.ROW_COUNT do
                gfx.drawText(tostring(self.board[i][j]), startX, startY)
                startY += 8
            end

            startY = 80
            startX += 8

        end
    end

    function self:populateBoard()
        while self:hasMatch() do
            for i = 1, self.COL_COUNT do
                for j = 1, self.ROW_COUNT do
                    self.board[i][j] = math.random(1,7)
                end
            end
        end
    end
    --  repurpose to draw gems on board
    function self:drawGemsOnBoard()
        gem:removeAllGems()
        local gemX = self.firstX
        local gemY = self.firstY

        for i = 1, self.COL_COUNT do
            for j = 1, self.ROW_COUNT do
                gem:drawGem(self.board[i][j], gemX, gemY)
                gemY += 28
            end

            gemY = self.firstY
            gemX += 28

        end
    end

    function self:getGemFromPosition(pos)
        return self.board[pos[1]][pos[2]]
    end

    function self:setGemAtPosition(gem, pos)
        print('setgem: '..pos[1]..','..pos[2])
        self.board[pos[1]][pos[2]] = gem
    end
    
    function self:swapValues(initialPos, newPos)
        self.board[initialPos[1]][initialPos[2]], self.board[newPos[1]][newPos[2]] = self.board[newPos[1]][newPos[2]], self.board[initialPos[1]][initialPos[2]]
    end
    
    function self:checkForNumberMatch(num)
        isMatched = 1
        matchedPos = {}
        --horizontal matches
        for col = 1, self.COL_COUNT-(num-1) do
            if isMatched == num then break end
            for row = 1, self.ROW_COUNT do
                toMatch = self.board[col][row]
                table.insert(matchedPos, {col,row})
                for i=1, num-1 do
                    if toMatch == self.board[col+i][row] and toMatch ~= 0 then
                        isMatched += 1
                        table.insert(matchedPos, {col+i,row})   
                    else
                        isMatched = 1
                        matchedPos = {}
                        break
                    end
                end
                if isMatched == num then
                    print("WE MATCH HORIZONTALLY")
                    return matchedPos
                end
            end
        end 

        
        matchedPos={}
        isMatched = 1
        --vertical matches
        for col = 1, self.COL_COUNT do
            if isMatched == num then break end
            for row = 1, self.ROW_COUNT-(num-1) do
                toMatch = self.board[col][row]
                table.insert(matchedPos, {col,row})
                for i=1, num-1 do
                    if toMatch == self.board[col][row+i] and toMatch ~= 0 then
                        isMatched += 1
                        table.insert(matchedPos, {col,row+i})
                    else
                        isMatched = 1
                        matchedPos = {}
                        break
                    end
                end
                if isMatched == num then
                    print("WE MATCH vertically")
                    return matchedPos
                end
            end
        end
         
    end
    
    function self:checkForMatches()
        --check for T match
        --check for L match
        --check for 5 match
        matches = self:checkForNumberMatch(5)
        if matches ~= nil then return matches end
        --check for 4 match
        matches = self:checkForNumberMatch(4)
        if matches ~= nil then return matches end
        --check for 3 match
        matches = self:checkForNumberMatch(3)
        if matches ~= nil then return matches end
        
        return matches
    end
    
    function self:cascadeGemsAfterMatch()
        tempPos = self:checkAboveZero()
        while tempPos ~= 0 do
            self:swapValues({tempPos[1], tempPos[2]}, {tempPos[1], tempPos[2]-1})
            tempPos = self:checkAboveZero()
        end
    end
    
    function self:checkAboveZero()
        for col = 1, self.COL_COUNT do
            for row = 2, self.ROW_COUNT do
                if self.board[col][row-1] ~= 0 and self.board[col][row] == 0 then
                    return {col,row}
                end
            end
        end
        return 0
    end
    
    return self
end