-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-14 16:54:17 星期三
-- Description: 过关斩将管理
-----------------------------------------------------
local PassKillHeroData = require("app.layer.passkillhero.data.PassKillHeroData")

--[-6300]登录加载数据
SocketManager:registerDataCallBack("loadPassKillHeroData",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadPassKillHeroData.id then
			local bLoginLoad = true
			Player:getPassKillHeroData():refreshDatasByService(__msg.body, bLoginLoad)
		end
	end
end)

--[-6301]过关斩将闯关
SocketManager:registerDataCallBack("reqPassKillHeroFight",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		if __msg.head.type == MsgType.reqPassKillHeroFight.id then
			Player:getPassKillHeroData():refreshDatasByService(__msg.body)
			if __msg.body and __msg.body.ob then
				--获取物品效果
				-- showGetAllItems(__msg.body.ob)
			end
			if __msg.body and __msg.body.report then
				local tObject = {}
				tObject.report  = __msg.body.report
				sendMsg(ghd_pass_report_update,tObject)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))						
	end
end)

--[-6302]重置副本
SocketManager:registerDataCallBack("reqResetFight",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqResetFight.id then
			Player:getPassKillHeroData():refreshDatasByService(__msg.body)
			-- local tObject = {}
			-- tObject.isReSet  =  true
			-- sendMsg(ghd_req_Reset_Fight,tObject)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--[-6303]购买过关斩将物品
SocketManager:registerDataCallBack("reqBuyPassGoods",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqBuyPassGoods.id then
			if __msg.body and __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
			end
			Player:getPassKillHeroData():refreshDatasByService(__msg.body)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[-6304]重置过关斩将商店
SocketManager:registerDataCallBack("reqResetPassShop",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		if __msg.head.type == MsgType.reqResetPassShop.id then
			if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
			end
			Player:getPassKillHeroData():refreshDatasByService(__msg.body)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))	
	end
end)

--[-6305]过关斩将数据刷新推送
SocketManager:registerDataCallBack("pushPassKillHeroData",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.pushPassKillHeroData.id then
			Player:getPassKillHeroData():refreshDatasByService(__msg.body)
		end
	end
end)

--[-6306]战报阅读记录
SocketManager:registerDataCallBack("reqReadPassKillHeroReport",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqReadPassKillHeroReport.id then
			--不需要刷新, 本地已记录
			-- Player:getPassKillHeroData():refreshDatasByService(__msg.body)
		end
	end
end)

--[-6307]过关斩将上阵
SocketManager:registerDataCallBack("reqPassKillHeroOnline",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqPassKillHeroOnline.id then
			Player:getPassKillHeroData():refreshHeroInfo(__msg.body)
		end
	end
end)


--获得玩家竞技场单例
function Player:getPassKillHeroData(  )
	-- body
	if not Player.pPassKillHeroData then
		self:initPassKillHeroData()
	end
	return Player.pPassKillHeroData
end

-- 初始化玩家竞技场数据
function Player:initPassKillHeroData(  )
	if not Player.pPassKillHeroData then
		Player.pPassKillHeroData = PassKillHeroData.new() --玩家的基础信息表
	end
	return "Player.pPassKillHeroData"
end

--释放玩家竞技场数据
function Player:releasePassKillHeroData(  )
	if Player.pPassKillHeroData then
		Player.pPassKillHeroData = nil --玩家的基础信息
	end
	return "Player.pPassKillHeroData"
end



