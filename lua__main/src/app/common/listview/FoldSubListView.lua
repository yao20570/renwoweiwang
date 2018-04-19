----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-3-29 17:20:00
-- Description: 放在滚动层里，实现移时刷新显示
-----------------------------------------------------
local FoldSubListView = class("FoldSubListView", function( )
	local pLayer = MUI.MLayer.new() 
	return pLayer
end)

--tInfo = {nWidth, nChildWidth, nChildHeight, nSubUiFunc, nChildCount, nTopMargin, nBottomMargin, nLeftMargin}
function FoldSubListView:ctor( nFoldId, tInfo )
	self.nFoldId = nFoldId
	self.nWidth = tInfo.nWidth
	self.nChildWidth = tInfo.nChildWidth
	self.nChildHeight = tInfo.nChildHeight
	self.nSubUiFunc = tInfo.nSubUiFunc
	self.tUsingSubUi = {}
	self.tIdleSubUi = {}
	self.nTopMargin = tInfo.nTopMargin or 0
	self.nBottomMargin = tInfo.nBottomMargin or 0
	self.nLeftMargin = tInfo.nLeftMargin or 0
	self.nCreateChild = math.ceil(display.height/self.nChildHeight) + 1,
	self:setItemCount(tInfo.nChildCount)
end

--设置子节点数量
function FoldSubListView:setItemCount( nCount )
	self:setContentSize(self.nWidth, nCount * (self.nChildHeight + self.nTopMargin + self.nBottomMargin))
	self.nCount = nCount
end

--设置滚动层
function FoldSubListView:setFoldView( pFoldView )
	self.pFoldView = pFoldView
end

--遍历进行检测和显示(被调用)
function FoldSubListView:refreshListViewsByFold( )
	local nScrollNodeY = self.pFoldView.scrollNode:getPositionY()
	local nCanTopY = self.pFoldView:getHeight()
	--进行刷新子控件
	local pUi = self
	local nChildHeight = self.nChildHeight + self.nTopMargin + self.nBottomMargin
	local nCreateChild = self.nCreateChild
	local nCount = self.nCount

	--算起始下标
	local nTopY = nScrollNodeY + pUi:getPositionY() + pUi:getHeight()

	--显示的起始下标值
	local nBeginIdex = math.floor((nTopY - nCanTopY)/nChildHeight) + 1
	if nBeginIdex < 1 then
		nBeginIdex = 1
	end
	--显示的终点下标值
	local nEndIndex = nBeginIdex + nCreateChild
	if nEndIndex > nCount then
		nEndIndex = nCount
	end
	--收集回闲置列表
	self:pushToIdleSubUiByIndex(nBeginIdex, nEndIndex)

	--添加到当前列表中
	local tCurrDict = {}
	for i=1,#self.tUsingSubUi do
		local nIndex = self.tUsingSubUi[i].nIndex
		tCurrDict[nIndex] = true
	end
	-- print("nBeginIdex, nEndIndex======",nBeginIdex, nEndIndex)
	local nTopH = pUi:getHeight()
	for i=nBeginIdex, nEndIndex do
		if not tCurrDict[i] then
			local pSubUi = self:getSubUiFromIdle(i)
			pSubUi.nIndex = i
			
			pSubUi:setPosition(self.nLeftMargin, nTopH - (i * nChildHeight) + self.nBottomMargin)
		end
	end
end

--把用不到的放到回收里面
function FoldSubListView:pushToIdleSubUiByIndex( nBeginIdex, nEndIndex )
	--倒序
	for i = #self.tUsingSubUi, 1, -1 do
		local pSubUi = self.tUsingSubUi[i]
		local nIndex = pSubUi.nIndex
		if nIndex < nBeginIdex or nIndex > nEndIndex then
			table.remove(self.tUsingSubUi, i)
			table.insert(self.tIdleSubUi, pSubUi)
			pSubUi:setVisible(false)
		else
			pSubUi:setVisible(true)
		end
	end
end

--获取要用到的
function FoldSubListView:getSubUiFromIdle(i)
	local nSubUiFunc = self.nSubUiFunc
	local nChildWidth = self.nChildWidth
	local nChildHeight = self.nChildHeight
	local pUi = self
	--从空闲列表获取队像
	local pSubUi = nil
	local nCount = #self.tIdleSubUi
	if nCount > 0 then
		pSubUi = self.tIdleSubUi[nCount]
		pSubUi:setVisible(true)
		table.remove(self.tIdleSubUi, nCount)
	end
	if pSubUi then
		nSubUiFunc(pSubUi, i)
	else
		pSubUi = nSubUiFunc(nil, i)	
		pUi:addView(pSubUi)
	end
	table.insert(self.tUsingSubUi, pSubUi)
	return pSubUi
end

--返回当前用到的列表
function FoldSubListView:getCurrUsingSubUis(  )
	return self.tUsingSubUi
end

return FoldSubListView
