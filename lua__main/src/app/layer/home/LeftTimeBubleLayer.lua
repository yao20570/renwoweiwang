--
-- Author: tanqian
-- Date: 2017-09-27 14:24:28
--剩余时间冒泡展示Layer
local MCommonView = require("app.common.MCommonView")
local LeftTimeBubleLayer = class("LeftTimeBubleLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LeftTimeBubleLayer:ctor()
	
	parseView("layout_lefttime_buble", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LeftTimeBubleLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:onResume()
	self:updateViews()
	-- self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("LeftTimeBubleLayer",handler(self, self.onDestroy))
end


function LeftTimeBubleLayer:setupViews(  )
	self.pLbTime = self:findViewByName("txt_left_time")

	

	self:setTime("00:00:00")


end

function LeftTimeBubleLayer:setTime( _sTime )
	if not _sTime then
		return 
	end
	local tLabel = {
		{text = getConvertedStr(8, 10033) ..getSpaceStr(1), color = getC3B(_cc.pwhite)},
		{text = _sTime, color = getC3B(_cc.red)}
	}
	self.pLbTime:setString(tLabel)
end
function LeftTimeBubleLayer:onResume()
	regUpdateControl(self, handler(self, self.onUpdateTime))
end

function LeftTimeBubleLayer:onUpdateTime()
	local nHjLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
	if nHjLeftTime > 0 then		
		self:setTime(formatTimeToHms(nHjLeftTime))
	end
end


function LeftTimeBubleLayer:updateViews(  )
	local nHjLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
	if nHjLeftTime > 0 then		
		self:setTime(formatTimeToHms(nHjLeftTime))
	end
end
-- 析构方法
function LeftTimeBubleLayer:onDestroy(  )
	unregUpdateControl(self)--停止计时刷新
end
return LeftTimeBubleLayer
