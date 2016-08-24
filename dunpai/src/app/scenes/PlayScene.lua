
Hero = import("app.scenes.Hero").new()
-- display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
-- display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")
local PlayScene = class("PlayScene", function()
    return display.newPhysicsScene("PlayScene")
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

	
	self:getPhysicsWorld():setGravity(cc.p(0,0))
	self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	self:initUI()
	self:Schedule()
	self:scheduleUpdate()
	self:Touch()
	self:Contact()
end

function PlayScene:initUI()
	local bg = display.newSprite("game/backgroundforest-sheet0.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)
	bg:setScaleY(1.5)
	bg:setScaleX(2.6)
	self.map = cc.TMXTiledMap:create("level/level1.tmx")
	self.map:setScale(1.6)
	self:addChild(self.map)
	-- dump(self.map)
	-- --Music UI
	-- local musicImage = {
	-- 	on = "#bmusic-sheet003.png",
	-- 	off = "#bmusic-sheet001.png"
	-- }

	-- local musicCheckButton = cc.ui.UICheckBoxButton.new(musicImage)
	-- musicCheckButton:setPosition(cc.p(display.right-110,display.top-25))
	-- musicCheckButton:addTo(self,2)
	-- musicCheckButton:onButtonClicked(function ()
	-- 	--print(musicCheckButton:isButtonSelected())
	-- end)

	-- --Sound UI
	-- local SoundImage = {
	-- 	on = "#bsfx-sheet004.png",
	-- 	off = "#bsfx-sheet001.png"
	-- }

	-- local SoundCheckButton = cc.ui.UICheckBoxButton.new(SoundImage)
	-- SoundCheckButton:setPosition(cc.p(display.right-70,display.top-25))
	-- SoundCheckButton:addTo(self,2)
	-- SoundCheckButton:onButtonClicked(function ()
	-- 	--print(SoundCheckButton:isButtonSelected())
	-- end)
	-- --Pause Button
	-- local PauseImage = {
	-- 	normal = "gameause-sheet0.png",
	-- 	pressed = "gameause-sheet1.png",
	-- 	disabled = "gameause-sheet2.png"
	-- }
	-- local PauseButton = cc.ui.UIPushButton.new(PauseImage)
	-- 	:setPosition(cc.p(display.right-30,display.top-25))
	-- 	:addTo(self,2)
	-- 	:onButtonClicked(function ()
	-- 		--pause game
	-- 		cc.Director:getInstance():pause()
	-- 		--Pause Layer
	-- 		local pauseLayer = display.newColorLayer(cc.c4b(0,0,0,220))
	-- 		self:addChild(pauseLayer,3)
	-- 		--BGButton
	-- 		local boardPause = display.newSprite("game/boardpause-sheet0.png")
	-- 			:setPosition(cc.p(display.cx,display.cy))
	-- 			:addTo(pauseLayer)
	-- 		--Map Button
	-- 		local MapImage = {
	-- 			normal = "gamettonmap.png",
	-- 		}
	-- 		local MapButton = cc.ui.UIPushButton.new(MapImage)
	-- 			:setPosition(cc.p(80,80))
	-- 			:addTo(boardPause) 
	-- 			:onButtonClicked(function ()
	-- 				cc.Director:getInstance():resume()
	-- 				local scene = import("app.scenes.LevelScene").new()
	-- 				display.replaceScene(scene,"fade",0.5)
	-- 			end)
	-- 		--replay Button
	-- 		local ReplayImage = {
	-- 			normal = "gamettonredo.png"
	-- 		}
	-- 		local ReplayButton = cc.ui.UIPushButton.new(ReplayImage)
	-- 			:setPosition(cc.p(180,80))
	-- 			:addTo(boardPause) 
	-- 			:onButtonClicked(function ()
	-- 				cc.Director:getInstance():resume()
	-- 				local scene = import("app.scenes.PlayScene").new()
	-- 				display.replaceScene(scene,"fade",0.5)
	-- 			end)

	-- 			--continue Button
	-- 		local ContinueImage = {
	-- 			normal = "gamettonunpause.png"
	-- 		}
	-- 		local ContinueButton = cc.ui.UIPushButton.new(ContinueImage)
	-- 			:setPosition(cc.p(280,80))
	-- 			:addTo(boardPause) 
	-- 			:onButtonClicked(function ()
	-- 				pauseLayer:removeFromParent()
	-- 				cc.Director:getInstance():resume()
	-- 			end)		
	-- 	end)


	local sizeX = self.map:getContentSize().width*1.6
	local sizeY = self.map:getContentSize().height*1.5
	local size = cc.size(sizeX,sizeY)
	local body = cc.PhysicsBody:createEdgeBox(size, cc.PHYSICSBODY_MATERIAL_DEFAULT, 1)

	local edgeNode = display.newNode()
	edgeNode:setPosition(size.width / 2, size.height / 2)
	edgeNode:setPhysicsBody(body)
	self:addChild(edgeNode)
	self.hero = Hero.new()
	self.hero:setTag(1)
	self:addChild(self.hero)
	self.pos1 = cc.p(self.hero:getPosition())

	local wallArray = self.map:getObjectGroup("wall"):getObjects()
	-- dump(wallArray[1].polylinePoints)
	for i=1,(#wallArray[1].polylinePoints -1) do
		local point1 = cc.p(wallArray[1].polylinePoints[i].x*1.6,(wallArray[1].y - wallArray[1].polylinePoints[i].y)*1.6)
		local point2 = cc.p(wallArray[1].polylinePoints[i+1].x * 1.6,(wallArray[1].y - wallArray[1].polylinePoints[i+1].y)*1.6)
		local wallbody = cc.PhysicsBody:createEdgeSegment(point1,point2,cc.PHYSICSBODY_MATERIAL_DEFAULT)
		-- wallbody:setCategoryBitmask(0xFFFFFFFF)
		wallbody:setContactTestBitmask(0xFFFFFFFF)
		-- wallbody:setCollisionBitmask(0xFFFFFFFF)
		local node = display.newNode()
			:setCameraMask(cc.CameraFlag.USER2)
			:setPhysicsBody(wallbody)
			:setTag(2)
			:addTo(self)
	end


	self.camera = cc.Camera:createOrthographic(display.width, display.height, 0, 1)
	self.camera:setCameraFlag(cc.CameraFlag.USER2)
	self:addChild(self.camera)

	self:setCameraMask(cc.CameraFlag.USER2)
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
			-- if self.hero.action ~= "jump_up" and self.hero.action ~= "jump_down" then
				self.hero:Jump()
			-- end
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
				self.jump = true
			end
			return true
		end

		if event.name == "ended" then
			if event.x>0 and event.x<display.width/4 and event.y>0 and event.y<display.height/3 then
				if self.hero.action == "run" then
					self.hero:runaction("stand")
				end
				self.moveright = false
				self.moveleft = false
			end

			if event.x>display.width/4 and event.x<display.width/2  and event.y>0 and event.y<display.height/3 then
				if self.hero.action == "run" then
					self.hero:runaction("stand")
				end
				self.moveright = false
				self.moveleft = false
			end

		end
	end)
end

function PlayScene:Contact()
	local function onContactBegin(contact)
		local tag1 = contact:getShapeA():getBody():getNode():getTag()
		local tag2 = contact:getShapeB():getBody():getNode():getTag()
		if self.hero.action == "jump_down" then
			if (tag1 == 2 and tag2 == 1) or (tag1 == 1 and tag2 == 2) then
				self.hero.speedY = 15
				self.jump = false
				self.hero:runaction("stand")
			end
		end
		return true
	end

	local contactListener = cc.EventListenerPhysicsContact:create()
	contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithFixedPriority(contactListener, 1)
end

return PlayScene


-- objPathline.x+objPathline.polylinePoints[1].x,objPathline.y-objPathline.polylinePoints[1].y
