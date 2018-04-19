local N_HAS_BUGLY_SDK = -1
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")

    --打印错误(myprintToFile声明在另外的文件，有可能没有加载进来)
    if type(myprintToFile) == "function" then
        local tStr = {
            "----------------------------------------",
            "LUA ERROR: " .. tostring(errorMessage) .. "\n",
            debug.traceback("", 2),
            "----------------------------------------",
        }
        -- myprintToFile(tStr)
    end
    -- 接入错误上报接口
    if N_HAS_BUGLY_SDK == -1 then
        local buglySDK = getStringDataCfg("hasBuglySDK")
        if buglySDK and string.len(buglySDK) > 0 and buglySDK ~= "0" then
            N_HAS_BUGLY_SDK = 1 -- 已接入BuglySDK
        else
            N_HAS_BUGLY_SDK = 0 --未接入BuglySDK
        end
    end
    if N_HAS_BUGLY_SDK == 1 then
        buglyReportLuaException(tostring(errorMessage), debug.traceback())
    end

    --检查是否是update.bin中报错
    if not UPDATE_BIN_FINISH then
        if not HAD_SAVE_ERROR then
            HAD_SAVE_ERROR = true
            local errorTimes = tonumber(getLocalInfo("error_in_updatebin","0"))
            errorTimes = errorTimes + 1
            saveLocalInfo("error_in_updatebin",tostring(errorTimes))
            if errorTimes >= 2 then --超过次数，需要做清除操作
                saveLocalInfo("error_in_updatebin",tostring(0))
                cleanDir(UPD_FOLDER)
                if(___doReleaseZip) then
                    ___doReleaseZip()
                end
            end
        end
    end
end

require("lfs")
-- 打印数据
function myprint( ... )
    -- local bCan = false
    -- if(N_PACK_MODE == 1000) then -- 测试包才打印
    --     bCan = true
    -- end
    -- if(not bCan) then
    --     return
    -- end
    print(os.date() .. " ", ...)
--    local tT = {...}
--    if(#tT > 1) then
--        local sStr = ""
--        for i, v in pairs(tT) do
--            sStr = sStr .. tostring(v) .. ","
--        end
--        print(os.date() .." ".. sStr)
--    else
--        print(os.date() .." ".. tostring(tT[1]))
--    end

    --打印普通数据日后需要打印myprint数据就开启这里
    -- if type(myprintToFile) == "function" then
    --     myprintToFile(...)
    -- end
end

--将内容写入文件中
-- path（string）：该文件的路径
-- content（string）：内容
-- mode(string): 读写模式
function writeContentToFile(path,content,mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        local hr,err = file:write(content)
        if hr == nil then
            myprintLau(err)
            return false
        end
        io.close(file)
        return true
    else
        myprint("can't open file:"..path)
        return false
    end
end
local tt_targetPlatform = cc.Application:getInstance():getTargetPlatform()
local bStringFindPlain = false
if PLATFORM_OS_IPAD == tt_targetPlatform or PLATFORM_OS_IPHONE == tt_targetPlatform then -- ios
    bStringFindPlain = true
end
tt_targetPlatform = nil
-- 判断一个文件是否存在
-- _path（string）：文件的相对路径
-- _type（int）：当前获取的类型，nil为所有，1为res，2为upd，3为整包文件
function isFileExistCfg( _path, _type )
    if(not _path) then
        print("文件路径为空")
        return
    end
    local bFound = false
    if(_type == nil) then
        if(string.find(_path, "res/")) then
             bFound = cc.FileUtils:getInstance():isFileExist(_path)
        else
             bFound = cc.FileUtils:getInstance():isFileExist("res/".. _path)
        end
        if(not bFound) then
            if(string.find(_path, UPD_FOLDER, 0, bStringFindPlain)) then
                bFound = cc.FileUtils:getInstance():isFileExist(_path)
            else
                bFound = cc.FileUtils:getInstance():isFileExist(UPD_FOLDER.. _path)
            end
        end
    elseif(_type == 1) then
        if(string.find(_path, "res/")) then
            bFound = cc.FileUtils:getInstance():isFileExist(_path)
        else
            bFound = cc.FileUtils:getInstance():isFileExist("res/".. _path)
        end
    elseif(_type == 3) then
        bFound = cc.FileUtils:getInstance():isFileExist(_path)
    else
        if(string.find(_path, UPD_FOLDER, 0, bStringFindPlain)) then
            bFound = cc.FileUtils:getInstance():isFileExist(_path)
        else
            bFound = cc.FileUtils:getInstance():isFileExist(UPD_FOLDER.. _path)
        end
    end
    return bFound
end
-- 由于framework_precompiled也可能需要更新，所以一些常用的函数也需要提取出来
---------一些常用函数----------
function myclassLau(classname, super)
    local superType = type(super)
    local cls
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}
        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end
        cls.__cname = classname
        cls.__ctype = 1
        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end
        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end
    return cls
end
--创建目录
function mkDir(path)
    if not isFileExistCfg(path, 2) then
        return lfs.mkdir(path)
    end
    return true
end
--删除目录以及目录下所有的东西
function cleanDir(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullpath = path..file
            local attr = lfs.attributes (fullpath)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                fullpath = fullpath.."/"
                cleanDir(fullpath)
                lfs.rmdir(fullpath)
            else
                os.remove(fullpath)
            end
        end
    end
end
--写flist文件
function writeFlist(path,flist)
    local content = "local flist ={\n"
    content = content.."\tfiles={"
    for _,v in ipairs(flist.files) do
        if v ~= nil then
            local fileDesc = "\n\t\t{ file=\""..v.file.."\", md5=\""..v.md5.."\", size="..v.size.."},"
            content = content..fileDesc
        end
    end
    content = content.."\n\t}\n}\nreturn flist"
    writeContentToFile(path, content)
end
--写version文件
function writeVersion(path,version, oversion)
    local content = ""
    content = "local ver ={\n" .. "\tcore="..version.core..",\n" 
            .. "\tbinVer=" .. version.binVer .. ",\n"
            .."\tversion=\""..version.version.."\","
    -- 增加新版本
    if(oversion and oversion.cnewcore) then
        content = content .. "\n\tcnewcore=\"" .. oversion.cnewcore .. "\",\n"
    end
    content = content.."}\nreturn ver"
    writeContentToFile(path, content)
end
-- 将字符串内容读取为lua的table
function luaDoString(str)
    local fn = loadstring(str)
    if(fn ~= nil) then
        local retval = fn()
        return retval
    end
    return nil
end
--[[
获取游戏包字符串数据
@param key(string) key
@return data (string) 数据
]]
function getStringDataCfg(key)
    local target = cc.Application:getInstance():getTargetPlatform()
    local data = "0"
    if PLATFORM_OS_ANDROID == target then -- android
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "getCfgString"
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {key}, "(Ljava/lang/String;)Ljava/lang/String;");
        if result then
            data = ret or data
        end
    elseif PLATFORM_OS_IPAD == target or PLATFORM_OS_IPHONE == target then -- ios
        local param = {}
        param.sName = key
        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", 
            "getString", param)
        if(bOk and sValue) then
            data = sValue
        else
            data = "0"
        end
    elseif target == PLATFORM_OS_WINDOWS then -- windows
        if("imei" == key) then -- imei号
            data = S_IMEI_DEFAULT
        elseif("mac" == key) then -- mac地址
            data = S_MAC_DEFAULT
        elseif(KKK_PLATFORM_ID == key) then -- 3k平台id
            data = S_KKK_PLAT_CHANNELID_DEFAULT 
        elseif(KKK_PLATFORM_CHILD_ID == key) then -- 3k平台子包id
            data = S_KKK_CHILD_CHANNELID_DEFAULT 
        end
    end
    return data
end
--[[
获得apk下载路径
@return path (string) 路径
]]
function getApkDownLoadPath(  )
    -- body
    local target = cc.Application:getInstance():getTargetPlatform()
    local path = UPD_FOLDER
    if PLATFORM_OS_ANDROID == target then -- android
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "getAPKDownloadPath"
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {}, "()Ljava/lang/String;");
        if result then
            path = ret or path
        end
    elseif PLATFORM_OS_IPAD == target or PLATFORM_OS_IPHONE == target then -- ios

    elseif target == PLATFORM_OS_WINDOWS then -- windows
       
    end
    return path
end

--[[
安装新下载的整包
@param path(string) 文件名＋全路径
]]
function installNewPack( path )
    -- body
    if not path then
        myprint("安装包路径不能为nil")
        return
    end
    local target = cc.Application:getInstance():getTargetPlatform()
    if PLATFORM_OS_ANDROID == target then -- android
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "installApk"
        local result, ret = luaj.callStaticMethod(className, methodName, 
            {path}, "(Ljava/lang/String;)V");
    elseif PLATFORM_OS_IPAD == target or PLATFORM_OS_IPHONE == target then -- ios

    elseif target == PLATFORM_OS_WINDOWS then -- windows
       
    end
end
-- 获取版本号的数字
function getVerNumCfg(version)
    if not version then
        return nil
    end
    local num = 0
    for w in string.gmatch(version,"%d+") do     --迭代出所有的数字
        num = num*10 + tonumber(w)
    end
    return num
end
-- 进入登录界面时，清空在检测更新界面缓存的lua文件
function clearOldLuaLoaded(  )
    -- 判断是否为游戏内的代码
    local function isMineLua( _sName )
        local nS, nE = string.find(_sName, "framework.")
        if(nS == 1) then
            return true
        end
        nS, nE = string.find(_sName, "cocos.")
        if(nS == 1) then
            return true
        end
        nS, nE = string.find(_sName, "app.")
        if(nS == 1) then
            return true
        end
        return false
    end
    if(package.loaded) then
        for k, v in pairs(package.loaded) do
            if(isMineLua(k)) then
                package.loaded[k] = nil
            end
        end
    end
    if(package.preload) then
        for k, v in pairs(package.preload) do
            if(isMineLua(k)) then
                package.preload[k] = nil
            end
        end
    end
    -- 判断是否存在app.bin，如果存在，加载app.bin内容
    if(isFileExistCfg("app.bin", 1)) then
        cc.LuaLoadChunksFromZIP("app.bin")
        -- 过去upd目录下存在的文件
        for k, v in pairs(package.preload) do
            local nS, nE = string.find(k, "app.")
            if(nS) then -- 属于app目录下的内容
                local sFilePath = string.gsub(k, "%.", "/") .. ".lua"
                if(isFileExistCfg(sFilePath, 2)) then
                    -- 如果upd目录有文件，取消app.bin中的预加载
                    package.preload[k] = nil
                end
            end
        end
    end
end
-- 延迟时间再加载具体的内容
-- pView（SView）：需要加载的界面
-- nBackHandler（function）：需要回调的函数
-- fTime（float）：延迟加载的时间
function performActionDelayCfg( pView, nBackHandler, fTime )
    if(pView) then
        fTime = fTime or 0
        if(fTime == 0) then
            nBackHandler()
            return
        end
        pView:runAction(cc.Sequence:create(
            cc.DelayTime:create(fTime),
            cc.CallFunc:create(function (  )
                nBackHandler()
            end)))
    end
end

--复制配表(game.db)
function copyGameDB(  )
    -- body
    --windows不需要复制db
    local target = cc.Application:getInstance():getTargetPlatform()
    if target ~= PLATFORM_OS_WINDOWS then -- windows
        --检测game.db文件,如果不存在就复制过去
        mkDir(UPD_FOLDER.."data/")
        if not isFileExistCfg("data/"..GAMEDB, 2) then
            local db = nil
            if(isFileExistCfg("data/" .. GAMEZIP, 1)) then
                local lz  = require("zlib")
                local data_ = cc.FileUtils:getInstance():getDataFromFile("res/data/"..GAMEZIP)
                db = lz.inflate()(data_, KEY_TOZIP)
            else
                db = cc.FileUtils:getInstance():getDataFromFile("res/data/"..GAMEDB)
            end
            if db then
                writeContentToFile(UPD_FOLDER.."data/"..GAMEDB,db)
            else
                myprintLau("未读取到db文件")
            end
       end
    end
end

-- 保存本地数据
-- sKey（string）：key值
-- sValue（string）：数据
function saveLocalInfo( sKey, sValue )
    cc.UserDefault:getInstance():setStringForKey(sKey, sValue)
    cc.UserDefault:getInstance():flush()
end

-- 获取本地数据
-- sKey（string）：key值
-- sDefaultValue（string）：默认数据
function getLocalInfo( sKey, sDefaultValue )
    if not sKey then
        return sDefaultValue
    end
    if not sDefaultValue then
        return sDefaultValue
    end
    return cc.UserDefault:getInstance():getStringForKey(sKey, sDefaultValue)
end

-- 获取语言类型
-- return(int): 0是其他类型，1是国内版本
function getLanguageType(  )
    if(not N_PACK_MODE) then
        print("游戏启动逻辑有问题")
        return 0
    end
    local fType = math.floor(N_PACK_MODE/1000)
    if(fType == 1) then -- 国内版本
        return fType
    end
    return 0
end

--展示进入游戏前游戏相关提示语
function showGameTips( pView )
    -- body

    if not pView then
        return
    end
    local tWords = require(getLauncherLanguageCfg())

    --第二版本
    local pTxtTips = MUI.MLabel.new({text = "", size = 20,anchorpoint=cc.p(0.5, 0.5)})
    pView:addView(pTxtTips)
    pTxtTips:setPosition(320,95)
    local tShowWords = {}
    --获得文字
    local getTipsString = function (  )
        -- body
        --获得文字
        if tShowWords == nil or table.nums(tShowWords) <= 0 then
            tShowWords = {}
            for i = 100, 129 do
                table.insert(tShowWords, tWords[i])
            end
        end
        local nSize = table.nums(tShowWords)
        local nRandomIndex = math.random(1, nSize)
        local sTr = tShowWords[nRandomIndex]
        table.remove(tShowWords,nRandomIndex)
        return sTr
    end
    --初始化文字
    pTxtTips:setString(getTipsString())

    local action1 = cc.DelayTime:create(3)
    local action2 = cc.CallFunc:create(function (  )
        -- body
        pTxtTips:setString(getTipsString())
    end)

    pTxtTips:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2)))

    --第一版本
    -- local pTxtTips1 = MUI.MLabel.new({text = "", size = 20,anchorpoint=cc.p(0, 0.5)})
    -- local pTxtTips2 = MUI.MLabel.new({text = "", size = 20,anchorpoint=cc.p(0, 0.5)})
    -- pView:addView(pTxtTips1)
    -- pView:addView(pTxtTips2)
    -- pTxtTips1:setPosition(640,95)
    -- pTxtTips2:setPosition(640,95)

    -- local nShowCt = 1
    -- local tShowWords = {}

    -- showGameTipsOnloadingAction = function (  )
    --     -- body
    --     --获得lable
    --     local pCurLb = nil
    --     if nShowCt % 2 == 1 then --第一条label
    --         pCurLb = pTxtTips1
    --     else
    --         pCurLb = pTxtTips2
    --     end

    --     --获得文字
    --     if tShowWords == nil or table.nums(tShowWords) <= 0 then
    --         tShowWords = {}
    --         for i = 100, 126 do
    --             table.insert(tShowWords, tWords[i])
    --         end
    --     end
    --     local nSize = table.nums(tShowWords)
    --     local nRandomIndex = math.random(1, nSize)
    --     local sTr = tShowWords[nRandomIndex]
    --     --设置文字
    --     pCurLb:setString(sTr)
    --     table.remove(tShowWords,nRandomIndex)

    --     --计算位置
    --     local fx = (640 - pCurLb:getWidth()) / 2

    --     --获得宽度
    --     local nWidth = pCurLb:getWidth()

    --     local actionMoveToShow = cc.MoveTo:create(1.5, cc.p(fx, 95))
    --     local actionDelay = cc.DelayTime:create(5)
    --     local actionCallNext = cc.CallFunc:create(function (  )
    --         -- body
    --         --下一条进场
    --         showGameTipsOnloadingAction()
    --     end)
    --     local actionMoveToHide = cc.MoveTo:create(1.5, cc.p(-nWidth, 95))
    --     local actionEnd = cc.CallFunc:create(function (  )
    --         -- body
    --         --重置位置
    --         pCurLb:setPosition(640,95)
    --     end)
    --     local allActions = cc.Sequence:create(actionMoveToShow,actionDelay,actionCallNext,actionMoveToHide,actionEnd)
    --     pCurLb:runAction(allActions)
    --     --次数加1
    --     nShowCt = nShowCt + 1
    -- end
    -- --展示表现
    -- showGameTipsOnloadingAction()
   
end

local kjtDatas = {"ver002","ver001"}
LOGOBG_VERSTR = "logobg_verstr" -- LOGO版本的存取字符串
-- 增加背景和logo，适用与检测更新界面和登录界面
-- _type(int): 1是检测更新界面，2是登录界面
-- _pView(CCNode): 当前需要添加进去的父层
function addBackgroundAndLogo( _type, _pView, _pBarBall )
    if(_pView and _pBarBall) then
        --
        local sDefaultStr = "ver001"
        -- 获取文件中保存的内容
        local sVerString = cc.UserDefault:getInstance():getStringForKey(LOGOBG_VERSTR, sDefaultStr)
        for i, v in ipairs(kjtDatas) do
            local isTypeFileExist = cc.FileUtils:getInstance():isFileExist(
                "res/ui/update_bin/" .. v .. "/sg_jdt_dh_sa_l_01.png")
            if(isTypeFileExist or (sVerString == v and checkCurLogoVerFiles(v))) then
                sVerString = v
                break
            end
        end
        if sVerString == "ver001" or sVerString == "ver002" then
            --设置背景跟logo
            setBgAndLogoByVer(_type, _pView, sVerString)

            --添加帧动画
            if _type == 1 then
                _pView:onUpdate(function (  )
                    MArmatureUtils:updateMArmature()
                end)
            end
            
            --帧动画表现文件定义
            local tArmDatas = 
            {
                nFrame = 30, -- 总帧数
                pos = {-27, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
                fScale = 1,-- 初始的缩放值
                nBlend = 1, -- 需要加亮
                nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
                tActions = {
                    {
                        nType = 2, -- 透明度
                        sImgName = "ui/update_bin/ver001/sg_jdt_dh_sa_l_01",
                        nSFrame = 1,
                        nEFrame = 15,
                        tValues = {-- 参数列表
                            {255, 175}, -- 开始, 结束透明度值
                        }, 
                    },
                    {
                        nType = 2, -- 透明度
                        sImgName = "ui/update_bin/ver001/sg_jdt_dh_sa_l_01",
                        nSFrame = 16,
                        nEFrame = 30,
                        tValues = {-- 参数列表
                            {175, 255}, -- 开始, 结束透明度值
                        },
                    },
                },
            }
            local pArm = MArmatureUtils:createMArmature(
                tArmDatas, 
                _pBarBall, 
                1000, 
                cc.p(_pBarBall:getContentSize().width / 2,_pBarBall:getContentSize().height / 2),
                function ( _pArm )

                end)
            if pArm then
                pArm:play(-1)
            end

            --新增粒子效果
            local pParitcle = cc.ParticleSystemQuad:create("ui/update_bin/ver001/lizi_jindut_hc_001.plist")
            local pBatch = cc.ParticleBatchNode:createWithTexture(pParitcle:getTexture())
            pParitcle:setPositionType(MUI.kCCPositionTypeRelative)
            pParitcle:setPosition(_pBarBall:getContentSize().width / 2 - 27,_pBarBall:getContentSize().height / 2)
            pParitcle:setScale(0.5)
            _pBarBall:addChild(pParitcle,20)
        end
    else
        print("logo的父控件不能为空")
    end
end

--设置背景图跟logo
function setBgAndLogoByVer( _type, _pView, _sVer )
    -- body
    local pImg
    if _sVer == "ver002" then --动态
        -- 增加背景图
        local isIXAdapt = isFileExistCfg("ui/update_bin/bg_login_ix.jpg")
        if isIXAdapt then
            pImg = MUI.MImage.new("ui/update_bin/bg_login_ix.jpg")
        else
            pImg = MUI.MImage.new("ui/update_bin/" .. _sVer .. "/bg_login.jpg")
        end
        
        pImg:setPosition(_pView:getWidth()/2, _pView:getHeight()/2)
        _pView:addChild(pImg, -30000)

        -- 增加人物特效
        local pArm = createAnimateForLanConfig()
        _pView:addChild(pArm, -25000)
        pArm:setPosition(_pView:getWidth()/2, _pView:getHeight()/2)

        --新增粒子效果
        local pParitcle1 = createParitcleForLanConfig("ui/update_bin/ver002/lizi_sg_longyanj_06.plist") 
        pParitcle1:setPosition(_pView:getWidth() / 2 - 336,_pView:getHeight() / 2 - 703)
        _pView:addChild(pParitcle1,-24999)

        local pParitcle2 = createParitcleForLanConfig("ui/update_bin/ver002/xxxa1yh001sx_003_3.plist") 
        pParitcle2:setPosition(_pView:getWidth() / 2 - 1441,_pView:getHeight() / 2 - 2115)
        pParitcle2:setScale(4)
        _pView:addChild(pParitcle2,-25001)

        local pParitcle3 = createParitcleForLanConfig("ui/update_bin/ver002/lizi_sg_longyanj_06.plist") 
        pParitcle3:setPosition(_pView:getWidth() / 2 - 260,_pView:getHeight() / 2 - 739)
        _pView:addChild(pParitcle3,-25001)

        local pParitcle4 = createParitcleForLanConfig("ui/update_bin/ver002/lizi_sg_longyanj_06.plist") 
        pParitcle4:setPosition(_pView:getWidth() / 2 - 549,_pView:getHeight() / 2 - 638)
        pParitcle4:setScale(0.6)
        _pView:addChild(pParitcle4,-25001)


    else --静态
        -- 增加背景图
        pImg = MUI.MImage.new("ui/update_bin/" .. _sVer .. "/bg_login.jpg")
        pImg:setPosition(_pView:getWidth()/2, _pView:getHeight()/2)
        _pView:addChild(pImg, -30000)
    end
   
    -- 增加logo
    pImg = MUI.MImage.new("ui/update_bin/" .. _sVer .. "/logo.png")
    pImg:setAnchorPoint(0.5, 1)
    pImg:setPosition(_pView:getWidth() - pImg:getWidth() / 2 - 30, _pView:getHeight() - pImg:getHeight() / 2 + 40)
    _pView:addChild(pImg, -20000)
    -- 为了特殊包增加的点击事件
    pImg:setViewTouched(true)
    pImg:setIsPressedNeedScale(false)
    pImg:setIsPressedNeedColor(false)
    pImg:onMViewClicked(function (  )
        G_SPECIALCLICK = G_SPECIALCLICK or 0
        G_SPECIALCLICK = G_SPECIALCLICK + 1
    end)

    if _type == 2 then --登陆界面
        --1.本地资源号
        local sVer = getPackageResVer()
        if sVer then
            local pLbVersion = MUI.MLabel.new({
                text = getConvertedStr(1, 10233) .. (AccountCenter.sPackageVerName .. "@" .. sVer),
                size = 14,
                anchorpoint = cc.p(0, 0.5),
                align = cc.ui.TEXT_ALIGN_CENTER,
                valign = cc.ui.TEXT_VALIGN_TOP,
                color = cc.c3b(143, 143, 143),
                })
            pLbVersion:setPosition(20, _pView:getHeight() - 30)
            _pView:addView(pLbVersion,10)
        end
        --2.版本号
        -- local pLbISBN = MUI.MLabel.new({
        --     text = getConvertedStr(1, 10268),
        --     size = 18,
        --     anchorpoint = cc.p(1, 0.5),
        --     align = cc.ui.TEXT_ALIGN_CENTER,
        --     valign = cc.ui.TEXT_VALIGN_TOP,
        --     })
        -- pLbISBN:setPosition(620, _pView:getHeight() - 60)
        -- _pView:addView(pLbISBN,10)
        --3.文网游备字 
        -- local pLbWWYBZ = MUI.MLabel.new({
        --     text = getConvertedStr(1, 10269),
        --     size = 18,
        --     anchorpoint = cc.p(0, 0.5),
        --     align = cc.ui.TEXT_ALIGN_CENTER,
        --     valign = cc.ui.TEXT_VALIGN_TOP,
        --     })
        -- pLbWWYBZ:setPosition(20, _pView:getHeight() - 30)
        -- _pView:addView(pLbWWYBZ,10)
        --4.新广出审
        -- local pLbXGCS = MUI.MLabel.new({
        --     text = getConvertedStr(1, 10270),
        --     size = 18,
        --     anchorpoint = cc.p(0, 0.5),
        --     align = cc.ui.TEXT_ALIGN_CENTER,
        --     valign = cc.ui.TEXT_VALIGN_TOP,
        --     })
        -- pLbXGCS:setPosition(20, _pView:getHeight() - 60)
        -- _pView:addView(pLbXGCS,10)
    end
    -- 增加版号提示语文字
    local pImg = MUI.MImage.new("ui/update_bin/v1_fonts_xcy.png")
    pImg:setAnchorPoint(cc.p(0.5, 0))
    pImg:setPosition(_pView:getWidth()/2, 0)
    _pView:addChild(pImg, -10000)

end

-- 增加人物动作
function createAnimateForLanConfig( )

    local _animPNG = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_70.png"
    local _animPLIST = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_70.plist"
    local _animJSON = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_7.ExportJson"

    for i = 0, 4 do 
        local sPlist = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_7" .. i .. ".plist"
        local sPng = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_7" .. i .. ".png"
        ccs.ArmatureDataManager:getInstance():addSpriteFrameFromFile(sPlist,sPng,_animJSON)
    end

    ccs.ArmatureDataManager:getInstance()
        :addArmatureFileInfo(_animPNG,_animPLIST,_animJSON)
    local pArm = ccs.Armature:create("sg_dljmbjdh_dtt_01_7")
    pArm:getAnimation():play("Animation1", -1)
    return pArm
end

-- 创建粒子
function createParitcleForLanConfig( _sPath )
    -- body
    --新增粒子效果
    local pParitcle = cc.ParticleSystemQuad:create(_sPath)
    local pBatch = cc.ParticleBatchNode:createWithTexture(pParitcle:getTexture())
    pParitcle:setPositionType(MUI.kCCPositionTypeRelative)
    pParitcle:setNeedCheckScreen(false)
    return pParitcle
end

--移除开机图纹理
function removeTextureForLanConfig(  )
    -- body
     for i = 0, 4 do 
        local sPlist = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_7" .. i .. ".plist"
        local sPng = "ui/update_bin/ver002/sg_dljmbjdh_dtt_01_7" .. i .. ".png"
        display.removeSpriteFramesWithFile(sPlist, sPng)
    end
end

-- 检测当前目录的文件是否齐全
function checkCurLogoVerFiles( sDir )
    if(not sDir) then
        return false
    end
    local writablePath = S_WRITABLE_PATH or cc.FileUtils:getInstance():getWritablePath()
    local UPD_FOLDER = writablePath .. "upd/" -- 更新下载后的文件目录
    local sFinalDir = UPD_FOLDER .. "ui/update_bin/" .. sDir .. "/"
    if(sDir == "ver001") then -- 总共8个文件
        -- 1
        local bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "bg_login.jpg")
        if(not bFile) then
            return false
        end
        -- 2
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_jindut_hc_001.plist")
        if(not bFile) then
            return false
        end
        -- 3
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_jindut_hc_001.png")
        if(not bFile) then
            return false
        end
        -- 4
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "logo.png")
        if(not bFile) then
            return false
        end
        -- 5
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_jdt_dh_sa_l_01.png")
        if(not bFile) then
            return false
        end
        return true
    elseif (sDir == "ver002") then
        -- 1
        local bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "bg_login.jpg")
        if(not bFile) then
            return false
        end
        -- 2
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_jindut_hc_001.plist")
        if(not bFile) then
            return false
        end
        -- 3
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_jindut_hc_001.png")
        if(not bFile) then
            return false
        end
        -- 4
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "logo.png")
        if(not bFile) then
            return false
        end
        -- 5
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_jdt_dh_sa_l_01.png")
        if(not bFile) then
            return false
        end
        -- 6
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_sg_longyanj_01.png")
        if(not bFile) then
            return false
        end
        -- 7
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_sg_longyanj_01.plist")
        if(not bFile) then
            return false
        end
        -- 8
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_sg_longyanj_06.png")
        if(not bFile) then
            return false
        end
        -- 9
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "lizi_sg_longyanj_06.plist")
        if(not bFile) then
            return false
        end
        -- 10
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "xxxa1yh001sx_003_3.png")
        if(not bFile) then
            return false
        end
        -- 11
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "xxxa1yh001sx_003_3.plist")
        if(not bFile) then
            return false
        end
        -- 12
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "xxxa1yh001sx_007.png")
        if(not bFile) then
            return false
        end
        -- 13
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "xxxa1yh001sx_007.plist")
        if(not bFile) then
            return false
        end
        -- 14
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_70.png")
        if(not bFile) then
            return false
        end
        -- 15
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_70.plist")
        if(not bFile) then
            return false
        end
        -- 16
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_71.png")
        if(not bFile) then
            return false
        end
        -- 17
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_71.plist")
        if(not bFile) then
            return false
        end
        -- 18
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_72.png")
        if(not bFile) then
            return false
        end
        -- 19
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_72.plist")
        if(not bFile) then
            return false
        end
        -- 20
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_73.png")
        if(not bFile) then
            return false
        end
        -- 21
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_73.plist")
        if(not bFile) then
            return false
        end
        -- 22
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_74.png")
        if(not bFile) then
            return false
        end
        -- 23
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_74.plist")
        if(not bFile) then
            return false
        end
        -- 24
        bFile = cc.FileUtils:getInstance():isFileExist(sFinalDir
            .. "sg_dljmbjdh_dtt_01_7.ExportJson")
        if(not bFile) then
            return false
        end
        return true
    end
    return false
end