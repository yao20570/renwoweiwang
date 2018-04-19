-- StrengthenLay.lua
----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2018-01-23 16:17:43 星期二
-- Description: 装备强化层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local StrengthenLay = class("StrengthenLay", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
local nDistanceTime = 500 --强化点击间隔时间(单位毫秒)
function StrengthenLay:ctor()
	--解析文件
	self.tEquipVo = nil
	self.nNeedStone = 0 	--分母显示祝福石个数(最大不超过使总成功率大于100的个数)
	self.nSelectStone = 0 --已选几个祝福石
	self.tLackResId = {}  --缺少消耗资源id
	parseView("strenthen_lay", handler(self, self.onParseViewCallback))
end

--解析界面回调
function StrengthenLay:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("StrengthenLay", handler(self, self.onStrengthenLayDestroy))
end

-- 析构方法
function StrengthenLay:onStrengthenLayDestroy(  )
    self:onPause()
end

function StrengthenLay:regMsgs(  )
	--监听资源刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshResCost))
end

function StrengthenLay:unregMsgs(  )
	--注销背包物品数量发生变化消息
	unregMsg(self, gud_refresh_playerinfo)
end

function StrengthenLay:onResume(  )
	self:regMsgs()
end

function StrengthenLay:onPause(  )
	self:unregMsgs()
end

function StrengthenLay:setupViews(  )
	self.pLayRoot 				= self:findViewByName("strenthen_lay")
	--强化信息及消耗层
	self.pLayInfo 				= self:findViewByName("lay_info")
	
	--左侧第1行强化等级层
	self.pLayLevel 				= self:findViewByName("lay_strengh_lv")
	local pTxtLv 				= self:findViewByName("txt_lv")
	pTxtLv:setString(getConvertedStr(7, 10319))
	setTextCCColor(pTxtLv, _cc.pwhite)
	--当前等级
	self.pLbLvB 				= self:findViewByName("lb_lv_b")
	setTextCCColor(self.pLbLvB, _cc.pwhite)
	--强化后等级
	self.pLbLvA 				= self:findViewByName("lb_lv_a")
	setTextCCColor(self.pLbLvA, _cc.green)

	--左侧第2行属性增加层
	self.pLayLAttr 				= self:findViewByName("lay_attr")
	--属性名称
	self.pTxtAttr 				= self:findViewByName("txt_attr")
	setTextCCColor(self.pTxtAttr, _cc.pwhite)
	--当前属性值
	self.pLbAttrB 				= self:findViewByName("lb_attr_value_b")
	setTextCCColor(self.pLbAttrB, _cc.pwhite)
	--属性加成
	self.pLbAttrA 				= self:findViewByName("lb_attr_value_a")
	setTextCCColor(self.pLbAttrA, _cc.green)
	
	--左侧第3行消耗层
	self.pLayLCost 				= self:findViewByName("lay_cost")
	self.pTxtCost 				= self:findViewByName("txt_cost")
	self.pTxtCost:setString(getConvertedStr(7, 10318))
	setTextCCColor(self.pTxtCost, _cc.pwhite)

	--突破石消耗层
	self.pLayStrengthStone 		= self:findViewByName("lay_strengthstone")
	local pTxtCost1 			= self:findViewByName("txt_cost_1")
	setTextCCColor(pTxtCost1, _cc.pwhite)
	pTxtCost1:setString(getConvertedStr(7, 10318))
	--突破石icon层
	self.pLayIconStrengthStone 	= self:findViewByName("lay_stone_1")
	
	--祝福石消耗层
	self.pLayBlessStone 		= self:findViewByName("lay_blessstone")
	--祝福石icon层
	self.pLayIconBlessStone 	= self:findViewByName("lay_stone_2")
	--祝福石名字
	self.pLbStoneName 			= self:findViewByName("lb_name")
	setTextCCColor(self.pLbStoneName, _cc.blue)
	--祝福石描述
	self.pLbStoneDesc 			= self:findViewByName("lb_des")
	--祝福石个数选择滑动条层
	self.playSliderBar 			= self:findViewByName("lay_slider")
	--祝福石(当前选择个数/最多允许选择个数)
	self.plbUseStone 			= self:findViewByName("lb_use_stone")
	--减号层
	self.playMinus 				= self:findViewByName("lay_minus")
	--减少按钮
	self.pBtnMinus 				= getSepButtonOfContainer(self.playMinus,TypeSepBtn.MINUS,TypeSepBtnDir.center)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--加号层
	self.playPlus 				= self:findViewByName("lay_add")
	--增加按钮
	self.pBtnPlus 				= getSepButtonOfContainer(self.playPlus,TypeSepBtn.PLUS,TypeSepBtnDir.center)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息
	
	--按钮操作层
	self.pLayOperate 			= self:findViewByName("lay_operate")
	--按钮层
	self.pLayStrenBtn 			= self:findViewByName("lay_btn")
	--vip增加成功率
	self.pLbVipAdd 				= self:findViewByName("lb_vip_add")
	--强化总成功率
	self.pLbSuccess 			= self:findViewByName("lb_success")

	self.pLbFull 				= self:findViewByName("lb_full")
	self.pLbFull:setString(getConvertedStr(7, 10317))
	setTextCCColor(self.pLbFull, _cc.pwhite)

	--成功率已满提示
	self.pLbRateFullTip 		= self:findViewByName("lb_rate_full_tip")
	self.pLbRateFullTip:setString(getConvertedStr(7, 10327)) --成功率已满，无需使用祝福石
	setTextCCColor(self.pLbRateFullTip, _cc.gray)
	--滑动和加减按钮层
	self.pLaySlider 			= self:findViewByName("lay_select_stone")

end

function StrengthenLay:updateViews(  )
	if not self.tEquipVo then
		return
	end
	local tEquipData = Player:getEquipData()
	local tEquip = getBaseEquipDataByID(self.tEquipVo.nId)
	-- dump(tEquip, "tEquip ==")
	if not tEquip then
		return
	end
	self.tEquip = tEquip
	local tAttData = getBaseAttData(tEquip.nAttrId)
	local nQuality = tEquip.nQuality
	local nStrenLv = self.tEquipVo.nStrenthLv
	local bIsFull = tEquipData:getIsStrengthenFull(nQuality, nStrenLv)
	--获取当前属性值
	local nCurAttrValue = self:getAttrValue(1)
	if bIsFull then
		self.pLayInfo:setVisible(false)
		self.pLayOperate:setVisible(false)
		self.pLbFull:setVisible(true)
		if not self.pLayFull then
			self.pLayFull = MUI.MLayer.new()
			self.pLayRoot:addView(self.pLayFull, 2)
			self.pLayFull:setLayoutSize(self.pLayInfo:getWidth(),self.pLayInfo:getHeight())
			self.pLayFull:setPosition(self.pLayInfo:getPosition())
			--强化等级
			self.pLbFullLv = MUI.MLabel.new({text = "", size = 20})
			self.pLayFull:addView(self.pLbFullLv, 1)
			self.pLbFullLv:setPosition(320, 126)
			--强化属性值
			self.pLbFullAttr = MUI.MLabel.new({text = "", size = 20})
			self.pLayFull:addView(self.pLbFullAttr, 2)
			self.pLbFullAttr:setPosition(320, 77)
		end
		
		local str = {
			{text = getConvertedStr(7, 10319), color = _cc.pwhite},
			{text = nStrenLv, color = _cc.green},
		}
		self.pLbFullLv:setString(str)

		if tAttData then
			local str1 = {
				{text = tAttData.sName.."："..getSpaceStr(3), color = _cc.pwhite},
				{text = "+"..nCurAttrValue, color = _cc.green},
			}
			self.pLbFullAttr:setString(str1)
		end
		self.pLayFull:setVisible(true)
	else
		if self.pLayFull then
			self.pLayFull:setVisible(false)
		end
		self.pLbFull:setVisible(false)
		self.pLayInfo:setVisible(true)
		self.pLayOperate:setVisible(true)
		self.pLbLvB:setString(nStrenLv)
		self.pLbLvA:setString(nStrenLv + 1)
		if tAttData then
			self.pTxtAttr:setString(tAttData.sName.."：")
		end
		self.pLbAttrB:setString(nCurAttrValue)
		--获取强化消耗配表数据
		self.tStrenConf = getEquipStrengthInfo(nQuality, nStrenLv + 1)
		-- dump(self.tStrenConf, "self.tStrenConf ==")
		if not self.tStrenConf then
			return
		end
		--获取强化后的属性值
		local nAfterAttrValue = self:getAttrValue(2)
		self.pLbAttrA:setString(nAfterAttrValue)
		if self.tStrenConf.stone and self.tStrenConf.stone > 0 then
			--使用突破石
			self.pLayBlessStone:setVisible(false)
			self.pLayLCost:setVisible(false)
			self.pLbVipAdd:setVisible(false)
			self.pLayStrengthStone:setVisible(true)
			self.pLbSuccess:setPositionY(85)
			-- local str = {
			-- 	{text =  getConvertedStr(7, 10320), color = _cc.pwhite}, --强化总成功率：
			-- 	{text =  (self.tStrenConf.prob*100).."%", color = _cc.yellow}
			-- }
			self.pLbSuccess:setString(getConvertedStr(7, 10330))

			self:refreshStrengthLayer()

			self.nStrenType = 1
		else
			--使用祝福石
			self.pLayStrengthStone:setVisible(false)
			self.pLayLCost:setVisible(true)
			self.pLayBlessStone:setVisible(true)

			self:refreshBlessLayer()

			self.nStrenType = 2
		end
		--强化按钮
		if not self.pBtnStrength then
			self.pBtnStrength = getCommonButtonOfContainer(self.pLayStrenBtn, TypeCommonBtn.L_BLUE, getConvertedStr(7, 10315))
			self.pBtnStrength:onCommonBtnClicked(handler(self, self.onStrengthenClicked))
		end
		if self.nStrenType == 1 then
			self.pBtnStrength:updateBtnText(getConvertedStr(7, 10331)) --突破
			self.pBtnStrength:updateBtnType(TypeCommonBtn.L_YELLOW)

			--新手教程
			Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.smith_strenght_btn)
		else
			self.pBtnStrength:updateBtnText(getConvertedStr(7, 10315)) --强化
			self.pBtnStrength:updateBtnType(TypeCommonBtn.L_BLUE)

			--新手教程
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnStrength, e_guide_finer.smith_strenght_btn)
		end
	end
end

--突破石层
function StrengthenLay:refreshStrengthLayer()
	--突破石icon
	if not self.pStrenStoneIcon then
		local tIconData = getGoodsByTidFromDB(e_item_ids.strengthstone)
		tIconData.nQuality = 3 --因为要蓝色的边框, 所以直接在这改变品质为蓝色
		self.pStrenStoneIcon = getIconGoodsByType(self.pLayIconStrengthStone, TypeIconGoods.HADMORE,
			type_icongoods_show.item, tIconData, TypeIconEquipSize.M)
		self.pStrenStoneIcon:setMoreTextSize(25)
	end
	if not self.pLbStrenStoneCost then
		self.pLbStrenStoneCost = MUI.MLabel.new({text = "", size = 20})
		self.pLayStrengthStone:addView(self.pLbStrenStoneCost, 2)
		self.pLbStrenStoneCost:setPosition(self.pLayIconStrengthStone:getPositionX() + 
			self.pLayIconStrengthStone:getWidth()/2, 23)
	end
	--拥有突破石数量
	self.nHasStrenStone = getMyGoodsCnt(e_item_ids.strengthstone) or 0
	local sColor = _cc.green
	if self.nHasStrenStone < self.tStrenConf.stone then
		sColor = _cc.red
	end
	local str = {
		{text =  self.nHasStrenStone, color = sColor},
		{text =  "/", color = _cc.pwhite},
		{text =  self.tStrenConf.stone, color = _cc.pwhite}
	}
	self.pLbStrenStoneCost:setString(str)
end

--刷新资源消耗(主要是刷新颜色变化)
function StrengthenLay:refreshResCost()
	-- body
	if not self.tStrenConf then
		return
	end
	self.tLackResId = {}
	--左侧第3行消耗数据
	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0
	if self.tStrenConf.resources then
		local tCostRes = luaSplitMuilt(self.tStrenConf.resources, ";", ":")
		if not self.pImgLbRes1 then
			self.pImgLbRes1 = MImgLabel.new({text="", size = 20, parent = self.pLayLCost})
			self.pImgLbRes1:followPos("left", self.pTxtCost:getPositionX() + self.pTxtCost:getWidth(),
				self.pTxtCost:getPositionY(), 0)
		end
		if not self.pImgLbRes2 then
			self.pImgLbRes2 = MImgLabel.new({text="", size = 20, parent = self.pLayLCost})
			self.pImgLbRes2:followPos("left", self.pTxtCost:getPositionX() + self.pTxtCost:getWidth()
				+ self.pImgLbRes1:getWidth() + 100, self.pTxtCost:getPositionY(), 0)
		end
		local nResId = tonumber(tCostRes[1][1])
		local tResData = getItemResourceData(nResId)
		self.pImgLbRes1:setImg(tResData.sIcon, 0.4, "left")
		local sCnt = getResourcesStr(tonumber(tCostRes[1][2]))
		self.pImgLbRes1:setString(sCnt)
		if getMyGoodsCnt(nResId) >= tonumber(tCostRes[1][2]) then
			setTextCCColor(self.pImgLbRes1, _cc.white)
		else
			self.tResList[nResId] = tonumber(tCostRes[1][2])
			setTextCCColor(self.pImgLbRes1, _cc.red)
			table.insert(self.tLackResId, nResId)
		end

		local nResId = tonumber(tCostRes[2][1])
		local tResData = getItemResourceData(nResId)
		self.pImgLbRes2:setImg(tResData.sIcon, 0.4, "left")
		local sCnt = getResourcesStr(tonumber(tCostRes[2][2]))
		self.pImgLbRes2:setString(sCnt)
		if getMyGoodsCnt(nResId) >= tonumber(tCostRes[2][2]) then
			setTextCCColor(self.pImgLbRes2, _cc.white)
		else
			self.tResList[nResId] = tonumber(tCostRes[2][2])
			setTextCCColor(self.pImgLbRes2, _cc.red)
			table.insert(self.tLackResId, nResId)
		end
	end
end

--祝福石层
function StrengthenLay:refreshBlessLayer()
	-- body
	--左侧第3行消耗数据
	self:refreshResCost()
	
	--拥有祝福石数量
	self.nHasStone = getMyGoodsCnt(e_item_ids.blessstone)
	--祝福石
	if not self.pBlessStoneIcon then
		local tIconData = getGoodsByTidFromDB(e_item_ids.blessstone)
		tIconData.nQuality = 3 --因为要蓝色的边框, 所以直接在这改变品质为蓝色
		tIconData.nCt = self.nHasStone
		self.pBlessStoneIcon = getIconGoodsByType(self.pLayIconBlessStone, TypeIconGoods.NORMAL,
			type_icongoods_show.itemnum, tIconData, TypeIconEquipSize.M)
		self.pLbStoneName:setString(tIconData.sName)
		self.pLbStoneDesc:setString(getTextColorByConfigure(tIconData.sDes))
	else
		self.pBlessStoneIcon:setNumber(self.nHasStone)
	end

	--基础成功率
	local nBaseRate = self.tStrenConf.prob*100
	
	local nVip = Player:getPlayerInfo().nVip or 0
	local sVipProb = getEquipInitParam("viprob")
	local tVipProb = luaSplitMuilt(sVipProb, ";", ":")
	--vip增加百分比
	self.nVipAddRate = 0
	if tVipProb[nVip] then
		self.nVipAddRate = (tonumber(tVipProb[nVip][2]))*nBaseRate
		local str = {
			{text =  getConvertedStr(7, 10321), color = _cc.pwhite},    --(含VIP
			{text =  nVip..getSpaceStr(1), color = _cc.pwhite},			--vip等级
			{text =  "+"..self.nVipAddRate.."%", color = _cc.yellow},   --百分比
			{text =  getConvertedStr(7, 10322), color = _cc.pwhite},    --成功率)
		}
		self.pLbVipAdd:setString(str)
	end
	if self.nVipAddRate > 0 then
		self.pLbVipAdd:setVisible(true)
		self.pLbSuccess:setPositionY(100)
	else
		self.pLbVipAdd:setVisible(false)
		self.pLbSuccess:setPositionY(85)
	end
	
	if nBaseRate + self.nVipAddRate >= 100 then
		self.pLbRateFullTip:setVisible(true)
		self.pLaySlider:setVisible(false)
	else
		self.pLbRateFullTip:setVisible(false)
		self.pLaySlider:setVisible(true)
	end
	local nNeedStoneRate =  100 - (nBaseRate + self.nVipAddRate)
	--每个祝福石提升概率
	self.nPerStoneRate = getEquipInitParam("stoneprob") * 100
	if nNeedStoneRate > 0 then
		self.nNeedStone = math.ceil(nNeedStoneRate/self.nPerStoneRate)
	else
		self.nNeedStone = 0
	end
	--如果需要的祝福石个数超过了已拥有的个数, 只显示已拥有的个数(不能超过已拥有的)
	if self.nNeedStone > self.nHasStone then
		self.nNeedStone = self.nHasStone
	end
	
	--滑动条
	if not self.pSliderBar then
		self:createSliderView()
	end
	self.pSliderBar:setSliderValue(0)	--设置滑动条值默认0

	--刷新总成功率
	self:refreshTotalRate()
end

--刷新总成功率
function StrengthenLay:refreshTotalRate()
	-- body
	local nBaseRate = self.tStrenConf.prob*100
	local nRate = nBaseRate + self.nSelectStone*self.nPerStoneRate + self.nVipAddRate
	if nRate > 100 then
		nRate = 100
	end
	local str = {
		{text =  getConvertedStr(7, 10320), color = _cc.pwhite}, --强化总成功率：
		{text =  nRate.."%", color = _cc.yellow}
	}
	self.pLbSuccess:setString(str)

	--刷新当前选择个数
	local str = {
		{text =  self.nSelectStone, color = _cc.blue},
		{text =  "/"..self.nNeedStone, color = _cc.pwhite}

	}
	self.plbUseStone:setString(str)
end

--获取属性值
--nType: 1为当前属性值, 2为强化后的属性值
function StrengthenLay:getAttrValue(nType)
	-- body
	local nValue = 0
	local nAddValue = 0
	local tStrenConf = nil
	if nType == 1 then
		tStrenConf = getEquipStrengthInfo(self.tEquip.nQuality, self.tEquipVo.nStrenthLv)
	elseif nType == 2 then
		tStrenConf = self.tStrenConf
	end
	if tStrenConf then
		local tParam = luaSplitMuilt(tStrenConf.attr, "|", ",")
		for k, pa in pairs(tParam) do
			if tonumber(pa[1]) == self.tEquip.nKind then
				local tAttr = luaSplitMuilt(pa[2], ";", ":")
				if tAttr[1][2] then
					nAddValue = tonumber(tAttr[1][2])
				else
					nAddValue = tonumber(tAttr[2])
				end
				break
			end
		end
	end

	nValue = self.tEquip.nAttrValue + nAddValue

	return nValue
end

--创建滑动条
function StrengthenLay:createSliderView()
	-- body
	self.pSliderBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_1.png"}, 
        {scale9 = true, touchInButton=false})

	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(188, 18)
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)
end

--滑动条释放消息回调
function StrengthenLay:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	local nSelectStone = roundOff(self.nNeedStone*curvalue/100, 1) --获取当前次数
	if nSelectStone <= 0 then
		nSelectStone = 0
	end
	self.nSelectStone = nSelectStone
	if self.nNeedStone > 0 then
		curvalue = self.nSelectStone/self.nNeedStone*100
	else
		curvalue = 0
		local tIconData = getGoodsByTidFromDB(e_item_ids.blessstone)
		TOAST(string.format(getConvertedStr(7, 10323), tIconData.sName))
	end
	--更新进度条显示	
	self.pSliderBar:setSliderValue(curvalue)
end

--滑动改变事件回调
function StrengthenLay:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nSelectStone = roundOff(self.nNeedStone*curvalue/100, 1) --获取当前次数
		if nSelectStone <= 0 then
			nSelectStone = 0
		end
		self.nSelectStone = nSelectStone
	else
		self.bRedoneSV = true
	end
	self:refreshTotalRate()
end

--minusBtn减少按钮点击回调事件
function StrengthenLay:onMinusBtnClicked( pView )
	-- body
	local nSelectStone = self.nSelectStone - 1
	if nSelectStone <= 0  then
		nSelectStone = 0		
	end
	self.nSelectStone = nSelectStone
	self.bRedoneSV = false
	--更新进度条显示
	if self.nNeedStone > 0 then
		self.pSliderBar:setSliderValue(self.nSelectStone/self.nNeedStone*100)
	end
	--祝福石不足提示
	if self.nHasStone == 0 then
		local tIconData = getGoodsByTidFromDB(e_item_ids.blessstone)
		TOAST(string.format(getConvertedStr(7, 10323), tIconData.sName))
	end
end

--plusBtn增加按钮点击回调事件
function StrengthenLay:onPlusBtnClicked( pView )
	-- body
	local nSelectStone = self.nSelectStone + 1
	if nSelectStone > self.nNeedStone then
		nSelectStone = self.nNeedStone		
	end
	self.nSelectStone = nSelectStone	
	self.bRedoneSV = false
	--更新进度条显示	
	if self.nNeedStone > 0 then
		self.pSliderBar:setSliderValue(self.nSelectStone/self.nNeedStone*100)
	end
	--祝福石不足提示
	if self.nHasStone == 0 then
		local tIconData = getGoodsByTidFromDB(e_item_ids.blessstone)
		TOAST(string.format(getConvertedStr(7, 10323), tIconData.sName))
	end
end

--强化按钮点击事件
function StrengthenLay:onStrengthenClicked( pView )
	-- body
	if self.nLastClickTime then
		local nCurTime = getSystemTime(false)
		if (nCurTime - self.nLastClickTime) < nDistanceTime then
			return
		end
	end
	self.nLastClickTime = getSystemTime(false)
	if not self.tEquipVo then
		return
	end
	--判断消耗材料够不够
	if self.nStrenType == 1 then
		--只消耗突破石
		if self.nHasStrenStone < self.tStrenConf.stone then
			local tIconData = getGoodsByTidFromDB(e_item_ids.strengthstone)
			TOAST(string.format(getConvertedStr(7, 10323), tIconData.sName)) --突破石不足
			return
		end

		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContentLetter(getConvertedStr(1,10387))
	    pDlg:setRightHandler(function ()
	    	if self then
	    		SocketManager:sendMsg("reqEquipStrengthen", {self.tEquipVo.sUuid, 0}, handler(self, self.onReqEquipStrengthen))
	    	end     
	        closeDlgByType(e_dlg_index.alert, false)  
	    end)
	    pDlg:showDlg(bNew)
	elseif self.nStrenType == 2 then
		--新手教程
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnStrength)
		
		--判断资源够不够, 不够弹出资源购买窗口
		if #self.tLackResId > 0 then
			goToBuyRes(self.tLackResId[1],self.tResList)
			return
		end
		SocketManager:sendMsg("reqEquipStrengthen", {self.tEquipVo.sUuid, self.nSelectStone}, handler(self, self.onReqEquipStrengthen))
	end

end

--请求强化返回
function StrengthenLay:onReqEquipStrengthen(__msg, __oldmsg)
	-- body
	if __msg.head.state == SocketErrorType.success then				
		--请求成功
		self.tLackResId = {}
		local tObject = {}
		if __msg.body.s == 1 then --强化成功
			tObject.bSuccess = true
		else 					 --强化失败
			tObject.bSuccess = false
		end
		tObject.nStrenType = self.nStrenType
		sendMsg(ghd_equip_strength_result_msg, tObject)
	end
end


function StrengthenLay:setStrengthData(tEquipVo)
	self.tEquipVo = tEquipVo
	self:updateViews()
end



return StrengthenLay