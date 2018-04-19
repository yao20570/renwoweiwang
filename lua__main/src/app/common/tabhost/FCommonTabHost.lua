-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-10 09:55:13 星期五
-- Description: 一级切换卡(内容层切换或者替换 带tabmanager管理器)
-- 				适用内容层差异性较大的页面
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local TabManager = require("app.common.TabManager")
local FCommonItemTab = require("app.common.tabhost.FCommonItemTab")

local FCommonTabHost = class("FCommonTabHost", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

-- _pTarget：父层控件
-- _nMType：1：一级切换卡 2：二级切换卡
-- _nType：顶部页签是否自适配宽度 1：是 2：否
-- _tTabTitle：切换卡选项标题（同时也决定个数）
-- _nHandler：获得展示内容层回调
-- _nRreshPage：是否创建的时候就刷新分页 默认0 创建的时候刷新1分页 1不需要刷新分页自由调用并刷新分页
-- _tabOffset偏移量：_tabOffset
function FCommonTabHost:ctor( _pTarget, _nMType, _nType, _tTabTitle, _nHandler, _nRreshPage, _tabOffset)
	-- body
	self:myInit()
	if not _pTarget then
		print("_pTarget is nil")
		return
	end
	self.pTarget = _pTarget
	self.nMType = _nMType or 1
	self.nType = _nType or 1
	self.tTabTitles = _tTabTitle or {}
	self.nRreshPage = _nRreshPage or 0
	self.tTabOffset = _tabOffset
	if not _nHandler then
		print("没实现setHandlerGetLayer()回调方法")
		return 
	end
	self:setHandlerGetLayer(_nHandler)
	parseView("layout_fcommon_tabhost", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function FCommonTabHost:myInit(  )
	-- body
	self.pTarget 			= nil 				--父层控件
	self.nMType 			= 1 				--1：一级切换卡 2：二级切换卡
	self.nType 				= 1 				--顶部页签是否动态设配宽度
	self._nHandlerGetLayer 	= nil 				--获取layer的handler

	self.tTabItems 			= {} 				--页签集合表
	self.tTabTitles 		= {} 				--页签名字
	self.tTabKeys 			= {} 				--key表
	self.nTopTabWidth 		= 0 				--顶部页签宽度（0的情况下不自动适配宽度）

	--是否创建的时候就刷新分页 默认0 创建的时候刷新1分页 1不需要刷新分页自由调用并刷新分页	
	self.nRreshPage         = 0
end

--解析布局回调事件
function FCommonTabHost:onParseViewCallback( pView )
	-- body
	--设置大小
	self:setCurLayerSize(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FCommonTabHost",handler(self, self.onFCommonTabHostDestroy))
end

--初始化控件
function FCommonTabHost:setupViews(  )
	-- body    
    self.pDefault 				    = 		self:findViewByName("default")
	self.pLayTop 					= 		self:findViewByName("lay_top")
	--fill_layout
	self.pLayTmpFill 				= 		self:findViewByName("lay_content")
	self.pLayerTabContent 			=  		MUI.MLayer.new()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
	self.pLayTmpFill:addView(self.pLayerTabContent)

	if self.nMType == 1 then
		self.pLayTop:setLayoutSize(self.pLayTop:getWidth(), 60)
	elseif self.nMType == 2 then
		self.pLayTop:setLayoutSize(self.pLayTop:getWidth(), 50)
	elseif self.nMType == 3 then
		self.pLayTop:setLayoutSize(self.pLayTop:getWidth(), 68)
	end

	self:resetTabTitles()

end

-- 重置分页标题
function FCommonTabHost:resetTabTitles(  )
	-- body
	local nSize = table.nums(self.tTabTitles)
	-- print(nSize)
	if nSize > 0 then
		-- 动态计算页签宽度
		if self.nType == 1 then
			self.nTopTabWidth = self.pLayTop:getWidth() / nSize
		end
		local nLeftMarge = 0
		local nTopTabWidth = self.nTopTabWidth
		if self.tTabOffset then
			nLeftMarge = self.tTabOffset.nLeftMarge
			nTopTabWidth = self.tTabOffset.nTopTabWidth
		end
		for i = 1, nSize do
			local pItemTab = FCommonItemTab.new( self.nMType, self.nType, nTopTabWidth)
			pItemTab:setPositionX(nLeftMarge + (i - 1) * pItemTab:getWidth())
			pItemTab:setTabTitle(self.tTabTitles[i])
			self.pLayTop:addView(pItemTab)
			self.tTabItems[i] = pItemTab
			pItemTab.nIndex = i --下标标志
			local sKey = "tabhost_key_" .. i
			table.insert(self.tTabKeys, sKey)
		end
		self.pTabManager = TabManager.new(self, self.pLayerTabContent,
			self.tTabItems, self.tTabKeys, handler(self, self.onTabChanged))
		if self.nRreshPage == 0 then
			self:setDefaultIndex(1)
		end
	end
end

--移出空格层1
function FCommonTabHost:removeLayTmp1(  )
	--间隔线1
	local pTmp1 					= 		self:findViewByName("lay_tmp_1")
	pTmp1:removeSelf()
    self.pDefault:requestLayout()
    --self:requestLayout()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
    self.pLayTmpFill:requestLayout()
end

--移出空格层2
function FCommonTabHost:removeLayTmp2(  )
	local pTmp2 					= 		self:findViewByName("lay_tmp_2")
	pTmp2:removeSelf()
    self.pDefault:requestLayout()
    --self:requestLayout()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
    self.pLayTmpFill:requestLayout()
end

-- 修改控件内容或者是刷新控件数据
function FCommonTabHost:updateViews(  )
	-- body
end

-- 析构方法
function FCommonTabHost:onFCommonTabHostDestroy(  )
	-- body
	self:onPause()
	self.pTabManager:releaseAll()
end

-- 注册消息
function FCommonTabHost:regMsgs( )
	-- body
end

-- 注销消息
function FCommonTabHost:unregMsgs(  )
	-- body
end


--暂停方法
function FCommonTabHost:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FCommonTabHost:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置默认选中项
function FCommonTabHost:setDefaultIndex( _nIndex )
	-- body
	local nDefaultIndex = _nIndex or 1
	self.pTabManager:gotoTabByIndex(nDefaultIndex)
end

-- tab change listener
function FCommonTabHost:onTabChanged( _key, _nType)
   -- print("_key:" .. _key .. ",_nType=" .. _nType)
   if self._nHandlerTabChanged then
   		self._nHandlerTabChanged(_key, _nType)
   end
end 

--设置切换监听的handler
function FCommonTabHost:setTabChangedHandler( _nHandler )
	self._nHandlerTabChanged = _nHandler
end

--设置获取内容层的handler
function FCommonTabHost:setHandlerGetLayer( _nHandler )
	-- body
	self._nHandlerGetLayer = _nHandler
end

--创建内容展示层
-- _key：展示层的key
function FCommonTabHost:createTab( _key )
	-- body
	local pLayer = nil
	if self._nHandlerGetLayer then
		pLayer = self._nHandlerGetLayer(_key, self.tTabKeys)
	else
		print("子类没实现setHandlerGetLayer()方法")
	end
	return pLayer
end

--设置需要展示的分页
--_tShowIndex：需要展示的下标（下标从1开始）
function FCommonTabHost:showTitleByIndex( _tShowIndex )
	-- body
	if not _tShowIndex then
		return 
	end
	local nShowCt = 0
	for k, v in pairs (self.tTabItems) do
		local bIsShow = false
		for m, n in pairs (_tShowIndex) do
			if v.nIndex == n then
				bIsShow = true
				nShowCt = nShowCt + 1
			end
		end
		v:setVisible(bIsShow)
	end
	--重新计算位置
	if self.nType == 1 then
		self.nTopTabWidth = self.pLayTop:getWidth() / nShowCt
	end
	local nLeftMarge = 0
	local nTopTabWidth = self.nTopTabWidth
	if self.tTabOffset then
		nLeftMarge = self.tTabOffset.nLeftMarge
		nTopTabWidth = self.tTabOffset.nTopTabWidth
	end

	--重新设置大小和位置
	local nIndex = 1
	for k, v in pairs (self.tTabItems) do
		v:resetLayoutSize(nTopTabWidth)
		--设置位置
		if v:isVisible() then
			v:setPositionX(nLeftMarge + (nIndex - 1) * v:getWidth())
			nIndex = nIndex + 1
		end
	end
end

--重新设置顶部切换页签的排序
--_tOrdertIndex：排序表
function FCommonTabHost:resetTopTitleOrder( _tOrdertIndex )
	-- body
	local tTmp = copyTab(self.tTabItems)
	self.tTabItems = nil
	self.tTabItems = {}
	local nIndex = 1
	for k, v in pairs (_tOrdertIndex) do
		for m, n in pairs (tTmp) do
			if n.nIndex == v then
				self.tTabItems[k] = n
				--重新计算位置
				if self.tTabItems[k]:isVisible() then
					self.tTabItems[k]:setPositionX((nIndex - 1) * self.tTabItems[k]:getWidth())
					nIndex = nIndex + 1
				end
				
				break
			end
		end
	end
	tTmp = nil
end

--获取当前切换卡的layer
function FCommonTabHost:getTabLayer(_key)
	-- body
	if _key then
		self.pTabManager:getLayer(_key)
	end
end

--获取标签列表
function FCommonTabHost:getTabItems(  )
	return self.tTabItems
end

--显示上锁
function FCommonTabHost:showTabLock( nIndex , tPos)
	local pItem = self.tTabItems[nIndex]
	if pItem then
		pItem:showTabLock(tPos)
	end
end

--隐藏上锁
function FCommonTabHost:hideTabLock( nIndex )
	local pItem = self.tTabItems[nIndex]
	if pItem then
		pItem:hideTabLock()
	end
end

--设置当前大小
function FCommonTabHost:setCurLayerSize( _pView )
	-- body
	if self.pTarget and _pView then
		_pView:setLayoutSize(self.pTarget:getLayoutSize())
		self:setLayoutSize(self.pTarget:getLayoutSize())
		self:addView(_pView, 10)
		--页签大小
		local pLayTop 		= _pView:findViewByName("lay_top")
		pLayTop:setLayoutSize(_pView:getWidth(), pLayTop:getHeight())
		--内容大小
		local pLayContent 	= _pView:findViewByName("lay_content")
		pLayContent:setLayoutSize(_pView:getWidth(), pLayContent:getHeight())
		self.pLayContent = pLayContent
	end
end

--获取当前区域的大小
function FCommonTabHost:getCurContentSize( ... )
	return self.pLayContent:getContentSize()
end

function FCommonTabHost:setTopZoder( nZoder )
	self.pLayTop:setLocalZOrder(nZoder)
end

return FCommonTabHost