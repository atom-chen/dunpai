display.addSpriteFrames("game/firelik-sheet.plist", "game/firelik-sheet.pvr.ccz")
display.addSpriteFrames("game/tempa-sheet.plist", "game/tempa-sheet.pvr.ccz")
display.addSpriteFrames("game/enemybasic-sheet.plist", "game/enemybasic-sheet.pvr.ccz")
display.addSpriteFrames("game/fireball-sheet.plist", "game/fireball-sheet.pvr.ccz")

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
        local frames = display.newFrames("firelik-sheet0_%02d.png",1,9)
        local animation = display.newAnimation(frames,0.1)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)

    elseif self.Type == 2 then
        
        monsterSprite = display.newSprite("#tempa-sheet0_01.png")
        local frames = display.newFrames("tempa-sheet0_%02d.png",1,10)
        local animation = display.newAnimation(frames,0.1)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)
    elseif self.Type == 3 then
        
        monsterSprite = display.newSprite("#enemybasic-sheet0_01.png")
        local frames = display.newFrames("enemybasic-sheet0_%02d.png",1,4)
        local animation = display.newAnimation(frames,0.1)
        local animate = cc.Animate:create(animation)
        local rep = cc.RepeatForever:create(animate)
        monsterSprite:runAction(rep)
    end


    return monsterSprite
end

function Monsters:addfireball()
 
    local fireball = display.newSprite("#enemybasic-sheet0_01.png")
    local fireballBody = cc.PhysicsBody:createBox(fireball:getContentSize(),cc.PHYSICSBODY_MATERIAL_DEFAULT)
    fireballBody:setGravityEnable(false)
    fireball:setPhysicsBody(fireballBody)

    return fireball
end

function Monsters:fireballMoveRight(fireball)
    fireball:setPosition(cc.p(fireball:getPositionX()+2,fireball:getPositionY()))     
end
function Monsters:fireballMoveLeft(fireball)
    fireball:setPosition(cc.p(fireball:getPositionX()-2,fireball:getPositionY()))     
end



return Monsters