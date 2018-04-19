-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 09:46:24 星期五 
-- Description: 建筑控制类
-----------------------------------------------------

local BuildData = require("app.layer.build.data.BuildData")

tsf_open_citydef_team_lv = 2 --统帅府城防队伍等级要求

--请求建筑基础数据回调
SocketManager:registerDataCallBack("loadBuildDatas",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		-- dump(__msg.body, "__msg.body", 100)
		Player:getBuildData():refreshDatasByService(__msg.body,1)
		--通知基地建筑数据发生变化
		local tObject2 = {}
		tObject2.nType = 1
		sendMsg(gud_build_data_refresh_msg,tObject2)

		sendMsg(ghd_auto_build_mgr_msg)
	end
end)

--推送建筑基础数据回调
SocketManager:registerDataCallBack("pushBuildDatas",function ( __type, __msg )
	-- bodyco
	if __msg.head.state == SocketErrorType.success then
		
		if __msg.body.openAuto then
			TOAST(getTipsByIndex(10080))
		end
		if __msg.body.bqqs then
			for k, v in pairs (__msg.body.bqqs) do
				if v.od==1 then 		--升级
					local pBuild=nil
					if v.loc > n_start_suburb_cell then
						pBuild = Player:getBuildData():getSuburbByCell(v.loc)
					else
						pBuild = Player:getBuildData():getBuildByCell(v.loc)
					end
					if pBuild then
						local pBuildUping = Player:getBuildData():getUpingBuildByCell(v.loc)
						if not pBuildUping then
							TOAST(string.format(getTipsByIndex(10082),pBuild.sName))
						end
					end
				end
				
			end
		end
		Player:getBuildData():refreshDatasByService(__msg.body,2)
		sendMsg(ghd_auto_build_mgr_msg)
	end
end)

--请求升级建筑数据回调
SocketManager:registerDataCallBack("upBuild",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tT = __msg.body
		-- dump(tT, "请求升级建筑数据回调 ==")
		tT.loc = __oldMsg[1]
		--添加到升级队列中
		Player:getBuildData():addBuildUpding({tT},__oldMsg[3])
	end
end)

-- helpupingBuild
--协助建筑升级数据推送
SocketManager:registerDataCallBack("helpupingBuild",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tT = __msg.body
		-- tT.loc = __msg.body.loc
		Player:getBuildData():refreshBuildUpdingLists({tT},3)
		--如果cd时间为0，那么需要从升级队列中移除
		if __msg.body.cd then
			if __msg.body.cd <= 0 then
				Player:getBuildData():removeBuildUpding(__msg.body)
				--通知基地建筑数据发生变化
				local tObject = {}
				tObject.nType = 1
				sendMsg(gud_build_data_refresh_msg,tObject)
			else
				local tObject = {}
				tObject.nBuildCell = __msg.body.loc
				tObject.nBuildId = __msg.body.id
				sendMsg(gud_finish_speed_btn_click,tObject)
			end
		--如果加速后cd不存在则默认是已完成升级
		elseif not __msg.body.cd then
			-- 通知基地建筑升级完成，表现特效
			local tObject = {}
			tObject.nCell = __msg.body.loc
			sendMsg(ghd_show_buildup_tx_msg, tObject)
		end
	end
end)


--请求升级加速数据回调
SocketManager:registerDataCallBack("upFastBuild",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tT = __msg.body
		tT.loc = __oldMsg[1]
		Player:getBuildData():refreshBuildUpdingLists({tT},3)
		--如果cd时间为0，那么需要从升级队列中移除
		if __msg.body.cd then
			if __msg.body.cd <= 0 then
				Player:getBuildData():removeBuildUpding(__msg.body)
				--通知基地建筑数据发生变化
				local tObject = {}
				tObject.nType = 1
				sendMsg(gud_build_data_refresh_msg,tObject)
			else
				local tObject = {}
				tObject.nBuildCell = __msg.body.loc
				tObject.nBuildId = __oldMsg[2]
				sendMsg(gud_finish_speed_btn_click,tObject)
			end
		--如果加速后cd不存在则默认是已完成升级
		elseif not __msg.body.cd then
			-- 通知基地建筑升级完成，表现特效
			local tObject = {}
			tObject.nCell = __msg.body.loc
			sendMsg(ghd_show_buildup_tx_msg, tObject)
		end
	end
end)

--推送建筑升级完成数据回调(建筑队列更新推送)
SocketManager:registerDataCallBack("pushUpBuild",function ( __type, __msg )
	-- body
	-- dump(__msg.body, "建筑队列更新推送 __msg.body ==")
	if __msg.head.state == SocketErrorType.success then
		-- --播放升级或者升级完成音效
		local tT = __msg.body
		if tT.recruting then --募兵府数据
			tT.id = tT.recruting.id
			tT.loc = tT.recruting.loc
			tT.lv = tT.recruting.lv
		end
		--移除升级中的队列
		Player:getBuildData():removeBuildUpding(tT)
		
		--通知基地建筑数据发生变化
		local tObject2 = {}
		tObject2.nType = 1
		sendMsg(gud_build_data_refresh_msg,tObject2)
		--通知基地建筑状态发生变化
		local tObject = {}
		tObject.nCell = tT.loc
		if tT.od == 3 then
			tObject.nBuildId = tT.id
			tObject.nType = tT.od
		end
		sendMsg(gud_build_state_change_msg,tObject)
		--奖励
		-- if tT.o then
		-- 	print("弹出奖励")
		-- end
		--提示语
		local tBuild = nil
		if tT.loc > n_start_suburb_cell then --郊外资源
			tBuild = Player:getBuildData():getSuburbByCell(tT.loc)
		else 									  --城内建筑
			tBuild = Player:getBuildData():getBuildByCell(tT.loc)
		end
		if tBuild then
			local sTip
			if tT.od == 1 then   -- 1.建筑升级 2.建筑拆除 3.建筑建造
				sTip = string.format(getConvertedStr(1, 10159),tBuild.sName)
			elseif tT.od == 3 then
				if tT.recruting then
					sTip = string.format(getConvertedStr(7, 10255),tBuild.sDetailName)
				else
					sTip = string.format(getConvertedStr(7, 10255),tBuild.sName)
				end
			end
			TOAST(sTip)
			--总览文字冒泡提示
			local tObject4 = {}
			tObject4.sTip = sTip
			sendMsg(ghd_show_overview_tip,tObject4)
		end
		--通知基地建筑升级或改建完成，表现特效
		local tObject3 = {}
		tObject3.nCell = tT.loc
		sendMsg(ghd_show_buildup_tx_msg,tObject3)


		-- --激活当前新手教程
		-- if B_GUIDE_LOG then
		-- 	print("B_GUIDE_LOG 推送建筑升级完成数据回调 再次检测新手")
		-- end
		-- Player:getNewGuideMgr():showNewGuideAgain()
	end
end)


--推送建筑升级加速数据回调
SocketManager:registerDataCallBack("pushExpediteBuild",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then

		local tT = __msg.body
		Player:getBuildData():refreshBuildUpdingLists({tT},3)
		--通知基地建筑数据发生变化
		local tObject2 = {}
		tObject2.nType = 1
		sendMsg(gud_build_data_refresh_msg,tObject2)


	end
end)


--校验升级数据回调
SocketManager:registerDataCallBack("checkupingBuild",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tT = __msg.body
		tT.loc = __oldMsg[1]
		Player:getBuildData():refreshBuildUpdingLists({tT},3)
		--如果cd时间为0，那么需要从升级队列中移除
		if __msg.body.cd and __msg.body.cd <= 0 then
			__msg.body.loc = __oldMsg[1]
			Player:getBuildData():removeBuildUpding(__msg.body)
			--通知基地建筑数据发生变化
			local tObject = {}
			tObject.nType = 1
			sendMsg(gud_build_data_refresh_msg,tObject)
		end
	end
end)

--购买建筑队列回调
SocketManager:registerDataCallBack("buyBuildTeam",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getBuildData():refreshBuildBuyLeftTime(__msg.body)
		--通知基地建筑数据发生变化
		local tObject = {}
		tObject.nType = 1
		sendMsg(gud_build_data_refresh_msg,tObject)
		
	end
end)

--自动升级请求回调
SocketManager:registerDataCallBack("autoBuilding",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--是否开启自动建造
		Player:getBuildData().bAutoUpOpen = __msg.body.openAuto
		sendMsg(ghd_auto_build_mgr_msg)
	end
end)

--建筑拆除等操作推送
SocketManager:registerDataCallBack("pushMoreActionBuild",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--移除建筑
		Player:getBuildData():removeOneBuild(__msg.body.loc,__msg.body.id)
		--通知基地建筑状态发生变化
		local tObject = {}
		tObject.nCell = __msg.body.loc
		sendMsg(gud_build_state_change_msg,tObject)
	end
end)

--建筑更多操作（拆除，建造）
SocketManager:registerDataCallBack("moreActionBuild",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tT = __msg.body
		-- dump(tT, "建筑更多操作（拆除，建造） ==")
		tT.loc = __oldMsg[1]
		--添加到升级队列中
		Player:getBuildData():actionForBuild({tT})
	end
end)

--创建募兵府
SocketManager:registerDataCallBack("reqBuildRecruitHouse",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.reqBuildRecruitHouse.id then
		if __msg.head.state == SocketErrorType.success then
			local tT = __msg.body
			tT.loc = __oldMsg[2]
			--新增一个操作到建筑中队列
			Player:getBuildData():actionForBuild({tT})

			if __oldMsg[4] then
				TOAST(string.format(getConvertedStr(7, 10422), __oldMsg[4])) --"%s建造完成"
			end

			--通知基地建筑状态发生变化
			local tObject = {}
			tObject.nCell = tT.loc
			tObject.nBuildId = __oldMsg[1]
			tObject.nType = 3
			sendMsg(gud_build_state_change_msg,tObject)
			
			--通知基地建筑建造完成，表现特效
			local tObject = {}
			tObject.nCell = tT.loc
			sendMsg(ghd_build_bubble_clicktx_msg,tObject)
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end
end)

--建筑解锁推送(养成建筑解锁推送)
SocketManager:registerDataCallBack("pushBuildUnlock",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local tData = __msg.body
		-- dump(tData, "tData", 100)
		if tData then
			--分开写，有可能同时解锁
			--仓库
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.store,e_build_ids.store,e_build_cell.store,tData.type)
			--步兵营
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.infantry,e_build_ids.infantry,e_build_cell.infantry,tData.type)
			--骑兵营
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.sowar,e_build_ids.sowar,e_build_cell.sowar,tData.type)
			--弓兵营
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.archer,e_build_ids.archer,e_build_cell.archer,tData.type)
			--科技院
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.tnoly,e_build_ids.tnoly,e_build_cell.tnoly,tData.type)
			--作坊
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.atelier,e_build_ids.atelier,e_build_cell.atelier,tData.type)
			--城门
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.gate,e_build_ids.gate,e_build_cell.gate,tData.type)
			--统帅府
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.drillGround,e_build_ids.tcf,e_build_cell.tcf,tData.type)
			--募兵府
			Player:getBuildData():refreshBuildDatasForUnlocked(tData.recruting,e_build_ids.mbf,e_build_cell.mbf,tData.type,tData.orc)

			--资源田
			Player:getBuildData():addSuburbBuild(tData.rb,tData.type, true)
			--未激活资源田			
			Player:getBuildData():addSuburbBuild(tData.unActB,tData.type, false)

			--不可升级建筑
			Player:getBuildData():refreshUnUpingBuilds(tData.ub,tData.type)

			--新手教程
			Player:getNewGuideMgr():checkIsShowUnloakGuide()
		end
		
	end
end)

--征收资源请求回调
SocketManager:registerDataCallBack("collectRes",function ( __type, __msg, __oldMsg )
	-- body
	-- dump(__msg.body, "__msg.body ==== ")
	if __msg.head.state == SocketErrorType.success then
		Player:getBuildData():refreshCollectCd(__msg.body)
		--发送资源田征收后数据变化的消息
		sendMsg(gud_refresh_suburb_data)

		--发送消息刷新资源田征收状态
		local nDelayAnimTime = 0
		local nDelayIndex = 0
		local tObjectList = {}
		
		sendMsg(ghd_refresh_suburb_state_mulit_msg, tObjectList)
		--如果需要打开自身再打开一下自身
		if __oldMsg[3] then
			local tObject = {}
			tObject.nCell = __oldMsg[1]
			tObject.bHadChecked = true
			sendMsg(ghd_show_build_actionbtn_msg,tObject)
		end
	end
end)

--募兵请求回调
SocketManager:registerDataCallBack("recruitSolider",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __oldMsg and __oldMsg[2] then
			--获得对应的兵营
			local pCamp = Player:getBuildData():getBuildById(__oldMsg[2])
			if pCamp then
				pCamp:refreshRecruitTeams(__msg.body.recruits)
				--通知招募队列发生变化
				local tObject = {}
				tObject.nBuildId = __oldMsg[2]
				sendMsg(ghd_refresh_camp_recruit_msg,tObject)
			end
		end
		
	end
end)

--募兵操作请求回调
SocketManager:registerDataCallBack("recruitAction",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __oldMsg and __oldMsg[1] then
			--获得对应的兵营
			local pCamp = Player:getBuildData():getBuildById(__oldMsg[1])
			if pCamp then
				pCamp:refreshRecruitTeams(__msg.body.recruits)
				--通知招募队列发生变化
				local tObject = {}
				tObject.nBuildId = __oldMsg[1]
				sendMsg(ghd_refresh_camp_recruit_msg,tObject)
			end
		end
	end
end)

--募兵招募队列更新推送
SocketManager:registerDataCallBack("pushRecruit",function ( __type, __msg)
	-- body
    -- dump(__msg.body, "pushBag __msg.body", 100)
	--获得对应的兵营
	local pCamp = Player:getBuildData():getBuildById(__msg.body.buildId)
	if pCamp then
		--获得正在招募中的队列
		local pRecruiting = pCamp:getRecruitingQue()
		if pRecruiting and pRecruiting.nId == __msg.body.proId then --判断是否是推送过来的队列
			-- pRecruiting:refreshByPush(1,__msg.body)
			pRecruiting:refreshCd(__msg.body)--更改cd时间
			--通知招募队列发生变化
			if __msg.body.buildId then
				local tObject = {}
				tObject.nBuildId = __msg.body.buildId
				sendMsg(ghd_refresh_camp_recruit_msg,tObject)
			end
		end
	end
end)

--兵营调整请求回调
SocketManager:registerDataCallBack("updateCamp",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __oldMsg and __oldMsg[1] and  __oldMsg[2] then
			--获得对应的兵营
			local pCamp = Player:getBuildData():getBuildById(__oldMsg[2])
			if pCamp then
				if __oldMsg[1] == 1 then --扩充
					pCamp:refreshCpyAndMoreQue(__msg.body)
				elseif __oldMsg[1] == 2 then --募兵加时
					pCamp:refreshRecruitMsg(__msg.body)
				end
				--通知招募队列发生变化
				local tObject = {}
				tObject.nBuildId = __oldMsg[2]
				sendMsg(ghd_refresh_camp_recruit_msg,tObject)
			end
		end
	end
end)

--雇用文官请求回调
SocketManager:registerDataCallBack("employCivil",function ( __type, __msg, __oldMsg)
	-- body
	--dump(__oldMsg, "__oldMsg=", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then			
			--刷新文官信息
			local tdata = {}
			tdata.cId = __oldMsg[1]
			tdata.ft  = __msg.body.cd		
			Player:getBuildData():getBuildById(e_build_ids.palace):refreshOfficalDatas(tdata)
		end
	end
end)

--文官事件校对刷新请求
SocketManager:registerDataCallBack("refreshOfficalCD",function ( __type, __msg)
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			local tmpdata = {}
			tmpdata.ft = __msg.body.cd
			Player:getBuildData():getBuildById(e_build_ids.palace):refreshOfficalDatas(tmpdata)			
		end
	end
end)

------------------------------------城墙-----------------------------------------

--城墙招募回调
SocketManager:registerDataCallBack("wallRecruitDef",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)			
		end
	end
end)

--城墙守卫推送
SocketManager:registerDataCallBack("pushWallChangeDef",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)	
			sendMsg(gud_refresh_wall)--通知刷新城墙		
		end
	end
end)


--守卫训练或治疗
SocketManager:registerDataCallBack("wallDefChangeState",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)			
		end
	end
end)

--城墙自动招募守卫推送
SocketManager:registerDataCallBack("pushWallAutoDef",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)	
			sendMsg(gud_refresh_wall)--通知刷新城墙		
			--通知基地建筑数据发生变化
			local tObject = {}
			tObject.nType = 1
			sendMsg(gud_build_data_refresh_msg,tObject)					
		end
	end
end)

--城墙守卫自动招募开关
SocketManager:registerDataCallBack("wallAutoDefSw",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			--通知基地建筑数据发生变化
			local tObject = {}
			tObject.nType = 1
			sendMsg(gud_build_data_refresh_msg,tObject)
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)			
		end
	end
end)

--城墙操作
SocketManager:registerDataCallBack("wallOperation",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			Player:getBuildData():getBuildById(e_build_ids.gate):refreshDatasByService(pData)			
		end
	end
end)

--校场解锁位置推送
SocketManager:registerDataCallBack("pushHeroTeamNums",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		local pData = __msg.body
		if pData then
			local tBuildData = Player:getBuildData():getBuildById(e_build_ids.tcf)
			if tBuildData then
				tBuildData:refreshDatasByService(pData)
				sendMsg(gud_tcf_hero_pos_unlock_push)
			end
		end
	end
end)

--校场解锁请求
SocketManager:registerDataCallBack("reqUnLockTcfPos",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "reqUnLockTcfPos=", 100)
	if  __msg.head.state == SocketErrorType.success then
		local tBuildData = Player:getBuildData():getBuildById(e_build_ids.tcf)
		if tBuildData then
			if __oldMsg and __oldMsg[1] == 3 then
				sendMsg(ghd_refresh_troop_trap_msg, tBuildData.nRate)
			end
			tBuildData:refreshDatasByService(__msg.body)
			sendMsg(gud_tcf_hero_pos_unlock_push)
		end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--升级高级御兵术
SocketManager:registerDataCallBack("reqTroopActivite",function ( __type, __msg, __oldMsg )
	--body
	--dump(__msg.body, "__msg.body", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then			
			local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
			if pBChiefData then
				pBChiefData:refreshDatasByService(__msg.body)
			end
		end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end
end)


--2142是否开启自动补充耐力
SocketManager:registerDataCallBack("autoAddHeroNaili",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "autoAddHeroNaili=", 100)
	if  __msg.head.state == SocketErrorType.success then
		local tBuildData = Player:getBuildData():getBuildById(e_build_ids.tcf)
		if tBuildData then
			tBuildData:refreshDatasByService(__msg.body)
		end
		sendMsg(gud_tcf_auto_add_naili)
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

-- [2145]设置是否低等级优先升级
SocketManager:registerDataCallBack("reqLowGradePriority",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "reqLowGradePriority=", 100)
	if  __msg.head.state == SocketErrorType.success then
		Player:getBuildData():refreshAutoBuildData(__msg.body)
		sendMsg(ghd_auto_build_mgr_msg)
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

-- [2146]设置自动建造升级的类型
SocketManager:registerDataCallBack("reqAutoBuildType",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "reqAutoBuildType=", 100)
	if  __msg.head.state == SocketErrorType.success then
		Player:getBuildData():refreshAutoBuildData(__msg.body)
		sendMsg(ghd_auto_build_mgr_msg)
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

-- [2147]设置自定义自动建造优先级
SocketManager:registerDataCallBack("reqCustomPriority",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "reqCustomPriority=", 100)
	if  __msg.head.state == SocketErrorType.success then
		Player:getBuildData():refreshAutoBuildData(__msg.body)
		sendMsg(ghd_auto_build_mgr_msg)
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

-- [2148]设置建筑是否开启自动建造
SocketManager:registerDataCallBack("reqOpenAutoBuild",function ( __type, __msg, __oldMsg  )
	--dump(__msg, "reqOpenAutoBuild=", 100)
	if  __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getBuildData():refreshAutoBuildData(__msg.body)
			sendMsg(ghd_auto_build_mgr_msg)					
		end		
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

------------------------------------城墙-----------------------------------------

--[2149]资源打包
SocketManager:registerDataCallBack("reqPackResours",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqPackResours.id then
			if __msg.body then
				Player:getBuildData():refreshResPackData(__msg.body)
				if __msg.body.ob then
					--获取物品效果
					showGetAllItems(__msg.body.ob)
				end
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--建筑id
e_build_ids = {
	--可建造
	palace 			= 		11000, 			--王宫
	store 			= 		11001, 			--仓库
	tnoly 			= 		11002, 			--科技院（太学院）
	infantry 		= 		11003, 			--步兵营
	sowar 			= 		11004, 			--骑兵营
	archer 			= 		11005, 			--弓兵营
	gate 			= 		11006, 			--城门（城墙）
	atelier 		= 		11007, 			--作坊
	house 			= 		11008, 			--民居
	wood 			= 		11009, 			--木场
	farm 			= 		11010, 			--农田
	iron 			= 		11011, 			--铁矿
	--不可建造
	tjp 			= 		11012, 			--铁匠铺
	ylp 			= 		11013, 			--冶炼铺
	jxg 			= 		11014, 			--聚贤馆
	shop 			= 		11015, 			--商店
	jbp 			= 		11016, 			--聚宝盆(珍宝阁)
	tcf 			= 		11017, 			--统帅府
	mbf 			= 		11018, 			--募兵府
	bjt 			= 		11019, 			--拜将台
	arena 			= 		11020, 			--竞技场
	warhall 		= 		11021, 			--战争大厅
}

--建筑cellindex
e_build_cell = {
	--可建造
	palace 			= 		1, 			    --王宫
	store 			= 		2, 			    --仓库
	tnoly 			= 		3, 			    --科技院（太学院）
	infantry 		= 		4, 			    --步兵营
	sowar 			= 		5, 			    --骑兵营
	archer 			= 		6, 			    --弓兵营
	gate 			= 		7, 			    --城门（城墙）
	atelier 		= 		8, 			    --作坊
	house 			= 		0, 			    --民居
	wood 			= 		0, 			    --木场
	farm 			= 		0, 			    --农田
	iron 			= 		0, 			    --铁矿
	--不可建造
	tjp 			= 		9, 			    --铁匠铺
	ylp 			= 		10, 			--冶炼铺
	jxg 			= 		11, 			--聚贤馆
	shop 			= 		12, 			--商店
	jbp 			= 		13, 			--聚宝盆	
	mbf 			= 		15, 			--募兵府
	bjt 			= 		16, 			--拜将台
	tcf 			= 		17, 			--统帅府
	arena 			=       18, 			--竞技场
	warhall 		= 		19, 			--战争大厅	
}

--资源建筑id
e_suburb_ids = {
	house 			= 		11008, 			--民居
	wood 			= 		11009, 			--木场
	farm 			= 		11010, 			--农田
	iron 			= 		11011, 			--铁矿
}

--3种兵营建筑id
e_camp_ids = {
	infantry 		= 		11003, 			--步兵营
	sowar 			= 		11004, 			--骑兵营
	archer 			= 		11005, 			--弓兵营
}

--募兵府3种兵营类型
e_mbf_camp_type = {
	infantry 		= 		1, 				--步兵营
	sowar 			= 		2, 				--骑兵营
	archer 			= 		3, 				--弓兵营
}

--加诸在建筑身上的buff作用类型
e_build_buff        = {
	infantry        =       6,              --步兵
	sowar           =       7,              --骑兵
	archer          =       8,              --弓兵
}

--建筑升级所需可key值
e_build_uplimit_key = {
	team 			= 		1,				--升级队列
	playerLv 		= 		2, 	 			--主公等级
	palaceLv 		= 		3, 				--王宫等级
	tong 			= 		4, 				--（资源1）
	mu 				= 		5, 				--（资源2）
	liang 			= 		6, 				--（资源3）
	tie 			= 		7, 				--（资源4）
	unfree 			= 		8, 				--非空闲状态(工坊专属)
}

--建筑状态
e_build_state = {
	free 			= 		1, 			    --空闲
	uping 			= 		2, 			    --升级
	producing 		= 		3, 			    --生产 
	creating  		= 		4, 				--改建
	removing 		= 		5, 				--拆除
}

--兵营募兵item类型
e_camp_item = {
	finish 			= 		1, 				--完成募兵
	ing 			= 		2, 				--募兵中
	wait  			= 		3, 				--等待中
	free 			= 		4, 				--可募兵
	fill 			= 		5, 				--兵力满
	more 			= 		6, 				--扩充
}

--建筑按钮类型
e_buildbtn_type = {
	lvup 			= 1, 			--升级
	enter 			= 2, 			--进入
	speedup 		= 3, 			--加速
	finish 			= 4, 			--立即完成
	recruit 		= 5, 			--募兵
	remove 			= 6, 			--拆除
}


--已追踪过的可升级建筑的格子列表
tClickedUpBuildList = {}

--获得玩家建筑单例
function Player:getBuildData(  )
	-- body
	if not Player.buildData then
		self:initBuildData()
	end
	return Player.buildData
end

-- 初始化玩家建筑数据
function Player:initBuildData(  )
	if not Player.buildData then
		Player.buildData = BuildData.new() --玩家的基础信息表
	end
	return "Player.buildData"
end

--释放玩家建筑数据
function Player:releaseBuildData(  )
	if Player.buildData then
		Player.buildData = nil --玩家的基础信息
	end
	return "Player.buildData"
end

--根据建筑下标获取位置
--_nCell：建筑格子下标
function getBuildGroupShowDataByCell( _nCell, _sId )
	-- body
	if not _nCell then
		print("getBuildGroupShowDataByCell : _nCell is nil")
		return
	end

	local tShowData = {} --建筑展示相关数据
	-- tShowData.img = "#" .. _sId .. "_img_hd.png" -- 默认图片
	if _sId == 11015 then
		tShowData.img = "#11010_img_hd.png" -- 默认图片
	elseif _sId == e_build_ids.mbf then --募兵府
		local tBuildData = Player:getBuildData():getBuildById(_sId, true)
		if tBuildData.nRecruitTp == e_mbf_camp_type.infantry then
			tShowData.img = "#"..e_build_ids.infantry.."_img_hd.png" -- 步兵营图片
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.sowar then
			tShowData.img = "#"..e_build_ids.sowar.."_img_hd.png" -- 骑兵营图片
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.archer then
			tShowData.img = "#"..e_build_ids.archer.."_img_hd.png" -- 弓兵营图片
		else
			tShowData.img = "#v1_img_caopi.png" -- 默认图片
		end
	elseif _sId == 11000 then --王宫，特别处理
		tShowData.img = "ui/11000_img_hd.png" -- 默认图片
	else
		tShowData.img = "#" .. _sId .. "_img_hd.png" -- 默认图片
	end

	--构建一张图片，用来获取宽高
	local pImg = MUI.MImage.new(tShowData.img)
	--相关参数定义
	local fW = pImg:getWidth() --宽
	local fH = pImg:getHeight() --高
	local fX = 0 --x值
	local fY = 0 --y值
	local fLrm = 0.5 -- 左边可点击的比例
	local fRrm = 0.5 -- 右边可点击的比例
	local fBrm = 0.5 -- 下边可点击的比例
	local fTrm = 0.5 -- 上边可点击的比例
	local fDzRw = 0.5 -- 底座宽度的比例
	local fDzRh = 0.5 -- 底座高度的比例
	local fBtRw = 0.5 -- 标题宽度的比例
	local fBtRh = 1.0 -- 标题高度的比例
	local fLockRw = 0.5 --锁图片的比例
	local fLockRh = 0.5 --锁图片的比例
	local fGroupScale = 1 -- 缩放比例
	local sSmallImg = "" -- 小图片

	--可升级建筑
	if _nCell == e_build_cell.palace then --王宫
		fX = 728
		fY = 1678
		fLrm = 0.5 -- 左边可点击的比例
		fRrm = 0.3 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.35 -- 上边可点击的比例
		fDzRw = 427 / fW -- 底座宽度的比例
		fDzRh = 185 / fH -- 底座高度的比例
		fBtRw = 255 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
	elseif _nCell == e_build_cell.tnoly then --科技院（太学院）
		fX = 384
		fY = 1443
		fLrm = 0.5 -- 左边可点击的比例
		fRrm = 0.5 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.5 -- 上边可点击的比例
		fDzRw = 255 / fW -- 底座宽度的比例
		fDzRh = 50 / fH -- 底座高度的比例
		fBtRw = 255 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+80)/fW
		fLockRh = (fH/2-16)/fH
	elseif _nCell == e_build_cell.store then --仓库
		-- fX = 2125
		-- fY = 1533
		fX = 1470
		fY = 1800
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.3 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.5 -- 上边可点击的比例
		fDzRw = 160 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 140 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+14)/fW
	elseif _nCell == e_build_cell.atelier then --作坊
		fX = 780
		fY = 1285
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.3 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.5 -- 上边可点击的比例
		fDzRw = 190 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 175 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+30)/fW
		fLockRh = (fH/2-20)/fH
	elseif _nCell == e_build_cell.infantry then --步兵营
		fX = 1068
		fY = 1117
		fLrm = 0.45 -- 左边可点击的比例
		fRrm = 0.3 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.35 -- 上边可点击的比例
		fDzRw = 215 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 170 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+26)/fW
		fLockRh = (fH/2-10)/fH
	elseif _nCell == e_build_cell.sowar then --骑兵营
		fX = 783
		fY = 986
		fLrm = 0.45 -- 左边可点击的比例
		fRrm = 0.35 -- 右边可点击的比例
		fBrm = 0.7 -- 下边可点击的比例
		fTrm = 0.7 -- 上边可点击的比例
		fDzRw = 230 / fW -- 底座宽度的比例
		fDzRh = 65 / fH -- 底座高度的比例
		fBtRw = 190 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+40)/fW
		fLockRh = (fH/2-20)/fH
	elseif _nCell == e_build_cell.archer then --弓兵营
		fX = 505
		fY = 837
		fLrm = 0.45 -- 左边可点击的比例
		fRrm = 0.4 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.35 -- 上边可点击的比例
		fDzRw = 240 / fW -- 底座宽度的比例
		fDzRh = 55 / fH -- 底座高度的比例
		fBtRw = 190 / fW -- 标题宽度的比例
		fBtRh = 1.05 -- 标题高度的比例
		fLockRw = (fW/2+50)/fW
		fLockRh = (fH/2-20)/fH
	elseif _nCell == e_build_cell.gate then --城门（城墙）
		fX = 1785
		fY = 995
		fLrm = 0.65 -- 左边可点击的比例
		fRrm = 0.25 -- 右边可点击的比例
		fBrm = 0.3 -- 下边可点击的比例
		fTrm = 0.52 -- 上边可点击的比例
		fDzRw = 0.5 -- 底座宽度的比例
		fDzRh = 0.5 -- 底座高度的比例
		fBtRw = 0.45 -- 标题宽度的比例
		fBtRh = 0.95 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
	--不可升级建筑
	elseif _nCell == e_build_cell.jxg then --将军府（聚贤馆）
		fX = 1355
		fY = 1555
		-- fLrm = 0.4 -- 左边可点击的比例
		-- fRrm = 0.25 -- 右边可点击的比例
		-- fBrm = 0.5 -- 下边可点击的比例
		-- fTrm = 0.35 -- 上边可点击的比例
		-- fDzRw = 200 / fW -- 底座宽度的比例
		-- fDzRh = 55 / fH -- 底座高度的比例
		-- fBtRw = 180 / fW -- 标题宽度的比例
		-- fBtRh = 1.0 -- 标题高度的比例
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.45 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 150 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 130 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
		fLockRh = (fH/2-20)/fH
	elseif _nCell == e_build_cell.tjp then --铁匠铺
		fX = 553
		fY = 1178
		fLrm = 0.3 -- 左边可点击的比例
		fRrm = 0.3 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.3 -- 上边可点击的比例
		fDzRw = 230 / fW -- 底座宽度的比例
		fDzRh = 65 / fH -- 底座高度的比例
		fBtRw = 200 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+40)/fW
		fLockRh = (fH/2-10)/fH
	elseif _nCell == e_build_cell.ylp then --冶炼铺
		fX = 320
		fY = 1060
		fLrm = 0.35 -- 左边可点击的比例
		fRrm = 0.35 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.5 -- 上边可点击的比例
		fDzRw = 175 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 160 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+28)/fW
		fLockRh = (fH/2-10)/fH
	elseif _nCell == e_build_cell.jbp then --聚宝盆
		fX = 1745
		fY = 1495
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.45 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 150 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 130 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
	elseif _nCell == e_build_cell.bjt then --拜将台
		fX = 1100
		fY = 1795
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.25 -- 右边可点击的比例
		fBrm = 0.5 -- 下边可点击的比例
		fTrm = 0.35 -- 上边可点击的比例
		fDzRw = 200 / fW -- 底座宽度的比例
		fDzRh = 55 / fH -- 底座高度的比例
		fBtRw = 180 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+40)/fW
		fLockRh = (fH/2-20)/fH
	elseif _nCell == e_build_cell.tcf then --统帅府
		fX = 1355
		fY = 1555
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.45 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 150 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 130 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
		fLockRh = (fH/2-20)/fH		
	elseif _nCell == e_build_cell.mbf then --募兵府 
		fX = 1610
		fY = 1390
		fLrm = 0.45 -- 左边可点击的比例
		fRrm = 0.4 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 150 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 130 / fW -- 标题宽度的比例
		fBtRh = 1.0 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
		local tBuildData = Player:getBuildData():getBuildById(e_build_ids.mbf, true)
		if tBuildData.nRecruitTp == e_mbf_camp_type.infantry then
			fDzRw = 215 / fW -- 底座宽度的比例
			fDzRh = 60 / fH -- 底座高度的比例
			fBtRw = 170 / fW -- 标题宽度的比例
			fLockRw = (fW/2+26)/fW
			fLockRh = (fH/2-10)/fH
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.sowar then
			fDzRw = 230 / fW -- 底座宽度的比例
			fDzRh = 65 / fH -- 底座高度的比例
			fBtRw = 190 / fW -- 标题宽度的比例
			fLockRw = (fW/2+40)/fW
			fLockRh = (fH/2-20)/fH
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.archer then
			fDzRw = 240 / fW -- 底座宽度的比例
			fDzRh = 55 / fH -- 底座高度的比例
			fBtRw = 190 / fW -- 标题宽度的比例
			fBtRh = 1.05 -- 标题高度的比例
			fLockRw = (fW/2+50)/fW
			fLockRh = (fH/2-20)/fH
		-- else
		-- 	fX = 1660
		-- 	fY = 1450
		end
	elseif _nCell == e_build_cell.arena then --竞技场
		fX = 1568
		fY = 1395
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.45 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 150 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 130 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (fW/2+10)/fW
	elseif _nCell == e_build_cell.warhall then --战争大厅
		fX = 285  
		fY = 1060
--        fX = 1568 + 185
--		fY = 1395 + 80
		fLrm = 0.4 -- 左边可点击的比例
		fRrm = 0.45 -- 右边可点击的比例
		fBrm = 0.55 -- 下边可点击的比例
		fTrm = 0.45 -- 上边可点击的比例
		fDzRw = 200 / fW -- 底座宽度的比例
		fDzRh = 60 / fH -- 底座高度的比例
		fBtRw = 200 / fW -- 标题宽度的比例
		fBtRh = 1.03 -- 标题高度的比例
		fLockRw = (200 - 10)/fW
	--资源田格子	
	--（民居）
	elseif _nCell == 1001 then
		fX = 1982
		fY = 573
	elseif _nCell == 1002 then
		fX = 1784
		fY = 523
	elseif _nCell == 1003 then
		fX = 1941
		fY = 435
	elseif _nCell == 1004 then
		fX = 2205
		fY = 470
	elseif _nCell == 1005 then
		fX = 1562
		fY = 487
	elseif _nCell == 1006 then
		fX = 1407
		fY = 376
	elseif _nCell == 1007 then
		fX = 1242
		fY = 312
	elseif _nCell == 1008 then
		fX = 1567
		fY = 294
	elseif _nCell == 1009 then
		fX = 1713
		fY = 394
	elseif _nCell == 1010 then
		fX = 1860
		fY = 285
	elseif _nCell == 1011 then
		fX = 2239
		fY = 314
	elseif _nCell == 1012 then
		fX = 2404
		fY = 431
	elseif _nCell == 1013 then
		fX = 2661
		fY = 375
	elseif _nCell == 1014 then
		fX = 2503
		fY = 299
	elseif _nCell == 1015 then
		fX = 2855
		fY = 311
	elseif _nCell == 1016 then
		fX = 3071
		fY = 284

	--（木厂）
	elseif _nCell == 1017 then
		fX = 2985
		fY = 1365
	elseif _nCell == 1018 then
		fX = 2805
		fY = 1405
	elseif _nCell == 1019 then
		fX = 3075
		fY = 1520
	elseif _nCell == 1020 then
		fX = 3270
		fY = 1520
	elseif _nCell == 1021 then
		fX = 2680
		fY = 1475
	elseif _nCell == 1022 then
		fX = 2680
		fY = 1610
	elseif _nCell == 1023 then
		fX = 2900
		fY = 1580
	elseif _nCell == 1024 then
		fX = 3025
		fY = 1655
	elseif _nCell == 1025 then
		fX = 3230
		fY = 1665
	elseif _nCell == 1026 then
		fX = 3415
		fY = 1640
	elseif _nCell == 1027 then
		fX = 3595
		fY = 1645
	elseif _nCell == 1028 then
		fX = 2485
		fY = 1645
	elseif _nCell == 1029 then
		fX = 2850
		fY = 1740
	elseif _nCell == 1030 then
		fX = 3115
		fY = 1780
	elseif _nCell == 1031 then
		fX = 3305
		fY = 1770
	elseif _nCell == 1032 then
		fX = 3523
		fY = 1768

	--（农田）
	elseif _nCell == 1033 then
		fX = 2328
		fY = 863
	elseif _nCell == 1034 then
		fX = 2479
		fY = 960
	elseif _nCell == 1035 then
		fX = 2636
		fY = 1078
	elseif _nCell == 1036 then
		fX = 2714
		fY = 947
	elseif _nCell == 1037 then
		fX = 2376
		fY = 727
	elseif _nCell == 1038 then
		fX = 2659
		fY = 725
	elseif _nCell == 1039 then
		fX = 2920
		fY = 810
	elseif _nCell == 1040 then
		fX = 3126
		fY = 872
	elseif _nCell == 1041 then
		fX = 3161
		fY = 682
	elseif _nCell == 1042 then
		fX = 2981
		fY = 589
	elseif _nCell == 1043 then
		fX = 3137
		fY = 474
	elseif _nCell == 1044 then
		fX = 3306
		fY = 575
	elseif _nCell == 1045 then
		fX = 3475
		fY = 690
	elseif _nCell == 1046 then
		fX = 3643
		fY = 593
	elseif _nCell == 1047 then
		fX = 3475
		fY = 497
	elseif _nCell == 1048 then
		fX = 3693
		fY = 416

	--（铁矿）
	elseif _nCell == 1049 then
		fX = 3325
		fY = 1155
	elseif _nCell == 1050 then
		fX = 3292
		fY = 1350
	elseif _nCell == 1051 then
		fX = 3480
		fY = 1335
	elseif _nCell == 1052 then
		fX = 3535
		fY = 1190
	elseif _nCell == 1053 then
		fX = 3510
		fY = 1040
	elseif _nCell == 1054 then
		fX = 3730
		fY = 1540
	elseif _nCell == 1055 then
		fX = 3650
		fY = 1405
	elseif _nCell == 1056 then
		fX = 3725
		fY = 1233
	elseif _nCell == 1057 then
		fX = 3740
		fY = 1055
	elseif _nCell == 1058 then
		fX = 3750
		fY = 925
	elseif _nCell == 1059 then
		fX = 3835
		fY = 1660
	elseif _nCell == 1060 then
		fX = 3930
		fY = 1540
	elseif _nCell == 1061 then
		fX = 3855
		fY = 1425
	elseif _nCell == 1062 then
		fX = 3955
		fY = 1330
	elseif _nCell == 1063 then
		fX = 3930
		fY = 1175
	elseif _nCell == 1064 then
		fX = 3944
		fY = 990
	elseif _nCell == 9999 then --武将游历
		fX = 520
		fY = 600
	end

	--数据赋值
	tShowData.sImg = sSmallImg -- 小图
	tShowData.w = fW*fGroupScale -- 控件的宽度
	tShowData.h = fH*fGroupScale -- 控件的高度
	tShowData.fDzRw = fDzRw -- 底座的x比例
	tShowData.fDzRh = fDzRh -- 底座的y比例
	tShowData.fBtRw = fBtRw -- 标题宽度的比例
	tShowData.fBtRh = fBtRh -- 标题高度的比例
	tShowData.fLockRw = fLockRw --锁图片的x比例
	tShowData.fLockRh = fLockRh --锁图片的y比例

	--特殊处理
	if (_nCell >= 1001 and _nCell <= 1016) or
		(_nCell >= 1033 and _nCell <= 1048) or 
		 _nCell == 9999 then
		tShowData.x = fX
		tShowData.y = fY
	else
		tShowData.x = fX-fW*fDzRw -- 控件摆放的位置x
		tShowData.y = fY-fH*fDzRh -- 控件摆放的位置y
	end
	tShowData.ox = fX -- 控件摆放的原始位置x
	tShowData.oy = fY -- 控件摆放的原始位置y
	tShowData.fLrm = fLrm -- 左边可点击的比例
	tShowData.fRrm = fRrm -- 右边可点击的比例
	tShowData.fBrm = fBrm -- 下边可点击的比例
	tShowData.fTrm = fTrm -- 上边可点击的比例
	tShowData.fGroupScale = fGroupScale -- 缩放比例

	return tShowData
end

--刚刚解锁的建筑
local tunLockBuilds = {}
--是否在展示解锁动画过程
bShowingUnLockBuild = false
--_tBuildInfos建筑数据列表(table结构)
--_nType：解锁途径：1玩家等级解锁 2王宫等级解锁 3主线任务解锁 4副本解锁
function addShowUnLockedBuild( _tBuildInfos, _nType)
	if B_GUIDE_LOG then
		dump(_tBuildInfos, "添加解锁数据 ")
		print("添加解锁数据 ", _nType)
	end
	-- body
	if not _tBuildInfos or table.nums(_tBuildInfos) <= 0 then
		return
	end
	_nType = _nType or 1 --如果没有类型默认为玩家等级解锁（不做解锁过程动画）
	for n, build in pairs (_tBuildInfos) do
		local bHadInsert = false
		if tunLockBuilds and table.nums(tunLockBuilds) > 0 then
			for k, v in pairs (tunLockBuilds) do
				if v.sTid == build.sTid then --如果存在了。直接插入到列表（.tLists）中
					v.nUnlockType = _nType
					table.insert(v.tLists, build)
					bHadInsert = true
					break
				end
			end
		end

		if not bHadInsert then --没有插入表中，表示是新增的
			local tT = {}
			tT.sTid = build.sTid
			tT.nUnlockType = _nType
			tT.tLists = {}
			table.insert(tT.tLists, build)
			--插入到大表中
			table.insert(tunLockBuilds, 1, tT)
		end
	end

	--判断是否在新手内
	if Player:getNewGuideMgr():getIsInGuide() then
		--把所有非主线任务解锁的建筑全部解锁出来,并且从列表中删除
		if tunLockBuilds and table.nums(tunLockBuilds) > 0 then
			local nSize = table.nums(tunLockBuilds)
			for i = nSize, 1, -1 do
				if tunLockBuilds[i] and tunLockBuilds[i].nUnlockType ~= 3 then --非主线任务的直接解锁
					if B_GUIDE_LOG then
						print("非主线任务的直接解锁!!!!!!!!!!!!!!!!!!!!!")
					end
					--发送消息展示建筑
					local tObj = {}
					tObj.tData = tunLockBuilds[i]
					sendMsg(ghd_show_unlock_build_background_msg,tObj)
					tunLockBuilds[i] = nil
				end
			end
		end
	end
	--判断当前新手步骤是否可以播放
	if Player:getNewGuideMgr():getIsCanPlayBuidopen() then
		--展示解锁提示框
		showUnlockBuildDlg()
	end
end

--获取解锁建筑数据
function getUnLockBuildsData(  )
	return tunLockBuilds
end

--展示解锁提示框
function showUnlockBuildDlg(  )
	-- body
	if bShowingUnLockBuild then --如果正在表现那么直接返回
		return
	end
	if tunLockBuilds and table.nums(tunLockBuilds) > 0 then
		bShowingUnLockBuild = true --标志在展示中
		local nSize = table.nums(tunLockBuilds)
		local tData = tunLockBuilds[nSize]
		tunLockBuilds[nSize] = nil

		local function func(  )

			closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
			sendMsg(ghd_home_show_base_or_world, 1)--切到主界面

			--发送消息展示升级建筑解锁
			local tObject = {}
			tObject.tData = tData
			sendMsg(ghd_unlock_build_msg, tObject)

			--展示屏蔽层
			showUnableTouchDlg(function (  )
				-- body
				--判断解锁提示框是否存在
				local pDlg = getDlgByType(e_dlg_index.unlockbuild)
				if pDlg and pDlg.jumpToShowBuildUnLocked then
					pDlg:stopAllActions()
					--展示解锁动画
					pDlg:jumpToShowBuildUnLocked()
				end
			end)
		end
		showSequenceFunc(e_show_seq.buildopen, func)
	else
		bShowingUnLockBuild = false --强制设置为没表现
		--关闭屏蔽层
		hideUnableTouchDlg(true)

		--显示顺序下一个
		showNextSequenceFunc(e_show_seq.buildopen)
	end
end

return BuildController