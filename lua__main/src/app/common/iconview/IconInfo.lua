-- Author: liangzhaowei
-- Date: 2017-07-07 16:50:06
-- icon属性

local MCommonView = require("app.common.MCommonView")
local IconInfo = class("IconInfo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function IconInfo:ctor()
	-- body
	self:myInit()

	parseView("item_icon_info", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("IconInfo",handler(self, self.onDestroy))
	
end

--初始化参数
function IconInfo:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function IconInfo:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)





	self:setupViews()
end

--初始化控件
function IconInfo:setupViews( )
	self.pLyMain = self:findViewByName("item_icon_info") 
	--lb
	self.pLbNe = self:findViewByName("lb_ne")
	self.pLbDesc =  MUI.MLabel.new({text="", size=18})
	self.pLbDesc:setAnchorPoint(0,0)
	self.pLbDesc:setDimensions(260,0)
	self.pLyMain:addView(self.pLbDesc, 10)	

	self.pLbTips =  MUI.MLabel.new({text="", size=18})
	self.pLbTips:setAnchorPoint(0,0)
	self.pLbTips:setDimensions(260,0)	
	self.pLyMain:addView(self.pLbTips, 10)

	setTextCCColor(self.pLbDesc,_cc.pwhite)
	setTextCCColor(self.pLbNe,_cc.pwhite)
end

-- 修改控件内容或者是刷新控件数据
function IconInfo:updateViews()
	if not self.pData then
		return
	end
	--dump(self.pData, "self.pData", 100)
	local nRectH = 20+25
	--显示名字
	if self.pData.sName and self.pData.nQuality then
		self.pLbNe:setString(self.pData.sName, false)
		setTextCCColor(self.pLbNe,getColorByQuality(self.pData.nQuality))
		nRectH  = nRectH + self.pLbNe:getHeight()
	end

	local nOH = self.pLbNe:getHeight()

	--显示描述语
	local nFH = 0
	if self.pData.sDes then
		self.pLbDesc:setString(getTextColorByConfigure(self.pData.sDes) ,false)
		if self.pLbDesc:getHeight() < nOH then
			nRectH = nRectH + nOH
		else
			nRectH = nRectH + self.pLbDesc:getHeight()
		end
	end
	if self.pData.sTips then		
		self.pLbTips:setString(getTextColorByConfigure(self.pData.sTips) ,false)
		if self.pLbTips:getHeight() < nOH then
			nRectH = nRectH + nOH
		else
			nRectH = nRectH + self.pLbTips:getHeight()
		end
	end

	self.pLbTips:setPosition(15,20)
	self.pLbDesc:setPosition(15,self.pLbTips:getPositionY() + self.pLbTips:getHeight())	
	self.pLbNe:setPositionY(nRectH - 20 - self.pLbNe:getHeight())
	self:setLayoutSize(self:getWidth(), nRectH)
	self.pLyMain:setLayoutSize(self:getWidth(), nRectH)
	-- end
end

--析构方法
function IconInfo:onDestroy(  )
	-- body
end

--设置数据 _data
function IconInfo:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()

end


return IconInfo