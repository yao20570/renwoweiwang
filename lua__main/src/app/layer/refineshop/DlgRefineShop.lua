----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-31 17:11:43
-- Description: 洗炼界面
-----------------------------------------------------
local FCommonItemTab = require("app.common.tabhost.FCommonItemTab")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemRefineEquip = require("app.layer.refineshop.ItemRefineEquip")
local ItemRefineAttr = require("app.layer.refineshop.ItemRefineAttr")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local MImgLabel = require("app.common.button.MImgLabel")
local StrengthenLay = require("app.layer.refineshop.StrengthenLay")


local nGoldId = 10 --元宝id
local nGreenQuality = 2 --绿色品质
local nPurpleQuality = 4 --紫色品质

local nBtnTypeGold = 1
local nBtnTypeHigh = 2
local nBtnTypeStop = 3

local nAttrLvMax = 6 --属性满级

local nAutoRefineTypeGold = 1 --自动黄金洗炼
local nAutoRefineTypeHigh = 2 --自动高级洗炼

local nBagIdx = 5

local nHeroTag = 5 --武将4个+背包1个

-- 洗炼铺界面
-- local DlgBase = require("app.common.dialog.DlgBase")
local MCommonView = require("app.common.MCommonView")
local DlgRefineShop = class("DlgRefineShop", function()
	-- return DlgBase.new(e_dlg_index.refineshop)
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--nFuncIdx: 功能索引(1是强化, 2是洗炼)
--sUuid:指定的装备
--heroId:指定的英雄
--nTeamType:武将队伍
function DlgRefineShop:ctor( _tSize, nFunc, sUuid, heroId )
	self:setContentSize(_tSize)
	self.nFunc = nFunc 	--选中的功能界面
	-- print("DlgRefineShop ~~~~~~ ", Player:getEquipData():getPerStoneProb())
	self.sUuid = sUuid
	self.nJumpHeroId = heroId  --跳到指定的英雄分页
	-- self.nFuncIdx = nFuncIdx 	--指定的功能界面
	local nTeamType = e_hero_team_type.normal
	if heroId then
		local tHero = Player:getHeroInfo():getHero(heroId)
		if tHero then
			if tHero:getIsCollectQueue() then
				nTeamType = e_hero_team_type.collect
			elseif tHero:getIsDefenceQueue() then
				nTeamType = e_hero_team_type.walldef
			end
		end
	end
	self.nTeamType = nTeamType
	self.nAutoRefineType = nil --自动洗炼，黄金洗炼，高级洗炼
	self.nAutoRefineCheckTime = getEquipInitParam("autoTrainTime") --时间触发自动洗练(秒)
	self.nAutoRefineCheckNum = getEquipInitParam("autoTrainNum") --次数触发自动洗练
	self.nCurrAutoRefineCheckTime = 0
	self.nCurrAutoRefineCheckNum = 0
	self.bAutoRefine = false                                --是否正在自动洗练
	self.nAutoRefineTimes = 0                               --正在自动洗练的次数

	self.tBagEquipItems  = {} 								--背包装备item列表
	self.tIdleEquipList = {} 								--背包空闲装备

	parseView("dlg_refine_shop", handler(self, self.onParseViewCallback))
end


--解析界面回调
function DlgRefineShop:onParseViewCallback( pView )
	self:addView(pView)
	-- self:addContentView(pView) --加入内容层
	-- self:addContentTopSpace()

	-- self:setTitle(getConvertedStr(3, 10266))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRefineShop",handler(self, self.onDlgRefineShopDestroy))
end

-- 析构方法
function DlgRefineShop:onDlgRefineShopDestroy(  )
    self:onPause()
    if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

function DlgRefineShop:regMsgs(  )
	--洗炼cd发生改变
	regMsg(self, gud_equip_refine_cd_msg, handler(self, self.updateTrainFreeCd))
	--洗炼成功
	regMsg(self, gud_equip_refine_success_msg, handler(self, self.onTrainSuccess))
	--武将装备发生变化
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.onHeroEquipChange))
	--洗炼失败
	regMsg(self, gud_equip_refine_Fail_msg, handler(self, self.stopAutoRefine))
	--注册刷新背包消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.refreshBagEquipList))
	--注册上阵武将消息监听
	regMsg(self, gud_refresh_hero, handler(self, self.onHeroLineUp))
	--注册请求强化成功消息
	regMsg(self, gud_equip_strength_msg, handler(self, self.onHeroEquipChange))
	--注册强化结果消息
	regMsg(self, ghd_equip_strength_result_msg, handler(self, self.onStrenthResult))
end

function DlgRefineShop:unregMsgs(  )
	--洗炼cd发生改变
	unregMsg(self, gud_equip_refine_cd_msg)
	--洗炼成功
	unregMsg(self, gud_equip_refine_success_msg)
	--武将装备发生变化
	unregMsg(self, gud_equip_hero_equip_change)
	--
	unregMsg(self, gud_equip_refine_Fail_msg)
	--注销刷新背包消息
	unregMsg(self, gud_refresh_baginfo)
	--销毁上阵武将消息监听
	unregMsg(self, gud_refresh_hero)
	--销毁请求强化成功消息
	unregMsg(self, gud_equip_strength_msg)
	--销毁强化结果消息
	unregMsg(self, ghd_equip_strength_result_msg)
end

function DlgRefineShop:onResume(  )
	--addTextureToCache("tx/other/sg_tx_jmtx_smjsj")
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgRefineShop:onPause(  )
	--removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")
	self:unregMsgs()
	unregUpdateControl(self)
	--本地记录最后选中的装备id
	local nFuncIdx = self.nCurFuncIdx
	local nTeamType = self.nTeamType
	local nTabIdx = self.nTabIdx or 1
	local nEquipIndex = self.nEquipIndex or 1
	if nTabIdx > 4 then
		nTabIdx = 1
		nEquipIndex = 1
	end
	
	saveLocalInfo("Refineshop_Sel_Equip"..Player:getPlayerInfo().pid, nFuncIdx.."_"..nTeamType.."_"..nTabIdx.."_"..nEquipIndex)
end

function DlgRefineShop:setupViews()
	--如果有指定的装备或英雄或功能就不取记忆了
	if self.sUuid or self.nJumpHeroId then
		self.tMemoryIdx = {0, 0, 0, 0}
	else
		--取出上次离开时记忆的标签
		local sMemoryIdx = getLocalInfo("Refineshop_Sel_Equip"..Player:getPlayerInfo().pid, "0_0_0_0")
	    self.tMemoryIdx = luaSplit(sMemoryIdx, "_")
	end

	self.pLayRoot = self:findViewByName("lay_bottom_container")
	--显示背包装备层
    self.pLayBag = self:findViewByName("lay_bag")
    --背包空闲装备
    self.tIdleEquipList = Player:getEquipData():getIdleEquipVos()

    --左右箭头
    self.pImgLeft = self:findViewByName("img_left")
    self.pImgRight = self:findViewByName("img_right")
	--自动洗练次数文本层
	self.pLayAutoRefineLb = self:findViewByName("lay_autorefinelb")
	self.pLayAutoRefineLb:setVisible(false)
	self.pTextAutoTimes =  MUI.MLabel.new({text = "", size = 26})
	self.pLayAutoRefineLb:addView(self.pTextAutoTimes, 10)
	centerInView(self.pLayAutoRefineLb, self.pTextAutoTimes)

	--头顶横条(banner)
	local pBannerImage = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(pBannerImage,TypeBannerUsed.xlp)
	-- pMBanner:setMBannerOpacity(100)

	--顶部说明
	self.pLbTopTip = self:findViewByName("lb_toptip")

	--武将分类层(主力、采集、城防武将)
	self.pLayTabHost = self:findViewByName("lay_banner")
	local tTitles = {
		getConvertedStr(3, 10570),
		getConvertedStr(3, 10571),
		getConvertedStr(3, 10572),
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,tTitles,handler(self, self.onIndexSelected))
	local tColor = {
		_cc.pwhite,
		_cc.pwhite,
		_cc.gray
	}
	self.pTComTabHost:setTabLabelColors(tColor)
	self.pLayTabHost:addView(self.pTComTabHost)
    centerInView(self.pLayTabHost, self.pTComTabHost )
    self.pTComTabHost:setPositionY(4)
	self.pTComTabHost:removeLayTmp1()
	--上次记忆武将类型
	local nTeamType = tonumber(self.tMemoryIdx[2])
	if nTeamType and nTeamType > 0 and nTeamType <= 3 then
		self.pTComTabHost:setDefaultIndex(nTeamType)
	else
		self.pTComTabHost:setDefaultIndex(self.nTeamType)
	end
	--武将类型tab
	self.tHeroTeamTabItems = self.pTComTabHost:getTabItems()
	--判断是否开锁
	self:tabLockUpdate()

	--装备框
	local pLayEquip1 = self:findViewByName("lay_equip1")
	local pLayEquip2 = self:findViewByName("lay_equip2")
	local pLayEquip3 = self:findViewByName("lay_equip3")
	local pLayEquip4 = self:findViewByName("lay_equip4")
	local pLayEquip5 = self:findViewByName("lay_equip5")
	local pLayEquip6 = self:findViewByName("lay_equip6")
	self.pLayEquips = {
		[e_type_equip.weapon] = pLayEquip1,
		[e_type_equip.horse] = pLayEquip2,
		[e_type_equip.clothes] = pLayEquip3,
		[e_type_equip.helmet] = pLayEquip4,
		[e_type_equip.yin] = pLayEquip5,
		[e_type_equip.fu] = pLayEquip6,
	}
	self.pEquips = {}
	for nKind,pLayEquip in pairs(self.pLayEquips) do
		local pItemRefineEquip = ItemRefineEquip.new(nKind)
		pItemRefineEquip:setIconClickedHandler(handler(self, self.setEquipSelect))
		pLayEquip:addView(pItemRefineEquip)
		self.pEquips[nKind] = pItemRefineEquip
	end

	--当前装备
	self.pLayCurrEquip = self:findViewByName("lay_curr_equip")
	--当前装备图片
	self.pEquipImg = self:findViewByName("img_curequip")
	--当前装备名字和属性
	self.pLbCurEqInfo = self:findViewByName("lb_cureq_info")
	--前往装备按钮
	self.pLayBtnBag = self:findViewByName("lay_btn_bag")
	self.pBtnBag = getCommonButtonOfContainer(self.pLayBtnBag, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10268))
	--下方层
	self.pLayBottom = self:findViewByName("lay_bottom")
	self.pLayBottom:setVisible(false)

	--lb 未穿戴装备
	self.pLbNotWear = self:findViewByName("lb_not_wear")
	self.pLbNotWear:setString(getConvertedStr(7, 10249))
	setTextCCColor(self.pLbNotWear, _cc.red)
	--洗炼按钮
	self.pLayBtnRefine = self:findViewByName("lay_btn_refine")
	showRedTips(self.pLayBtnRefine, 0, 0, 2)
	self.pBtnRefine = getCommonButtonOfContainer(self.pLayBtnRefine, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10270))
	local nTrainFreeMax = getEquipInitParam("trainFreeMax")
	local tConTable = {}
	local tLabel = {
		{getConvertedStr(3, 10271), getC3B(_cc.white)},
		{"0",getC3B(_cc.blue)},
		{"/"..nTrainFreeMax, getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 18
	self.pBtnRefine:setBtnExText(tConTable)
	self.pBtnRefine:onCommonBtnClicked(handler(self, self.onRefineClicked))
	--高级洗炼提示
	self.pTxtBottomTip = self:findViewByName("txt_bottom_tip")
	self.pTxtBottomTip:setString(getConvertedStr(3, 10272))

	--黄金洗炼/高级洗炼
	local pLayBtnGoldRefine = self:findViewByName("lay_btn2")
	self.pBtnGoldRefine = getCommonButtonOfContainer(pLayBtnGoldRefine, TypeCommonBtn.L_YELLOW)
	--按钮上面的字
	self.pImgLabel = MImgLabel.new({text="", size = 22, parent = self.pLayBottom})
	self.pImgLabel:setImg("#v1_img_qianbi.png", 1, "left")
	local posx = pLayBtnGoldRefine:getPositionX() + pLayBtnGoldRefine:getWidth()/2
	local posy = pLayBtnGoldRefine:getPositionY() + pLayBtnGoldRefine:getHeight() + 1
	self.pImgLabel:followPos("center", posx, posy, 8)

	self.pBtnGoldRefine:onCommonBtnClicked(handler(self, self.onGoldRefineClicked))

	--绿色以上才可以洗炼提示
	local pTxtContentTip = self:findViewByName("txt_content_tip")
	setTextCCColor(pTxtContentTip, _cc.red)
	pTxtContentTip:setString(getConvertedStr(3, 10269))
	self.pTxtContentTip = pTxtContentTip
	self.pTxtContentTip:setVisible(false)

	--装备属性框
	self.pItemRefineAttr1 = ItemRefineAttr.new(1)
	self.pItemRefineAttr1:setPosition(42, 230)
	self.pLayBottom:addView(self.pItemRefineAttr1)

	self.pItemRefineAttr2 = ItemRefineAttr.new(2)
	self.pItemRefineAttr2:setPosition(164, 230)
	self.pLayBottom:addView(self.pItemRefineAttr2)

	self.pItemRefineAttr3 = ItemRefineAttr.new(3)
	self.pItemRefineAttr3:setPosition(286, 230)
	self.pLayBottom:addView(self.pItemRefineAttr3)

	self.pItemRefineAttr4 = ItemRefineAttr.new(4)
	self.pItemRefineAttr4:setPosition(503, 230)
	self.pLayBottom:addView(self.pItemRefineAttr4)

	self.pImgAdd = self:findViewByName("img_add")

	--洗炼cd时间
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.red)

	--英雄listView
	self.tTabItems = {}
	local pLayTab = self:findViewByName("lay_tab")
	self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pLayTab:getContentSize().width, pLayTab:getContentSize().height),
        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
        itemMargin = {left = 0,
            right =  0,
            top =  3,
            bottom =  0},
    }
    pLayTab:addView(self.pListView)
    self.pListView:setIsCanScroll(true)
    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
    self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nTeamType)
    self.pListView:setItemCount(nHeroTag)
    self.pListView:reload()

    --顶部功能层(强化、洗炼)
	-- self.pLayTopTab = self:findViewByName("lay_top_tab")
	-- local tTitles = {
	-- 	getConvertedStr(7, 10315),
	-- 	getConvertedStr(7, 10316)
	-- }
    --顶部功能
    self:onFuncSelected(self.nFunc)
	-- self.pTopTabHost = TCommonTabHost.new(self.pLayTopTab,1,1,tTitles,handler(self, self.onFuncSelected))
	-- self.pLayTopTab:addView(self.pTopTabHost)
 --    centerInView(self.pLayTopTab, self.pTopTabHost)
	-- self.pTopTabHost:removeLayTmp1()
	-- self.pTopTabItems = self.pTopTabHost:getTabItems()
	-- --顶部功能层开启刷新
	-- self:topTabLockUpdate()
 --    if self.nFuncIdx then
 --    	self.pTopTabHost:setDefaultIndex(self.nFuncIdx)
 --    else
    	
 --    	local nFuncIdx = tonumber(self.tMemoryIdx[1])
 --    	if nFuncIdx and nFuncIdx > 0 then
 --    		self.pTopTabHost:setDefaultIndex(nFuncIdx)
 --    	else
 --    		--强化开没开
 --    		local bOpen, sLockTip = getIsReachOpenCon(20, false)
 --    		if bOpen then
	-- 			self.pTopTabHost:setDefaultIndex(n_smith_func_type.strengthen)
 --    		else
	-- 			self.pTopTabHost:setDefaultIndex(n_smith_func_type.train)
	-- 		end
	-- 	end
 --    end

end

--刷新背包装备
function DlgRefineShop:refreshBagEquipList()
	--装备数量
	if self.pBagListView then
	    self.tIdleEquipList = Player:getEquipData():getIdleEquipVos()
		local nequipCnt = table.nums(self.tIdleEquipList)
		self.pBagListView:notifyDataSetChange(false, nequipCnt)
		self.pImgLeft:setVisible(#self.tIdleEquipList > 0)
		self.pImgRight:setVisible(#self.tIdleEquipList > 0)
	end
end

--功能下标选择
function DlgRefineShop:onFuncSelected(_index)
	-- body
	if self.nCurFuncIdx ~= _index then
		self.nCurFuncIdx = _index
		if not self.pStrengthenView then
			self.pStrengthenView = StrengthenLay.new()
			self.pLayRoot:addView(self.pStrengthenView, 9)
		end
		if self.nCurFuncIdx == n_smith_func_type.strengthen then
			self.pLayBottom:setVisible(false)
			self.pTxtContentTip:setVisible(false)
			self.pStrengthenView:setVisible(true)
			local sTip = getTextColorByConfigure(getTipsByIndex(20133))
			self.pLbTopTip:setString(sTip)
		elseif self.nCurFuncIdx == n_smith_func_type.train then
			self.pStrengthenView:setVisible(false)
			self.pLbTopTip:setString(getTipsByIndex(20058))
		end
		--更新当前选中的装备
		self:updateCurrEquip()
		--更新武将身上的装备
		self:updateEquips()
		--刷新背包装备
		self:refreshBagEquipList()
		--刷新武将身上的红点
		self:updateHeroRedTip()
	end
end

--下标选择回调事件
function DlgRefineShop:onIndexSelected( nIndex )
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		self.nTeamType = nIndex
		self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nCurrTab)
		if self.pListView then
			self.pListView:notifyDataSetChange(true, nHeroTag)
			self:updateViews()

			self.pListView:scrollToPosition(1)
			self.pBagListView:scrollToPosition(1)
		end
	end
end


--列表项回调
function DlgRefineShop:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tHeroList[_index]
    local pTempView = _pView
    if pTempView == nil then
    	local pItemTab = FCommonItemTab.new(1, 1, 128)
        pTempView = pItemTab 
        --table.insert(self.tTabItems, pItemTab)
    end
    self.tTabItems[_index] = pTempView
    pTempView.nIndex = _index --下标标志
    if tTempData then
   		pTempView:setTabTitle(tTempData.sName)
   		pTempView:setViewEnabled(true)
   		--隐藏上锁
		pTempView:hideTabLock()
   	else
   		if _index == nBagIdx then
	   		pTempView:setTabTitle(getConvertedStr(7, 10248)) --背包
	   		pTempView:setViewEnabled(true)
   			--隐藏上锁
			pTempView:hideTabLock()
   		else
	   		pTempView:setTabTitle(getConvertedStr(7, 10247).._index)
	   		local nState = Player:getHeroInfo():getOnlinePosStateByTeam(self.nCurrTab, _index)
			if nState == TypeIconHero.LOCK then
		   		--显示上锁
				pTempView:showTabLock()
				pTempView:setViewEnabled(false)
				pTempView:onMViewDisabledClicked(handler(self, function (  )
				    TOAST(getConvertedStr(3, 10575))
				end))
			else
				pTempView:setViewEnabled(true)
	   			--隐藏上锁
				pTempView:hideTabLock()
			end
		end
   	end
    --设置点击事件
	pTempView:onMViewClicked(handler(self, self.setTopTabState))
    return pTempView
end

--背包装备列表项回调
function DlgRefineShop:onBagListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tIdleEquipList[_index]
    local tEquipVo = Player:getEquipData():getEquipVoByUuid(tTempData.sUuid)
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemRefineEquip.new()
    end
    pTempView:setData(tEquipVo, self.nCurFuncIdx)
    pTempView.nIndex = _index --下标标志
	self.tBagEquipItems[_index] = pTempView
	if tTempData.sUuid == self.bagSuuid then
		pTempView:setEquipSelected(true)
	else
		pTempView:setEquipSelected(false)
	end

	pTempView:setIconClickedHandler(function()
		-- body
		self:setBagEquipSelect(tEquipVo.sUuid)
	end)
    return pTempView
end

--设置按钮状态
function DlgRefineShop:setTopTabState( pView , nKind, nTabIdx)
	local nIndex = pView.nIndex
	self.nTabIdx = nIndex
	nKind = nKind or 1
	self.bagSuuid = nil
	self.nSelectHeroId = nil
	for k, v in pairs (self.tTabItems) do
		if v.nIndex == nIndex then
			v:setChecked(true, "#v2_btn_selected_hkoyp.png")
			if v.nIndex == nBagIdx then --背包
				for i = 1, 6 do
					self.pLayEquips[i]:setVisible(false)
				end
				self.pLayBag:setVisible(true)
				self.pImgLeft:setVisible(#self.tIdleEquipList > 0)
				self.pImgRight:setVisible(#self.tIdleEquipList > 0)
				local tEquip = self.tIdleEquipList[nKind]
				if tEquip then
					self:setBagEquipSelect(tEquip.sUuid)
				end
			else
				--执行显示或更新
				if self.tHeroList[nIndex] then
					self.nSelectHeroId = self.tHeroList[nIndex].nId
				end
				self:updateEquips()
				for i = 1, 6 do
					self.pLayEquips[i]:setVisible(true)
				end
				self.pLayBag:setVisible(false)
				self.pImgLeft:setVisible(true)
				self.pImgRight:setVisible(true)
				self:setEquipSelect(nKind)
			end
		else
			v:setChecked(false, "#v2_btn_biaoqian_hkoyp.png")
		end
	end
end

function DlgRefineShop:updateViews(  )
	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if(_index == 1) then
			--背包里的装备列表
			--装备数量
			local nequipCnt = table.nums(self.tIdleEquipList)
			if not self.pBagListView then
			    self.pBagListView = MUI.MListView.new {
			        viewRect   = cc.rect(0, 0, self.pLayBag:getContentSize().width, self.pLayBag:getContentSize().height),
			        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
			        itemMargin = {left = 0,
			            right = 5,
			            top = 0,
			            bottom = 0},
			    }
			    self.pLayBag:addView(self.pBagListView)
			    self.pBagListView:setItemCallback(handler(self, self.onBagListViewItemCallBack))
			    
			    self.pBagListView:setItemCount(nequipCnt)
			    self.pBagListView:reload(true)
			else
				self.pBagListView:notifyDataSetChange(false, nequipCnt)
			end
		elseif(_index == 2) then
			--切换第几个
			local nIndex = 1
			local nEquipIndex = 1

			if self.tMemoryIdx[3] and tonumber(self.tMemoryIdx[3]) > 0 and self.tMemoryIdx[4] and tonumber(self.tMemoryIdx[4]) > 0 then
				nIndex = tonumber(self.tMemoryIdx[3])
				nEquipIndex = tonumber(self.tMemoryIdx[4])
				self.tMemoryIdx[3] = 0
				self.tMemoryIdx[4] = 0
			end

			--切换到指定的英雄
			if self.nJumpHeroId then
				for i=1, #self.tHeroList do
					if self.nJumpHeroId == self.tHeroList[i].nId then
						nIndex = i
						if self.sUuid then
							local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
							if tEquipVo then
								local tEquipData = tEquipVo:getConfigData()
				    			if tEquipData then
				    				nEquipIndex = tEquipData.nKind
				    			end
							end
						end
						break
					end
				end
			end
			
			if self.sUuid then
				local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
				if tEquipVo then
					nIndex = nil
			    	for i=1,#self.tHeroList do			    		
			    		if tEquipVo.nHeroId ==  self.tHeroList[i].nId then
			    			nIndex = i
			    			local tEquipData = tEquipVo:getConfigData()
			    			if tEquipData then
			    				nEquipIndex = tEquipData.nKind
			    			end
			    			break
			    		end
			    	end
			    	if not nIndex then
			    		nIndex = nBagIdx
			    	end
			    	for k , v in pairs(self.tIdleEquipList) do
						if v.sUuid == self.sUuid then
							nEquipIndex = k
							break
						end
					end
			    end
			end
			if nIndex > 4 then
				self.pListView:scrollToPosition(nIndex)
				self.pBagListView:scrollToPosition(nEquipIndex)
				-- nIndex = 1
				-- nEquipIndex = 1
			end
			if self.tTabItems[nIndex] then
				self:setTopTabState(self.tTabItems[nIndex], nEquipIndex)
			end

			--刷新武将红点
			self:updateHeroRedTip()
			--刷新顶部功能红点
			-- self:updateTopFuncItemRedTip()
		end
	end)
end

--恢复免费洗炼cd
function DlgRefineShop:updateTrainFreeCd(  )
	--当层显示的时候才进行刷新
	if not self.tEquipVo then
		return
	end
	local tEquipData = getBaseEquipDataByID(self.tEquipVo.nId)
	if tEquipData.nQuality >= nGreenQuality then
		local nTrainFreeMax = getEquipInitParam("trainFreeMax")
		local nTrainFree = Player:getEquipData():getFreeTrain()
		if nTrainFree < nTrainFreeMax then
			local nCd = Player:getEquipData():getFreeTrainCd()
			self.pTxtCd:setString(formatTimeToHms(nCd))
			self.pTxtCd:setVisible(true)
			if nCd <= 0 then
				SocketManager:sendMsg("refreshEquipFreeTrain", {}, function()
					-- body
					-- unregUpdateControl(self)
					-- regUpdateControl(self, handler(self, self.updateCd))
				end)
			end
		else
			self.pTxtCd:setVisible(false)
		end
		--免费洗炼按钮
		self:updateRefineBtn()
	end
end

--更新免费洗炼按钮
function DlgRefineShop:updateRefineBtn(  )
	--避免重复刷新
	local nTrainFree = Player:getEquipData():getFreeTrain()
	if self.nTrainFreePrev ~= nTrainFree or self.nAutoRefineTypePrev ~= self.nAutoRefineType then
		self.nTrainFreePrev = nTrainFree
		self.nAutoRefineTypePrev = self.nAutoRefineType		
		self.pBtnRefine:setExTextLbCnCr(2, nTrainFree)
		if nTrainFree > 0 and self.nAutoRefineType == nil then
			self.pBtnRefine:setBtnEnable(true)
			--洗练按钮上的红点显示
			showRedTips(self.pLayBtnRefine, 0, 1, 2)
		else
			self.pBtnRefine:setBtnEnable(false)
			--洗练按钮上的红点隐藏
			showRedTips(self.pLayBtnRefine, 0, 0, 2)
		end
	end
end

function DlgRefineShop:updateEquips()
	--图标
	local tEquipData = Player:getEquipData()
	if not tEquipData then
		return
	end
	--有上阵的情况下
	if self.nSelectHeroId then
		local tEquipVos = tEquipData:getEquipVosByKindInHero(self.nSelectHeroId)
		for nKind, pIcon in pairs(self.pEquips) do
			local tEquipVo = tEquipVos[nKind]
			pIcon:setData(tEquipVo, self.nCurFuncIdx)
		end
	else
		--没有上阵的情况下
		for nKind, pIcon in pairs(self.pEquips) do
			pIcon:setData(nil)
		end
	end
end

--背包装备选中
function DlgRefineShop:setBagEquipSelect(_sUuid)
	for k, v in pairs(self.tBagEquipItems) do
		if v.getData and v:getData().sUuid == _sUuid then
			v:setEquipSelected(true)
		else
			v:setEquipSelected(false)
		end
	end
	--更新当前装备
	self.bagSuuid = _sUuid
	
	self:updateCurrEquip()
end

--设置选中框
--nIndex 装备集选中的装备下标
function DlgRefineShop:setEquipSelect( nIndex )
	--停止
	self:stopAutoRefine()

	if not nIndex then
		return
	end

	if self.nEquipIndex then
		self.pEquips[self.nEquipIndex]:setEquipSelected(false)	
	end

	--装备下标
	self.nEquipIndex = nIndex

	--设置选中框位置
	-- local nX, nY = self.pLayEquips[nIndex]:getPosition()
	-- local nOffsetX,nOffsetY = -7, -7
	-- self.pLaySelect:setPosition(nX + nOffsetX, nY + nOffsetY)
	self.pEquips[self.nEquipIndex]:setEquipSelected(true)	

	--更新当前装备
	self:updateCurrEquip()
end

--当前选中装备信息
function DlgRefineShop:setSelEquipData(_tEquipVo, _bIsTrainSuccess)
	-- body
	self.tEquipVo = _tEquipVo

	if _tEquipVo then
		--隐藏背包和显示当前装备
		self.pLayBtnBag:setVisible(false)
		self.pLbNotWear:setVisible(false)
		self.pLayCurrEquip:setVisible(true)
		self.pEquipImg:setVisible(true)
		local tEquipData = getBaseEquipDataByID(_tEquipVo.nId)
		if tEquipData then
			--设置当前装备显示
			self.pEquipImg:setCurrentImage(tEquipData.sIcon)
			if self.pLbCurEqInfo then
				local sAttrs = tEquipData.sAttrs
				local tAttrs = luaSplit(sAttrs, ":")
				local nAttrId = tonumber(tAttrs[1])
				local nAttrValue = _tEquipVo:getAttrValue() --tonumber(tAttrs[2])
				if nAttrId and nAttrValue then
					local tAttData = getBaseAttData(nAttrId)
					if tAttData then
						local tLb = {
							{text = tEquipData.sName, color = getC3B(getColorByQuality(tEquipData.nQuality))},--玩家名字
							{text = " "..tAttData.sName, color = getC3B(_cc.pwhite)},--主要属性名字
							{text = "+"..nAttrValue, color = getC3B(_cc.blue)},--属性值
						}
						self.pLbCurEqInfo:setString(tLb, false)
					end
				end
			end
			--如果是洗炼功能
			if self.nCurFuncIdx ~= n_smith_func_type.strengthen then
				--绿色品质以上才可以洗炼
				if tEquipData.nQuality >= nGreenQuality then
					self.pTxtContentTip:setVisible(false)
					self.pLayBottom:setVisible(true)

					--显示前三个属性
					self.pItemRefineAttr1:setData(_tEquipVo.tTrainAtbVos[1], _bIsTrainSuccess)
					self.pItemRefineAttr2:setData(_tEquipVo.tTrainAtbVos[2], _bIsTrainSuccess)
					self.pItemRefineAttr3:setData(_tEquipVo.tTrainAtbVos[3], _bIsTrainSuccess)

					--紫装以上显示3+1属性
					if tEquipData.nQuality >= nPurpleQuality then
						local nX, nY = 42, 230
						self.pItemRefineAttr1:setPosition(nX, nY)
						local nX, nY = 164, 230
						self.pItemRefineAttr2:setPosition(nX, nY)
						local nX, nY = 286, 230
						self.pItemRefineAttr3:setPosition(nX, nY)
						--隐藏属性
						self.pItemRefineAttr4:setVisible(true)
						self.pImgAdd:setVisible(true)
						self.pItemRefineAttr4:setData(_tEquipVo.tHiddenTAVo, _bIsTrainSuccess)
						if _tEquipVo.tHiddenTAVo then
							self.pImgAdd:setToGray(false)
						else
							self.pImgAdd:setToGray(true)
						end
					else
						local nOffsetX = 169
						local nX, nY = 103, 230
						self.pItemRefineAttr1:setPosition(nX, nY)
						local nX, nY = 273, 230
						self.pItemRefineAttr2:setPosition(nX, nY)
						local nX, nY = 448, 230
						self.pItemRefineAttr3:setPosition(nX, nY)
						self.pItemRefineAttr4:setVisible(false)
						self.pImgAdd:setVisible(false)
					end
					--更新按钮
					self:updateGoldRefineBtn()
					self:updateRefineBtn()
				else
					--绿装以上才可以洗炼
					self.pTxtContentTip:setVisible(true)
					self.pLayBottom:setVisible(false)
				end
			elseif self.nCurFuncIdx ~= n_smith_func_type.train then
				self.pStrengthenView:setVisible(true)
				self.pStrengthenView:setStrengthData(self.tEquipVo)
			end
		end
	end
end

--更新当前选中的装备
function DlgRefineShop:updateCurrEquip( bIsTrainSuccess )
	--每10次强制清空一次垃圾
	if self.nUpdateIndex then
		self.nUpdateIndex = self.nUpdateIndex + 1
		if self.nUpdateIndex > 10 then
			--print("清空垃圾~~~~~")
			collectgarbage("collect")
			self.nUpdateIndex = 0
		end
	else
		self.nUpdateIndex = 0
	end
	
	--bag no nil
	local tEquipVo = nil
	
	if self.bagSuuid then
		tEquipVo = Player:getEquipData():getEquipVoByUuid(self.bagSuuid)
	elseif self.nSelectHeroId and self.nEquipIndex then
		local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(self.nSelectHeroId)
		tEquipVo = tEquipVos[self.nEquipIndex]
	end

	self.tEquipVo = tEquipVo
	if tEquipVo then
		self:setSelEquipData(tEquipVo, bIsTrainSuccess)
	else
		--显示前往背包装备
		self.pTxtContentTip:setVisible(false)
		self.pLayBtnBag:setVisible(true)
		self.pLbNotWear:setVisible(true)
		self.pLayCurrEquip:setVisible(false)
		self.pLayBottom:setVisible(false)
		self.pStrengthenView:setVisible(false)
		self.pEquipImg:setVisible(false)

		if self.nSelectHeroId then --已上阵
			self.pBtnBag:updateBtnText(getConvertedStr(3, 10268))
			self.pBtnBag:onCommonBtnClicked(handler(self, self.onBagClicked))
		else--未上阵
			self.pBtnBag:updateBtnText(getConvertedStr(3, 10574))
			self.pBtnBag:onCommonBtnClicked(handler(self, self.onLineUpClicked))
		end
	end
end

--刷新装备，cd时间
function DlgRefineShop:onTrainSuccess(  )
	--如果自动黄金洗炼满足就停止
	if self.nAutoRefineType == nAutoRefineTypeGold then
		if self.tEquipVo then
			local bIsHighRefine = true
			for i=1,#self.tEquipVo.tTrainAtbVos do
				local nLv = self.tEquipVo.tTrainAtbVos[i].nLv
				if nLv < nAttrLvMax then
					bIsHighRefine = false
					break
				end
			end
			if bIsHighRefine then
				self:stopAutoRefine()
			end
		else
			self:stopAutoRefine()
		end	
	end
	--更新恢复cd
	self:updateTrainFreeCd()
	--刷新装备成功
	self.bIsTrainSuccess = true
	sendMsg(gud_equip_hero_equip_change)
end

--每秒进来一次 
function DlgRefineShop:updateCd(  )
	self:updateTrainFreeCd()

	--自动洗炼对话框点击次数清0
	if self.nCurrAutoRefineCheckTime > self.nAutoRefineCheckTime then
		self.nCurrAutoRefineCheckTime = 0
		self.nCurrAutoRefineCheckNum = 0
	else
		self.nCurrAutoRefineCheckTime = self.nCurrAutoRefineCheckTime + 1
	end
	--print("XXXXXXXXXXXXXXXXXXXXXXXXXX")
	--关闭定时器 cd时间>0 且点击次数已清0
	local nTrainFreeMax = getEquipInitParam("trainFreeMax")
	local nTrainFree = Player:getEquipData():getFreeTrain()
	local nCd = Player:getEquipData():getFreeTrainCd()
	if nCd <= 0 and self.nCurrAutoRefineCheckNum == 0 and nTrainFree >= nTrainFreeMax then
		unregUpdateControl(self)
	end
end

function DlgRefineShop:onHeroEquipChange(  )
	--更新装备
	self:updateEquips()
	--更新当前装备
	self:updateCurrEquip(self.bIsTrainSuccess)
	self.bIsTrainSuccess = false
	--刷新武将红点
	self:updateHeroRedTip()
	--刷新背包装备
	self:refreshBagEquipList()
	--刷新顶部功能红点
	-- self:updateTopFuncItemRedTip()
end

--更新黄金按钮
function DlgRefineShop:updateGoldRefineBtn(  )
	if self.nAutoRefineType then
		local sCost = getEquipInitParam("trainGoldCost")
		if self.nAutoRefineType == nAutoRefineTypeGold then
		elseif self.nAutoRefineType == nAutoRefineTypeHigh then
			sCost = getEquipInitParam("trainHighGoldCost")
		end
		self.pImgLabel:setString(sCost.."/" .. Player:getPlayerInfo().nMoney)
		self.pBtnGoldRefine:updateBtnText(getConvertedStr(3, 10275))
		self.pBtnGoldRefine:updateBtnType(TypeCommonBtn.L_RED)
		self.pBtnGoldRefine:setCallBackParam(nBtnTypeStop)
	else
		if self.tEquipVo then
			--是否显示高级洗炼
			if self.tEquipVo:getIsCanHighRefine() then
				self.pImgLabel:setString(getEquipInitParam("trainHighGoldCost"))
				self.pBtnGoldRefine:updateBtnText(getConvertedStr(3, 10274))
				self.pBtnGoldRefine:updateBtnType(TypeCommonBtn.L_YELLOW)
				self.pBtnGoldRefine:setCallBackParam(nBtnTypeHigh)
				self.pTxtBottomTip:setVisible(true)
			else
				self.pImgLabel:setString(getEquipInitParam("trainGoldCost"))
				self.pBtnGoldRefine:updateBtnText(getConvertedStr(3, 10273))
				self.pBtnGoldRefine:updateBtnType(TypeCommonBtn.L_YELLOW)
				self.pBtnGoldRefine:setCallBackParam(nBtnTypeGold)
				self.pTxtBottomTip:setVisible(false)
			end
		end
	end
	-- self:updateRefineBtn()
end

--开启自动黄金洗炼
function DlgRefineShop:openAutoGoldRefine( )
	self.bAutoRefine = true
	--更新地表
	if not self.nUpdateScheduler then
		self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
			if self.tEquipVo:getIsCurrRefineLvMax() then
				self:stopAutoRefine()
			else
				self:useGoldRefine()
			end
		end,getEquipInitParam("autoTrainInterval"))
	end
	--更新按钮
	self.nAutoRefineType = nAutoRefineTypeGold
	self:updateGoldRefineBtn()
	self:updateRefineBtn()
end

--开启自动高级洗炼
function DlgRefineShop:openAutoHighRefine( )
	self.bAutoRefine = true
	-- self.pLayAutoRefineLb:setVisible(true)
	if not self.nUpdateScheduler then
		self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
			if self.tEquipVo:getIsAllTrainAtbSame() then
				self:stopAutoRefine()
			else
				self:useHighRefine()
			end
		end,getEquipInitParam("autoTrainInterval"))
	end
	--更新按钮
	self.nAutoRefineType = nAutoRefineTypeHigh
	self:updateGoldRefineBtn()
	self:updateRefineBtn()
end

--停止自动洗炼
function DlgRefineShop:stopAutoRefine(  )
	self.bAutoRefine = false
	self.nAutoRefineTimes = 0
	self.pLayAutoRefineLb:setVisible(false)
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	self.nAutoRefineType = nil
	self:updateGoldRefineBtn()
	self:updateRefineBtn()
end

--点击前往背包
function DlgRefineShop:onBagClicked( pView )
	local pDlg, bNew = getDlgByType(e_dlg_index.equipbag)
	if pDlg then
		pDlg:closeOrHideDlg()
	end
	local tObject = {
	    nType = e_dlg_index.equipbag, --dlg类型
	    nKind = self.nEquipIndex,
	    nHeroId = self.nSelectHeroId,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--点击前往上阵
function DlgRefineShop:onLineUpClicked( pView )
	local tObject = {
	    nType = e_dlg_index.dlgherolineup, --dlg类型
	    nTeamType = self.nTeamType,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--点击普通洗炼
function DlgRefineShop:onRefineClicked( pView )
	if not self.tEquipVo then
		return
	end

	--洗炼请求
	local function refineReq(  )
		SocketManager:sendMsg("reqEquipTrain", {self.tEquipVo.sUuid, 0}, function()
			-- body
			unregUpdateControl(self)
			regUpdateControl(self, handler(self, self.updateCd))
		end)
	end

	--隐藏属性已激活
	if self.tEquipVo.tHiddenTAVo then
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getTipsByIndex(10012))
	    pDlg:setRightHandler(function (  )
	        refineReq()
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	else
		refineReq()
	end
end

--点击黄金洗炼
function DlgRefineShop:onGoldRefineClicked( pView, nBtnType)
	if nBtnType == nBtnTypeGold then
		--开启定时器
		if self.nCurrAutoRefineCheckNum == 0 then
			regUpdateControl(self, handler(self, self.updateCd))
		end
		--弹出自动黄金洗炼对话框
		self.nCurrAutoRefineCheckNum = self.nCurrAutoRefineCheckNum + 1
		if (self.tEquipVo and not self.tEquipVo:getIsCurrRefineLvMax()) and self.nCurrAutoRefineCheckNum >= self.nAutoRefineCheckNum then
			
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end			
		    pDlg:setTitle(getConvertedStr(3, 10091))
		    pDlg:setContent(getTextColorByConfigure(getTipsByIndex(20003)))
		    pDlg:showDlg(bNew)
		    pDlg:setRightHandler(handler(self, function ( )
		    	-- body
		    	pDlg:closeAlertDlg()
		    	self:openAutoGoldRefine()
		    end))

		else
			local tStr = {
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
		    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), getEquipInitParam("trainGoldCost"))},
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10282)},
		    }
			showBuyDlg(tStr, getEquipInitParam("trainGoldCost"), handler(self, self.useGoldRefine), 1, false)
		end
	elseif nBtnType == nBtnTypeHigh then
		--开启定时器
		if self.nCurrAutoRefineCheckNum == 0 then
			regUpdateControl(self, handler(self, self.updateCd))
		end
		--弹出自动高级洗炼对话框
		self.nCurrAutoRefineCheckNum = self.nCurrAutoRefineCheckNum + 1
		-- if self.nCurrAutoRefineCheckNum >= self.nAutoRefineCheckNum then
		-- 	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		--     if(not pDlg) then
		--         pDlg = DlgAlert.new(e_dlg_index.alert)
		--     end			
		--     pDlg:setTitle(getConvertedStr(3, 10091))
		--     pDlg:setContent(getTextColorByConfigure(getTipsByIndex(20004)))
		--     pDlg:showDlg(bNew)
		--     pDlg:setRightHandler(handler(self, function ( )
		--     	-- body
		--     	pDlg:closeAlertDlg()
		--     	self:openAutoHighRefine()
		--     end))
			-- local tStr = {
		 --    	{color = _cc.pwhite, text = getConvertedStr(3, 10276)},
		 --    	{color = _cc.yellow, text = getConvertedStr(3, 10279)},
		 --    	{color = _cc.pwhite, text = getConvertedStr(3, 10278)},
		 --    }
			-- showBuyDlg(tStr, getEquipInitParam("trainHighGoldCost"), handler(self, self.openAutoHighRefine), 1, false)
		-- else
			local tStr = {
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
		    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), getEquipInitParam("trainHighGoldCost"))},
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10283)},
		    }
			showBuyDlg(tStr, getEquipInitParam("trainHighGoldCost"), handler(self, self.useHighRefine), 1, false)
		-- end
	elseif nBtnType == nBtnTypeStop then
		self:stopAutoRefine()
	end
end

function DlgRefineShop:useGoldRefine()
	if not self.tEquipVo then
		self:stopAutoRefine()
		return
	end
	if checkIsResourceEnough(nGoldId, getEquipInitParam("trainGoldCost"), true) then
		SocketManager:sendMsg("reqEquipTrain", {self.tEquipVo.sUuid, 1}, function(__msg)
			if __msg.head.state ~= SocketErrorType.success then
				--突然关掉会有问题
				if self.stopAutoRefine then
					self:stopAutoRefine()
				end
			else
				--突然关掉会有问题 znftodo
				if self.playRefineTimeAct then
					self:playRefineTimeAct()
				end
			end
		end)
	else
		self:stopAutoRefine()
	end
end

function DlgRefineShop:useHighRefine()
	if not self.tEquipVo then
		self:stopAutoRefine()
		return
	end
	if checkIsResourceEnough(nGoldId, getEquipInitParam("trainHighGoldCost"), true) then
		SocketManager:sendMsg("reqEquipHighTrain", {self.tEquipVo.sUuid},function ( __msg )
			if __msg.head.state ~= SocketErrorType.success then
				self:stopAutoRefine()
			else
				self:playRefineTimeAct()
			end 
		end)
	else
		self:stopAutoRefine()
	end
end

--如果是自动洗练播放自动洗练次数刷新
function DlgRefineShop:playRefineTimeAct()
	if self.bAutoRefine then
		self.nAutoRefineTimes = self.nAutoRefineTimes + 1
		local tStr = {
			{text=getConvertedStr(7, 10119), color=getC3B(_cc.pwhite)},
			{text=self.nAutoRefineTimes, color=getC3B(_cc.blue)},
			{text=getConvertedStr(7, 10120), color=getC3B(_cc.pwhite)},
		}
		self.pLayAutoRefineLb:setVisible(true)
		self.pTextAutoTimes:setString(tStr)
	end
end

--刷新英雄标签上的红点显示
function DlgRefineShop:updateHeroRedTip()
	-- body
	local tEquipData = Player:getEquipData()
	if not tEquipData then
		return
	end
	
	for k, v in pairs(self.tTabItems) do
		local bCan = false
		if table.nums(self.pEquips) > 0 then
			local pHero = self.tHeroList[v.nIndex]
			if pHero then
				local tEquipVos = tEquipData:getEquipVosByKindInHero(pHero.nId)
				for nKind, pIcon in pairs(self.pEquips) do
					local tEquipVo = tEquipVos[nKind]
					if tEquipVo then
						--如果是强化功能
						if self.nCurFuncIdx == n_smith_func_type.strengthen then
							if tEquipData:isCanStrengthen(tEquipVo) then
								bCan = true
								break
							end
						elseif self.nCurFuncIdx == n_smith_func_type.train then --如果是洗炼功能
							if tEquipData:isCanRefine(tEquipVo) then
								bCan = true
								break
							end
						end
					end
				end
			end
		end
		if bCan then
			showRedTips(v:getRedNumLayer(), 0, 1, 2)
		else
			showRedTips(v:getRedNumLayer(), 0, 0, 2)
		end
	end
	--武将类型标签上的红点显示
	for i, tab in pairs(self.tHeroTeamTabItems) do
		local bCan = false
		local tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(i)
		for _, pHero in pairs(tHeroList) do
			local tEquipVos = tEquipData:getEquipVosByKindInHero(pHero.nId)
			for _, equipVo in pairs(tEquipVos) do
				--如果是强化功能
				if self.nCurFuncIdx == n_smith_func_type.strengthen then
					if tEquipData:isCanStrengthen(equipVo) then
						bCan = true
						break
					end
				elseif self.nCurFuncIdx == n_smith_func_type.train then --如果是洗炼功能
					if tEquipData:isCanRefine(equipVo) then
						bCan = true
						break
					end
				end
			end
			if bCan then
				break
			end
		end
		if bCan then
			showRedTips(tab:getRedNumLayer(), 0, 1, 2)
		else
			showRedTips(tab:getRedNumLayer(), 0, 0, 2)
		end
	end
end

--刷新顶部功能按钮上的红点
-- function DlgRefineShop:updateTopFuncItemRedTip()
-- 	-- body
-- 	--获取所有已上阵的武将
-- 	local tAllHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(1)
-- 	for i = 2, 3 do
-- 		local tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(i)
-- 		for k, v in pairs(tHeroList) do
-- 			table.insert(tAllHeroList, v)
-- 		end
-- 	end

-- 	local tEquipData = Player:getEquipData()
	
-- 	for i, tab in pairs(self.pTopTabItems) do
-- 		local bCan = false
-- 		for _, pHero in pairs(tAllHeroList) do
-- 			local tEquipVos = tEquipData:getEquipVosByKindInHero(pHero.nId)
-- 			for _, equipVo in pairs(tEquipVos) do
-- 				--如果是强化功能
-- 				if i == n_smith_func_type.strengthen then
-- 					local bOpen = getIsReachOpenCon(20, false)
-- 					if bOpen and tEquipData:isCanStrengthen(equipVo) then
-- 						bCan = true
-- 						break
-- 					end
-- 				elseif i == n_smith_func_type.train then --如果是洗炼功能
-- 					local bOpen = getIsReachOpenCon(21, false)
-- 					if bOpen and tEquipData:isCanRefine(equipVo) then
-- 						bCan = true
-- 						break
-- 					end
-- 				end
-- 			end
-- 			if bCan then
-- 				break
-- 			end
-- 		end
-- 		if bCan then
-- 			showRedTips(tab:getRedNumLayer(), 0, 1, 2)
-- 		else
-- 			showRedTips(tab:getRedNumLayer(), 0, 0, 2)
-- 		end
-- 	end
-- end


--背包装备洗练引导专用
function DlgRefineShop:showBagEquipRefine(_sUuid)
	-- body
	if not _sUuid then
		return
	end
	doDelayForSomething(self, function (  )
		-- body
		local tEquipVo = Player:getEquipData():getEquipVoByUuid(_sUuid)
		if not tEquipVo then
			return 
		end
		self.pListView:scrollToPosition(nBagIdx)--移动到背包
		local nEquipIndex = 1
		for k , v in pairs(self.tIdleEquipList) do
			if v.sUuid == _sUuid then
				nEquipIndex = k
				break
			end
		end
		if self.tTabItems[nBagIdx] then
			self:setTopTabState(self.tTabItems[nBagIdx], nEquipIndex)
		end	
	end, 1)
end

--武将上阵检测
function DlgRefineShop:onHeroLineUp( )
	--之前武将数据
	local pPreHero = self.tHeroList[self.nTabIdx]
	--存在上阵界面
	self.tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(self.nCurrTab)
	if self.pListView then
		self.pListView:notifyDataSetChange(true, nHeroTag)
		if pPreHero == nil and self.tHeroList[self.nTabIdx] then
			if self.tTabItems then
				self:setTopTabState(self.tTabItems[self.nTabIdx], 1)
			end
		end
	end
end

--切换片上锁设置
function DlgRefineShop:tabLockUpdate( )
	if not self.tHeroTeamTabItems then
		return
	end

	local bIsLock = true
	local tBuildData=Player:getBuildData():getBuildById(e_build_ids.tcf)
	if tBuildData then
		bIsLock = false
	end

	--采集
	local pTabItem = self.tHeroTeamTabItems[2]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    local nNeedLv = 0
			    local tBuild = getBuildDatasByTid(e_build_ids.tcf)
			    if tBuild then
			    	local tData = luaSplit(tBuild.open, ":") 
			    	if tData[2] and tonumber(tData[2]) then
			    		nNeedLv = tonumber(tData[2])
			    	end
			    end
			    TOAST(string.format(getTipsByIndex(20086), nNeedLv))
			end))
		else
			pTabItem:setViewEnabled(true)             
			pTabItem:hideTabLock()
		end
	end

	local bIsLock = true
	if tBuildData and tBuildData.nLv >= tsf_open_citydef_team_lv then
		bIsLock = false
	end
	--城防队列
	local pTabItem = self.tHeroTeamTabItems[3]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    TOAST(getTipsByIndex(20087))
			end))
		else
			pTabItem:setViewEnabled(true)             
			pTabItem:hideTabLock()
		end
	end
end

--顶部功能层开启刷新(建筑开启了强化就开启了, 主要是刷新洗炼功能开启状态)
function DlgRefineShop:topTabLockUpdate()
	-- body
	local bIsLock = true
	--洗炼功能是否开启
	local bOpen, sLockTip = getIsReachOpenCon(21, false)
	if bOpen then
		bIsLock = false
	end
	local pTopTabItem = self.pTopTabItems[n_smith_func_type.train]
	if bIsLock then
		pTopTabItem:showTabLock()
		pTopTabItem:setViewEnabled(false)
		pTopTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTopTabItem:hideTabLock()
		pTopTabItem:setViewEnabled(true)
	end
	--强化功能是否开启
	local bOpen, sLockTip = getIsReachOpenCon(20, false)
	local pTopTabItem = self.pTopTabItems[n_smith_func_type.strengthen]
	if not bOpen then
		pTopTabItem:showTabLock()
		pTopTabItem:setViewEnabled(false)
		pTopTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTopTabItem:hideTabLock()
		pTopTabItem:setViewEnabled(true)
	end
end

function DlgRefineShop:onStrenthResult(sMsgName, pMsgObj)
	-- body
	if self.pTx then
		self.pTx:removeSelf()
		self.pTx = nil
	end
	if pMsgObj then
		if pMsgObj.bSuccess then 	 --强化成功
			local sImg = "#v2_fonts_qhchgo.png"
			if pMsgObj.nStrenType == 1 then
				sImg = "#v2_fonts_pwdchgo.png" --突破成功
			end
			local nArmTag = 18130
			local sName = createAnimationBackName("tx/exportjson/", "rwww_qhzb_dh_001")
		    local pArm = ccs.Armature:create(sName)
		    --替换骨骼
		    changeBoneWithPngAndScale(pArm, "qhcg02", sImg, true) 
		    changeBoneWithPngAndScale(pArm, "qhcg01", sImg, true)
		    if self.tEquipVo then
			    local tEquipData = getBaseEquipDataByID(self.tEquipVo.nId)
			    changeBoneWithPngAndScale(pArm, "qhzb02", tEquipData.sIcon, true) 
			    changeBoneWithPngAndScale(pArm, "qhzb01", tEquipData.sIcon, true)
			end 
		    --设置动画位置
		    pArm:setPosition(self.pEquipImg:getPosition())
		    self.pEquipImg:getParent():addChild(pArm, 10, nArmTag)
		    pArm:getAnimation():play("Animation1", 1)
		    pArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
				if (eventType == MovementEventType.COMPLETE) then
					pArm:removeSelf()
					self.pTx = nil
				end
			end)
			self.pTx = pArm
		else 						 --强化失败
			local pFailImg = MUI.MImage.new("#v2_fonts_qhshibai.png")
		    self.pEquipImg:getParent():addView(pFailImg, 10)
		    pFailImg:setPosition(self.pEquipImg:getPosition())
		    pFailImg:setScale(0.5)
		    local action1 = cc.ScaleTo:create(0.13, 1.15)
		    local action2 = cc.ScaleTo:create(0.08, 1)
		    local action3 = cc.ScaleTo:create(0.54, 1)
		    local action4 = cc.FadeTo:create(0.15, 0)
		    local pAction = cc.Sequence:create(action1, action2, action3, action4)
		    pFailImg:runAction(pAction)
			self.pTx = pFailImg
		end
	end
end

return DlgRefineShop