-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-13 11:47:52 星期四
-- Description: 玩家信息控制类
-----------------------------------------------------

local PlayerInfo = require("app.layer.playerinfo.PlayerInfo")

e_home_bottom = {
	hero = 1, --武将
	copy = 2, --副本
	country = 3, --国家
	mail = 4, --邮件
	bag = 5,--背包
	godweapon = 6, --神器
	task = 7,--任务
	friend = 8, --好友
	rank = 9, --排行榜
	setting = 10, --设置		
}

--服务器踢下线推送
SocketManager:registerDataCallBack("serOffline",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.login_from_other) then
		-- 账户在别处登录
		if(getIsTokenOuttime()) then
			showReconnectDlg(e_disnet_type.tok, false)
		else
			showReconnectDlg(e_disnet_type.acc, false)
		end
	else
		showReconnectDlg(e_disnet_type.ser, false)
	end
end)

--请求玩家基础数据回调
SocketManager:registerDataCallBack("loadPlayer",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg,"loadPlayer=",100)
		--刷新玩家数据
		Player:getPlayerInfo():refreshDatasByService(__msg.body)
		--发送消息刷新玩家界面
		sendMsg(gud_refresh_playerinfo)
    end
end)

--推送玩家基础数据回调
SocketManager:registerDataCallBack("pushPlayer",function ( __type, __msg )
	-- dump(__msg, "__msg")
	-- body
	if __msg.head.state == SocketErrorType.success then
		--刷新玩家数据
		Player:getPlayerInfo():refreshDatasByService(__msg.body)
		--发送消息刷新玩家界面
		sendMsg(gud_refresh_playerinfo)
	end
end)

--请求能量恢复数据回调
SocketManager:registerDataCallBack("getEnergy",function ( __type, __msg )
	-- body	
	if __msg.head.state == SocketErrorType.success then
		--刷新玩家能量数据
		Player:getPlayerInfo():refreshEnergy(__msg.body)
	end
end)

--购买能量数据回调
SocketManager:registerDataCallBack("buyEnergy",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			Player:getPlayerInfo().nBuyEnergyNum = __msg.body.ben or Player:getPlayerInfo().nBuyEnergyNum--每天购买体力次数
			if __msg.body.o then
				showGetAllItems(__msg.body.o)
			end
		end
	end
end)

--购买Vip礼包
SocketManager:registerDataCallBack("buyVipGift", function ( __type, __msg, __oldMsg )
	--dump(__msg.body,"__msg.body",100)
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then			
			--记录购买Vip礼包
			local nGiftId = __oldMsg[1]
			Player:getPlayerInfo():addBoughtVipGift(nGiftId)
			sendMsg(gud_vip_gift_bought_update_msg)

			--奖励信息
			if __msg.body.o then

				--奖励动画展示			
				local tHero = nil
				for k, v in pairs(__msg.body.o) do
					if v.k >= 200001 and v.k <= 299999 then
						tHero = copyTab(v)
						break
					end
				end
				if tHero then
					local tDataList = {}
					local tReward = {}
					tReward.d = {}
					tReward.g = {}
					table.insert(tReward.d, copyTab(tHero))
					table.insert(tReward.g, copyTab(tHero))
					table.insert(tDataList, tReward)

					--dump(tDataList, "tDataList", 100)
					--打开招募展示英雄对话框
				    local tObject = {}
				    tObject.nType = e_dlg_index.showheromansion --dlg类型
				    tObject.tReward = tDataList
				    tObject.nHandler = handler(self, function ( ... )
				    	-- body
				    	showGetAllItems(__msg.body.o)
				    end)
				    sendMsg(ghd_show_dlg_by_type,tObject)	
				else
					showGetAllItems(__msg.body.o)
			    end	

				--showGetAllItems(__msg.body.o)
			end
		end
	end	
end)
--充值结果推送
SocketManager:registerDataCallBack("pushRecharge", function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			-- 展示获得的内容
			showGetAllItems(__msg.body.o)
		end
	end	
end)


--巡逻兵提示开启任务推送回调
SocketManager:registerDataCallBack("pushOpenXLBTips",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		
		if 	__msg.body then
			
			Player:getPlayerInfo().nOpenXLBTips = 	__msg.body.open
			sendMsg(ghd_refresh_homebase_xlb_tips)
		end
    end
end)


--获取是否开启巡逻兵提示信息
SocketManager:registerDataCallBack("getOpenXLBTips", function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			
			Player:getPlayerInfo().nOpenXLBTips = 	__msg.body.open
		end
	end	
end)

--[2009]改变人物形象
SocketManager:registerDataCallBack("reqChangeCharacters", function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			Player:getPlayerInfo():getActorVo():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_playerinfo)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end)

--[-6005]名将推荐请求
SocketManager:registerDataCallBack("reqHeroRecommond", function (__type,__msg)
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			Player:getPlayerInfo():setHeroRecommondCd(__msg.body.st)
			sendMsg(gud_hero_recommond_cd)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end)

--[-6004]名将推荐推送
SocketManager:registerDataCallBack("pushHeroRecommond", function (__type,__msg)
	if __msg.head.state == SocketErrorType.success then
		-- dump(__msg.body,"pushHeroRecommond")
		if  __msg.body then
			Player:getPlayerInfo():setHeroRecommondCd(__msg.body.st)
			sendMsg(gud_hero_recommond_cd)
		end
	end
end)

SocketManager:registerDataCallBack("checkTimeBox", function (__type,__msg)
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			Player:getPlayerInfo():refreshIconDatasByService(__msg.body)
			sendMsg(gud_refresh_playerinfo)
		end
	end
end)

--[2013]查看玩家战力评分
SocketManager:registerDataCallBack("reqCheckPowerOut", function (__type,__msg)
	if __msg.head.state == SocketErrorType.success then
		if  __msg.body then
			Player:getPlayerInfo():refreshPlayerPower(__msg.body)
		end
	end
end)


--获得玩家基础信息单例
function Player:getPlayerInfo()
	-- body
	if not Player.baseInfos then
		self:initPlayerInfo()
	end
	return Player.baseInfos
end

-- 初始化玩家基础数据
function Player:initPlayerInfo(  )
	if not Player.baseInfos then
		Player.baseInfos = PlayerInfo.new() --玩家的基础信息表
	end
	return "Player.baseInfos"
end

--释放玩家基础数据
function Player:releasePlayerInfo(  )
	if Player.baseInfos then
		Player.baseInfos = nil --玩家的基础信息
	end
	return "Player.baseInfos"
end




