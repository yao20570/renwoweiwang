-- 注销require进来的lua代码
-- _luaName（string）：lua代码的路径
-- _bReload（bool）：是否重新加载
function destroyLuaLoaded( _luaName, _bReload )
    if(not _luaName) then
        return
    end
    package.loaded[_luaName] = nil
    package.preload[_luaName] = nil
    -- 重新载入updconfig
    if(_bReload) then
        require(_luaName)
    end
end
-- 重新载入工具类
destroyLuaLoaded("app.updatecfg.UpdUtils", true)
destroyLuaLoaded("app.updatecfg.SDKUtils", true)

local tLeis = {}
tLeis[#tLeis+1]="app.updatecfg.UpdConfig"
tLeis[#tLeis+1]="framework.functions"
tLeis[#tLeis+1]="framework.debug"
-- 为了引入打印的方法
for i, v in pairs(tLeis) do
    if(i > 1) then
        require(v)
    end
end

S_YUAN_RESDOMAIN = "http://res.dwby.tmsjyx.com/" -- 源站的域名地址
S_CDN_RESDOMAIN = "http://cdn.dwby.tmsjyx.com/" -- cdn的域名地址
S_INNER_RESDOMAIN = "http://inner.tmsjyx.com:10000/"

if(getLanguageType() == 1) then -- 国内版本
    if (N_PACK_MODE >= 1000 and N_PACK_MODE < 1100 ) then -- 测试包
        S_ACCOUNT_SERVER_ADDRESS = "http://inner.tmsjyx.com:30005" -- 帐号服地址
        S_KKK_PLAT_CHANNELID_DEFAULT = "10000" -- 默认3k的平台渠道号
        S_KKK_CHILD_CHANNELID_DEFAULT = "1" -- 默认3k的平台的子渠道号
    elseif (N_PACK_MODE >= 1100 and N_PACK_MODE < 1200) then --同步包
        S_ACCOUNT_SERVER_ADDRESS = "http://qauser.dwby.tmsjyx.com:20022" -- 地址
        S_KKK_PLAT_CHANNELID_DEFAULT = "20000" -- 默认3k的平台渠道号
        S_KKK_CHILD_CHANNELID_DEFAULT = "1" -- 默认3k的平台的子渠道号
    else
        S_ACCOUNT_SERVER_ADDRESS = "http://account.dwby.inapk.com:20022" -- 地址
        S_KKK_PLAT_CHANNELID_DEFAULT = "0" -- 默认3k的平台渠道号
        S_KKK_CHILD_CHANNELID_DEFAULT = "9082" -- 默认3k的平台的子渠道号
        if(N_PACK_MODE >= 1500) then
            -- 重新定义资源服务器域名
            S_YUAN_RESDOMAIN = "http://res.dwby.inapk.com/" -- 源站的域名地址
            S_CDN_RESDOMAIN = "http://cdn.dwby.inapk.com/" -- cdn的域名地址
        end
    end
end

S_IMEI_DEFAULT = "000000000000000" -- 默认的imei号
local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()
if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    S_IMEI_DEFAULT = "00000000-0000-0000-0000-000000000000" -- 默认的imei号
end
S_MAC_DEFAULT = "00:00:00:00:00" -- 默认的mac地址
ENCRYPT_KEY = "0GCSqGSIb3DQEBAQUAA4GNADCBiQ" -- 加密的key值
KKK_PLATFORM_ID = "KKKPlatformId" -- 平台字段名称
KKK_PLATFORM_CHILD_ID = "KKKPlatformChildId" -- 平台子包字段名称
UPD_FOLDER = S_WRITABLE_PATH .. "upd/" -- 更新下载后的文件目录
N_CORE_DEFAULT = 0 -- 默认的core版本值
N_CORE_CHANNEL_DEFAULT = "all" -- 获取newcore版本时的默认渠道值
USING_ENCRYPT = true -- http是否使用加密方式
GAMEDB = "game.db" -- 游戏的数据表
GAMEZIP = "game.zip" -- 游戏的加密内容
KEY_TOZIP = "finish" -- 加密key值

F_OUTTIME_HTTP_LANU = 15 -- http超时时间
mkDir(UPD_FOLDER)

HAD_SAVE_ERROR = false --是否已经保存了报错次数
UPDATE_BIN_FINISH = false --update.bin是否执行完成

-- 刷新所有http地址的内容
local function updateAllServerDomain(  )
    if(N_PACK_MODE == 1000) then
    end
end
updateAllServerDomain()

--初始化完成
--nState:1表示成功   2表示失败
function endInitSDK( nState )
    -- body
    if nState == nil then
        print("初始化结果状态不能为空")
        return 
    end
    if tonumber(nState) == 1 then
        CCNotificationCenter:sharedNotificationCenter():postNotification("INIT_SDK_STATE_AT_SUCCESS")
    elseif tonumber(nState) == 2 then
        CCNotificationCenter:sharedNotificationCenter():postNotification("INIT_SDK_STATE_AT_FAILURE")
    end
end
-- 确定语言类型
function getLauncherLanguageCfg(  )
    local sStr = ""
    sStr = "app.worldlan.cn.LanCfg"
    return sStr
end

--获取资源版本号
function getPackageResVer(  )
    -- body
    --资源版本号
    local verStr = cc.FileUtils:getInstance():getDataFromFile(UPD_FOLDER.."version.txt")
    if verStr == nil or verStr == "" then
        verStr = cc.FileUtils:getInstance():getDataFromFile("res/".."version.txt")
    end
    -- 本地版本号
    local installVer = luaDoString(verStr)
    if installVer and installVer.version then
        return installVer.version, installVer
    end
    return "1.0.0", installVer
end

-- 跳转到游戏界面内
function gotoLogin(  )
    -- 执行解压
    if (___doUncompressZip) then
        ___doUncompressZip()
    end
    clearOldLuaLoaded()
    copyGameDB()
    -- 置空之前加载进来的内容
    for i, v in pairs(tLeis) do
        destroyLuaLoaded(v, i == 1)
    end
    require("app.MyApp").new():run()
end