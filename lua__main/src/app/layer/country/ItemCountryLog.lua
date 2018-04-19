----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-09 19:48:14
-- Description:国家日志
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemCountryLog = class("ItemCountryLog", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryLog:ctor(  )
	-- body
	self:myInit()
	parseView("countrylog_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemCountryLog:myInit(  )
	-- body
	self.pCurData = nil
end

--解析布局回调事件
function ItemCountryLog:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryLog",handler(self, self.onItemCountryLogDestroy))
end

--初始化控件
function ItemCountryLog:setupViews( )
	-- body
	local tTime =  os.date("*t", getSystemTime())	
	self.pLbTime1 = self:findViewByName("lb_time_1")
	setTextCCColor(self.pLbTime1, _cc.gray)	
	self.pLbTime1:setString(string.format("%04d",tTime.year).."-"..string.format("%02d",tTime.month)..
        "-"..string.format("%02d",tTime.day))
	self.pLbTime2 = self:findViewByName("lb_time_2")
	setTextCCColor(self.pLbTime2, _cc.gray)
	self.pLbTime2:setString(string.format("%02d",tTime.hour)..
        ":"..string.format("%02d",tTime.min)..":"..string.format("%02d",tTime.sec))
	self.pLbContent = self:findViewByName("lay_content") 

	self.pLbLog = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 0.5),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(self.pLbContent:getWidth(), 0),
		    })	
	self.pLbLog:setPosition(0, self.pLbContent:getHeight()/2)
	self.pLbContent:addView(self.pLbLog, 10)
	centerInView(self.pLayContent, self.pLbLog)

	self.pImgLine = self:findViewByName("img_line")
end

-- 修改控件内容或者是刷新控件数据
function ItemCountryLog:updateViews( )
	-- body

	if self.pCurData then
		local tTime =  os.date("*t", self.pCurData.nTime/1000)	
		if tTime then		
			self.pLbTime1:setString(string.format("%04d",tTime.year).."-"..string.format("%02d",tTime.month)..
		        "-"..string.format("%02d",tTime.day))				
			self.pLbTime2:setString(string.format("%02d",tTime.hour)..
		        ":"..string.format("%02d",tTime.min)..":"..string.format("%02d",tTime.sec))
		else
			self.pLbTime1:setString("")
			self.pLbTime2:setString("")
		end
		local str = self.pCurData:getJournalContentTextColor() or ""
		self.pLbLog:setString(str, false)
	else
		self.pLbTime1:setString("")
		self.pLbTime2:setString("")
	end
end

-- 析构方法
function ItemCountryLog:onItemCountryLogDestroy(  )
	-- body
end
--
function ItemCountryLog:setCurData( _data )
	-- body
	self.pCurData = _data or self.pCurData
	self:updateViews()
end

return ItemCountryLog


