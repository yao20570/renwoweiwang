-- WeaponItem.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-31 16:26:48 星期三
-- Description: 神兵单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local WeaponItem = class("WeaponItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function WeaponItem:ctor()
	-- body	
	self:myInit()	
	parseView("weapon_item", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function WeaponItem:myInit()
	-- body		
	self.nIndex 			= 	nIndex or 1
	self.tCurData 			= 	nil 				--当前数据	
	self.tBaseData          =   nil                 --配置基础数据
	self.tWeaponSerData     =   nil
end

--解析布局回调事件
function WeaponItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("WeaponItem",handler(self, self.onWeaponItemDestroy))
end

--初始化控件
function WeaponItem:setupViews()
	-- body
	self.pLayRoot       = self:findViewByName("default")
	self.pLayRedTip     = self:findViewByName("lay_redtip")
	self.pImgLevel      = self:findViewByName("img_level")
	self.pLbLevel       = self:findViewByName("lb_level")
	self.pImgWeapon     = self:findViewByName("img_weapons")
	self.pLayBar        = self:findViewByName("lay_bar")
	self.pProBar        = self:findViewByName("pro_bar")
	self.pLbPercent     = self:findViewByName("lb_percent")
	self.pLbUnlock      = self:findViewByName("lb_unlock")
	self.pLayCanmake    = self:findViewByName("lay_canmake")
	self.pLbCanmake     = self:findViewByName("lb_canmake")
	self.pLbCanmake:setString(getConvertedStr(7, 10150))
	self.pLbCanmake:enableOutline(cc.c4b(0, 0, 0, 255),2)

	self.pLayCanmake:setVisible(false)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self.pImgLevel:setVisible(false)

end

-- 修改控件内容或者是刷新控件数据
function WeaponItem:updateViews()
	self.tWeaponSerData = Player:getWeaponInfo()

	self.tBaseData = self.tWeaponSerData:getWeaponByIndex(self.nIndex)
	if self.tBaseData and self.tBaseData.nId == e_weapon_id.sword then
		Player:getNewGuideMgr():setNewGuideFinger(self, e_guide_finer.gequip_sword)
	end

	self.pImgWeapon:setVisible(true)
	self.pImgWeapon:setCurrentImage(self.tBaseData.sIcon)
	self.pImgWeapon:setScale(0.5)

	--人物当前等级
	local roleLevel = Player:getPlayerInfo().nLv

	-- 1、神兵未解锁
	if roleLevel < self.tBaseData.nMakeLv then
		self.pLbUnlock:setVisible(true)
		self.pLbUnlock:setString(string.format(getConvertedStr(7, 10038), self.tBaseData.nMakeLv))
		setTextCCColor(self.pLbUnlock, _cc.red)
		self.pImgWeapon:setToGray(true)

		return
	end

	self.pLbUnlock:setVisible(false)

	local tFragmentsList = self.tWeaponSerData:getFragmentsList()

	--神器名字
	local tWeapName = self.tBaseData.sName
	--神兵服务器数据
	local weaponInfo = self.tBaseData

	--神兵名字层
	if not self.sNameTxt then
		self.sNameTxt = self:createLabels(cc.p(125, 45))
	end
	--神兵状态层
	if not self.sStateTxt then
		self.sStateTxt = self:createLabels(cc.p(125, 23))
	end
	self.sStateTxt:setVisible(true)

	-- 2、神兵未打造
	if not weaponInfo.nWeaponId then
		self.pImgWeapon:setToGray(true)
		local nNeedFragment = self.tBaseData.nNeedFra
		local sCanBuild = getConvertedStr(7, 10027)
		local _color = _cc.red
		local nCurFragment = 0
		if tFragmentsList[self.tBaseData.nId] then
			nCurFragment = tFragmentsList[self.tBaseData.nId].nFragments
		end
		local tStateStr = {}
		if nCurFragment >= nNeedFragment then   --可打造,分子显示绿色
			_color = _cc.green
			sCanBuild = getConvertedStr(7, 10028)
			self.pLayCanmake:setVisible(true) --可打造图片
			tStateStr = {
				{text = getConvertedStr(7, 10011)},
				{text = nCurFragment, color = getC3B(_color)},
				{text = "/"},
				{text = nNeedFragment},
			}
			self:showRedTip(false)
		else  --不足显示红色
			tStateStr = {
				{text = getConvertedStr(7, 10011)},
				{text = nCurFragment, color = getC3B(_color)},
				{text = "/"},
				{text = nNeedFragment},
			}

			--神器对应的副本关卡已解锁显示红点(神兵碎片列表如果对应副本已通关则存在对应碎片)
			if tFragmentsList[self.tBaseData.nId] then
				self:showRedTip(true)
			else
				self:showRedTip(false)
			end
		end

		
		local tStr = {
			{text = tWeapName, color = getC3B(_cc.purple),},
			{text = sCanBuild, color = getC3B(_color)}
		}
		self.sNameTxt:setString(tStr)


		self.sStateTxt:setString(tStateStr)

		return
	end

	self.pLayCanmake:setVisible(false)

	-- 3、神兵正在打造,左上角锤子动画
	--获取神兵在打造的剩余时间
	local nLeftTime = self.tWeaponSerData:getBuildCDLeftTime(weaponInfo.nWeaponId)
	if nLeftTime> 0 then
		local tStr = {
			{text = tWeapName, color = getC3B(_cc.purple),},
			{text = getConvertedStr(7, 10030), color = getC3B(_cc.green)}
		}
		self.sNameTxt:setString(tStr)

		self.nCDType = e_cd_type.build
		--打造完成倒计时
		tStr = {
			{text = getConvertedStr(7, 10022)},
			{text = "", color = getC3B(_cc.red)}
		}
		self.sStateTxt:setString(tStr)

		--设置时间
		self:setTime()

		unregUpdateControl(self)
		--注册定时器
		regUpdateControl(self, handler(self, self.onUpdateCD))

		return
	end

	self.pImgLevel:setVisible(true)
	self.pLbLevel:setString("Lv."..weaponInfo.nWeaponLv)

	--神兵变亮
	self.pImgWeapon:setToGray(false)

	--神兵ID
	local nId = weaponInfo.nWeaponId

	--判断神兵是否可升级
	if self.tWeaponSerData:isWeaponCanLeveUp(nId) then
		self:showRedTip(true)
	else
		self:showRedTip(false)
	end

	-- 4、已获得神兵信息
	
	--属性名称和属性值
	local sAttrName, nAttack = self.tWeaponSerData:getWeaponAttribute(nId, weaponInfo.nWeaponLv, weaponInfo.nAdvanceLv)

	-- 5、神兵可进阶
	if self.tWeaponSerData:isWeaponCanAdvance(nId) then
		self.pLayBar:setVisible(false)
		--神兵正在进阶
		local nLeftTime = self.tWeaponSerData:getAdvCDLeftTime(nId)
		if nLeftTime > 0 then
			self:showRedTip(false)

			local tStr = {
				{text = tWeapName, color = getC3B(_cc.purple),},
				{text = getConvertedStr(7, 10031), color = getC3B(_cc.green)}
			}
			self.sNameTxt:setString(tStr)

			self.nCDType = e_cd_type.advance
			--进阶完成倒计时
			tStr = {
				{text = getConvertedStr(7, 10023)},
				{text = "", color = getC3B(_cc.red)}
			}
			self.sStateTxt:setString(tStr)
			--设置时间
			self:setTime()
			unregUpdateControl(self)
			--注册定时器
			regUpdateControl(self, handler(self, self.onUpdateCD))
		else
			unregUpdateControl(self)
			--判断进阶材料是否足够
			if self.tWeaponSerData:isCanAdvance(nId,weaponInfo.nAdvanceLv) then
				self:showRedTip(true)
			else
				self:showRedTip(false)
			end
			
			self:weaponAttackText(tWeapName, sAttrName, nAttack)
			local tStr = {
				{text = getConvertedStr(7, 10060), color = getC3B(_cc.green)}
			}
			self.sStateTxt:setString(tStr)
		end
		return
	end

	unregUpdateControl(self)

	self:weaponAttackText(tWeapName, sAttrName, nAttack)


	-- 6、神兵等级已满
	if self.tWeaponSerData:isWeaponFullLv(nId) then
		self.sStateTxt:setString(getConvertedStr(7, 10032))
		return
	end

	--神兵进阶进度
	if self.sStateTxt then
		self.sStateTxt:setVisible(false)
	end
	self.pLayBar:setVisible(true)
	local nPercent = weaponInfo.nProgress
	self.pProBar:setPercent(nPercent)
	self.pLbPercent:setString(nPercent.."%")

end

--每秒刷新
function WeaponItem:onUpdateCD()
	-- body
	self:setTime()
end

--设置时间
function WeaponItem:setTime()
	local fAllTime, fLeftTime, sStr
	if self.nCDType == e_cd_type.build then
		--总时间
		fAllTime = getWeaponInitData().makeTime
		--剩余时间
		fLeftTime = self.tWeaponSerData:getBuildCDLeftTime(self.tBaseData.nId)
		sStr = getConvertedStr(7, 10022)
	elseif self.nCDType == e_cd_type.advance then
		--总时间
		fAllTime = getWeaponInitData().advaTime
		--剩余时间
		fLeftTime = self.tWeaponSerData:getAdvCDLeftTime(self.tBaseData.nId)
		sStr = getConvertedStr(7, 10023)
	end

	if fLeftTime > 0 then
		local tStr = {
			{text = sStr},
			{text = formatTimeToHms(fLeftTime), color = getC3B(_cc.red)}
		}
		self.sStateTxt:setString(tStr)
	else
		unregUpdateControl(self)
		local tStr = {
			{text = sStr},
			{text = "0", color = getC3B(_cc.red)}
		}
		self.sStateTxt:setString("")
	end
end

function WeaponItem:weaponAttackText(_tWeapName, _sAttrName, _nAttack)
	-- body
	if not self.sNameTxt then
		self.sNameTxt = self:createLabels(cc.p(125, 45))
	end
	local tStr = {
		{text = _tWeapName, color = getC3B(_cc.purple)},
		{text = "("},
		{text = _sAttrName},
		{text = "+", color = getC3B(_cc.green)},
		{text = _nAttack, color = getC3B(_cc.green)},
		{text = ")"},
	}
	self.sNameTxt:setString(tStr)
end

--创建组合文本
function WeaponItem:createTableText(_content1, _content2, _content3, _content4, _color1, _color2, _color3, _color4)
	-- body
	local tConTableTip = {}
	tConTableTip.tLabel = {
		{_content1, getC3B(_color1)},
		{_content2, getC3B(_color2)},
		{_content3, getC3B(_color3)},
		{_content4, getC3B(_color4)},
	}
	local pText = createGroupText(tConTableTip)
	pText:setAnchorPoint(0.5, 0.5)
	self.pLayRoot:addView(pText, 10)
	return pText
end

-- 析构方法
function WeaponItem:onWeaponItemDestroy()
	-- body
end

function WeaponItem:setItemIndex(_index)
	self.nIndex = _index
	self:updateViews()
end

--是否显示红点
function WeaponItem:showRedTip(bShow)
	if bShow then
		showRedTips(self.pLayRedTip, 0, 1)
	else
		showRedTips(self.pLayRedTip, 0, 0)
	end
end

function WeaponItem:createLabels(pos)
	-- body
	local pLabel = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
    })
    pLabel:setPosition(pos)
    self.pLayRoot:addView(pLabel, 10)
    return pLabel
end

return WeaponItem




