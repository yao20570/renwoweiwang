-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-17 11:48:23 星期二
-- Description: 女将商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local LayoutFemaleHeroShop = class("LayoutFemaleHeroShop", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayoutFemaleHeroShop:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_female_heros_shop", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayoutFemaleHeroShop:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayoutFemaleHeroShop",handler(self, self.onDestroy))
end

-- --初始化参数
function LayoutFemaleHeroShop:myInit()
	-- body
	self.tTips = {}
end

--初始化控件
function LayoutFemaleHeroShop:setupViews( )
	-- body	
	self.pLayRoot 		= 	self:findViewByName("lay_default")
	self.pView 	  		= 	self:findViewByName("lay_view")
	self.pLayBanner 	= 	self:findViewByName("lay_bannar")

	self.pLayBtnRefresh =  	self:findViewByName("lay_btn_refresh")
	self.pLbTime 		= 	self:findViewByName("lb_time")
	self.pLayCont 		= 	self:findViewByName("ly_cont")
		
	self.pBtnRefresh = getCommonButtonOfContainer(self.pLayBtnRefresh, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10859), true)
	setMCommonBtnScale(self.pLayBtnRefresh, self.pBtnRefresh, 0.8)
	self.pBtnRefresh:onCommonBtnClicked(handler(self, self.onRefreshBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function LayoutFemaleHeroShop:updateViews(  )
	-- body
	
	--self.pLbTime
end

function LayoutFemaleHeroShop:onRefreshBtnClicked( _pView )
	-- body
	print("刷新")

end

--析构方法
function LayoutFemaleHeroShop:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayoutFemaleHeroShop:regMsgs( )
	-- body	    
end

-- 注销消息
function LayoutFemaleHeroShop:unregMsgs(  )
	-- body	
end
--暂停方法
function LayoutFemaleHeroShop:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayoutFemaleHeroShop:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayoutFemaleHeroShop
