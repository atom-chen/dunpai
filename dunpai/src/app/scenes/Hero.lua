
display.addSpriteFrames("game/player-sheet.plist","game/player-sheet.pvr.ccz")
local Hero = class("PlayScene", function(map)
	hero = display.newSprite("#player-sheet0_1.png")
	hero.map = map
    return hero
end)

function Hero:ctor()
	self.state = "normal"
	self.face = "right"
	self.action = "stand"
	self.contact = "wall"
	self.wall = 1
	self.standline = 1
	self.wallArray = {}
	self.speed = 2.5
	self.downspeed = 4
	self.speedY = 19
	self:initself()
end

function Hero:initself()
	self.wallArray = self.map:getObjectGroup("wall"):getObjects()

	local heroArray = self.map:getObjectGroup("hero"):getObjects()
	for _,value in pairs(heroArray) do
		hero:setScale(1.2)
		local herobody = cc.PhysicsBody:createBox(cc.size(hero:getContentSize().width,hero:getContentSize().height), cc.PHYSICSBODY_MATERIAL_DEFAULT)
		-- local herobody = cc.PhysicsBody:createCircle(hero:getContentSize().width*0.6)
		herobody:getShape(0):setRestitution(0)
		-- herobody:setCategoryBitmask(0xFFFFFFFF)
		herobody:setContactTestBitmask(0xFFFFFFFF)
		herobody:setCollisionBitmask(0)
		herobody:getShape(0):setFriction(0.5)
		-- herobody:setGravityEnable(false)
		-- herobody:applyImpulse(cc.p(-150 * math.sqrt(2),150 * math.sqrt(2)))
		hero:setPhysicsBody(herobody)
		hero:setPosition(cc.p(value.x*1.6+hero:getContentSize().width/2, value.y*1.6+hero:getContentSize().height/2 -2))
	end


	local stayframe = display.newFrames("player-sheet0_%d.png", 1, 5)
	local stayanimation = display.newAnimation(stayframe, 0.1)
	display.setAnimationCache("stay", stayanimation)
	self:playAnimationForever(stayanimation, 0)

	local normal_runframe = display.newFrames("player-sheet0_%d.png", 6, 4)
	local normal_runanimation = display.newAnimation(normal_runframe, 0.1)
	display.setAnimationCache("normal_run", normal_runanimation)

	local protect_runframe = display.newFrames("player-sheet0_%d.png", 13, 4)
	local protect_runanimation = display.newAnimation(protect_runframe, 0.1)
	display.setAnimationCache("protect_run", protect_runanimation)

	local protect_jumpupframe = display.newFrames("player-sheet0_%d.png", 17, 2)
	local protect_jumpupanimation = display.newAnimation(protect_jumpupframe, 0.1)
	display.setAnimationCache("protect_jumpup", protect_jumpupanimation)

	local protect_jumpdownframe = display.newFrames("player-sheet0_%d.png", 19, 4)
	local protect_jumpdownanimation = display.newAnimation(protect_jumpdownframe, 0.1)
	display.setAnimationCache("protect_jumpdown", protect_jumpdownanimation)

end

function Hero:Moveleft()
	-- local herobody = self:getPhysicsBody()
	if self.contact == "wall" then
		-- herobody:setVelocity(cc.p(-100,0))
		local heropos
		if self.wallArray[self.wall].polylinePoints[self.standline-1] ~= nil then
			if math.abs(self.wallArray[self.wall].polylinePoints[self.standline-1].y - self.wallArray[self.wall].polylinePoints[self.standline].y) < 3 then
				if self.wallArray[self.wall].polylinePoints[self.standline].y < self.wallArray[self.wall].polylinePoints[self.standline+1].y then
					heropos = cc.p(self:getPositionX()-self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
				else
					heropos = cc.p(self:getPositionX()+self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
				end
			else
				if self.wallArray[self.wall].polylinePoints[self.standline-1].y <= self.wallArray[self.wall].polylinePoints[self.standline].y then
					-- print("left")
					heropos = cc.p(self:getPositionX()-self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
				else
					-- print("right")
					heropos = cc.p(self:getPositionX()+self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
				end
			end
		else
			-- print("nil")
			heropos = cc.p(self:getPositionX()-self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
		end
		-- print(self.standline)
		if self.standline > 1 then

			if heropos.x > self.wallArray[self.wall].x*1.6 + self.wallArray[self.wall].polylinePoints[self.standline-1].x*1.6 and heropos.x < self.wallArray[self.wall].x*1.6 + self.wallArray[self.wall].polylinePoints[self.standline].x*1.6 then
				self.standline = self.standline - 1
			end
		end
		local point1 = cc.p(self.wallArray[self.wall].polylinePoints[self.standline].x*1.6,(self.wallArray[self.wall].y-self.wallArray[self.wall].polylinePoints[self.standline].y)*1.6)
		local point2 = cc.p(self.wallArray[self.wall].polylinePoints[self.standline+1].x*1.6,(self.wallArray[self.wall].y-self.wallArray[self.wall].polylinePoints[self.standline+1].y)*1.6)
		local speedX = self.speed * (point2.x - point1.x) / cc.pGetDistance(point1,point2)
		local speedY = self.speed * (point2.y - point1.y) / cc.pGetDistance(point1,point2)
		self:setPosition(self:getPositionX()  - speedX,self:getPositionY() - speedY)
	elseif self.contact == "air" or self.contact == "stone" then
		self:setPosition(self:getPositionX()  - self.speed,self:getPositionY())
	end
	if self.face == "right" then
		self:setFlippedX(true)
		self.face = "left"
	end
	if self.action == "stand" then
		self:runaction("run")
	end
end

function Hero:Moveright()
	-- print("right")
	-- local herobody = self:getPhysicsBody()
	-- herobody:setVelocity(cc.p(100,0))
	--dump(self.wallArray[self.wall])
	if self.contact == "wall" then
		local heropos
		if self.wallArray[self.wall].polylinePoints[self.standline+2] ~= nil then
			-- print("")
			if self.wallArray[self.wall].polylinePoints[self.standline+1].y <= self.wallArray[self.wall].polylinePoints[self.standline+2].y then	
				heropos = cc.p(self:getPositionX()-self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
			else
				heropos = cc.p(self:getPositionX()+self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
			end
		else
			heropos = cc.p(self:getPositionX()-self:getContentSize().width/2,self:getPositionY()-self:getContentSize().height/2)
		end
		if self.wallArray[self.wall].polylinePoints[self.standline+2] ~= nil then
			if heropos.x > self.wallArray[self.wall].polylinePoints[self.standline+1].x*1.6 and heropos.x < self.wallArray[self.wall].polylinePoints[self.standline+2].x*1.6 then
				self.standline = self.standline + 1
			end
		end
		local point1 = cc.p(self.wallArray[self.wall].polylinePoints[self.standline].x*1.6,(self.wallArray[self.wall].y-self.wallArray[self.wall].polylinePoints[self.standline].y)*1.6)
		local point2 = cc.p(self.wallArray[self.wall].polylinePoints[self.standline+1].x*1.6,(self.wallArray[self.wall].y-self.wallArray[self.wall].polylinePoints[self.standline+1].y)*1.6)
		local speedX = self.speed * (point2.x - point1.x) / cc.pGetDistance(point1,point2)
		local speedY = self.speed * (point2.y - point1.y) / cc.pGetDistance(point1,point2)
		print(speedY)
		self:setPosition(self:getPositionX()  + speedX,self:getPositionY() + speedY)
	elseif self.contact == "air" or self.contact == "stone" then
		self:setPosition(self:getPositionX()  + self.speed,self:getPositionY())
	end
	if self.face == "left" then
		self:setFlippedX(false)
		self.face = "right"
	end
	if self.action == "stand" then
		self:runaction("run")
	end
end

function Hero:Protect()
	if self.state == "normal" then
		self.speed = 1.3
		self.downspeed = 1
		self.state = "protect"
	else
		self.speed = 2.5
		self.downspeed = 4
		self.state = "normal"
	end
	if self.action == "stand" then
		self:runaction("stand")
	elseif self.action == "run" then
		self:runaction("run")
	elseif self.action == "jump_down" then
		self:runaction("jump_down")
	end

end

function Hero:Jump()
	-- local herobody = self:getPhysicsBody()
	if self.speedY > 0 then
		self:setPosition(self:getPositionX(),self:getPositionY() + self.speedY)
		self.speedY = self.speedY -1 
	else
		self:setPosition(self:getPositionX(),self:getPositionY() - self.downspeed)
	end
	if self.speedY>0 and self.action~="jump_up" then
		self:runaction("jump_up")
	elseif self.speedY <= 0 and self.action~= "jump_down" then
		self:runaction("jump_down")
	end

end

function Hero:runaction( state )
	if state == "stand" then
		self.action = "stand"
		if self.state == "normal" then
			local stayanimation = display.getAnimationCache("stay")
			self:stopAllActions()
			self:playAnimationForever(stayanimation, 0)
		elseif self.state == "protect" then
			local protectframe = display.newSpriteFrame("player-sheet0_12.png")
			self:stopAllActions()
			self:setSpriteFrame(protectframe)
		end
	end
	if state == "run" then
		self.action = "run"
		if self.state == "normal" then
			local normal_runanimation = display.getAnimationCache("normal_run")
			self:stopAllActions()
			self:playAnimationForever(normal_runanimation, 0)
		elseif self.state == "protect" then
			local protect_runanimation = display.getAnimationCache("protect_run")
			self:stopAllActions()
			self:playAnimationForever(protect_runanimation, 0)
		end
	end

	if state == "jump_up" then
		self.action = "jump_up"
		if self.state == "normal" then
			local normal_jumpupframe = display.newSpriteFrame("player-sheet0_10.png")
			self:stopAllActions()
			self:setSpriteFrame(normal_jumpupframe)
		elseif self.state == "protect" then
			local protect_jumpupanimation = display.getAnimationCache("protect_jumpup")
			self:stopAllActions()
			self:playAnimationOnce(protect_jumpupanimation,false,function()
				-- body
			end, 0)
		end
	end

	if state == "jump_down" then
		self.action = "jump_down"
		if self.state == "normal" then
			local normal_jumpdownframe = display.newSpriteFrame("player-sheet0_11.png")
			self:stopAllActions()
			self:setSpriteFrame(normal_jumpdownframe)
		elseif self.state == "protect" then
			-- local herobody = self:getPhysicsBody()
			-- herobody:setMass()
			local protect_jumpdownanimation = display.getAnimationCache("protect_jumpdown")
			self:stopAllActions()
			self:playAnimationForever(protect_jumpdownanimation, 0)
		end
	end

	if state == "death" then
		local protectframe = display.newSpriteFrame("player-sheet0_24.png")
		self:stopAllActions()
		self:setSpriteFrame(protectframe)
	end

end


return Hero


-- objPathline.x+objPathline.polylinePoints[1].x,objPathline.y-objPathline.polylinePoints[1].y
