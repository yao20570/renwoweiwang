-- ItemKingAward.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-10-31 15:15:18
-- 七日为王活动奖励项
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemKingAward = class("ItemKingAward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemKingAward:ctor(_index)
	self.nIndex = _index
	--解析
	parseView("item_king_awards", handler(self, self.onParseViewCallback))
	--注册析构方法
	self:setDestroyHandler("ItemKingAward",handler(self, self.onItemKingAwardDestroy))	
end

--解析布局回调事件
function ItemKingAward:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemKingAward:setupViews( )
	self.pLayRoot = self:findViewByName("item_king_awards")
	--lb
	self.pLbTitle = self:findViewByName("lb_title")

	--img
	self.pImgState    = self:findViewByName("img_state")

	--滚动列
	self.pLayAwards   = self:findViewByName("lay_awards")
	self.pLyBtn  = self:findViewByName("lay_btn")
	local pBtnGet = getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	pBtnGet:setIsPressedNeedScale(false)
	self.pBtnGet = pBtnGet

	--进度
	self.pLbProgress = MUI.MLabel.new({text = "", size = 20})
	self.pLayRoot:addView(self.pLbProgress, 10)
	self.pLbProgress:setPosition(self.pLyBtn:getPositionX()+self.pLyBtn:getWidth()/2, 
		self.pLyBtn:getPositionY()+self.pLyBtn:getHeight()+15)
end

--设置数据 _data
function ItemKingAward:setCurData(_tData, _nIdx, _tAct)
	if not _tData then
		return
	end
	self.pData = _tData or {}
	self.nActIdx = _nIdx
	self.nTarget = self.pData.a --领取奖励的目标数量
	--标题
	if self.pData.sTitle then
		self.pLbTitle:setString(self.pData.sTitle)
	end

	--奖励列表
	local tAwards = getRewardItemsFromSever(self.pData.b)
	gRefreshHorizontalList(self.pLayAwards, tAwards)

	--奖励状态
	-- local nState, nHasReach, nTar = _tAct:getStateByIdx(_nIdx, self.nTarget, self.nIndex)
	local nState, nHasReach, nTar = self.pData.nState, self.pData.nHasReach, self.pData.nTar
	--未达到
	if nState == e_award_state.not_reach then
		self.pImgState:setCurrentImage("#v2_fonts_weidadao.png")
		self.pImgState:setVisible(true)
		self.pBtnGet:setVisible(false)
	--前往
	elseif nState == e_award_state.go_ahead then
		self.pBtnGet:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtnGet:updateBtnText(getConvertedStr(7, 10170)) --前往
		self.pBtnGet:setVisible(true)
		self.pImgState:setVisible(false)
	--可领取
	elseif nState == e_award_state.can_get then
		self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
		self.pBtnGet:updateBtnText(getConvertedStr(7, 10086)) --领取
		self.pBtnGet:setVisible(true)
		self.pImgState:setVisible(false)
		nHasReach = nTar or self.pData.a
	--已领取
	elseif nState == e_award_state.has_got then
		self.pImgState:setCurrentImage("#v2_fonts_yilingqu.png")
		self.pImgState:setVisible(true)
		self.pBtnGet:setVisible(false)
		nHasReach = nTar or self.pData.a
	end

	--重置进度
	if nHasReach then
		local nItemTar
		nItemTar = nTar or self.pData.a
		local sTip = {
			{text = getConvertedStr(7, 10219), color = _cc.pwhite},
			{text = nHasReach, color = _cc.pwhite},
			{text = "/"..formatCountToStr(nItemTar), color = _cc.pwhite},
		}
		self.pLbProgress:setString(sTip)
	end
end

--设置按钮点击回调
function ItemKingAward:setClickedCallBack( _handler )
	-- body
	self._nBtnClickHandler = _handler
end

function ItemKingAward:onGetClicked(pView)
	-- body
	if self._nBtnClickHandler then
		self._nBtnClickHandler()
	end

	if self.pBtnGet:getBtnText() == getConvertedStr(7, 10170) then 	--前往
		if self.nActIdx == e_sevenking_index.level then
			local bIsOpen = getIsReachOpenCon(2)
			if not bIsOpen then
				return
			end
			local tObject = {}
			tObject.nType = e_dlg_index.fubenmap 	--跳到副本
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.nActIdx == e_sevenking_index.killarmy or self.nActIdx == e_sevenking_index.cityfight then
			local bIsOpen = getIsReachOpenCon(4, true)
			if not bIsOpen then
				return
			end
			sendMsg(ghd_home_show_base_or_world, 2) --跳到世界
		elseif self.nActIdx == e_sevenking_index.tnolyup then
			local tBuildInfo = Player:getBuildData():getBuildByCell(e_build_cell.tnoly)
			if tBuildInfo and tBuildInfo:getIsLocked() then
				local tBuildData = getBuildDatasByTid(e_build_ids.tnoly)
				if tBuildData then
					TOAST(getConvertedStr(7, 10149))
				end
				return
			end
			local tObject = {}
			tObject.nType = e_dlg_index.tnolytree 	--跳转到科技树界面, 相对应的科技
			tObject.tData = getGoodsByTidFromDB(self.nTarget)
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.nActIdx == e_sevenking_index.kikkboss then
			local tAct = Player:getActById(e_id_activity.wuwang)
			if tAct == nil then
				TOAST(getConvertedStr(7, 10216))
				return
			end
			local tObject = {}
		    tObject.nType = e_dlg_index.wuwang 	--跳到武王伐纣活动
		    -- tObject.nTabIndex = 3
		    sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.nActIdx == e_sevenking_index.equip then
			if showBuildOpenTips(e_build_ids.tjp) == false then
				TOAST(getConvertedStr(7, 10217))
				return
			end		
			local nQualityMax = getEquipQualityMax()
			local nQualityLock = 1
			for i=1, nQualityMax do
				local bIsLock = true
				local tEquipDatas = getEquipsInSmith(i)
				for j=1,#tEquipDatas do
					if Player:getPlayerInfo().nLv >= tEquipDatas[j].nMakeLv then
						bIsLock = false
						break
					end
				end
				if bIsLock then
					nQualityLock = i
					break
				end
			end
			if self.pData.nQuality >= nQualityLock then--对应品质装备未解锁
				TOAST(getConvertedStr(6, 10597))
				return
			end
			--计算对应品质装备
			local tEquipDatas = getEquipsInSmith(self.pData.nQuality)
			local nEquipID = nil
			for j=1,#tEquipDatas do
				if e_type_equip.weapon == tEquipDatas[j].nKind then
					nEquipID = tEquipDatas[j].sTid
				end
			end			
			--dump(tEquipDatas, "tEquipDatas", 100)
			local pObj = {}
			pObj.nType = e_dlg_index.smithshop 	--跳到铁匠铺
			pObj.nEquipID = nEquipID
			pObj.nFuncIdx = n_smith_func_type.build
			sendMsg(ghd_show_dlg_by_type,pObj)
		elseif self.nActIdx == e_sevenking_index.fuben then
			local bIsOpen = getIsReachOpenCon(2)
			if not bIsOpen then
				return
			end
			local tOpenChapters = Player:getFuben():getOpenChpater()
			--如果该章节未解锁跳到副本最大章节
			if self.nTarget > #tOpenChapters then
				TOAST(getConvertedStr(7, 10144)) --章节未解锁
				self.nTarget = #tOpenChapters
			end
			local tObject = {}
			tObject.tData = self.nTarget --跳到副本对应章节id
			tObject.nType = e_dlg_index.fubenmap --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.nActIdx == e_sevenking_index.camp or self.nActIdx == e_sevenking_index.troops then
			local tOb = {} 					--移动到兵营位置
			tOb.nCell = e_build_cell.sowar
			sendMsg(ghd_move_to_build_dlg_msg, tOb)
		elseif self.nActIdx == e_sevenking_index.shenbing then
			local bCanOpen = getIsReachOpenCon(5)
			if not bCanOpen then
				return
			end
			local tObject = {}
			tObject.nType = e_dlg_index.dlgweaponmain --跳到神兵列表界面
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.nActIdx == e_sevenking_index.resource then
			local tOb = {} 					--移动到资源田(客栈1)位置
			tOb.nCell = 1001
			sendMsg(ghd_move_to_build_dlg_msg, tOb)
		elseif self.nActIdx == e_sevenking_index.succinct then
			if showBuildOpenTips(e_build_ids.ylp) == false then
				TOAST(getConvertedStr(7, 10218))
				return
			end
			local pObj = {}
			pObj.nType = e_dlg_index.smithshop 	--跳到洗炼铺
			pObj.nFuncIdx = n_smith_func_type.train
			sendMsg(ghd_show_dlg_by_type,pObj)
		end
		closeDlgByType(e_dlg_index.actmodela)
	elseif self.pBtnGet:getBtnText() == getConvertedStr(7, 10086) then 	--领取奖励
		local sReq = nil
		if self.nActIdx == e_sevenking_index.dailylogin then
			sReq = "reqDailyLoginAwd"
		elseif self.nActIdx == e_sevenking_index.level then
			sReq = "reqLevelAwd"
		elseif self.nActIdx == e_sevenking_index.killarmy then
			sReq = "reqKillArmyAwd"
		elseif self.nActIdx == e_sevenking_index.tnolyup then
			sReq = "reqTnolyupAwd"
		elseif self.nActIdx == e_sevenking_index.recruithero then
			sReq = "reqRecruitHeroAwd"
		elseif self.nActIdx == e_sevenking_index.kikkboss then
			sReq = "reqKikkBossAwd"
		elseif self.nActIdx == e_sevenking_index.equip then
			sReq = "reqEquipAwd"
		elseif self.nActIdx == e_sevenking_index.fuben then
			sReq = "reqFubenAwd"
		elseif self.nActIdx == e_sevenking_index.cityfight then
			sReq = "reqCityFightAwd"
		elseif self.nActIdx == e_sevenking_index.itemspeed then
			sReq = "reqItemSpeedAwd"
		elseif self.nActIdx == e_sevenking_index.camp then
			sReq = "reqCampAwd"
		elseif self.nActIdx == e_sevenking_index.shenbing then
			sReq = "reqShenbingAwd"
		elseif self.nActIdx == e_sevenking_index.troops then
			sReq = "reqTroopsAwd"
		elseif self.nActIdx == e_sevenking_index.resource then
			sReq = "reqResourceAwd"
		elseif self.nActIdx == e_sevenking_index.succinct then
			sReq = "reqSuccinctAwd"
		end
		if sReq then
			SocketManager:sendMsg(sReq, {self.nTarget}, function(__msg, __oldMsg)
				-- body
				-- dump(__msg.body, "请求领取奖励结果 == ")
				-- dump(__oldMsg, "__oldMsg == ")
				if  __msg.head.state == SocketErrorType.success then
					local tAwd = __msg.body.o
					-- --奖励动画展示
					showGetItemsAction(tAwd, 1)
				else
					TOAST(SocketManager:getErrorStr(__msg.head.state))
				end
				
			end)
		end
	end
end


--析构方法
function ItemKingAward:onItemKingAwardDestroy(  )
end



return ItemKingAward