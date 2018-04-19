-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-15 15:13:12 星期三
-- Description: 帐号中心
-----------------------------------------------------

--用户中心
AccountCenter = {}

--服务器状态
--en_server_state.login
en_server_state = {
    normal = 1, --正常
    maintain = 3, --维护
    recomm = 4, --推荐服
    full = 7,    --爆满
    login = 8,   --最近登录服
    last = 10,   --最后一次登录服务器
}


-- 初始化帐号数据
function AccountCenter.initAcountData()
    -- 用户名
    AccountCenter.acc = ""
    -- 密码
    AccountCenter.pass = ""
    -- token
    AccountCenter.token = ""

    -- 服务器id
    AccountCenter.serverId = ""
    -- 服务器名称
    AccountCenter.serverName = ""
    -- 所有服
    AccountCenter.allServer = {}
    -- 已登录服列表
    AccountCenter.enterServerList = {}
    -- 最近登陆服
    -- AccountCenter.recentServer = {}
    -- 推荐服
    AccountCenter.recommendServer = {}
    -- 最后登录服
    AccountCenter.lastLoginServer = {}
    -- 合服服务器列表
    AccountCenter.unionServerList = nil
    -- 临时合服服务器
    AccountCenter.tempUnionServer= nil
    -- rl 字段解析
    --{pid 每个服务器独有的id(未出现过为0)  sid 对应服务器列表中的id oldservername 未合服前的服务器名称  }

    --server解析字段
    --{ad 服务器地址;  id 服务器id编号 label 服务器状态  ne 服务器名称-- sort排名
    -- tLabel 服务器类型  hr 是否有角色角色 }

    --当前服
    AccountCenter.nowServer = {}

    -- 平台id
    AccountCenter.platformlId = ""
    -- 平台数据(table)
    AccountCenter.platformData = nil

    -- 所有服id和名称字典,用于聊天服号转名字
    AccountCenter.allServerNameDict = {}
end

-- 初始化包数据
function AccountCenter.initPackageData()

    -- 平台ID
    AccountCenter.subcid = S_KKK_PLAT_CHANNELID_DEFAULT -- 在launcher中有默认值
    -- 平台子包id
    AccountCenter.subpcid = S_KKK_CHILD_CHANNELID_DEFAULT -- 在launcher中有默认值
    -- 平台类型
    AccountCenter.os = 1 -- android是1，ios是2，3是ios越狱
    -- 登录类型
    AccountCenter.isNormalLogin = true
    -- mac
    AccountCenter.mac = S_MAC_DEFAULT -- 在launcher中有默认值
    -- imei
    AccountCenter.imei = S_IMEI_DEFAULT -- 在launcher中有默认值
    -- 设备的名称
    AccountCenter.sDevModel = "win32" -- 设备类型名称
    -- 获取idfa值，ios是指idfa标识，android是指android特殊的唯一标识
    AccountCenter.sIdfa = "0"
    -- 包的类型
    -- AccountCenter.nPackMode = N_PACK_MODE -- 在launcher中有默认值
    -- 是否切换帐号的时候需要延迟
    -- AccountCenter.bNeedToDelayWhenChangeCount = false
    -- 延迟执行的时间
    -- AccountCenter.fNeedDelayTime = 0.5
    -- 是否需要重新加载初始化时的数据
    -- AccountCenter.bReloadInit = false
    -- 是否需要提交新手引导步骤
    -- AccountCenter.bSubmitGuide = false
    -- 当前apk或者ipa的版本号
    AccountCenter.sPackageVer = ""
     -- 当前apk或者ipa的版本号名字
    AccountCenter.sPackageVerName = ""
    -- 是否使用SDK的退出对话框
    -- AccountCenter.bUsingSDKExit = false
    -- 当前游戏资源版本号
    AccountCenter.sPackResVer = ""
    AccountCenter.rn_sdk_age = 0 -- 实名认证年龄默认值
end

-- 更新包数据
function AccountCenter.updatePackageData()
    -- 更新mac
    local mac = getStringDataCfg("mac")
    if mac and string.len(mac) > 0 and mac ~= "0" then
        AccountCenter.mac = mac
    end
    -- 更新imei
    local imei = getStringDataCfg("imei")
    if imei and string.len(imei) > 0 and imei ~= "0" then
        AccountCenter.imei = imei
    end
    -- 更新subcid
    local channelId = getStringDataCfg(KKK_PLATFORM_ID)
    if channelId then
        AccountCenter.subcid = tostring(channelId)
    end
    -- 更新subcid
    channelId = getStringDataCfg(KKK_PLATFORM_CHILD_ID)
    if channelId then
        AccountCenter.subpcid = tostring(channelId)
    end
    -- 包的版本号
    AccountCenter.sPackageVer = getStringDataCfg("bundleVersion") or ""
    if(AccountCenter.sPackageVer == "0") then
        AccountCenter.sPackageVer = ""
    end
    -- 包的版本名
     AccountCenter.sPackageVerName = getStringDataCfg("bundleVersionName") or ""
    if(AccountCenter.sPackageVerName == "0") then
        AccountCenter.sPackageVerName = ""
    end
    -- 记录本地资源版本号
    local sResVer, tInstallVersions = getPackageResVer()
    AccountCenter.sPackResVer = sResVer
    -- 平台判断
    if(device.platform == "android") then
        AccountCenter.os = 1

        -- 获取model类型
        -- local className = "org/cocos2dx/lib/Cocos2dxHelper"
        -- local methodName = "getDeviceModel"
        -- local result, ret = luaj.callStaticMethod(className, 
        --     methodName, {}, "()Ljava/lang/String;")
        -- if(result) then
        --     AccountCenter.sDevModel = ret or AccountCenter.sDevModel
        --     -- 过滤空格符号
        --     if(string.find(AccountCenter.sDevModel, " ")) then
        --        AccountCenter.sDevModel = string.gsub(AccountCenter.sDevModel, " ", "")
        --     end
        -- end
        -- --
        -- local lz  = require("zlib")
        -- -- 获取android的唯一标识
        -- local className = "com/andgame/plane/sdkmgr/Utils"
        -- local methodName = "getDownloadPath"
        -- result, ret = luaj.callStaticMethod(className, 
        --     methodName, {}, "()Ljava/lang/String;")
        -- if(result) then -- 如果获取到了数据
        --     local sDir = ret
        --     if(sDir and string.find(sDir, ".wmDownLoad")) then
        --         sDir = string.gsub(sDir, ".wmDownLoad", "360GuideSafe")
        --     end
        --     -- 路径不存在，增加路径
        --     if(not isFileOrDirExist(sDir)) then
        --         lfs.mkdir(sDir)
        --     end
        --     local sFileKey = "finish"
        --     local sPath = sDir .. "/3DS99IIDO00SDLD3F"
        --     -- 文件不存在，创建唯一标识，放到文件中
        --     if(not isFileOrDirExist(sPath)) then
        --         local mode = mode or "w+b"
        --         local file = io.open(sPath, mode)
        --         if file then
        --             local content = AccountCenter.imei .. "__"
        --                 .. AccountCenter.mac .. "__"
        --                 .. getSystemTime(false)
        --             content = crypto.md5(content)
        --             -- 加密文件
        --             local dbzip,eof = lz.deflate()(content, sFileKey)
        --             io.writefile(sPath, dbzip)
        --         end
        --     end
        --     -- 存在文件，获取内容
        --     if(isFileOrDirExist(sPath)) then
        --         local data = CCFileUtils:sharedFileUtils():getFileData(sPath)
        --         local dbZip = lz.inflate()(data, sFileKey)
        --         AccountCenter.sIdfa = dbZip or AccountCenter.sIdfa
        --     end
        -- end
    elseif(device.platform == "ios") then -- Ios
        AccountCenter.os = 2
        --这里以后需要判断是否是越狱平台
        -- if 越狱 then
        --      AccountCenter.os = 3
        -- end

        AccountCenter.sDevModel = "iphone"
        AccountCenter.sIdfa = getStringDataCfg("idfa") or AccountCenter.sIdfa
    else -- windows
        AccountCenter.os = 1
    end
    -- 是否使用SDK的登录系统
    local sdkLoginState = getStringDataCfg("sdklogin")
    AccountCenter.isNormalLogin = sdkLoginState == "0"
    -- 浮标控制
    AccountCenter.resetSDKFubiaoPos()
end

--[[
解析账号信息
@param ：_data(table) 账号服返回的账号信息  
]]
function AccountCenter.parseAccountInfo( data )
    --账号密码错误
    -- if (data and data.s and tonumber(data.s) == 10)  then
    --     return false
    -- end
    -- -- 不存在该渠道
    -- if (data and data.s and tonumber(data.s) == 11)  then
    --     return false
    -- end
    -- -- 帐号被锁定
    -- if (data and data.s and tonumber(data.s) == 6)  then
    --     return false
    -- end

    --非成功状态下
    if (data and data.s and tonumber(data.s) ~= 0)  then
        return false
    end

    local tData = data.r

    -- 判断是否为白名单帐号
    if(tData and tData.isWhite ~= nil) then
        b_is_white_account = tData.isWhite
    end
    
    -- 账号
    AccountCenter.acc = tData.ac
    -- token
    AccountCenter.token = tData.key

    -- 清空服务器列表
    clearTableArray(AccountCenter.allServer)
    -- clearTableArray(AccountCenter.recentServer)
    clearTableArray(AccountCenter.recommendServer)
    clearTableArray(AccountCenter.lastLoginServer)
    clearTableArray(AccountCenter.nowServer)
    clearTableArray(AccountCenter.enterServerList)--已经登录过的服务器列表

    --分离服务器类型
    AccountCenter.allServerNameDict = {}
    if tData.gsl and table.nums(tData.gsl) > 0 then
        for i, server in ipairs(tData.gsl) do
            table.insert(AccountCenter.allServer, server) --所有服
            if server.id and server.ne then
                AccountCenter.allServerNameDict[server.id] = server.ne
            end
        end
    end
    local tFirstSever = nil
    for k,v in pairs(AccountCenter.allServer) do
        local tServerState = AccountCenter.analyzeSerLabel(v.label)
        -- dump(tServerState,"tServerState")
        if tServerState and table.nums(tServerState)> 0 then
            v.tState = tServerState --记录服务器状态列表
            -- 记录第一个服,防止没有推荐服和最后登录服的情况
            if(not tFirstSever) then
                tFirstSever = v
            end
            for x,y in pairs(tServerState) do
                --最后登录服
                if y == en_server_state.last then
                   AccountCenter.lastLoginServer = v
                end
                --推荐服
                if y == en_server_state.recomm then
                     AccountCenter.recommendServer = v
                end

                --先取推荐服
                if table.nums(AccountCenter.recommendServer)> 0 then
                    AccountCenter.nowServer = AccountCenter.recommendServer
                end

                --如果有最后登录服,拿最后登录服为登录服务器
                if table.nums(AccountCenter.lastLoginServer)> 0 then
                    AccountCenter.nowServer = AccountCenter.lastLoginServer
                end
                

            end
        end
    end
    -- 如果没有当前服,设置为第一个服，防止没有推荐服和最后登录服的情况
    if(not AccountCenter.nowServer or table.nums(AccountCenter.nowServer) <= 0) then
        AccountCenter.nowServer = tFirstSever
    end

    --已登录服务器列表数据
    if tData.rl and table.nums(tData.rl) > 0 then
        for i, server in ipairs(tData.rl) do
            local pServer = {}
            for k,v in pairs(AccountCenter.allServer) do
                if server.sid == v.id then
                    pServer = copyTab(v)
                    pServer.name = server.name
                    pServer.lv = server.lv
                    pServer.vip = server.vip

                    pServer.nRecent = 0 -- 用于我的服务器列表中最近服的排序
                    if pServer.tState and table.nums(pServer.tState)> 0 then
                       for k,v in pairs(pServer.tState) do
                           if v == en_server_state.last then
                                pServer.nRecent = 1 --默认是0,1可以获得优先排序
                                break
                           end
                       end
                    end
                    table.insert(AccountCenter.enterServerList,pServer)
                end
            end
        end
    end     

    if table.nums(AccountCenter.allServer) <= 0 then
        local DlgAlert = require("app.common.dialog.DlgAlert")
        local text = tData.serverNullTip or getConvertedStr(1, 10276)

        AccountCenter.serverNullTip = text -- 未开服提示
        local pDlg = DlgAlert.new()
        if tData.serverNullTip then
            pDlg:setContentLetter(text, nil, 20, 400, 0, cc.p(0, 0.5))
        else
            pDlg:setContent(text)
        end
        pDlg:setTitle(getConvertedStr(1, 10218))
        if (device.platform == "ios") then
            pDlg:setOnlyConfirm(getConvertedStr(1, 10059))
        else
            pDlg:setOnlyConfirm(getConvertedStr(1, 10277))
        end
        if(pDlg.pLayAClose) then
            pDlg.pLayAClose:setVisible(false)
        end
        pDlg:setRightHandler(function (  )
            doExitGame()
        end)
        -- 设置外部不能点击关闭对话框
        pDlg:setIsNeedOutside(false)
        pDlg:showDlg()
    end
    
    return true
end

-- 解析服务器列表label字段
-- _label:1_2_3_4_5_6 (类似这样的字段)
function AccountCenter.analyzeSerLabel( _label )
    -- body
    local tLabel = {}
    if _label and #_label > 0 then
        local tParam = luaSplit(_label,"_")
        
        if tParam and table.nums(tParam) > 0 then
            for k,v in pairs(tParam) do
                table.insert(tLabel,tonumber(v))
            end

            -- for k, v in pairs(tParam) do
            --     local temp = tonumber(v)
            --     if temp == 1 then
            --         tLabel.normal = 1 --正常
            --     elseif temp == 3 then 
            --         tLabel.maintain = 3 --维护
            --     elseif temp == 4 then 
            --         tLabel.recomm = 4 --推荐服
            --     elseif temp == 7 then
            --         tLabel.full = 7    --爆满
            --     elseif temp == 8 then
            --         tLabel.login = 8   --最近登录服
            --     elseif temp == 10 then 
            --         tLabel.last = 10   --最后一次登录服务器
            --     -- elseif temp == 11 then
            --         -- tLabel.prevue = 11                    
            --     end
            -- end
        end

    end

    -- dump(tLabel,"tLabel=",10)
    return tLabel
end

--AnalysisServer 解析服务器状态
function AccountCenter.analysisServer(_server)

    local nShowState = en_server_state.full
    --解析服务器状态
    if _server.tState and table.nums(_server.tState)> 0 then
        for k,v in pairs(_server.tState) do
            --维护中
            if v == en_server_state.maintain then
                nShowState = v
                break
            end
            --推荐服
            if v == en_server_state.recomm then
                nShowState = v
                break
            end         
        end
    end
    return nShowState
end

-- 返回登录界面
-- _nType 1需要执行登录行为，0不需要执行登录行为，只是切换服务器而已，2重新登录
function AccountCenter.backToLoginScene(_nType)
    -- 重新初始化帐号数据
    local pClearn = true
    if _nType and _nType == 0 then
        pClearn = false
    end

    AccountCenter.doClearBeforeBacktologin(pClearn)
    local LoginLayer = require("app.layer.login.LoginLayer")
    local pScene = LoginLayer.new(_nType)
    RootLayerHelper:replaceRootLayer(pScene)
    if(device.platform == "ios") then -- iPhoneX适配:隐藏顶部和底部的补缺图
        local luaoc = require("framework.luaoc")
        luaoc.callStaticMethod("PlatformSDK", "showIphoneSafeArea", {show="0"})
    end
end

-- 执行切换回登录界面时的数据重置
function AccountCenter.doClearBeforeBacktologin( bClearAcc )
    if(bClearAcc == nil) then
        bClearAcc = true
    end
    if(bClearAcc) then
        AccountCenter.initAcountData()
    end
    Player:destroyPlayer()
    -- 关闭socket接口
    SocketManager:close()
    --关闭所有的对话框
    closeAllDlg(true)
end
-- 增加重新定位SDK浮标的处理
function AccountCenter.resetSDKFubiaoPos(  )
    -- 暂时关闭
    if(true) then
        return
    end
    if(device.platform == "android") then
        local className = "com/game/quickmgr/QuickMgr"
        local methodName = "setFubiaoLocation"
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {0}, "(I)V");
        if result then
            data = ret or data
        end
    end
end

--[[-- 
SDK登陆成功回调(json)
JAVA, OC回调用的全局函数
@param data(string) 平台玩家参数
]]
function onSDKRealNameAuthSuccess(jsonStr)
    -- print("jsonStr", jsonStr)
    if jsonStr == nil then
        return
    end
    if string.len(jsonStr) <= 0 then
        return
    end
    local data = json.decode(jsonStr)
    if data == nil then
        return
    end

    -- local nType = tonumber(data.type) or 1 -- 1：登陆，2：实名认证回调
    local nAge = tonumber(data.age) or 0 -- 实名认证的年龄

    -- 记录sdk实名认证返回的年龄
    AccountCenter.rn_sdk_age = nAge 
    if (device.platform == "android") then
    elseif (device.platform == "ios") then 
        local pAct = Player:getActById(e_id_activity.realnamecheck)
        if pAct then
            pAct:checkRealName() -- 检查是否已实名
        end
    end
    -- if (AccountCenter.serverId and string.len(AccountCenter.serverId) > 0) then 
    --     -- 实名认证返回回调，直接请求实名认证信息
    --     loadRealNameAuthDatas(2)
    -- else -- 实名认证登陆返回，在玩家进入游戏服时请求实名认证信息
    --     -- loadRealNameAuthDatas(1)
    -- end
end

--[[-- 
加载实名认证信息
_nType：类型， 1：登陆，2：实名认证回调
]]
function loadRealNameAuthDatas(_nType)
    if (not b_open_real_name_auth) then -- 未开启实名认证
        return 
    end
    _nType = _nType or 1

    local url = nil 
    if (_nType == 1) then -- 登陆
        url = "/action/user/recordAccAuth"
    else -- 实名认证回调
        url = "/action/user/updateAccAuth"
    end

    local param = {}
    param.age = AccountCenter.rn_sdk_age -- 实名认证的年龄
    param.account = AccountCenter.acc -- 账号
    param.serid = AccountCenter.serverId -- 服务器id

    HttpManager:doGetFunctionToLoginServer(url, param, function(event)
    end)
end

--------------------------------↑实名认证相关↑----------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--------------------------------↓防沉迷相关↓------------------------------
--[[-- 
SDK防沉迷检验成功回调(json)
JAVA, OC回调用的全局函数
@param data(string) 平台玩家参数
]]
function onSuccessVerifyPhone(jsonStr)
    if jsonStr == nil then
        return
    end
    if string.len(jsonStr) <= 0 then
        return
    end

    if device.platform == "android" then
        if jsonStr == "1" then
            local pAct = Player:getActById(e_id_activity.phonebind)
            if pAct and pAct.nState == 0 then
                pAct:sendNet(1) -- 已绑定
            end
        end
    elseif (device.platform == "ios") then -- 回调即已完成防沉迷信息填写
        -- 告诉服务器已绑定
        local pAct = Player:getActById(e_id_activity.phonebind)
        if pAct then
            pAct:sendNet(1) -- 已绑定
        end
    end
end
--[[-- 
SDK防沉迷检验失败回调(json)
JAVA, OC回调用的全局函数
@param data(string) 平台玩家参数
]]
function onFailureVerifyPhone(jsonStr)
    -- print("jsonStr", jsonStr)
    if jsonStr == nil then
        return
    end
    if string.len(jsonStr) <= 0 then
        return
    end
    local data = json.decode(jsonStr)
    if data == nil then
        return
    end
end
--------------------------------↑防沉迷相关↑------------------------------
--------------------------------------------------------------------------

AccountCenter.initAcountData()
AccountCenter.initPackageData()
AccountCenter.updatePackageData()
