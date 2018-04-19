require("app.utils.GameUtils")
require("app.utils.Player")
require("app.utils.net.HttpManager")
require("app.utils.TestProfile")
require("app.utils.GCMgr")
require("app.utils.TimeUtils")


Scene_arm_type = {
    normal = 1, -- 其他(默认)
    base = 2, -- 基地
    world = 3, -- 世界
    fight = 4, -- 战斗
    forver = 5, --永久
}

local LoginLayer = require("app.layer.login.LoginLayer")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    self:myInit()
    self:setContentSize(cc.size(display.width, display.height))

   	self:onUpdate(function (  )
       	-- 默认刷新普通的
        MArmatureUtils:updateMArmature(Scene_arm_type.normal)
        MArmatureUtils:updateMArmature(Scene_arm_type.forver)

        local hasFight = Player:getUIFightLayer()
        -- 判断是否在战斗界面中
        if(hasFight) then
            MArmatureUtils:updateMArmature(Scene_arm_type.fight)
        else
            local tmpHome = Player:getUIHomeLayer()
            if(tmpHome) then
                -- 展示至少一个全屏对话框中，跳过刷新
                if(tmpHome.pTmpLaySeqLayer and tmpHome.pTmpLaySeqLayer:isVisible()) then
                else
                    -- 展示基地中
                    if(tmpHome.pHomeContent and tmpHome.pHomeContent:isVisible()) then
                        if(tmpHome.pHomeBase and tmpHome.pHomeBase:isVisible()) then
                            MArmatureUtils:updateMArmature(Scene_arm_type.base)
                        else
                            MArmatureUtils:updateMArmature(Scene_arm_type.world)
                        end
                    else
                        
                    end
                end
            end
        end

        -- MViewPool:getInstance():autoPushByFreeTime()
        Gf_doRealMsgDeliver()
        gPerFrameUpdate()
   	end)

   	-- --RootLayerHelper引用
    local helper = RootLayerHelper:Instance()
    local loginLayer = LoginLayer.new()
    self:addChild(loginLayer, 10)
    helper:setCurScene(self)
    helper:setCurRootLayer(loginLayer)

    -- 1秒后才执行一部分数据
    doDelayForSomething(self, function (  )
        --注册按键事件
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            --新手引导不可退出
            if Player:getIsGuiding() == true then
                return
            end
            if (not self:backKeyboard()) then                
                if event.key == "back" then
--                    if N_PACK_MODE == 1000 then
----                        -- 测试服
----                        --local sTextureInfo = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
----						--TOAST(sTextureInfo)

----                        local s = string.format("当前内存:%sM, CheckCount:%s, time:%s", math.floor(collectgarbage("count")/1024), CheckCount, TimeCost)
----                        TOAST(s)
--                        package.loaded["app.debugOnRun"] = nil
--                        require("app.debugOnRun")
--                    else
                        -- 非测试服
                        showExitDialog()
--                    end
                end
            end

            if(device.platform == "windows") then
                if event.key == "47" then
                    --F1在线调试代码
                    package.loaded["app.debugOnRun"] = nil
                    require("app.debugOnRun")           
                elseif event.key == "53" then
                    --F7回收lua垃圾内存
                    collectgarbage("collect")
                elseif event.key == "54" then 
                    --F8打印lua使用的内存                  
                    print(string.format("当前lua内存:%s", math.floor(collectgarbage("count"))))
                elseif event.key == "55" then
                    --F9回收没被引用的纹理
                    removeUnusedTextures() 
                elseif event.key == "56" then
                    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
                    --F10打印纹理使用内存         
                elseif event.key == "58" then 
                    --F12执行网络断线                    
                    SocketManager._socket:close()
                end
            end

        end)
        self:setKeypadEnabled(true)
    end, 1)
end

function MainScene:myInit( )
    -- 记录切换到后台的时间
    n_last_background_time = getSystemTime()
end

function MainScene:onEnter()
    --取消推送
    cancelPushAlarms()
    -- 注册游戏切换后台和游戏恢复的消息
    regMsg(self, "ghd_APP_ENTER_BACKGROUND_EVENT", handler(self, self.onEnterBackground))
    regMsg(self, "ghd_APP_ENTER_FOREGROUND_EVENT", handler(self, self.onEnterForeground))
    regMsg(self, "ghd_APPSCREEN_SIZE_CHANGED", handler(self, self.onScreenSizeChanged))
end

function MainScene:onExit()
    -- 销毁游戏切换后台和游戏恢复的消息
    unregMsg(self, "ghd_APP_ENTER_BACKGROUND_EVENT")
    unregMsg(self, "ghd_APP_ENTER_FOREGROUND_EVENT")
    unregMsg(self, "ghd_APPSCREEN_SIZE_CHANGED")
    -- 一定要关闭socket
    SocketManager:close()
end

-- 游戏切换到后台
function MainScene:onEnterBackground(  )
    startPushAlarms()--开启推送
    -- 记录切换到后台的时间
    n_last_background_time = getSystemTime()
    self:backKeyboard()
    doUnloadFightEffect()
end
-- 回缩键盘
function MainScene:backKeyboard(  )
    local bSucceed = false
    -- 如果存在键盘暂时，关闭键盘展示
    local pRoot = RootLayerHelper:Instance():getCurRootLayer()
    if(pRoot and pRoot.closeKeyboard) then
        bSucceed = pRoot:closeKeyboard()
    end
    return bSucceed
end

-- 游戏恢复,这里只是一个临时的过度，用来控制数据别那么快加载而已
function MainScene:onEnterForeground(  )
    -- 记录恢复游戏状态的时间
    doPreloadFightEffect()
    n_last_foreground_time = getSystemTime()
    -- self:stopAllActions()
    doDelayForSomething(self,function (  )
        -- body
       self:onRealEnterForeground()
    end, 1)
end

-- 游戏恢复
function MainScene:onRealEnterForeground(  )
    --取消推送
    cancelPushAlarms()
    -- 判断到切换到后台的时间
    if(n_last_foreground_time and n_last_background_time and 
        n_last_foreground_time > n_last_background_time) then
        local fTempDis = n_last_foreground_time - n_last_background_time
        local nMaxTime = 60 * 60 * 1 -- 超过1个小时就重启
        if(fTempDis >= nMaxTime) then --超过1个小时
            -- 停留一定时间，然后重启
            if(Player:getUIHomeLayer() and Player:getUIHomeLayer().runAction) then
                Player:getUIHomeLayer():runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(function (  )
                        -- 直接显示重登对话框
                        showReconnectDlg(e_disnet_type.tok, false, true)
                    end)))
            end
        else
            sendMsg(ghd_backtoforeground_msg)
        end
    end
end

function MainScene:onScreenSizeChanged(  )
    -- 重置画布的
    cc.Director:getInstance():getOpenGLView():setFrameSize(
        cc.Director:getInstance():getNewWidth(),
        cc.Director:getInstance():getNewHeight())
    -- 优化画布的宽高发生变化，所以强制重新加载display中的数据
    destroyLuaLoaded("framework.display", true)
end

return MainScene
 