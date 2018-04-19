-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-13 10:42:18 星期一
-- Description: 切换卡测试
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local TestLayer = require("app.layer.test.TestLayer")


local TestTabHost = class("TestTabHost", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MROOTLAYER)
end)

function TestTabHost:ctor(  )
	-- body
	self:myInit()
	local tTitle = {"商店1","背包2"}
	self.nTabHost = FCommonTabHost.new(self,1,1,tTitle, handler(self, self.getLayerByKey))
	-- self.nTabHost = TCommonTabHost.new(self,2,tTitle, handler(self, self.onSelTabCallBack))

	self.nTabHost:setLayoutSize(self:getLayoutSize())
	self:addView(self.nTabHost, 10)
	centerInView(self, self.nTabHost)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TestTabHost",handler(self, self.onTestTabHostDestroy))

end

--初始化成员变量
function TestTabHost:myInit(  )
	-- body
	self.pLayTest = nil
end

--初始化控件
function TestTabHost:setupViews( )
	-- body
	self.nTabHost:setDefaultIndex(2)
end

-- 修改控件内容或者是刷新控件数据
function TestTabHost:updateViews(  )
	-- body
	-- self.nTabHost:showTitleByIndex({2,3})
	-- self.nTabHost:resetTopTitleOrder({4,1,2,3})
	-- self.nTabHost:resetTopTitleOrder({3,1,4,2})

end

-- 析构方法
function TestTabHost:onTestTabHostDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function TestTabHost:regMsgs( )
	-- body
end

-- 注销消息
function TestTabHost:unregMsgs(  )
	-- body
end


--暂停方法
function TestTabHost:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function TestTabHost:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--通过key值获取内容层的layer
function TestTabHost:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil
	if( _sKey == _tKeyTabLt[1] ) then
		-- pLayer = TestLayer.new(1)
		pLayer = TCommonTabHost.new(self,2,1,{"ss","ssdd"}, handler(self, self.onSelTabCallBack))
		self.tt = TestLayer.new(5)
		pLayer:setDefaultIndex(1)
		pLayer:setContentLayer(self.tt)
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = TestLayer.new(2)
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = TestLayer.new(3)
	elseif (_sKey == _tKeyTabLt[4] ) then
		pLayer = TestLayer.new(4)
	end

	return pLayer
end

--选择某一项回调事件
function TestTabHost:onSelTabCallBack( _nIndex )
	-- body
	-- print("_nIndex:" .. _nIndex)
end

return TestTabHost