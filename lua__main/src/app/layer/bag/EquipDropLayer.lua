-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-17 14:12:23 星期六
-- Description: 装备分解掉落物品单元
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local EquipDropLayer = class("EquipDropLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function EquipDropLayer:ctor()
	-- body
	self:myInit()

	parseView("item_drop_layer", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("EquipDropLayer",handler(self, self.onEquipDropLayerDestroy))
	
end

--初始化参数
function EquipDropLayer:myInit()
	-- body
	self.tCurData = nil
end

--解析布局回调事件
function EquipDropLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function EquipDropLayer:setupViews( )
	--装备信息
	self.pLayRoot = self:findViewByName("lay_def")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, nil, TypeIconGoodsSize.L)

	self.pLbTip = self.pLayRoot:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(6, 10428), false)
	setTextCCColor(self.pLbTip, _cc.pwhite)
end

-- 修改控件内容或者是刷新控件数据
function EquipDropLayer:updateViews(  )
	-- body
	if self.tCurData then
		--dump(self.tCurData, "self.tCurData", 100)
		self.pIcon:setCurData(self.tCurData.item)	
		local sStr = nil	
		if self.tCurData.min == 0 or self.tCurData.min == self.tCurData.max then	
			sStr = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10428)},
				{color=_cc.blue, text="*"},
				{color=_cc.blue, text=formatCountToStr(self.tCurData.max)},
			}			
		else			
			sStr = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10428)},
				{color=_cc.blue, text=self.tCurData.min},
				{color=_cc.blue, text="-"},
				{color=_cc.blue, text=self.tCurData.max},
			}
		end
		self.pLbTip:setString(sStr, false)
	end
end

--析构方法
function EquipDropLayer:onEquipDropLayerDestroy(  )
	-- body
	
end

--设置数据 _data
function EquipDropLayer:setCurData(_data)
	if _data then
		self.tCurData = _data 
	else
		self.tCurData = nil
	end
	self:updateViews()
end

return EquipDropLayer