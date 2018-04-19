-- CountryTnolyItem.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-30 11:44:23 星期五
-- Description: 国家科技单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local CountryTnolyProgress = require("app.layer.newcountry.newcountrytnoly.CountryTnolyProgress")

local CountryTnolyItem = class("CountryTnolyItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CountryTnolyItem:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_country_tnoly", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function CountryTnolyItem:myInit(_index)
	-- body		
	self.nIndex 			= 	_index 				--当前阶段	
	self.tCurData 			= 	nil 				--当前数据	
	self.tImgStars  		= {}
end

--解析布局回调事件
function CountryTnolyItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("CountryTnolyItem",handler(self, self.onCountryTnolyItemDestroy))
end

--初始化控件
function CountryTnolyItem:setupViews()
	-- body
	self.pLayMain = self:findViewByName("lay_main")

	--icon层
	self.pLayIcon = self:findViewByName("lay_icon")

	--名字
	self.pLbName = self:findViewByName("lb_namelv")
	setTextCCColor(self.pLbName, _cc.blue)
	
	--推荐图标
	self.pImgTuijian = self:findViewByName("img_jian")

	self:setViewTouchEnable(true)   
	self:setIsPressedNeedScale(false)
	-- self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onSelfClicked))

	--升级进度信息层
	self.pLayProgress = CountryTnolyProgress.new()
	self.pLayMain:addView(self.pLayProgress, 2)
	self.pLayProgress:setPosition(140, 0)
end

--设置自身点击事件
function CountryTnolyItem:setSelfClickHandler(_handler)
	self._nClickHandler = _handler
end

--自身点击事件
function CountryTnolyItem:onSelfClicked(_pView)
	if self.tCurData == nil then
		return
	end
	if self._nClickHandler then
		self._nClickHandler(self.tCurData)
	else
		--打开科技详情界面
		local tObject = {}
		tObject.nType = e_dlg_index.dlgcountrytnolydetail --dlg类型
		tObject.tData = self.tCurData
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--设置选中状态
function CountryTnolyItem:setSelectedState(_bState)
	self.bOpenState = _bState
end

function CountryTnolyItem:getSelectedState()
	return self.bOpenState 
end

-- 修改控件内容或者是刷新控件数据
function CountryTnolyItem:updateViews()
	-- dump(self.tCurData, "self.tCurData ==")
	if self.tCurData == nil then
		return
	end
	if not self.pIcon then
		local tData = self.tCurData
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,tData)
		self.pIcon.pLayBase:setViewTouched(false)
		--隐藏品质特效
		self.pIcon:setIsShowBgQualityTx(false)
	end
	

	--刷新升级进度
	self.pLayProgress:updateData(self.tCurData)

	
	--推荐科技
	if self.tCurData.nRecommend == 1 then
		self.pImgTuijian:setVisible(true)
	else
		self.pImgTuijian:setVisible(false)
	end
	--名称
	self.pLbName:setString(self.tCurData.sName)
	
end

-- 析构方法
function CountryTnolyItem:onCountryTnolyItemDestroy()
	-- body
end

function CountryTnolyItem:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end

function CountryTnolyItem:getItemData()
	return self.tCurData
end


return CountryTnolyItem
