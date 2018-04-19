-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-16 17:15:23 星期一
-- Description: 女将寻访
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local LayoutFemaleLookfor = class("LayoutFemaleLookfor", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayoutFemaleLookfor:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_female_heros_lookfor", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayoutFemaleLookfor:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayoutFemaleLookfor",handler(self, self.onDestroy))
end

-- --初始化参数
function LayoutFemaleLookfor:myInit()
	-- body
	self.tTips = {}
end

--初始化控件
function LayoutFemaleLookfor:setupViews( )
	-- body	
	self.pLayRoot 		= 	self:findViewByName("lay_default")
	self.pView 	  		= 	self:findViewByName("lay_view")
	self.pLayHeros 		= 	self:findViewByName("lay_top_heros")
	self.pLayTip 		= 	self:findViewByName("lay_tip")
	self.pLbTip1 		= 	self:findViewByName("lb_tip_1")
	self.pLbTip2 		= 	self:findViewByName("lb_tip_2")
	self.pLayBtn1 		= 	self:findViewByName("lay_btn_1")
	self.pLayBtn2 		= 	self:findViewByName("lay_btn_2")
	self.pLayBtnL 		= self:findViewByName("lay_btn_l")
	self.pLayBtnR 		= self:findViewByName("lay_btn_r")
	--立即拜访按钮
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10860), true)
	self.pBtn1:onCommonBtnClicked(handler(self, self.onVisitBtnClicked))
	setMCommonBtnScale(self.pLayBtn1, self.pBtn1, 0.8)
	--免费寻访
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10861), true)
	self.pBtn2:onCommonBtnClicked(handler(self, self.onFreeBtnClicked))
	--寻访一次
	self.pBtnL = getCommonButtonOfContainer(self.pLayBtnL, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10862), true)
	self.pBtnL:onCommonBtnClicked(handler(self, self.onBtnLClicked))
	--寻访十次
	self.pBtnR = getCommonButtonOfContainer(self.pLayBtnR, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10863), true)
	self.pBtnR:onCommonBtnClicked(handler(self, self.onBtnRClicked))
end

--修改控件内容或者是刷新控件数据
function LayoutFemaleLookfor:updateViews(  )
	-- body
	
end

--立即拜访按钮
function LayoutFemaleLookfor:onVisitBtnClicked( pView )
	-- body

end

--免费寻访
function LayoutFemaleLookfor:onFreeBtnClicked( pView )
	-- body
end
--寻访一次
function LayoutFemaleLookfor:onBtnLClicked( ... )
	-- body
end

--寻访十次
function LayoutFemaleLookfor:onBtnRClicked( ... )
	-- body
end

--析构方法
function LayoutFemaleLookfor:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayoutFemaleLookfor:regMsgs( )
	-- body	    
end

-- 注销消息
function LayoutFemaleLookfor:unregMsgs(  )
	-- body	
end
--暂停方法
function LayoutFemaleLookfor:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayoutFemaleLookfor:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayoutFemaleLookfor
