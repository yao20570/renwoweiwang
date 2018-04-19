--
-- Author: liangzhaowei
-- Date: 2017-06-21 17:58:29
-- 活动时间item

local MCommonView = require("app.common.MCommonView")
local ItemActTime = class("ItemActTime", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _tData
function ItemActTime:ctor(_tData)
	-- body
	self:myInit()

	self.pData = _tData
	
	parseView("item_act_time_a", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemActTime",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActTime:myInit()
	self.pData = {} --数据
	self.bFirstReset = true
end

--解析布局回调事件
function ItemActTime:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	

	self:setupViews()
	--self:updateViews()
end

--初始化控件
function ItemActTime:setupViews( )
	--ly 
	self.pLyMain = self:findViewByName("ly_main")        	

	--lb
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTime:setLocalZOrder(10)

	--img
	self.pImgClock =  self:findViewByName("img_clock")

	--如果不是永久类型才执行时间更新函数
	if self.pData and self.pData.nType and self.pData.nType~= 3 then
		regUpdateControl(self, handler(self, self.updateViews))
	else
		self.pLbTime:setString(getConvertedStr(5, 10228),false)
		
	end	
	
end

-- 修改控件内容或者是刷新控件数据
function ItemActTime:updateViews()

	if not self.pData then
		return
	end
	if self.pData.nType and self.pData.getRemainTime  then
		if self.pData:getRemainTime() then
			self.pLbTime:setString(self.pData:getRemainTime(),false)
		end
		if self.bFirstReset then
			self:updataSize()
			self.bFirstReset = false
		end
	end
end
--设置其他内容
function ItemActTime:setContent( _sStr )
	-- body
	if not _sStr then
		return
	end
	unregUpdateControl(self)
	self.pLbTime:setString(_sStr)
end

--析构方法
function ItemActTime:onDestroy(  )
	-- body
	unregUpdateControl(self)
end

--设置数据 _data
function ItemActTime:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()


end

--更新大小
function ItemActTime:updataSize()
	local nLong
	--如果是永久有效设置宽度为260
	if self.pData.nType and self.pData.nType == 3 then
		nLong = 260
	else
		nLong = self.pImgClock:getWidth() + 15 + self.pLbTime:getWidth() +30
	end
	self.pLyMain:setLayoutSize(nLong, self:getHeight())
end


return ItemActTime