-- DayLoginController.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-30 13:57:23 星期五
-- Description: 每日登录奖励操作类
-----------------------------------------------------

local DayLoginData = require("app.layer.dayloginawd.DayLoginData")


--[4019]检查是否可以领取每日奖励回调
-- SocketManager:registerDataCallBack("reqCheckDayAwards",function ( __type, __msg )
-- 	if __msg.head.state == SocketErrorType.success then
-- 		-- dump( __msg.body,"加载每日登录奖励数据=",100)	
-- 		if __msg.body then
-- 			Player:getDayLoginData():refreshDatasByService(__msg.body)
-- 			-- sendMsg(gud_refresh_dayloginawards) --通知刷新界面
-- 		end
-- 	end
-- end)

--[4018]请求领取每日奖励回调
-- SocketManager:registerDataCallBack("reqGetDayAwards",function ( __type, __msg )
-- 	if __msg.head.state == SocketErrorType.success then
-- 		-- dump( __msg.body,"领取每日登录奖励数据=",100)	
-- 		if __msg.body then
-- 			Player:getDayLoginData():setGetAwardState(1)
-- 			-- sendMsg(gud_refresh_dayloginawards) --通知刷新界面
-- 		end
-- 	end
-- end)

--[4041]每日登录0点推送
SocketManager:registerDataCallBack("pushDayLoginAwards",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		-- dump( __msg.body,"推送每日登录奖励数据=",100)	
		if __msg.body then
			Player:getDayLoginData():refreshDatasByService(__msg.body)
			-- sendMsg(gud_refresh_dayloginawards) --通知刷新界面
		end
	end
end)

--[2010]请求已经引导过的界面数据(建筑引导)
SocketManager:registerDataCallBack("reqGetAlreadyGuided",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		-- dump( __msg.body,"引导过的界面数据=",100)	
		if __msg.body then
			Player:getDayLoginData():setAlreadyGuidedView(__msg.body.rec)
		end
	end
end)

--[2011]记录已经引导过的界面id
SocketManager:registerDataCallBack("reqPlayGuideDlg",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
		end
	end
end)


--获得每日登录奖励数据单例
function Player:getDayLoginData()
	-- body
	if not Player.pDayLoginData then
		self:initDayLoginData()
	end
	return Player.pDayLoginData
end

-- 初始化每日登录奖励数据
function Player:initDayLoginData(  )
	if not Player.pDayLoginData then
		Player.pDayLoginData = DayLoginData.new()
	end
	return "Player.pDayLoginData"
end

--释放每日登录奖励数据
function Player:releaseDayLoginData(  )
	if Player.pDayLoginData then
		Player.pDayLoginData = nil
	end
	return "Player.pDayLoginData"
end