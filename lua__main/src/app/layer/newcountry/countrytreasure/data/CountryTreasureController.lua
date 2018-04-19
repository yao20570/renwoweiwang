-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-30 16:32:17 
-- Description: 国家宝藏管理
-----------------------------------------------------
local DataCountryTreasure = require("app.layer.newcountry.countrytreasure.data.DataCountryTreasure")

--[-5036]登录加载宝藏列表数据
SocketManager:registerDataCallBack("loadCountryTreasureList",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadCountryTreasureList.id then
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			sendMsg(ghd_refresh_country_treasure)
		end
	end
end)
-- --[-5037]加载我的宝藏列表数据
SocketManager:registerDataCallBack("loadMyCountryTreasure",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadMyCountryTreasure.id then
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			sendMsg(ghd_refresh_country_treasure)			
		end
	end
end)

-- --[-5038]加载我的宝藏帮助列表数据
SocketManager:registerDataCallBack("loadCountryTreasureHelpList",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadCountryTreasureHelpList.id then
			-- dump(__msg.body, "__msg.body", 100)
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			sendMsg(ghd_refresh_country_treasure)
		end
	end
end)
-- --[-5106]宝藏列表数据刷新推送
SocketManager:registerDataCallBack("refreshCountryTreasure",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.refreshCountryTreasure.id then
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			sendMsg(ghd_refresh_country_treasure)
		end
	end
end)

-- --[-6414] --6415
-- SocketManager:registerDataCallBack("nationaltreasure",function ( __type, __msg )
-- 	-- body
-- 	if __msg.head.state == SocketErrorType.success then		
-- 		if __msg.head.type == MsgType.nationaltreasure.id then
-- 			Player:getNationalTreasureData():refreshDatasByService(__msg.body)
-- 			if __msg.body and __msg.body.o then
-- 				--获取物品效果
-- 				showGetAllItems(__msg.body.o)
-- 			end
-- 		end
-- 	else
-- 		TOAST(SocketManager:getErrorStr(__msg.head.state))						
-- 	end
-- end)


-- SocketManager:registerDataCallBack("treasurecongratu",function ( __type, __msg )
-- 	-- body
-- 	if __msg.head.state == SocketErrorType.success then	
-- 		if __msg.head.type == MsgType.treasurecongratu.id then
-- 			Player:getNationalTreasureData():refreshDatasByService(__msg.body)
-- 			if __msg.body and __msg.body.ob then
-- 				--获取物品效果
-- 				showGetAllItems(__msg.body.ob)
-- 			end
-- 		end
-- 	else
-- 		TOAST(SocketManager:getErrorStr(__msg.head.state))						
-- 	end
-- end)


--获得国家宝藏单例
function Player:getCountryTreasureData(  )
	-- body
	if not Player.pCountryTreasureData then
		self:initCountryTreasureData()
	end
	return Player.pCountryTreasureData
end

-- 初始化国家宝藏数据
function Player:initCountryTreasureData(  )
	if not Player.pCountryTreasureData then
		Player.pCountryTreasureData = DataCountryTreasure.new() --国家宝藏信息
	end
	return "Player.pCountryTreasureData"
end

--释放国家宝藏数据
function Player:releaseCountryTreasureData(  )
	if Player.pCountryTreasureData then
		Player.pCountryTreasureData = nil --国家商店信息
	end
	return "Player.pCountryTreasureData"
end



