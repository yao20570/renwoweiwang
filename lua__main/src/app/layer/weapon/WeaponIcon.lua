-- WeaponIcon.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-05 16:14:48 星期一
-- Description: 神兵图标层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local WeaponIcon = class("WeaponIcon", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WeaponIcon:ctor(_index, _goPage, _pageView)
	-- body	
	self:myInit(_index, _goPage, _pageView)	
	parseView("weapon_icon", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function WeaponIcon:myInit(_index, _goPage, _pageView)
	-- body
	self.nIndex = _index
	self.nGoPage = _goPage
	self.pPageView = _pageView
end

--解析布局回调事件
function WeaponIcon:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	-- self:updateViews()

	--注册析构方法
	self:setDestroyHandler("WeaponIcon",handler(self, self.onWeaponIconDestroy))
end

--初始化控件
function WeaponIcon:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("default")
	self.pImgLock = self:findViewByName("img_lock")
	self.pLayMaking = self:findViewByName("lay_making")
	self.pLbMaking = self:findViewByName("lb_making")
	self.pLbMaking:setString(getConvertedStr(7, 10137))

	self.pImgLock:setVisible(false)
	self.pLayMaking:setVisible(false)
	self:setIsPressedNeedScale(true)
	self:setIsPressedNeedColor(false)
	self.tBaseData = Player:getWeaponInfo():getWeaponInfoById(200+self.nIndex)
	local data = {}
	data.sIcon = self.tBaseData.sIcon
	data.nQuality = self.tBaseData.nQuality
	self.weaponIcon = getIconGoodsByType(self.pLayRoot, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconEquipSize.M)
	self.weaponIcon:removeQualityTx()
end

-- 修改控件内容或者是刷新控件数据
function WeaponIcon:updateViews(roleLevel, tWeaponInfo)
	self.weaponIcon:setIconClickedCallBack(function()
		-- body
		self.pPageView:gotoPage(self.nGoPage, false)
	end)
	if roleLevel < self.tBaseData.nMakeLv then
		self.pImgLock:setVisible(true)
		-- self.weaponIcon:hideIconImg(true)
		self.weaponIcon:setIconToGray(true)
		return
	else
		self.pImgLock:setVisible(false)
		-- self.weaponIcon:hideIconImg(false)
		self.weaponIcon:setIconToGray(false)
	end
	if not tWeaponInfo then
		self.weaponIcon:showLeftTopLayer(getLvString( "0"))
		return
	end
	if tWeaponInfo.nBuildCD and tWeaponInfo.nBuildCD > 0 then
		self.pLayMaking:setVisible(true)
	end
	if tWeaponInfo.nWeaponLv > 0 then
		self.pLayMaking:setVisible(false)
	end
	-- local tWeaponInfo = Player:getWeaponInfo():getWeaponInfoById(tBaseData.id)
	-- local data = {}
	-- data.sIcon = tBaseData.icon..".png"
	-- data.nGtype = e_type_goods.type_item --神兵
	-- data.nQuality = tBaseData.quality
	-- data.nLv = tWeaponInfo.nWeaponLv
	self.weaponIcon:showLeftTopLayer(getLvString(tWeaponInfo.nWeaponLv))
	
end

function WeaponIcon:setIconScale(_nScale)
	self.weaponIcon:setScale(_nScale)
	if self.pLayMaking:isVisible() then
		if _nScale == 0.8 then
			self.pLayMaking:setScale(_nScale+0.1)
			self.pLayMaking:setPosition(0, 30)
		else
			self.pLayMaking:setScale(_nScale+0.2)
			self.pLayMaking:setPosition(4, 34)
		end
	end
end

-- 析构方法
function WeaponIcon:onWeaponIconDestroy()
	-- body
end

function WeaponIcon:createLabels()
	-- body
	local pLabel = MUI.MLabel.new({
    text = "",
    size = 20,
    anchorpoint = cc.p(0, 0.5)})
    pLabel:setPosition(self.pLayRoot:getWidth()/10, self.pLayRoot:getHeight()/2)
    setTextCCColor(pLabel, _cc.pwhite)
    self.pLayRoot:addView(pLabel)    
    self.tLabel = pLabel
end

return WeaponIcon