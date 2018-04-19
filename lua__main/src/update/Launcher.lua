print("===================================================================")


N_PACK_MODE = 1000 --测试服
--N_PACK_MODE = 1100 -- qa服
local b_open_uncompress_zip = false -- 是否开启解压压缩文件(注意安卓平台无需开启)
local target = cc.Application:getInstance():getTargetPlatform()
if target == PLATFORM_OS_IPAD or target == PLATFORM_OS_IPHONE then -- ios
    b_open_uncompress_zip = true
end
-- 检测是否需要对zip文件进行处理
function __checkNeedHandleZip( _zipName, _updDir )
    local fileUtils = cc.FileUtils:getInstance()
    -- -- 首先判断压缩文件是否存在（去掉重复判断）
    -- if (not fileUtils:isFileExist(_zipName)) then
    --     return false
    -- end
    local finishZipName = _zipName .. ".tmp"
    -- 获取该文件的MD5值，然后取后12位来命名
    local path = fileUtils:fullPathForFilename("res/".._zipName)
    local resMD5 = cc.Crypto:MD5File(path)
    if(resMD5 and type(resMD5) == "string" and #resMD5 > 12) then
        finishZipName = string.sub(resMD5, -12)
    end
    local finishPath = _updDir .. finishZipName
    -- 判断标志文件是否存在，若存在则无需解压或读取解压文件
    if (fileUtils:isFileExist(finishPath)) then
        return nil
    else
        return finishZipName
    end
end
-- 如果存在压缩包的话，复制并且加载压缩包中的内容
function ___doReleaseZip( )
    local tmpFileName = "dwby.res"
    local fileUtils = cc.FileUtils:getInstance()
    local _path = fileUtils:fullPathForFilename("res/" .. tmpFileName)
    local bFound = fileUtils:isFileExist(_path)
    -- 如果压缩包文件不存在的话
    if(not bFound) then
        return
    end
    local updDir = S_WRITABLE_PATH.."upd/"
    -- 创建upd目录
    if(not fileUtils:isFileExist(updDir)) then
        require("lfs")
        lfs.mkdir(updDir)
    end
    -- 判断是否开启解压压缩文件，并判断是否需要解压
    if (b_open_uncompress_zip and not __checkNeedHandleZip(tmpFileName, updDir)) then
        -- 压缩文件已解压，无需读取压缩文件
        return 
    end
    -- 文件的保存路径
    local savePath = updDir .. tmpFileName
    -- 如果压缩文件不存在
    if(not fileUtils:isFileExist(savePath)) then
        local data_ = fileUtils:getDataFromFile(_path)
        -- 简历文件操作类
        local file = io.open(savePath, "w+b")
        if file then
            -- 写入文件内容
            local hr,err = file:write(data_)
            -- 关闭文件
            io.close(file)
        end
    end
    if(fileUtils.loadGameZipFile) then
        -- 加载压缩包的内容
        fileUtils:loadGameZipFile(savePath, "", "")
    end
end
___doReleaseZip()
-- 开启线程执行zip文件的解压
function ___doUncompressZip()
    -- 判断是否开启解压压缩文件
    if (not b_open_uncompress_zip) then
        return 
    end
    local tmpFileName = "dwby.res"
    local fileUtils = cc.FileUtils:getInstance()
    local _path = fileUtils:fullPathForFilename("res/" .. tmpFileName)
    local bFound = fileUtils:isFileExist(_path)
    -- 如果压缩包文件不存在的话
    if(not bFound) then
        return
    end
    local updDir = S_WRITABLE_PATH .. "upd/"
    -- 创建upd目录
    if(not fileUtils:isFileExist(updDir)) then
        require("lfs")
        lfs.mkdir(updDir)
    end
    -- 判断是否需要解压
    local finishZipName = __checkNeedHandleZip(tmpFileName, updDir)
    if (not finishZipName) then
        -- 压缩文件已解压，无需解压压缩文件
        return 
    end
    -- 文件的保存路径
    local savePath = updDir .. tmpFileName
    -- 如果压缩文件不存在
    if(not fileUtils:isFileExist(savePath)) then
        local data_ = fileUtils:getDataFromFile(_path)
        -- 简历文件操作类
        local file = io.open(savePath, "w+b")
        if file then
            -- 写入文件内容
            local hr,err = file:write(data_)
            -- 关闭文件
            io.close(file)
        end
    end
    if (doUnCompressLua) then
        -- 此处设置为全局变量，防止被切换时销毁了，因为开了多线程的关系
        G_zipName = updDir .. tmpFileName
        G_finishZipName = updDir .. finishZipName
        G_dirName = updDir
        -- 开始解压文件
        doUnCompressLua(G_zipName, G_finishZipName, G_dirName, nil, 1)
    end
end
-- 引入配置文件
require("app.updatecfg.UpdConfig")
local tWords = require(getLauncherLanguageCfg())
local lz  = require("zlib")

local bNeedCheckUpdate = true -- 是否需要检测更新
local target = cc.Application:getInstance():getTargetPlatform()
if target == PLATFORM_OS_WINDOWS then
	bNeedCheckUpdate = false -- win32下不需要检测更新
end

KEY_TOZIP = KEY_TOZIP or "finish"
local NAME_FLIST = "flist.txt" -- 所有文件的MD5内容
local NAME_FZIP = "flist.zip"  -- flist.txt加密后的文件
local NAME_VER = "version.txt" -- 游戏的版本文件
local NAME_LCHR = "update.bin" -- laucher文件的加密后文件
local NAME_GAMEDB = GAMEDB or "game.db" -- 游戏的数据表
local NAME_GAMEZIP = GAMEZIP or "game.zip" -- 游戏数据表加密后的文件
local NAME_PACKVER = "packageversion.txt"
local sTempVersionDir = "version/ver_" -- version文件的路径
-- http各种请求类型
-- 请求的顺序为：下载version.txt文件，判断是否需要强更：需要就下载packageversion.txt获得apk下载地址；
-- 不需要就判断资源版本号，是否需要热更：需要的话就下载flist.zip获取所有文件的md5，跟本地进行比对，然后下载资源
-- 不需要的话，直接进入游戏
local RequestFileType = { 
	LCHR = 0,  -- Launcher自身
	VER = 10,  -- version.txt
	PACVER = 11,  -- packageversion.txt
	FLIST = 20,  -- flist.zip
	RES = 30 -- 其他游戏资源
}
local sFirstDir = "" -- 最外层目录
local sFileDir = nil -- 当前更新的目录
local PATCH_SERVER_ADDR = nil -- 资源下载的cdn全路径
local PATCH_SERVER_ADDR_BACK = nil -- 资源下载的源站全路径
local bNeedVerDirControl = true -- 是否需要增加版本目录控制
local sVerPath = nil -- version文件下载的路径
local sPackVerPath = nil -- apk检测更新的版本路径
local sCDN_PATH = S_CDN_RESDOMAIN
local sYUAN_PATH = S_YUAN_RESDOMAIN
if (N_PACK_MODE == 1000) then -- 测试包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_test" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH  --不走cdn
elseif (N_PACK_MODE == 1050) then -- ios测试包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_test_ios" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH      --不走cdn
elseif (N_PACK_MODE == 1100) then --QA包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_tongbu" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH      --不走cdn
elseif (N_PACK_MODE == 1101)  then --ios的QA包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_ios_qa" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH         --不走cdn
elseif (N_PACK_MODE == 1300) then -- 申请版号包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_banhao" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH      --不走cdn
elseif (N_PACK_MODE == 1301) then -- 云测测试包
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_yunce" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN --不走cdn
    sCDN_PATH = sYUAN_PATH      --不走cdn
elseif (N_PACK_MODE == 1500) then -- 3k母包地址
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3krelease" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1600) then -- 3k母包地址
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1601) then -- 安卓外网同步包
    sFirstDir = "test" -- 国内包
    sFileDir = "dir_3krelease_tb" -- 更新目录前缀
    bNeedVerDirControl = false -- 是否需要增加版本目录控制
    sYUAN_PATH = S_INNER_RESDOMAIN 
    sCDN_PATH = sYUAN_PATH      --不走cdn
elseif (N_PACK_MODE == 1700) then -- ios的3K母包
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1701) then   --ios的3K母包（攻城ol）
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1702) then -- ios的3K母包（权谋者）
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1703) then -- ios的3K母包（帝王传）
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1704) then -- ios的3K母包（大军师）
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
elseif (N_PACK_MODE == 1705) then -- ios的3K母包（大军师）
    sFirstDir = "master" -- 国内包
    sFileDir = "dir_3kmubao_ios" -- 更新目录前缀
    bNeedVerDirControl = true -- 是否需要增加版本目录控制
end

-- 故意加上mode值，用来确定只要mode值正确，路径就正确
sFileDir = sFileDir .. "_" .. N_PACK_MODE
-- 资源下载的cdn全路径
PATCH_SERVER_ADDR = sCDN_PATH .. sFirstDir .. "/" .. sFileDir .. "/"
-- 资源下载的源站全路径
PATCH_SERVER_ADDR_BACK = sYUAN_PATH .. sFirstDir .. "/" .. sFileDir .. "/"
-- version文件下载的路径
if(bNeedVerDirControl) then
    sVerPath = sYUAN_PATH .. sFirstDir .. "/version/ver_" .. sFileDir .. ".txt"
else
    sVerPath = PATCH_SERVER_ADDR_BACK .. "version.txt"
end
sPackVerPath = sYUAN_PATH .. sFirstDir .. "/".. "apks/"


myprint("sFileDir=", sFileDir)
myprint("PATCH_SERVER_ADDR=", PATCH_SERVER_ADDR)
myprint("PATCH_SERVER_ADDR_BACK=", PATCH_SERVER_ADDR_BACK)
myprint("sVerPath=", sVerPath)
myprint("sPackVerPath=", sPackVerPath)
----------------------------------------------------------------------------------------
require("app.config")
require("cocos.init")
require("framework.init")
require("cocos.myui.MInit")

local nCenterX = display.width / 2
local nCenterY = display.height / 2

local Launcher = class("Launcher", function (  )
	return MUI.MRootLayer.new()
end)
function Launcher:ctor(  )
	self:laucherInit()

    --关闭FPS
    if target == PLATFORM_OS_WINDOWS then -- win32
    else
        local sharedDirector = cc.Director:getInstance()
        sharedDirector:setDisplayStats(false)
        if(target == PLATFORM_OS_ANDROID) then
            sharedDirector:setAnimationInterval(1/60)
        end
    end
    MViewReader:getInstance():createNewGroup("app.jsontolua.layout_update_bin",handler(self, self.onParseViewCallback))
	
end
-- 初始化参数
function Launcher:laucherInit(  )
    self.bIsBack = false -- 是否为备用行为
    self.nNormalSerFailedTimes = 0 -- 当前正式连接失败的次数
    self.nFailedTimes = 0 -- 当前连接的总失败次数
    self.bDownFailed = false -- 是否下载失败
    self.nFailedType = 0 -- 失败类型
    self.nFinalMaxCore = -1 -- 当前服务器上最大的包体版本号
    self.nPackDownType = 0 -- 下载更新包的类型，1是强更，2是非强更
    self.newList = nil -- 服务器上flist.zip的文件内容
    self.downloadList = nil -- 需要下载文件名称列表
    self.bIsCDNDomain = true -- flist.zip是否使用的是CDN的域名
    self.bNCVersion = true -- 需要改变版本号
    self.m_sPlatId = getStringDataCfg(KKK_PLATFORM_ID) -- 平台id
    self.m_sPlatCid = getStringDataCfg(KKK_PLATFORM_CHILD_ID) -- 平台子包id
    self.sApkName = nil --整包更新的文件名
    self.sApkDownloadPath = getApkDownLoadPath()
end
--布局解析
function Launcher:onParseViewCallback( pView )
    -- body
    pView:setLayoutSize(self:getLayoutSize())
    self:addView(pView)
    centerInView(self,pView)
    

    --进度条
    self.pSlider = self:findViewByName("slider")
    self.pSlider:setSliderValue(0)
    self.pSlider:align(display.LEFT_BOTTOM)
    self.pSlider:setPosition(10, self.pSlider:getPositionY()-self.pSlider:getHeight()/2)
    self.pSlider:onSliderValueChanged(function (  )
        -- body
        local curvalue = self.pSlider:getSliderValue() --滑动条当前值
        if curvalue > 8 then
            self.pSlider:getSliderBarBall():setVisible(true)
        else 
            self.bVi = false
            self.pSlider:getSliderBarBall():setVisible(false)
        end
    end)

    --游戏提示语
    local pLayGameTips = self:findViewByName("lay_game_tips")
    if showGameTips and pLayGameTips then
        showGameTips(pLayGameTips)
    end

    --加载提示语
    self.pLbTips = self:findViewByName("lb_tips")
    self.pLbTips:setString(tWords[7])
    --更新内容
    self.pLayUpd = self:findViewByName("lay_update_tips") --提示内容层
    self.pLbUpdTitle = self:findViewByName("lb_title") --提示层标题
    self.pLbUpdTitle:setString(tWords[14])
    self.pLayUpd:setVisible(false)
    self.pLaySv = self:findViewByName("lay_sv") --ScrollLayer父层
    self.pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLaySv:getWidth(), self.pLaySv:getHeight()),
        touchOnContent = false,
        direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
    self.pLaySv:addView(self.pSv)
    self.pSv:setBounceable(true)
    --更新按钮
    self.pLayBtnUpd = self:findViewByName("lay_btn_upd")
    self.pLbBtnUpd = self:findViewByName("lb_upd")
    self.pLayBtnUpd:setViewTouched(true)
    self.pLayBtnUpd:onMViewClicked(handler(self, self.onDownloadClicked))
    self.pLayBtnUpd:setVisible(false)
    self.pLbBtnUpd:setString(tWords[17])

    if(addBackgroundAndLogo and self.pSlider.getSliderBarBall) then
        addBackgroundAndLogo(1, pView, self.pSlider:getSliderBarBall())
    end
    
    if bNeedCheckUpdate then  --需要检测更新的时候先隐藏
        self.pSlider:setVisible(false)
    else
        self.pSlider:setVisible(true)
    end

    if(not bNeedCheckUpdate) then
        self.pSlider:setPercentFromTo(1,100, function (  )
            -- body
            self:gotoGame()
        end)
    else
        -- 延迟一点点开始执行检测更新
        performActionDelayCfg(self, function (  )
            self:requestFile(NAME_VER, RequestFileType.VER, 0)
        end, 0.1)
    end
end
-- 执行更新下载按钮的功能
function Launcher:onDownloadClicked( _pView )
    -- 如果是下载失败
    if(self.bDownFailed) then
        if self.nFailedType == RequestFileType.VER then -- version.txt版本文件
            self:requestFile(NAME_VER, RequestFileType.VER, 0)
            self.pLbTips:setString(tWords[7])
        elseif self.nFailedType == RequestFileType.LCHR then -- update.bin更新文件
            self:requestFile(NAME_LCHR, RequestFileType.LCHR, 0)
            self.pLbTips:setString(tWords[7])
        elseif self.nFailedType == RequestFileType.FLIST then -- flist.zip文件
            self:requestFile(NAME_FZIP, RequestFileType.FLIST, 0)
            self.pLbTips:setString(tWords[7])
        elseif self.nFailedType == RequestFileType.FLIST then -- packagever.txt文件
            self:requestFile(NAME_PACKVER, RequestFileType.PACVER, 0)
            self.pLbTips:setString(tWords[7])
        else
            if(self.mIndex == nil) then
                self.mIndex = 1
            end
            if(self.bIsAutoDown) then
                self.pLbTips:setString(tWords[18] .. 
                    "(" .. self:getCurPercent(self.mIndex) .. "%)")
            else
                self.pLbTips:setString(tWords[15] .. 
                    "(" .. self:getCurPercent(self.mIndex) .. "%)")
            end
            -- 刻意减少到前2位，这样可以避免遗漏或者被跳过的现象
            local nTempIndex = self.mIndex - 2
            if(nTempIndex < 1) then
                nTempIndex = 1
            end
            self:requestFile(self.downloadList[nTempIndex].file,
                RequestFileType.RES, nTempIndex)
        end
    else -- 如果刚开始下载
        if(self.bIsAutoDown) then
            self.pLbTips:setString(tWords[18] .. 
                "(" .. self:getCurPercent(0) .. "%)")
        else
            self.pLbTips:setString(tWords[15] .. 
                "(" .. self:getCurPercent(0) .. "%)")
        end
        self:requestFile(self.downloadList[1].file, RequestFileType.RES, 1)
        -- 显示进度条
        if(self.pSlider) then
            self.pSlider:setVisible(true) -- 不检测更新时显示
        end
        --隐藏按钮
        if self.pLayBtnUpd then
            self.pLayBtnUpd:setVisible(false)
        end
    end
    -- 取消下载失败的标识
    self.bDownFailed = false
end
-- 获取最后下载的地址
-- _path（string）：当前相对路径
-- _bBack（bool）：是否为备用域名
function Launcher:checkFinalUrl( _path, _bBack, _type )
    if(_bBack == nil) then
        _bBack = false
    end
    dump(self.newVer)
    -- 如果需要增加版本路径，则增加版本控制下载路径
    if(bNeedVerDirControl and self.newVer and self.newVer.version) then
        local ver1 = getVerNumCfg(self.newVer.version)
        if(ver1 and ver1 > 0) then
            local nSindex, nEindex = string.find(PATCH_SERVER_ADDR, "/"..ver1.."/")
            if(nSindex == nil) then
                PATCH_SERVER_ADDR = PATCH_SERVER_ADDR .. ver1 .. "/"
            end
            nSindex, nEindex = string.find(PATCH_SERVER_ADDR_BACK, "/"..ver1.."/")
            if(nSindex == nil) then
                PATCH_SERVER_ADDR_BACK = PATCH_SERVER_ADDR_BACK .. ver1 .. "/"
            end
        end
    end
    local sFinalPath = ""
    if(_bBack) then
        sFinalPath = PATCH_SERVER_ADDR_BACK .. _path
    else
        sFinalPath = PATCH_SERVER_ADDR .. _path
    end
    if(RequestFileType.VER == _type) then -- 如果是版本文件
        sFinalPath = sVerPath
    elseif(RequestFileType.PACVER == _type) then-- 如果是apk包的版本文件
        sFinalPath = sPackVerPath
    end

    return sFinalPath
end
-- 执行联网行为
-- path（string）：相对路径
-- type（RequestFileType）: 连接类型
-- index（int）：当前加载到第几个
function Launcher:requestFile(path,type,index)
    local sFinalPath = self:checkFinalUrl(path, false, type)
    if self.bIsBack then
        self:requestBackFile(path,type,index)
        return
    end
    local request = cc.HTTPRequest:createWithUrl(
        function(event) self:onRequestFinished(event,type,index,path,false)end
        , sFinalPath, 0)
    -- 设置30秒的网络超时
    request:setTimeout(F_OUTTIME_HTTP_LANU)
    -- 开始执行网络连接
    request:start()
end
-- 备用联网行为
-- path（string）：相对路径
-- type（RequestFileType）: 连接类型
-- index（int）：当前加载到第几个
function Launcher:requestBackFile(path,type,index)
	local sFinalPath = self:checkFinalUrl(path, true, type)
    local request = cc.HTTPRequest:createWithUrl(
        function(event) self:onRequestFinished(event,type,index,path,true)end
        , sFinalPath, 0)
    request:setTimeout(F_OUTTIME_HTTP_LANU)
    request:start()
end
-- 回调结束
-- event（table）：http请求回调的事件
-- nType（RequestFileType）：连接类型
-- index（int）：当前下载到第几个
-- path（string）：相对路径
-- isBack（bool）：是否为备用行为
function Launcher:onRequestFinished(event,nType,index,path,isBack)
	if(not event) then -- 如果是返回没有数据
        -- 直接显示检测更新失败
        self:onDownloadFailed(nType)
        return
    end
    -- 执行失败
    local function doTempFailed( nType1,index1,path1,isBack1 )
        -- 如果是正式域名，判定是否超过失败次数
        if(not isBack1) then
            self.nNormalSerFailedTimes = self.nNormalSerFailedTimes + 1
            if(self.nNormalSerFailedTimes >= 3) then
                -- 如果正常域名失败3次，启用备用域名
                PATCH_SERVER_ADDR = PATCH_SERVER_ADDR_BACK
            end
        end
        if(not isBack1) then
            self.bIsBack = true
            -- 重置失败次数
            self.nFailedTimes = 0
            self:requestBackFile(path1,nType1,index1)
        else
            if(self.nFailedTimes and self.nFailedTimes >= 2) then
                self.bIsBack = false
                -- 展示下载失败的界面
                self.nFailedTimes = 0
                -- 检测更新失败
                self:onDownloadFailed(nType1)
            else
                self.bIsBack = true
                -- 重置失败次数
                self.nFailedTimes = self.nFailedTimes + 1
                self:requestBackFile(path1,nType1,index1)
            end
        end
    end
    -- 如果是下载失败
    if(event.name == "failed") then
        doTempFailed(nType,index,path,isBack)
        return
    end
    if(event.name ~= "completed") then
        return
    end
    local request = event.request -- 返回的数据
    local code = nil -- 返回的代号
    if(request) then
        code = request:getResponseStatusCode()
    end
    if(not code or code ~= 200) then
        doTempFailed(nType,index,path,isBack)
        return
    end
    -- 获取返回的数据
    local data = request:getResponseData()
    if(nType == RequestFileType.VER) then -- version.txt文件下载完成
        self:onFileVersionDownloaded(data)
    elseif(nType == RequestFileType.LCHR) then -- update.bin文件下载完成
        self:onFileUpdatebinDownloaded(data)
    elseif(nType == RequestFileType.PACVER) then -- packagever.txt文件下载完成
        self:onFilePackageVerDownloaded(data)
    elseif(nType == RequestFileType.FLIST) then -- flist.zip 文件下载完成
        self:onFileFlistDownloaded(data)
    else -- 单个资源文件下载完成
        self:onSingleFileDownloaded(index, data)
    end
end
-- version文件下载完成
-- _data(instream): verison文件的数据流
function Launcher:onFileVersionDownloaded( _data )
	self.newVer = luaDoString(_data)
    dump(self.newVer, "self.newVer")
    -- 如果load不到数据，认为下载失败
    if(self.newVer == nil or self.newVer.version == nil) then
        -- 下载失败
        self:onDownloadFailed(RequestFileType.VER)
        return
    end
    if(self.newVer) then
    	-- 修改CDN域名
        self:changeCDNDomain( self.newVer.CDNDomain )
    end
    --从apk包中中读取version文件
    local verStr = cc.FileUtils:getInstance():getDataFromFile("res/"..NAME_VER)
    self.installVer = luaDoString(verStr)
    -- 从upd目录中读取verison文件
    if isFileExistCfg(NAME_VER, 2) then
        self.updVer = dofile(UPD_FOLDER..NAME_VER)
    end
    -- 新版本中的数据
    local nCurCoreN, nMinCoreN, nMaxCoreN = N_CORE_DEFAULT, N_CORE_DEFAULT, N_CORE_DEFAULT
    if(self.newVer) then
        nCurCoreN, nMinCoreN, nMaxCoreN = self:departNewcore(self.newVer.cnewcore)
    end
    -- 更新目录下的数据
    local nCurCoreU, nMinCoreU, nMaxCoreU = N_CORE_DEFAULT, N_CORE_DEFAULT, N_CORE_DEFAULT
    if(self.updVer) then
        nCurCoreU, nMinCoreU, nMaxCoreU = self:departNewcore(self.updVer.cnewcore)
    end
    -- 包体目录下的数据
    local nCurCoreR, nMinCoreR, nMaxCoreR = N_CORE_DEFAULT, N_CORE_DEFAULT, N_CORE_DEFAULT
    if(self.installVer) then
        nCurCoreR, nMinCoreR, nMaxCoreR = self:departNewcore(self.installVer.cnewcore)
    end
    --当安装包中的code版本号和upd中的不同时,应该是重新安装了apk或者出现了错误,需要删除upd目录下的文件
    --最后把安装目录的flist重新写入upd中
    if(self.updVer == nil -- 不存在文件
        or (nCurCoreR ~= nCurCoreU) -- 包体中的核心版本与更新目录的不一致
        or getVerNumCfg(self.updVer.version) < getVerNumCfg(self.installVer.version) -- 包体的资源版本号更大
        ) then
        -- 清除目录
        cleanDir(UPD_FOLDER)
        if(___doReleaseZip) then
            ___doReleaseZip()
        end
        writeVersion(UPD_FOLDER..NAME_VER, self.installVer, self.installVer)
        self.updVer = self.installVer
        if(self.updVer) then
            nCurCoreU, nMinCoreU, nMaxCoreU = self:departNewcore(self.updVer.cnewcore)
        end
    end
    -- apk版本文件的下载路径
    sPackVerPath = sPackVerPath .. "packver_" .. nMaxCoreN .. "/" .. NAME_PACKVER
    -- 记录下载的版本号
    self.nFinalMaxCore = nMaxCoreN
    if(nCurCoreU < nMinCoreN) then -- 如果小于最低强更版本
        -- 执行强更行为
        self.nPackDownType = 1
        -- self:requestFile(NAME_PACKVER, RequestFileType.PACVER, 0)
        -- return
    else
        if(nCurCoreU < nMaxCoreN) then -- 有新包，但是可以不用强更
            self.nPackDownType = 2
            -- self:requestFile(NAME_PACKVER, RequestFileType.PACVER, 0)
            -- return
        else -- 已是最新版本
        end
    end
    -- 判断检测更新行为
    self:checkUpdatebin()
end
-- 下载update.bin完成
-- _data(instream)
function Launcher:onFileUpdatebinDownloaded(_data)
    local localmd5 = nil
    if isFileExistCfg(NAME_LCHR, 2) then
        localmd5 = cc.Crypto:MD5File(UPD_FOLDER..NAME_LCHR)
    else
        path = cc.FileUtils:getInstance():fullPathForFilename("res/"..NAME_LCHR)
        localmd5 = cc.Crypto:MD5File(path)
    end
    -- 读取服务器update.bin数据，保存在本地
    local rmf = UPD_FOLDER..NAME_LCHR..".tmp"
    -- 必须先删除多余的临时数据
    if isFileExistCfg(NAME_LCHR..".tmp", 2) then
        os.remove(rmf)
    end
    -- 将数据写入到临时数据中
    writeContentToFile(rmf,_data)
    -- 取得临时数据的md5值
    local rmtmd5 = cc.Crypto:MD5File(rmf)
    os.remove(rmf)
    -- 最新调整
    -- 判断md5值，如果有需求，重新载入update.bin
    if rmtmd5 ~= localmd5 then
        -- 写入新的文件
        if(_data ~= nil) then
            writeContentToFile(UPD_FOLDER .. NAME_LCHR, _data)
        end
    end
    local bNeed = false
    -- 修改当前版本号
    if(self.updVer and self.newVer) then
        self.newVer.binVer = self.newVer.binVer or 0
        self.updVer.binVer = self.updVer.binVer or 0
        if self.updVer.binVer < self.newVer.binVer then
            bNeed = true
            self.updVer.binVer = self.newVer.binVer
        end
    end
    -- 重置文件当前内容
    if bNeed and self.updVer and self.updVer.version then
        writeVersion(UPD_FOLDER..NAME_VER, self.updVer, self.updVer)
    end
    if self.nPackDownType == 0 then
        -- 检测资源更新（热更）
        self:checkVersionState()
    else
        -- -- 如果需要强更，那么执行重新加载update.bin
        -- package.preload["update.Launcher"] = nil
        -- -- 每次载入前都先置空，重头开始
        -- package.loaded["update.Launcher"] = nil
        -- -- 手机版本增加检测更新的内容
        -- cc.LuaLoadChunksFromZIP("update.bin")
        -- -- 重新执行检测更新的方法
        -- require "update.Launcher"

        -- 检测apk更新（强更）下次进游戏才执行新的update.bin
        self:requestFile(NAME_PACKVER, RequestFileType.PACVER, 0)
    end
end
-- 版本文件下载完成
-- _data（instream）: 数据流
function Launcher:onFilePackageVerDownloaded( _data )
    if(not _data) then
        -- 下载失败
        self:onDownloadFailed(RequestFileType.PACVER)
        return
    end
    self.tAllPackVers = luaDoString(_data)
    if(not self.tAllPackVers) then
        -- 下载失败
        self:onDownloadFailed(RequestFileType.PACVER)
        return
    end
    -- 等待处理
    local sPlatId = self.m_sPlatId -- 平台id
    local sPlatCid = self.m_sPlatCid -- 平台子包id
    if(self.tAllPackVers and self.tAllPackVers[sPlatId..":"..sPlatCid]) then
        local url = self.tAllPackVers[sPlatId..":"..sPlatCid].url
        local nDownType = self.tAllPackVers[sPlatId..":"..sPlatCid].type --下载途径1：表示普通下载 2：表示市场下载
        if nDownType == 1 then --普通下载
            --获取文件名
            self.sApkName = sPlatId.."_"..sPlatCid .. ".apk"
            local tT = string.split(url, "/")
            if tT and table.nums(tT) > 0 then
                local nSize = table.nums(tT)
                self.sApkName = tT[nSize]
            end
            if isFileExistCfg(self.sApkDownloadPath .. self.sApkName, 3) then
                --安装新包
                installNewPack(self.sApkDownloadPath .. self.sApkName)
            else
                 --展示下载整包提示框
                self:showPackageUpdateTips(url)
            end
        elseif nDownType == 2 then --市场下载
            --市场下载的情况只需要跳过去就可以了
            if target == PLATFORM_OS_WINDOWS then -- win32
            elseif target == PLATFORM_OS_ANDROID then -- android
                -- 跳转到市场去下载
                local className = "org/cocos2dx/utils/PSNative"
                local methodName = "openURL"
                local bOk, ret = luaj.callStaticMethod(className, methodName, {url}, 
                    "(Ljava/lang/String;)V")
            elseif target == PLATFORM_OS_IPAD or target == PLATFORM_OS_IPHONE then -- ios
                if(url == nil) then
                    print("跳转地址为空")
                    return 
                end
                local param = {}
                param.sPath = url
                param.nType = 1
                param.nBrowser = 1
                local bOk, sValue = CCLuaObjcBridge.callStaticMethod("PlatformSDk", 
                    "openURL", param)
            end
        end
    end
end

--展示apk更新提示
--_sUrl：下载apk地址
function Launcher:showPackageUpdateTips( _sUrl )
    -- body
     MViewReader:getInstance():createNewGroup("app.jsontolua.layout_update_pack",function ( pView )
        -- body
        if target == PLATFORM_OS_WINDOWS then -- win32下缩放一下
            pView:setScale(display.width / 640)
        end
        self.pUpdatePackView = pView
        self:addView(pView,10)
        centerInView(self,pView)
        --title
        local pLbTitle = pView:findViewByName("lb_title")
        pLbTitle:setString(tWords[22])
        --content
        local pLayContent = pView:findViewByName("lay_content")
        local pLabContent = MUI.MLabel.new({
            text = "",
            size = 20,
            anchorpoint = cc.p(0.5, 0.5),
            align = cc.ui.TEXT_ALIGN_CENTER,
            valign = cc.ui.TEXT_VALIGN_TOP,
            color = cc.c3b(255, 255, 255),
            dimensions = cc.size(450, 0),
            })
        pLayContent:addView(pLabContent)
        centerInView(pLayContent,pLabContent)
        --左边按钮
        local pLayBtnL = pView:findViewByName("lay_btn_l")
        local pLbBtnL = pView:findViewByName("lb_btn_l")
        pLayBtnL:setViewTouched(true)
        
        --右边按钮
        local pLayBtnR = pView:findViewByName("lay_btn_r")
        local pLbBtnR = pView:findViewByName("lb_btn_r")
        pLbBtnR:setString(tWords[17])
        pLayBtnR:setViewTouched(true)
        pLayBtnR.sPackUrl = _sUrl --强更链接
        pLayBtnR:onMViewClicked(handler(self, self.onDownPackageClilked))
        --强更类型
        if self.nPackDownType == 1 then --强更一定更
            pLabContent:setString(tWords[4])
            pLbBtnL:setString(tWords[19])
            pLayBtnL:onMViewClicked(handler(self, self.onExitGame))
        elseif self.nPackDownType == 2 then --强更可不更
            pLabContent:setString(tWords[21])
            pLbBtnL:setString(tWords[20])
            pLayBtnL:onMViewClicked(handler(self, self.cancelUpdatePack))
        end
    end)
end

--退出游戏
function Launcher:onExitGame( pView )
    -- body
    cc.Director:getInstance():endToLua()
end

--取消强更更新
function Launcher:cancelUpdatePack( pView )
    -- body
    if self.pUpdatePackView then
        self.pUpdatePackView:setVisible(false)
    end
    --热更检测
    self:checkVersionState()
end

--整包下载失败目前定义为重新下载
function Launcher:onDownLoadApkFailed( )
    -- body
    if self.pUpdatePackView then
        self.pUpdatePackView:setVisible(true)
    end
end

--执行强更处理
function Launcher:onDownPackageClilked( pView )
    -- body
    if self.pUpdatePackView then
        self.pUpdatePackView:setVisible(false)
    end
    local url = pView.sPackUrl
    -- 显示进度条
    if(self.pSlider) then
        self.pSlider:setVisible(true) -- 不检测更新时显示
    end
    local request = cc.HTTPRequest:createWithUrl(
        function(event) 
            if(event.name == "failed") then
                myprint("整包下载失败！failed")
                self:onDownLoadApkFailed()
            elseif(event.name == "completed")then
                local request = event.request -- 返回的数据
                local code = nil -- 返回的代号
                if(request) then
                    code = request:getResponseStatusCode()
                end
                if(not code or code ~= 200) then
                    myprint("下载完成失败 code ~= 200")
                    self:onDownLoadApkFailed()
                else
                    -- 获取返回的数据
                    local data = request:getResponseData()
                    --apk整包下载完成
                    self:onApkDownloaded(data)
                end
            elseif(event.name == "progress")then
                --进度计算
                local nPercent = math.ceil(event.dltotal / event.total * 100)
                if nPercent > 0 then
                    self.pSlider:setSliderValue(nPercent)
                end
                self.pLbTips:setString(tWords[24] .. "(" .. nPercent .. "%)")
            end
        end
        , url, 0)
    -- 设置网络超时的超时时间(30分钟)
    request:setTimeout(18 * 100)
    -- 开始执行网络连接
    request:start()
end

--整包apk下载完成
function Launcher:onApkDownloaded( data )
    -- body
    --展示下载完成
    self.pSlider:setSliderValue(100)
    self.pLbTips:setString(tWords[24] .. "(100%)")
    writeContentToFile(self.sApkDownloadPath .. self.sApkName,data)
    --安装新包
    installNewPack(self.sApkDownloadPath .. self.sApkName)
end

-- 判断update.bin是否需要更新
function Launcher:checkUpdatebin(  )
    myprint("更新目录版本号:"..self.updVer.version)
    -- 判断是否需要更新udpate.bin
    self.newVer.binVer = self.newVer.binVer or 0
    self.updVer.binVer = self.updVer.binVer or 0
    local nNewBinVer = self.newVer.binVer
    local nOldBinVer = self.updVer.binVer
    if(nNewBinVer > nOldBinVer) then -- 有新版本
        -- 重新下载update.bin
        self:requestFile(NAME_LCHR, RequestFileType.LCHR, 0)
        return
    end
    if self.nPackDownType == 0 then
        -- 检测资源更新（热更）
        self:checkVersionState()
    else
        -- 检测apk更新（强更）
        self:requestFile(NAME_PACKVER, RequestFileType.PACVER, 0)
    end
end

-- 判断是否需要更新资源
function Launcher:checkVersionState(  )
    if(self.updVer and self.newVer) then
        --取出版本号的数字
        local ver1 = getVerNumCfg(self.updVer.version)
        local ver2 = getVerNumCfg(self.newVer.version)
        local bShenhe = false
        -- 判断是否存于审核情况下
        if(self.newVer.shver and string.len(self.newVer.shver) > 0) then
            local nVer = self.newVer.shver
            local nCurVer = getStringDataCfg("bundleVersion")
            if(nVer ~= nil and nCurVer ~= nil and nVer == nCurVer) then
                bShenhe = true
            end
        end
        --检测是否需要更新
        if ver2 <= ver1 or bShenhe then
            if(self.pSlider) then
                self.pSlider:setSliderValue(100)
            end
            self:gotoGame()
            return
        end
    end

    --游戏提示语
    -- local pLayGameTips = self:findViewByName("lay_game_tips")
    -- if showGameTips and pLayGameTips then
    --     showGameTips(pLayGameTips)
    -- end
    
    --下载flist,比较需要更新的文件
    self:requestFile(NAME_FZIP, RequestFileType.FLIST, 0)
end
-- flist.zip 文件下载完成
-- _data(instream): flist.zip的数据流
function Launcher:onFileFlistDownloaded( _data )
    local dbZip = lz.inflate()(_data, KEY_TOZIP)
    self.newList = luaDoString(dbZip)
    -- 如果load不到数据，认为下载失败
    if(self.newList == nil) then
        self:onDownloadFailed(RequestFileType.FLIST)
        return 
    end
    --从安装目录中读取flist文件
    local resZipFlist = cc.FileUtils:getInstance():getDataFromFile("res/"..NAME_FZIP)
    local flistStr = lz.inflate()(resZipFlist, KEY_TOZIP)
    local installList = luaDoString(flistStr)
    --检查更新目录中的flist文件
    local fileName = UPD_FOLDER..NAME_FLIST
    local updlist = nil
    if isFileExistCfg(NAME_FLIST, 2) then
        updlist = dofile(fileName)
    end
    --当更新目录中没有找到flist文件,把安装目录中的写进去
    if updlist==nil then
        writeFlist(UPD_FOLDER..NAME_FLIST, installList)
        updlist = installList
    end
    --创建资源目录
    local dirPaths = self.newList.dirs
    for i=1,#(dirPaths) do
        -- 如果不存在目录，创建新目录
        mkDir(UPD_FOLDER..(dirPaths[i].name))
    end
    --比较flist,得到需要更新的文件
    local filemap = {}
    for _,v in ipairs(updlist.files) do
        filemap[v.file] = {name = v.file,md5 = v.md5}
    end
    local count = 0 -- 下载的总大小
    for i,v in ipairs(self.newList.files) do
        --判断哪些需要更新
        local t = filemap[v.file]
        if  t== nil or t.md5 ~= v.md5 then
            --比较本地实际文件的md5值
            local md5 = cc.Crypto:MD5File(UPD_FOLDER..v.file)
            if md5 ~= v.md5 then
                self.downloadList = self.downloadList or {}
                table.insert(self.downloadList, v)
                count = count + tonumber(v.size,10)
            end
        end 
    end
    -- 判断是否需要执行资源下载
    if self.downloadList == nil or #self.downloadList <= 0 then
        if(not self.bIsCDNDomain) then
            -- 不需要改变版本号
            self.bNCVersion = false
            self:onPatchFinished()
        else
            -- 如果CDN中flist没有内容变化，重新下载源里面的flist
            PATCH_SERVER_ADDR = PATCH_SERVER_ADDR_BACK
            -- 改变状态
            self.bIsCDNDomain =  false
            --下载flist,比较需要更新的文件
            self:requestFile(NAME_FZIP, RequestFileType.FLIST, 0)
        end
    else
        -- 需要改变版本号
        self.bNCVersion = true
        --开始更新
        self:onShowUpdate(count)
    end
end
-- 全部下载完成
function Launcher:onPatchFinished()
    -- 还需要处理version文件的保存（等待处理）
    -- --更新flist文件
    if self.newVer and self.newVer.version and self.bNCVersion then
        writeVersion(UPD_FOLDER..NAME_VER, self.newVer, self.updVer)
    end
    -- 更新flist文件
    if self.newList and self.bNCVersion then
        writeFlist(UPD_FOLDER..NAME_FLIST, self.newList)
    end
    if(self.pSlider) then
        self.pSlider:setSliderValue(100)
    end
    --进入游戏
    self:gotoGame()
end
-- 展示需要下载的资源大小，包括展示更新说明
function Launcher:onShowUpdate( _size )
    -- 计算更新内容大小
    local num = (math.floor(_size/1024/1024*100))/100
    if(self.newVer and self.newVer.minAskSize 
        and num < tonumber(self.newVer.minAskSize)) then
        self.bIsAutoDown = true
        -- 执行自动下载（等待处理）
        self:onDownloadClicked()
    else
        self.bIsAutoDown = false
        if num < 0.1 then
            num = (math.floor(_size/1024*100))/100
            self.pLbTips:setString(tWords[6]..num .. "k"..tWords[16])
        else
            self.pLbTips:setString(tWords[6]..num .. "M" ..tWords[16])
        end
        if _size > 0 then
            if self.pLayBtnUpd then
                self.pLayBtnUpd:setVisible(true)
            end
            -- 显示更新公告
            if(self.newVer) then
                self:showUpdateNotice(self.newVer.content)
            end
        end
    end
end
-- 展示更新公告
function Launcher:showUpdateNotice( sContent )
    if(sContent and string.len(sContent) > 0) then
        local nSindex, nEindex = string.find(sContent, "\n")
        if(nSindex) then
            -- 替换所有换行标识
            sContent = string.gsub(sContent, "\n", "")
        end
        if self.pLayUpd then
            self.pLayUpd:setVisible(true)
            local pLabelView = MUI.MLabel.new({
                text = sContent,
                size = 24,
                anchorpoint = cc.p(1, 0.5),
                color = cc.c3b(255, 255, 255),
                dimensions = cc.size(self.pSv:getWidth() , 0),
            })
            self.pSv:addView(pLabelView)
        end
    else
        self:hideUpdateNotice()
    end
end
-- 隐藏更新公告
function Launcher:hideUpdateNotice(  )
    if(self.pLayUpd) then
        self.pLayUpd:setVisible(false)
    end
end
-- 下载单个文件完成
-- _index(int): 当前文件在临时下载列表中的下标
-- _data（instream）：当前文件的数据流
function Launcher:onSingleFileDownloaded(_index,_data)
    -- 获取当前下载完成的单条数据
    local info = self.downloadList[_index]
    local fullpath = UPD_FOLDER..info.file
    if info.file == "data/game.zip" then
        self:onZipFinished(_data)
    else
        writeContentToFile(fullpath,_data)
    end

    local num = self:getCurPercent(_index)
    -- 延迟判断是否已经更新完成
    if(self.pSlider) then
        self.pSlider:setPercentToByTime(0.08, num, 
            handler(self,self.checkFile))
    end
    if(self.pLbTips) then
        if(self.bIsAutoDown) then
            self.pLbTips:setString(tWords[18] .. 
                "(" .. num .. "%)")
        else
            self.pLbTips:setString(tWords[15] .. 
                "(" .. num .. "%)")
        end
    end
    -- performActionDelayCfg(self, handler(self,self.checkFile), 0.1)
    -- 记录当前下载的位置
    self.mIndex = _index
    -- 刷新进度完成
    self:onUpdateActionEnd()
end
-- 数据库文件下载完成的情况
function Launcher:onZipFinished( _data )
    local dbZip = lz.inflate()(_data, KEY_TOZIP)
    writeContentToFile(UPD_FOLDER.."data/"..NAME_GAMEDB, dbZip)
end
-- 更新进度，下载下一个文件
function Launcher:onUpdateActionEnd(  )
    -- 判断是否已经结束了
    if self.mIndex >= #self.downloadList then
        self.isOver = true
        return
    end
    -- 下标加1，下载下一个需要更新的文件
    self.mIndex = self.mIndex+1
    self:requestFile(self.downloadList[self.mIndex].file,
        RequestFileType.RES, self.mIndex)
end
-- 下载失败
function Launcher:onDownloadFailed( nType )
    -- 标志为下载失败
    self.bDownFailed = true
    -- 失败的类型
    self.nFailedType = nType
    -- 增加失败记录次数
    self.nNormalSerFailedTimes = self.nNormalSerFailedTimes + 1
    --按钮展示
    if self.pLayBtnUpd then
        self.pLayBtnUpd:setVisible(true)
    end
    --更新按钮文字
    if self.pLbBtnUpd then
        self.pLbBtnUpd:setString(tWords[23])
    end
    -- 重新设置提示语
    if(self.pLbTips) then
        self.pLbTips:setString(tWords[3])
    end
end

-- 修改CDN域名
function Launcher:changeCDNDomain( _sDomain )
    if(not _sDomain or string.len(_sDomain) <= 0) then
        return
    end
    if(string.find(PATCH_SERVER_ADDR, S_CDN_RESDOMAIN)) then
        PATCH_SERVER_ADDR = string.gsub(PATCH_SERVER_ADDR, S_CDN_RESDOMAIN, _sDomain)
    end
end
-- 解析核心版本控制的语句
-- sStr(string): 格式为：   33:533&0:0:0;
function Launcher:departNewcore( sStr )
    local nCurCore = N_CORE_DEFAULT -- 当前版本,默认值
    local nMaxCore = N_CORE_DEFAULT -- 最高版本
    local nMinCore = N_CORE_DEFAULT -- 最低版本
    if(not sStr or string.len(sStr) <= 0) then
        return nCurCore, nMinCore, nMaxCore
    end
    local sPlatId = self.m_sPlatId -- 平台id
    local sPlatCid = self.m_sPlatCid -- 平台子包id
    local sFinalId = sPlatId .. ":" .. sPlatCid
    -- 如果找不到该包的特殊包版本号，使用默认的版本号
    if(not string.find(sStr, sFinalId)) then
        -- 使用-1:-1去查找的话，会存在问题，所以修改成用all的关键字查找
        sFinalId = "all" .. ":" .. "all"
    end
    local tStrs = string.split(sStr, ";")
    if(tStrs and #tStrs > 0) then
        for i, v in pairs(tStrs) do
            -- 找到对应渠道
            if(string.find(v, sFinalId)) then
                local tTmps = string.split(v, "&")
                -- 大于2个参数
                if(tTmps and #tTmps >= 2) then
                    local sTmp = tTmps[2]
                    if(sTmp and string.len(sTmp) > 0) then
                        local tFounds = string.split(sTmp, ":")
                        if(tFounds and #tFounds >= 3) then
                            nCurCore = tonumber(tFounds[1]) or N_CORE_DEFAULT
                            nMinCore = tonumber(tFounds[2]) or N_CORE_DEFAULT
                            nMaxCore = tonumber(tFounds[3]) or N_CORE_DEFAULT
                            break
                        end
                    end
                end
            end
        end
    end
    return nCurCore, nMinCore, nMaxCore
end
-- 获取当前进度数字
function Launcher:getCurPercent( _index )
    local nPer = 0
    if(self.downloadList) then
        nPer = math.floor((_index / (#self.downloadList)) * 100)
    end
    return nPer
end
-- 检查文件是否完成
function Launcher:checkFile()
    if self.isOver then
        performActionDelayCfg(self, function (  )
            self:onPatchFinished()
        end, 0.3)
        return
    end
end
-- 跳转到登录界面
function Launcher:gotoGame( )
    performActionDelayCfg(self, function (  )
        gotoLogin()
    end, 0.01)
end
-- 启动游戏
local pScene = cc.Scene:create()
local pLauncher = nil


if true then
    pLauncher = Launcher.new()
else 
    require "app.Test"
    pLauncher = Test.new()
end

pScene:addChild(pLauncher)
local sharedDirector = cc.Director:getInstance()
if sharedDirector:getRunningScene() then
    sharedDirector:replaceScene(pScene)
else
    sharedDirector:runWithScene(pScene)
end
