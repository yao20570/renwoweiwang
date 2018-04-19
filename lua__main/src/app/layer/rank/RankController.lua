-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-16 11:47:52 星期二
-- Description: 排行榜信息控制类
-----------------------------------------------------
local RankInfo = require("app.layer.rank.RankInfo")
--请求排行榜数据数据回调
SocketManager:registerDataCallBack("getRankData",function ( __type, __msg, __oldMsg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		-- dump( __msg.body,"排行数据=",100)	
		if 	__msg.body then
			--刷新玩家任务数据
            if __msg.body.tp == e_rank_type.exam then
                Player:getExamRankInfo():refreshDatasByService(__msg.body)
            else
			    Player:getRankInfo():refreshDatasByService(__msg.body)
            end
			--发送玩家排行榜数据消息
			sendMsg(gud_refresh_rankinfo)

		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--请求排行榜数据更新通知
SocketManager:registerDataCallBack("refreshRankInfoNotice",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"排行刷新=",100)	
		if 	__msg.body then
			--刷新玩家任务数据
			Player:getRankInfo():refreshDatasByService(__msg.body)
			--发送玩家排行榜数据消息
			sendMsg(gud_refresh_rankinfo)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end)

--查看玩家信息
SocketManager:registerDataCallBack("getRankPlayerInfo",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"查询玩家其他玩家的数据=",100)	
		if 	__msg.body then

		end
    end
end)

--[8454]查看玩家个人排行榜信息
SocketManager:registerDataCallBack("getMyRankInfo",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if 	__msg.body then
			Player:getRankInfo():setMyRankInfo(__msg.body)
			sendMsg(gud_fc_promote_my_rank_info)
		end
    end
end)


--排行类型
e_rank_type = {		
		world			= 		4,	--世界排行
		country  		= 		5,	--国家排行
		cityfight 		= 		6, 	--城战排行
		countryfight 	= 		7, 	--城战排行
		countrybuild 	= 		8,  --国家建设排行	

		ac_foodstore 	= 		9,	--屯粮排行	
		ac_cityfight 	= 		10, --攻城排行
		ac_forge 		=      	11,	--活动锻造排行
		ac_army 		= 		12, --兵力排行
		ac_succinct 	= 		13,	--洗练排行
		ironstore 		= 		14, --屯铁排行
		ac_country_fight = 		15, --活动国战排行	
		ac_lucky_star 	= 		16, --福星高照排行	
        
		exam            =        22, --每日抢答排行
		wuwang_kill     =        23, --武王击杀排行
		ac_nian         =        24, --年兽排行

		--七日登基子活动
		sr_tnoly 		= 		102413,  --七日登基科技排行
		sr_cf 			= 		102416,  --攻城
		sr_equip 		= 		102417,  --装备
		sr_fuben 		= 		102419,  --副本
		sr_palace 		= 		102420,  --王宫
		sr_combat		= 		102421,  --战力

		nobility 		= 		25, 	--国家爵位
		ac_nation_combat = 		26, 	--国家战力

		imperialwar     =       27,     --决战阿房宫
		zhouwangtrial   = 		28, 	--纣王试炼积分排行
		arena 		    = 		29, 	--竞技场排行
		country_science = 		30, 	--捐献国家科技
}

--获得玩家基础信息单例
function Player:getRankInfo()
	-- body
	if not Player.pRankInfo then
		self:initRankInfo()
	end
	return Player.pRankInfo
end

-- 初始化玩家基础数据
function Player:initRankInfo(  )
	if not Player.pRankInfo then
		Player.pRankInfo = RankInfo.new() --玩家的基础信息表
	end
	return "Player.pRankInfo"
end

--释放玩家基础数据
function Player:releaseRankInfo(  )
	if Player.pRankInfo then
		Player.pRankInfo = nil --玩家的基础信息
	end
	return "Player.pRankInfo"
end