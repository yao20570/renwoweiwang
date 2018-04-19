-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-03-22 14:37:17 
-- Description: 阿房宫宝藏管理
-----------------------------------------------------
local NationalTreasureData = require("app.layer.nationaltreasure.data.NationalTreasureData")

-- --[-6413]登录加载数据
SocketManager:registerDataCallBack("asknationaltreasure",function ( __type, __msg )
	-- body
	--dump(__msg,"asknationaltreasure",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.asknationaltreasure.id then
			Player:getNationalTreasureData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_nationaltreasure)
		end
	end
end)

--[-6414] --6415
SocketManager:registerDataCallBack("nationaltreasure",function ( __type, __msg )
	-- body
	--dump(__msg,"nationaltreasure")
	if __msg.head.state == SocketErrorType.success then		
		if __msg.head.type == MsgType.nationaltreasure.id then
			Player:getNationalTreasureData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_nationaltreasure)
			if __msg.body and __msg.body.o then
				--获取物品效果
				showGetAllItems(__msg.body.o)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))						
	end
end)


SocketManager:registerDataCallBack("treasurecongratu",function ( __type, __msg )
	-- body
	--dump(__msg,"treasurecongratu")
	if __msg.head.state == SocketErrorType.success then	
		if __msg.head.type == MsgType.treasurecongratu.id then
			Player:getNationalTreasureData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_nationaltreasure)
			if __msg.body and __msg.body.o then
				--获取物品效果
				showGetAllItems(__msg.body.o)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))						
	end
end)


--获得玩家国家宝藏数据
function Player:getNationalTreasureData(  )
	-- body
	if not Player.pNatioanlTreasureData then
		self:initNationalTreasureData()
	end
	return Player.pNatioanlTreasureData
end

-- 初始化玩家国家宝藏数据
function Player:initNationalTreasureData(  )
	if not Player.pNatioanlTreasureData then
		Player.pNatioanlTreasureData = NationalTreasureData.new() --玩家的基础信息表
	end
	return "Player.pNatioanlTreasureData"
end

--释放玩家国家宝藏数据
function Player:releaseNationalTreasureData(  )
	if Player.pNatioanlTreasureData then
		Player.pNatioanlTreasureData = nil --玩家的基础信息
	end
	return "Player.pNatioanlTreasureData"
end



