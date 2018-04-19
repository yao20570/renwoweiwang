-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-10 17:51:52 星期一
-- Description: 基地中间层（主要是放对联及其其他活动入口）
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemHomeLR = require("app.layer.home.ItemHomeLR")
local WorldTargetLayer = require("app.layer.worldtarget.WorldTargetLayer")
local WorldBattleResultTip = require("app.layer.worldbattle.WorldBattleResultTip")
local HomeBuffsLayer = require("app.layer.home.HomeBuffsLayer")
-- local BeAttackNoticesLayer = require("app.layer.world.BeAttackNoticesLayer")
local HomeTaskLayer = require("app.layer.country.HomeTaskLayer")

local HomeCenterLayer = class("HomeCenterLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nHeight：该层的高度
function HomeCenterLayer:ctor( _nHeight )
	-- body
	self:myInit()
	self.nContentHeight = _nHeight 
	self.nCurChoice = 1
	self:setLayoutSize(display.width, self.nContentHeight)
	parseView("layout_home_center", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeCenterLayer:myInit(  )
	-- body
	self.nContentHeight 		= 0 		--中间层的高度
	self.pCenterView 			= nil 		--中间json层
	self.tItemRight 			= {} 		--右边对联item集合
	self.tItemLeft 				= {} 		--左边对联item集合
	self.tItemDownLeft 				= {} 		--左边下面对联item集合

	self.nItemNeedHeight 		= 85 		--每一个item所需要的高度

	self.tItemRTList            = {}        --右上列表

	self.pHomeBuffs 		    = nil       --buff增益显示
	-- self.tBattleResTips 		= {}		--战斗结果提示
end

--解析布局回调事件
function HomeCenterLayer:onParseViewCallback( pView )
	-- body
	self.pCenterView = pView
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeCenterLayer",handler(self, self.onHomeCenterLayerDestroy))
end

--初始化控件
function HomeCenterLayer:setupViews( )
	-- body
	self.pLayRoot 	 	=		self:findViewByName("default")

	--右边对联
	self.pLayRight 		= 		self:findViewByName("lay_home_c_right")
	--刷新右边对联
	-- self:refreshLayRight()
	--左边对联
	self.pLayLeft 		= 		self:findViewByName("lay_home_c_left")

	--左下对联
	self.pLayDownLeft 		= 		self:findViewByName("lay_home_down_left")
	--进游戏默认刷新一次
	-- self:refreshLayLeft()

	-- -- 被攻击提示层
 --    local pBeAttackNoticesLayer = BeAttackNoticesLayer.new()
 --    self.pLayRoot:addView(pBeAttackNoticesLayer)
 --    self.pBeAttackNoticesLayer = pBeAttackNoticesLayer

	--任务主线层
    local pHomeTaskLayer = HomeTaskLayer.new()
    self.pLayRoot:addView(pHomeTaskLayer)
    self.pHomeTaskLayer = pHomeTaskLayer

    --世界目标层
    local pWorldTargetLayer = WorldTargetLayer.new()
    self.pLayRoot:addView(pWorldTargetLayer)
    self.pWorldTargetLayer = pWorldTargetLayer
    pWorldTargetLayer:setVisible(false)

    --增益buffs显示
    local pHomeBuffsLayer = HomeBuffsLayer.new()
    pHomeBuffsLayer:setPosition(0, self.nContentHeight + 18 - pHomeBuffsLayer:getHeight())
    self.pLayRoot:addView(pHomeBuffsLayer)
    self.pHomeBuffs = pHomeBuffsLayer
end

-- 修改控件内容或者是刷新控件数据
function HomeCenterLayer:updateViews(  )
	--刷新右边对联
	self:refreshLayRight()
	--进游戏默认刷新一次
	self:refreshLayLeft()
	self:refreshLayDownLeft()
	--刷新限时Boss
	self:refreshTLBoss()
end

-- 析构方法
function HomeCenterLayer:onHomeCenterLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HomeCenterLayer:regMsgs( )
	-- body
	
	-- 注册对联刷新消息
	regMsg(self,ghd_refresh_homeitem_msg, handler(self, self.onRefreshLRItem))
	-- 监听一键解锁征收
	regMsg(self, ghd_unlock_one_collect_all, handler(self, self.refreshLayLeft))
	--注册活动刷新消息
	regMsg(self, gud_refresh_activity, handler(self, self.refreshAboutActivity))
	--注册名将刷新消息
	regMsg(self, gud_hero_recommond_cd, handler(self, self.refreshHeroRecommondCd))
	--注册名将刷新消息
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.refreshHeroRecommondCd))
	-- 注册对联红点回调
	-- regMsg(self, gud_refresh_homelr_red, handler(self, self.refreshSpecialSale))
	--注册触发礼包
	regMsg(self, gud_trigger_gift_list_refresh, handler(self, self.refreshTriggerGift))

	--世界战斗结束消息
	regMsg(self, ghd_battle_result, handler(self, self.showBattleResultTx))

	--刷新战斗结果提示条数
	regMsg(self, ghd_refresh_battle_tip, handler(self, self.removeBattleTip))

	--我的世界目标发生变化
	regMsg(self, gud_my_world_target_refresh, handler(self, self.refreshWorldTarget))

	--高度发生变化
	regMsg(self, gud_be_attack_notices_height_refresh, handler(self, self.refreshLayDownLeft))

	--限时Boss
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.refreshTLBoss))
	--决战阿房宫
	regMsg(self, ghd_imperialwar_open_state, handler(self, self.refreshEpw))
	--王者秘藏
	regMsg(self, gud_refresh_nationaltreasure, handler(self, self.refreshGjbk))
	--决战阿房宫入口
	regMsg(self, ghd_close_epw_enter_item, handler(self, self.refreshEpw))
end

-- 注销消息
function HomeCenterLayer:unregMsgs(  )
	-- body
	-- 销毁对联刷新消息
    unregMsg(self, ghd_refresh_homeitem_msg)
    -- 监听一键解锁征收
    unregMsg(self, ghd_unlock_one_collect_all)
    -- 销毁活动刷新消息
    unregMsg(self, gud_refresh_activity)
    -- 销毁名将刷新消息
    unregMsg(self, gud_hero_recommond_cd)
    -- 销毁名将刷新消息
    unregMsg(self, gud_vip_gift_bought_update_msg)
    -- 注册对联红点回调
    -- unregMsg(self, gud_refresh_homelr_red)
    --销毁触发礼包
	unregMsg(self, gud_trigger_gift_list_refresh)
	--世界战斗结束消息
	unregMsg(self, ghd_battle_result)
	--销毁战斗结果提示条数消息
	unregMsg(self, ghd_refresh_battle_tip)
	--我的世界目标发生变化
	unregMsg(self, gud_my_world_target_refresh)
	--高度发生变化
	unregMsg(self, gud_be_attack_notices_height_refresh)
	--限时Boss
	unregMsg(self, gud_tlboss_data_refresh)
	--决战阿房宫
	unregMsg(self, ghd_imperialwar_open_state)
	--王者秘藏
	unregMsg(self, gud_refresh_nationaltreasure)
	--决战阿房宫入口
	unregMsg(self, ghd_close_epw_enter_item)
end


--暂停方法
function HomeCenterLayer:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function HomeCenterLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--战斗结果提示
function HomeCenterLayer:showBattleResultTx(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.tMailMsg then
		--关闭任务引导
		closeGuideTip()
		--如果有提示正在展示就清除
		if self.pBattleResTip then
			self:removeBattleTip()
		end
		--增加提示
		local pBattleResultLayer = WorldBattleResultTip.new()
		self.pLayRoot:addView(pBattleResultLayer, 999)
		local nHeight = 110
		pBattleResultLayer:setOpacity(0)
		pBattleResultLayer:setPosition(-420, nHeight)
		pBattleResultLayer:setData(pMsgObj.tMailMsg, pMsgObj.tMailData)
		self.pBattleResTip = pBattleResultLayer
	end
end

--移除某项提示
--_sPid:邮件id
function HomeCenterLayer:removeBattleTip(sMsgName, pMsgObj)
	-- body
	if self.pBattleResTip then
		self.pBattleResTip:removeFromParent()
		self.pBattleResTip = nil
	end
end

--刷新对联消息回调
function HomeCenterLayer:onRefreshLRItem( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		if nType == 1 then
			self:perDelayToDo(999093, handler(self, self.refreshLayRight))
		elseif nType == 2 then
			self:perDelayToDo(999092, handler(self, self.refreshLayLeft))
		end
	end
end
-- 延迟执行方法，为的是避免重复刷新（其他界面有需要可以将此方法提取到全局去使用）
-- _tag(int): 该action的tag值
-- _callback(function): 回调方法
function HomeCenterLayer:perDelayToDo( _tag, _callback )
	local action = self:getActionByTag(_tag)
	if(action) then
		return
	end
	-- 此处的1.2秒是用64个资源矿点的帧刷新来决定的，相当于64帧即可
	action = cc.Sequence:create(
		cc.DelayTime:create(1.2),
		cc.CallFunc:create(_callback))
	action:setTag(_tag)
	self:runAction(action)
end

--初始化右边对联
function HomeCenterLayer:refreshLayRight(  )
	-- body
	--获得需要展示的item
	local tItemRightDatas = {}
	--活动 （1）默认开启
	if true then
		local tT = {}
		tT.nId = e_index_itemrl.r_hd
		tT.sName = getConvertedStr(1, 10240)
		tT.sIcon = "#v1_img_zjm_hd.png"
		table.insert(tItemRightDatas, tT)
	end
	--福利 （2）默认开启
	if true then
		local tT = {}
		tT.nId = e_index_itemrl.r_fl
		tT.sName = getConvertedStr(1, 10241)
		tT.sIcon = "#v1_img_zjm_fl.png"
		table.insert(tItemRightDatas, tT)
	end
	--商店 （3）默认开启
	if true then

		local tT = {}
		tT.nId = e_index_itemrl.r_sd
		tT.sName = getConvertedStr(1, 10207)
		tT.sIcon = "#v1_img_zjm_shangdian.png"
		table.insert(tItemRightDatas, tT)
	end
	--公告 （4）默认开启
	if true then
		local tT = {}
		tT.nId = e_index_itemrl.r_gg
		tT.sName = getConvertedStr(1, 10242)
		tT.sIcon = "#v1_img_zjm_gg.png"
		table.insert(tItemRightDatas, tT)
	end


	--排序一下
	table.sort(tItemRightDatas, function ( a, b )
		-- body
		return a.nId < b.nId
	end)

	local nIndex = 1
	local nSize = table.nums(tItemRightDatas)
	--重置高度
	self.pLayRight:setLayoutSize(self.pLayRight:getWidth(), self.nItemNeedHeight * nSize - 10)
	for k, v in pairs (tItemRightDatas) do
		local pItem = self.pLayRight:findViewByName("item_home_right_i_" .. nIndex)
		if not pItem then
			 pItem = ItemHomeLR.new(1,v)
			 pItem:setName("item_home_right_i_" .. nIndex)
			 self.pLayRight:addView(pItem)
			 self.tItemRight[nIndex] = pItem
		else
			--存在的话设置当前数据
			pItem:setCurData(v)
		end
		pItem:setVisible(true)
		--计算位置
		local nX = (self.pLayRight:getWidth() - pItem:getWidth()) / 2
		local nY = self.pLayRight:getHeight() - (nIndex * self.nItemNeedHeight) + (self.nItemNeedHeight - pItem:getHeight()) / 2 + 35
		pItem:setPosition(nX,nY)
		nIndex = nIndex + 1
	end
	--隐藏多余的item
	local nItemSize = table.nums(self.tItemRight)
	if nIndex <= nItemSize then
		for i = nIndex, nItemSize do
			local pItem = self.pLayRight:findViewByName("item_home_right_i_" .. i)
			if pItem then
				pItem:setVisible(false)
			end
		end
	end
	
	--动态设置位置
	--右边对联
	self.pLayRight:setPositionY(self:getHeight() - self.pLayRight:getHeight() - 30)

	--免费宝箱
	local nDailyGiftOpenLv=getDailyGiftParam("openBoxLv")
	local tData = Player:getDailyGiftData()
	if Player:getPlayerInfo().nLv>= tonumber(nDailyGiftOpenLv) and tData and not self.nIsAddBx then
		local tT = {}
			tT.nId = e_index_itemrl.r_bx
			tT.sName = getConvertedStr(7, 10186)
			tT.sIcon = "#v1_img_mfbx.png"
			tT.nIconScale = 0.7
			tT.nNameWidth = 86
			if not self.pItemBx then
				self.pItemBx = ItemHomeLR.new(3, tT)
				self.pLayRight:addView(self.pItemBx)
				self.pItemBx:setPosition((self.pLayRight:getWidth()-self.pItemBx:getWidth())/2, -self.pItemBx:getHeight())
			else
				self.pItemBx:setCurData(tT)
			end
			self.nIsAddBx=true

		--请求宝箱数据
		-- SocketManager:sendMsg("checkDailyGiftRes", {}, function(__msg)
		-- 	if __msg.head.state == SocketErrorType.success then
		-- 		if __msg.body then
					
		-- 		end
		-- 	end
			
		-- end)
	end
	--添加特价卖场图标
	self:refreshSpecialSale()
	--添加名将推荐
	self:refreshHeroRecommondCd()
	--添加首充好礼图标
	self:refreshFirstRecharge()
	--添加触发好礼图标
	self:refreshTriggerGift()
	--添加王权征收
	self:refreshRoyaltyCollect()
	self:refreshAttkCity()
end

--刷新活动相关的图标
function HomeCenterLayer:refreshAboutActivity()
	-- body
	self:refreshSpecialSale()
	self:refreshFirstRecharge()
	self:refreshWuWang()
	self:refreshRoyaltyCollect()
	self:refreshAttkCity()
	self:refreshGhostdom()
	self:refreshKingZhou()
end

--添加特价卖场图标
function HomeCenterLayer:refreshSpecialSale( )
	if Player:getActById(e_id_activity.specialsale) then
		--特价卖场
		local tT = {}
		tT.nId = e_index_itemrl.r_mc
		tT.sName = getConvertedStr(7, 10112)
		tT.sIcon = "#v1_img_tjmc.png"
		tT.nIconScale = 0.7
		tT.nNameWidth = 86
		self:addItemRT(tT)
	else
		self:removeItemRT(e_index_itemrl.r_mc)
	end
end

--添加王权征收图标
function HomeCenterLayer:refreshRoyaltyCollect( )
	local pActData = Player:getRoyaltyCollectData()
	if pActData and pActData:isHaveGetAll() == false then
		--特价卖场
		local tT = {}
		tT.nId = e_index_itemrl.r_wq
		tT.sName = getConvertedStr(6, 10643)
		tT.sIcon = "#v1_img_wangquanzhengshou.png"
		tT.nIconScale = 0.7
		tT.nNameWidth = 86
		self:addItemRT(tT)
	else
		self:removeItemRT(e_index_itemrl.r_wq)
	end
end

--添加名将推荐
function HomeCenterLayer:refreshHeroRecommondCd( )
	--全部已购买关闭入口
	local bIsBought3 = Player:getPlayerInfo():getIsBoughtVipGift(3)
	local bIsBought6 = Player:getPlayerInfo():getIsBoughtVipGift(6)
	local bIsBought9 = Player:getPlayerInfo():getIsBoughtVipGift(9)
	if bIsBought3 and bIsBought6 and bIsBought9 then
		self:removeItemRT(e_index_itemrl.r_hc)
		return 
	end
	--有时间就显示，没时间就关闭显示
	local nCd = Player:getPlayerInfo():getHeroRecommondCd()
	-- print("HomeCenterLayer 419",nCd)
	if self.nHeroRecommondCd ~= nCd then
		self.nHeroRecommondCd = nCd
		if self.nHeroRecommondCd > 0 then
			local tT = {}
			tT.nId = e_index_itemrl.r_hc
			tT.sName = getConvertedStr(3, 10521)
			tT.sIcon = "#v1_img_v2_btn_wujiangtuijian.png"
			tT.nIconScale = 1
			tT.nNameWidth = 86
			tT.sBgImg = "ui/daitu.png"
			self:addItemRT(tT)
		else
			self:removeItemRT(e_index_itemrl.r_hc)
		end
	end
end

--添加首充好礼图标
function HomeCenterLayer:refreshFirstRecharge()
	local tActData = Player:getActById(e_id_activity.newfirstrecharge)		--首充好礼
	local tActData2= Player:getActById(e_id_activity.severalrecharge) 		--多次充值	
	if (tActData and tActData.nT ~= 2) or (tActData2 and tActData2:isCanGetRecharge() ~= 2) then
		--首充好礼

		local tT = {}
		tT.nId = e_index_itemrl.r_fc
		tT.sName = getConvertedStr(7, 10245)
		tT.sIcon = "#v1_img_shouchongbaoxiang.png"
		tT.nIconScale = 0.65
		tT.nNameWidth = 86
		self:addItemRT(tT)
		local bIsShowTx=false
		local bIsAct2 = false 	--是否是第二个活动
		--如果有奖励可领,添加特效
		if tActData then
			if tActData:isCanGetRechargeAwa() then
				bIsShowTx=true

			end
		else
			if tActData2 and tActData2:isCanGetRecharge() == 1 then
				bIsShowTx=true
				
			end
			bIsAct2=true
		end
		if bIsShowTx then

			for i=1, #self.tItemRTList do
				local pItem = self.tItemRTList[i]
				if tT.nId == pItem:getId() then
					-- self:stopFcBxAction()
					pItem:showMfbxTx()

					pItem:resetName(getConvertedStr(6,10472))
					break
				end
			end
		else
			
			for i=1, #self.tItemRTList do
				local pItem = self.tItemRTList[i]
				if tT.nId == pItem:getId() then
					if bIsAct2 then --多次首充礼包要显示礼包名
						
						pItem:resetName(getConvertedStr(9,10065)) 
					end
					
					pItem:stopMfbxRockAction()
					break
				end
			end
		end
	else
		self:removeItemRT(e_index_itemrl.r_fc)
	end
end

--添加触发礼包
function HomeCenterLayer:refreshTriggerGift( )
	local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
	if #tTriGiftList > 0 then
		local tT = {}
		tT.nId = e_index_itemrl.r_tg
		tT.sName = getConvertedStr(3, 10524)
		tT.sIcon = "#v1_img_chufalibao.png"
		tT.nIconScale = 0.7
		tT.nNameWidth = 86
		self:addItemRT(tT)
	else
		self:removeItemRT(e_index_itemrl.r_tg)
	end
end

--添加右上角其中一个id
function HomeCenterLayer:addItemRT( tData )
	local bIsNew = true
	for i=1, #self.tItemRTList do
		local pItem = self.tItemRTList[i]
		if tData.nId == pItem:getId() then
			bIsNew = false
			break
		end
	end
	if bIsNew then
		local pItem = ItemHomeLR.new(3, tData)
		self.pLayRight:addView(pItem)
		table.insert(self.tItemRTList, pItem)
		self:updateItemRTListPoses()
	end
end

--移除右上角其中一个id
function HomeCenterLayer:removeItemRT( nId )
	for i=1, #self.tItemRTList do
		local pItem = self.tItemRTList[i]
		if nId == pItem:getId() then
			pItem:removeFromParent(true)
			table.remove(self.tItemRTList,i)
			self:updateItemRTListPoses()
			break
		end
	end
end

--更新右上角列表位置
function HomeCenterLayer:updateItemRTListPoses( )
	local tStartPos = cc.p(-86, self.pLayRight:getHeight()-86/1.7 - 15)
	local nOffsetX = -86
	for i=1,#self.tItemRTList do
		self.tItemRTList[i]:setPosition(tStartPos)
		tStartPos.x = tStartPos.x + nOffsetX 
	end
end


--刷新左边对联（由于左边对联是动态变化的，所以没有初始化 只有实时刷新）
function HomeCenterLayer:refreshLayLeft( )
	-- body
	--获得需要展示的item
	local tItemLeftDatas = {}
	--普通队列 （1）默认开启
	if true then
		local tT = {}
		tT.nId = e_index_itemrl.l_pydl
		tT.sName = getConvertedStr(1, 10244)
		tT.sIcon = "#v1_img_zjm_ptdl.png"
		table.insert(tItemLeftDatas, tT)
	end
	
	--黄金队列（2）
	--判断是否已经开启
	local nHad = Player:getBuildData().nHadSecondQue
	if nHad == 1 then
		local tT = {}
		tT.nId = e_index_itemrl.l_hjdl
		tT.sName = getConvertedStr(1, 10245)
		tT.sIcon = "#v1_img_zjm_hjdl.png"
		table.insert(tItemLeftDatas, tT)
	end
	--判断是否有自动建造（3）
	-- local nAutoBuildCt = Player:getBuildData().nAutoUpTimes
	-- if nAutoBuildCt and nAutoBuildCt > 0 then
	-- 商店开启了就显示自动建造 modified by shulan
	local bIsOpen = getIsReachOpenCon(9, false)
	if bIsOpen then
		local tT = {}
		tT.nId = e_index_itemrl.l_zdjz
		tT.sName = getConvertedStr(1, 10246)
		tT.sIcon = "#v1_img_zjm_zdjz.png"
		table.insert(tItemLeftDatas, tT)
	end
	--判断是否有补充城防（4）
	--先判断是否城门系统开启了
	local pGateBuild = Player:getBuildData():getBuildByCell(e_build_cell.gate) 
	if pGateBuild and pGateBuild.bLocked == false then
		--注释原来的次数判断, 城门开启了就显示入口 modified by shulan
		-- local nAutoRecruitCt = Player:getBuildData().nAutoRecruit
		-- if nAutoRecruitCt and nAutoRecruitCt > 0 then
			local tT = {}
			tT.nId = e_index_itemrl.l_sjbc
			tT.sName = getConvertedStr(1, 10247)
			tT.sIcon = "#v1_img_zjm_sjbc.png"
			table.insert(tItemLeftDatas, tT)
		-- end
	end
	
	--判断是可以一键征收（5）
	--先判断是否已经开启了
	-- local openLv = tonumber(getDisplayParam("oneKeyCollect"))
	-- if Player:getPlayerInfo().nLv >= openLv then
	-- 	--指定任务开启时不可以征收
	-- 	if Player:getPlayerTaskInfo():getLevyResTaskIsUnLock() then
	-- 		local bCanCollect = Player:getBuildData():isCanCollectedFast()
	-- 		if bCanCollect then
	-- 			local tT = {}
	-- 			tT.nId = e_index_itemrl.l_yjzs
	-- 			tT.sName = getConvertedStr(1, 10248)
	-- 			tT.sIcon = "#v1_img_zjm_yjsg.png"
	-- 			table.insert(tItemLeftDatas, tT)
	-- 		end
	-- 	end
	-- end

	--判断是否有美女icon(教你玩)（6）
	local bIsOpen = getIsReachOpenCon(24, false)
	if bIsOpen then
		local tT = {}
		tT.nId = e_index_itemrl.l_jnw
		tT.sName = getConvertedStr(9,10184)
		tT.sIcon = "#v2_img_v2_btn_xinsho.png"
		table.insert(tItemLeftDatas, tT)
	end

	-- local bOpen = Player:getNationalTreasureData():isOpen()
	-- if bOpen then
	-- 	local tT = {}
	-- 	tT.nId = e_index_itemrl.l_gjbk
	-- 	tT.sName = getConvertedStr(1, 10408)
	-- 	tT.sIcon = "#v1_bth_gongchengluedi.png"
	-- 	tT.nIconScale = 0.8
	-- 	table.insert(tItemLeftDatas, tT)
	-- end


	local nIndex = 1
	local nSize = table.nums(tItemLeftDatas)
	--重置高度
	self.pLayLeft:setLayoutSize(self.pLayLeft:getWidth(), self.nItemNeedHeight * nSize)
	for k, v in pairs (tItemLeftDatas) do
		local pItem = self.pLayLeft:findViewByName("item_home_left_i_" .. nIndex)
		if not pItem then
			 pItem = ItemHomeLR.new(2,v)
			 pItem:setName("item_home_left_i_" .. nIndex)
			 self.pLayLeft:addView(pItem)

			 self.tItemLeft[nIndex] = pItem
		else
			--存在的话设置当前数据
			pItem:setCurData(v)
		end
		pItem:setVisible(true)
		--计算位置
		local nX = (self.pLayLeft:getWidth() - pItem:getWidth()) / 2
		local nY = self.pLayLeft:getHeight() - (nIndex * self.nItemNeedHeight) + (self.nItemNeedHeight - pItem:getHeight()) / 2
		pItem:setPosition(nX,nY)
		nIndex = nIndex + 1
	end
	--隐藏多余的item
	local nItemSize = table.nums(self.tItemLeft)
	if nIndex <= nItemSize then
		for i = nIndex, nItemSize do
			local pItem = self.pLayLeft:findViewByName("item_home_left_i_" .. i)
			if pItem then
				pItem:setVisible(false)
				--移除所有特效
				pItem:removeAllTx()
			end
		end
	end
	
	--动态设置位置
	--左边对联
	self.pLayLeft:setPositionY(self:getHeight() - self.pLayLeft:getHeight() - 10)

end

--快捷入口是否展示中
--_nType：1：右 2：左
--_nIndex：e_index_itemrl类型
function HomeCenterLayer:isLRItemShowedByIndex( _nType, _nIndex )
	-- body
	local bShow = false
	if _nType == 1 then
		
	elseif _nType == 2 then
		if self.tItemLeft and table.nums(self.tItemLeft) > 0 then
			for k, v in pairs (self.tItemLeft) do
				local pItemData = v:getCurData()
				if pItemData then
					if pItemData.nId == _nIndex and v:isVisible() then
						bShow = true
						break
					end
				end
			end 
		end
	end
	return bShow
end

--武王讨伐活动数据刷新
function HomeCenterLayer:refreshWuWang( )
	--在世界不显示
	if self.nCurChoice == 1 then
		if self.pLayWuWang then
			self.pLayWuWang:setVisible(false)
		end
	else
		--获取武王讨伐活动数据
		local tWwActivity=Player:getActById(e_id_activity.wuwang)
		local tWwForcast=Player:getActById(e_id_activity.wuwangforcast)
		if (tWwActivity and tWwActivity:isOpen() and getIsReachOpenCon(13,false)) 
			or (tWwForcast and tWwForcast:isOpen() and tWwForcast:getOpenTime()>0 and getIsReachOpenCon(19,false)) then
			if self.pLayWuWang then
				self.pLayWuWang:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_wwtf
				tT.sName = getConvertedStr(9, 10007)
				tT.sIcon = "#v1_btn_zhouwang.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayWuWang = pItem
			end
		else
			if self.pLayWuWang then
				self.pLayWuWang:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end

function HomeCenterLayer:refreshKingZhou( )
	-- body
	if self.nCurChoice == 1 then
		if self.pLayKingZhou then
			self.pLayKingZhou:setVisible(false)
		end
	else
		--获取武王讨伐活动数据
		local pActivity=Player:getActById(e_id_activity.zhouwangtrial)		
		if pActivity and pActivity:isOpen() then
			if self.pLayKingZhou then
				self.pLayKingZhou:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_zwsl
				tT.sName = getConvertedStr(6, 10784)
				tT.sIcon = "#v1_btn_zhouwang.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayKingZhou = pItem
			end
		else
			if self.pLayKingZhou then
				self.pLayKingZhou:setVisible(false)
			end
		end
	end	
	self:refreshLayDownLeft()	
end

--世界任务进行刷新 
function HomeCenterLayer:refreshWorldTarget( )
	if self.nCurChoice == 2 then
		local nIsShow=checkWorldTargetShow()
		if self.pWorldTargetLayer then
			self.pWorldTargetLayer:setVisible(nIsShow)
		end
	else
		if self.pWorldTargetLayer then
			self.pWorldTargetLayer:setVisible(false)
		end
	end
	--刷新列表
	self:refreshLayDownLeft()
end
--攻城掠地数据刷新
function HomeCenterLayer:refreshAttkCity( )
	--在世界不显示
	if self.nCurChoice == 1 then
		if self.pLayAttkCity then
			self.pLayAttkCity:setVisible(false)
		end
	else
		--获取攻城掠地数据
		local tActData=Player:getActById(e_id_activity.attackcity)
		if tActData and getIsReachOpenCon(22,false) then
			if self.pLayAttkCity then
				self.pLayAttkCity:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_gcld
				tT.sName = getConvertedStr(9, 10105)
				tT.sIcon = "#v1_bth_gongchengluedi.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayAttkCity = pItem
			end
		else
			if self.pLayAttkCity then
				self.pLayAttkCity:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end

--限时Boss数据刷新
function HomeCenterLayer:refreshTLBoss( )
	--在主城不显示
	if self.nCurChoice == 1 then
		if self.pLayTLBoss then
			self.pLayTLBoss:setVisible(false)
		end
	else
		local nState = Player:getTLBossData():getCdState()
		if nState ~= e_tlboss_time.no then
			if self.pLayTLBoss then
				self.pLayTLBoss:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_tlboss
				tT.sName = getConvertedStr(3, 10830)
				tT.sIcon = "#v2_btn_bossxin.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayTLBoss = pItem
			end
		else
			if self.pLayTLBoss then
				self.pLayTLBoss:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end

--冥界入侵数据刷新
function HomeCenterLayer:refreshGhostdom( )
	--获取冥界入侵数据
	if self.nCurChoice == 1 then
		if self.pLayGhostdom then
			self.pLayGhostdom:setVisible(false)
		end
	else
		local tActData=Player:getActById(e_id_activity.mingjie)
		if tActData then--and getIsReachOpenCon(22,false) then
			if self.pLayGhostdom then
				self.pLayGhostdom:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_mjrq
				tT.sName = getConvertedStr(9, 10149)
				tT.sIcon = "#v2_bth_mingjie.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayGhostdom = pItem
			end
		else
			if self.pLayGhostdom then
				self.pLayGhostdom:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end

--决战阿房宫入口
function HomeCenterLayer:refreshEpw( )
	--在世界不显示
	if self.nCurChoice == 1 then
		if self.pLayEpw then
			self.pLayEpw:setVisible(false)
		end
	else
		local nCd = Player:getImperWarData():getCloseEnterCd()
		if nCd > 0 then
			if self.pLayEpw then
				self.pLayEpw:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_epw
				tT.sName = getConvertedStr(3, 10959)
				tT.sIcon = "#v1_bth_gongchengluedi.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayEpw = pItem
			end
		else
			if self.pLayEpw then
				self.pLayEpw:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end

--王者秘藏入口
function HomeCenterLayer:refreshGjbk( )
	--在世界不显示
	if self.nCurChoice == 1 then
		if self.pLayGjbk then
			self.pLayGjbk:setVisible(false)
		end
	else
		if Player:getNationalTreasureData():isOpen() then
			if self.pLayGjbk then
				self.pLayGjbk:setVisible(true)
			else
				local tT = {}
				tT.nId = e_index_itemrl.d_l_gjbk
				tT.sName = getConvertedStr(1, 10408)
				tT.sIcon = "#v1_bth_gongchengluedi.png"
				tT.nIconScale=0.89
				local pItem = ItemHomeLR.new(4, tT)
				self.pLayRoot:addView(pItem)
				self.pLayGjbk = pItem
			end
		else
			if self.pLayGjbk then
				self.pLayGjbk:setVisible(false)
			end
		end
	end
	self:refreshLayDownLeft()
end


--刷新列表方式
function HomeCenterLayer:refreshLayDownLeft( )
	local tLayList = {}

	-- --被打提示层
	-- if self.pBeAttackNoticesLayer:isVisible() then
	-- 	table.insert(tLayList, {pUi = self.pBeAttackNoticesLayer, nX = 0, height = self.pBeAttackNoticesLayer:getContentSize().height + 18})
	-- end

	--任务主线层
	table.insert(tLayList, {nBaseYAdd = 10, pUi = self.pHomeTaskLayer, nX = 0, height = self.pHomeTaskLayer:getContentSize().height + 18})

	--世界目标
	if self.pWorldTargetLayer and self.pWorldTargetLayer:isVisible() then
		table.insert(tLayList, {pUi = self.pWorldTargetLayer, nX = 18, height = self.pWorldTargetLayer:getContentSize().height + 45})
	end

	--武王讨伐
	if self.pLayWuWang and self.pLayWuWang:isVisible() then
		table.insert(tLayList, {pUi = self.pLayWuWang, nX = 28, height = self.pLayWuWang:getContentSize().height + 28})
	end
	--攻城掠地
	if self.pLayAttkCity and self.pLayAttkCity:isVisible() then
		table.insert(tLayList, {pUi = self.pLayAttkCity, nX = 28, height = self.pLayAttkCity:getContentSize().height +30 })
	end
	--限时Boss 
	if self.pLayTLBoss and self.pLayTLBoss:isVisible() then
		table.insert(tLayList, {pUi = self.pLayTLBoss, nX = 28, height = self.pLayTLBoss:getContentSize().height +30 })
	end

	--冥界入侵
	if self.pLayGhostdom and self.pLayGhostdom:isVisible() then
		table.insert(tLayList, {pUi = self.pLayGhostdom, nX = 28, height = self.pLayGhostdom:getContentSize().height +30 })
	end

	--决战阿房宫
	if self.pLayEpw and self.pLayEpw:isVisible() then
		table.insert(tLayList, {pUi = self.pLayEpw, nX = 28, height = self.pLayEpw:getContentSize().height +30 })
	end

	--王者秘藏
	if self.pLayGjbk and self.pLayGjbk:isVisible() then
		table.insert(tLayList, {pUi = self.pLayGjbk, nX = 28, height = self.pLayGjbk:getContentSize().height +30 })
	end

	--纣王试炼
	if self.pLayKingZhou and self.pLayKingZhou:isVisible() then
		table.insert(tLayList, {pUi = self.pLayKingZhou, nX = 28, height = self.pLayKingZhou:getContentSize().height +30 })
	end

	local nY = 0
	for i=1,#tLayList do
		local tData = tLayList[i]
		local pUi = tData.pUi
		local nX = tData.nX

		if i == 1 and tData.nBaseYAdd then--针对任务起如位置的特殊设置
			nY = nY + tData.nBaseYAdd
		end
		local nHeight = tData.height
		pUi:setPosition(nX, nY)
		nY = nY + nHeight
	end
end
--跳转到世界或跳转到主界面		1-跳到主界面 2-世界
function HomeCenterLayer:changeToWorldOrBase( _nType)
	-- body
	self.nCurChoice = _nType
	if _nType==1 then
		--右边对联
		self.pLayRight :setVisible(true)
		--左边对联
		self.pLayLeft :setVisible(true)

		--左下对联
		self.pLayDownLeft :setVisible(true)
	else
		--右边对联
		self.pLayRight :setVisible(false)
		--左边对联
		self.pLayLeft :setVisible(false)

		--左下对联
		self.pLayDownLeft :setVisible(true)
	end
	self:refreshWorldTarget()
	self:refreshWuWang()
	self:refreshAttkCity()
	self:refreshTLBoss()
	self:refreshGhostdom()
	self:refreshEpw()
	self:refreshGjbk()
	self:refreshKingZhou()
end

function HomeCenterLayer:getWorldTargetLayer()
	return self.pWorldTargetLayer
end

--获取
function HomeCenterLayer:getHomeTaskLayer( )
	return self.pHomeTaskLayer
end

return HomeCenterLayer