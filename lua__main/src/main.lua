
S_WRITABLE_PATH = cc.FileUtils:getInstance():getWritablePath() -- 可读写的路径
local target = cc.Application:getInstance():getTargetPlatform()
PLATFORM_OS_WINDOWS = 0
PLATFORM_OS_ANDROID = 3
PLATFORM_OS_IPHONE  = 4
PLATFORM_OS_IPAD    = 5
if target == PLATFORM_OS_WINDOWS then
	cc.FileUtils:getInstance():addSearchPath("res/")
else
	if target == PLATFORM_OS_IPHONE or target == PLATFORM_OS_IPAD then
		-- ios包针对icloud备份做了特殊处理，调整可读写目录的路径
		if(S_WRITABLE_PATH and string.find(S_WRITABLE_PATH, "/Documents")) then
		    S_WRITABLE_PATH = string.gsub(S_WRITABLE_PATH, "/Documents", "/Library/Caches")
		end
	end
	local updDir = S_WRITABLE_PATH.."upd/"
	-- 增加检测更新的路径地址
	cc.FileUtils:getInstance():addSearchPath(updDir)
	cc.FileUtils:getInstance():addSearchPath("res/")
	-- 手机版本增加检测更新的内容
	cc.LuaLoadChunksFromZIP("update.bin")
end
-- 增加需要正常的查询目录
package.path = package.path .. ";src/?.lua;src/framework/protobuf/?.lua"
cc.FileUtils:getInstance():setPopupNotify(false)
-- 每次载入前都先置空，重头开始
package.loaded["update.Launcher"] = nil
-- 重新执行检测更新的方法
require "update.Launcher"