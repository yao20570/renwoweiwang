-- Author: wenzongyao
-- Date: 2018-1-30 11:30:29
-- 活动排行没有排名提示

local MCommonView = require("app.common.MCommonView")
local ItemActCard = require("app.layer.activitya.ItemActCard")

local ActivityRankNoneTip = class("ActivityRankNoneTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ActivityRankNoneTip:ctor()
	-- body
	self:myInit()

	parseView("lay_rank_none_tip", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ActivityRankNoneTip",handler(self, self.onDestroy))
	
end

--初始化参数
function ActivityRankNoneTip:myInit()
	
end

--析构方法
function ActivityRankNoneTip:onDestroy(  )
	-- body

end

--解析布局回调事件
function ActivityRankNoneTip:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ActivityRankNoneTip:setupViews( )
	-- 文本提示
	self.pLayTip = self:findViewByName("lab_tip")
    self.pLayTip:setString(getConvertedStr(10, 90002))
    setTextCCColor(self.pLayTip, _cc.pwhite)

    -- 文本背景
    local size = self.pLayTip:getContentSize()
	self.pLayTipBg = self:findViewByName("lay_tip_bg")
	self.pLayTipBg:setContentSize(size.width + 10)
    
end

-- 修改控件内容或者是刷新控件数据
function ActivityRankNoneTip:updateViews(  )
	
end


return ActivityRankNoneTip

