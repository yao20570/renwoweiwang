-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-03 17:29:17 
-- Description: 国家商店管理
-----------------------------------------------------
local DataCountryTask = require("app.layer.newcountry.countrytask.data.DataCountryTask")
--[5049]加载国家任务
SocketManager:registerDataCallBack("LoadCountryTask",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.LoadCountryTask.id then
			-- dump(__msg.body, "LoadCountryTask", 100)
			Player:getCountryTaskData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_countrytask)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)
-- --[-5050]国家商店数据推送
SocketManager:registerDataCallBack("pushCountryTask",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.pushCountryTask.id then
			-- dump(__msg.body, "pushCountryTask", 100)
			Player:getCountryTaskData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_countrytask)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--[5100]领取国家任务奖励
SocketManager:registerDataCallBack("getCountryTaskReward",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.getCountryTaskReward.id then
			-- dump(__msg.body, "getCountryTaskReward", 100)
			Player:getCountryTaskData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_countrytask)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--获得国家任务信息
function Player:getCountryTaskData(  )
	-- body
	if not Player.pCountryTaskData then
		self:initCountryTaskData()
	end
	return Player.pCountryTaskData
end

-- 初始化国家任务信息
function Player:initCountryTaskData(  )
	if not Player.pCountryTaskData then
		Player.pCountryTaskData = DataCountryTask.new() --国家任务信息
	end
	return "Player.pCountryTaskData"
end

--释放国家任务信息
function Player:releaseCountryTaskData(  )
	if Player.pCountryTaskData then
		Player.pCountryTaskData = nil --国家任务信息
	end
	return "Player.pCountryTaskData"
end



