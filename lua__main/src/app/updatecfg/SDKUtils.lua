----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-07-25 15:13:58 
-- Description: 用于和SDK对接的内容
-----------------------------------------------------
local sErrorTag = "error=====>"
local tSDKLoginData = nil -- SDK登录之后返回的数据
local hasShowLogin = false -- 是否已经执行过登录行为了
-- SDK初始化的状态
-- 0是初始化失败，1是初始化成功
SDK_INIT_STATE = 0
-- SDK初始化回调
-- _data(string): 当前初始化状态的回调
-- 0: 初始化成功 继续游戏
-- 1: 初始化成功 同时用户自动登录成功，不要再次调用登录接口
-- 2: 初始化失败 建议在有网络的情况下再次调用，失败还是失败，建议重启游戏或者退出游戏
function getInitSDKState( )
    local _data = nil
    if(device.platform == "android") then
        local className = "com/game/quickmgr/QuickMgr"
        local methodName = "getInitSDKState"
        local result, ret = luaj.callStaticMethod(className, methodName, {}, "()I");
        if result then
            _data = ret or _data
        end
    elseif(device.platform == "ios") then
        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", "getInitSDKState", nil)
        if(bOk and sValue) then
            _data = tonumber(sValue)
        end
    end
    if(_data ~= nil) then
        _data = tonumber(_data)
        if(_data == 0 or _data == 1) then
            SDK_INIT_STATE = 1
        else
            SDK_INIT_STATE = 0
        end
    else
        SDK_INIT_STATE = 0
    end
    if(SDK_INIT_STATE == 0) then
        if(device.platform == "ios") then -- 关闭提示(ios sdk初始化较慢)
        else
            sdkShowTip("SDK初始化失败")
        end
    end
end
-- SDK登录回调
-- _data(string): json格式的返回数据
function onSDKLoginResult( _data )
    if(not _data or string.len(_data) <= 0) then
    	sdkShowTip("登录数据异常")
    	return
    end
    local json = require("framework.json")
    local result = json.decode(_data)
    if result == nil then
    	sdkShowTip("登录数据解析失败")
        return
    end
    if(result.platformId == nil or result.platformUrl == nil) then
    	sdkShowTip("请填写游戏的platformId和platformUrl")
    	return
    end
    if(result.token == nil) then
    	sdkShowTip("登录令牌获取失败")
    	return
    end
    -- 保存登录数据
    tSDKLoginData = result
    AccountCenter.platformData = tSDKLoginData
    if (tSDKLoginData.guid) then
        AccountCenter.guid = tSDKLoginData.guid  -- guid
    end
    local pToken = json.decode(tSDKLoginData.token)
    if pToken then
        AccountCenter.guid = pToken.guid or AccountCenter.guid -- guid
    end
    -- 执行登录行为
    if(hasShowLogin == true) then
        loadSeverList()
    end
end
-- 展示SDK登录框
-- _pView(CCNode): 用于未初始化时的不间断检测
-- _bForce(bool): 是否强制展示登录框
function showSDKLoginView( _pView, _bForce)
    if(hasShowLogin == true and not _bForce) then
        return
    end
    -- 执行初始化状态的访问
    getInitSDKState()
    if(SDK_INIT_STATE == 1) then
        -- 如果是强制弹出登录框
        if(_bForce) then
            -- 清空登录数据
            resetSDKLoginData()
            -- 重置已经展示过登录框
            hasShowLogin = true
            if(device.platform == "android") then
                local className = "com/game/quickmgr/QuickMgr"
                local methodName = "doSDKRelogin"
                local result, ret = luaj.callStaticMethod(className, methodName, {}, "()V");
            elseif(device.platform == "ios") then
                local luaoc = require("framework.luaoc")
                luaoc.callStaticMethod("PlatformSDK", "doSDKLogin", nil)
            end
        else
            hasShowLogin = true
            -- 如果已经自动登录成功
            if(tSDKLoginData) then
                -- 加载服务器列表
                loadSeverList()
            else
                -- 展示SDK登录框
                if(device.platform == "android") then
                    local className = "com/game/quickmgr/QuickMgr"
                    local methodName = "doSDKLogin"
                    local result, ret = luaj.callStaticMethod(className, methodName, {}, "()V");
                    if result then
                        data = ret or data
                    end
                elseif(device.platform == "ios") then
                    local luaoc = require("framework.luaoc")
                    luaoc.callStaticMethod("PlatformSDK", "doSDKLogin", nil)
                end
            end
        end
    else
        _pView:performWithDelay(function (  )
            showSDKLoginView(_pView, _bForce)
        end, 0.2)
    end
end
-- 加载服务器列表
function loadSeverList(  )
    local url = nil
    local param = {}
    -- 获取平台相关数据
    for k, v in pairs(tSDKLoginData) do
        if v ~= nil then
            if k == "platformUrl" then
                url = v
            else
                param[k] = v
            end
        end
    end
    -- showLoadingDlg(-2, false, 0, 15)
    showUnableTouchDlg()
    HttpManager:doGetFunctionToHttpServer(url, param, function ( _event )
        if _event.name == "completed" then
            -- hideLoadingDlg()
            hideUnableTouchDlg()
            -- 解析登录帐号服后的数据
            if(AccountCenter) then
                AccountCenter.parseAccountInfo(_event.data)
                -- 发送消息告知界面刷新
                sendMsg(gud_sdkloginsucceed)
            else
                sdkShowTip("AccountCenter还没有完成初始化")
            end
        elseif _event.name == "failed" then
            -- hideLoadingDlg()
            hideUnableTouchDlg()
            sdkShowTip("获取游戏服列表失败，请重试")
            -- 强制显示重登界面
            showSDKLoginView(Player:getUILoginLayer(), true)
        end
    end)
end
-- 实名认证回调
-- _data(string): 当前年龄的字符串值
function onSDKRealNameAuthSuccess( _data )
    
end
-- SDK注销回调
-- _data(string): 注销状态的返回值, 1是注销成功，其他值为注销失败
function onSDKLogoutResult( _data )
    
end
-- SDK退出游戏
function onSDKExitGame( _data )
    doExitGame()
end
-- 防沉迷回调
-- _data(string): 防沉迷的状态值返回
-- 0 暂无此用户信息
-- 1 您也许可以采取防沉迷策略
-- 2 您也许可以适当提醒用户
function onSDKAdultResult( _data )

end
-- 充值回调
-- _data(table): 充值返回的内容{tip=???, state=???}
--              state(int): 0为充值成功，其他为充值失败
--              tip(string): 提示语
function onSDKRechargeResult( _data )

end
-- 重登回调
-- _data(table): 重登返回的内容{tip=???, state=???}
--              state(int): 
--                  0  表示用户切换成功，1 败 表示登录失败 （ 用户已注销）
--                  3  表示用户修改密码成功 4  登录成功，登录回调接口返回用户信息。
--                  1 到 4  表示 sdk  登录界面已经打开 ，不要再次调用登录接口。
--              tip(string): 提示语
function onSDKReloginResult( _data )
    if(_data and json) then
       local tData = json.decode(_data)
        if(tData.state == 0) then
            if(AccountCenter) then
                -- 切换回登录界面
                AccountCenter.backToLoginScene(2)
            end
        end
    end
end
-- 提交3k数据
-- @param submitType(int) 1 角色登陆 2 角色创建 3 角色升级 4 退出游戏
function doSummitData3k( _type )
    if AccountCenter.isNormalLogin then
        return
    end
    local params = {}
    params.roleId = Player:getPlayerInfo().pid .. "" -- 角色ID
    params.roleName = Player:getPlayerInfo().sName -- 角色名称
    params.roleLevel = Player:getPlayerInfo().nLv -- 角色等级
    params.serverId = AccountCenter.nowServer.id -- 订单创建服务器
    params.serverName = AccountCenter.nowServer.ne -- 服务器名称
    params.vipLevel = Player:getPlayerInfo().nVip -- vip等级
    params.balance = Player:getPlayerInfo().nMoney -- 玩家拥有的金币数
    params.crTime = Player:getPlayerInfo().sCreateDate -- 角色创建时间
    params.power = Player:getPlayerInfo().nScore -- 角色创建时间
    --先占位，免得到时候添加
    params.gender = ""
    params.professionid = 0
    params.profession = ""
    params.partyid = ""
    params.partyname = ""
    params.partyroleid = 0
    params.partyrolename = ""
    if(device.platform == "android") then
        local className = "com/game/quickmgr/QuickMgr"
        local methodName = "doSubmitData"
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {_type, json.encode(params)}, 
            "(ILjava/lang/String;)V");
    elseif(device.platform == "ios") then
        params.submitType = _type
        local luaoc = require("framework.luaoc")
        luaoc.callStaticMethod("PlatformSDK", "doSubmitData", params)
    end
end
-- 重置SDK登录后的数据
function resetSDKLoginData(  )
	tSDKLoginData = nil -- SDK登录之后返回的数据
    hasShowLogin = false
end
-- 展示提示语
function sdkShowTip( _str )
	print(sErrorTag, _str)
	if(TOAST) then
		TOAST(_str)
	end
end

-- 打开sdk浮标
-- _bShow: 是否关闭
function showSDKFloatIcon( _bShow )
    if (_bShow == true) then
        if device.platform == "android" then
            -- local className = "com/andgame/quicksdk/SDKBridge"
            -- local methodName = "showSDKFloatIcon"
            -- luaj.callStaticMethod(className, methodName, {}, "()V");
        elseif device.platform == "ios" then
            local luaoc = require("framework.luaoc")
            luaoc.callStaticMethod("PlatformSDK", "showSDKFloatIcon", nil)
        end
    end
end