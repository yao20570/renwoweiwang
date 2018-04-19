-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-17 17:15:23 星期二
-- Description: 女将商店商品
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemFemalHeroShop = class("ItemFemalHeroShop", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ItemFemalHeroShop:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("item_femal_hero_shop", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ItemFemalHeroShop:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ItemFemalHeroShop",handler(self, self.onDestroy))
end

-- --初始化参数
function ItemFemalHeroShop:myInit()
	-- body
	self.pData = nil
end

--初始化控件
function ItemFemalHeroShop:setupViews( )
	-- body	
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayIcon = self:findViewByName("lay_icon")  --
	self.pLbName 	= self:findViewByName("lb_name")
	self.pLayBtn 	= self:findViewByName("lay_btn")	
end

-- 修改控件内容或者是刷新控件数据
function ItemFemalHeroShop:updateViews(  )
	-- body
	
end

function ItemFemalHeroShop:setCurData( _tData )
	-- body
	self.pData = _tData or self.pData
	self:updateViews()
end

--析构方法
function ItemFemalHeroShop:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ItemFemalHeroShop:regMsgs( )
	-- body	    
end

-- 注销消息
function ItemFemalHeroShop:unregMsgs(  )
	-- body	
end
--暂停方法
function ItemFemalHeroShop:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemFemalHeroShop:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ItemFemalHeroShop
