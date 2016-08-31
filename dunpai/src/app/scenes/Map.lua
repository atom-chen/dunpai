
display.addSpriteFrames("game/cagea-sheet.plist", "game/cagea-sheet.pvr.ccz")
display.addSpriteFrames("game/coin-sheet.plist", "game/coin-sheet.pvr.ccz")
display.addSpriteFrames("game/cageb-sheet.plist", "game/cageb-sheet.pvr.ccz")
display.addSpriteFrames("game/baba-sheet.plist", "game/baba-sheet.pvr.ccz")
-- display.addSpriteFrames("game/player-sheet.plist","game/player-sheet.pvr.ccz")
local Map = class("Map", function(nowNum)
	map = cc.TMXTiledMap:create("level/level"..nowNum..".tmx")
    return map
end)
function Map:ctor()
	self.wallnode = {}
	self.stonenode = {}
	self.goldnode = {}
	self.babynode = {}
	self.nextnode = {}
	self.spikenode = {}
	self.coinnode = {}
	self.bodynode = {}
	self:initUI()
end

function Map:initUI()
	local wallArray = self:getObjectGroup("wall"):getObjects()
	-- dump(wallArray[1])

	for i = 1,#wallArray do
		for j = 1,#wallArray[i].polylinePoints-1 do
			local point1 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j].x)*1.6,(wallArray[i].y - wallArray[i].polylinePoints[j].y)*1.6)
			local point2 = cc.p((wallArray[i].x+wallArray[i].polylinePoints[j+1].x) * 1.6,(wallArray[i].y - wallArray[i].polylinePoints[j+1].y)*1.6)
			local wallbody = cc.PhysicsBody:createEdgeSegment(point1,point2,cc.PhysicsMaterial(1.5,0,10))
			-- wallbody:setCategoryBitmask(0xFFFFFFFF)
			wallbody:setContactTestBitmask(0xFFFFFFFF)
			wallbody:getShape(0):setRestitution(0)
			-- wallbody:setCollisionBitmask(0xFFFFFFFF)
 			local node = display.newNode()
				:setCameraMask(cc.CameraFlag.USER2)
				-- :setPosition(point1)
	 			:setPhysicsBody(wallbody)
	 			:setTag(50+ 20*(i-1) + j)
	 			-- :addTo(self)
	 		table.insert(self.wallnode, node)
		end
	end


	
	--stone
	if self:getObjectGroup("stone") ~= nil then
		local stoneArray = self:getObjectGroup("stone"):getObjects()
		-- dump(stoneArray)
		for _,value in pairs(stoneArray) do
			local stonebody = cc.PhysicsBody:createEdgeBox(cc.size(value.width*1.45,value.height*1.45), cc.PHYSICSBODY_MATERIAL_DEFAULT)
			-- local stonebody = cc.PhysicsBody:createCircle(hero:getContentSize().width*0.6)
			stonebody:getShape(0):setRestitution(0)
			-- stonebody:setCategoryBitmask(0xFFFFFFFF)
			stonebody:setContactTestBitmask(0xFFFFFFFF)
			-- stonebody:setCollisionBitmask(0)
			-- stonebody:getShape(0):setFriction(0.5)
			-- stonebody:applyImpulse(cc.p(-150 * math.sqrt(2),150 * math.sqrt(2)))
			local node = display.newNode()
				:setPosition(cc.p(value.x*1.6+value.width*0.8+2, value.y*1.6+value.height*0.8+2))
				:setContentSize(cc.size(value.width*1.45,value.height*1.45))
	 			:setPhysicsBody(stonebody)
	 			:setTag(3)
	 		table.insert(self.stonenode, node)
		end
	end

	if self:getObjectGroup("spike") ~= nil then
		local spikeArray = self:getObjectGroup("spike"):getObjects()
		for _,value in pairs(spikeArray) do
			local spikebody = cc.PhysicsBody:createEdgeBox(cc.size(value.width*1.6,value.height), cc.PHYSICSBODY_MATERIAL_DEFAULT)
			spikebody:getShape(0):setRestitution(0)
			spikebody:setContactTestBitmask(0xFFFFFFFF)
			local node = display.newNode()
				:setPosition(cc.p(value.x*1.6+value.width*0.8+2, value.y*1.6+value.height*0.8+2))
				:setContentSize(cc.size(value.width*1.45,value.height*1.45))
	 			:setPhysicsBody(spikebody)
	 			:setTag(5)
	 		table.insert(self.spikenode, node)
		end
	end

	--coin
	if self:getObjectGroup("coin") ~= nil then
		local coinArray = self:getObjectGroup("coin"):getObjects()
		--dump(coinArray)
		for _,value in pairs(coinArray) do
			local coinSprite = display.newSprite("#coin-sheet5.png")
			local coinbody = cc.PhysicsBody:createCircle(coinSprite:getContentSize().width/2, cc.PHYSICSBODY_MATERIAL_DEFAULT)
			coinbody:getShape(0):setRestitution(0)
			coinbody:setContactTestBitmask(0xFFFFFFFF)
			coinbody:setCollisionBitmask(0x000000001)
			coinSprite:setPhysicsBody(coinbody)
			coinSprite:setPosition(cc.p(value.x*1.6+coinSprite:getContentSize().width/2,value.y*1.6+coinSprite:getContentSize().height/2))
			coinSprite:setTag(6)
	 		table.insert(self.coinnode, coinSprite)
		end
	end

		--body
	if self:getObjectGroup("body") ~= nil then
		local bodyArray = self:getObjectGroup("body"):getObjects()
		--dump(coinArray)
		for _,value in pairs(bodyArray) do
			local bodySprite = display.newSprite("#cageb-sheet0.png")
			bodySprite:setScale(1.3)
			local bodybody = cc.PhysicsBody:createEdgeBox(cc.size(bodySprite:getContentSize().width*1.1,bodySprite:getContentSize().height*1.2), cc.PHYSICSBODY_MATERIAL_DEFAULT)
			bodybody:getShape(0):setRestitution(0)
			bodybody:setContactTestBitmask(0xFFFFFFFF)
			bodybody:setCollisionBitmask(0x000000001)
			bodySprite:setPhysicsBody(bodybody)
			bodySprite:setPosition(cc.p(value.x*1.6+bodySprite:getContentSize().width/2,value.y*1.6+bodySprite:getContentSize().height/2))
			bodySprite:setTag(7)
			-- bodySprite.babaSprite = display.newSprite("#baba-sheet0.png")
			-- bodySprite.babaSprite:setPosition(cc.p(bodySprite:getPositionX(),bodySprite:getPositionY()))
			--self:addChild(babaSprite,2)
	 		table.insert(self.bodynode, bodySprite)
		end
	end



	--next
	local nextArray = self:getObjectGroup("next"):getObjects()
	for _,value in pairs(nextArray) do
		local nextsprite = display.newSprite("#cagea-sheet5.png")
		nextsprite:setScale(1.2)
		local nextbody = cc.PhysicsBody:createEdgeBox(cc.size(nextsprite:getContentSize().width*1.2,nextsprite:getContentSize().height*1.2), cc.PHYSICSBODY_MATERIAL_DEFAULT)
		-- nextbody:getShape(0):setRestitution(0)
		-- nextbody:setCategoryBitmask(0xFFFFFFFF)
		nextbody:setContactTestBitmask(0xFFFFFFFF)
		nextbody:setCollisionBitmask(0x000000001)
		-- nextbody:getShape(0):setFriction(0.5)
		-- nextbody:applyImpulse(cc.p(-150 * math.sqrt(2),150 * math.sqrt(2)))
		nextsprite:setPhysicsBody(nextbody)
		nextsprite:setTag(4)
		nextsprite:setPosition(cc.p(value.x*1.6+nextsprite:getContentSize().width/2, value.y*1.6+nextsprite:getContentSize().height/2- 10))
		table.insert(self.nextnode, nextsprite)
	end 
end

return Map


-- objPathline.x+objPathline.polylinePoints[1].x,objPathline.y-objPathline.polylinePoints[1].y
