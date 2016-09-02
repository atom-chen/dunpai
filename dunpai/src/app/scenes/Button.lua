display.addSpriteFrames("game/bmusic-sheet0.plist","game/bmusic-sheet0.png")
display.addSpriteFrames("game/bsfx-sheet0.plist","game/bsfx-sheet0.png")

local Button = class("Button", function()
	local Button = {}
    return Button
end)

function Button:ctor()
	self.gamedata = {}
	self.gamedata = GameData
	

end

function Button:MusicButton()
	--Music UI
	local musicImage = {
		on = "#bmusic-sheet001.png",
		off = "#bmusic-sheet003.png"
	}


	local musicCheckButton = cc.ui.UICheckBoxButton.new(musicImage)
	musicCheckButton:setButtonSelected(self.gamedata.isMusic)
	if self.gamedata.isMusic then
		audio.resumeMusic()
	else
		audio.pauseMusic()
	end

	musicCheckButton:onButtonClicked(function ()
		self.gamedata.isMusic = not self.gamedata.isMusic
		GameState.save(self.gamedata)
		if self.gamedata.isMusic then
			audio.resumeMusic()
		else
			audio.pauseMusic()
		end
	end)
	

	return musicCheckButton

	
end

function Button:SoundButton()
	--Sound UI
	local SoundImage = {
		on = "#bsfx-sheet001.png",
		off = "#bsfx-sheet004.png"
	}

	local SoundCheckButton = cc.ui.UICheckBoxButton.new(SoundImage)
	SoundCheckButton:setButtonSelected(self.gamedata.isSound)
	if self.gamedata.isSound then
		audio.resumeAllSounds()
	else
		audio.pauseAllSounds()
	end
	SoundCheckButton:onButtonClicked(function ()
		self.gamedata.isSound = not self.gamedata.isSound
		GameState.save(self.gamedata)
		if self.gamedata.isSound then
			audio.resumeAllSounds()
		else
			audio.pauseAllSounds()
		end
	end)

	return SoundCheckButton
end

function Button:ReturnButton()
	--return menu
	local ReturnImage = {
		normal = "game/buttonmainmenu-sheet0.png",
		pressed = "game/buttonmainmenu-sheet1.png"
	}
	local ReturnButton = cc.ui.UIPushButton.new(ReturnImage)
		:onButtonClicked(function ()
			local scene = import("app.scenes.MainScene").new()
			display.replaceScene(scene,"fade",0.5)
		end)

	return ReturnButton
end

function Button:PauseButton()
	local PauseImage = {
		normal = "game/bpause-sheet0.png",
		pressed = "game/bpause-sheet1.png",
		disabled = "game/bpause-sheet2.png"
	}
	local PauseButton = cc.ui.UIPushButton.new(PauseImage)



	return PauseButton
end




return Button