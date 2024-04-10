import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

Tools = {}
Tools.__index = Tools

function Tools:new()
	local self = {}
	
	function self:removeFromList(list, value)
		for i = #list, 1, -1 do
			if list[i] == value then
				table.remove(list, i)
			end
		end
	end
	
	function self:isInList(list, value)
	 	for i = #list, 1, -1 do
		 	if list[i] == value then
			 	return true
		 	end
	 	end
	 	return false
	end
	
	function self:isPosInList(list, value)
		 for i = #list, 1, -1 do
			 if list[i][1] == value[1] and list[i][2] == value[2] then
				 return true
			 end
		 end
		 return false
	end
	
	function self:removeAllTimers()
		timers = playdate.timer.allTimers()
		for i = 1, #timers do
			timers[i]:remove()
		end
	end
	return self
end
