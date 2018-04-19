----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-06 14:25:33
-- Description: 地图控制类
-----------------------------------------------------
require("app.layer.world.WorldFunc")
local WorldData = require("app.layer.world.data.WorldData")

e_syscity_ids = {
	EpangPalace = 11169
}

--获取世界数据单例
function Player:getWorldData(  )
	if not Player.worldData then
		self:initWorldData()
	end
	return Player.worldData
end

--初始化世界数据
function Player:initWorldData(  )
	if not Player.WorldData then
		Player.worldData = WorldData.new()
	end
	return "Player.worldData"
end

--释放世界数据
function Player:releaseWorldData()
	if Player.WorldData then
		Player.WorldData:release()
		Player.WorldData = nil
	end
	return "Player.worldData"
end

--加载城市数据3000
SocketManager:registerDataCallBack("reqWorldCityData",function ( __type, __msg )
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCityData.id then
			if __msg.body then
				Player:getWorldData():onLoadCityRes(__msg.body)

				if __msg.body.otob then
					Player:getWorldData():setOffLineReward(__msg.body.otob)
				end
			end
		end
	end
end)

--创建世界任务3002
SocketManager:registerDataCallBack("reqWorldTask",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldTask.id then
        	TOAST(getTipsByIndex(20006))
        end
    else
    	if __msg.head.state == 325 and __oldMsg and __oldMsg[1] == e_type_task.zhouwang then--攻打纣王等级不足
    		TOAST(getTipsByIndex(20153))
    	else
    		TOAST(SocketManager:getErrorStr(__msg.head.state))
    	end        
        --相关界面重新请求数据
        sendMsg(gud_city_garrisonInfo_req)
    end
end)

--输入任务指令3003
SocketManager:registerDataCallBack("reqWorldTaskInput",function ( __type, __msg, __oldMsg)
	-- myprint("__msg.head.state=",__msg.head.state)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldTaskInput.id then
        	if __oldMsg and __oldMsg[2] == e_type_task_input.quick then
        		TOAST(getTipsByIndex(10070))
        	end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--侦查3004
SocketManager:registerDataCallBack("reqWorldDetect",function ( __type, __msg )
	-- myprint("__msg.head.state=",__msg.head.state)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldDetect.id then
        	local sMailId = __msg.body.m
        	if sMailId then
        		local tMailMsg = Player:getMailData():getMailMsg(sMailId)
        		if tMailMsg then
        			--直接弹出界面
        			local tObject = {
					    nType = e_dlg_index.maildetail, --dlg类型
					    tMailMsg = tMailMsg,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					Player:getMailData():setDetectMailId(nil)
        		else
        			Player:getMailData():setDetectMailId(sMailId)
        		end
        	end
        	
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--驻防召回
SocketManager:registerDataCallBack("reqWorldGarrisonBack",function ( __type, __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldGarrisonBack.id then
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--玩家迁城返回3001
SocketManager:registerDataCallBack("reqWorldMigrate",function ( __type, __msg ,__oldMsg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldMigrate.id then
			if __msg.body then
				local nBlockId = WorldFunc.getBlockId(__msg.body.x, __msg.body.y)
				local tBlockData=getWorldMapDataById(nBlockId)
				if tBlockData then
					TOAST(string.format(getTipsByIndex(20090),tBlockData.name))
				end
				-- TOAST(getTipsByIndex(600))
				Player:getWorldData():onMigrateRes(__msg.body)
				sendMsg(gud_world_my_city_pos_change_msg)
			end
		end
	else
        -- TOAST(getTipsByIndex(20088))
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--搜索周围视图点3008
SocketManager:registerDataCallBack("reqWorldAroundDot",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body, "reqWorldAroundDot", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldAroundDot.id then
			if __msg.body then

				if __oldMsg then
					local nDotX = __oldMsg[1]
					local nDotY = __oldMsg[2]
					local fLastGetDataTime = __oldMsg[3]
					local fLastLoadTime = Player:getWorldData().fLastLoadTime
					if fLastLoadTime and fLastGetDataTime and fLastGetDataTime < fLastLoadTime then
						print("数据已经失效了，不需要执行任何操作...")
						return
					end
					--
					Player:getWorldData():setPrevSearchDot(nDotX, nDotY)
					Player:getWorldData().fLastLoadTime = getSystemTime(false)
					Player:getWorldData():updateArroundDots(__msg.body.dots, nDotX, nDotY)
				else
					sendMsg(gud_world_search_around_msg)
				end
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--请求区域视图点3009
SocketManager:registerDataCallBack("reqWorldBlock",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldBlock.id then
			if __msg.body then
				--3009不知道为什么服务器会重连的时候推过来导致出错，服务器说没有推，先兼容一下
				if not __oldMsg then
					return
				end

				local nBlockId = __oldMsg[1]
				if not nBlockId then
					return
				end
				
				--设置外部地图请求间隔
				Player:getWorldData():setLoadBlockSecond(getWorldInitData("loadBlockSecond"))
				--设置请求间隔
				-- Player:getWorldData():setBlockReqTime(nBlockId)
				--设置请求的区域视图点信息
				Player:getWorldData():onLoadBlockRes(__msg.body, nBlockId)
				sendMsg(gud_world_block_dots_msg, nBlockId)
			end
		end
	end
end)

--任务状态变更推送3006
SocketManager:registerDataCallBack("pushWorldTask",function ( __type, __msg )
	-- dump(__msg.body,"pushWorldTask",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldTask.id then
			if __msg.body then
				Player:getWorldData():onTaskMsgPush(__msg.body)
				sendMsg(gud_world_task_change_msg)
			end
		end
	end
end)

--视图点消失推送3007
SocketManager:registerDataCallBack("pushWorldDotDispear",function ( __type, __msg )
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldDotDispear.id then
			if __msg.body then
				Player:getWorldData():onDotDispear(__msg.body)
				local sDotKey = string.format("%s_%s", __msg.body.x,__msg.body.y)
				sendMsg(gud_world_dot_disappear_msg, sDotKey)
			end
		end
	end
end)

--行军推送3005
SocketManager:registerDataCallBack("pushWorldTaskMove",function ( __type, __msg )
	-- dump(__msg.body,"pushWorldTaskMove",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldTaskMove.id then
			if __msg.body then
				Player:getWorldData():onTaskMovePush(__msg.body)
				sendMsg(gud_world_task_move_push_msg)
				sendMsg(ghd_sys_city_mingjie_action)
			end
		end
	end
end)

--区域内城战发生变化推送3014
SocketManager:registerDataCallBack("pushWorldBCWar",function ( __type, __msg )
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldBCWar.id then
			if __msg.body then
				Player:getWorldData():onBlockCWOVPush(__msg.body)
				sendMsg(gud_block_city_war_change_push_msg, __msg.body.i )
			end
		end
	end
end)



--区域内城池占领发生变化推送3015
SocketManager:registerDataCallBack("pushWorldBCOccupy",function ( __type, __msg )
	-- dump(__msg.body, "pushWorldBCOccupy", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldBCOccupy.id then
			if __msg.body then
				Player:getWorldData():onBlockSCOIPush(__msg.body)
				sendMsg(gud_block_city_occupy_change_push_msg, __msg.body.i )
			end
		end
	end
end)


--加载我国国战列表3016
SocketManager:registerDataCallBack("reqWorldMyCountryWar",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldMyCountryWar.id then
			if __msg.body then
				Player:getWorldData():onLoadMyCountryWar(__msg.body)
				sendMsg(gud_my_country_war_list_change)
			end
		end
	end
end)

--移除任务移除推送3019
SocketManager:registerDataCallBack("pushWorldDelTask",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldDelTask.id then
			if __msg.body then
				Player:getWorldData():delTaskMsgByUuid(__msg.body.u)
				sendMsg(gud_world_task_change_msg)
			end
		end
	end
end)

--我国国战列表推送3021
SocketManager:registerDataCallBack("pushWorldMyCountryWar",function ( __type, __msg)
	--dump(__msg.body, "pushWorldMyCountryWar", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldMyCountryWar.id then
			if __msg.body then
				Player:getWorldData():onPushMyCountryWar(__msg.body.w)
				sendMsg(gud_my_country_war_list_change)
			end
		end
	end
end)

--视图点变化推送3020
SocketManager:registerDataCallBack("pushWorldDotChange",function ( __type, __msg )
	--dump(__msg.body, "pushWorldDotChange", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldDotChange.id then
			if __msg.body then
				Player:getWorldData():onDotChange(__msg.body.v)
			end
		end
	end
end)

-- --移除我国国战列表推送3022
-- SocketManager:registerDataCallBack("pushWorldDelMyCountryWar",function ( __type, __msg)
-- 	-- dump(__msg.body)
-- 	if  __msg.head.state == SocketErrorType.success then 
-- 		if __msg.head.type == MsgType.pushWorldDelMyCountryWar.id then
-- 			if __msg.body then
-- 				Player:getWorldData():delMyCountryWar(__msg.body.i)
-- 				sendMsg(gud_my_country_war_list_change)
-- 			end
-- 		end
-- 	end
-- end)

--城战提醒推送3023
SocketManager:registerDataCallBack("pushWorldHitMyCityNotice",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldHitMyCityNotice.id then
			if __msg.body then
				Player:getWorldData():onHitMyCityNotice(__msg.body)
				sendMsg(gud_world_my_city_be_attack_msg)
			end
		end
	end
end)

--[3024]加载城主候选人列表
SocketManager:registerDataCallBack("reqWorldCityCandidate",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldCityCandidate.id then
			--第一次打开候选人界面，之后在相对应的界面里监听
			local pDlg, bNew = getDlgByType(e_dlg_index.cityownercandidate)
			if not pDlg then
				local nSysCityId = __oldMsg[1]
				local tObject = {
				    nType = e_dlg_index.cityownercandidate, --dlg类型
				    nSysCityId = nSysCityId,
				    __msg = __msg,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--季节日推送3026
SocketManager:registerDataCallBack("pushWorldSeasonDay",function ( __type, __msg)
	--dump(__msg,"pushWorldSeasonDay", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldSeasonDay.id then
			if __msg.body then
				Player:getWorldData():setSeasonDay(__msg.body.s)
				sendMsg(gud_world_season_day_change)
			end
		end
	end
end)

--3028]参与召唤
SocketManager:registerDataCallBack("reqWorldJoinCall",function ( __type, __msg )
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldJoinCall.id then
			if __msg.body then
				Player:getWorldData():onMigrateRes(__msg.body)
				sendMsg(gud_world_my_city_pos_change_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--3031]我的协防信息推送
SocketManager:registerDataCallBack("pushWorldMyCityGarrison",function ( __type, __msg )
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushWorldMyCityGarrison.id then
			if __msg.body then
				Player:getWorldData():onMyCityGarrison(__msg.body)
				sendMsg(gud_refresh_wall)--通知刷新城墙
			end
		end
	end
end)

--[3034]列出所有区域中心城的占领信息
SocketManager:registerDataCallBack("reqWorldCenterCity",function ( __type, __msg)
	-- dump(__msg.body, "reqWorldCenterCity", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldCenterCity.id then
			if __msg.body then
				Player:getWorldData():setMainCityOccupyVOs(__msg.body.v)
				sendMsg(gud_world_center_city_capture_msg)
			end
		end
	end
end)

--[3035]区域中心城占领信息推送
SocketManager:registerDataCallBack("pushWorldCenterCity",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldCenterCity.id then
			if __msg.body then
				Player:getWorldData():pushMainCityOccupyVO(__msg.body)
				sendMsg(gud_world_center_city_capture_msg)
			end
		end
	end
end)


--[3036]乱军可以打的等级推送
SocketManager:registerDataCallBack("pushWorldWildArmyLv",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldWildArmyLv.id then
			if __msg.body then
				Player:getWorldData():setWildArmyLv(__msg.body.ml)
			end
		end
	end
end)

--[-3037]被迁城推送
SocketManager:registerDataCallBack("pushBeMigrated",function ( __type, __msg)
	-- dump(__msg.body, "pushBeMigrated", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushBeMigrated.id then
			if __msg.body then
				Player:getWorldData():pushBeMigrated(__msg.body)
				sendMsg(gud_world_my_city_pos_change_msg)
			end
		end
	end
end)

SocketManager:registerDataCallBack("pushWorldWildArmyLv",function ( __type, __msg)
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldWildArmyLv.id then
			if __msg.body then
				Player:getWorldData():setWildArmyLv(__msg.body.ml)
			end
		end
	end
end)

--[-3038]首杀领取
SocketManager:registerDataCallBack("reqSysCityFKPaper",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqSysCityFKPaper.id then
			if __msg.body then
				local nCityId = __oldMsg[1]
				local tViewDotMsg = Player:getWorldData():getSysCityDot(nCityId)
				if tViewDotMsg then
					tViewDotMsg:setFirstKill(__msg.body.fk) --是否能领取首杀
				end
				showGetAllItems(__msg.body.ob, 2) --奖励物品
			end
		end
	end
end)

--3018申请城主回调
SocketManager:registerDataCallBack("reqWorldApplyCityOwner",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldApplyCityOwner.id then
			if __msg.body then
				local nX = __oldMsg[1]
				local nY = __oldMsg[2]
				local tCityData = getWorldCityDataByPos(nX, nY)
				if tCityData then
					--进一步处理
					local nCd = __msg.body.cd
					if nCd and nCd > 0 then
						--设置数据已申请
						local tViewDotMsg = Player:getWorldData():getSysCityDot(tCityData.id)
						if tViewDotMsg then
							tViewDotMsg:setIsApplyCityOwner(true)
						end
						
						--申请候选人命令
						SocketManager:sendMsg("reqWorldCityCandidate", {tCityData.id, 0})
					else
						--关闭自己, 显示恭喜界面
						--关闭申请界面
						closeDlgByType( e_dlg_index.cityownerapply, false)
						--单次确认框
						local DlgAlert = require("app.common.dialog.DlgAlert")
						local pDlg, bNew = getDlgByType(e_dlg_index.alert)
					    if(not pDlg) then
					        pDlg = DlgAlert.new(e_dlg_index.alert)
					    end
					    pDlg:setTitle(getConvertedStr(3, 10091))
					    pDlg:setContent(string.format(getConvertedStr(3, 10105), tCityData.name))
					    pDlg:setOnlyConfirm()
					    pDlg:showDlg(bNew)

					    --设置数据未申请
						local tViewDotMsg = Player:getWorldData():getSysCityDot(tCityData.id)
						if tViewDotMsg then
							tViewDotMsg:setIsApplyCityOwner(false)
						end
					end

					sendMsg(ghd_update_city_owner_apply)
				end
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[3040]领取世界目标奖励
SocketManager:registerDataCallBack("regWorldTargetReward",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "regWorldTargetReward", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.regWorldTargetReward.id then
			Player:getWorldData():setMyWorldTargetId(__msg.body.ts) -- Integer	当前世界目标序号
			showGetAllItems(__msg.body.ob, 2) --List<Pair<Integer,Long>>	获得
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3041]完成世界目标后消耗低迁迁城
SocketManager:registerDataCallBack("reqWorldTargetUsedMoveCity",function ( __type, __msg, __oldMsg)
	--dump(__msg, "reqWorldTargetUsedMoveCity", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldTargetUsedMoveCity.id then
			Player:getWorldData():setUsedMoveCity(__msg.body.lm)-- List<Integer>	已消耗低迁前往指定区域的序号
			Player:getWorldData():onMigrateRes(__msg.body)
			sendMsg(gud_world_my_city_pos_change_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[-3042]世界目标数据刷新推送
SocketManager:registerDataCallBack("pushWorldTargetRefresh",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "pushWorldTargetRefresh", 100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushWorldTargetRefresh.id then
			Player:getWorldData():setMyWorldTargetId(__msg.body.ts) --Integer	当前世界的目标
			Player:getWorldData():setWorldTargetId(__msg.body.cs) --Integer	当前世界的目标
			-- Player:getWorldData():setWorldBossExist(__msg.body.bx) -- bx	Integer	世界BOSS是否存在 0：否 1:是
			Player:getWorldData():setWorldBossVo(__msg.body.bv) -- bv	WorldBossVO	世界BOSS
			Player:getWorldData():setWildArmyKill(__msg.body.mk)-- Integer	世界目标我击杀的乱军数量
			Player:getWorldData():setCapitalInfo(__msg.body.dcs) --各势力都城信息 [Pair<势力ID,城池ID>] 如果没有该势力ID,则表示没占领有都城
			Player:getWorldData():setAttackedBoss(__msg.body.kb) --Integer 今天是否打过世界BOSS
		end
	end
end)

--[-3045]不能打的都城推送
SocketManager:registerDataCallBack("pushNoAttackCapitalCity",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushNoAttackCapitalCity.id then
			Player:getWorldData():setNoAttackCapital(__msg.body.bc) -- bc	Integer	不能攻打的都城
		end
	end
end)

--[-3027]发起召唤
SocketManager:registerDataCallBack("reqWorldReqCall",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "reqWorldReqCall", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldReqCall.id then
        	--更新召唤数据
        	local tViewDotMsg = Player:getWorldData():getMyViewDotMsg()
        	if tViewDotMsg then
        		tViewDotMsg:setCallInfo(__msg.body.c) --c	CallInfo	召唤信息
        		local tCallInfo=tViewDotMsg:getCallInfo()
        		-- if tCallInfo then
        			--发送分享消息
		        	local tData={
						an=tViewDotMsg.sName,		--防守方名字
						al=tViewDotMsg.nLevel,		--防守方等级
						dx=tViewDotMsg.nX,
						dy=tViewDotMsg.nY,
						ac=tViewDotMsg.nCountry,
						-- dc=self.tCityWarMsg.nSenderCountry,--Integer	发起者国家
						-- dl=self.tCityWarMsg.nSenderCityLv,
						dt = e_share_type.call,
						rn = __msg.body.c.r,  --召唤已响应人数
						cannum = __msg.body.c.c	--可召唤人数
					}
					autoShareToCountry(e_share_id.call,tData)
        		-- end
	        	

        	end
        	Player:getCountryData():setCalledNumToday(__msg.body.ct) --ct	Integer	已召唤次数
        	--我的召唤信息刷新
        	sendMsg(gud_world_my_callinfo_refresh)

        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[-3046]重发召唤公告
SocketManager:registerDataCallBack("reqWorldReqCallNotice",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "reqWorldReqCallNotice", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldReqCallNotice.id then
        	--更新召唤数据
        	local tViewDotMsg = Player:getWorldData():getMyViewDotMsg()
        	if tViewDotMsg then
        		tViewDotMsg:setCallInfo(__msg.body.ci) --ci	CallInfo	召唤信息
        		-- local tCallInfo=tViewDotMsg:getCallInfo()
        		-- if tCallInfo then
	        		--发送分享消息
		        	local tData={
						an=tViewDotMsg.sName,		--防守方名字
						al=tViewDotMsg.nLevel,		--防守方等级
						dx=tViewDotMsg.nX,
						dy=tViewDotMsg.nY,
						ac=tViewDotMsg.nCountry,
						-- dc=self.tCityWarMsg.nSenderCountry,--Integer	发起者国家
						-- dl=self.tCityWarMsg.nSenderCityLv,
						dt = e_share_type.call,
						rn = __msg.body.ci.r,  --召唤已响应人数
						cannum = __msg.body.ci.c	--可召唤人数
					}
					autoShareToCountry(e_share_id.call,tData)
				-- end

        	end
        	--我的召唤信息刷新
        	sendMsg(gud_world_my_callinfo_refresh)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-3047]pushWorldCityData
--推送城市数据3047
SocketManager:registerDataCallBack("pushWorldCityData",function ( __type, __msg )
	-- dump(__msg.body,"pushWorldCityData",100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushWorldCityData.id then
			if __msg.body then
				Player:getWorldData():onLoadCityRes(__msg.body)
			end
		end
	end
end)

--申求城战列表
SocketManager:registerDataCallBack("reqWorldCityWarInfo",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "reqWorldCityWarInfo", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCityWarInfo.id then
        	--是自己的就保存刷新
        	if __oldMsg[1] == Player:getPlayerInfo().pid then
        		--转成本地数据
				local tCityWarMsgs = {}
				if __msg.body.wars and #__msg.body.wars > 0 then
					local CityWarMsg = require("app.layer.world.data.CityWarMsg")
					for i=1,#__msg.body.wars do
						table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
					end
					--倒计时排列
					table.sort(tCityWarMsgs, function ( a , b )
						return a:getCd() < b:getCd()
					end)
				end

				if __msg.body.gw then
			        -- local GhostWarVO = require("app.layer.world.data.GhostWarVO")
			        -- local tGhostWar = GhostWarVO.new(__msg.body.gw)
			        Player:getWorldData():onGhostAttackNotice(__msg.body.gw)
			    end

				Player:getWorldData():setMyCityWarMsgs(tCityWarMsgs)
				sendMsg(gud_my_city_war_list_change)
        	end
        end
    end
end)

--[-3048]pushMyCityWarMsg
SocketManager:registerDataCallBack("pushMyCityWarMsg",function ( __type, __msg )
	-- dump(__msg.body,"pushMyCityWarMsg",100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushMyCityWarMsg.id then
			if __msg.body then
				local CityWarMsg = require("app.layer.world.data.CityWarMsg")
				Player:getWorldData():addMyCityWarMsg(CityWarMsg.new(__msg.body))
				sendMsg(gud_my_city_war_list_change)
			end
		end
	end
end)

--[-3049]加载正在赶往的友军帮助列表
SocketManager:registerDataCallBack("reqFriendArmys",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "reqFriendArmys", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqFriendArmys.id then
        	Player:getWorldData():setFriendArmys(__msg.body.cs)
			sendMsg(gud_friend_army_list_change)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-3050]pushFriendArmy
SocketManager:registerDataCallBack("pushFriendArmy",function ( __type, __msg )
	--dump(__msg.body,"pushFriendArmy",100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushFriendArmy.id then
			if __msg.body then
				if __msg.body.t == 1 then
					Player:getWorldData():addFriendArmy(__msg.body.v)
				elseif __msg.body.t == 0 then
					Player:getWorldData():subFriendArmy(__msg.body.v)
				end
				sendMsg(gud_friend_army_list_change)
			end
		end
	end
end)


--[-3500]乱军战斗画面推送
SocketManager:registerDataCallBack("pushWildArmyFight",function ( __type, __msg )
	-- dump(__msg.body)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushWildArmyFight.id then
			if __msg.body then
				sendMsg(gud_play_wild_army_fight, {nX = __msg.body.x, nY = __msg.body.y})
			end
		end
	end
end)

--[-3501]世界任务完成奖励推送
SocketManager:registerDataCallBack("worldMissionPush",function ( __type, __msg )
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.worldMissionPush.id then
			if __msg.body then
				if __msg.body.ob then
					showGetAllItems(__msg.body.ob)
				end
			end
		end
	end
end)


-----------------城池首杀
--[-3502]加载城池首杀数据
SocketManager:registerDataCallBack("reqCityFirstBlood",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "reqCityFirstBlood", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqCityFirstBlood.id then
        	Player:getWorldData():setCityFirstBlood(__msg.body.fbs)
        	if __msg.body["end"] == 1 then
        		Player:getWorldData():setCFBloodClose(true)
        	else
        		Player:getWorldData():setCFBloodClose(false)
        	end
			sendMsg(gud_city_first_blood_refresh)
			sendMsg(gud_city_first_blood_red)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-3503]城池首杀数据推送
SocketManager:registerDataCallBack("pushCityFirstBlood",function ( __type, __msg, __oldMsg)
	-- dump(__msg, "pushCityFirstBlood", 100)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushCityFirstBlood.id then
        	Player:getWorldData():updateCityFirstBlood(__msg.body)
			sendMsg(gud_city_first_blood_refresh, {nKind == __msg.body.ct})
			sendMsg(gud_city_first_blood_red)
        end
    end
end)

--[3039]城战请求支援
SocketManager:registerDataCallBack("reqCityWarSupport",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqCityWarSupport.id then

        	--发送求援消息
        	local tViewDotMsg=__oldMsg[3]
        	local tCityWarMsg=__oldMsg[4]
        	if tCityWarMsg then
	        	if tViewDotMsg  and tViewDotMsg:getIsMe() then		--被打的是我
					-- local playerinfo = Player:getPlayerInfo()
					local tData={
						an=tCityWarMsg.sSenderName,
						al=tCityWarMsg.nSenderCityLv,
						ax=tCityWarMsg.nSenderX,
						ay= tCityWarMsg.nSenderY,
						dc=tViewDotMsg.nCountry,--防守方国家
						dn=tViewDotMsg.sName,		--防守方名字
						dl=tViewDotMsg.nLevel,		--防守方等级
						dx=tViewDotMsg.nX,
						dy=tViewDotMsg.nY,
						-- dc=self.tCityWarMsg.nSenderCountry,--Integer	发起者国家
						-- dl=self.tCityWarMsg.nSenderCityLv,
						dt = e_share_type.becitywar,
					}
					autoShareToCountry(e_share_id.becitywar,tData)
				else		--我打人求援 
					local tData={
						an=tCityWarMsg.sSenderName,
						al=tCityWarMsg.nSenderCityLv,
						dc=tViewDotMsg.nCountry,--防守方国家
						dn=tViewDotMsg.sName,		--防守方名字
						dl=tViewDotMsg.nLevel,		--防守方等级
						dx=tViewDotMsg.nX,
						dy=tViewDotMsg.nY,
						dt = e_share_type.citywar,
					}
					autoShareToCountry(e_share_id.citywar,tData)
				end


			end
        end
    end
end)

--[-3105]请求boss支援
SocketManager:registerDataCallBack("reqWorldBossSupport",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldBossSupport.id then
        	-- {an}对:f5d93d;<u>{ln}Lv.{ll}[{lx},{ly}]</u>:f5d93d;发起了讨伐，大战一触即发，请求友军火速支援！:f5d93d;
        	--发送求援消息
        	local tViewDotMsg=__oldMsg[3]
        	if tViewDotMsg then
        		local playerinfo=Player:getPlayerInfo()
				local tData={
					an=playerinfo.sName,
					dc=tViewDotMsg.nCountry,--防守方国家
					dn=tViewDotMsg.sDotName,		--防守方名字
					dl=tViewDotMsg.nDotLv,		--防守方等级
					dx=tViewDotMsg.nX,
					dy=tViewDotMsg.nY,
					dt = e_share_type.bosssupport,
				}

				autoShareToCountry(e_share_id.bosssupport,tData)
			end
        end
    end
end)

--[3506]国战请求支援
SocketManager:registerDataCallBack("reqCountryWarSupport",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqCountryWarSupport.id then
        	-- dump(__msg.body,"body")
        	local playerinfo = Player:getPlayerInfo()
        	--发送求援消息
        	local nSysCityId = __oldMsg[1]

        	local tViewDotMsg=__oldMsg[3]
        	local tCityWarMsg=__oldMsg[4]
        	local sName=tViewDotMsg:getSysCityOwnerName()
        	if tCityWarMsg then
				local tData={
					an=playerinfo.sName,
					dc=tViewDotMsg.nSysCountry,
					bn = WorldFunc.getBlockId(tViewDotMsg.nX, tViewDotMsg.nY),
					dn=tViewDotMsg.sDotName,
					dx=tViewDotMsg.nX,
					dy=tViewDotMsg.nY,
					did=nSysCityId,
					dl=tViewDotMsg.nLevel,
					dt = e_share_type.countrywar,

				}
				
				if sName then
					tData.cn = sName
				else
					tData.cn = getConvertedStr(9,10109)
				end

				autoShareToCountry(e_share_id.countrywar,tData)
			end
        end
    end
end)


--[3505]免费迁往州
--MsgType.freetostate = {id = -3505, keys = {}}
SocketManager:registerDataCallBack("freetostate",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.freetostate.id then
        	
        	if __msg.body and __msg.body.mzt then
        		Player:getWorldData():setTodayFreeChangeCity(__msg.body.mzt)
        		Player:getWorldData():onFreeToState(__msg.body)
				sendMsg(gud_world_my_city_pos_change_msg)
        	end
        end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)
--[3508]请求生成一个任务乱军
--MsgType.reqTaskWildArmy = {id = -3508, keys = {}}
SocketManager:registerDataCallBack("reqTaskWildArmy",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqTaskWildArmy.id then
        	dump(__msg.body, "__msg.body", 100)
        	if __msg.body then
				Player:getWorldData():onLoadCityRes(__msg.body)

				if __msg.body.otob then
					Player:getWorldData():setOffLineReward(__msg.body.otob)
				end
			end
        end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3602]冥界入侵推送

SocketManager:registerDataCallBack("pushGhostdomWar",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        -- dump(__msg.body, "__msg.body ghost", 100)
        if __msg.body then
			Player:getWorldData():onGhostAttackNotice(__msg.body)
			sendMsg(gud_world_my_city_be_attack_msg)
			-- sendMsg(gud_my_city_war_list_change)
		end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3603]冥界请求支援
SocketManager:registerDataCallBack("reqGhostdomWarSupport",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqGhostdomWarSupport.id then

        	--发送求援消息
        	local tViewDotMsg=__oldMsg[1]
        	local tCityWarMsg=__oldMsg[2]
        	if tCityWarMsg then
	        	-- if tViewDotMsg  and tViewDotMsg:getIsMe() then		--被打的是我
					-- local playerinfo = Player:getPlayerInfo()
					local tData={
						an=tCityWarMsg.sSenderName,
						al=tCityWarMsg.nBossLv,
						aId=tCityWarMsg.nNpcId,
						ls= tCityWarMsg.nSeq,
						dx=tViewDotMsg.nX,
						dy=tViewDotMsg.nY,
						dc=tViewDotMsg.nCountry,--防守方国家
						dn=tViewDotMsg.sName,		--防守方名字
						-- aId = tCityWarMsg
						-- dc=self.tCityWarMsg.nSenderCountry,--Integer	发起者国家
						dl=tViewDotMsg.nLevel,
						dt = e_share_type.ghostsupport,
					}
					autoShareToCountry(e_share_id.ghostsupport,tData)
				-- else		--我打人求援 
				-- 	local tData={
				-- 		an=tCityWarMsg.sSenderName,
				-- 		al=tCityWarMsg.nSenderCityLv,
				-- 		dc=tViewDotMsg.nCountry,--防守方国家
				-- 		dn=tViewDotMsg.sName,		--防守方名字
				-- 		dl=tViewDotMsg.nLevel,		--防守方等级
				-- 		dx=tViewDotMsg.nX,
				-- 		dy=tViewDotMsg.nY,
				-- 		dt = e_share_type.citywar,
				-- 	}
				-- 	autoShareToCountry(e_share_id.citywar,tData)
				-- end


			end
        end
    end
end)

--[3509]请求单个城池信息
SocketManager:registerDataCallBack("reqSingalSysCityDot",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.body then
			Player:getWorldData():onSingalSysCity(__msg.body)
		end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)