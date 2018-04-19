----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 16:59:00
-- Description: 限时Boss 时间条
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local TLBossCd = class("TLBossCd", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function TLBossCd:ctor()
	-- body
	self:myInit()
	parseView("item_act_time_a", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("TLBossCd",handler(self, self.onDestroy))
end

--初始化参数
function TLBossCd:myInit()
	self.bFirstReset = true
end

--解析布局回调事件
function TLBossCd:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	
	self:setupViews()
	self:onResume()
end

--初始化控件
function TLBossCd:setupViews( )
	--ly 
	self.pLyMain = self:findViewByName("ly_main")        	

	--lb
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTime:setLocalZOrder(10)

	--img
	self.pImgClock =  self:findViewByName("img_clock")	
end

-- 修改控件内容或者是刷新控件数据
function TLBossCd:updateViews()
	local nState = Player:getTLBossData():getCdState()
	local sStr = nil
	if nState == e_tlboss_time.no then
		local sTimeFormat = getConvertedStr(3, 10815)
		sStr = string.format(sTimeFormat, getTimeLongStr(Player:getTLBossData():getCd(),false,true))
	elseif nState == e_tlboss_time.ready then
		local sTimeFormat = getConvertedStr(3, 10816)
		sStr = string.format(sTimeFormat, getTimeLongStr(Player:getTLBossData():getCd(),false,true))
	elseif nState == e_tlboss_time.begin then
		sStr = getConvertedStr(3, 10829)
	end
	if sStr then
		self.pLbTime:setString(sStr,false)

		if self.bFirstReset then
			self:updataSize()
			self.bFirstReset = false
		end
	end
end

--析构方法
function TLBossCd:onDestroy(  )
	self:onPause()
end

function TLBossCd:onResume( )
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
end

function TLBossCd:onPause( )
	unregUpdateControl(self)
end

--更新大小
function TLBossCd:updataSize()
	local nLong = self.pImgClock:getWidth() + 15 + self.pLbTime:getWidth() +30
	self.pLyMain:setLayoutSize(nLong, self:getHeight())
end


return TLBossCd