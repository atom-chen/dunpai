
local LevelScene = class("LevelScene", function()
    return display.newScene("LevelScene")
end)

function LevelScene:ctor()
	self:initUI()
end

function LevelScene:initUI()
	local levelbgsprite = display.newSprite("game/bglvlselect-sheet0.png")
		:align(display.BOTTOM_LEFT, 0, 0)
	levelbgsprite:setScale(display.width/levelbgsprite:getContentSize().width * 2,display.height/levelbgsprite:getContentSize().height * 1.7)

	cc.ui.UIScrollView.new({
        direction = cc.ui.UIScrollView.DIRECTION_BOTH,
        viewRect = {x = 0, y = 0, width = display.width, height = display.height}, -- 设置显示区域
    })
    :addScrollNode(levelbgsprite)
    :addTo(self)
    :pos(0,0)
    :setBounceable(false)
end

return LevelScene
