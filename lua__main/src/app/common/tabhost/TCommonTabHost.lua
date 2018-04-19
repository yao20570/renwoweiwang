-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-13 15:01:01 星期一
-- Description: 一级切换卡(单独内容层展示 不带tabmanager管理器)
-- 				适用内容层展示界面高度相似
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local FCommonItemTab = require("app.common.tabhost.FCommonItemTab")


local TCommonTabHost = class("TCommonTabHost", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

-- _pTarget：父层控件
-- _nMType：1：一级切换卡 2：二级切换卡
-- _nType：顶部页签是否自适配宽度 1：是 2：否
-- _tTabTitle：切换卡选项标题（同时也决定个数）
-- _nHandler：选择 下标回调事件
function TCommonTabHost:ctor( _pTarget, _nMType, _nType, _tTabTitle, _nHandler, _nNotOpenHandler )
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
	if _nNotOpenHandler then
		self._nNotOpenHandlerCallBack = _nNotOpenHandler
	end

	if not _nHandler then
		print("选择回调事件不能为nil")
		return
	end
	self._nHandlerCallBack = _nHandler

	parseView("layout_fcommon_tabhost", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function TCommonTabHost:myInit( )
	-- body
	self.pTarget 			= nil 				--父层控件
	self.nMType 			= 1 				--1：一级切换卡 2：二级切换卡
	self.nType 				= 1 				--顶部页签是否动态设配宽度
	self.tTabTitles 		= {} 				--页签名字
	self.tTabItems 			= {} 				--页签集合表
	self._nHandlerCallBack 	= nil 				--选择回调事件
	self.tNotOpenIndexs		= {}				--没开放index列表
	self._nNotOpenHandlerCallBack = nil			--没开放index回调事件
end

--解析布局回调事件
function TCommonTabHost:onParseViewCallback( pView )
	-- body
	--设置大小
	self:setCurLayerSize(pView)


	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TCommonTabHost",handler(self, self.onTCommonTabHostDestroy))
end

--初始化控件
function TCommonTabHost:setupViews( )
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

-- 修改控件内容或者是刷新控件数据
function TCommonTabHost:updateViews(  )
	-- body
end

--设置内容
function TCommonTabHost:setContentLayer( _pContent )
	-- body
	if not _pContent then
		return
	end
    self.pLayerTabContent:removeAllChildren()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
    self.pLayTmpFill:requestLayout()
	self.pLayerTabContent:addView(_pContent, 100)
end

-- 重置分页标题
function TCommonTabHost:resetTabTitles(_tabTitles)
	--先删掉之前的
	for i=1,#self.tTabItems do
		self.tTabItems[i]:removeFromParent(true)
	end
	self.tTabItems = {}
	-- body
	local tTabTitles = _tabTitles or self.tTabTitles
	local nSize = table.nums(tTabTitles)
	if nSize > 0 then
		-- 动态计算页签宽度
		if self.nType == 1 then
			self.nTopTabWidth = self.pLayTop:getWidth() / nSize
		end
		for i = 1, nSize do
			local pItemTab = FCommonItemTab.new(self.nMType, self.nType, self.nTopTabWidth)
			pItemTab:setPositionX((i - 1) * pItemTab:getWidth())
			pItemTab:setTabTitle(tTabTitles[i])
			self.pLayTop:addView(pItemTab)
			self.tTabItems[i] = pItemTab
			pItemTab.nIndex = i --下标标志
			--设置点击事件
			pItemTab:onMViewClicked(handler(self, self.onTabItemClciked))
		end

	end
end

--设置默认选中项
function TCommonTabHost:setDefaultIndex( _nIndex )
	-- body
	self:setTopTabState(_nIndex)
end

--页签选择事件回调
function TCommonTabHost:onTabItemClciked( _pView )
	-- body
	self:setTopTabState(_pView.nIndex)
end

--设置按钮状态
function TCommonTabHost:setTopTabState( _nIndex )
	-- body
	local nIndex = _nIndex or 1
	if self.tNotOpenIndexs[nIndex] then
		self._nNotOpenHandlerCallBack(nIndex)
		return
	end

	for k, v in pairs (self.tTabItems) do
		if v.nIndex == nIndex then
			v:setChecked(true, self.sImgBgSelected)
			if self._nHandlerCallBack then
				self._nHandlerCallBack(nIndex)
			end
		else
			v:setChecked(false, self.sImgBg)
		end
	end
end

function TCommonTabHost:setImgBag( sImgBg, sImgBgSelected )
	-- body
	self.sImgBgSelected 	= 			sImgBg 						--选中背景
	self.sImgBg 			= 			sImgBgSelected				--背景	
end

--设置需要展示的分页
--_tShowIndex：需要展示的下标（下标从1开始）
function TCommonTabHost:showTitleByIndex( _tShowIndex )
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
	--重新设置大小和位置
	local nIndex = 1
	for k, v in pairs (self.tTabItems) do
		v:resetLayoutSize(self.nTopTabWidth)
		--设置位置
		if v:isVisible() then
			v:setPositionX((nIndex - 1) * v:getWidth())
			nIndex = nIndex + 1
		end
	end
end


--重新设置顶部切换页签的排序
--_tOrdertIndex：排序表
function TCommonTabHost:resetTopTitleOrder( _tOrdertIndex )
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

-- 析构方法
function TCommonTabHost:onTCommonTabHostDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function TCommonTabHost:regMsgs( )
	-- body
end

-- 注销消息
function TCommonTabHost:unregMsgs(  )
	-- body
end


--暂停方法
function TCommonTabHost:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function TCommonTabHost:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--移出空格层1
function TCommonTabHost:removeLayTmp1(  )
	--间隔线1
	local pTmp1 					= 		self:findViewByName("lay_tmp_1")
	pTmp1:removeSelf()
    self.pDefault:requestLayout()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
    self.pLayTmpFill:requestLayout()
end

--移出空格层2
function TCommonTabHost:removeLayTmp2(  )
	local pTmp2 					= 		self:findViewByName("lay_tmp_2")
	pTmp2:removeSelf()
    self.pDefault:requestLayout()
	self.pLayerTabContent:setLayoutSize(self.pLayTmpFill:getLayoutSize())
    self.pLayTmpFill:requestLayout()
end

--设置当前大小
function TCommonTabHost:setCurLayerSize( _pView )
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
	end
end

--获得内容层控件
function TCommonTabHost:getContentLayer( )
	-- body
	return self.pLayerTabContent
end


--设置所有按钮文本颜色
--tColor颜色数组
function TCommonTabHost:setTabLabelColors( tColor )
	for i=1,#tColor do
		local pItem = self.tTabItems[i]
		if pItem then
			pItem:setLableColor(tColor[i])
		end
	end
end

--获取标签列表
function TCommonTabHost:getTabItems(  )
	return self.tTabItems
end

--显示上锁
function TCommonTabHost:showTabLock( nIndex , tPos)
	local pItem = self.tTabItems[nIndex]
	if pItem then
		pItem:showTabLock(tPos)
	end
end

--隐藏上锁
function TCommonTabHost:hideTabLock( nIndex )
	local pItem = self.tTabItems[nIndex]
	if pItem then
		pItem:hideTabLock()
	end
end

function TCommonTabHost:setNotOpen(nIndex)-- self.tNotOpenIndexs	
	if not nIndex then
		return
	end
	self.tNotOpenIndexs[nIndex] = true
end

function TCommonTabHost:setOpen(nIndex)
	if not nIndex then
		return
	end
	self.tNotOpenIndexs[nIndex] = false
end

return TCommonTabHost
