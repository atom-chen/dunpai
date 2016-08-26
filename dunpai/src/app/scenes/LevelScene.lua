local LevelScene = class("LevelScene", function()
    return display.newScene("LevelScene")
end)

local Button = import("app.scenes.Button")

 local LevelInformation = import("app.scenes.LevelInformation")
 display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
 display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")

 local PlayScene = import("app.scenes.PlayScene")

function LevelScene:ctor()
	-- self.levelNumber = {{x = 390,y = 140,medal = 3},{x = 240,y = 140,medal = 0},
	-- 	{x = 140,y = 220,medal = 0},{x = 240,y = 300,medal = 0},{x = 340,y = 360,medal = 0},
	-- 	{x = 310,y = 445,medal = 0},{x = 440,y = 450,medal = 0},{x = 590,y = 420,medal = 0},
	-- 	{x = 480,y = 350,medal = 0},{x = 530,y = 230,medal = 0},{x = 630,y = 140,medal = 0},
	-- 	{x = 715,y = 190,medal = 0},levelCrossNum = 1,maxlevelNum = 12,isMusic = true,isSound = true}
	-- GameState.save(self.levelNumber)
	--  dump(GameData)
	self.levelinfo = {}
	self.levelinfo = GameData
	-- self.levelinfo.levelCrossNum = 5
	-- GameState.save(self.levelinfo)

	self:addLevelBG()
	self:initUI()
end

function LevelScene:addLevelBG()
	print(self.levelinfo.levelCrossNum)
	local levelCrossNum = self.levelinfo.levelCrossNum  --当前已经通过的关卡数

	local levelbgsprite = display.newSprite("game/bglvlselect-sheet0.png")
		:align(display.BOTTOM_LEFT, -self.levelinfo[tostring(levelCrossNum+1)].x, -self.levelinfo[tostring(levelCrossNum+1)].y)
	levelbgsprite:setScale(display.width/levelbgsprite:getContentSize().width * 2,display.height/levelbgsprite:getContentSize().height * 1.7)

	cc.ui.UIScrollView.new({
        direction = cc.ui.UIScrollView.DIRECTION_BOTH,
        viewRect = {x = 0, y = 0, width = display.width, height = display.height}, -- 设置显示区域
    })
   	 :addScrollNode(levelbgsprite)
    	:addTo(self)
   	 :pos(0,0)
   	 :setBounceable(false)


   	
   	if levelCrossNum <= 10 then 
		for i = 0,levelCrossNum do
			local levelinformation = LevelInformation.new(i+1)
			local levelimage = levelinformation.levelimage
			local levelbutton = cc.ui.UIPushButton.new(levelimage)
				:setPosition(cc.p(levelinformation.PosX,levelinformation.PosY))
				:addTo(levelbgsprite)
				:onButtonClicked(function (event)
					local scene = PlayScene.new(i+1)
					display.replaceScene(scene,"fade",0.2)
				end)
			 local sprite1 = display.newSprite("game/stagebutton-sheet0_01.png")
			 	:setPosition(cc.p(self.levelinfo[tostring(levelCrossNum+2)].x,self.levelinfo[tostring(levelCrossNum+2)].y))
			 	:addTo(levelbgsprite)
		end
	elseif levelCrossNum == 11 then
		for i = 0,levelCrossNum do
			local levelinformation = LevelInformation.new(i+1)
			local levelimage = levelinformation.levelimage
			local levelbutton = cc.ui.UIPushButton.new(levelimage)
				:setPosition(cc.p(levelinformation.PosX,levelinformation.PosY))
				:addTo(levelbgsprite)
				:onButtonClicked(function (event)
					local scene = PlayScene.new(i+1)
					display.replaceScene(scene,"fade",0.2)
				end)
		end
	else
		for i = 1,levelCrossNum do
			local levelinformation = LevelInformation.new(i)
			local levelimage = levelinformation.levelimage
			local levelbutton = cc.ui.UIPushButton.new(levelimage)
				:setPosition(cc.p(levelinformation.PosX,levelinformation.PosY))
				:addTo(levelbgsprite)
				:onButtonClicked(function (event)
					local scene = PlayScene.new(i+1)
					display.replaceScene(scene,"fade",0.2)
				end)
		end

	end

 end

function LevelScene:initUI()

		--UIButton
	local button = Button.new()

	local Musicbutton = button:MusicButton()
	Musicbutton:setPosition(cc.p(display.right-80,display.top-25))
	Musicbutton:addTo(self,2)

	local SoundButton = button:SoundButton()
	SoundButton:setPosition(cc.p(display.right-30,display.top-25))
	SoundButton:addTo(self,2)

	local ReturnButton = Button:ReturnButton()
	ReturnButton:setPosition(cc.p(display.left+40,display.top-40))
	ReturnButton:addTo(self,2)



end


function LevelScene:onEnter()
	
end
function LevelScene:onExit()
	
end
return LevelScene