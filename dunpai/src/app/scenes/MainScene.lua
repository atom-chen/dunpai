local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local Button = import("app.scenes.Button")

function MainScene:ctor()
	self:initBG()
	self:initUI()
	
end

function MainScene:initBG()
	local mainbg = display.newSprite("game/mainbackground-sheet0.png")
	mainbg:setPosition(cc.p(display.cx,display.cy))
	mainbg:setScale(display.width/mainbg:getContentSize().width,display.height/mainbg:getContentSize().height)
	mainbg:addTo(self,1)
end

function MainScene:initUI()
	--gamelogo
	local gamelogo = display.newSprite("game/gamelogo-sheet0.png")
	gamelogo:setPosition(cc.p(display.cx,display.cy*1.3))
	gamelogo:setScale(2.4*(display.width/3)/gamelogo:getContentSize().width,2*(display.height/2)/gamelogo:getContentSize().height)
	gamelogo:addTo(self,2)
	local gamelogoScale = cc.ScaleBy:create(0.2,0.5)
	local callfunc = cc.CallFunc:create(function ()
		--play Button
		local playImages = {
			normal = "game/buttonnext-sheet0.png",
			pressed = "game/buttonnext-sheet1.png",
			disabled = "game/buttobnext-sheet2.png"
		}
		local playButton = cc.ui.UIPushButton.new(playImages, {scale9 = true})
			:setPosition(cc.p(display.cx,display.height/4))
			:addTo(self,2)	
			:setScale(0.5)
			:onButtonClicked(function (event)
				--跳转到选择关卡界面
				local scene = import("app.scenes.LevelScene").new()
				display.replaceScene(scene,"fade",1)
			end)
		local playscale = cc.ScaleBy:create(0.2, 2)
		local callfunc1 = cc.CallFunc:create(function ()
			--more Button
			local moreImages = {
				normal = "game/buttonmoregames-sheet0.png",
				pressed = "game/buttonmoregames-sheet1.png",
				disabled = "game/buttonmoregames-sheet2.png"
			}
			local moreButton = cc.ui.UIPushButton.new(moreImages, {scale9 = true})
				:setPosition(cc.p(display.width/3,display.height/3.5))
				:addTo(self,2)	
				:setScale(0.5)
				:onButtonClicked(function (event)
				
			end)

			local moreScale = cc.ScaleBy:create(0.2, 2)
			local callfunc2 = cc.CallFunc:create(function ()
				--credits Button
				local creditsImages = {
					normal = "game/buttoncredits-sheet0.png",
					pressed = "game/buttoncredits-sheet1.png",
					disabled = "game/buttoncredits-sheet2.png"
				}
				local creditsButton = cc.ui.UIPushButton.new(creditsImages, {scale9 = true})
					:setPosition(cc.p(display.width/1.6,display.height/3.5))
					:addTo(self,2)	
					:setScale(0.5)
					:onButtonClicked(function (event)
			
				end)
				local creditsscale = cc.ScaleBy:create(0.2, 2)
				creditsButton:runAction(creditsscale)
			end)
			local seq2 = cc.Sequence:create(moreScale,callfunc2)
			moreButton:runAction(seq2)

		end)
		local seq1 = cc.Sequence:create(playscale,callfunc1)
		playButton:runAction(seq1)
		

		
		
	end)
	local seq = cc.Sequence:create(gamelogoScale,callfunc)
	gamelogo:runAction(seq)

	--UIButton
	local button = Button.new()

	local Musicbutton = button:MusicButton()
	Musicbutton:setPosition(cc.p(display.right-80,display.top-25))
	Musicbutton:addTo(self,2)

	local SoundButton = button:SoundButton()
	SoundButton:setPosition(cc.p(display.right-30,display.top-25))
	SoundButton:addTo(self,2)


end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
