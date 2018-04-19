-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-10 19:38:41 星期一
-- Description: 常态存在层，执行数据的交互
-- 				1.处理常态存在的数据
-- 				2.消息的注册和监听（刷新等操作）
-- 				3.定时监听的行为
-- 				4.任务跳转和界面打开灯行为操作
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
import(".ShowDlgUtils")

local TmpMidLayer = class("TmpMidLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TmpMidLayer:ctor(  )
	-- body
	self:myInit()
	self:setLayoutSize(display.width, display.height)
    self:setVisible(false)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TmpMidLayer",handler(self, self.onTmpMidLayerDestroy))
end

--初始化成员变量
function TmpMidLayer:myInit(  )
	-- body
	--国家相关数据请求协议
	self.tSerDatas = {"loadCountryInfo", 
					  "loadOfficialInfo", 
					  "loadCountryGlory", 
					  "loadCountryCity", 
					  "loadCountryLog", 
					  "LoadCountryTask",
					  "loadCountryTreasureList",
					  "loadMyCountryTreasure",
					  "loadCountryTnoly",
					  "loadcountryhelp",
					  "loadCountryShop"}
	self.tTriggerGiftCd1Prev = {}
	self.bEpwEnterClose = nil
end


--初始化控件
function TmpMidLayer:setupViews( )
	-- body
	if self.nUpdateHandler == nil then
	    self.nUpdateHandler = MUI.scheduler.scheduleGlobal(handler(self, self.updateForTime), 1)
	end
end

-- 修改控件内容或者是刷新控件数据
function TmpMidLayer:updateViews(  )
	if self.pScheduleUpdate == nil then
		self.pScheduleUpdate = MUI.scheduler.scheduleUpdateGlobal(handler(self, self.updateForFrame))
	end
end

--定时刷新
function TmpMidLayer:updateForTime(  )
	-- body

--	--table数据回收
--	if nCollectCnt > 0 then
--		nCollectCnt = nCollectCnt - 1
--		--collectgarbage("collect")
--		if nCollectCnt == 0 then --记录一下最后回收table数据的时间
--			n_last_collect_time = getSystemTime()
--		end
--		-- print("collect:清除回收Table")
--	else
--		local nTime = getSystemTime() - n_last_collect_time
--		local nMaxTime = 60 * 3
--		if nTime > nMaxTime then
--			nCollectCnt = 3
--		end
--	end

	--任务引导指引
	local tTaskIdParam = luaSplit(getGlobleParam("guideFingerLv"), ";")
	local nBeginTaskId = tonumber(tTaskIdParam[1])
	local nEndTaskId = tonumber(tTaskIdParam[2])
	--当前的主线任务
	local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tCurTask and tCurTask.sTid then
		if tCurTask.sTid >= nBeginTaskId and tCurTask.sTid <= nEndTaskId then
			local nNowTime = getSystemTime()
			if not N_LAST_CLICK_TIME then return end
			--时间间隔
			local nGuideTimeGap = tonumber(getGlobleParam("guideFinger"))
			if nNowTime - N_LAST_CLICK_TIME > nGuideTimeGap then
				--战斗界面
				local pFightLayer = Player:getUIFightLayer()
				--正在展示中的对话框
				local tShowingDlgs = getShowingDlgs()
				--判断当前有没有新手手指
	            local isFingerShow = Player:getNewGuideMgr():getIsFingerShow()
				--引导提示
				local pDlg,bNew = getDlgByType(e_dlg_index.taskguidetip)
				if Player.bRealyShowHome and not pFightLayer and table.nums(tShowingDlgs) == 0 and
					not pDlg and not isFingerShow and not B_OVERVIEW_LAYER then
					local tObj = {}
					tObj.bIsShow = true
					sendMsg(ghd_refresh_home_bottom_msg, tObj)
					openGuideTip()
					--重置引导时间
					N_LAST_CLICK_TIME = getSystemTime()
				end
			end
		end
	end
	

	-- 刷新其他地方的数据
	doUpdateControl()

	--能量恢复倒计时
	self:refreshEnergyData()

	--资源征收状态
	self:refreshSuburbColState()

	--刷新募兵操作
	self:refreshRecruitDatas()

	--刷新文官Buff倒计时
	self:refreshOfficalData()

	--刷新特殊副本倒计时
	self:refreshSpFubenData()

	--刷新世界倒计时
	self:refreshWorldData()

	--刷新装备倒计时
	self:refreshEquipData()

	--刷新神兵最新信息
	self:refreshWeaponData()

	--校对研究员倒计时
	self:refreshResercherCD()

	--刷新研究中科技
	self:refreshTnolyUping()

	--刷新募兵令buff倒计时
	self:refreshRecruitBuff()

	--刷新珍宝阁翻牌倒计时
	self:refreshFlipCD()

	--刷新拜将台神将关闭到技术
	self:refreshBuyCloseShenCd()

	--刷新城墙CD倒计时
	self:refreshGateCD()

	--建筑升级队列完成校验
	self:checkBuildUpingLists()

	--刷新登台拜将的物品免费刷新次数
	self:refreshHeroMansionCD()

	--刷新武将培养次数
	self:refreshHeroTrainTimes()
	--刷新建筑升级黄金队列剩余生效时间
	self:refreshBuildSecQueCD()

	--武将推荐cd时间结束
	self:refreshHeroRecommondCd()

    --答题结束关闭红点
    self:refreshExamRedPointState()

	--触发礼包活动cd测试
	self:refreshTriggerGiftCd()

	--校对限时头像框使用时间
	self:refreshTimeBoxCd()

	--倒计时
	self:refreshHeroNailiRecoveCd()
	--新版成长基金限购时间刷新
	self:refreshGrowFoundLimitCd()
	--刷新洗炼铺洗炼cd
	self:refreshRefineCd()
	--隐藏世界限时Boss
	self:refreshDeathTLBoss()
	--刷新资源兑换CD
	self:refreshResChangeCd()

    --刷新战争大厅气泡
   self:refreshWarHallBubble()
   --刷新资源捐献次数恢复cd
	self:refreshDonateRecover()
	--刷新国家宝藏
	self:onRefreshNationalTreasureInfo()
	--刷新决战阿房宫入口关闭cd
	self:refreshEpwCloseEnterCd()
end

--常态帧刷新
function TmpMidLayer:updateForFrame()
    -- 执行聊天数据的分发
    doDelieverChatInfo()
end

--刷新特殊副本倒计时
function TmpMidLayer:refreshSpFubenData()
	
end

--研究中科技
function TmpMidLayer:refreshTnolyUping(  )
	-- body
	--正在研究的科技
	local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	if tUpingTnoly then
		if tUpingTnoly:getUpingFinalLeftTime() <= 0 then
			if self.bHadSend == false then
				self.bHadSend = true
				--发生消息刷新科技相关
				sendMsg(gud_refresh_tnoly_lists_msg)
			end
		else
			self.bHadSend = false
		end
	end
end

--刷新研究员CD
function TmpMidLayer:refreshResercherCD(  )
	-- body
	local nLeftTime = Player:getTnolyData():getCurResearcherCD()
	if Player:getTnolyData().nId and nLeftTime == 0 then
		SocketManager:sendMsg("actionTnoly", {4}, function ( __msg, __oldMsg )
			-- body
			print("研究员Buff效果CD校对，这里以后需要做获得表现")
		end)		
	end	
end

--刷新文官buff倒计时
function TmpMidLayer:refreshOfficalData(  )
	-- body
	local pPalace = Player:getBuildData():getBuildById(e_build_ids.palace) 
	if not pPalace then
		return
	end
	local nLeftTime = pPalace:getOfficalLeftCD()
	if nLeftTime == 0 and pPalace:getOfficalBaseData() then
		SocketManager:sendMsg("refreshOfficalCD", {}, function ( __msg, __oldMsg )
			-- body
			print("文官Buff效果CD校对，这里以后需要做获得表现")
		end)		
	end
end

--刷新能量
function TmpMidLayer:refreshEnergyData( )
	-- body
	local nLeftTime = Player:getPlayerInfo():getEnergyLeftTime() or 0
	if nLeftTime == 0 and Player:getPlayerInfo().nEnergyUT and Player:getPlayerInfo().nEnergyUT > 0 then
		SocketManager:sendMsg("getEnergy", {}, function ( __msg, __oldMsg )
			-- body
			print("能量请求成功，这里以后需要做获得表现")
		end)
	end
end


--刷新登台拜将的物品免费刷新次数
function TmpMidLayer:refreshHeroMansionCD( )	
	local pActData = Player:getActById(e_id_activity.heromansion)
	if not pActData then
		return
	end
	if pActData:isCheckStatus() == true then
		pActData:openCheck()
		SocketManager:sendMsg("freeHeroMansion", {}, function ( __msg, __oldMsg )
			--dump(__msg.body, "freeHeroMansion", 100)
			-- body	
				
			print("校对登台拜将的物品免费刷新次数")
		end)
	end

end

--刷新武将培养次数
function TmpMidLayer:refreshHeroTrainTimes()
	-- body
	local nCd = Player:getHeroInfo():getTrainTime()
	local nTrainCount = Player:getHeroInfo():getTrainCount()
	--cd为0时请求更新武将免费培养次数
	if nCd == -1 and nTrainCount < tonumber(getHeroInitData("trainFreeMax")) then
		SocketManager:sendMsg("renewTrainTimes", {}, function (__msg)
			--dump(__msg.body, "renewTrainTimes", 100)
		end)
	end
end

--刷新建筑升级黄金队列剩余生效时间
function TmpMidLayer:refreshBuildSecQueCD()
	-- body
	local nCd = Player:getBuildData():getBuildBuyFinalLeftTime()
	if nCd == 0 then
		if self.bBuildQueCD then
			--通知基地建筑数据发生变化
			local tObject = {}
			tObject.nType = 1
			sendMsg(gud_build_data_refresh_msg,tObject)
			self.bBuildQueCD = false
		end
	else
		self.bBuildQueCD = true
	end
end

--资源征收状态
function TmpMidLayer:refreshSuburbColState(  )
	-- body
	-- local tSuburbs = Player:getBuildData():getSuburbBuilds()
	-- if tSuburbs and table.nums(tSuburbs) > 0 then
		-- for k, v in pairs(tSuburbs) do
	local tBuildData = Player:getBuildData()
	local nColState = tBuildData:getColState()
	local nLeftTime = tBuildData:getCollectLeftTime()
	if nColState == 0 then --不可征收
		if nLeftTime > tBuildData:getResCollectTime() then --超过可征收时间
			tBuildData:setColState(1)
			--发送消息刷新资源田征收状态
			local tObject = {}
			-- tObject.nCell = v.nCellIndex --建筑格子下标
			sendMsg(ghd_refresh_suburb_state_mulit_msg,tObject)
		end
	elseif nColState == 1 then --已经可以征收了，但是未满
		if nLeftTime > tBuildData:getResCollectTimeMax() then --超过满征收时间
			tBuildData:setColState(2)
			--发送消息刷新资源田征收状态
			local tObject = {}
			-- tObject.nCell = v.nCellIndex --建筑格子下标
			sendMsg(ghd_refresh_suburb_state_mulit_msg,tObject)
		end
	end
end

--刷新募兵操作
function TmpMidLayer:refreshRecruitDatas(  )
	-- body
	--步兵
	local pInfantry = Player:getBuildData():getBuildById(e_build_ids.infantry)
	self:checkRecruit(pInfantry)
	--骑兵
	local pSowar = Player:getBuildData():getBuildById(e_build_ids.sowar)
	self:checkRecruit(pSowar)
	--弓兵
	local pArcher = Player:getBuildData():getBuildById(e_build_ids.archer)
	self:checkRecruit(pArcher)
	--募兵府
	local pMbf = Player:getBuildData():getBuildById(e_build_ids.mbf)
	self:checkRecruit(pMbf)
end

--校验募兵进行中的队列
function TmpMidLayer:checkRecruit( _tCamp )
	-- body
	if _tCamp then
		local tRecruitLists = _tCamp:getRecruitTeams() --获得募兵队列
		if tRecruitLists and table.nums(tRecruitLists) > 0 then
			for k, v in pairs (tRecruitLists) do
				if v.nType == e_camp_item.ing then
					if v:getRecruitLeftTime() <= 0 then
						--发送消息募兵操作
						local tObject = {}
						tObject.nBuildId = _tCamp.sTid
						tObject.nType = 6
						tObject.sId = v.nId
						sendMsg(ghd_recruit_action_msg,tObject)
					end
					break
				end
			end
		end
	end
end

--更新世界
function TmpMidLayer:refreshWorldData( )
	--更新世界任务倒计时（到时间就关掉)
	Player:getWorldData():updateTaskCd()
	--更新世界行军倒计时(到时间就关掉)
	Player:getWorldData():updateTaskMovePushsCd()
	--更新国战列表(到时间就关掉)
	Player:getWorldData():updateMyCountryWarsCd()
	--更新我自己城池列表(到时间就关掉)
	Player:getWorldData():updateMyCityWarsCd()
	--更新友军驻防列表
	Player:getWorldData():updateFriendArmysCd()
	--记录前攻特效
	Player:getWorldData():updateTaskAtkEffect()
	--更新世界Boss的离开(到时间就关掉)
	Player:getWorldData():updateBossLeaveCd()
	--更新世界纣王试炼点的离开(到时间就关掉)
	Player:getWorldData():updateKingZhouLeaveCd()
end

--更新装备
function TmpMidLayer:refreshEquipData(  )
	--更新打造装备倒计时
	Player:getEquipData():updateMakeEquipCd()
end

--请求神兵最新数据
function TmpMidLayer:refreshWeaponData()
	-- body
	local weaponData = Player:getWeaponInfo()
	--获得神兵列表
	local tWeaponList = weaponData:getAllWeaponDatas()
	for nId, info in pairs(tWeaponList) do
		if weaponData:getBuildCDLeftTime(nId) == 0 then
			-- if not self.bHasSendWeapon then
				-- self.bHasSendWeapon = true
				--打造神兵完成后请求新神兵数据
				SocketManager:sendMsg("reqWeaponNewData", {nId})

			-- end
		-- else
			-- self.bHasSendWeapon = false

		
		end
		if weaponData:getAdvCDLeftTime(nId) == 0 then
			--进阶神兵完成后请求
			SocketManager:sendMsg("reqAdvancedWeaponData", {nId})
		end
		--额外暴击CD时间
		if weaponData:getExtraCriticalLeftTime(nId) == 0 then
			sendMsg(gud_show_weapon_extracritical) --通知刷新界面显示神兵额外暴击
		end
	end
end

--刷新募兵令buff倒计时
function TmpMidLayer:refreshRecruitBuff()
	-- body
	local tBuffData = Player:getBuffData()
	local tBuff = tBuffData:getCampBuffList()
	if table.nums(tBuff) > 0 then
		for nId, tBuffVo in pairs(tBuff) do
			if tBuffVo:getRemainCd() == 0 then
				tBuffData:removeBuff(tBuffVo)
				sendMsg(gud_buff_update_msg)
			end
		end
	end
end

--刷新珍宝阁翻牌倒计时
function TmpMidLayer:refreshFlipCD()
	-- body
	local tShopData = Player:getShopData()
	local nCd = tShopData:getFlipCardCd()
	if nCd == 0 then
		if not self.bFlipCD then
			self.bFlipCD = true
			-- sendMsg(ghd_treasure_shop_flip_card_cdchange_msg)
			sendMsg(gud_refresh_activity) --通知刷新界面
			-- 刷新活动红点
			sendMsg(gud_refresh_act_red)			
		end
	else
		self.bFlipCD = false
	end
end

--刷新拜将台神将关闭倒计时
function TmpMidLayer:refreshBuyCloseShenCd()
	-- body
	local tData = Player:getHeroInfo()
	if not tData then
		return
	end
	local nCd = tData:getLeftCloseLiangCd()
	if nCd == 0 then
		if not self.bShenCD then
			self.bShenCD = true
			--关闭神将推演
			tData:closeShen()
			sendMsg(gud_refresh_buy_hero) --通知刷新界面
		end
	else
		self.bShenCD = false
	end
end

--刷新城墙倒计时
function TmpMidLayer:refreshGateCD()
	-- body
	local tBuildGate = Player:getBuildData():getBuildById(e_build_ids.gate)
	if tBuildGate then
		local bShowGateTips = tBuildGate:showRecruitTip()

		if self.bGateCD then
			if self.bGateCD ~= bShowGateTips then
				self.bGateCD=bShowGateTips
				sendMsg(ghd_gate_cdchange_msg)
			end
		else
			self.bGateCD = bShowGateTips
			sendMsg(ghd_gate_cdchange_msg)
		end
	end
	
end

--武将推荐cd时间结束
function TmpMidLayer:refreshHeroRecommondCd( )
	local nCd = Player:getPlayerInfo():getHeroRecommondCd()
	if nCd == 0 then
		sendMsg(gud_hero_recommond_cd)
	end
end

--每日答题
function TmpMidLayer:refreshExamRedPointState()
    local tExamData = Player:getExamData()
    if tExamData:isReadyStart() then
        if tExamData.nActivityCloseLocalTimeStamp < getSystemTime(true) then
            tExamData:setReadyStart(false)
            sendMsg(gud_refresh_activity)
            sendMsg(gud_refresh_act_red)
        end
    end
end

--触发礼包cd时间结束
function TmpMidLayer:refreshTriggerGiftCd( )
	local tCdOver = {}
	local tTriGiftList = Player:getTriggerGiftData():getPlayTpackList()
	local bIsSendMsg = false
	for i=1,#tTriGiftList do
		local nPid = tTriGiftList[i].nPid
		local nGid = tTriGiftList[i].nGid
		local nCd1 = tTriGiftList[i]:getCd()
		if nCd1 <= 0 and tTriGiftList[i]:getCd2() <= 0 then
			table.insert(tCdOver, {nPid = nPid, nGid = nGid})
		end

		--之前的cd1与cd1比较
		if self.tTriggerGiftCd1Prev[nPid] then
			if self.tTriggerGiftCd1Prev[nPid][nGid] and self.tTriggerGiftCd1Prev[nPid][nGid] > 0 and nCd1 <= 0 then
				bIsSendMsg = true
			end
		else
			self.tTriggerGiftCd1Prev[nPid] = {}
		end
		self.tTriggerGiftCd1Prev[nPid][nGid] = nCd1
	end

	--删除数据
	if #tCdOver > 0 then
		for i=1,#tCdOver do
			local nPid = tCdOver[i].nPid
			local nGid = tCdOver[i].nGid
			self.tTriggerGiftCd1Prev[nPid][nGid] = nil
			-- self.tTriggerGiftCd1Prev[nPid] = nil
			Player:getTriggerGiftData():delPlayTpack(nPid, nGid)
		end
		bIsSendMsg = true
	end

	--发送消息
	if bIsSendMsg then
		sendMsg(gud_trigger_gift_list_refresh)
	end
end

--[2012]校对限时头像时间
--MsgType.checkTimeBox = {id = -2012, keys = {}}
function TmpMidLayer:refreshTimeBoxCd(  )
	-- body
	local tActorVo = Player:getPlayerInfo():getActorVo()
	local pBox = Player:getPlayerInfo():getBoxDataById(tActorVo.sB) 
	local pTitle = Player:getPlayerInfo():getTitleDataById(tActorVo.sT)
	if (pBox and pBox.nTime > 0 and pBox:isNeedCheckBoxCd() == true) or 
		(pTitle and pTitle.nTime > 0 and pTitle:isNeedCheckCd() == true) then
		--校对限时头像时间
		SocketManager:sendMsg("checkTimeBox", {})
	end

end

--倒计时检测
function TmpMidLayer:refreshHeroNailiRecoveCd(  )
	local bIsAuto = getIsOpenNailiFill()
	local tCost = luaSplit(getBuildParam("defCost"), ":")
	local nResCostType = tonumber(tCost[1])
	local nResCostValue = tonumber(tCost[2])
	local bIsEnoughFood = getMyGoodsCnt(nResCostType) > nResCostValue
	if bIsAuto and bIsEnoughFood then
		local pBChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
	    if pBChiefData then
	    	if self.pRevTimeRecord then
	        	local nSubCd = getSystemTime() - self.pRevTimeRecord
	        	pBChiefData:setNailiFillCdSub(nSubCd)
	        end
	    end
	end
	self.pRevTimeRecord = getSystemTime()
end

--新版成长基金限购时间刷新
function TmpMidLayer:refreshGrowFoundLimitCd()
	local tActData = Player:getActById(e_id_activity.newgrowthfound)
	if tActData == nil then
		return
	end
	local nCd = tActData:getGrowFoundLimitCd()
	if nCd == 0 then
		if not self.bGrowFoundCD then
			self.bGrowFoundCD = true
			sendMsg(gud_refresh_growthfound) --通知刷新界面
			-- 刷新活动红点
			sendMsg(gud_refresh_act_red)
		end
	else
		self.bGrowFoundCD = false
	end
end

--刷新洗炼铺洗炼cd
function TmpMidLayer:refreshRefineCd()
	-- body
	local nTrainFreeMax = getEquipInitParam("trainFreeMax")
	local nTrainFree = Player:getEquipData():getFreeTrain()
	if nTrainFree < nTrainFreeMax then
		local nCd = Player:getEquipData():getFreeTrainCd()
		if nCd <= 0 then
			SocketManager:sendMsg("refreshEquipFreeTrain", {}, function()
			end)
		end
	end
end

function TmpMidLayer:refreshDeathTLBoss()
	local bIsShowTLBoss = Player:getTLBossData():getIsShowWorldTLBoss()
	if self.bIsShowTLBoss ~= bIsShowTLBoss then
		if self.bIsShowTLBoss == true then --之前的为true,现在为false就进行强制隐藏刷新一下世界
			sendMsg(ghd_hide_world_tlboss)
		end
	end
	self.bIsShowTLBoss = bIsShowTLBoss
end

--建筑升级队列校验
function TmpMidLayer:checkBuildUpingLists( )
	-- body
	local tUpings = Player:getBuildData():getBuildUpdingLists()
	if tUpings and table.nums(tUpings) > 0 then
		for k, v in pairs (tUpings) do
			local fLeftTime, fOverTime = v:getBuildingFinalLeftTime()
			if fLeftTime <= 0 and fOverTime and fOverTime < -3 then
				SocketManager:sendMsg("checkupingBuild", {v.nCellIndex})
			end
		end
	end
end

--刷新资源兑换CD
function TmpMidLayer:refreshResChangeCd()
	local nCnt = Player:getShopData():getResChangeLeftCnt()
	if self.nLastChangeCnt ~= nCnt then
		sendMsg(gud_refresh_merchants)
		self.nLastChangeCnt = nCnt
	end
end

-- 析构方法
function TmpMidLayer:onTmpMidLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function TmpMidLayer:regMsgs( )
	-- 注册根据类型打开某个对话框的消息
	regMsg(self, ghd_show_dlg_by_type, handler(self, self.showDlgByType))
	-- 注册升级建筑的消息
	regMsg(self, ghd_up_build_msg, handler(self, self.upBuild))
	-- 注册物品使用消息
	regMsg(self, ghd_useItems_msg, handler(self, self.useItem))
	-- 注册募兵操作消息
	regMsg(self, ghd_recruit_action_msg, handler(self, self.onActionRecruit))
	-- 注册兵营调整消息
	regMsg(self, ghd_update_camp_msg, handler(self, self.onUpdateCamp))
	-- 注册研究科技消息
	regMsg(self, ghd_uping_tnoly_msg, handler(self, self.upTnoly))
	-- 注册科技操作消息
	regMsg(self, ghd_action_tnoly_msg, handler(self, self.actionTnoly))
	--注册获取其他玩家的消息
	regMsg(self, ghd_get_playerinfo_msg, handler(self, self.getOtherPlayerInfo))
	--注册国家系统开放消息
	regMsg(self, ghd_open_countrysystem_msg, handler(self, self.getDataAboutCountry))
	--注册装备背包已满的事件
	regMsg(self, ghd_equipBag_fulled_msg, handler(self, self.showEquipBagFillde))
	--注册国战请求消息
	regMsg(self, ghd_world_country_war_req_msg, handler(self, self.onWorldCountryWarReq))
	--注册任务跳转消息
	regMsg(self, ghd_task_goto_msg, handler(self, self.onTaskGoto))
	--注册界面跳转消息
	regMsg(self, ghd_jumpto_dlg_msg, handler(self, self.goToDlg))
	--注册打开对话框任务消息
	regMsg(self, ghd_open_dlg_task_msg, handler(self, self.checkOpenDlgTask))
	--注册排行信息清理消息
	regMsg(self, ghd_clear_rankinfo_msg, handler(self, self.clearRankinfo))
	--注册建筑更多操作消息
	regMsg(self, ghd_more_action_build_msg, handler(self, self.moreActionForBuild))
	--注册工坊生产的立即完成操作
	regMsg(self, ghd_atelier_gold_finish_msg, handler(self, self.onAtelierGoldProduce))
	--注册国家荣誉任务数据变化信息
	regMsg(self, ghd_country_honor_prize_change_msg, handler(self, self.onReLoadCountryHonorData))
	--注册城战发起信息
	regMsg(self, ghd_send_city_war_req, handler(self, self.onCityWarReq))
	--注册多条协议发生请求
	regMsg(self, ghd_mulit_proto_list_req, handler(self, self.onMulitProtoReq))
	--注册每日目标引导消息
	regMsg(self, ghd_daily_task_guide_msg, handler(self, self.onDailyTaskGuide))
	--零点的活动推送
	regMsg(self, ghd_zero_act_push, handler(self, self.onZeroActPush))
	--装备加速
	regMsg(self, ghd_speed_make_equip_msg, handler(self, self.onSpeedMakeEquip))

	regMsg(self, ghd_speed_make_equip_msg, handler(self, self.onSpeedMakeEquip))

	regMsg(self, gud_refresh_hero, handler(self, self.onRefreshHeroInfo)) --武将数据发生变化
	regMsg(self, gud_load_chat_data, handler(self, self.onReqChatDataInfo)) --可以请求聊天数据
end

-- 注销消息
function TmpMidLayer:unregMsgs(  )
	-- 销毁根据类型打开某个对话框的消息
	unregMsg(self, ghd_show_dlg_by_type)
	-- 销毁升级建筑的消息
	unregMsg(self, ghd_up_build_msg)
    -- 销毁物品使用消息
	unregMsg(self, ghd_useItems_msg)
	-- 销毁募兵操作消息
	unregMsg(self, ghd_recruit_action_msg)
	-- 销毁兵营调整消息
	unregMsg(self, ghd_update_camp_msg)
	-- 销毁研究科技消息
	unregMsg(self, ghd_uping_tnoly_msg)
	-- 销毁科技操作消息
	unregMsg(self, ghd_action_tnoly_msg)
	--注销获取其他顽疾的消息
	unregMsg(self, ghd_get_playerinfo_msg)
	--注销国家系统开放消息
	unregMsg(self, ghd_open_countrysystem_msg)	
	--注销装备背包已满的事件
	unregMsg(self, ghd_equipBag_fulled_msg)	
	--注销点击国战请求消息
	unregMsg(self, ghd_world_country_war_req_msg)	
	--注销任务跳转
	unregMsg(self, ghd_task_goto_msg)
	--销毁界面跳转消息
	unregMsg(self, ghd_jumpto_dlg_msg)
	--注销打开对话框任务
	unregMsg(self, ghd_open_dlg_task_msg)
	--注销排行信息清理消息
	unregMsg(self, ghd_clear_rankinfo_msg)	
	--注销建筑更多操作消息
	unregMsg(self, ghd_more_action_build_msg)	
	--注销工坊生产的立即完成操作
	unregMsg(self, ghd_atelier_gold_finish_msg)	
	--注销国家荣誉任务数据变化信息
	unregMsg(self, ghd_country_honor_prize_change_msg)	
	--注销城战发起信息
	unregMsg(self, ghd_send_city_war_req)	
	--注销多条协议发生请求
	unregMsg(self, ghd_mulit_proto_list_req)
	--注销每日目标引导消息
	unregMsg(self, ghd_daily_task_guide_msg)
	--注销的活动推送
	unregMsg(self, ghd_zero_act_push)	
    --注销装备加速
	unregMsg(self, ghd_speed_make_equip_msg)
	--武将数据发生变化
	unregMsg(self, gud_refresh_hero) 
	--可以请求聊天数据
	unregMsg(self, gud_load_chat_data) 	
end

--接收消息回调，根据类型打开某个对话框
function TmpMidLayer:showDlgByType( sMsgName, pMsgObj )

	if pMsgObj then
		--获得对话框类型
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		--发送消息隐藏特定层
		-- sendMsgToHideHome(nDlgType)
--		-- 临时处理（为了对话框列表，临时关闭缓存池）
--		updatePoolState(nDlgType)
		--延迟一帧加载
		-- self:performWithDelay(function (  )
			-- body
			if nDlgType >= 1000 and nDlgType <= 1499 then
				showDlgByType1(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 1500 and nDlgType <= 1999 then
				showDlgByType2(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 2000 and nDlgType <= 2499 then
				showDlgByType3(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 2500 and nDlgType <= 2999 then
				showDlgByType4(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 3000 and nDlgType <= 3499 then
				showDlgByType5(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 3500 and nDlgType <= 3999 then
				showDlgByType6(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 4000 and nDlgType <= 4499 then
				showDlgByType7(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 4500 and nDlgType <= 4999 then
				showDlgByType8(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 5000 and nDlgType <= 5499 then
				showDlgByType9(pMsgObj, handler(self, self.onShowDlgCallBack))
			elseif nDlgType >= 5500 and nDlgType <= 5999 then
				showDlgByType10(pMsgObj, handler(self, self.onShowDlgCallBack))
			end
			self:checkOpenDlgTask(nDlgType)

			-- --新增判断是否已经打开，如果当前对话框列表中不存在或者被隐藏了，那么说明需要展示基地
			-- if not checkIfHadShowed(nDlgType) then
			-- 	--发送消息展示隐藏层
   --  			print("33333333333333333消息展示基地")

			-- 	sendMsgToShowHome(nDlgType)
			-- end
		-- end, 0.03)
	end	
end

--打开对话框的回调
function TmpMidLayer:onShowDlgCallBack( nDlgType )
	-- body
	--新增判断是否已经打开，如果当前对话框列表中不存在或者被隐藏了，那么说明需要展示基地
	if not checkIfHadShowed(nDlgType) then
		--发送消息展示隐藏层
		sendMsgToShowHome(nDlgType)
	end
end

--暂停方法
function TmpMidLayer:onPause( )
	-- body
	self:unregMsgs()
	if(self.nUpdateHandler ~= nil) then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateHandler)
	    self.nUpdateHandler = nil
	end

	if(self.pScheduleUpdate ~= nil) then
	    MUI.scheduler.unscheduleGlobal(self.pScheduleUpdate)
	    self.pScheduleUpdate = nil
	end

end

--继续方法
function TmpMidLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--募兵操作消息回调
function TmpMidLayer:onActionRecruit( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		local nBuildId = pMsgObj.nBuildId
		local sId = pMsgObj.sId
		local nNum = pMsgObj.nNum
		if nType == 1 then --加速道具加速
			local nItemId = pMsgObj.nItemId
			SocketManager:sendMsg("recruitAction", {nBuildId,1,sId,nItemId,nNum},handler(self, self.onActionRecruitResponse))
		elseif nType == 2 then --购买并使用加速道具
			local nItemId = pMsgObj.nItemId
			SocketManager:sendMsg("recruitAction", {nBuildId,2,sId,nItemId,nNum},handler(self, self.onActionRecruitResponse))
		elseif nType == 3 then --金币完成
			SocketManager:sendMsg("recruitAction", {nBuildId,3,sId,nil},handler(self, self.onActionRecruitResponse))
		elseif nType == 4 then --取消生产
			SocketManager:sendMsg("recruitAction", {nBuildId,4,sId,nil},handler(self, self.onActionRecruitResponse))
		elseif nType == 5 then --招募完成领取士兵
			SocketManager:sendMsg("recruitAction", {nBuildId,5,sId,nil},handler(self, self.onActionRecruitResponse))
		elseif nType == 6 then --刷新队列
			SocketManager:sendMsg("recruitAction", {nBuildId,6,sId,nil},handler(self, self.onActionRecruitResponse))
		elseif nType == 7 then --免费加速
			SocketManager:sendMsg("recruitAction", {nBuildId,7,sId,nil},handler(self, self.onActionRecruitResponse))
		elseif nType == 8 then --领取所有招募完成队列的士兵
			SocketManager:sendMsg("recruitAction", {nBuildId,8,sId,nil},handler(self, self.onActionRecruitResponse))
		end
	end
end

--请求募兵操作界面回调
function TmpMidLayer:onActionRecruitResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.recruitAction.id then 		--募兵操作
		if __msg.head.state == SocketErrorType.success then
			if __oldMsg and __oldMsg[2] then
				if __oldMsg[2] == 3 then --金币完成
					TOAST(getConvertedStr(1, 10170))
					closeDlgByType(e_dlg_index.buildprop)
				elseif __oldMsg[2] == 4 then --取消生产
					TOAST(getConvertedStr(1, 10163))
				elseif __oldMsg[2] == 1 or __oldMsg[2] == 2 then --道具加速
					TOAST(getConvertedStr(1, 10167))
				elseif __oldMsg[2] == 8 then
					--气泡点击响应
					local nCell = nil
					local nBuildId = __oldMsg[1] 
					if nBuildId == e_build_ids.infantry then
						nCell = e_build_cell.infantry
					elseif nBuildId == e_build_ids.sowar then
						nCell = e_build_cell.sowar
					elseif nBuildId == e_build_ids.archer then
						nCell = e_build_cell.archer
					elseif nBuildId == e_build_ids.mbf then
						nCell = e_build_cell.mbf
					end
					if nCell then
						local tOb = {}
						tOb.nCell = nCell
						sendMsg(ghd_build_bubble_clicktx_msg, tOb)
					end
				end
			end
			--获得士兵数量
			if __msg.body.sd then
				--播放音效
				Sounds.playEffect(Sounds.Effect.soldier)				
				local tItems = {}
				if __oldMsg[1] == e_build_ids.infantry then --步兵
					table.insert( tItems, {k=e_resdata_ids.bb, v=__msg.body.sd})
					--TOAST(getConvertedStr(1, 10162) ..  __msg.body.sd .. getConvertedStr(1, 10081))
				elseif __oldMsg[1] == e_build_ids.sowar then --骑兵
					table.insert( tItems, {k=e_resdata_ids.qb, v=__msg.body.sd})
					--TOAST(getConvertedStr(1, 10162) ..  __msg.body.sd .. getConvertedStr(1, 10082))
				elseif __oldMsg[1] == e_build_ids.archer then --弓兵 
					table.insert( tItems, {k=e_resdata_ids.gb, v=__msg.body.sd})
					--TOAST(getConvertedStr(1, 10162) ..  __msg.body.sd .. getConvertedStr(1, 10083))
				elseif __oldMsg[1] == e_build_ids.mbf then --募兵府
					local tBuildInfo = Player:getBuildData():getBuildById(e_build_ids.mbf)
					local nResId
					if tBuildInfo.nRecruitTp == e_mbf_camp_type.infantry then
						nResId = e_resdata_ids.bb
					elseif tBuildInfo.nRecruitTp == e_mbf_camp_type.sowar then
						nResId = e_resdata_ids.qb
					elseif tBuildInfo.nRecruitTp == e_mbf_camp_type.archer then
						nResId = e_resdata_ids.gb
					end
					table.insert( tItems, {k=nResId, v=__msg.body.sd})
				end
				showGetAllItems(tItems)
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end

--兵营调整消息回调
function TmpMidLayer:onUpdateCamp( sMsgName, pMsgObj  )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		local nBuildId = pMsgObj.nBuildId
		if nType == 1 then --扩建
			SocketManager:sendMsg("updateCamp", {1,nBuildId},handler(self, self.onUpdateCampResponse))
		elseif nType == 2 then --募兵加时
			SocketManager:sendMsg("updateCamp", {2,nBuildId},handler(self, self.onUpdateCampResponse))
		end
	end
end

--请求兵营调整界面回调
function TmpMidLayer:onUpdateCampResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.updateCamp.id then 		--兵营调整
		if __msg.head.state == SocketErrorType.success then			
			if __oldMsg[1] == 1 then --扩充					
				TOAST(getConvertedStr(1, 10166))			
				--播放获取物品动画
				if __msg.body.ob then
					showGetAllItems(__msg.body.ob)
				end
			elseif __oldMsg[1] == 2 then --募兵加时
				TOAST(getTipsByIndex(10068))
			end			
		else
			if __oldMsg[1] == 1 then
		    	TOAST(SocketManager:getErrorStr(__msg.head.state))
		    elseif __oldMsg[1] == 2 then
		    	local nResID = nil
				if __msg.head.state == 233 then --银币不足
					nResID = e_resdata_ids.yb
				elseif __msg.head.state == 231 then--木材不足
					nResID = e_resdata_ids.mc
				elseif __msg.head.state == 232 then--粮草不足
					nResID = e_resdata_ids.lc
				elseif __msg.head.state == 230 then--铁矿不足			
					nResID = e_resdata_ids.bt
				else
					TOAST(SocketManager:getErrorStr(__msg.head.state))	
					return	
				end
				if nResID then
					goToBuyRes(nResID)
				end
		    end
        end
    end
end

--升级建筑消息回调
function TmpMidLayer:upBuild( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		local nBuildId = pMsgObj.nBuildId
		local nBuildCell = pMsgObj.nCell
		local nNum = pMsgObj.nNum
		local nFromWhat = pMsgObj.nFromWhat or 0
		if nType == -1 then --普通升级
			SocketManager:sendMsg("upBuild", {nBuildCell,nBuildId,1,nFromWhat}, handler(self, self.onBuildResponse))
		elseif nType == -2 then --普通升级立即完成
			SocketManager:sendMsg("upBuild", {nBuildCell,nBuildId,2}, handler(self, self.onBuildResponse))
		elseif nType == 1 then --免费加速
			SocketManager:sendMsg("upFastBuild", {nBuildCell,nBuildId,nil,1}, handler(self, self.onBuildResponse))
		elseif nType == 2 then --道具加速
			local nItemId = pMsgObj.nItemId
			SocketManager:sendMsg("upFastBuild", {nBuildCell,nBuildId,nItemId,2,nNum}, handler(self, self.onBuildResponse))
		elseif nType == 3 then --金币完成
			SocketManager:sendMsg("upFastBuild", {nBuildCell,nBuildId,nil,3}, handler(self, self.onBuildResponse))
		elseif nType == 4 then --购买并使用
			local nItemId = pMsgObj.nItemId
			SocketManager:sendMsg("upFastBuild", {nBuildCell,nBuildId,nItemId,4,nNum}, handler(self, self.onBuildResponse))
		end
	end
end

function TmpMidLayer:onSpeedMakeEquip( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		local nOpt = pMsgObj.nOpt or 1
		local nItemId = pMsgObj.nItemId		
		local nNum = pMsgObj.nNum		
		if nType == 1 then --普通升级
			SocketManager:sendMsg("speedMakeEquip", {nItemId,nNum,nOpt}, handler(self, self.onSpeedEquipResponse))
		elseif nType == 2 then --立即完成			
			SocketManager:sendMsg("reqMakeQuickByCoin", {}, handler(self, self.onSpeedEquipResponse))
		end
	end	
end

--建筑更多操作消息毁掉
function TmpMidLayer:moreActionForBuild( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		local nBuildId = pMsgObj.nBuildId
		local nBuildCell = pMsgObj.nCell
		local nRt = pMsgObj.nRt
		local nFromWhat = pMsgObj.nFromWhat or 0
		local nToWhatBuildId = pMsgObj.nToWhatBuildId or 0
		local buildQueueId = pMsgObj.buildQueueId
		local sName = pMsgObj.sName
		if nType == 1 then --拆除
			--判断nBuildCell
			if nBuildCell > n_start_suburb_cell then --资源田
				SocketManager:sendMsg("moreActionBuild", {nBuildCell,nBuildId,1,0,0}, handler(self, self.onBuildResponse))
			end
		elseif nType == 2 then --改建
			SocketManager:sendMsg("moreActionBuild", {nBuildCell, nBuildId, 2, nRt, nToWhatBuildId, buildQueueId, sName}, 
				handler(self, self.onBuildResponse))
		end
	end
end

--建筑请求相关回调
function TmpMidLayer:onBuildResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.upBuild.id then 			--建筑升级
		if __msg.head.state == SocketErrorType.success then
			--关闭升级建筑对话框界面
			local tObject = {}
			tObject.nCell = __oldMsg[1]
			sendMsg(ghd_close_buildup_dlg_msg,tObject)
			local tBuild = nil
			if __oldMsg[1] > n_start_suburb_cell then --郊外资源
				tBuild = Player:getBuildData():getSuburbByCell(__oldMsg[1])
			else 									  --城内建筑
				tBuild = Player:getBuildData():getBuildByCell(__oldMsg[1])
			end
			
			if tBuild then
				if __oldMsg[3] and __oldMsg[3] == 2 then --立即完成是没有推送的
					local sTip = string.format(getConvertedStr(1, 10159),tBuild.sName)
					TOAST(sTip)
					--通知基地建筑状态发生变化
					local tObject2 = {}
					tObject2.nCell = __oldMsg[1]
					sendMsg(gud_build_state_change_msg,tObject2)

					--通知基地建筑升级完成，表现特效
					local tObject3 = {}
					tObject3.nCell = __oldMsg[1]
					sendMsg(ghd_show_buildup_tx_msg,tObject3)
					--总览文字冒泡提示
					local tObject4 = {}
					tObject4.sTip = sTip
					sendMsg(ghd_show_overview_tip,tObject4)
				elseif __oldMsg[3] and __oldMsg[3] == 1 then--普通升级
					Sounds.playEffect(Sounds.Effect.jianzhu)--波峰确定普通升级音效
				else
					TOAST(string.format(getConvertedStr(1, 10158),tBuild.sName))
				end
			end
			
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    elseif __msg.head.type == MsgType.upFastBuild.id then --建筑升级加速请求
		if __msg.head.state == SocketErrorType.success then
			if __oldMsg[4] then
				if __oldMsg[4] == 3 then --金币完成
					closeDlgByType(e_dlg_index.buildprop)
				elseif __oldMsg[4] == 2 or __oldMsg[4] == 4 then --道具使用
					TOAST(getConvertedStr(1, 10167))
				elseif __oldMsg[4] == 1 then --免费加速
					--气泡响应
					local tOb = {}
					tOb.nCell = __oldMsg[1]
					sendMsg(ghd_build_bubble_clicktx_msg, tOb)
					if __msg.body.s then
						TOAST(string.format(getConvertedStr(1, 10235),formatTimeToStr(__msg.body.s,false,true)))
					end
					
				end
			end
			--奖励
			if __msg.body.o then
				print("弹出奖励")
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    elseif __msg.head.type == MsgType.moreActionBuild.id then --建筑更多操作(资源田改建)
		if __msg.head.state == SocketErrorType.success then
			closeDlgByType(e_dlg_index.restructsuburb)
			closeDlgByType(e_dlg_index.restructrecruit)
			if __oldMsg[7] then
				TOAST(string.format(getConvertedStr(7, 10419), __oldMsg[7])) --"xx开始建造"
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end


function TmpMidLayer:onSpeedEquipResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.speedMakeEquip.id then --物品加速
		if __msg.head.state == SocketErrorType.success then
			TOAST(getConvertedStr(1, 10167))
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    elseif __msg.head.type == MsgType.reqMakeQuickByCoin.id then --立即完成
		if __msg.head.state == SocketErrorType.success then			

		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end		
end

--物品使用消息回调
function TmpMidLayer:useItem( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nUseid = pMsgObj.useId
		local nUseNum = pMsgObj.useNum
		local nType = pMsgObj.type
		if nType == 3 then --出售物品			
			local MRichLabel = require("app.common.richview.MRichLabel")
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10091))

		    local titemdata = getBaseItemDataByID(nUseid)
			local tsell = luaSplit(titemdata.sSell, ":")
			local resName = getGoodsByTidFromDB(tonumber(tsell[1])).sName
			local nget = tonumber(tsell[2])*nUseNum			
		    local tStr = {
		    	{color=_cc.pwhite,text=getConvertedStr(6, 10138)},--出售
			    {color=_cc.dblue,text=titemdata.sName.."*"..nUseNum},
			    {color=_cc.pwhite,text=getConvertedStr(6, 10422)},
			    {color=_cc.yellow,text=nget},
			    {color=_cc.pwhite,text=resName..getConvertedStr(6, 10423)},			    
			}
			local pRichLabel = MRichLabel.new({str = tStr, fontSize = 20, rowWidth = 380})
		    pDlg:addContentView(pRichLabel)
		    pDlg:setRightHandler(function (  )
		        SocketManager:sendMsg("useStuff", {nUseid,nUseNum,nType}, handler(self, self.onUseItemResponse))
		        pDlg:closeDlg(false)
		    end)
		    pDlg:showDlg(bNew)									
		else
			--体力判断
			if nUseid == e_id_item.energy then
				local sDropId = getBaseItemDataByID(nUseid).sDropId
				local tDrop = getDropById(sDropId)
				if Player:getPlayerInfo().nEnergy >= tonumber(getGlobleParam("buyEnergy")) then
					TOAST(getTipsByIndex(20145))
					return
				end
				if getIsOverMaxEnergy(tDrop[1].nCt * nUseNum) then
					local DlgAlert = require("app.common.dialog.DlgAlert")
		   	 		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    		if(not pDlg) then
		        		pDlg = DlgAlert.new(e_dlg_index.alert)
		    		end
		    		pDlg:setTitle(getConvertedStr(1,10034))
		    		pDlg:setContent(string.format(getConvertedStr(1, 10392), tonumber(getGlobleParam("maxEnergy"))))
		    		pDlg:setRightHandler(function ()
						SocketManager:sendMsg("useStuff", {nUseid,nUseNum,nType}, handler(self, self.onUseItemResponse))
		        		closeDlgByType(e_dlg_index.alert, false)  
		    		end)
		    		pDlg:showDlg(bNew)
					return
				end
			end
			SocketManager:sendMsg("useStuff", {nUseid,nUseNum,nType}, handler(self, self.onUseItemResponse))
		end
		
	end
end

--物品使用请求回调
function TmpMidLayer:onUseItemResponse( __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		--关闭使用物品对话框
		closeDlgByType(e_dlg_index.useitems)
		--
		closeDlgByType(e_dlg_index.useitemsbytip)	
		--使用完纣王碎片之后关闭兑换窗口
		if __oldMsg and __oldMsg[1] and __oldMsg[1] == e_id_item.zwpiece then
			closeDlgByType(e_dlg_index.dlgusefragments)				
		end
				
		--奖励
		if __msg.body.o and #__msg.body.o > 0 then
			--获取物品效果
			showGetAllItems(__msg.body.o)
		else
			TOAST(getConvertedStr(1, 10167))
		end
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

--研究科技消息回调
function TmpMidLayer:upTnoly( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nId = pMsgObj.nId
		SocketManager:sendMsg("upTnoly", {nId}, handler(self, self.onTnolyResponse))
	end
end

--科技操作消息回调
function TmpMidLayer:actionTnoly( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		SocketManager:sendMsg("actionTnoly", {pMsgObj.nType, pMsgObj.nItemId, pMsgObj.nNum, pMsgObj.nLoc or 2}, handler(self, self.onTnolyResponse))
	end
end

--研究科技请求回调
function TmpMidLayer:onTnolyResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.upTnoly.id then 			--研究科技
		if __msg.head.state == SocketErrorType.success	then
			TOAST(getConvertedStr(1, 10186))
		else		
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	elseif __msg.head.type == MsgType.actionTnoly.id then --科技操作
		if __msg.head.state == SocketErrorType.success	then
			if __oldMsg and __oldMsg[1] then
				if (__oldMsg[1] == 5 or __oldMsg[1] == 6) then--道具加速
					TOAST(getConvertedStr(1, 10167))
				elseif __oldMsg[1] == 2 then--立即完成
					TOAST(getConvertedStr(1, 10183))
				elseif __oldMsg[1] == 3 then--获取科技
					-- 气泡点击响应
					local tOb = {}
					tOb.nCell = e_build_cell.tnoly
					sendMsg(ghd_build_bubble_clicktx_msg, tOb)
			 	end
			end
		else		
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end
	
end

--获取其他玩家信息的消息
function TmpMidLayer:getOtherPlayerInfo(sMsgName, pMsgObj)
	--body
	if pMsgObj and (pMsgObj.nplayerId or pMsgObj.splayerName) then
		local nplayerId = pMsgObj.nplayerId-- or 0
		local sPlayerName = pMsgObj.splayerName
		local bToChat = pMsgObj.bToChat or false
		local nHandler = pMsgObj.nCloseHandler
		SocketManager:sendMsg("getRankPlayerInfo", {nplayerId, sPlayerName}, function ( __msg )
			-- body
			if __msg.head.state == SocketErrorType.success	then
				--print("获取其他玩家数据成功！")
			    --查看玩家数据
			    local SPlayerData = require("app.layer.rank.SPlayerData")
				local temp = SPlayerData.new()
				temp:refreshDatasByService(__msg.body)
				--刷新聊天头像数据				
				Player:recordPlayerCardInfo(temp)						
				--发送玩家排行榜数据消息
				if bToChat then
					if not Player:getFriendsData():isInBlackList(temp.nID) then--不在屏蔽列表中
						if nHandler then
							nHandler()
						end
						Player:getFriendsData():addRecentRecord(temp.nID, temp, 1, true)
						local tObject = {} 
						tObject.nType = e_dlg_index.dlgchat --dlg类型
						tObject.nChatType = e_lt_type.sl --聊天类型
						tObject.tPChatInfo = {
							nPlayerId = temp.nID,
							sPlayerName = temp.sName,
						}							
						sendMsg(ghd_show_dlg_by_type,tObject)
					else
						TOAST(getConvertedStr(6, 10630))
					end
				else
					Player:getFriendsData():addRecentRecord(temp.nID, temp, 1, false)
					if not b_open_ios_shenpi then
						local tObj = {}
						tObj.tplayerinfo = temp
						tObj.tChatData = pMsgObj.tChatData
						showRankPlayerInfo(tObj)
					end
				end
				--sendMsg(ghd_check_playerinfo_msg, tObj)
			else		
				TOAST(SocketManager:getErrorStr(__msg.head.state))
			end			
		end)
	end
end

--请求加载国家相关信息
function TmpMidLayer:getDataAboutCountry( )
	-- body	
	self:reqCountryData(1)
end
--逐条加载国家相关信息
function TmpMidLayer:reqCountryData( idx )
	-- body
	if not idx or idx > #self.tSerDatas then
		return
	end
	local nCurIdx = idx
	local sRequestStr = self.tSerDatas[nCurIdx] 
	if not sRequestStr then
		return
	end
	SocketManager:sendMsg(sRequestStr, {}, function ( __msg )
		-- body		
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType[sRequestStr].id then			
				self:reqCountryData(nCurIdx + 1)
			end
		else
        	TOAST(SocketManager:getErrorStr(__msg.head.state))
    	end
	end)
	
end
--装备背包已满的提示
function TmpMidLayer:showEquipBagFillde()
	-- body
	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
	local pLbTip = MUI.MLabel.new({
		    text = getConvertedStr(6, 10424),
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(410, 100),
		    })	
	setTextCCColor(pLbTip, _cc.pwhite)
    pDlg:addContentView(pLbTip)
    pDlg:getRightButton():updateBtnText(getConvertedStr(6, 10425))
    pDlg:setRightHandler(function (  )
        local tObject = {}
		tObject.nType = e_dlg_index.bag --dlg类型
		tObject.nDefIdx = 2 --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)  
		pDlg:closeAlertDlg()
    end)    
    pDlg:showDlg(bNew)	
end

--世界国战发起
function TmpMidLayer:onWorldCountryWarReq( sMsgName, pMsgObj )
	--等级不足
	local nNeedLv = getWorldInitData("warOpen")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10050), nNeedLv))
		return
	end
	
	local nSysCityId = pMsgObj
	--容错
	if not nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	--容错
	if not tViewDotMsg then
		return
	end

	local tCityData = getWorldCityDataById(nSysCityId)
	if tCityData then
		if tCityData.kind == e_kind_city.ducheng then
			--已经有都城不能打
			local bHasCapital = Player:getWorldData():getIsHasCapital()
			if bHasCapital then
				TOAST(getConvertedStr(3, 10351))
				return
			end

			--官员发起前，非官员不能打
			local bIsAttacked = Player:getWorldData():getSysCityIsMyCountryAtk(nSysCityId)
			if not bIsAttacked then
				local bIsOfficial = false
				local tCountryDataVo = Player:getCountryData():getCountryDataVo()
				if tCountryDataVo then
					bIsOfficial = tCountryDataVo:isOfficial()
				end
				if not bIsOfficial then
					TOAST(getConvertedStr(3, 10350))
					return
				end
			end
		end
	end

	--判断是否是势力城池
	if Player:getPlayerInfo().nInfluence == tViewDotMsg.nDotCountry then
		--确认是否是势力城池是防守方，是就直接请求国战列表
		-- if Player:getWorldData():getSysCityIsMyCountryDef(tViewDotMsg.nSystemCityId) then
		--外显示有国战就直接请求国战列表
		if tViewDotMsg.bIsHasCountryWar then
			SocketManager:sendMsg("reqWorldCountryWarInfo", {nSysCityId}, handler(self, self.onWorldCountryWarInfo))
		else
			--TOAST(getConvertedStr(3, 10099))
			TOAST(getTipsByIndex(20103))
		end
	else
		--正在保护cd时间中
		if tViewDotMsg:getProtectCd() > 0 then
			TOAST(getTipsByIndex(20012))
			return
		end

		--确认是否是势力城池是攻方，是就直接请求国战列表
		-- if Player:getWorldData():getSysCityIsMyCountryAtk(tViewDotMsg.nSystemCityId) then
		--外显示有国战就直接请求国战列表
		if tViewDotMsg.bIsHasCountryWar then
			SocketManager:sendMsg("reqWorldCountryWarInfo", {nSysCityId}, handler(self, self.onWorldCountryWarInfo))
		else
			--二次确认框
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
			if(not pDlg) then
			    pDlg = DlgAlert.new(e_dlg_index.alert)
			end
			pDlg:setTitle(getConvertedStr(3, 10068))
			pDlg:setContent(string.format(getConvertedStr(3, 10069), tViewDotMsg:getDotName() .. getLvString(tViewDotMsg.nDotLv)))
			pDlg:setRightHandler(function (  )
				pDlg:closeAlertDlg()
				SocketManager:sendMsg("reqWorldCountryWar", {nSysCityId}, handler(self, self.onCountryWar))
			end)
			pDlg:showDlg(bNew)
		end
	end
end

--世界国战信息
function TmpMidLayer:onWorldCountryWarInfo( __msg, __oldMsg)
	-- dump(__msg, "TmpMidLayer:onWorldCountryWarInfo", 100)
	if  __msg.head.state == SocketErrorType.success then 
		local nSysCityId = __oldMsg[1]
		--容错
		if not nSysCityId then
			return
		end
		local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
		--容错
		if not tViewDotMsg then
			return
		end
        if __msg.head.type == MsgType.reqWorldCountryWarInfo.id then
        	--判断是否有多国战
			if __msg.body.wars and #__msg.body.wars > 0 then
				--转化为本地数据
				local tCountryWarMsgs = {}
				local CountryWarMsg = require("app.layer.world.data.CountryWarMsg")
				for i=1,#__msg.body.wars do
					table.insert(tCountryWarMsgs, CountryWarMsg.new(__msg.body.wars[i]))
				end
				--倒计时排列
				table.sort(tCountryWarMsgs, function ( a , b )
					return a:getCd() < b:getCd()
				end)

				--发送消息打开dlg
				local tObject = {
				    nType = e_dlg_index.countrywar, --dlg类型
				    --
				    tCountryWarMsgs = tCountryWarMsgs,
				    tViewDotMsg = tViewDotMsg,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			else
				--二次确认框
				local pDlg, bNew = getDlgByType(e_dlg_index.alert)
				if(not pDlg) then
				    pDlg = DlgAlert.new(e_dlg_index.alert)
				end
				pDlg:setTitle(getConvertedStr(3, 10068))
				pDlg:setContent(string.format(getConvertedStr(3, 10069), tViewDotMsg:getDotName() .. getLvString(tViewDotMsg.nDotLv)))
				pDlg:setRightHandler(function (  )
					--关闭自己
					pDlg:closeAlertDlg()
					--请求国战
					SocketManager:sendMsg("reqWorldCountryWar", {tViewDotMsg.nSystemCityId,true}, handler(self, self.onCountryWar))
				end)
				pDlg:showDlg(bNew)
			end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end
--国战返回
function TmpMidLayer:onCountryWar( __msg, __oldMsg )
	-- dump(__msg.body)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCountryWar.id then
        	--请求国战列表
        	local nSysCityId = __oldMsg[1]
        	if nSysCityId then
        		SocketManager:sendMsg("reqWorldCountryWarInfo", {nSysCityId, true}, handler(self, self.onWorldCountryWarInfo))
        		local bIsMe = __oldMsg[2]
				-- if bIsMe then
					local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
					if tViewDotMsg then
						local playerinfo = Player:getPlayerInfo()
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
						local sName=tViewDotMsg:getSysCityOwnerName()
						if sName then
							tData.cn = sName
						else
							tData.cn = getConvertedStr(9,10109)
						end

						autoShareToCountry(e_share_id.countrywar,tData)

				end
        	end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--任务界面跳转
function TmpMidLayer:onTaskGoto( sMsgName, pMsgObj )
	-- body
	if not pMsgObj or not pMsgObj.nTaskID then
		return
	end
	local tTaskData = Player:getPlayerTaskInfo():getTaskDataById(pMsgObj.nTaskID)

	if not tTaskData then 
		return		
	end
	-- dump(tTaskData, "tTaskData", 100)
	local sLinked = tTaskData.sLinked
	-- dump(sLinked, "sLinked ==")
	--任务界面跳转	
	if sLinked then
		local tParam = luaSplit(sLinked, ":")
		local nDlgID = tonumber(tParam[1])
		local tParam2 = luaSplit(tParam[2], "|")
		if pMsgObj.chatper then
			local nMode = tTaskData.nType
			self:jumpToDlg2(nMode, nDlgID, tParam2)
		else
			self:jumpToDlg(1 ,tTaskData.nMode, nDlgID, tParam2, tTaskData.sTid)
		end
	end	
end

function TmpMidLayer:goToDlg(sMsgName, pMsgObj)
	-- body	
	-- dump(pMsgObj.nInterface, "pMsgObj.nInterface ==")
	local sLinked = pMsgObj.nInterface
	if sLinked then
		local tParam = luaSplit(sLinked, ":")
		local nDlgID = tonumber(tParam[1])
		local tParam2 = luaSplit(tParam[2], "|")
		self:jumpToDlg(2, pMsgObj.nMode, nDlgID, tParam2)
	end
end

--简单界面跳转
function TmpMidLayer:jumpToDlg2(nMode, nDlgID, tParam)
	local dlgid = nDlgID
	if dlgid == e_dlg_index.taskhome or dlgid == e_dlg_index.taskworld then
		closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
		sendMsg(ghd_home_show_base_or_world, dlgid - 100)--主城或世界跳转
		--武将游历因为不是建筑，这里调整做特殊处理
		if nMode == e_plot_modes.travel then
			local pObj = {}
			pObj.nCell =  tonumber(tParam[1] or 9999)
			pObj.nBuildId = e_build_ids.house
			sendMsg(ghd_move_to_point_dlg_msg, pObj)
		else
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos			
			pObj.nChildType = 1	
			pObj.nBtnType = e_buildbtn_type.lvup	--任务引导升级按钮	
			pObj.nFunc = function (  )
			-- body
				--如果是科技院先检查一下有没有可以领取的科技, 如果有的话先领取,保证二级菜单可以打开
				if pObj.nCell == e_build_cell.tnoly then
					local tCurTonly = Player:getTnolyData():getUpingTnoly()
					if tCurTonly and tCurTonly:getUpingFinalLeftTime() <= 0 then
						--领取科技
						local tObject = {}
						tObject.nType = 3
						sendMsg(ghd_action_tnoly_msg, tObject)
					end
					pObj.bHadChecked = true
				end
				doDelayForSomething(self, function ()		
					sendMsg(ghd_show_build_actionbtn_msg,pObj)		--打开检出GroupActionlayer				
					
				end, 0.1)
			end
			sendMsg(ghd_move_to_build_dlg_msg, pObj)	--移动到指定建筑位置
		end
	else
		closeAllDlg()
		local tObject = {} 
		tObject.nType = dlgid --dlg类型
		if nMode == e_plot_modes.cdzb then
			tObject.nIndex = tonumber(tParam[1] or 0)
		elseif nMode == e_plot_modes.fuben then
			local id = tonumber(tParam[1] or 0)
			local fuben = Player:getFuben():getLevelById(id)
			--dump(fuben, "fuben", 100)
			if fuben then 
				tObject.tData = fuben.nChapterid or 1
				tObject.nID = fuben.nId
			else
				tObject.tData = 1
			end
			--已开启的最大章节
			local nOpened = Player:getFuben():getNearestOpenChapter()
			--如果要去的章节还没开启就打开已开启的最大章节
			if tObject.tData > nOpened then
				tObject.tData = nOpened
			end
		elseif nMode == e_plot_modes.proarmynum then
			tObject.nBuildId = tonumber(tParam[1] or 0)

		elseif nMode == e_plot_modes.zlts then

		elseif nMode == e_plot_modes.science then --科技
			local nScienceId = tonumber(tParam[1] or 0)
			tObject.nTarScienceId = nScienceId
			if Player:getTnolyData():isInScienceList(nScienceId) == false then--如果当前科技未解锁，则引导至科技树页面
				tObject.tData = Player:getTnolyData():getTnolyByIdFromAll(nScienceId)
				tObject.nType = e_dlg_index.tnolytree
			end
		elseif  nMode == e_plot_modes.yyzb then --科技
			tObject.nIndex = tonumber(tParam[1] or 0)

		elseif  nMode == e_plot_modes.countryfight then --国战

		elseif  nMode == e_plot_modes.cityfight then --城战

		elseif  nMode == e_plot_modes.dzsb then --打造神兵

		elseif  nMode == e_plot_modes.sjsb then --升级神兵
		
		elseif  nMode == e_plot_modes.travel then --武将游历

		elseif  nMode == e_plot_modes.train then --武将培养
			local tHeroList = Player:getHeroInfo():getOnlineHeroList() 
			if tHeroList[1] then
				tObject.tData = tHeroList[1] --当前武将数据
			end
		end
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end



--跳转
function TmpMidLayer:jumpToDlg(nOrg, nMode, nDlgID, tParam, nTaskID)--跳转
	-- body
	-- dump(tParam, "jumpToDlg")
	local dlgid = nDlgID
	if dlgid == e_dlg_index.taskhome or dlgid == e_dlg_index.taskworld then
		--主界面引导，移动到指定建筑位置
		if nMode == e_task_modes.playeruplv then --1主公升级		
			local pObj = {}
			pObj.nType = e_dlg_index.dlgplayerlvup
			sendMsg(ghd_show_dlg_by_type, pObj)
		elseif nMode == e_task_modes.localbuildpos then --99 移动到指定建筑位置
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos			
			pObj.nChildType = 1		
			pObj.nFunc = function (  )
				-- body
			end
			sendMsg(ghd_move_to_build_dlg_msg, pObj)	--移动到指定建筑位置
		elseif nMode == e_task_modes.builduplv or nMode == e_task_modes.buildupfast then --2建筑升级 22建筑立即升级
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos			
			pObj.nChildType = 1	
			pObj.nBtnType = e_buildbtn_type.lvup	--任务引导升级按钮	
			pObj.nFunc = function (  )
				-- body
				--如果是科技院先检查一下有没有可以领取的科技, 如果有的话先领取,保证二级菜单可以打开
				if pObj.nCell == e_build_cell.tnoly then
					local tCurTonly = Player:getTnolyData():getUpingTnoly()
					if tCurTonly and tCurTonly:getUpingFinalLeftTime() <= 0 then
						--领取科技
						local tObject = {}
						tObject.nType = 3
						sendMsg(ghd_action_tnoly_msg, tObject)
					end
					pObj.bHadChecked = true
				end
				doDelayForSomething(self, function ()		
					if nOrg == 1 then
						sendMsg(ghd_task_build_actionbtn_msg,pObj)		--打开检出GroupActionlayer				
					elseif nOrg == 2 then
						sendMsg(ghd_show_build_actionbtn_msg,pObj)		--打开检出GroupActionlayer				
					end
				end, 0.1)
			end
			sendMsg(ghd_move_to_build_dlg_msg, pObj)	--移动到指定建筑位置
											
		elseif nMode == e_task_modes.check then			 --11查看	
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos
			pObj.nFunc = function (  )
				-- body
			end
			sendMsg(ghd_move_to_build_dlg_msg, pObj)
		elseif nMode == e_task_modes.collect then	 --13征收	
			sendMsg(ghd_collect_task_guide_msg)					
		elseif nMode == e_task_modes.buildsuplv then	 --16多个建筑升级				
			local pObj = {}
			pObj.nTaskID = nTaskID
			sendMsg(ghd_builds_task_guide_msg, pObj)
		elseif nMode == e_task_modes.shzb then	 --17收获装备	
			if Player:getEquipData():getIsFinishMakeEquip() then
				local pos = tonumber(tParam[1] or 0)
				local pObj = {}
				pObj.nCell = pos
				pObj.nFunc = function (  )
					-- body
				end
				sendMsg(ghd_move_to_build_dlg_msg, pObj)	
			else
				--dump(tParam, "tParam", 100)
				local pObj = {}
				pObj.nType = e_dlg_index.smithshop
				pObj.nEquipID = tonumber(tParam[2] or 0)
				pObj.nFuncIdx = n_smith_func_type.build
				sendMsg(ghd_show_dlg_by_type,pObj)
			end

		elseif nMode == e_task_modes.xmljnum then	 --19消灭乱军数量	
			-- 定位
	    	sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.wildArmy})
		elseif nMode == e_task_modes.zbnpc then    --20战报npc
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos
			pObj.nBuildId = e_build_ids.house
			sendMsg(ghd_move_to_point_dlg_msg, pObj)
		elseif nMode == e_task_modes.zbg then    --21珍宝阁任务
			local pos = tonumber(tParam[1] or 0)
			local pObj = {}
			pObj.nCell = pos
			pObj.nFunc = function (  )
				-- body
			end
			sendMsg(ghd_move_to_build_dlg_msg, pObj)
		elseif nMode == e_task_modes.xmlj then --4消灭乱军等级			
			if self.nArmyLv ~= tParam[1] then
				self.bEnterAgain = false
			end
			if tParam[1] then
				-- if not self.bEnterAgain and not Player:getWorldData():isGoAheadState() then
				if not Player:getWorldData():isGoAheadState() then
					local nArmyLv = tonumber(tParam[1])
					local nMyBlockType = Player:getWorldData():getMyCityBlockType()
					if nArmyLv >= 11 and nMyBlockType and nMyBlockType <= e_type_block.jun then--目标乱军等级大于等于11
						TOAST(getTipsByIndex(20108))
						return
					else
						self:refreshTaskWildArmy(nTaskID)
						--定位
						sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.wildArmy,
							nDotLv = nArmyLv, bHideFinger = true})
						--乱军头上一直存在的箭头
						--乱军等级大于或等于8级不再显示箭头指示。
						if nArmyLv < 8 then
							sendMsg(ghd_wildarmy_circle_effect, {nDotLv = nArmyLv})
						end
						if self.nArmyLv == tParam[1] then
							self.bEnterAgain = true
						end
						self.nArmyLv = tParam[1]
					end					
				end									
			end
		elseif nMode == e_task_modes.countryfight then--参与国战			
			--开启判断
			local bIsOpen = getIsReachOpenCon(3)
			if bIsOpen then
				local nCityKind = tonumber(tParam[1])
				local pCityData = Player:getWorldData():getCountryFightTaskPos(nCityKind)
				if pCityData then
					sendMsg(ghd_world_location_dotpos_msg, {nX = pCityData.tCoordinate.x, nY = pCityData.tCoordinate.y, isClick = true})	
				else
					TOAST(getConvertedStr(6, 10540))
				end
			end			
		elseif nMode == e_task_modes.worldtarget then --世界目标
			-- local bIsOpen = getIsReachOpenCon(3)
			-- if not bIsOpen then
			-- 	return
			-- end					
			-- local nCityKind = tonumber(tParam[1])
			-- local pCityData = Player:getWorldData():getCountryFightTaskPos(nCityKind)
			-- if pCityData then
			-- 	sendMsg(ghd_world_location_dotpos_msg, {nX = pCityData.tCoordinate.x, nY = pCityData.tCoordinate.y, isClick = true})	
			-- else
			-- 	TOAST(getConvertedStr(6, 10540))
			-- end	
			local tObj = {}
			tObj.nType = e_dlg_index.worldtarget
			sendMsg(ghd_show_dlg_by_type, tObj)
		end
		closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
		sendMsg(ghd_home_show_base_or_world, dlgid - 100)--主城或世界跳转		
	else 	--打开对应功能模块
		local tObject = {} 
		tObject.nType = dlgid --dlg类型
		if nMode == e_task_modes.proarmy then --3生产兵种
			tObject.nBuildId = tonumber(tParam[1] or 0)
			tObject.bNewGuide = true
		elseif nMode == e_task_modes.xmlj then --4消灭乱军等级
			
		elseif nMode == e_task_modes.gytj then --5雇佣铁匠
			local nemploytype = tonumber(tParam[1] or 0)
			tObject.nEmployType = nemploytype
		elseif nMode == e_task_modes.zfsc then --6作坊生产

		elseif nMode == e_task_modes.fuben or nMode == e_task_modes.fubenfast then --7副本
			local id = tonumber(tParam[1] or 0)
			local fuben = Player:getFuben():getLevelById(id)
			--dump(fuben, "fuben", 100)
			if fuben then 
				tObject.tData = fuben.nChapterid or 1
				tObject.nID = fuben.nId
			else
				tObject.tData = 1
			end
			--已开启的最大章节
			local nOpened = Player:getFuben():getNearestOpenChapter()
			--如果要去的章节还没开启就打开已开启的最大章节
			if tObject.tData > nOpened then
				tObject.tData = nOpened
			end		
		elseif nMode == e_task_modes.science then --8科技			
			local tCurTonly = Player:getTnolyData():getUpingTnoly()
			--如果有可领取的科技定位到建筑, 不做任何处理
			if tCurTonly and tCurTonly:getUpingFinalLeftTime() <= 0 then
				local pObj = {}
				pObj.nCell = e_build_cell.tnoly			
				pObj.nChildType = 1
				pObj.nFunc = function ()
					-- body
				end
				closeDlgByType(e_dlg_index.dlgtask)
				sendMsg(ghd_move_to_build_dlg_msg, pObj)	--移动到指定建筑位置
				return
			else
				local nScienceId = tonumber(tParam[1] or 0)
				tObject.nTarScienceId = nScienceId
				if Player:getTnolyData():isInScienceList(nScienceId) == false then--如果当前科技未解锁，则引导至科技树页面
					tObject.tData = Player:getTnolyData():getTnolyByIdFromAll(nScienceId)
					tObject.nType = e_dlg_index.tnolytree
				end
			end
		elseif nMode == e_task_modes.guoqi then   --9国器		

		elseif nMode == e_task_modes.zxrw then   --10完成支线任务
			tObject.nIndex = 1
		elseif nMode == e_task_modes.djzb then	 --12打造装备
			tObject.nEquipID = tonumber(tParam[1] or 0)
		elseif nMode == e_task_modes.cdzb then	 --14穿戴装备	
			--dump(tParam, "tParam", 100)
			tObject.nIndex = tonumber(tParam[1] or 0)			
		elseif nMode == e_task_modes.recruit then	 --15招募 		
			local id = tonumber(tParam[1] or 0)
			local fuben = Player:getFuben():getLevelById(id)
			if fuben then 
				tObject.tData = fuben.nChapterid or 1
				tObject.nID = fuben.nId
			else
				tObject.tData = 1
			end		
		elseif nMode == e_task_modes.wjsz then	 --18武将上阵	

		elseif nMode == e_task_modes.proarmynum then --26募兵数量
			tObject.nBuildId = tonumber(tParam[1] or 0)
			tObject.bNewGuide = true
		end
		--要去到强化和洗炼功能的
		if dlgid == e_dlg_index.refineshop then
			tObject.nType = e_dlg_index.smithshop --dlg类型
			tObject.nFuncIdx = tonumber(tParam[1])
		end
		sendMsg(ghd_show_dlg_by_type,tObject)		
	end	
end

--检查打开对话框任务
function TmpMidLayer:checkOpenDlgTask(param1, param2)
	-- body
	local nDlgType = param2 or param1
	if not nDlgType then
		return
	end		
	local tAgency = Player:getPlayerTaskInfo():checkOpenDlgTask(nDlgType)	
	if tAgency then--查看任务
		SocketManager:sendMsg("finishTask", {tAgency.sTid})		
	end
end
--每日目标引导
function TmpMidLayer:onDailyTaskGuide( sMsgName, pMsgObj )
	-- body	
	local tParam = luaSplit(pMsgObj.sLinked, ":")
	--dump(tParam, "tParam", 100)
	local dlgid = tonumber(tParam[1] or 0)
	local nCell = tonumber(tParam[2] or 0)
	if dlgid == e_dlg_index.taskhome or dlgid == e_dlg_index.taskworld then
		closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
		sendMsg(ghd_home_show_base_or_world, dlgid - 100)--主城或世界跳转
		if nCell ~= 0 then
			local pObj = {}
			pObj.nCell = nCell			
			pObj.nChildType = 1		
			sendMsg(ghd_move_to_build_dlg_msg, pObj)	--移动到指定建筑位置		
		end
	else
		local tObject = {} 
		tObject.nType = dlgid --dlg类型	
		if dlgid == e_dlg_index.camp and nCell ~= 0 then
			tObject.nBuildId = nCell
		elseif dlgid == e_dlg_index.smithshop then
			tObject.nFuncIdx = nCell
		end	
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--工坊立即完成耗时最短队列
function TmpMidLayer:onAtelierGoldProduce( )
	-- body
	SocketManager:sendMsg("atelierSpeedFinished", {})
end

--清理排行数据
function TmpMidLayer:clearRankinfo(  )
	-- body
	Player:getRankInfo():clearRankInfo()
end

--响应玩家数据推送
function TmpMidLayer:onReLoadCountryHonorData(  )
	-- body
	--打开对话框请求国家荣誉数据
	SocketManager:sendMsg("loadCountryGlory", {})
end

--发起城战请求
function TmpMidLayer:onCityWarReq( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if not tViewDotMsg then
		return
	end

	--如果是目标城池是自己且自己被打
	if tViewDotMsg:getIsMe() and Player:getWorldData():getOtherIsAttackMe() then
		--不拦截请求
	else
		--等级不足
		local nNeedLv = getWorldInitData("castkeWarOpen")
		if Player:getPlayerInfo().nLv < nNeedLv then
			TOAST(string.format(getConvertedStr(3, 10101), nNeedLv))
			return
		end
	end
	self.tViewDotMsg = tViewDotMsg
	SocketManager:sendMsg("reqWorldCityWarInfo", {tViewDotMsg.nCityId}, handler(self, self.onWorldCityWarInfo))
end

--发起城战返回
function TmpMidLayer:onWorldCityWarInfo( __msg  )
	--发起单个城战
	local function showCityWarSingle()
		if not self.tViewDotMsg then
			return
		end
		--如果是同势力就不发起城战
    	if Player:getPlayerInfo().nInfluence == self.tViewDotMsg.nDotCountry then
    		TOAST(getTipsByIndex(20093))
    	else
			--发送消息打开dlg
			local tObject = {
			    nType = e_dlg_index.citydetail, --dlg类型
			    nIndex = 1,
			    tViewDotMsg = self.tViewDotMsg,
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
	end

	--dump(__msg.body)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCityWarInfo.id then
        	--多人战检测
        	if (__msg.body.wars and #__msg.body.wars > 0 ) or __msg.body.gw then
        		if (not __msg.body.wars or #__msg.body.wars <= 0) and Player:getPlayerInfo().nInfluence ~= self.tViewDotMsg.nDotCountry then   --只有冥界的数据，不能妨碍城战的进行
        			showCityWarSingle()
        		else
	        		openDlgCityWar(__msg.body,self.tViewDotMsg)
	        	end
    --     		local tCityWarMsgs = {}
				
				
    --     		if (__msg.body.wars and #__msg.body.wars > 0 ) then
				-- 	--转成本地数据
				-- 	local CityWarMsg = require("app.layer.world.data.CityWarMsg")
				-- 	for i=1,#__msg.body.wars do
				-- 		local tData={}
				-- 		tData.nType = 1   --类型1代表普通城战
				-- 		tData.tWarData = CityWarMsg.new(__msg.body.wars[i])
				-- 		-- table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
				-- 		table.insert(tCityWarMsgs, tData)
				-- 	end
				-- end
				-- if __msg.body.gw then
				-- 	local GhostWarVO = require("app.layer.world.data.GhostWarVO")
				-- 	local tData={}
				-- 	tData.nType = 2   --代表冥王入侵
				-- 	tData.tWarData = GhostWarVO.new(__msg.body.gw)
				-- 	-- table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
				-- 	table.insert(tCityWarMsgs, tData)
				-- end

				-- --倒计时排列
				-- table.sort(tCityWarMsgs, function ( a , b )
				-- 	return a.tWarData:getCd() < b.tWarData:getCd()
				-- end)

				-- --发送消息打开dlg
				-- local tObject = {
				--     nType = e_dlg_index.citywar, --dlg类型
				--     --
				--     tCityWarMsgs = tCityWarMsgs,
				--     tViewDotMsg = self.tViewDotMsg
				-- }
				-- sendMsg(ghd_show_dlg_by_type, tObject)
			else
				--单人战
				showCityWarSingle()
			end
        end
    elseif __msg.head.state == SocketErrorType.no_citywar then 
    	--单人战
    	showCityWarSingle()
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--逐条加载协议
--{{sProto = "xxxx", tParam = {} }}
function TmpMidLayer:onMulitProtoReq( sMsgName, pMsgObj )
	if not pMsgObj then
		return
	end
	self.tMulitReqData = pMsgObj
	self:onReqProto(1)
end

--加载协议
function TmpMidLayer:onReqProto( idx )
	-- body
	if not idx then
		return
	end
	local nCurIdx = idx
	if not self.tMulitReqData[nCurIdx] then
		return
	end
	local sProto = self.tMulitReqData[nCurIdx].sProto
	if not sProto then
		return
	end
	local tParam = self.tMulitReqData[nCurIdx].tParam
	local nFunc = self.tMulitReqData[nCurIdx].nFunc
	SocketManager:sendMsg(sProto, tParam , function ( __msg )
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType[sProto].id then
				self:onReqProto(nCurIdx + 1)
				if nFunc then
					nFunc()
				end
			end
		else
        	TOAST(SocketManager:getErrorStr(__msg.head.state))
    	end
	end)
	
end

--刷新任务乱军
function TmpMidLayer:refreshTaskWildArmy( _nTaskId )
	-- body
	if not _nTaskId then
		return 
	end
	if Player:getWorldData():isCanReqTaskWildArmy(_nTaskId) then
		SocketManager:sendMsg("reqTaskWildArmy", {_nTaskId})
	end
end
--监听零点活动推送
function TmpMidLayer:onZeroActPush(  )
	-- body
	local tWwData = Player:getActById(e_id_activity.wuwang)
	if tWwData then
		tWwData:setZeroPush(true)
	end
end
--武将数据发生变化
function TmpMidLayer:onRefreshHeroInfo(  )
	-- body
	local tActData = Player:getActById(e_id_activity.herocollect)
	if tActData then
		tActData:setRewardState()
		sendMsg(gud_refresh_activity)
	end
end

--国家宝藏发生变化
function TmpMidLayer:onRefreshNationalTreasureInfo(  )
	-- body
	local tData = Player:getNationalTreasureData()
	if tData and tData:isOpen() then
		local nTime = tData:getLeftTime()
		if nTime <= 0 then
			SocketManager:sendMsg("asknationaltreasure", {},function() end) 
		end
	end
end

--请求聊天数据发生变化
function TmpMidLayer:onReqChatDataInfo(  )
	-- body
	SocketManager:sendMsg("loadChatData", {})
end


--战争大厅刷新气泡
local tFirstBubbleId = 0
function TmpMidLayer:refreshWarHallBubble()
    
    local tWarHallData = Player:getWarHall()
    local warHallList = tWarHallData:newListByType(1)  
    -- 显示气泡优先级排序
    table.sort(warHallList, function(a, b) 
        if a.nPriority == b.nPriority then
            return a.nId > b.nId
        end
        return a.nPriority < b.nPriority
    end)
    --print("\n=============>")
    -- 按优先等级取第一个气泡
    for k, v in pairs(warHallList) do
        if v:isShowBuildingBubble() == true then
            if tFirstBubbleId ~= v.nId then
                tFirstBubbleId = v.nId
                sendMsg(gud_war_hall_refresh)                                
            end 
            return           
        end
    end	
end

--刷新资源捐献次数恢复cd
function TmpMidLayer:refreshDonateRecover()
	-- body
	local pCountryTnolyData = Player:getCountryTnoly()
	if pCountryTnolyData == nil then
		return
	end
	
	local nCd = pCountryTnolyData:getRecoverDonateLeftTime()
	local nLeftCount = pCountryTnolyData.nLeftDonate
	--请求更新资源捐献次数
	if nCd == 0 and nLeftCount < tonumber(getCountryParam("donateLimit")) then
		SocketManager:sendMsg("reqDonateRecover", {}, function (__msg)
			-- dump(__msg.body, "reqDonateRecover", 100)
		end)
	end
end

--刷新决战阿房宫入口关闭cd
function TmpMidLayer:refreshEpwCloseEnterCd(  )
	local bIsClose = false
	local nCd = Player:getImperWarData():getCloseEnterCd()
	if nCd > 0 then
		bIsClose = false
	else
		bIsClose = true
	end
	if self.bEpwEnterClose ~= bIsClose then
		self.bEpwEnterClose = bIsClose
		if bIsClose == true then
			sendMsg(ghd_close_epw_enter_item)
		end
	end
end


return TmpMidLayer