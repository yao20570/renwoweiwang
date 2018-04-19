-- TaskGuideTip.lua
-- Author: dengshulan
-- Date: 2017-08-19 14:37:06
-- description: 任务引导提示框

local MCommonView = require("app.common.MCommonView")
local TaskGuideTip = class("TaskGuideTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function TaskGuideTip:ctor(_sTip)
	-- body
	self:myInit(_sTip)

	parseView("task_guide_tip", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("TaskGuideTip",handler(self, self.onDestroy))
	
end

--初始化参数
function TaskGuideTip:myInit(_sTip)
	self.sTip = _sTip
end

--解析布局回调事件
function TaskGuideTip:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function TaskGuideTip:setupViews( )
	-- local pLbTip = self:findViewByName("lb_tip")
	local pLayRoot = self:findViewByName("root")
	local pLbTip = MUI.MLabel.new({text = "", size = 20, dimensions = cc.size(350, 0)})
	pLayRoot:addView(pLbTip, 10)
	centerInView(pLayRoot, pLbTip)
	if self.sTip then
		pLbTip:setString(self.sTip)
	else
		pLbTip:setString(getTipsByIndex(20011))
	end
end

--析构方法
function TaskGuideTip:onDestroy(  )
	-- body
end



return TaskGuideTip