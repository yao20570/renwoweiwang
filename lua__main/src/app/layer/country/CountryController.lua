
--职位id
e_official_ids = {
	king 			= 		1, 			--国王
	chancellor 		= 		2, 			--丞相
	counsellor 		= 		3, 			--军师
	general			=		4,			--将军	
}
local CountryData = require("app.layer.country.data.CountryData")
--获取国家数据
function Player:getCountryData( )
 	-- body
 	if not Player.pCountryData then
 		Player:initCountryData()
 	end
 	return Player.pCountryData
end 
--初始化
function Player:initCountryData( )
	if not Player.pCountryData then
		Player.pCountryData = CountryData.new()
	end
	return "Player.pCountryData"
end
--释放装备数据
function Player:releasCountryData()
	if Player.pCountryData then
		Player.pCountryData:release()
		Player.pCountryData = nil
	end
	return "Player.pCountryData"
end

--选择国家
SocketManager:registerDataCallBack("choiceCountry",function ( __type, __msg, __oldMsg)
	--dump(__msg,"choiceCountry=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.choiceCountry.id then
			Player:getPlayerInfo().nCountrySelected = 1
			Player:getPlayerInfo():refreshPlayerInfluence(__msg.body)					
			--玩家基础信息数据刷新	
			sendMsg(gud_refresh_playerinfo) 
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--国家开发
SocketManager:registerDataCallBack("stateDevelopmen",function ( __type, __msg, __oldMsg)
	--dump(__msg,"stateDevelopmen=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.stateDevelopmen.id then
			--刷新国家经验
			Player:getCountryData():getCountryDataVo():refreshCountryExp(__msg.body)
			sendMsg(gud_refresh_country_msg)			
			if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--加载官员/官员候选人列表
SocketManager:registerDataCallBack("loadOfficialInfo",function ( __type, __msg, __oldMsg)
	--dump(__msg,"loadOfficialInfo=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.loadOfficialInfo.id then
			Player:getCountryData():refreshOfficialAndCandidate(__msg.body)	
			sendMsg(gud_refresh_country_official_msg)		
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--投票给官员候选人
SocketManager:registerDataCallBack("officialVote",function ( __type, __msg, __oldMsg)
	--dump(__msg,"officialVote=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.officialVote.id then
			--刷新已经投票次数
			Player:getCountryData():refreshSupportInfo(__msg.body.a)
			Player:getCountryData():getCountryDataVo():refreshVotedTimes(__msg.body)
			sendMsg(gud_refresh_country_official_msg)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--膜拜国王
SocketManager:registerDataCallBack("worshipKing",function ( __type, __msg, __oldMsg)
	--dump(__msg,"worshipKing=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.worshipKing.id then
			Player:getCountryData():getCountryDataVo():updateMyWorship(1)
			Player:getCountryData():getCountryDataVo():refreshCountryWorship(__msg.body)			
			sendMsg(gud_refresh_country_msg)
			if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--发布公告
SocketManager:registerDataCallBack("announceDecree",function ( __type, __msg, __oldMsg)
	--dump(__msg,"announceDecree=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.announceDecree.id then
			Player:getCountryData():getCountryDataVo():refreshCountryAffiche(__msg.body)
			Player:getCountryData():getCountryDataVo():refreshAfficheCnt(__msg.body.ss)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--获取膜拜次数
SocketManager:registerDataCallBack("getWorshipTimes",function ( __type, __msg, __oldMsg)
	--dump(__msg,"getWorshipTimes=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.getWorshipTimes.id then
			Player:getCountryData():getCountryDataVo():refreshCountryWorship(__msg.body)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--国家公告变更推送
SocketManager:registerDataCallBack("pushDecree",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushDecree=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushDecree.id then			
			Player:getCountryData():getCountryDataVo():refreshCountryAffiche(__msg.body)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--加载国家数据
SocketManager:registerDataCallBack("loadCountryInfo",function ( __type, __msg, __oldMsg)
	--dump(__msg,"loadCountryInfo=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.loadCountryInfo.id then
			--刷新国家基础数据
			Player:getCountryData():refreshCountryDataByService(__msg.body)
			--积分宝箱领取情况刷新
			Player:getCountryData():refreshScoreBoxsByService(__msg.body.csg)
			--当天已召唤次数
			Player:getCountryData():setCalledNumToday(__msg.body.cts)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--获取城战积分箱子
SocketManager:registerDataCallBack("getCityFightBox",function ( __type, __msg, __oldMsg)
	--dump(__msg,"getCityFightBox=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.getCityFightBox.id then
			Player:getCountryData():refreshScoreBoxsByService(__msg.body.get)	
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--加载国家荣誉任务完成情况
SocketManager:registerDataCallBack("loadCountryGlory",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"loadCountryGlory=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.loadCountryGlory.id then
			Player:getCountryData():refreshHonorTasksByService(__msg.body)	
			sendMsg(gud_refresh_country_honor_msg)				
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--获取荣誉任务奖励
SocketManager:registerDataCallBack("getHonorTaskPrize",function ( __type, __msg, __oldMsg)
	--dump(__msg,"getHonorTaskPrize=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.getHonorTaskPrize.id then			
			if __msg.body.g then
				local tData = {}
				tData.rs = __msg.body.g
				Player:getCountryData():refreshHonorTasksByService(tData)
				sendMsg(gud_refresh_country_honor_msg)	
			end
			--弹出奖励特效
			if __msg.body.ob then
				showGetAllItems(__msg.body.ob)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--罢免将军
SocketManager:registerDataCallBack("recallGeneral",function ( __type, __msg, __oldMsg)
	--dump(__msg,"recallGeneral=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.recallGeneral.id then			
			Player:getCountryData():refreshGeneralCandidate(__msg.body.g)
			sendMsg(gud_refresh_generalrenmian_msg)			
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--任命将军
SocketManager:registerDataCallBack("appoinrGeneral",function ( __type, __msg, __oldMsg)	
	--dump(__msg,"appoinrGeneral=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.appoinrGeneral.id then			
			Player:getCountryData():refreshGeneralCandidate(__msg.body.g)
			sendMsg(gud_refresh_generalrenmian_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--加载国家日志
SocketManager:registerDataCallBack("loadCountryLog",function ( __type, __msg, __oldMsg)
	--dump(__msg,"loadCountryLog=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.loadCountryLog.id then			
			Player:getCountryData():loadCountryLog(__msg.body)
			sendMsg(gud_refresh_country_log_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--城战积分变化
SocketManager:registerDataCallBack("cityFightScoreChange",function ( __type, __msg, __oldMsg)
	--dump(__msg,"cityFightScoreChange=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.cityFightScoreChange.id then			
			Player:getCountryData():getCountryDataVo():refreshCountryScore(__msg.body)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--升级爵位
SocketManager:registerDataCallBack("upNobility",function ( __type, __msg, __oldMsg)
	--dump(__msg,"upNobility=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.upNobility.id then	
			--爵位更新		
			Player:getCountryData():getCountryDataVo():refreshNobility(__msg.body)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--推送官员候选人数据更新
SocketManager:registerDataCallBack("pushCandidate",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushCandidate=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushCandidate.id then	
			Player:getCountryData():updateCandidateByService(__msg.body)
			sendMsg(gud_refresh_country_official_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--加载我的国家城池
SocketManager:registerDataCallBack("loadCountryCity",function ( __type, __msg, __oldMsg)
	--dump(__msg,"loadCountryCity=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.loadCountryCity.id then	
			Player:getCountryData():refreshCountryCityByService(__msg.body)
			sendMsg(gud_refresh_countrycity_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--国家日志推送
SocketManager:registerDataCallBack("pushCountryLog",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushCountryLog=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushCountryLog.id then	
			Player:getCountryData():updateNewCountryLog(__msg.body)
			sendMsg(gud_refresh_country_log_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--加载将军候选人列表
SocketManager:registerDataCallBack("getGeneralCandidate",function ( __type, __msg, __oldMsg)
	--dump(__msg,"getGeneralCandidate=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.getGeneralCandidate.id then
			Player:getCountryData():refreshGeneralCandidate(__msg.body.g)
			sendMsg(gud_refresh_generalrenmian_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--官员任命罢免推送
SocketManager:registerDataCallBack("pushOfficial",function ( __type, __msg, __oldMsg)
	--dump(__msg.body,"pushOfficial=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushOfficial.id then	
			Player:getCountryData():updateOfficialByService(__msg.body)
			sendMsg(gud_refresh_generalrenmian_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--竞选开始推送
SocketManager:registerDataCallBack("pushStartVote",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushStartVote=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushStartVote.id then	
			Player:getCountryData():refreshOfficialAndCandidate(__msg.body.l)						
			Player:getCountryData():getCountryDataVo():refreshVotedTimes(__msg.body)
			sendMsg(gud_refresh_country_official_msg)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--竞选结束推送
SocketManager:registerDataCallBack("pushEndVote",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushEndVote=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushEndVote.id then	
			Player:getCountryData():refreshOfficialAndCandidate(__msg.body.l)		
			Player:getCountryData():getCountryDataVo():refreshDataByService(__msg.body)
			sendMsg(gud_refresh_country_official_msg)
			sendMsg(gud_refresh_country_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--国家数据推送给
SocketManager:registerDataCallBack("pushCountryInfo",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushCountryInfo=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushCountryInfo.id then	
			--刷新国家基础数据
			Player:getCountryData():refreshCountryDataByService(__msg.body)
			--积分宝箱领取情况刷新
			Player:getCountryData():refreshScoreBoxsByService(__msg.body.csg)
			--当天已召唤次数
			Player:getCountryData():setCalledNumToday(__msg.body.cts)
			sendMsg(gud_refresh_country_msg)
			sendMsg(gud_refresh_country_official_msg)		
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--国家城池数据推送
SocketManager:registerDataCallBack("pushCountryCity",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushCountryCity=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushCountryCity.id then	
			Player:getCountryData():refreshCountryCityByService(__msg.body)
			sendMsg(gud_refresh_countrycity_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

---5029国家荣誉任务奖励推送
SocketManager:registerDataCallBack("pushHonorPrize",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushHonorPrize=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushHonorPrize.id then	
			if __msg.body.r == 1 then
				sendMsg(ghd_country_honor_prize_change_msg)
			end			
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-5030]官员/候选人更名推送
--MsgType.pushOfficialRename = {id = -5030, keys = {}}
SocketManager:registerDataCallBack("pushOfficialRename",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushOfficialRename=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushOfficialRename.id then			
			Player:getCountryData():pushrefreshName(__msg.body)	
			sendMsg(gud_refresh_country_official_msg)
			sendMsg(gud_refresh_generalrenmian_msg)	
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--[-5031]官员竞选状态推送
SocketManager:registerDataCallBack("pushOfficialStatus",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushOfficialStatus=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushOfficialStatus.id then			
			Player:getCountryData():refreshOfficialStatus(__msg.body)	
			sendMsg(gud_refresh_country_official_msg)	
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--MsgType.pushPoliticiansPoster = {id= -5032, keys = {}}
SocketManager:registerDataCallBack("pushPoliticiansPoster",function ( __type, __msg, __oldMsg)
	--dump(__msg,"pushPoliticiansPoster=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushPoliticiansPoster.id then			
			Player:getCountryData():refreshPoster(__msg.body)
			sendMsg(gud_refresh_country_official_msg)	
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)