local LevelInformation = class("LevelScene", function(levelNumber)
	local levelData = {}
	levelData = GameData
	-- dump(levelData)
	
    local levelinformation = {}
    levelinformation.levelNumber = levelNumber
    levelinformation.medal = levelData[tostring(levelNumber)].medal
    levelinformation.PosX = levelData[tostring(levelNumber)].x
    levelinformation.PosY = levelData[tostring(levelNumber)].y

    return levelinformation
end)

function LevelInformation:ctor()
	self.levelimage = self:levelSprite()
end
function LevelInformation:levelSprite()
--	local levelSprite
	local image 
	
	if self.medal == 1 then
		image = {
			normal = "game/stagebutton-sheet0_13.png"
		}
	--	levelSprite = display.newSprite("game/stagebutton-sheet0_13.png")
	elseif self.medal == 2 then
		image = {normal = "game/stagebutton-sheet0_14.png"}
		--levelSprite = display.newSprite("game/stagebutton-sheet0_14.png")
	elseif  self.medal == 0 then
		image = {normal = "game/stagebutton-sheet0_02.png"}
		--levelSprite = display.newSprite("game/stagebutton-sheet0_02.png")
	else
		image = {normal = "game/stagebutton-sheet0_12.png"}
		--levelSprite = display.newSprite("game/stagebutton-sheet0_12.png")
	end

	 return image

end



return LevelInformation
