-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-04-04 13:59:17 
-- Description: 国家互助管理
-----------------------------------------------------
local DataCountryHelp = require("app.layer.newcountry.newcountryhelp.data.DataCountryHelp")
--[5049]加载国家任务
SocketManager:registerDataCallBack("loadcountryhelp",function ( __type, __msg )
	-- body
	-- dump(__msg, "国家互助数据", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadcountryhelp.id then
			Player:getCountryHelpData():refreshDatasByService(__msg.body.helps)
			sendMsg(gud_refresh_countryhelp)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)
-- --[-5047]国家数据推送
SocketManager:registerDataCallBack("countryhelpupdate",function ( __type, __msg )
	-- body
	-- dump(__msg,"国家互助数据更新",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.countryhelpupdate.id then
			Player:getCountryHelpData():refreshDatasByService(__msg.body.helps)
			sendMsg(gud_refresh_countryhelp)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--
SocketManager:registerDataCallBack("countrygethelpupdate",function ( __type, __msg )
	-- body
	-- dump(__msg, "countrygethelpupdate ", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.countrygethelpupdate.id then
			if __msg.body and __msg.body.helpName then
				TOAST(string.format(getConvertedStr(1,10428), __msg.body.helpName))
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--建筑请求协助
SocketManager:registerDataCallBack("buildupinghelp",function ( __type, __msg, __oldMsg )
	-- body
	-- dump(__msg, "建筑升级请求协助数据",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.buildupinghelp.id then
			local tT = __msg.body
			tT.loc = __oldMsg[1]
			Player:getBuildData():addBuildUpding({tT},1)
			TOAST(getConvertedStr(1,10422))
			sendMsg(gud_refresh_countryhelp)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)


--科技请求协助
SocketManager:registerDataCallBack("scienceupinghelp",function ( __type, __msg, __oldMsg )
	-- body
	-- dump(__msg, "科技请求协助数据",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.scienceupinghelp.id then
 			local tT = __msg.body
			Player:getTnolyData():refreshUpingTnolyByAction(tT, __msg.body.op,__oldMsg[1])
			TOAST(getConvertedStr(1,10423))
			sendMsg(gud_refresh_countryhelp)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--装备打造请求协助
SocketManager:registerDataCallBack("makevoupinghelp",function ( __type, __msg, __oldMsg )
	-- body
	-- dump(__msg, "装备打造请求协助数据",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.makevoupinghelp.id then
			local tMakeVo = Player:getEquipData():getMakeVo()
			if tMakeVo then
				tMakeVo:update(__msg.body.m)
			end
			TOAST(getConvertedStr(1,10424))
			sendMsg(gud_equip_makevo_change_msg)
			
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--协助
SocketManager:registerDataCallBack("countryhelp",function ( __type, __msg, __oldMsg )
	-- body
	-- dump(__msg, "协助",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.countryhelp.id then
			TOAST(getConvertedStr(1,10431))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)


--获得国家互助信息
function Player:getCountryHelpData(  )
	-- body
	if not Player.pCountryHelpData then
		self:initCountryHelpData()
	end
	return Player.pCountryHelpData
end

-- 初始化国家互助信息
function Player:initCountryHelpData(  )
	if not Player.pCountryHelpData then
		Player.pCountryHelpData = DataCountryHelp.new() --国家任务信息
	end
	return "Player.pCountryHelpData"
end

--释放国家互助信息
function Player:releaseCountryHelpData(  )
	if Player.pCountryHelpData then
		Player.pCountryHelpData = nil --国家任务信息
	end
	return "Player.pCountryHelpData"
end



