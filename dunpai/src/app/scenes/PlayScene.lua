
local Hero = import("app.scenes.Hero")
local Map = import("app.scenes.Map")
local Monsters = import("app.scenes.Monsters")
display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")
display.addSpriteFrames("game/baba-sheet.plist", "game/baba-sheet.pvr.ccz")
local Button = import("app.scenes.Button")

local PlayScene = class("PlayScene", function(nowNum)
	local playscene = display.newPhysicsScene("PlayScene")
	playscene.nowNum = nowNum
    return playscene
end)

 

function PlayScene:ctor()
	self.hero = nil
	self.pos1 = nil
	self.map = nil
	self.mapheight = nil
	self.mapwidth = nil
	self.cameramove = false
	self.moveleft = false
	self.moveright = false
	self.isFire = true  --发射子弹
	self.jump = false
	self.over = false  --游戏结束
	self.haveGold = 0  --当前地图存在的金币数
	self.haveBody = 0  --当前地图存在要拯救的小动物的数量
	self.nowMedal = 1 --当前关卡所得金牌数
	self.nowGold = 0   --当前关卡金币是否全部得到
	self.nowBody = 0   --当前关卡的小动物是否救完
	self.MonsterTable = {} --存放怪物
	self.fireballTable = {}  --存放子弹

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
	bg:setScaleY(2)
	bg:setScaleX(2.6)
	
	--
	-- self.map = cc.TMXTiledMap:create("level/level"..self.nowNum..".tmx")
	self.map = Map.new(self.nowNum)
	self.map:setScale(1.6)
	self:addChild(self.map)
	self.mapheight = self.map:getContentSize().height*1.6
	self.mapwidth = self.map:getContentSize().width*1.6
	--print(self.mapwidth)

	local sizeX = self.map:getContentSize().width*1.6
	local sizeY = self.map:getContentSize().height*1.5
	local size = cc.size(sizeX,sizeY)
	local body = cc.PhysicsBody:createEdgeBox(size, cc.PHYSICSBODY_MATERIAL_DEFAULT, 1)

	local edgeNode = display.newNode()
	edgeNode:setPosition(size.width / 2, size.height / 2)
	edgeNode:setPhysicsBody(body)
	self:addChild(edgeNode)
	--dump(self.map)
	

	self.hero = Hero.new(self.map)
	self.hero:setTag(1)
	self:addChild(self.hero)
	-- self.pos1 = cc.p(self.hero:getPosition())
	--addstone
	if #self.map.stonenode ~= 0 then
		for _,value in pairs(self.map.stonenode) do
			self:addChild(value)
		end
	end
	--addwall
	for _,value in pairs(self.map.wallnode) do
		self:addChild(value)
	end
	--addnext
	for _,value in pairs(self.map.nextnode) do
		self:addChild(value)
	end

	--addcoin
	for _,value in pairs(self.map.coinnode) do
		self.haveGold = self.haveGold +1
		self:addChild(value)
	end

	--addspike
	for _,value in pairs(self.map.spikenode) do
		self:addChild(value)
	end

	--cageb
	for _,value in pairs(self.map.bodynode) do
		self.haveBody = self.haveBody +1
		self:addChild(value)
	end
 

	--Monster
	if self.map:getObjectGroup("monsters") ~= nil then
		self.MonsterP = self.map:getObjectGroup("monsters"):getObjects()
		--dump(MonsterP)
		for i=1,#self.MonsterP do
			local Monster = Monsters.new(tonumber(self.MonsterP[i].Type))
			Monster.monsterSprite:setPosition(cc.p(Monster.monsterSprite:getContentSize().width/2+self.MonsterP[i].x*1.6,Monster.monsterSprite:getContentSize().height/2+self.MonsterP[i].y*1.6))
		 	Monster.monsterSprite:addTo(self)
		 	table.insert(self.MonsterTable,Monster)
		end
	end

	self.camera = cc.Camera:createOrthographic(display.width, display.height, 0, 1)
	self.camera:setCameraFlag(cc.CameraFlag.USER2)
	self:addChild(self.camera)

	self:setCameraMask(cc.CameraFlag.USER2)

	self:setCameraMask(cc.CameraFlag.USER2, true)

	--Button
	--Music Button
	local button = Button.new()

	local Musicbutton = button:MusicButton()
	Musicbutton:setPosition(cc.p(display.right-110,display.top-25))
	Musicbutton:addTo(self,2)

	--Sound Button
	local SoundButton = button:SoundButton()
	SoundButton:setPosition(cc.p(display.right-70,display.top-25))
	SoundButton:addTo(self,2)

	--Pause Button
	local PauseButton = button:PauseButton()
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
					local scene = import("app.scenes.PlayScene").new(self.nowNum)
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
	
	--操作提示
	if self.nowNum == 1 then
		--开场CG
		local i = 1 --记录当前CG的图片
		local comic = display.newSprite("game/comic-sheet0_0"..i..".png")
		-- local comic2 = display.newSprite("game/comic-sheet0_02.png")
		-- local comic3 = display.newSprite("game/comic-sheet0_03.png")
		local comicLayer = display.newColorLayer(cc.c4b(0,0,0,240))
		self:addChild(comicLayer,3)

		comic:setPosition(cc.p(display.cx,display.cy))
			:addTo(comicLayer)

		local skipimage = {
			normal = "game/skip-sheet0.png"
		}
		local skipButton = cc.ui.UIPushButton.new(skipimage)
			:setPosition(cc.p(100,-20))
			:addTo(comic)
			:onButtonClicked(function ()
				comicLayer:removeFromParent()
			end)

		local nextImage = {
			normal = "game/btnnext-sheet0.png"
		}
		local nextButton = cc.ui.UIPushButton.new(nextImage)
			:setPosition(cc.p(350,-25))
			:addTo(comic)
			:onButtonClicked(function ()
				i = i+1
				local comic = display.newSprite("game/comic-sheet0_0"..i..".png")
					:setPosition(cc.p(display.cx,display.cy))
					:addTo(comicLayer)
				if i >= 4 then
					comicLayer:removeFromParent()
				end
				if i == 2 then
					local previmage = {
						normal = "game/btnprev-sheet0.png"
					}
					self.prevButton = cc.ui.UIPushButton.new(previmage)
						:setPosition(cc.p(280,-25))
						:addTo(comic)
						:onButtonClicked(function ()
							i = i-1
							local comic = display.newSprite("game/comic-sheet0_0"..i..".png")
								:setPosition(cc.p(display.cx,display.cy))
								:addTo(comicLayer)
							if i == 1 then
								self.prevButton:removeFromParent()
							end
						end)
				end
			end)

		local tishiSprite = display.newSprite("game/launch_01.png")
			:addTo(self,1)
			:setPosition(cc.p(display.cx,display.top-20))
			:setAnchorPoint(0.5,1)
	end
	if self.nowNum == 2 then
		local tishiSprite = display.newSprite("game/launch_02.png")
			:addTo(self,1)
			:setPosition(cc.p(display.cx,display.top-50))
			:setAnchorPoint(0.5,1)
	end

end

function PlayScene:Schedule()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		if self.hero:getPositionX()>= display.width/2 and self.hero:getPositionX()<= self.map:getContentSize().width * 1.6 - display.width/2 then
			if self.hero:getPositionY() >= display.height*0.6 then
				self.camera:setPosition(self.hero:getPositionX()-display.width/2, self.hero:getPositionY() - display.height*0.6)
			else
				self.camera:setPosition(self.hero:getPositionX()-display.width/2, 0)
			end
		elseif self.hero:getPositionY() >= display.height*0.6 then
			if self.hero:getPositionX() < display.width/2 then
				self.camera:setPosition(0, self.hero:getPositionY() - display.height*0.6)
			elseif self.hero:getPositionX() > self.map:getContentSize().width * 1.6 - display.width/2 then
				self.camera:setPosition(self.map:getContentSize().width * 1.6 - display.width, self.hero:getPositionY() - display.height*0.6)
			end
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
		if #self.MonsterTable>= 1 then
			for i = 1,#self.MonsterTable do
				local MSprite = self.MonsterTable[i].monsterSprite
				local x1 = self.MonsterP[i].x1*1.6
				local x2 = self.MonsterP[i].x2*1.6
				if self.MonsterTable[i].face == "right" then				
				 	if MSprite:getPositionX()-MSprite:getContentSize().width/2 <= tonumber(x2) then 
						self.MonsterTable[i]:MoveRight()
					else
						MSprite:setFlippedX(true)
						self.MonsterTable[i].face = "left"
					end
				else
					if MSprite:getPositionX()-MSprite:getContentSize().width/2 >= tonumber(x1) then
						self.MonsterTable[i]:MoveLeft()
					else
						MSprite:setFlippedX(false)
						self.MonsterTable[i].face = "right"
					end
				end

				if self.MonsterTable[i].Type == 1 then
					if self.hero:getPositionY()-self.hero:getContentSize().height <= self.MonsterTable[i].monsterSprite:getPositionY()+self.MonsterTable[i].monsterSprite:getContentSize().height then
						if self.hero:getPositionY()-self.hero:getContentSize().height >= self.MonsterTable[i].monsterSprite:getPositionY()-self.MonsterTable[i].monsterSprite:getContentSize().height then
							if self.MonsterTable[i].face ~= self.hero.face then
								if self.isFire then 
									--self.MonsterTable[i].monsterSprite:setCameraMask(cc.CameraFlag.USER2)
									self.isFire = false
									local fireball = self.MonsterTable[i]:addfireball()
									self:addChild(fireball)
									fireball:setCameraMask(cc.CameraFlag.USER2)
									if self.MonsterTable[i].face == "right" then
										fireball.fireRight = true
										fireball:setPosition(cc.p(self.MonsterTable[i].monsterSprite:getPositionX()+2+self.MonsterTable[i].monsterSprite:getContentSize().width/2,self.MonsterTable[i].monsterSprite:getPositionY()))
									else
										fireball.fireRight = false
										fireball:setPosition(cc.p(self.MonsterTable[i].monsterSprite:getPositionX()-2-self.MonsterTable[i].monsterSprite:getContentSize().width/2,self.MonsterTable[i].monsterSprite:getPositionY()))
									end
									table.insert(self.fireballTable,fireball)
								end
								
							end
						end
					end
				end
			end
		end

		--子弹检测
		if #self.fireballTable >= 1 then
			for k,v in pairs(self.fireballTable) do
				if v:getPositionX() <= 0 or v:getPositionX() >= self.mapwidth then
					v:removeFromParent()
					table.remove(self.fireballTable,k)
					self.isFire = true
				else
					if v.fireRight then
						v:setPosition(cc.p(v:getPositionX()+2,v:getPositionY()))
					else
						v:setPosition(cc.p(v:getPositionX()-2,v:getPositionY()))
					end
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
			if self.hero.state ~= "death" then 
				if event.x>0 and event.x<display.width/4 and event.y>0 and event.y<display.height/3 then
					self.hero:runaction("stand")
					self.moveleft = false
				end

				if event.x>display.width/4 and event.x<display.width/2  and event.y>0 and event.y<display.height/3 then
					self.hero:runaction("stand")
					self.moveright = false
				end
			end
		end
	end)
end


function PlayScene:Contact()
	local function onContactBegin(contact)
		local tag1 = contact:getShapeA():getBody():getNode():getTag()
		local tag2 = contact:getShapeB():getBody():getNode():getTag()
		local hero,other
		if tag1 == 1 then
			hero = contact:getShapeA():getBody():getNode()
			other = contact:getShapeB():getBody():getNode()
		else
			hero = contact:getShapeB():getBody():getNode()
			other = contact:getShapeA():getBody():getNode()
		end

		--hero死亡
		local function heroDeath(herostate)
			other:getPhysicsBody():setContactTestBitmask(0)	
			self:setTouchEnabled(false)
			self:unscheduleUpdate()
			self.over = true
			
			self:unscheduleUpdate()
			self.hero:runaction(herostate)

			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			eventDispatcher:removeEventListener(self.contactListener)
			self:performWithDelay(function ()
				local scene = self.new(self.nowNum)
				display.replaceScene(scene,"fade",0.4)
			end, 1)
		end


		local hero_bottom = self.hero:getPositionY()-self.hero:getContentSize().height/2
		if self.hero.action == "jump_down" then
			if tag1 > 50 and tag2 == 1 or tag1 == 1 and tag2 > 50 then
				local tag = 0
				if tag1 > 50 then
					tag = tag1
				elseif tag2 > 50 then
					tag = tag2
				end
				local wallY1
				local wallY2
				local minwallY
				local wallArray = self.map:getObjectGroup("wall"):getObjects()
				local wallnum = math.ceil((tag-50) / 20)
				local pointnum = tag-50 - (wallnum-1) * 20
				wallY1 = (wallArray[wallnum].y - wallArray[wallnum].polylinePoints[pointnum].y)*1.6
				wallY2 = (wallArray[wallnum].y - wallArray[wallnum].polylinePoints[pointnum+1].y)*1.6
				if wallY1 <= wallY2 then
					minwallY = wallY1
				else
					minwallY = wallY2	
				end
				if minwallY - hero_bottom <= 4 then
					local tag = 0
					if tag1 > 50 then
						tag = tag1
					elseif tag2 > 50 then
						tag = tag2
					end

					self.hero.wall = math.ceil((tag-50) / 20)
					self.hero.standline = tag-50 - (self.hero.wall-1) * 20

					self.hero.contact = "wall"
					-- self.hero:getPhysicsBody():setGravityEnable(false)
					self.jump = false
					self.hero.speedY = 19
					self.hero:runaction("stand")
				end
			end

			if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
				local stoneY
				if tag1 == 3 then
					stoneY = contact:getShapeA():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				elseif tag2 == 3 then
					stoneY = contact:getShapeB():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				end
				if stoneY -hero_bottom > 3 then
					if self.hero.face == "right"  then					
						self.moveright = false
					elseif self.hero.face == "left" then
						self.moveleft = false
					end
				else
					self.hero.contact = "stone"
					self.jump = false
					self.hero.speedY = 19
					self.hero:runaction("stand")
				end
			end
		end

		if self.hero.action == "run" then
			if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
				local stoneY
				if tag1 == 3 then
					stoneY = contact:getShapeA():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				elseif tag2 == 3 then
					stoneY = contact:getShapeB():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				end
				if stoneY - hero_bottom > 3 then
					if self.hero.face == "right" then
						self.moveright = false
					elseif self.hero.face == "left" then
						self.moveleft = false
					end
				end
			end

			if tag1 == 1 and tag2 == 4 or tag1 == 4 and tag2 == 1 and not self.over then
				self.over = true
				self:CrossLevel()
			end
		end
		--碰到钉刺死亡
		if tag1 == 1 and tag2 == 5 or tag1 == 5 and tag2 == 1 then
			self.hero.state = "death-spike"
			heroDeath(self.hero.state)
		end

		if tag1 == 1 and tag2 == 6 or tag1 == 6 and tag2 == 1 then
			self.nowGold = self.nowGold +1
			other:setVisible(false)
		end

		if tag1 == 1 and tag2 == 7 or tag1 == 7 and tag2 == 1 then
			self.nowBody = self.nowBody + 1
			local frames = display.newFrames("cageb-sheet%d.png",1,4)
			local animation = display.newAnimation(frames,0.01)
			local animate = cc.Animate:create(animation)
			
			other:getPhysicsBody():setContactTestBitmask(0)
			other:runAction(animate)
			
			local babaSprite = display.newSprite("#baba-sheet0.png")
			babaSprite:setCameraMask(cc.CameraFlag.USER2)
			babaSprite:setPosition(cc.p(other:getPositionX(),other:getPositionY()))
			self:addChild(babaSprite,2)
			local babaFrames = display.newFrames("baba-sheet%d.png", 0, 2)
			local babaanimation = display.newAnimation(babaFrames,0.2)
			local babaP = cc.p(babaSprite:getPositionX(),babaSprite:getPositionY()+30)
			local babaanimate = cc.Animate:create(babaanimation)
			local moveup = cc.MoveTo:create(0.5, babaP)
			local spw = cc.Spawn:create(babaanimate,moveup)
			local rep = cc.RepeatForever:create(spw)
			babaSprite:runAction(rep)
		end

		if tag1 == 1 and tag2 == 8 or tag1 == 8 and tag2 == 1 then
			self.hero.state = "death-monster"
			heroDeath(self.hero.state)
		end	
		if tag1 == 1 and tag2 == 10 or tag1 == 10 and tag2 == 1 then
			if self.hero.action == "jump_down" and (self.hero:getPositionX()+self.hero:getContentSize().width/2) >= (other:getPositionX()-other:getContentSize().width/2) and (self.hero:getPositionX()-self.hero:getContentSize().width/2) <= (other:getPositionX()+other:getContentSize().width/2) then
				self.hero.jump = true
				self.hero.speedY = 22
				for k,v in pairs(self.MonsterTable) do
					if v.monsterSprite == other then
						table.remove(self.MonsterTable,k)
					end
				end
				Monsters:MonsterDeath(other)
			else
				self.hero.state = "death-spike"
				heroDeath(self.hero.state)
			end
		end
		if tag1 == 1 and tag2 == 11 or tag1 == 11 and tag2 == 1 then
			if self.hero.state == "protect" then
				other.fireRight = not other.fireRight
				self.isFire = true
			else
				self.hero.state = "death-monster"
				heroDeath(self.hero.state)
				other:setVisible(false)
			end
		end
	end


	local function onContactEnd(contact)
		
		if self.over then
			return
		end
		local tag1 = contact:getShapeA():getBody():getNode():getTag()
		local tag2 = contact:getShapeB():getBody():getNode():getTag()
		local hero,other
		if tag1 == 1 then
			hero = contact:getShapeA():getBody():getNode()
			other = contact:getShapeB():getBody():getNode()
		else
			hero = contact:getShapeB():getBody():getNode()
			other = contact:getShapeA():getBody():getNode()
		end
		local hero_bottom = self.hero:getPositionY()-self.hero:getContentSize().height/2

		if self.hero.action == "run" then
			if tag1 == 1 and tag2 == 3 or tag1 == 3 and tag2 == 1 then
				local stoneY
				if tag1 == 3 then
					stoneY = contact:getShapeA():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				elseif tag2 == 3 then
					stoneY = contact:getShapeB():getBody():getNode():getPositionY() + contact:getShapeA():getBody():getNode():getContentSize().height/2
				end
				if hero_bottom>stoneY then

					if self.hero.contact == "stone" then
						local stoneX
						local stoneWidth
						if tag1 == 3 then
							stoneX = contact:getShapeA():getBody():getNode():getPositionX()
							stoneWidth = contact:getShapeA():getBody():getNode():getContentSize().width
						elseif tag2 == 3 then
							stoneX = contact:getShapeB():getBody():getNode():getPositionX()
							stoneWidth = contact:getShapeB():getBody():getNode():getContentSize().width
						end
						if math.abs(self.hero:getPositionX() - stoneX) >= stoneWidth/2 then
							self.hero.speedY = 0
							self.jump = true
						end
					end
				end
			end

			if tag1 > 50 and tag2 == 1 or tag1 == 1 and tag2 > 50 then
				local tag = 0
				if tag1 > 50 then
					tag = tag1
				elseif tag2 > 50 then
					tag = tag2
				end
				local wallX
				local wallArray = self.map:getObjectGroup("wall"):getObjects()				
				local wallnum = math.ceil((tag-50) / 20)
				local heropos
				local maxpoint = #wallArray[wallnum].polylinePoints
				if self.hero.face == "right" then
					wallX = (wallArray[wallnum].x+wallArray[wallnum].polylinePoints[maxpoint].x)*1.6
					heropos = self.hero:getPositionX() - self.hero:getContentSize().width/2	
					if heropos > wallX then	
						self.hero.speedY = 0
						self.jump = true
					end
				elseif self.hero.face == "left" then
					wallX = (wallArray[wallnum].x+wallArray[wallnum].polylinePoints[1].x)*1.6
					heropos = self.hero:getPositionX() + self.hero:getContentSize().width/2	
					if heropos < wallX then	
						self.hero.speedY = 0
						self.jump = true
					end
				end
			end
		end

		if tag1 == 1 and tag2 == 6 or tag1 == 6 and tag2 == 1 then
			other:removeFromParent()
		end

	end

	self.contactListener = cc.EventListenerPhysicsContact:create()
	self.contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
	self.contactListener:registerScriptHandler(onContactEnd,cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithFixedPriority(self.contactListener, 1)
end

--通过当前关卡
function PlayScene:CrossLevel()

	--pause game
	cc.Director:getInstance():pause()
	--Pause Layer
	local crossLayer = display.newColorLayer(cc.c4b(0,0,0,200))
	self:addChild(crossLayer,3)
	--BGButton
	local boardPause = display.newSprite("game/boardwin-sheet0.png")
		:setPosition(cc.p(display.cx,display.cy*1.3))
		:addTo(crossLayer)

	local m1,m2,m3

	m1= display.newSprite("game/badgebaba-sheet2.png")
	m1:setPosition(cc.p(60,155))
	m1:addTo(boardPause,2)

	 if self.haveGold == self.nowGold then
	 	self.nowMedal = self.nowMedal + 1
	 	if self.haveGold == 0 then
	 		m2 = display.newSprite("game/badgebaba-sheet0.png")
	 	else
	 		m2 = display.newSprite("game/badgebaba-sheet2.png")
	 	end
	 else
	 	m2 = display.newSprite("game/badgebaba-sheet1.png")
	 end
	m2:setPosition(cc.p(60,105))
	m2:addTo(boardPause,2)

	 if self.haveBody == self.nowBody then
	 	self.nowMedal = self.nowMedal + 1
	 	if self.haveBody == 0 then
	 		m3 = display.newSprite("game/badgebaba-sheet0.png")
	 	else
	 		m3 = display.newSprite("game/badgebaba-sheet2.png")
	 	end
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
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			eventDispatcher:removeEventListener(self.contactListener)
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
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			eventDispatcher:removeEventListener(self.contactListener)
			local scene = self.new(self.nowNum)
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
			cc.Director:getInstance():resume()
			local scene = self.new(self.nowNum+1)
			display.replaceScene(scene,"fade",0.5)
		end)	



	self.levelinfo = {}
	self.levelinfo = GameData
	if self.self.levelinfo[tostring(self.nowNum)].medal < self.nowMedal then 
		self.levelinfo[tostring(self.nowNum)].medal = self.nowMedal   --得到的金牌数
	end
	if self.nowNum-1 == self.levelinfo.levelCrossNum then
		self.levelinfo.levelCrossNum = self.levelinfo.levelCrossNum + 1  --通过的关卡数+1
	end
	GameState.save(self.levelinfo)


end

function PlayScene:onEnter()
	-- body
end
function PlayScene:onExit()
	-- body
end
return PlayScene
