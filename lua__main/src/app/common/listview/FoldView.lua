----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-3-29 17:20:00
-- Description: 滚动层 其中某些子ui实现类似listview的功能
-----------------------------------------------------
local FoldView = class("FoldView", function( nWidth, nHeight)
	local pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, nWidth, nHeight),
		        touchOnContent = false,
				direction=MUI.MScrollLayer.DIRECTION_VERTICAL}) --现在只支持垂直
	return pSv
end)

function FoldView:ctor( )
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
    self.nWidth = self:getWidth()
    self.tFoldLay = {}
    self.tFoldChildren = {}
end

function FoldView:onExit()
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

--折叠节点数量
function FoldView:setFoldCount( nCount )
	self.nFoldCount = nCount
end

--折叠节点创建回调
function FoldView:setFoldCallBack( nFoldCallBack )
	self.nFoldCallBack = nFoldCallBack
end

--设置margin
function FoldView:setTopAndBottomMargin( nTopMargin, nBottomMargin )
	self.nTopMargin = nTopMargin or 0
	self.nBottomMargin = nBottomMargin or 0
end

-- 重新加载
function FoldView:reload(  )
	--清空之前
	for i=1,#self.tFoldChildren do
		local pFold = self.tFoldChildren[i]
		local pFoldSub = pFold.pFoldSub
		if pFoldSub then
			pFoldSub:removeFromParent()
			pFold.pFoldSub = nil
		end
		pFold:removeFromParent()
		local pLay = self.tFoldLay[i]
		pLay:removeFromParent()
	end
	self.tFoldChildren = {}
	self.tFoldLay = {}

	--初始化
	if self.nFoldCount and self.nFoldCallBack then
		for i=1,self.nFoldCount do
			local pFold = self.nFoldCallBack(i,nil)
			self:addFold(i, pFold, true)
		end
	end
	-- 刷新内容
	self:refreshContainer()
end

-- 打开折叠点
function FoldView:openFold( nIndex, pFoldSub )
	local pFold = self.tFoldChildren[nIndex]
	if not pFold then
		return
	end
	--删除之前
	self:closeFold(nIndex)
	--打开现在
	if pFoldSub then
		self:addView(pFoldSub)
		pFold.pFoldSub = pFoldSub
		-- 刷新内容
		self:refreshContainer()
	end
end

-- 打开折叠列表子列表内空
--tInfo = {nWidth, nChildWidth, nChildHeight, nSubUiFunc, nChildCount, nTopMargin, nBottomMargin}
function FoldView:openFoldListView( nIndex, tInfo )
	local pFold = self.tFoldChildren[nIndex]
	if not pFold then
		return
	end
	--删除之前
	self:closeFold(nIndex)
	--打开现在
	if tInfo then
		local FoldSubListView = require("app.common.listview.FoldSubListView")
		local pFoldSub = FoldSubListView.new(nIndex, tInfo)
		pFoldSub:setFoldView(self)
		self:openFold(nIndex, pFoldSub)
	end
end

-- 关闭折叠点
function FoldView:closeFold( nIndex )
	local pFold = self.tFoldChildren[nIndex]
	if pFold then
		local pFoldSub = pFold.pFoldSub
		if pFoldSub then
			pFoldSub:removeFromParent()
			pFold.pFoldSub = nil
		end
		-- 刷新内容
		self:refreshContainer()
	end
end

-- 增加折叠点
function FoldView:addFold( nIndex, pFold, bIsReload )
	if pFold then
		local pLay = MUI.MLayer.new()
		local pSize = pFold:getContentSize()
		pLay:setLayoutSize(self.nWidth, pSize.height + self.nTopMargin + self.nBottomMargin ) 
		pLay:addView(pFold)
		centerInView(pLay, pFold)
		self:addView(pLay)
		if nIndex then
			table.insert(self.tFoldLay, nIndex, pLay)
			table.insert(self.tFoldChildren, nIndex, pFold)
		else
			table.insert(self.tFoldLay, pLay)
			table.insert(self.tFoldChildren, pFold)
		end
	end
	if not bIsReload then
	    -- 刷新内容
		self:refreshContainer()
	end
end

-- 刷除折叠点
function FoldView:delFold( nIndex, bIsReload)
	local pFold = self.tFoldChildren[nIndex]
	if pFold then
		local pFoldSub = pFold.pFoldSub
		if pFoldSub then
			pFoldSub:removeFromParent()
			pFold.pFoldSub = nil
		end
		pFold:removeFromParent()
		table.remove(self.tFoldChildren, nIndex)

		local pLay = self.tFoldLay[nIndex]
		pLay:removeFromParent()
		table.remove(self.tFoldLay, nIndex)
	end
	if not bIsReload then
	    -- 刷新内容
		self:refreshContainer()
	end
end

-- 获取折叠节点子节点
function FoldView:getFoldSub( nIndex )
	local pFold = self.tFoldChildren[nIndex]
	if pFold then
		return pFold.pFoldSub
	end
end

-- 刷新子折叠ListView
function FoldView:refreshListViews(  )
	for i=1,#self.tFoldChildren do
		local pFold = self.tFoldChildren[i]
		if pFold then
			local pFoldSub = pFold.pFoldSub
			if pFoldSub and pFoldSub.refreshListViewsByFold then
				pFoldSub:refreshListViewsByFold()
			end
		end
	end
end

--获取打开的下列集
function FoldView:getOpenedIndex(  )
	local tIndex = {}
	for i=1,#self.tFoldChildren do
		local pFold = self.tFoldChildren[i]
		local pFoldSub = pFold.pFoldSub
		if pFoldSub then
			table.insert(tIndex, i)
		end
	end
	return tIndex
end

--获取获取的y坐标
function FoldView:getScrollPosY()
	return self.scrollNode:getPositionY()
end

--设置滚动的y坐标
function FoldView:setScrollPosY( nY )
	if not nY then
		return
	end

	self.scrollNode:setPositionY(nY)
	self:refreshContainer()
end


-- 刷新内容
function FoldView:refreshContainer(  )
	--计算总高度
	local nHeight = 0
	for i=1,#self.tFoldLay do
		local pLay = self.tFoldLay[i]
		local pFold = self.tFoldChildren[i]
		if pLay and pFold then
			nHeight = nHeight + pLay:getHeight()
		
			local pFoldSub = pFold.pFoldSub
			if pFoldSub then
				nHeight = nHeight + pFoldSub:getHeight()
			end
		end
	end
	--回复总高度
	local nTotalH = nHeight
	self.scrollNode:setContentSize(self.nWidth, nTotalH)
	--更新各个位置
	for i=1,#self.tFoldLay do
		local pLay = self.tFoldLay[i]
		local pFold = self.tFoldChildren[i]
		if pLay and pFold then
			local nH = nHeight - pLay:getHeight()
			pLay:setPosition(0, nH)
			local pFoldSub = pFold.pFoldSub
			if pFoldSub then
				nH = nH - pFoldSub:getHeight()
				pFoldSub:setPosition(0, nH)
			end
			nHeight = nH
		end
	end
	--刷新子内容
	self:refreshListViews()

	--当内容高度小于可显示高度时
	local nViewHeight = self:getHeight()

	local nY = self.scrollNode:getPositionY()
	local nOffsetH = 0
	if self.nPrevTotalH then
		nOffsetH = self.nPrevTotalH - nTotalH
	end
	self.nPrevTotalH = nTotalH
	if nOffsetH > 0 then --变小时缩放回去
		self:scrollTo(0, nY + nOffsetH , false)	
	else
		if nViewHeight >= nTotalH then
			self:scrollTo(0, nViewHeight - nTotalH, false)
		else --当内容高度大于可显示高度
			if nY >= 0 then
				self:scrollTo(0, 0, false)
			else
				if nY < nViewHeight - nTotalH then
					self:scrollTo(0, nViewHeight - nTotalH , false)	
				end
			end
		end
	end
end




return FoldView
