
Hero = import("app.scenes.Hero")
local Monsters = import("app.scenes.Monsters")
display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")

local PlayScene = class("PlayScene", function(nowNum)
	local playscene = display.newPhysicsScene("PlayScene")
	playscene.nowNum = nowNum
    return playscene
end)

 

function PlayScene:ctor()
	self.hero = nil
	self.pos1 = nil
	self.map = nil
	self.cameramove = false
	self.moveleft = false
	self.moveright = false
	self.jump = false
	self.hero = nil
	self.nowMedal = 1 --当前关卡所得金牌数
	self.isGold = false   --当前关卡金币是否全部得到
	self.isHelp = false   --当前关卡的小动物是否救完
	self.MonsterTable = {}

	self:getPhysicsWorld():setGravity(cc.p(0,0))
	self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	self:initUI()
	self:Schedule()
	self:scheduleUpdate()
	self:Touch()
	self:Contact()

end

function PlayScene:initUI()



	--banfground pictrue
	local bg = display.newSprite("game/backgroundforest-sheet0.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)
	bg:setScaleY(1.5)
	bg:setScaleX(2.6)
	--
	self.map = cc.TMXTiledMap:create("level/level"..self.nowNum..".tmx")
	self.map:setScale(1.6)
	self:addChild(self.map)

	local sizeX = self.map:getContentSize().width*1.6
	local sizeY = self.map:getContentSize().height*1.5
	local size = cc.size(sizeX,sizeY)
	local body = cc.PhysicsBody:createEdgeBox(size, cc.PHYSICSBODY_MATERIAL_DEFAULT, 1)

	local edgeNode = display.newNode()
	edgeNode:setPosition(size.width / 2, size.height / 2)
	edgeNode:setPhysicsBody(body)
	self:addChild(edgeNode)
	-- dump(self.map)
	--

	self.hero = Hero.new(self.nowNum)
	self.hero:setTag(1)
	self:addChild(self.hero)
	self.pos1 = cc.p(self.hero:getPosition())


	local wallArray = self.map:getObjectGroup("wall"):getObjects()

	for i = 1,#wallArray do
		for j = 1,#wallArray[i].polylinePoints-1 do
			local point1 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j].x)*1.6,(wallArray[i].y - wallArray[i].polylinePoints[j].y)*1.6)
			local point2 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j+1].x) * 1.6,(wallArray[i].y - wallArray[i].polylinePoints[j+1].y)*1.6)
			local wallbody = cc.PhysicsBody:createEdgeSegment(point1,point2,cc.PhysicsMaterial(1.5,0,10))
			-- wallbody:setCategoryBitmask(0xFFFFFFFF)
			wallbody:setContactTestBitmask(0xFFFFFFFF)
			-- wallbody:setCollisionBitmask(0xFFFFFFFF)
 			local node = display.newNode()
				:setCameraMask(cc.CameraFlag.USER2)
	 			:setPhysicsBody(wallbody)
	 			:setTag(50+ 20*(i-1) + j)
	 			:addTo(self)
		end
	end


	
	--stone
	if self.map:getObjectGroup("stone") ~= nil then
		local stoneArray = self.map:getObjectGroup("stone"):getObjects()
		-- dump(stoneArray)
		for _,value in pairs(stoneArray) do
			local stonebody = cc.PhysicsBody:createEdgeBox(cc.size(value.width*1.45,value.height*1.45), cc.PHYSICSBODY_MATERIAL_DEFAULT)
			-- local herobody = cc.PhysicsBody:createCircle(hero:getContentSize().width*0.6)
			-- herobody:getShape(0):setRestitution(0)
			-- stonebody:setCategoryBitmask(0xFFFFFFFF)
			stonebody:setContactTestBitmask(0xFFFFFFFF)
			-- herobody:setCollisionBitmask(0xFFFFFFFF)
			-- herobody:getShape(0):setFriction(0.5)
			-- herobody:applyImpulse(cc.p(-150 * math.sqrt(2),150 * math.sqrt(2)))
			local node = display.newNode()
				:setPosition(cc.p(value.x*1.6+value.width*0.8+2, value.y*1.6+value.height*0.8+2))
				:setContentSize(cc.size(value.width*1.45,value.height*1.45))
	 			:setPhysicsBody(stonebody)
	 			:setTag(3)
	 			:addTo(self)
		end
	end 

	--Monster
	if self.map:getObjectGroup("monsters") ~= nil then
		self.MonsterP = self.map:getObjectGroup("monsters"):getObjects()
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
	end





	self.camera = cc.Camera:createOrthographic(display.width, display.height, 0, 1)
	self.camera:setCameraFlag(cc.CameraFlag.USER2)
	self:addChild(self.camera)

	self:setCameraMask(cc.CameraFlag.USER2)

	self:setCameraMask(cc.CameraFlag.USER2, true)
	

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

		if self.jump then
			self.hero:Jump()
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
				self.hero.contact = "air"
				self.jump = true
			end
			return true
		end

		if event.name == "ended" then
			if event.x>0 and event.x<display.width/4 and event.y>0 and event.y<display.height/3 then
				self.hero:runaction("stand")
				self.moveleft = false
			end

			if event.x>display.width/4 and event.x<display.width/2  and event.y>0 and event.y<display.height/3 then
				-- if self.hero.state == "stay_right" then
				-- 	-- print("1")
				-- 	self.hero:runaction("stay")
				-- elseif self.hero.state == "protect_right" then
				-- 	self.hero:runaction("protect")
				-- end
				self.hero:runaction("stand")
				self.moveright = false
			end
		end
	end)
end


function PlayScene:Contact()
	local function onContactBegin(contact)
		local tag1 = contact:getShapeA():getBody():getNode():getTag()
		local tag2 = contact:getShapeB():getBody():getNode():getTag()
		-- print(tag1,tag2)
		if self.hero.action == "jump_down" then
			if tag1 > 50 and tag2 == 1 or tag1 == 1 and tag2 > 50 then
				local tag = 0
				if tag1 > 50 then
					tag = tag1
				elseif tag2 > 50 then
					tag = tag2
				end

				self.hero.wall = math.ceil((tag-50) / 20)
				self.hero.standline = tag-50 - (self.hero.wall-1) * 20
				print(self.hero.wall,self.hero.standline)

				self.hero.contact = "wall"
				self.jump = false
				self.hero.speedY = 20
				self.hero:runaction("stand")
			end

			if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
				self.hero.contact = "stone"
				self.jump = false
				self.hero.speedY = 20
				self.hero:runaction("stand")
			end
		end

		if self.hero.action == "run" then
			if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
				-- print("stone")
				if self.hero.face == "right" then
					self.hero:setPosition(self.hero:getPositionX() - self.hero.speed, self.hero:getPositionY())
				elseif self.hero.face == "left" then
					self.hero:setPosition(self.hero:getPositionX() + self.hero.speed, self.hero:getPositionY())
				end
			end
		end
	end

	local function onContactEnd( contact )
		local tag1 = contact:getShapeA():getBody():getNode():getTag()
		local tag2 = contact:getShapeB():getBody():getNode():getTag()

		if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
			-- print("end")
			-- print("stone")
			local stoneX
			local stoneWidth
			if tag1 == 3 then
				stoneX = contact:getShapeA():getBody():getNode():getPositionX()
				stoneWidth = contact:getShapeA():getBody():getNode():getContentSize().width
			elseif tag2 == 3 then
				stoneX = contact:getShapeB():getBody():getNode():getPositionX()
				stoneWidth = contact:getShapeB():getBody():getNode():getContentSize().width
			end

			-- print(contact:getShapeA():getBody():getNode():getContentSize().width)
			if self.hero:getPositionX() - stoneX >= stoneWidth/2  or stoneX - self.hero:getPositionX() >= stoneWidth/2 then
				self.hero.speedY = 0
				self.jump = true
			end

			if self.hero.face == "right" then
				self.hero:setPosition(self.hero:getPositionX() - 2, self.hero:getPositionY())
			elseif self.hero.face == "left" then
				self.hero:setPosition(self.hero:getPositionX() + 2, self.hero:getPositionY())
			end
		end

	end

	local contactListener = cc.EventListenerPhysicsContact:create()
	contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

	local contactListener2 = cc.EventListenerPhysicsContact:create()
	contactListener2:registerScriptHandler(onContactEnd,cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithFixedPriority(contactListener, 1)
	eventDispatcher:addEventListenerWithFixedPriority(contactListener2, 1)
end

--通过当前关卡
function PlayScene:CrossLevel()

	--pause game
	--cc.Director:getInstance():pause()
	--Pause Layer
	local crossLayer = display.newColorLayer(cc.c4b(0,0,0,220))
	self:addChild(crossLayer,3)
	--BGButton
	local boardPause = display.newSprite("game/boardwin-sheet0.png")
		:setPosition(cc.p(display.cx,display.cy*1.3))
		:addTo(crossLayer)

	local m1,m2,m3

	m1= display.newSprite("game/badgebaba-sheet2.png")
	m1:setPosition(cc.p(60,155))
	m1:addTo(boardPause,2)

	 if isGold then
	 	m2 = display.newSprite("game/badgebaba-sheet2.png")
	 else
	 	m2 = display.newSprite("game/badgebaba-sheet1.png")
	 end
	m2:setPosition(cc.p(60,105))
	m2:addTo(boardPause,2)

	 if isHelp then
	 	m3 = display.newSprite("game/badgebaba-sheet2.png")
	 else
	 	m3 = display.newSprite("game/badgebaba-sheet1.png")
	 end
	m3:setPosition(cc.p(60,55))
	m3:addTo(boardPause,2)

	local medalImage
	if self.nowMedal == 1 then
		medalImage = display.newSprite("game/medal-sheet1.png")
	elseif self.nowMedal == 2 then
		medalImage = display.newSprite("game/medal-sheet0.png")
	elseif self.nowMedal == 3 then
		medalImage = display.newSprite("game/medal-sheet2.png")
	end
	medalImage:setPosition(cc.p(210,110))
	medalImage:addTo(boardPause,2)
	
	--Map Button
	local MapImage = {
		normal = "game/buttonmap.png",
	}
	local MapButton = cc.ui.UIPushButton.new(MapImage)
		:setPosition(cc.p(display.cx-100,display.cy*0.6))
		:addTo(crossLayer) 
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
		:setPosition(cc.p(display.cx,display.cy*0.6))
		:addTo(crossLayer) 
		:onButtonClicked(function ()
			cc.Director:getInstance():resume()
			local scene = import("app.scenes.PlayScene").new(self.nowNum)
			display.replaceScene(scene,"fade",0.5)
		end)

		--next Button
	local NextImage = {
		normal = "game/buttonnext.png"
	}
	local ContinueButton = cc.ui.UIPushButton.new(NextImage)
		:setPosition(cc.p(display.cx+100,display.cy*0.6))
		:addTo(crossLayer) 
		:onButtonClicked(function ()
			local scene = import("app.scenes.PlayScene").new(self.nowNum+1)
			display.replaceScene(scene,"fade",0.5)
		end)	



	self.levelinfo = {}
	self.levelinfo = GameData
	dump(self.levelinfo)
	self.levelinfo[tostring(self.nowNum)].medal = self.nowMedal   --得到的金牌数
	self.levelinfo[tostring(self.nowNum)].levelCrossNum = self.levelinfo[tostring(self.nowNum)].levelCrossNum   --通过的关卡数+1
	GameState.save(self.levelinfo)


end

return PlayScene


-- objPathline.x+objPathline.polylinePoints[1].x,objPathline.y-objPathline.polylinePoints[1].y