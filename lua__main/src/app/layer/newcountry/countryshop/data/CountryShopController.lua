-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-30 10:04:17 
-- Description: 国家商店管理
-----------------------------------------------------
local DataCountryShop = require("app.layer.newcountry.countryshop.data.DataCountryShop")

-- --[-5034]登录加载数据
SocketManager:registerDataCallBack("loadCountryShop",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadCountryShop.id then
			Player:getCountryShopData():refreshDatasByService(__msg.body)
		end
	end
end)
-- --[-5035]国家商店数据推送
SocketManager:registerDataCallBack("pushCountryShop",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.pushCountryShop.id then
			Player:getCountryShopData():refreshDatasByService(__msg.body)
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


--获得国家商店单例
function Player:getCountryShopData(  )
	-- body
	if not Player.pCountryShopData then
		self:initCountryShopData()
	end
	return Player.pCountryShopData
end

-- 初始化国家商店数据
function Player:initCountryShopData(  )
	if not Player.pCountryShopData then
		Player.pCountryShopData = DataCountryShop.new() --国家商店信息
	end
	return "Player.pCountryShopData"
end

--释放国家商店数据
function Player:releaseCountryShopData(  )
	if Player.pCountryShopData then
		Player.pCountryShopData = nil --国家商店信息
	end
	return "Player.pCountryShopData"
end



