-- PowerMarkItem.lua
-----------------------------------------------------
-- author: dengshulan
-- updatetime:  2018-1-16 13:45:55 星期二
-- Description: 战力评分单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local PowerMarkItem = class("PowerMarkItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function PowerMarkItem:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_power_mark", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function PowerMarkItem:myInit(_index)
	-- body
	self.nIdx = _index
	self.tCurData = nil
end

--解析布局回调事件
function PowerMarkItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("PowerMarkItem",handler(self, self.onPowerMarkItemDestroy))
end

--初始化控件
function PowerMarkItem:setupViews()
	-- body
	--渐变背景
	self.pImgBg = self:findViewByName("img_bg")
	if self.nIdx % 2 == 0 then
		self.pImgBg:setVisible(false)
	else
		self.pImgBg:setVisible(true)
	end
	--战力名称
	self.pLbName = self:findViewByName("lb_power_name")
	--战力值
	self.pLbValue = self:findViewByName("lb_power_value")
end

-- 修改控件内容或者是刷新控件数据
function PowerMarkItem:updateViews()
	if self.tCurData == nil then return end
	setTextCCColor(self.pLbName, self.tCurData.color)
	setTextCCColor(self.pLbValue, self.tCurData.color)
	self.pLbName:setString(self.tCurData.name)
	self.pLbValue:setString(self.tCurData.value)

end

-- 析构方法
function PowerMarkItem:onPowerMarkItemDestroy()
	-- body
end

-- 设置单项数据
function PowerMarkItem:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end



return PowerMarkItem
