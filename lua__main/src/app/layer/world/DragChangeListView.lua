----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-03 11:33:06
-- Description: 列表式拖动更改层
-----------------------------------------------------
local DragChangeListView = class("DragChangeListView", function (size)
	local pView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, size.width, size.height),
        touchOnContent = false,
        direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
        bothSize=cc.size(size.width, size.height)
        })
	return pView
end)

local e_state_dir = {
	horizontal = 1,
	vertical = 2,
}

function DragChangeListView:ctor( size, nDir )
	self.nDir = nDir
	-- self:setContentSize(size)
	-- self:setIsTouches(true)
	-- self:setClipable(false)
	-- self:setMaxScaleTouches(1.0)
	-- if(self.setMinScaleTouches) then
	-- 	self:setMinScaleTouches(1.0)
	-- end

	-- 添加触摸事件
	self:setBounceable(false)
	self:onScroll(handler(self, self.onScrollViewTouch))

	--创建滚动层
	self.pMapViewGroup = MUI.MLayer.new()
	self.pMapViewGroup:setContentSize(size)
	self:addView(self.pMapViewGroup)
	-- 添加点击事件
	-- self:setClickLuaHandler(handler(self, self.onScrollViewClick))

	self.pItems = {}
	self.pItemsExclude = {}
	self.nIsMoving = 0
end

--添加拖动的UI
function DragChangeListView:addItem( pItem,pPos)
	if pItem.tDragChangeAttrs then
		myprint("错误         DragChangeListView:addItem 已存在tDragChangeAttrs")
	end

	self.pMapViewGroup:addChild(pItem)
	pItem:setAnchorPoint(cc.p(0.5, 0.5))
	pItem:setPosition(pPos)
	pItem.tDragChangeAttrs = {
		pPos = pPos,
		isTarget = false,
		nZorder = 0,
	}
	table.insert(self.pItems,pItem)
end

--排除子项UI（存在的子项本身脱离移动队列）
--pItem
function DragChangeListView:excludeItem( pItem)
	for i=1,#self.pItems do
		if self.pItems[i] == pItem then
			table.insert(self.pItemsExclude, pItem)
			table.remove(self.pItems, i)
			break
		end
	end
end

--包括子项UI（存在的子项本身加入移动队列）
--pItem
function DragChangeListView:includeItem( pItem)
	for i=1,#self.pItemsExclude do
		if self.pItemsExclude[i] == pItem then
			table.insert(self.pItems, pItem)
			table.remove(self.pItemsExclude, i)
			break
		end
	end
end

-- scrollView的触摸事件回调
function DragChangeListView:onScrollViewTouch(event)
	if self:getIsMoving() then
		return
	end
	
	local pScrollView = event.scrollView
	local sEvent = event.name
	local x = event.x
	local y = event.y
	local nOriginX = event.originX
	local nOriginY = event.originY

	if sEvent == "began" then -- 手指按下
		-- 重置选项
		self:resetFoundItem()
		-- 查找被选中的item
		for k,pItem in pairs(self.pItems) do
			if self:isPointInItem(pItem,x, y,k) then
				-- 保留偏移的位置
				local attr = pItem.tDragChangeAttrs
				if self.nDir == e_state_dir.vertical then
					attr.fPointX = x - pItem:getPositionX()
					attr.fPointY = y - pItem:getPositionY()					
				else
					attr.fPointX = x - pItem:getPositionX()
					attr.fPointY = 0 - pItem:getPositionY()				
				end				

				self:setItemDrag(pItem,true)
				self.bIsFoundItem = true
				self.pFoundItem = pItem
				break
			end
		end
	elseif sEvent == "moved" then
		if(self.bIsFoundItem) then
			-- 重新设置选中item的位置
			local attr = self.pFoundItem.tDragChangeAttrs
			if attr then
				if self.nDir == e_state_dir.vertical then
					self.pFoundItem:setPosition(x - attr.fPointX, 
						y - attr.fPointY)					
				else
					self.pFoundItem:setPosition(x - attr.fPointX, 
						0 - attr.fPointY)					
				end				
			end
			-- 判断是否存在可交换的item
			for k,pItem in pairs(self.pItems) do
				if pItem ~= self.pFoundItem then
					if self:isPointInItem(pItem,x,y) then
						--设置为目标
						if not pItem.tDragChangeAttrs.isTarget then
							if self:isCanChange(self.pFoundItem,pItem) then
								pItem.tDragChangeAttrs.isTarget = true
								self:setItemTarget(pItem,true)
							end
						end
					else
						if pItem.tDragChangeAttrs.isTarget then
							pItem.tDragChangeAttrs.isTarget = false
							self:setItemTarget(pItem,false)
						end
					end
				end
			end
		end
	elseif sEvent == "ended" then
		self:changeItem()
	else
		self:changeItem()
	end
end

-- 重置
function DragChangeListView:resetFoundItem(  )
	self.pFoundItem = nil
	self.bIsFoundItem = false
	for k,pItem in pairs(self.pItems) do
		if pItem.tDragChangeAttrs.isTarget then
			pItem.tDragChangeAttrs.isTarget = false
		end
		self:setItemDrag(pItem,false)
		self:setItemTarget(pItem,false)
	end
	--排好序
	if self.nDir == e_state_dir.vertical then
		table.sort(self.pItems,function ( a, b )
			return a.tDragChangeAttrs.pPos.y > b.tDragChangeAttrs.pPos.y
		end )
	else
		table.sort(self.pItems,function ( a, b )
			return a.tDragChangeAttrs.pPos.x < b.tDragChangeAttrs.pPos.x
		end )		
	end
end

-- 判断位置是否在目标位置中
function DragChangeListView:isPointInItem( pItem, x, y, k)
	local pRect = pItem:getBoundingBox()
	if cc.rectContainsPoint(pRect, cc.p(x, y)) then
		return true
	end
	return false
end

-- 交换item
function DragChangeListView:changeItem(  )
	if (not self.bIsFoundItem) then
		return 
	end

	local pTargetItem = nil
	-- 判断是否存在可交换的item
	for k,pItem in pairs(self.pItems) do
		if pItem ~= self.pFoundItem then
			if pItem.tDragChangeAttrs.isTarget then
				pTargetItem = pItem
				break
			end
		end
	end
	self.pTargetItem = pTargetItem
	if pTargetItem then
		if self.tTempChangeHandler then
			self.tTempChangeHandler(self.pFoundItem,pTargetItem)
		end
		self:showChangedArm(self.pFoundItem,pTargetItem)
	else
		self:showItemBackArm(self.pFoundItem)
	end
end

-- 点击item
function DragChangeListView:clickItem( )
	if (not self.bIsFoundItem) then
		return 
	end
	if self.nClickedHandler then
		self.nClickedHandler(self.pFoundItem)
	end
end

--设置拖拽效果
function DragChangeListView:setItemDrag( pItem,isSel)
	if self.tItemDragHandler then
		self.tItemDragHandler(pItem,isSel)
		return
	end
	if isSel then
		pItem:setAnchorPoint((cc.p(0.5, 0.5)))
		pItem:setScale(0.99)
		pItem:setOpacity(150)
		pItem:setZOrder(#self.pItems)
	else
		pItem:setAnchorPoint(cc.p(0.5, 0.5))
		pItem:setScale(1.0)
		pItem:setOpacity(255)
		pItem:setZOrder(pItem.tDragChangeAttrs.nZorder)
	end
end

--设置自定义拖拽效果方法
--tHandler：方法 function(pItem)
function DragChangeListView:setItemDragHandler( tHandler)
	self.tItemDragHandler = tHandler
end

--设置目标选中效果
function DragChangeListView:setItemTarget( pItem,isSel)
	if self.tItemTargetHandler then
		self.tItemTargetHandler(pItem,isSel)
		return
	end
end


--设置自定义目标选中效果方法
--tHandler：方法 function(pItem)
function DragChangeListView:setItemTargetHandler( tHandler)
	self.tItemTargetHandler = tHandler
end

--判断是否可以进行交换
--pFoundItem已选那个，pTargetItem想交换的那个
function DragChangeListView:isCanChange( pFoundItem, pTargetItem)
	if self.tIsCanChangeHandler then
		return self.tIsCanChangeHandler(pFoundItem,pTargetItem)
	end
	return true
end

--设置自定义是否可以进行交换方法
--tHandler：方法 function(pFoundItem,pTargetItem) pFoundItem已选那个，pTargetItem想交换的那个,要返回bool
function DragChangeListView:setIsCanChangeHandler( tHandler)
	self.tIsCanChangeHandler = tHandler
end

--显示更换动画
function DragChangeListView:showChangedArm( pFoundItem, pTargetItem)
	local pMoveItems = {}
	local pMoveItemsPos = {}
	
	if self.nDir == e_state_dir.horizontal then
		--znftodo 用到的时候再写
		local nFoundItemIndex = 1
		local nTargetIndex = 1
		for i = 1,#self.pItems do
			if self.pItems[i] == pFoundItem then
				nFoundItemIndex = i
			elseif self.pItems[i] == pTargetItem then
				nTargetIndex = i
			end
		end
		-- print("nFoundItemIndex , nTargetIndex =",nFoundItemIndex,nTargetIndex )
		if nFoundItemIndex < nTargetIndex then
			for i = nFoundItemIndex+1,nTargetIndex do
				if self.pItems[i-1] then
					table.insert(pMoveItems, self.pItems[i])
					table.insert(pMoveItemsPos, self.pItems[i-1].tDragChangeAttrs.pPos)
				end
			end
		else
			for i = nTargetIndex, nFoundItemIndex - 1 do
				if self.pItems[i+1] then
					table.insert(pMoveItems, self.pItems[i])
					table.insert(pMoveItemsPos, self.pItems[i+1].tDragChangeAttrs.pPos)
				end
			end
		end
		table.insert(pMoveItems, pFoundItem)
		table.insert(pMoveItemsPos, pTargetItem.tDragChangeAttrs.pPos)		
	elseif self.nDir == e_state_dir.vertical then
		local nFoundItemIndex = 1
		local nTargetIndex = 1
		for i = 1,#self.pItems do
			if self.pItems[i] == pFoundItem then
				nFoundItemIndex = i
			elseif self.pItems[i] == pTargetItem then
				nTargetIndex = i
			end
		end
		-- print("nFoundItemIndex , nTargetIndex =",nFoundItemIndex,nTargetIndex )
		if nFoundItemIndex < nTargetIndex then
			for i = nFoundItemIndex+1,nTargetIndex do
				if self.pItems[i-1] then
					table.insert(pMoveItems, self.pItems[i])
					table.insert(pMoveItemsPos, self.pItems[i-1].tDragChangeAttrs.pPos)
				end
			end
		else
			for i = nTargetIndex, nFoundItemIndex - 1 do
				if self.pItems[i+1] then
					table.insert(pMoveItems, self.pItems[i])
					table.insert(pMoveItemsPos, self.pItems[i+1].tDragChangeAttrs.pPos)
				end
			end
		end
		table.insert(pMoveItems, pFoundItem)
		table.insert(pMoveItemsPos, pTargetItem.tDragChangeAttrs.pPos)
	end

	self.nIsMoving = #pMoveItems
	--移动
	for i = 1,#pMoveItems do
		local pItem = pMoveItems[i]
		local pMoveTo = cc.MoveTo:create(0.1, pMoveItemsPos[i])
		local pDelay = cc.DelayTime:create(0.1)
		local pCallFunc = cc.CallFunc:create(function (  )
			local fX, fY = pItem:getPosition()
			pItem.tDragChangeAttrs.pPos.x = fX
			pItem.tDragChangeAttrs.pPos.y = fY
			self.nIsMoving = self.nIsMoving - 1
			if self.nIsMoving <= 0 then
				self:moveArmOver()
			end
		end)
		pItem:runAction(cc.Sequence:create({pMoveTo, pDelay, pCallFunc}))
	end
end


--显示复位动画
function DragChangeListView:showItemBackArm( pItem )
	self.bIsMoving1 = true
	local attr = pItem.tDragChangeAttrs
	local pMt = cc.MoveTo:create(0.1, attr.pPos)
	local pCallFunc = cc.CallFunc:create(function (  )
			self.bIsMoving1 = false
			self:setItemDrag(pItem,false)
			self:moveArmOver()
		end)
	pItem:runAction(cc.Sequence:create({pMt, pCallFunc}))
end

--动画结束
function DragChangeListView:moveArmOver( )
	if self:getIsMoving() then
		return
	end
	
	--进行成功交换
	local bIsSuccess = false
	local pFoundItem = self.pFoundItem
	local pTargetItem = self.pTargetItem
	if self.pFoundItem and self.pTargetItem then
		bIsSuccess = true
	end
	self:resetFoundItem()	
	--执行自定义交换数据
	if self.tChangeSuccessHandler and bIsSuccess then
		self.tChangeSuccessHandler(pFoundItem, pTargetItem)
	end
end



--设置临时交换的显示
--tHandler：方法 function(pFoundItem,pTargetItem)
function DragChangeListView:setTempChangeHandler( tHandler)
	self.tTempChangeHandler = tHandler
end

--设置更换成功结束回调
--tHandler：方法 function(pFoundItem,pTargetItem)
function DragChangeListView:setChangeSuccessHandler( tHandler)
	self.tChangeSuccessHandler = tHandler
end

--设置点击回调
function DragChangeListView:setClickedHandler( nHandler )
	self.nClickedHandler = nHandler
end

--是否在移动动画中
function DragChangeListView:getIsMoving(  )
	return self.bIsMoving1 or self.nIsMoving > 0
end

--返回当前在序的列表
function DragChangeListView:getItemList()
	return self.pItems
end

function DragChangeListView:getAllItemList()
	local tItems = {}
	if self.pItems and #self.pItems > 0 then
		for k, v in pairs(self.pItems) do
			table.insert(tItems, v)
		end
	end
	if self.pItemsExclude and #self.pItemsExclude > 0 then
		for k, v in pairs(self.pItemsExclude) do
			table.insert(tItems, v)
		end
	end
	--排好序
	if self.nDir == e_state_dir.vertical then
		table.sort(tItems,function ( a, b )
			return a.tDragChangeAttrs.pPos.y > b.tDragChangeAttrs.pPos.y
		end )
	else
		table.sort(tItems,function ( a, b )
			return a.tDragChangeAttrs.pPos.x < b.tDragChangeAttrs.pPos.x
		end )
	end	
	return tItems 
end
return DragChangeListView



	