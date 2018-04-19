-- LayerImperialWarTab.lua
-----------------------------------------------------
-- author: xiest
-- updatetime:  2018-3-21 16:01:06 星期三
-- Description: 决战阿房宫 阿房宫分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local LayerImperialWarTab = class("LayerImperialWarTab", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LayerImperialWarTab:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_imperial_war_tab", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayerImperialWarTab:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayerImperialWarTab",handler(self, self.onDestroy))
end

-- --初始化参数
function LayerImperialWarTab:myInit()

end

--初始化控件
function LayerImperialWarTab:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function LayerImperialWarTab:updateViews(  )
 
end

--析构方法
function LayerImperialWarTab:onDestroy(  )
	self:onPause()
end
 

-- 注册消息
function LayerImperialWarTab:regMsgs( )
end

-- 注销消息
function LayerImperialWarTab:unregMsgs(  )
end

--暂停方法
function LayerImperialWarTab:onPause( )
	self:unregMsgs()
end

--继续方法
function LayerImperialWarTab:onResume( )
	-- body
	self:regMsgs()
end

return LayerImperialWarTab
