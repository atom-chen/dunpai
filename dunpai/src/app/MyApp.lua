
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)

    GameState = require("framework.cc.utils.GameState")

    GameState.init(function (param)
    	local returnValue = nil
    	if param.errorCode then
    		print("error code: % d",param.errorCode)
    	else
    		--crypto
    		if param.name == "save" then
    			-- local str = json.encode(param.values)
    			-- str = crypto.encryptXXTEA(str,"abcd")
    			returnValue = {data = param.values}
    		elseif param.name == "load" then
    			-- local str = crypto.decryptXXTEA(param.values.data, "abcd")
    			returnValue = param.values.data
    		end
    	end
    	return returnValue
    end,"data.text","1234")

    GameData = GameState.load()or{level1 = {x = 390,y = 140,medal = 0},level2 = {x = 240,y = 140,medal = 0},
        level3 = {x = 140,y = 220,medal = 0},level4 = {x = 240,y = 300,medal = 0},level5 = {x = 340,y = 360,medal = 0},
        level6 = {x = 310,y = 445,medal = 0},level7 = {x = 440,y = 450,medal = 0},level8 = {x = 590,y = 420,medal = 0},
        level9 = {x = 480,y = 350,medal = 0},level10 = {x = 530,y = 230,medal = 0},level11 = {x = 630,y = 140,medal = 0},
        level12 = {x = 715,y = 190,medal = 0},levelCrossNum = 0,maxlevelNum = 12,isMusic = true,isSound = true}
    GameState.save(GameData)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
