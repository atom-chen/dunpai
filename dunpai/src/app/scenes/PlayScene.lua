
Hero = import("app.scenes.Hero").new()

local PlayScene = class("PlayScene", function()
    return display.newPhysicsScene("PlayScene")
end)

 local Monsters = import("app.scenes.Monsters")
 display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
 display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")

function PlayScene:ctor()
	self.hero = nil
	self.pos1 = nil
	self.map = nil
	self.cameramove = false
	self.moveleft = false
	self.moveright = false
	self.hero = nil
	self.MonsterTable = {}

	
	self:getPhysicsWorld():setGravity(cc.p(0,-1000))
	self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	self:initUI()
	self:Schedule()
	self:scheduleUpdate()
	self:Touch()
end

function PlayScene:initUI()



	--physics Box
	local sizeX = display.width*1.6
	local sizeY = display.height*1.6
	local size = cc.size(sizeX,sizeY)
	local body = cc.PhysicsBody:createEdgeBox(size, cc.PHYSICSBODY_MATERIAL_DEFAULT, 3)

	local edgeNode = display.newNode()
	edgeNode:setPosition(size.width / 2, size.height / 2)
	edgeNode:setPhysicsBody(body)
	self:addChild(edgeNode)


	--banfground pictrue
	local bg = display.newSprite("game/backgroundforest-sheet0.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)
	bg:setScaleY(1.5)
	bg:setScaleX(2.6)
	--
	self.map = cc.TMXTiledMap:create("game/level2.tmx")
	self.map:setScale(1.6)
	self:addChild(self.map)
	-- dump(self.map)
	--
	self.hero = Hero.new()
	self:addChild(self.hero)
	self.pos1 = cc.p(self.hero:getPosition())

	local wallArray = self.map:getObjectGroup("wall"):getObjects()

	for i = 1,#wallArray do
		for j = 1,#wallArray[i].polylinePoints-1 do
			local point1 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j].x)*1.6,(wallArray[i].y - wallArray[i].polylinePoints[j].y)*1.6)
			local point2 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j+1].x) * 1.6,(wallArray[i].y - wallArray[i].polylinePoints[j+1].y)*1.6)
			local wallbody = cc.PhysicsBody:createEdgeSegment(point1,point2,cc.PhysicsMaterial(1.5,0,10))
 			local node = display.newNode()
			:setCameraMask(cc.CameraFlag.USER2)
	 		:setPhysicsBody(wallbody)
	 		:addTo(self)
		end
	end


	


	--Monster
	self.MonsterP = self.map:getObjectGroup("Monster"):getObjects()
	--dump(MonsterP)
	for i=1,#self.MonsterP do
		local Monster = Monsters.new(tonumber(self.MonsterP[i].Type))
		--dump(Monster)
		local MonsterBody = cc.PhysicsBody:createBox(Monster.monsterSprite:getContentSize(),cc.PhysicsMaterial(1.5,0,10))
		Monster.monsterSprite:setPhysicsBody(MonsterBody)
		Monster.monsterSprite:setPosition(cc.p(Monster.monsterSprite:getContentSize().width/2+self.MonsterP[i].x*1.6,Monster.monsterSprite:getContentSize().height/2+self.MonsterP[i].y*1.6))
	 	Monster.monsterSprite:addTo(self,2)
	 	table.insert(self.MonsterTable,Monster)

	end






	self.camera = cc.Camera:createOrthographic(display.width, display.height, 0, 1)
	self.camera:setCameraFlag(cc.CameraFlag.USER2)
	self:addChild(self.camera)

	self:setCameraMask(cc.CameraFlag.USER2, true)
	-- print(musicCheckButton:getCameraMask())
	-- musicCheckButton:setCameraMask(1)
	-- print(musicCheckButton:getCameraMask())

	--Music UI
	local musicImage = {
		on = "#bmusic-sheet003.png",
		off = "#bmusic-sheet001.png"
	}

	local musicCheckButton = cc.ui.UICheckBoxButton.new(musicImage)
	musicCheckButton:setPosition(cc.p(display.right-110,display.top-25))
	musicCheckButton:addTo(self,2)
	musicCheckButton:onButtonClicked(function ()
		--print(musicCheckButton:isButtonSelected())
		-- musicCheckButton:setCameraMask(cc.CameraFlag.USER2)
	end)
	self.musicCheckButton = musicCheckButton
	--Sound UI
	local SoundImage = {
		on = "#bsfx-sheet004.png",
		off = "#bsfx-sheet001.png"
	}

	local SoundCheckButton = cc.ui.UICheckBoxButton.new(SoundImage)
	SoundCheckButton:setPosition(cc.p(display.right-70,display.top-25))
	SoundCheckButton:addTo(self,2)
	SoundCheckButton:onButtonClicked(function ()
		--print(SoundCheckButton:isButtonSelected())
	end)
	--Pause Button
	local PauseImage = {
		normal = "game/bpause-sheet0.png",
		pressed = "game/bpause-sheet1.png",
		disabled = "game/bpause-sheet2.png"
	}
	local PauseButton = cc.ui.UIPushButton.new(PauseImage)
		:setPosition(cc.p(display.right-30,display.top-25))
		:addTo(self,2)
		:onButtonClicked(function ()
			--pause game
			cc.Director:getInstance():pause()
			--Pause Layer
			local pauseLayer = display.newColorLayer(cc.c4b(0,0,0,220))
			self:addChild(pauseLayer,3)
			--BGButton
			local boardPause = display.newSprite("game/boardpause-sheet0.png")
				:setPosition(cc.p(display.cx,display.cy))
				:addTo(pauseLayer)
			--Map Button
			local MapImage = {
				normal = "game/buttonmap.png",
			}
			local MapButton = cc.ui.UIPushButton.new(MapImage)
				:setPosition(cc.p(80,80))
				:addTo(boardPause) 
				:onButtonClicked(function ()
					cc.Director:getInstance():resume()
					local scene = import("app.scenes.LevelScene").new()
					display.replaceScene(scene,"fade",0.5)
				end)
			--replay Button
			local ReplayImage = {
				normal = "game/buttonredo.png"
			}
			local ReplayButton = cc.ui.UIPushButton.new(ReplayImage)
				:setPosition(cc.p(180,80))
				:addTo(boardPause) 
				:onButtonClicked(function ()
					cc.Director:getInstance():resume()
					local scene = import("app.scenes.PlayScene").new()
					display.replaceScene(scene,"fade",0.5)
				end)

				--continue Button
			local ContinueImage = {
				normal = "game/buttonunpause.png"
			}
			local ContinueButton = cc.ui.UIPushButton.new(ContinueImage)
				:setPosition(cc.p(280,80))
				:addTo(boardPause) 
				:onButtonClicked(function ()
					pauseLayer:removeFromParent()
					cc.Director:getInstance():resume()
			end)		
	end)

end

function PlayScene:Schedule()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		if self.hero:getPositionX()>= display.width/2 and self.hero:getPositionX()<= self.map:getContentSize().width * 1.6 - display.width/2 then
			self.cameramove = true
		else 
			self.cameramove = false
		end
		if self.cameramove then
			self.camera:setPosition(self.hero:getPositionX()-display.width/2 ,0)
		end

		if self.moveleft then
			self.hero:Moveleft()
		end

		if self.moveright then
			self.hero:Moveright()
		end

		--MonsterMove
		for i = 1,#self.MonsterTable do
			local MSprite = self.MonsterTable[i].monsterSprite
			local x1 = self.MonsterP[i].x1*1.6
			local x2 = self.MonsterP[i].x2*1.6
			if self.MonsterTable[i].face == "right" then				
			 	if MSprite:getPositionX()-MSprite:getContentSize().width/2 <= tonumber(x2) then 
					MSprite:setPosition(cc.p(MSprite:getPositionX()+1,MSprite:getPositionY()))
				else
					self.MonsterTable[i].face = "left"
				end
			else
				if MSprite:getPositionX()-MSprite:getContentSize().width/2 >= tonumber(x1) then
					MSprite:setPosition(cc.p(MSprite:getPositionX()-1,MSprite:getPositionY()))
				else
					self.MonsterTable[i].face = "right"
				end
			end
		end
	end)
end

function PlayScene:Touch()
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			if event.x>0 and event.x<display.width/4 and event.y>0 and event.y<display.height/3 then
				self.moveleft = true
			end

			if event.x>display.width/4 and event.x<display.width/2  and event.y>0 and event.y<display.height/3 then
				self.moveright = true
			end

			if event.x>display.width/2 and event.x<display.width*3/4  and event.y>0 and event.y<display.height/3 then
				self.hero:Protect()
			end

			if event.x>display.width*3/4 and event.x<display.width  and event.y>0 and event.y<display.height/3 then
				self.hero:Jump()
			end
			return true
		end

		if event.name == "ended" then
			if event.x>0 and event.x<display.width/4 and event.y>0 and event.y<display.height/3 then
				if self.hero.state == "stay_left" then
					self.hero:runaction("stay")
				elseif self.hero.state == "protect_left" then
					self.hero:runaction("protect")
				end
				self.moveleft = false
			end

			if event.x>display.width/4 and event.x<display.width/2  and event.y>0 and event.y<display.height/3 then
				if self.hero.state == "stay_right" then
					-- print("1")
					self.hero:runaction("stay")
				elseif self.hero.state == "protect_right" then
					self.hero:runaction("protect")
				end
				self.moveright = false
			end
		end
	end)
end

return PlayScene


-- objPathline.x+objPathline.polylinePoints[1].x,objPathline.y-objPathline.polylinePoints[1].y
