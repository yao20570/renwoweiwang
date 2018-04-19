-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-01-19 9:42:17 星期五
-- Description: 竞技场管理
-----------------------------------------------------
local SPlayerData = require("app.layer.rank.SPlayerData")
local DataArena = require("app.layer.arena.data.DataArena")

--[6100]加载自己的竞技场视图
SocketManager:registerDataCallBack("loadArenaView",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)
	end
end)

--[6101]竞技场挑战
SocketManager:registerDataCallBack("reqArenaChallenge",function ( __type, __msg )
	-- body	
	if __msg.head.state == SocketErrorType.success then	
		-- dump(__msg.body, "__msg.body", 100)
		Player:getArenaData():refreshPrevRank()	
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)

		local pMyInfo = __msg.body.minfo
		local pObInfo = __msg.body.oinfo
		local tItems = __msg.body.ob
		if 	__msg.body and __msg.body.report then
			showFight(__msg.body.report, function (  )
				local tData = {}
				tData.report = __msg.body.report
				tData.arenafightBack = true
				tData.star = __msg.body.star or 0
				-- dump(pMyInfo, "pMyInfo")
				-- dump(pObInfo, "pObInfo")
				tData.nCloseHandler = function ( ... )
					-- dump(tItems, "tItems", 100)								
					-- body									
					local ArenaRankUpView = require("app.layer.arena.ArenaRankUpView")
					local nChange = 0
					if pObInfo and pMyInfo then
						nChange = pObInfo.ar - pMyInfo.ar
					end
					ArenaRankUpView.show(pMyInfo, pObInfo, nChange, function ( ... )
						-- body
						showGetAllItems(tItems)	
					end)													
				end				
				showFightRst(tData)
    		end, true)	
		else
			showGetAllItems(tItems)							
		end		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
	sendMsg(ghd_arena_viewdata_refresh_msg)
end) 


--[6102]竞技场获取积分奖励
SocketManager:registerDataCallBack("reqArenaScoreAward",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)
		if __msg.body.ob then
			--获取物品效果
			showGetAllItems(__msg.body.ob)
		end	
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))							
	end
end)


--[6103]扫荡
SocketManager:registerDataCallBack("reqArenaSweep",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)	
		if __msg.body.ob then
			--获取物品效果
			showGetAllItems(__msg.body.ob)
		end	
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)


--[6104]购买竞技场物品
SocketManager:registerDataCallBack("buyArenaItem",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)	
		if __msg.body.ob then
			--获取物品效果
			showGetAllItems(__msg.body.ob)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))						
	end
end)

--[6105]加载竞技场信息(没开放建筑或者没设置个人阵容不传个人数据)
SocketManager:registerDataCallBack("loadArenaData",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)
	end
end)

--[6106]设置竞技场阵容
SocketManager:registerDataCallBack("adjustArenaLineUp",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[-6107]竞技场数据更新
SocketManager:registerDataCallBack("pushArenaData",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)	
		if __msg.body.ob then
			--获取物品效果
			showGetAllItems(__msg.body.ob)
		end			
	end
end)

--[6108]查看战斗记录
SocketManager:registerDataCallBack("checkArenaRecord",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getArenaData():setBattleRecords(__msg.body)
		sendMsg(ghd_refresh_god_fight_data_msg)
	end
end)

--[6109]查看竞技场排行榜
SocketManager:registerDataCallBack("checkArenaRank",function ( __type, __msg, __oldmsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.r then
			Player:getArenaData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_arena_msg)
		end				
		if __oldmsg[1] == 1 then--请求第一页数据的时候清空旧数据
			Player:getArenaData():cleanArenaRank()
		end
		Player:getArenaData():refreshArenaRank(__msg.body.ranks)
		sendMsg(ghd_refresh_arena_rank_msg)
	end
end)

--[6110]查看幸运排行榜
SocketManager:registerDataCallBack("checkArenaLuckyRank",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.r then
			Player:getArenaData():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_arena_msg)
		end		
		if __msg.body and __msg.body.luckys then
			Player:getArenaData():refreshArenaLuckyList(__msg.body.luckys)
			sendMsg(ghd_refresh_arena_lucky_msg)
		end
	end
end)

--[6111]竞技场购买挑战次数
SocketManager:registerDataCallBack("buyChallengeTimes",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getArenaData():refreshDatasByService(__msg.body)
		sendMsg(gud_refresh_arena_msg)
	end
end)

--[6112]竞技场玩家信息查询
SocketManager:registerDataCallBack("checkArenaPlayer",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		local temp = SPlayerData.new()
		temp:refreshDatasByService(__msg.body)
		--刷新聊天头像数据				
		Player:recordPlayerCardInfo(temp)	
		showArenaPlayerInfo(temp)	
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--我的战斗记录推送
--MsgType.pushMyArenaReport = {id = -6113, keys = {}}
SocketManager:registerDataCallBack("pushMyArenaReport",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():pushMyArenaReport(__msg.body)
	-- else
	-- 	TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[6114]商店刷新
--MsgType.reqRefreshArenaShop = {id = -6114, keys = {}}
SocketManager:registerDataCallBack("reqRefreshArenaShop",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)

--[6115]竞技场更新阵容显示战力
SocketManager:registerDataCallBack("reqCurShowCurCombat",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)

--[6116]竞技场清除挑战cd时间
SocketManager:registerDataCallBack("clearChallengeCd",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)

--[6117]刷新玩家挑战队列
SocketManager:registerDataCallBack("reqNewChallengeList",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)
--[6118]领取排行奖励
SocketManager:registerDataCallBack("reqGetArenaRankPrize",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)
--[6119]领取幸运奖励
SocketManager:registerDataCallBack("reqGetArenaLuckyPrize",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)

--[6120]竞技场使用挑战令
SocketManager:registerDataCallBack("useArenaToken",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		Player:getArenaData():refreshDatasByService(__msg.body)
		--发生消息刷新竞技场相关
		sendMsg(gud_refresh_arena_msg)		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end)


ARENA_RANK_PAGE_LENGTH = 20

--获得玩家竞技场单例
function Player:getArenaData(  )
	-- body
	if not Player.pArenaData then
		self:initTnolyData()
	end
	return Player.pArenaData
end

-- 初始化玩家竞技场数据
function Player:initArenaData(  )
	if not Player.pArenaData then
		Player.pArenaData = DataArena.new() --玩家的基础信息表
	end
	return "Player.pArenaData"
end

--释放玩家竞技场数据
function Player:releaseArenaData(  )
	if Player.pArenaData then
		Player.pArenaData = nil --玩家的基础信息
	end
	return "Player.pArenaData"
end



