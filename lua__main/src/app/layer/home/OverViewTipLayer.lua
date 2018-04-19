-- OverViewTipLayer.lua
----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2017-10-25 11:52:10 星期三
-- Description: 总览文字冒泡提示
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local OverViewTipLayer = class("OverViewTipLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function OverViewTipLayer:ctor()
	
	parseView("overview_tip", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function OverViewTipLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:onResume()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("OverViewTipLayer",handler(self, self.onDestroy))
end


function OverViewTipLayer:setupViews(  )
	local pLbTip = self:findViewByName("lb_tip")
	
	self.pImgBg = self:findViewByName("img_bg")

	self.pLbTip = MUI.MLabel.new({
		text = "完成",
		size = 18,
		align = cc.ui.TEXT_ALIGN_LEFT,
    	valign = cc.ui.TEXT_ALIGN_CENTER,
		anchorpoint = cc.p(0, 0.5),
		dimensions = cc.size(230, 0)
		})
	self:addView(self.pLbTip, 10)
	self.pLbTip:setPosition(pLbTip:getPosition())
end

function OverViewTipLayer:setTips( _sTips )
	if not _sTips then
		return 
	end

	self.pLbTip:setString(_sTips)
	self.pImgBg:setContentSize(cc.size(self.pLbTip:getWidth() + 50, self.pImgBg:getHeight()))

	self:performWithDelay(function ()
		self:setVisible(false)
	end, 2)
	
end

function OverViewTipLayer:onResume()
end

function OverViewTipLayer:updateViews(  )

end
-- 析构方法
function OverViewTipLayer:onDestroy(  )
end

return OverViewTipLayer
