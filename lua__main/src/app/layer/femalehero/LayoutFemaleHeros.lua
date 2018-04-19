-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-17 17:15:23 星期二
-- Description: 女将分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local LayoutFemaleHeros = class("LayoutFemaleHeros", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayoutFemaleHeros:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_female_heros", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayoutFemaleHeros:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayoutFemaleHeros",handler(self, self.onDestroy))
end

-- --初始化参数
function LayoutFemaleHeros:myInit()
	-- body	
end

--初始化控件
function LayoutFemaleHeros:setupViews( )
	-- body	
	self.pLayRoot 		= 	self:findViewByName("lay_default")
	self.pView 	  		= 	self:findViewByName("lay_view")
	self.pLayBanner		= 	self:findViewByName("lay_bannar")
	self.pLayTab 		= 	self:findViewByName("lay_tab")
	self.pLayHeroList 	= 	self:findViewByName("lay_hero_list")
	
	local tTitles = {getConvertedStr(6, 10856), getConvertedStr(6, 10857), getConvertedStr(6, 10858)}

	self.pTabHost = TCommonTabHost.new(self.pLayTab,1,1,tTitles,handler(self, self.onIndexSelected))
	self.pTabHost:setImgBag("#v1_btn_selected_biaoqian2.png", "#v1_btn_biaoqian2.png")
	self.pLayTab:addView(self.pTabHost,10)	
	self.pTabHost:removeLayTmp1()
	--默认选中第一项
	self.pTabHost:setDefaultIndex(1)
	self.tTabItems = self.pTabHost:getTabItems()
	
end

-- 修改控件内容或者是刷新控件数据
function LayoutFemaleHeros:updateViews(  )
	-- body
	
end

function LayoutFemaleHeros:onIndexSelected( _index )

	self.nSelect = _index --当前所选星级
	self:refreshHeroData()
	--刷新列表
	self:updateTabHost()
end

function LayoutFemaleHeros:refreshHeroData( ... )
	-- body
end

function LayoutFemaleHeros:updateTabHost( ... )
	-- body
end

--析构方法
function LayoutFemaleHeros:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayoutFemaleHeros:regMsgs( )
	-- body	    
end

-- 注销消息
function LayoutFemaleHeros:unregMsgs(  )
	-- body	
end
--暂停方法
function LayoutFemaleHeros:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayoutFemaleHeros:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayoutFemaleHeros
