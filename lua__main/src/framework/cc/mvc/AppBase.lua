
local AppBase = class("AppBase")

AppBase.APP_ENTER_BACKGROUND_EVENT = "APP_ENTER_BACKGROUND_EVENT"
AppBase.APP_ENTER_FOREGROUND_EVENT = "APP_ENTER_FOREGROUND_EVENT"
AppBase.APP_SCREEN_SIZE_CHANGED = "applicationScreenSizeChanged"

function AppBase:ctor(appName, packageRoot)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.name = appName
    self.packageRoot = packageRoot or "app"

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create(AppBase.APP_ENTER_BACKGROUND_EVENT,
                                handler(self, self.onEnterBackground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create(AppBase.APP_ENTER_FOREGROUND_EVENT,
                                handler(self, self.onEnterForeground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
    local customListenerSize = cc.EventListenerCustom:create(AppBase.APP_SCREEN_SIZE_CHANGED,
                                handler(self, self.onScreenSizeChanged))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerSize, 1)

    self.snapshots_ = {}

    -- set global app
    app = self
end

function AppBase:run()
end

function AppBase:exit()
    cc.Director:getInstance():endToLua()
    if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    end
end

function AppBase:enterScene(sceneName, args, transitionType, time, more)
    local scenePackageName = self.packageRoot .. ".scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.replaceScene(scene, transitionType, time, more)
end

function AppBase:createView(viewName, ...)
    local viewPackageName = self.packageRoot .. ".views." .. viewName
    local viewClass = require(viewPackageName)
    return viewClass.new(...)
end

function AppBase:onEnterBackground()
    sendMsg("ghd_APP_ENTER_BACKGROUND_EVENT")
    self:dispatchEvent({name = AppBase.APP_ENTER_BACKGROUND_EVENT})
end

function AppBase:onEnterForeground()
    sendMsg("ghd_APP_ENTER_FOREGROUND_EVENT")
    self:dispatchEvent({name = AppBase.APP_ENTER_FOREGROUND_EVENT})
end
function AppBase:onScreenSizeChanged(  )
    -- 发送消息告知界面宽高发生变化
    sendMsg("ghd_APPSCREEN_SIZE_CHANGED")
end

return AppBase
