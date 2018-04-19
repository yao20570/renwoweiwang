----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-06 14:08:31
-- Description: 滚动层 其中某些子ui实现类似listview的功能
-----------------------------------------------------
local ScrollViewEx = class("ScrollViewEx", function( nWidth, nHeight)
	local pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, nWidth, nHeight),
		        touchOnContent = false,
				direction=MUI.MScrollLayer.DIRECTION_VERTICAL}) --现在只支持垂直
	return pSv
end)

function ScrollViewEx:ctor( )
	self.tListViewData = {}

	--监听onExit
    self:onNodeEvent("exit", function(...)
		self:onExit(...)
	end)

	--滑动层
	self:onScroll(function ( event )
		local sEvent = event.name
    	if sEvent == "moved" then
    		if not self.nUpdateScheduler then
	    		--更新每几帧执行更新，以防惯性滑动
				self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
					local nY = self.scrollNode:getPositionY()
					if self.nPrevY ~= nY then
						self.nPrevY = nY
						self:refreshListViews()
					end
				end,0.02)
			end
    	elseif sEvent == "scrollEnd" then
    		if self.nUpdateScheduler then
			    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
			    self.nUpdateScheduler = nil
			end
			self:refreshListViews()
    	end
    end)

    self.nWidht=0
	self.nHeight=0
	self.tAllChildren={}
	self.bIsResetContentSize=false

end

function ScrollViewEx:onExit()
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

--pUi :指定实现ListView容器类(一般是Layer)
--nChildWidth: 子类的宽度
--nChildHeight: 子类的高度
--nSubUiFunc: 子类循环的方法
function ScrollViewEx:setListView( pUi, nChildWidth, nChildHeight, nSubUiFunc, nUiMinHieght)
	if self:checkIsUiListView(pUi) then
		return
	end
	pUi.__bIsSListView = true
	table.insert(self.tListViewData, {
		pUi = pUi,
		nChildWidth = nChildWidth,
		nChildHeight = nChildHeight,
		nSubUiFunc = nSubUiFunc,
		nCreateChild = math.ceil(self:getHeight()/nChildHeight) + 1,
		tUsingSubUi = {},
		tIdleSubUi = {},
		nUiMinHieght = nUiMinHieght or 0,
		})
end

function ScrollViewEx:refreshListViews( )
	--遍历进行检测和显示
	local nScrollNodeY = self.scrollNode:getPositionY()
	local nCanTopY = self:getHeight()
	--进行刷新子控件
	for j=1,#self.tListViewData do
		local tData = self.tListViewData[j]
		local pUi = tData.pUi
		local nChildHeight = tData.nChildHeight
		local nCreateChild = tData.nCreateChild
		local nCount = tData.nCount

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
		self:pushToIdleSubUiByIndex(tData, nBeginIdex, nEndIndex)

		--添加到当前列表中
		local tCurrDict = {}
		for i=1,#tData.tUsingSubUi do
			if tData.tUsingSubUi[i] then
				local nIndex = tData.tUsingSubUi[i].nIndex
				tCurrDict[nIndex] = true
			end
		end
		-- print("nBeginIdex, nEndIndex======",nBeginIdex, nEndIndex)
		local nTopH = pUi:getHeight()
		for i=nBeginIdex, nEndIndex do
			if not tCurrDict[i] then
				local pSubUi = self:getSubUiFromIdle(tData, i)
				pSubUi.nIndex = i
				
				pSubUi:setPosition(0, nTopH - (i * nChildHeight))
			end
		end
	end
end

--把用不到的放到回收里面
function ScrollViewEx:pushToIdleSubUiByIndex( tData, nBeginIdex, nEndIndex )
	--倒序
	for i = #tData.tUsingSubUi, 1, -1 do
		local pSubUi = tData.tUsingSubUi[i]
		local nIndex = pSubUi.nIndex
		if nIndex < nBeginIdex or nIndex > nEndIndex then
			table.remove(tData.tUsingSubUi, i)
			table.insert(tData.tIdleSubUi, pSubUi)
			pSubUi:setVisible(false)
		else
			pSubUi:setVisible(true)
		end
	end
end

--获取要用到的
function ScrollViewEx:getSubUiFromIdle( tData, i)
	local nSubUiFunc = tData.nSubUiFunc
	local nChildWidth = tData.nChildWidth
	local nChildHeight = tData.nChildHeight
	local pUi = tData.pUi
	--从空闲列表获取队像
	local pSubUi = nil
	local nCount = #tData.tIdleSubUi
	if nCount > 0 then
		pSubUi = tData.tIdleSubUi[nCount]
		pSubUi:setVisible(true)
		table.remove(tData.tIdleSubUi, nCount)
	end
	if pSubUi then
		nSubUiFunc(pSubUi, i)
	else
		pSubUi = nSubUiFunc(nil, i)	
		pUi:addView(pSubUi)
	end
	table.insert(tData.tUsingSubUi, pSubUi)
	return pSubUi
end



--检查Ui是否是特殊控件
function ScrollViewEx:checkIsUiListView( pUi )
	if pUi.__bIsSListView then
		return true
	end
	return false
end

--获取控件相关数据
function ScrollViewEx:getListViewData( _pUi )
	for i=1,#self.tListViewData do
		local tData = self.tListViewData[i]
		if tData.pUi == _pUi then
			return tData
		end
	end
	return nil
end

--设置指定ListView控件数量
function ScrollViewEx:setListViewNum( pUi, nCount)
	if not self:checkIsUiListView(pUi) then
		return
	end

	local tData = self:getListViewData(pUi)
	if not tData then
		print("不存在相关ListViewData数据")
		return
	end

	tData.nCount = nCount
end

--置顶方法重写
function ScrollViewEx:scrollToBegin( _bAction )
	--如果高度小于就重置子类高度
	local nHeight = self:getHeight()
	if self.scrollNode:getHeight() < nHeight then
		self.scrollNode:setContentSize(self.scrollNode:getWidth(), nHeight)
	end
	self:scrollToPosition(1,_bAction)
end

function ScrollViewEx:setScrollViewContent( _pContent)
	-- body
	if not _pContent then
		return
	end
	self.pContent=_pContent
	local pSize = self.pContent:getContentSize()
	local nWidht, nHeight = pSize.width, pSize.height
	self.nWidht=nWidht
	self.nHeight=nHeight


end

--添加scrollview的各个内容节点
function ScrollViewEx:addScrollViewChild( _pNode)
	-- body
	self.nHeight = self.nHeight - _pNode:getContentSize().height
	_pNode:setPosition(0, self.nHeight)
	self.pContent:addView(_pNode)
	table.insert(self.tAllChildren,_pNode)
	if self.nHeight < 0 then
		self.bIsResetContentSize=true
	end
end
--重置滚动层高度
function ScrollViewEx:resetContentSize( )
	-- body
	if self.bIsResetContentSize then
		local nNewHeight=self.pContent:getHeight() - self.nHeight  		--nHeight是负数 所以用减的
		self.pContent:setLayoutSize(self.pContent:getWidth(),nNewHeight)

		for k,v in pairs(self.tAllChildren) do 

			v:setPositionY(v:getPositionY() - self.nHeight)
		end
		if self.scrollNode then
			self.scrollNode:setLayoutSize(self.pContent:getWidth(),nNewHeight)
		end
		self:scrollToBegin(false)

	end
end

function ScrollViewEx:getCurContentHeight( )
	-- body

	return self.nHeight
end

function ScrollViewEx:setCurContentHeight( _nHeight )
	-- body
	self.nHeight=_nHeight
end


return ScrollViewEx
