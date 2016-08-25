display.addSpriteFrames("game/firelik-sheet.plist", "game/firelik-sheet.pvr.ccz")
display.addSpriteFrames("game/tempa-sheet.plist", "game/tempa-sheet.pvr.ccz")
display.addSpriteFrames("game/enemybasic-sheet.plist", "game/enemybasic-sheet.pvr.ccz")

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
    display.addSpriteFrames("game/fireball-sheet.plist", "game/fireball-sheet.pvr.ccz")
    local fireball = display.newSprite("#enemybasic-sheet0_01.png")
    local frames = display.newFrames("enemybasic-sheet0_%02d.png",1,6)
    local animation = display.newAnimation(frames,0.1)
    local animate = cc.Animate:create(animation)
    local rep = cc.RepeatForever:create(animate)
    fireball:runAction(rep)

    return fireball
end

function Monsters:firefireball()
    local fireball = self:addfireball()
        :setPosition(cc.p(display.cx,display.cy))
        :addTo(self)
    fireball:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
        if self.move == 0 then
            fireball:setPosition(cc.p(fireball:getPositionX()+2,fireball:getPositionY()))
        else
            fireball:setPosition(cc.p(fireball:getPositionX()-2,fireball:getPositionY()))
        end
    end)
end


return Monsters