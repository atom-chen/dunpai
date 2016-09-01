display.addSpriteFrames("game/firelik-sheet.plist", "game/firelik-sheet.pvr.ccz")
display.addSpriteFrames("game/tempa-sheet.plist", "game/tempa-sheet.pvr.ccz")
display.addSpriteFrames("game/enemybasic-sheet.plist", "game/enemybasic-sheet.pvr.ccz")
display.addSpriteFrames("game/fireball.plist", "game/fireball.pvr.ccz")

local Monsters = class("Monsters", function(Type)
	local Monster = {}
    Monster.Type = Type  --怪物类型
    Monster.face = "right"     --怪物移动方向 0表示向右，1表示想左
    return Monster
end)


function Monsters:ctor()
    self.monsterSprite = self:addMonster()
end

function Monsters:addMonster()
    local monsterSprite
    if self.Type == 1 then
        
        monsterSprite = display.newSprite("#firelik-sheet0_01.png")
        monsterSprite:setTag(8)
        local MonsterBody = cc.PhysicsBody:createBox(monsterSprite:getContentSize(),cc.PhysicsMaterial(1.5,0,10))
        monsterSprite:setPhysicsBody(MonsterBody)
        MonsterBody:setContactTestBitmask(0xFFFFFFFF)
        
        local frames = display.newFrames("firelik-sheet0_%02d.png",1,9)
        local animation = display.newAnimation(frames,0.1)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)

    elseif self.Type == 2 then
        
        monsterSprite = display.newSprite("#tempa-sheet0_01.png")
        monsterSprite:setTag(9) 
        local MonsterBody = cc.PhysicsBody:createBox(monsterSprite:getContentSize(),cc.PhysicsMaterial(1.5,0,10))
        monsterSprite:setPhysicsBody(MonsterBody)
        MonsterBody:setContactTestBitmask(0xFFFFFFFF)  
        local frames = display.newFrames("tempa-sheet0_%02d.png",1,10)
        local animation = display.newAnimation(frames,0.05)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)
    elseif self.Type == 3 then
        
        monsterSprite = display.newSprite("#enemybasic-sheet0_01.png")
        monsterSprite:setTag(10) 
        local MonsterBody = cc.PhysicsBody:createBox(monsterSprite:getContentSize(),cc.PhysicsMaterial(1.5,0,10))
        monsterSprite:setPhysicsBody(MonsterBody)
        MonsterBody:setContactTestBitmask(0xFFFFFFFF)  
        local frames = display.newFrames("enemybasic-sheet0_%02d.png",1,4)
        local animation = display.newAnimation(frames,0.1)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)
    end
   -- monsterSprite:setCameraFlag(cc.CameraFlag.USER1)

    return monsterSprite
end


function Monsters:MoveLeft()
    self.monsterSprite:setPosition(cc.p(self.monsterSprite:getPositionX()-1,self.monsterSprite:getPositionY()))
end

function Monsters:MoveRight()
    self.monsterSprite:setPosition(cc.p(self.monsterSprite:getPositionX()+1,self.monsterSprite:getPositionY()))
end

function Monsters:MonsterDeath(node)
    local monster3frame = display.newSpriteFrame("enemybasic-sheet0_09.png")
    node:getPhysicsBody():setContactTestBitmask(0) 
    node:stopAllActions()
    node:setSpriteFrame(monster3frame)
    node:performWithDelay(function ()
        node:removeFromParent()
    end, 0.5)
end

function Monsters:addfireball()
  --  print("fire")
    local fireball = display.newSprite("#fireball-sheet0_01.png")
    local fireballBody = cc.PhysicsBody:createBox(fireball:getContentSize(),cc.PHYSICSBODY_MATERIAL_DEFAULT)
    fireballBody:setGravityEnable(false)
    fireballBody:setContactTestBitmask(0xFFFFFFFF)
    fireball:setPhysicsBody(fireballBody)
    fireball:setTag(11)
    return fireball
end


-- function Monsters:fireballMoveRight(fireball)
--     fireball:setPosition(cc.p(fireball:getPositionX()+2,fireball:getPositionY()))     
-- end
-- function Monsters:fireballMoveLeft(fireball)
--     fireball:setPosition(cc.p(fireball:getPositionX()-2,fireball:getPositionY()))     
-- end



return Monsters