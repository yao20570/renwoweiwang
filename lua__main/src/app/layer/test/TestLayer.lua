-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 20:07:32 星期四
-- Description: 测试  TestLayer.lua
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local TestLayer = class("TestLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function TestLayer:ctor( _nType )
	-- body
	self:myInit()
	self.nType = _nType or 1
	parseView("test_layout", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function TestLayer:myInit(  )
	-- body
	self.nType = 1
end

--解析布局回调事件
function TestLayer:onParseViewCallback( pView )
	-- body
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TestLayer",handler(self, self.onTestLayerDestroy))
end

--初始化控件
function TestLayer:setupViews( )
	-- body

	self.pLayContent 			= 	self:findViewByName("default")
	self.pLayContent:setLayoutSize(self:getLayoutSize())

	self.pLbContent 			= 	self:findViewByName("lb_content")
	self.pLbContent:setPositionY(self.pLayContent:getHeight() / 2)
	self.pLbContent:setString("内容：" .. self.nType)
end

-- 修改控件内容或者是刷新控件数据
function TestLayer:updateViews(  )
	-- body
end

-- 析构方法
function TestLayer:onTestLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function TestLayer:regMsgs( )
	-- body
end

-- 注销消息
function TestLayer:unregMsgs(  )
	-- body
end


--暂停方法
function TestLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function TestLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	print("ddddddddddddddddddddddddddddddddd")
	    



	    
end

return TestLayer