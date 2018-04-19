
require("app.config")
require("cocos.init")
require("framework.init")
require("cocos.myui.MInit")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    self:enterScene("MainScene")
    --self:enterScene("TestScene")
end

return MyApp
