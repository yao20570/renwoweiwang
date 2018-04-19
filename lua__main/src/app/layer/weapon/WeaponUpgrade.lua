-- WeaponUpgrade.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-01 14:04:10 星期五
-- Description: 神兵升级层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local WeaponUpgrade = class("WeaponUpgrade", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WeaponUpgrade:ctor()
	-- body	
	self:myInit()	
	parseView("weapon_upgrade", handler(self, self.onParseViewCallback))
	self:onResume()
end

--初始化成员变量
function WeaponUpgrade:myInit()
	-- body
	self.nPreWeaponLv           = nil   --神兵的上一次等级
	self.nCurWeaponLv           = nil   --神兵当前等级
end

--解析布局回调事件
function WeaponUpgrade:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("WeaponUpgrade",handler(self, self.onWeaponUpgradeDestroy))
end

--初始化控件
function WeaponUpgrade:setupViews()
	-- body
	self.pLayRoot          = self:findViewByName("default")
	self.pLayBar           = self:findViewByName("lay_bar")
	self.pLayCenterBtn     = self:findViewByName("lay_centerbtn")

	self.pLayBaoji 		   = MUI.MLayer.new()
	self.pLayRoot:addView(self.pLayBaoji, 10)
	local size = self.pLayCenterBtn:getContentSize()
	self.pLayBaoji:setLayoutSize(size.width, size.height)
	self.pLayBaoji:setPosition(self.pLayCenterBtn:getPosition())
	
	--复选按钮层
	self.pLayCheckBox = self:findViewByName("lay_checkbox")
	self.pCheckBox = MUI.MCheckBoxButton.new(
        {on="#v2_img_gouxuan.png", off="#v2_img_gouxuankuang.png"})
	self.pLayCheckBox:addView(self.pCheckBox)
	centerInView(self.pLayCheckBox, self.pCheckBox)
	self.pCheckBox:onButtonStateChanged(function ( bChecked )
		-- body
		--是否自动升级
		self.bSelectAuto = bChecked
		if self.bSelectAuto then
			saveLocalInfo("Weapon_Upgrade_Auto"..Player:getPlayerInfo().pid, 1)
		else
			saveLocalInfo("Weapon_Upgrade_Auto"..Player:getPlayerInfo().pid, 0)
		end
		self:stopAutoUpgrade()
		
	end)
	--复选说明
	self.pLbCheckText      = self:findViewByName("lb_checktext")
	self.pLbCheckText:setString(getConvertedStr(7,10019))

	self.pLayAboveBtnTip   = self:findViewByName("lay_abovebtntip")
	self.pLbPercent        = self:findViewByName("lb_percent")
	self.pLayMaterial      = self:findViewByName("lay_material")
	self.nSecCost          = getWeaponInitData().advaSpeedGold / 60 --每秒所消耗的黄金数
end

--设置自动升级复选框显示状态
function WeaponUpgrade:setAutoUpgradeCheckBoxVis(_bShow)
	-- body
	self.pLayCheckBox:setVisible(_bShow)
	self.pLbCheckText:setVisible(_bShow)
end

--创建打造进度条
function WeaponUpgrade:createWeaponBar(_weaponId)
	-- body
	--隐藏复选框
	self:setAutoUpgradeCheckBoxVis(false)
	self.pWeaponBar = MCommonProgressBar.new({bg = "v1_bar_b3.png", bar = "v1_bar_yellow_11.png", barWidth = 561, barHeight = 16})
	self.pLayBar:addView(self.pWeaponBar)
	centerInView(self.pLayBar, self.pWeaponBar)
	
	self.CDType = e_cd_type.build
	self.nWeaponId = _weaponId

	--加速按钮
	self:createSpeedUpBtn()

	--打造完成时间倒计时组合文本
	local tConTable = {}
	tConTable.tLabel = {
		{getConvertedStr(7, 10022), getC3B(_cc.white)},
		{"11:22:33", getC3B(_cc.red)},
	}
	self.pTimeText =  createGroupText(tConTable)
	self.pTimeText:setAnchorPoint(0.5, 0.5)
	self.pLayRoot:addView(self.pTimeText, 10)
	self.pTimeText:setPosition(290, 222)

	self:setBarAndTime(_weaponId)

	unregUpdateControl(self)
	regUpdateControl(self, handler(self, self.onUpdate))
end

--设置进度和时间
function WeaponUpgrade:setBarAndTime(_weaponId)
	-- body
	--总时间和剩余时间
	local fAllTime, fLeftTime
	if self.CDType == e_cd_type.build then
		fAllTime = getWeaponInitData().makeTime
		fLeftTime = Player:getWeaponInfo():getBuildCDLeftTime(_weaponId)
	elseif self.CDType == e_cd_type.advance then
		fAllTime = getWeaponInitData().advaTime
		fLeftTime = Player:getWeaponInfo():getAdvCDLeftTime(_weaponId)
	end
	self.fNeedTime = fLeftTime or 0
	self.nMoney = math.ceil(self.nSecCost * self.fNeedTime)
	self.pText:setLabelCnCr(1, self.nMoney)

	if fLeftTime > 0 then
		local nPercent = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
		self.pWeaponBar:setPercent(nPercent)
		self.pLbPercent:setString(nPercent.."%")
		self.pTimeText:setLabelCnCr(2, formatTimeToHms(fLeftTime))
	else
		
		self.pWeaponBar:setPercent(100)
		self.pLbPercent:setString("100%")
		self.pTimeText:setLabelCnCr(2, formatTimeToHms(0))
		unregUpdateControl(self)

	end
end

--每秒刷新
function WeaponUpgrade:onUpdate()
	-- body
	self:setBarAndTime(self.nWeaponId)
end

--加速按钮(_type:1加速打造 2加速升阶)
function WeaponUpgrade:createSpeedUpBtn()
	-- body
	self.pBtnSpeedUp = getCommonButtonOfContainer(self.pLayCenterBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(7,10015))
	self.pBtnSpeedUp:onCommonBtnClicked(handler(self, self.onSpeedUpClicked))
	--需要黄金数
	self:createImgGroupText("#v1_img_qianbi.png", 0, _cc.white)
end

--创建升级进度条
function WeaponUpgrade:createUpgradeBar(_weapon, icon, need, has, tGoods, nResId)
	-- body
	local nPercent = _weapon.nProgress
	if not self.pUpgradeBar then
		self.pUpgradeBar = MCommonProgressBar.new({bg = "v1_bar_b3.png", bar = "v1_bar_blue_6.png", barWidth = 561, barHeight = 16})
		self.pLayBar:addView(self.pUpgradeBar)
		centerInView(self.pLayBar, self.pUpgradeBar)
	end
	self.nCurLvPercent = nPercent
	self.pUpgradeBar:setPercent(nPercent)
	self.pLbPercent:setString(nPercent.."%")

	self.nNeedCost = need
	self.nHasNum   = has
	self.nResId = nResId

	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0
	self.tResList[self.nResId] = self.nNeedCost
	--升级消耗和拥有数
	if not self.tCostText then
		self.tCostText = self:createMaterialGroupText(self.pLayRoot, icon, need, has, cc.p(0.5,0.5), cc.p(230, 200))
	else
		local str = formatCountToStr(need)
		if need > has then
			self.tCostText:setLabelCnCr(3, str)
			local str2 = formatCountToStr(has)
			self.tCostText:setLabelCnCr(1, str2, getC3B(_cc.red))
		else
			self.tCostText:setLabelCnCr(3, str)
			local str2 = formatCountToStr(has)
			self.tCostText:setLabelCnCr(1, str2, getC3B(_cc.blue))
		end
		
	end
	self.tCostText:onMViewClicked(function()
		openIconInfoDlg(self.tCostText, tGoods)
	end)
end

--刷新升级材料数量
function WeaponUpgrade:refreshMaterial()
	-- body
	if not self.tCostText then return end
	local tGoods = getGoodsByTidFromDB(self.nResId)
	if tGoods then
		self.nHasNum = getMyGoodsCnt(self.nResId)
	end
	
	local sNeedStr = formatCountToStr(self.nNeedCost)
	if self.nHasNum >= self.nNeedCost then
		self.tCostText:setLabelCnCr(3, sNeedStr)
		local sHasStr = formatCountToStr(self.nHasNum)
		self.tCostText:setLabelCnCr(1,sHasStr, getC3B(_cc.blue))
	else
		self.tCostText:setLabelCnCr(3, sNeedStr)
		local sHasStr = formatCountToStr(self.nHasNum)
		self.tCostText:setLabelCnCr(1,sHasStr, getC3B(_cc.red))
	end
end

--材料组合文本(消耗和拥有数)
function WeaponUpgrade:createMaterialGroupText(_parent, _img, _needNum, _hasNum, _anchor, pos)
	local tConTable = {}
	local pColor = _cc.blue
	if _needNum > _hasNum then
		pColor = _cc.red
	end
	local tLb= {
		{formatCountToStr(_hasNum), getC3B(pColor)},
		{"/", getC3B(_cc.white)},
		{formatCountToStr(_needNum), getC3B(_cc.white)},
	}
	tConTable.tLabel = tLb
	tConTable.img = _img
	local pText =  createGroupText(tConTable)
	pText:setAnchorPoint(_anchor)
	_parent:addView(pText, 10)
	pText:setPosition(pos)
	pText:setViewTouched(true)
	return pText
end

--升级按钮
function WeaponUpgrade:createUpgradeBtn(_nWeaponId, _nCritical, _fRise)
	-- body
	--显示复选框
	self:setAutoUpgradeCheckBoxVis(true)
	if _nWeaponId ~= self.nWeaponId then
		self:stopAutoUpgrade()
	end
	self.nWeaponId = _nWeaponId
	--当前几倍暴击
	self.nCurCritical = _nCritical

	if not self.pTextTip then
		self.pTextTip = self:createTextTableTip(getConvertedStr(7, 10024), _fRise.."%", getConvertedStr(7, 10025), cc.p(290, 146), _cc.blue)
	end

	if not self.pBtnUpgrade then
		self.pBtnUpgrade = getCommonButtonOfContainer(self.pLayCenterBtn, TypeCommonBtn.L_BLUE, getConvertedStr(7,10016))
		self.pBtnUpgrade:onCommonBtnClicked(handler(self, self.onUpgradeClicked))
		local sState = getLocalInfo("Weapon_Upgrade_Auto"..Player:getPlayerInfo().pid, "0")
		self.pCheckBox:setButtonSelected(tonumber(sState) == 1)
		self.bSelectAuto = tonumber(sState) == 1
		if self.bSelectAuto then
			self.pBtnUpgrade:updateBtnText(getConvertedStr(7,10259))
		else
			self.pBtnUpgrade:updateBtnText(getConvertedStr(7,10016))
		end
	end
	if self.nCurCritical == 1 then
		--提升经验
		self.pTextTip:setLabelCnCr(2, _fRise.."%")
		if self.pBtnBaoji then
			self.pLayBaoji:setVisible(false)
		end
		self.pLayCenterBtn:setVisible(true)
	elseif _nCritical > 1 then
		self:showBaoji(_nCritical, _nCritical*_fRise)
	end
	--更新按钮
	self:updateUpgradeBtn()
	
end

--开启自动升级
function WeaponUpgrade:openAutoUpgrade()
	if self.nHasNum < self.nNeedCost then
		goToBuyRes(self.nResId, self.tResList)
		return
	end
	self.bAutoUpgrade = true
	local tInitData = getWeaponInitData()
	local interval = tInitData.upterval        --自动升级间隔
	if not self.nUpdateScheduler then
		self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
			--是否满足升级条件
			local bCanUpgrade = Player:getWeaponInfo():isWeaponCanLeveUp(self.nWeaponId)
			if bCanUpgrade then
				self:reqUpgradeWeapon()
				self.nUpgradeTimes = self.nUpgradeTimes + 1    -- 自动升级次数
				local tObj = {}
				tObj.bShow = true
				tObj.nUpgradeTimes = self.nUpgradeTimes
				sendMsg(ghd_weapon_auto_upgrade_tip, tObj)
			else
				self:stopAutoUpgrade()
			end
		end, interval)
	end
	--更新按钮
	self:updateUpgradeBtn()
end

--停止自动升级
function WeaponUpgrade:stopAutoUpgrade()
	self.bAutoUpgrade = false
	self.nAutoUpgradeTimes = 0
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	
	self.nUpgradeTimes = 0

	local tObj = {}
	tObj.bShow = false
	tObj.nUpgradeTimes = self.nUpgradeTimes
	sendMsg(ghd_weapon_auto_upgrade_tip, tObj)

	--更新按钮
	self:updateUpgradeBtn()
	
end

--刷新升级和暴击按钮
function WeaponUpgrade:updateUpgradeBtn()
	if not self.pBtnUpgrade and not self.pBtnBaoji then return end
	if self.bAutoUpgrade then
		self.pBtnUpgrade:updateBtnText(getConvertedStr(7, 10260)) --停止升级
		self.pBtnUpgrade:updateBtnType(TypeCommonBtn.L_RED)
	else
		--自动升级没有暴击按钮
		if self.bSelectAuto then
			self.pBtnUpgrade:updateBtnText(getConvertedStr(7,10259))
			if self.pBtnBaoji then
				self.pLayBaoji:setVisible(false)
			end
			self.pBtnUpgrade:updateBtnType(TypeCommonBtn.L_BLUE)
			self.pLayCenterBtn:setVisible(true)
		else
			if self.nCurCritical and self.nCurCritical > 1 then
				if self.pBtnBaoji then
					self.pLayBaoji:setVisible(true)
				else
					self.pBtnBaoji = getCommonButtonOfContainer(self.pLayBaoji, TypeCommonBtn.L_YELLOW, self.nCurCritical..getConvertedStr(7,10018))
					self.pBtnBaoji:onCommonBtnClicked(handler(self, self.onBaojiClicked))
					self.pBtnBaoji:updateBtnType(TypeCommonBtn.L_YELLOW)
					self.pBtnBaoji:updateBtnText(self.nCurCritical..getConvertedStr(7,10018))
					self.pLayBaoji:setVisible(true)
				end
				self.pLayCenterBtn:setVisible(false)
			elseif self.nCurCritical and self.nCurCritical <= 1 then
				self.pBtnUpgrade:updateBtnText(getConvertedStr(7,10016))
				self.pBtnUpgrade:updateBtnType(TypeCommonBtn.L_BLUE)
				self.pLayCenterBtn:setVisible(true)
			end
		end
	end
end


--发送升级神兵请求
function WeaponUpgrade:reqUpgradeWeapon()
	-- body
	if self.nHasNum >= self.nNeedCost then
		--发送请求时的活动暴击数
		local nActivtCrit = nil
		local tData = Player:getActById(e_id_activity.magiccrit)
		if tData then
			nActivtCrit = tData:getCrit(self.nWeaponId)
		end
		SocketManager:sendMsg("reqWeaponLevelUp", {self.nWeaponId, nActivtCrit},function ( __msg )
			-- body
		end)
	else
		goToBuyRes(self.nResId, self.tResList)
	end
end

--出现暴击
function WeaponUpgrade:showBaoji(_critical, _nExp)
	--当前几倍暴击
	self.nCurCritical = _critical
	-- body
	--如果单次升级出现暴击的时候显示暴击
	if not self.bSelectAuto then
		if self.pBtnUpgrade then
			self.pLayCenterBtn:setVisible(false)
		end
		
		if not self.pBtnBaoji then
			self.pBtnBaoji = getCommonButtonOfContainer(self.pLayBaoji, TypeCommonBtn.L_YELLOW, _critical..getConvertedStr(7,10018))
			self.pBtnBaoji:onCommonBtnClicked(handler(self, self.onBaojiClicked))
		end
		self.pBtnBaoji:updateBtnType(TypeCommonBtn.L_YELLOW)
		self.pBtnBaoji:updateBtnText(_critical..getConvertedStr(7,10018))
		self.pLayBaoji:setVisible(true)
	else
		if self.pBtnBaoji then
			self.pLayBaoji:setVisible(false)
		end
		if self.pBtnUpgrade then
			self.pLayCenterBtn:setVisible(true)
		end
	end
	if not self.pTextTip then
		self.pTextTip = self:createTextTableTip(getConvertedStr(7, 10024), _nExp.."%", getConvertedStr(7, 10025), cc.p(290, 146), _cc.blue)
	end
	--重置文本(提升经验)
	self.pTextTip:setLabelCnCr(2, _nExp.."%")
end


--升级提示、进阶进度组合文本
function WeaponUpgrade:createTextTableTip(_content1, _content2, _content3, _pos, _color)
	-- body
	local tConTableTip = {}
	tConTableTip.tLabel = {
		{_content1, getC3B(_cc.white)},
		{_content2, getC3B(_color)},
		{_content3, getC3B(_cc.white)},
	}
	local pTextTip = createGroupText(tConTableTip)
	pTextTip:setAnchorPoint(0.5, 0.5)
	self.pLayRoot:addView(pTextTip, 10)
	pTextTip:setPosition(_pos)
	return pTextTip
end

--进阶按钮
function WeaponUpgrade:createAdvanceBtn(_nWeaponId, _costs, _time, _curStep, _allStep)
	--隐藏复选框
	self:setAutoUpgradeCheckBoxVis(false)
	self.tAdvCost = _costs
	-- body
	self.nWeaponId = _nWeaponId
	--进阶所需材料
	local tCost, tGoods = {}, {}
	local i = 0
	for nId, value in pairs(_costs) do
		i = i+1
		local pGood = getGoodsByTidFromDB(nId)
		local pRes
		if pGood then
			tGoods[i] = pGood
			pRes = pGood.sIcon --材料图片名字
			tCost[i] = {need = value, has = getMyGoodsCnt(nId), resName = pRes}
		end
	end
	for k, v in pairs(tCost) do
		if k == 1 then
			local pLayCost1 = self:createMaterialGroupText(self.pLayMaterial, v.resName, v.need, v.has, cc.p(0,0.5), cc.p(0, 35))
			pLayCost1:onMViewClicked(function()
				openIconInfoDlg(pLayCost1, tGoods[k])
			end)
			if table.nums(tCost) == 1 then
				centerInView(self.pLayMaterial, pLayCost1)
			end
		elseif k == 2 then
			local pLayCost2 = self:createMaterialGroupText(self.pLayMaterial, v.resName, v.need, v.has, cc.p(0,0.5), cc.p(303, 35))
			pLayCost2:onMViewClicked(function()
				openIconInfoDlg(pLayCost2, tGoods[k])
			end)
		end
	end

	--进阶所需时间
	self.pLayNeedTime = self:createImgGroupText("#v1_img_clock.png", formatTimeToHms(_time), _cc.red)
	--进阶按钮
	self.pBtnAdvance = getCommonButtonOfContainer(self.pLayCenterBtn, TypeCommonBtn.L_BLUE, getConvertedStr(7,10017))
	self.pBtnAdvance:onCommonBtnClicked(handler(self, self.onAdvanceClicked))
	--进阶进度
	local pColor = _cc.blue
	if _curStep == 0 then
		pColor = _cc.red
	end
	self.pAdvanceTip = self:createTextTableTip(getConvertedStr(7, 10020), _curStep, "/".._allStep, cc.p(290, 29), pColor)
end

--进阶过程显示(进阶完成倒计时)
function WeaponUpgrade:showAdvanceCount(_weaponId)
	-- body
	--隐藏复选框
	self:setAutoUpgradeCheckBoxVis(false)
	--进阶进度条
	self.pWeaponBar = MCommonProgressBar.new({bg = "v1_bar_b3.png", bar = "v1_bar_yellow_11.png", barWidth = 561, barHeight = 16})
	self.pLayBar:addView(self.pWeaponBar)
	centerInView(self.pLayBar, self.pWeaponBar)

	self.nWeaponId = _weaponId
	self.CDType = e_cd_type.advance

	--加速按钮
	self:createSpeedUpBtn()

	--进阶完成时间倒计时组合文本
	local tConTable = {}
	tConTable.tLabel = {
		{getConvertedStr(7, 10023), getC3B(_cc.white)},
		{"01:55:20", getC3B(_cc.red)},
	}
	self.pTimeText =  createGroupText(tConTable)
	self.pTimeText:setAnchorPoint(0.5, 0.5)
	self.pLayRoot:addView(self.pTimeText, 10)
	self.pTimeText:setPosition(290, 222)

	self:setBarAndTime(_weaponId)

	unregUpdateControl(self)
	regUpdateControl(self, handler(self, self.onUpdate))
end

--进阶和加速按钮上面的图片和文字组合文本
function WeaponUpgrade:createImgGroupText(_img, _text, _color)
	-- body
	self.pLayAboveBtnTip:removeAllChildren()
	local tConTable = {}
	tConTable.tLabel = {
		{_text, getC3B(_color)},
	}
	tConTable.img = _img
	self.pText =  createGroupText(tConTable)
	self.pText:setAnchorPoint(0.5, 0.5)
	self.pLayAboveBtnTip:addView(self.pText, 10)
	self.pText:setPosition(97, 16)
	return self.pText
end

-- 加速完成按钮点击事件
function WeaponUpgrade:onSpeedUpClicked(_pView)
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgspeedupadvance --dlg类型
	tObject.nCost = self.nMoney
	tObject.nSpeedType = self.CDType     --加速打造还是加速进阶
	tObject.nWeaponId = self.nWeaponId
	sendMsg(ghd_show_dlg_by_type,tObject)
end


-- 升级按钮点击事件
function WeaponUpgrade:onUpgradeClicked(_pView)
	-- body
	if not _pView:isVisible() then return end

	if self.pBtnUpgrade:getBtnText() == getConvertedStr(7, 10260) then --停止升级
		self:stopAutoUpgrade()
	else
		if self.bSelectAuto then
			--开启自动升级
			self:openAutoUpgrade()
		else
			self:reqUpgradeWeapon()
		end
	end
end

-- 暴击按钮点击事件
function WeaponUpgrade:onBaojiClicked(_pView)
	if not _pView:isVisible() then return end
	self:reqUpgradeWeapon()
end

--进阶按钮点击事件
function WeaponUpgrade:onAdvanceClicked(_pView)
	-- body
	for resId, value in pairs(self.tAdvCost) do
		if value > getMyGoodsCnt(tonumber(resId)) then
			goToBuyRes(resId)
			return
		end
	end
	--发送进阶请求
	SocketManager:sendMsg("reqWeaponAdvance", {self.nWeaponId})
end

-- 修改控件内容或者是刷新控件数据
function WeaponUpgrade:updateViews()

end

-- 析构方法
function WeaponUpgrade:onWeaponUpgradeDestroy()
	-- body
	self:onPause()
	--记录自动升级状态
	if self.bSelectAuto then
		saveLocalInfo("Weapon_Upgrade_Auto"..Player:getPlayerInfo().pid, 1)
	else
		saveLocalInfo("Weapon_Upgrade_Auto"..Player:getPlayerInfo().pid, 0)
	end
	self:stopAutoUpgrade()
end

function WeaponUpgrade:setItemIndex(_index)
	self.nIndex = _index
	self:updateViews()
end

-- 注册消息
function WeaponUpgrade:regMsgs( )
	-- body
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshMaterial))
end

-- 注销消息
function WeaponUpgrade:unregMsgs(  )
	-- body
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function WeaponUpgrade:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function WeaponUpgrade:onResume( )
	-- body
	self:regMsgs()
	
end


return WeaponUpgrade