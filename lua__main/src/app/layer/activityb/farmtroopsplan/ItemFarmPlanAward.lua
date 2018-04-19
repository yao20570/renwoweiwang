-- ItemFarmPlanAward.lua
----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-08-08 13:03:31
-- Description: 屯田计划单个奖励子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemFarmPlanAward = class("ItemFarmPlanAward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemFarmPlanAward:ctor()
	parseView("item_farm_plan_award", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemFarmPlanAward:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemFarmPlanAward",handler(self, self.onItemFarmPlanAwardDestroy))
end

function ItemFarmPlanAward:regMsgs(  )
end

function ItemFarmPlanAward:unregMsgs(  )
end

function ItemFarmPlanAward:onResume(  )
	self:regMsgs()
end

function ItemFarmPlanAward:onPause(  )
	self:unregMsgs()
end


function ItemFarmPlanAward:onItemFarmPlanAwardDestroy(  )
	self:onPause()
end

function ItemFarmPlanAward:setupViews()
	self.pLayIcon = self:findViewByName("lay_icon")
end


function ItemFarmPlanAward:setItemInfo(_str, _color)
	if not self.pLbDay then
		self.pLbDay = self:findViewByName("lb_day")
	end
	self.pLbDay:setString(_str)
	setTextCCColor(self.pLbDay, _color)
	self.color = _color
end

function ItemFarmPlanAward:setTextToGray(_state)
	-- body
	if _state then
		setTextCCColor(self.pLbDay, _cc.gray)
	else
		setTextCCColor(self.pLbDay, self.color)
	end
end



return ItemFarmPlanAward
