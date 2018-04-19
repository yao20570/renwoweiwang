----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-26 20:55:00
-- Description: 皇城战 时间条
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local EpwCd = class("EpwCd", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function EpwCd:ctor()
	-- body
	self:myInit()
	parseView("item_act_time_a", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("EpwCd",handler(self, self.onDestroy))
end

--初始化参数
function EpwCd:myInit()
	self.bFirstReset = true
end

--解析布局回调事件
function EpwCd:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	
	self:setupViews()
	self:onResume()
end

--初始化控件
function EpwCd:setupViews( )
	--ly 
	self.pLyMain = self:findViewByName("ly_main")        	

	--lb
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTime:setLocalZOrder(10)

	--img
	self.pImgClock =  self:findViewByName("img_clock")	
end

-- 修改控件内容或者是刷新控件数据
function EpwCd:updateViews()
	local sStr = nil
	if Player:getImperWarData():getImperWarIsOpen() then
		sStr = getConvertedStr(3, 10828)
	else
		local nCd = Player:getImperWarData():getOpenCd()
		local sTimeFormat = getConvertedStr(3, 10816)
		sStr = string.format(sTimeFormat, getTimeLongStr(nCd,false,true))
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
function EpwCd:onDestroy(  )
	self:onPause()
end

function EpwCd:onResume( )
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
end

function EpwCd:onPause( )
	unregUpdateControl(self)
end

--更新大小
function EpwCd:updataSize()
	local nLong = self.pImgClock:getWidth() + 15 + self.pLbTime:getWidth() +30
	self.pLyMain:setLayoutSize(nLong, self:getHeight())
end


return EpwCd