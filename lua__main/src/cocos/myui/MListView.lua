----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 17:02:47 
-- Description: 自定义列表
-----------------------------------------------------

--------------------------------
-- @module MListView

local MScrollLayer = import(".MScrollLayer")
local MListView = myclass("MListView", MScrollLayer)

local MListViewItem = import(".MListViewItem")


MListView.DELEGATE					= "ListView_delegate"
MListView.TOUCH_DELEGATE			= "ListView_Touch_delegate"

MListView.CELL_TAG					= "Cell"
MListView.CELL_SIZE_TAG				= "CellSize"
MListView.COUNT_TAG					= "Count"
MListView.CLICKED_TAG				= "Clicked"
MListView.UNLOAD_CELL_TAG			= "UnloadCell"

MListView.BG_ZORDER 				= -1
MListView.CONTENT_ZORDER			= 10

MListView.ALIGNMENT_LEFT			= 0
MListView.ALIGNMENT_RIGHT			= 1
MListView.ALIGNMENT_VCENTER			= 2
MListView.ALIGNMENT_TOP				= 3
MListView.ALIGNMENT_BOTTOM			= 4
MListView.ALIGNMENT_HCENTER		 	= 5

MListView.SCROLL_TIME 				= 0.3	

-- start --

--------------------------------
-- MListView构建函数
-- @function [parent=#MListView] new
-- @param table params 参数表

--[[--

MListView构建函数

可用参数有：

-   direction 列表控件的滚动方向，默认为垂直方向
-   alignment listViewItem中content的对齐方式，默认为垂直居中
-   viewRect 列表控件的显示区域
-   scrollbarImgH 水平方向的滚动条
-   scrollbarImgV 垂直方向的滚动条
-   bgColor 背景色,nil表示无背景色
-   bgStartColor 渐变背景开始色,nil表示无背景色
-   bgEndColor 渐变背景结束色,nil表示无背景色
-   bg 背景图
-   bgScale9 背景图是否可缩放
-	capInsets 缩放区域
-   divider listView中item之间的间隔距离\
-   headerView 列表头
-   footerView 列表尾
-   itemMargin item上下左右间隔

]]
-- end --

function MListView:ctor(params)
	MListView.super.ctor(self, params)
	self:__mlistviewInit()

    self:setSpecialDestroyCallback(handler(self, self.onSpecialDestroy))

	self.direction = params.direction or MScrollLayer.DIRECTION_VERTICAL
	self.alignment = params.alignment or MListView.ALIGNMENT_VCENTER
	self.m_itemMargin = params.itemMargin
	-- self.padding_ = params.padding or {left = 0, right = 0, top = 0, bottom = 0}

	-- params.viewRect.x = params.viewRect.x + self.padding_.left
	-- params.viewRect.y = params.viewRect.y + self.padding_.bottom
	-- params.viewRect.width = params.viewRect.width - self.padding_.left - self.padding_.right
	-- params.viewRect.height = params.viewRect.height - self.padding_.bottom - self.padding_.top

	self:setDirection(self.direction)
	self:setViewRect(params.viewRect)
	self:onScroll(handler(self, self.scrollListener))


	--目前只针对竖向的listview做列表头和列表尾的扩充，横线的先保留
	self.headerViewW = 0
	self.headerViewH = 0
	self.footerViewW = 0
	self.footerViewH = 0
	if self.direction == MScrollLayer.DIRECTION_VERTICAL then
		--列表头
		self:addHeaderView(params.headerView)
		--列表尾
		self:addFooterView(params.footerView)
	end

	self.size = {}
	self.itemsFree_ = {}
	self.redundancyViewVal = 0 --异步的视图两个方向上的冗余大小,横向代表宽,竖向代表高

	self.args_ = {params}

	-- 定义回调函数
	self.delegate_ = {}
    self:setDelegate(function ( _iContent, _tag, _index )
        if MUI.MListView.COUNT_TAG == _tag then
            return self:getItemCount()
        elseif MUI.MListView.CELL_TAG == _tag then
        	local pItem = nil
        	if(self.m_callbackItem) then
        		pItem = self.m_callbackItem(_index, _iContent)
        	end
            
            return pItem
        else
        end
    end)
    self:align(display.LEFT_BOTTOM)
end

function MListView:__mlistviewInit(  )
	self:__setViewType(MUI.VIEW_TYPE.listview)
	self.items_ = {}
	self.m_itemW = 0 -- item的宽度，在reload的时候重新记录
	self.m_itemH = 0 -- item的高度，在reload的时候重新记录
	self.container = MUI.MLayer.new()
	self.container:setContentSize(0, 0)-- 每次都需要重置高度，暂时还未找到原因	
	self:addScrollNode(self.container)
	self.m_bIsLoadingData = false -- 是否正在初始化数据
	self.m_tmpScaleX = 1 -- 临时用来记录缩放值的变量，在update中实时刷新，为了复用刷新时增加的
	self.m_tmpScaleY = 1 -- 临时用来记录缩放值的变量，在update中实时刷新，为了复用刷新时增加的
	self.m_bItemAction = false -- item是否需要进场动画
	self.m_nItemCount = 0 -- 多少个项
end

function MListView:onSpecialDestroy()
	self:releaseAllFreeItems_()	
end

-- start --

--------------------------------
-- 列表控件触摸注册函数
-- @function [parent=#MListView] onTouch
-- @param function listener 触摸临听函数
-- @return MListView#MListView  self 自身

-- end --

function MListView:onTouch(listener)
	self.touchListener_ = listener

	return self
end

-- start --

--------------------------------
-- 列表控件设置所有listItem中content的对齐方式
-- @function [parent=#MListView] setAlignment
-- @param number align 对
-- @return MListView#MListView  self 自身

-- end --

function MListView:setAlignment(align)
	self.alignment = align
end

-- start --

--------------------------------
-- 列表滚动到某一项
-- @function [parent=#MListView] scrollToPosition
-- @param number _nPos 某一项
-- @return MListView#MListView  self 自身

-- end --
function MListView:scrollToPosition( _nPos, _bAction, _handler )
	local bToFooter = false
	local bToHeader = false
	if _nPos <=0 then
		if(self.pHeaderView and _nPos == 0) then
			bToHeader = true
			_nPos = 1
		else
			return
		end
	end
	if _nPos > self.m_nItemCount then
		if(self.pFooterView and _nPos == self.m_nItemCount+1) then
			bToFooter = true
			_nPos = self.m_nItemCount
		else
			return
		end
	end
	-- 检测第一项是否已经加载过了
	self:checkFirstItem()
	local itemW, itemH = self.m_itemW, self.m_itemH
	if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
		--最大的移动长度
		local nMaxLength = self.m_nItemCount * itemH + self.headerViewH + self.footerViewH
		local y__ = (_nPos - 1) * itemH + self.viewRect_.height + self.headerViewH
		if(bToFooter) then
			y__ = y__ + self.footerViewH
		elseif(bToHeader) then
			y__ = y__ - self.headerViewH
		end
		if y__ > nMaxLength then
			y__ = nMaxLength
		end
		local xx, yy = self:__checkMaxState(self.scrollNode:getPositionX(), y__, 0)
		self:scrollTo(xx, yy, false, _handler)
	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
		--总长
		local fTotal = self.m_nItemCount * itemW
		local nLength = (_nPos - 1) * itemW 
		--最大的移动长度
		local nMax = self.viewRect_.width - fTotal
		local x__ = -nLength 
		if(bToFooter) then
			x__ = x__ - self.footerViewW
		elseif(bToHeader) then
			x__ = x__ + self.headerViewW
		end
		if x__ < nMax then
			x__ = nMax
		end
		local xx, yy = self:__checkMaxState(x__, self.scrollNode:getPositionY(), 0)
		self:scrollTo(xx, yy, false, _handler)
	end
end

-- start --

--------------------------------
-- 设置列表尾是否展示
-- @function [parent=#MListView] setFooterVisible
-- @param 
-- @return MListViewItem#MListViewItem 

-- end --
function MListView:setFooterVisible( _bEnable )
	-- body
	if self.pFooterView then
		self.pFooterView:setVisible(_bEnable)
	end
end

-- start --

--------------------------------
-- 滚动到第一项
-- @function [parent=#MListView] scrollToBegin
-- @return MListViewItem#MListViewItem 

-- end --
function MListView:scrollToBegin( )
	-- body
	if self.pHeaderView then
		-- 滑动到第0项
		self:scrollToPosition(0)
	else
		-- 滑动到第1项
		self:scrollToPosition(1)
	end
end

-- start --

--------------------------------
-- 滚动到最后一项
-- @function [parent=#MListView] scrollToEnd
-- @return MListViewItem#MListViewItem 

-- end --
function MListView:scrollToEnd( )
	-- body
	if self.pFooterView then
		-- count+1项
		self:scrollToPosition(self.m_nItemCount+1)
	else
		-- count项
		self:scrollToPosition(self.m_nItemCount)
	end
end

-- start --

--------------------------------
-- 创建一个新的listViewItem项
-- @function [parent=#MListView] newItem
-- @param node item 要放到listViewItem中的内容content
-- @return MListViewItem#MListViewItem 

-- end --

function MListView:newItem()
	local item = MListViewItem.new()
	item:setDirction(self.direction)
	item:setMargin(self.m_itemMargin)
	item:onSizeChange(handler(self, self.itemSizeChangeListener))
	return item
end

-- start --

--------------------------------
-- 设置显示区域
-- @function [parent=#MListView] setViewRect
-- @return MListView#MListView  self

-- end --

function MListView:setViewRect(viewRect)
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		self.redundancyViewVal = viewRect.height
	else
		self.redundancyViewVal = viewRect.width
	end

	MListView.super.setViewRect(self, viewRect)

	return self
end

function MListView:itemSizeChangeListener(listItem, newSize, oldSize)
	local pos = self:getItemPos(listItem)
	if not pos then
		return
	end

	local itemW, itemH = newSize.width - oldSize.width, newSize.height - oldSize.height
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		itemW = 0
	else
		itemH = 0
	end

	local content = listItem:getContent()
	transition.moveBy(content,
				{x = itemW/2, y = itemH/2, time = 0.2})

	self.size.width = self.size.width + itemW
	self.size.height = self.size.height + itemH
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		transition.moveBy(self.container,
			{x = -itemW, y = -itemH, time = 0.2})
		self:moveItems(1, pos - 1, itemW, itemH, true)
	else
		self:moveItems(pos + 1, table.nums(self.items_), itemW, itemH, true)
	end
end

function MListView:scrollListener(event)
	if "clicked" == event.name then
		local nodePoint = self.container:convertToNodeSpace(cc.p(event.x, event.y))
		local itemRect = cc.rect(0, 0, 0, 0)
		local pos
		local idx

		for i,v in ipairs(self.items_) do
			itemRect.x, itemRect.y = v:getPosition()
			itemRect.width, itemRect.height = v:getItemSize()			
			if cc.rectContainsPoint(itemRect, nodePoint) then
				idx = v.idx_
				pos = i
				break
			end
		end

		self:notifyListener_{name = "clicked",
			listView = self, itemPos = idx, item = self.items_[pos],
			point = nodePoint}
	else
		event.scrollView = nil
		event.listView = self
		self:notifyListener_(event)
	end
end

-- start --

--------------------------------
-- 在列表项中添加一项
-- @function [parent=#MListView] addItem
-- @param node listItem 要添加的项
-- @param integer pos 要添加的位置,默认添加到最后
-- @return MListView#MListView 

-- end --

function MListView:addItem(listItem, pos)
	self:modifyItemSizeIf_(listItem)

	if pos then
		table.insert(self.items_, pos, listItem)
	else
		table.insert(self.items_, listItem)
	end
	self.container:addView(listItem)

	return self
end

-- start --

--------------------------------
-- 根据下标获得item
-- @function [parent=#MListView] getItemByIdx
-- @param number _idx item下班标
-- @return MListView#MListView 

-- end --

function MListView:getItemByIdx( _idx )
	-- body
	if not _idx then
		return
	end
	local pItem = nil
	for k, v in pairs (self.items_) do
		if v.idx_ == _idx then
			pItem = v
			break
		end
	end
	return pItem
end

-- start --

--------------------------------
-- 在列表项中移除一项
-- @function [parent=#MListView] removeItem
-- @param node listItem 要移除的项
-- @param boolean bAni 是否要显示移除动画
-- @return MListView#MListView 

-- end --

function MListView:removeItem(listItem, bAni)
	if(true) then
		print("此方法已取消：MListView:removeItem")
		return
	end

	local itemW, itemH = listItem:getItemSize()
	self.container:removeChild(listItem)

	local pos = self:getItemPos(listItem)
	if pos then
		table.remove(self.items_, pos)
	end

	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		itemW = 0
	else
		itemH = 0
	end

	self.size.width = self.size.width - itemW
	self.size.height = self.size.height - itemH

	if 0 == table.nums(self.items_) then
		return
	end
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		self:moveItems(1, pos - 1, -itemW, -itemH, bAni)
	else
		self:moveItems(pos, table.nums(self.items_), -itemW, -itemH, bAni)
	end

	return self
end

-- start --

--------------------------------
-- 移除所有的项
-- @function [parent=#MListView] removeAllItems
-- @return integer#integer 

-- end --

function MListView:removeAllItems()
	-- 将所有item放回freeitems中,这里是倒序移除
	if(self.items_ and #self.items_ > 0) then
		local nTotalCount = #self.items_
		for i=nTotalCount, 1, -1 do
			local pItem = self.items_[i]
			if(pItem) then
				-- 将所有的项都返回缓存列表中
				self:unloadOneItem_(pItem.idx_)
			end
		end
	end
    self.container:removeAllChildren()
    self.items_ = {}
    self.bHeaderHad = false
    self.bFooterHad = false

    return self
end

--移除列表头
function MListView:removeHeaderView( )
	-- body
	if self.pHeaderView then
		self.pHeaderView:removeSelf()
		self.pHeaderView:release()
		self.pHeaderView = nil
	end
	self.headerViewW = 0
	self.headerViewH = 0
	self.bHeaderHad = false
end

--添加列表头
function MListView:addHeaderView( pView )
	-- body
	self.pHeaderView = pView
	if self.pHeaderView then
		self.pHeaderView:retain()
		self.headerViewW = self.pHeaderView:getWidth()
		self.headerViewH = self.pHeaderView:getHeight()
	end
end

--移除列表尾
function MListView:removeFooterView( )
	-- body
	if self.pFooterView then
		self.pFooterView:removeSelf()
		self.pFooterView:release()
		self.pFooterView = nil
	end
	self.footerViewW = 0
	self.footerViewH = 0
	self.bFooterHad = false
end

--添加列表尾
function MListView:addFooterView( pView )
	-- body
	self.pFooterView = pView
	if self.pFooterView then
		self.pFooterView:retain()
		self.footerViewW = self.pFooterView:getWidth()
		self.footerViewH = self.pFooterView:getHeight()
	end
end

-- start --

--------------------------------
-- 取某项在列表控件中的位置
-- @function [parent=#MListView] getItemPos
-- @param node listItem 列表项
-- @return integer#integer 

-- end --

function MListView:getItemPos(listItem)
	for i,v in ipairs(self.items_) do
		if v == listItem then
			return i
		end
	end
end

-- start --

--------------------------------
-- 判断某项是否在列表控件的显示区域中
-- @function [parent=#MListView] isItemInViewRect
-- @param integer pos 列表项位置
-- @return boolean#boolean 

-- end --

function MListView:isItemInViewRect(pos)
	if(not pos) then
		return false
	end
	-- 如果还没有初始化，则返回false
	if(self.m_itemW <= 0) then
		-- 初始化前第一项默认都是可见的，这样为了完成初始化
		if(pos == 1) then
			return true
		end
		return false
	end
	local tmpX = 0 -- 临时的x值
	local tmpY = 0 -- 临时的y值
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		tmpY = -self.m_itemH * pos
		if self.pHeaderView then
			tmpY = - self.pHeaderView:getHeight() + tmpY
		end
	else
		tmpX = self.m_itemW * (pos-1)
		if self.pHeaderView then
			tmpX = self.pHeaderView:getWidth() + tmpX
		end
	end
	-- 构建一个矩形
	local bound = cc.rect(tmpX, tmpY, self.m_itemW, self.m_itemH)
	local nodePoint = self.container:convertToWorldSpace(cc.p(bound.x, bound.y))
	bound.x = nodePoint.x
	bound.y = nodePoint.y
	-- 显示区域的矩形
	local viewrect = cc.rect(self.viewRect_.x, self.viewRect_.y, self.viewRect_.width, self.viewRect_.height)
	local viewPoint = self:convertToWorldSpace(cc.p(viewrect.x, viewrect.y))
	viewrect.x = viewPoint.x
	viewrect.y = viewPoint.y
	-- 判断矩形的相交情况
	return cc.rectIntersectsRect(viewrect, bound)
end
-- 重置容器的位置
function MListView:resetContainerPosition(  )
	-- 如果控件未初始化，直接处理在0位置
	if(self.m_itemW <= 0) then
		-- 重新摆放容器的位置
		if MScrollLayer.DIRECTION_VERTICAL == self.direction then
			self.container:setPosition(self.viewRect_.x,
				self.viewRect_.y + self.viewRect_.height)
		else
			self.container:setPosition(self.viewRect_.x, self.viewRect_.y)
		end
	else
		local oldX, oldY = self.container:getPositionX(), self.container:getPositionY()
		local count = self:getItemCount()
		local maxPos = 0
		if MScrollLayer.DIRECTION_VERTICAL == self.direction then
			maxPos = self.m_itemH * count
			-- 头部项
			if self.pHeaderView then
				maxPos = self.pHeaderView:getHeight() + maxPos
			end
			--列表尾
			if self.pFooterView then
				maxPos = self.pFooterView:getHeight() + maxPos
			end
			if(maxPos < self.viewRect_.height) then
				maxPos = self.viewRect_.height
			end
			if(oldY > maxPos) then
				self:scrollTo(oldX, maxPos, false)
			end
		else
			maxPos = - self.m_itemW * count + self.viewRect_.width
			-- 头部项
			if self.pHeaderView then
				maxPos = -self.pHeaderView:getWidth() + maxPos
			end
			--列表尾
			if self.pFooterView then
				maxPos = -self.pFooterView:getWidth() + maxPos
			end
			if(oldX < maxPos) then
				self:scrollTo(maxPos, oldY, false)
			end
		end
	end
end
-- 根据下标获取item的xy位置
-- _pos（number）：当前项的下标
-- return(cc.p): item的位置
function MListView:getPositionByIndex( _pos )
	local tmpX = 0 -- 临时的x值
	local tmpY = 0 -- 临时的y值
	if(not _pos or _pos < 1 or _pos > self:getItemCount() or self.m_itemW <= 0) then
		if MScrollLayer.DIRECTION_VERTICAL == self.direction then
			if self.pHeaderView then
				tmpY = - self.pHeaderView:getHeight() + tmpY
			end
		else
			if self.pHeaderView then
				tmpX = self.pHeaderView:getWidth() + tmpX
			end
		end
		return tmpX, tmpY
	end
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		tmpY = -self.m_itemH * _pos
		if self.pHeaderView then
			tmpY = - self.pHeaderView:getHeight() + tmpY
		end
		-- 刻意返回上一个item的位置，目的为了和loadOneItem结合使用
		tmpY = tmpY + self.m_itemH
	else
		tmpX = self.m_itemW * (_pos-1)
		if self.pHeaderView then
			tmpX = self.pHeaderView:getWidth() + tmpX
		end
	end
	return tmpX, tmpY
end

-- start --

--------------------------------
-- 加载列表
-- @function [parent=#MListView] reload
-- @param _async boolean 是否使用分帧模式
-- @return MListView#MListView 
-- end --

function MListView:reload( _async )
	if(_async == nil) then
		_async = false
	end
	-- 执行实际的加载行为
	self:asyncLoad_(true, _async)

	return self
end
--------------------------------
-- 刷新列表数据
-- @function [parent=#MListView] notifyDataSetChange
-- @param boolean _bAsync：是否分帧刷新
-- @param number _newCount: 新的item总个数
-- @return MListViewItem#MListViewItem 

-- end --
function MListView:notifyDataSetChange( _bAsync, _newCount )
	-- body
	if _bAsync == nil then
		_bAsync = true
	end
	-- 如果传进来新的count值，重置一下
	if(_newCount) then
		self:setItemCount(_newCount)
	end
	-- 重新加载数据
	self:asyncLoad_(false, _bAsync)
end

-- start --

--------------------------------
-- 取一个空闲项出来,如果没有返回空
-- @function [parent=#MListView] getFreeItem
-- @return MListViewItem#MListViewItem  item
-- @see MListViewItem

-- end --

function MListView:getFreeItem()
	if #self.itemsFree_ < 1 then
		return
	end

	local item
	item = table.remove(self.itemsFree_, 1)

	--标识从free中取出,在loadOneItem_中调用release
	--这里直接调用release,item会被释放掉
	item.bFromFreeQueue_ = true

	return item
end

function MListView:layout_()
	local width, height = 0, 0
	local itemW, itemH = 0, 0
	local margin

	-- calcate whole width height
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		width = self.viewRect_.width

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			height = height + itemH
		end
	else
		height = self.viewRect_.height

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			width = width + itemW
		end
	end
	self:setActualRect({x = self.viewRect_.x,
		y = self.viewRect_.y,
		width = width,
		height = height})
	self.size.width = width
	self.size.height = height

	local tempWidth, tempHeight = width, height
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		itemW, itemH = 0, 0

		local content
		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			tempHeight = tempHeight - itemH
			content = v:getContent()
			content:setAnchorPoint(0.5, 0.5)
			-- content:setPosition(itemW/2, itemH/2)
			self:setPositionByAlignment_(content, itemW, itemH, v:getMargin())
			v:setPosition(self.viewRect_.x,
				self.viewRect_.y + tempHeight)
		end
	else
		itemW, itemH = 0, 0
		tempWidth = 0

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			content = v:getContent()
			content:setAnchorPoint(0.5, 0.5)
			-- content:setPosition(itemW/2, itemH/2)
			self:setPositionByAlignment_(content, itemW, itemH, v:getMargin())
			v:setPosition(self.viewRect_.x + tempWidth, self.viewRect_.y)
			tempWidth = tempWidth + itemW
		end
	end

	self.container:setPosition(0, self.viewRect_.height - self.size.height)
end

function MListView:notifyItem(point)
	local count = self.listener[MListView.DELEGATE](self, MListView.COUNT_TAG)
	local temp = (self.direction == MListView.DIRECTION_VERTICAL and self.container:getContentSize().height) or 0
	local w,h = 0, 0
	local tag = 0

	for i = 1, count do
		w,h = self.listener[MListView.DELEGATE](self, MListView.CELL_SIZE_TAG, i)
		if self.direction == MListView.DIRECTION_VERTICAL then
			temp = temp - h
			if point.y > temp then
				point.y = point.y - temp
				tag = i
				break
			end
		else
			temp = temp + w
			if point.x < temp then
				point.x = point.x + w - temp
				tag = i
				break
			end
		end
	end

	if 0 == tag then
		printInfo("MListView - didn't found item")
		return
	end

	local item = self.container:getChildByTag(tag)
	self.listener[MListView.DELEGATE](self, MListView.CLICKED_TAG, tag, point)
end

function MListView:moveItems(beginIdx, endIdx, x, y, bAni)
	if 0 == endIdx then
		self:elasticScroll()
	end

	local posX, posY = 0, 0

	local moveByParams = {x = x, y = y, time = 0.2}
	for i=beginIdx, endIdx do
		if bAni then
			if i == beginIdx then
				moveByParams.onComplete = function()
					self:elasticScroll()
				end
			else
				moveByParams.onComplete = nil
			end
			transition.moveBy(self.items_[i], moveByParams)
		else
			posX, posY = self.items_[i]:getPosition()
			self.items_[i]:setPosition(posX + x, posY + y)
			if i == beginIdx then
				self:elasticScroll()
			end
		end
	end
end

function MListView:notifyListener_(event)
	if not self.touchListener_ then
		return
	end

	self.touchListener_(event)
end

function MListView:modifyItemSizeIf_(item)
	local w, h = item:getItemSize()

	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		if w ~= self.viewRect_.width then
			item:setItemSize(self.viewRect_.width, h, true)
		end
	else
		if h ~= self.viewRect_.height then
			item:setItemSize(w, self.viewRect_.height, true)
		end
	end
end

function MListView:update_(dt)
	MListView.super.update_(self, dt)
	-- 重置实际显示时的缩放大小
	self:resetContainerScale()
	if(not self.m_bIsLoadingData) then
		if(self:__needCheckItems()) then
			self:increaseOrReduceItem_()
		end
	end
end
-- 检测是否需要再进行update中的 item位置检测
function MListView:__needCheckItems( )
	-- 拖动界面时，需要刷新
	if(self.bDrag_) then
		return true
	end
	-- container处于滑动过程中，需要刷新
	if(self.bScrolling_) then
		return true
	end
	-- 重置位置了，需要刷新
	if(self.bReposing_) then
		return true
	end
	return false
end
--[[--

动态调整item,是否需要加载新item,移除旧item
私有函数

]]
function MListView:increaseOrReduceItem_()

	if 0 == #self.items_ then
		-- print("ERROR items count is 0")
		return
	end

	local getContainerCascadeBoundingBox = function ()
		local boundingBox
		for i, item in ipairs(self.items_) do
			local w,h = item:getItemSize()
			local x,y = item:getPosition()
			local anchor = item:getAnchorPoint()
			x = x - anchor.x * w
			y = y - anchor.y * h

			if boundingBox then
				boundingBox = cc.rectUnion(boundingBox, cc.rect(x, y, w, h))
			else
				boundingBox = cc.rect(x, y, w, h)
			end
		end

		local point = self.container:convertToWorldSpace(cc.p(boundingBox.x, boundingBox.y))
		boundingBox.x = point.x
		boundingBox.y = point.y
		return boundingBox
	end

	local count = self.delegate_[MListView.DELEGATE](self, MListView.COUNT_TAG)
	local nNeedAdjust = 2 --作为是否还需要再增加或减少item的标志,2表示上下两个方向或左右都需要调整
	local cascadeBound = getContainerCascadeBoundingBox()
	local localPos = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
	local item
	local itemW, itemH

	-- print("child count:" .. self.container:getChildrenCount())
	-- dump(cascadeBound, "increaseOrReduceItem_ cascadeBound:")
	-- dump(self.viewRect_, "increaseOrReduceItem_ viewRect:")

	if MScrollLayer.DIRECTION_VERTICAL == self.direction then

		--ahead part of view
		local disH = localPos.y + cascadeBound.height - self.viewRect_.y - self.viewRect_.height
		local tempIdx
		item = self.items_[1]
		if not item then
			print("increaseOrReduceItem_ item is nil, all item count:" .. #self.items_)
			return
		end
		tempIdx = item.idx_
		-- print(string.format("befor disH:%d, view val:%d", disH, self.redundancyViewVal))
		if disH > self.redundancyViewVal then
			itemW, itemH = item:getItemSize()
			if cascadeBound.height - itemH - self.headerViewH > self.viewRect_.height
				and disH - itemH - self.headerViewH > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx - 1
			if tempIdx > 0 then
				local localPoint = self.container:convertToNodeSpace(
					cc.p(cascadeBound.x, cascadeBound.y + cascadeBound.height* self.m_tmpScaleY))
				item = self:loadOneItem_(nil, localPoint, tempIdx, true)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end

		--part after view
		disH = self.viewRect_.y - localPos.y
		item = self.items_[#self.items_]
		if not item then
			return
		end
		tempIdx = item.idx_
		-- print(string.format("after disH:%d, view val:%d", disH, self.redundancyViewVal))
		if disH > self.redundancyViewVal then
			itemW, itemH = item:getItemSize()
			if cascadeBound.height - itemH - self.headerViewH > self.viewRect_.height
				and disH - itemH - self.headerViewH > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx + 1
			if tempIdx <= count then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
				item = self:loadOneItem_(nil, localPoint, tempIdx)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end
	else
		--left part of view
		local disW = self.viewRect_.x - localPos.x
		item = self.items_[1]
		local tempIdx = item.idx_
		if disW > self.redundancyViewVal then
			itemW, itemH = item:getItemSize()
			if cascadeBound.width - itemW > self.viewRect_.width
				and disW - itemW > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx - 1
			if tempIdx > 0 then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
				item = self:loadOneItem_(nil, localPoint, tempIdx, true)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end

		--right part of view
		disW = localPos.x + cascadeBound.width - self.viewRect_.x - self.viewRect_.width
		item = self.items_[#self.items_]
		tempIdx = item.idx_
		if disW > self.redundancyViewVal then
			itemW, itemH = item:getItemSize()
			if cascadeBound.width - itemW > self.viewRect_.width
				and disW - itemW > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx)
			else
				nNeedAdjust = nNeedAdjust - 1
			end
		else
			item = nil
			tempIdx = tempIdx + 1
			if tempIdx <= count then
				local localPoint = self.container:convertToNodeSpace(cc.p(
					cascadeBound.x + cascadeBound.width* self.m_tmpScaleX, cascadeBound.y))
				item = self:loadOneItem_(nil, localPoint, tempIdx)
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1
			end
		end
	end

	-- print("increaseOrReduceItem_() adjust:" .. nNeedAdjust)
	-- print("increaseOrReduceItem_() item count:" .. #self.items_)
	if nNeedAdjust > 0 then
		return self:increaseOrReduceItem_()
	else
		if(self.bReposing_) then
			self.bReposing_ = false
		end
	end
end

-- 检测有没有尾部
-- _index(int): 要处理的下标
function MListView:checkFooterView( _index, _posX, _posY )
	--列表尾
	if self.pFooterView then
		if _index == self.m_nItemCount then
			if not self.bFooterHad  then
				self.bFooterHad = true
				self.container:addView(self.pFooterView)
				_posX = _posX or 0
				_posY = _posY or 0
				self.pFooterView:setPosition(0, _posY - self.footerViewH)
			end
		end
	end
end
-- 检测有没有头部，有的话，添加进去
-- _index(int): 要处理的下标
function MListView:checkHeadView( _index )
	if self.pHeaderView then
		if(_index == 1) then
			if not self.bHeaderHad  then
				self.bHeaderHad = true
				self.container:addView(self.pHeaderView)
				self.pHeaderView:setPosition(0, -self.headerViewH)
			end
		end
	end
end

--[[--

复用加载列表数据
@params _index int 当前加载到第几项
@return MListView
]]
function MListView:asyncLoad_( _bNew, _bAsync )
	-- if(_bNew) then
		-- 重置宽高
		-- self.m_itemW = 0
		-- self.m_itemH = 0
		-- -- 将所有控件放回空闲列表中
		-- self:removeAllItems()
	-- end
	-- 重新刷新列表的位置
	self:resetContainerPosition()
	-- 重置每项item的内容
	self.items_ = self.items_ or {}
	local count = self.delegate_[MListView.DELEGATE](self, MListView.COUNT_TAG)
	local itemW, itemH = 0, 0
	local item
	local containerW, containerH = 0, 0
	local posX, posY = 0, 0
	local bIsFinished = false
	if(count <= 0) then
		-- 将所有控件放回空闲列表中
		self:removeAllItems()
		-- 检测有没有头部
		self:checkHeadView(1)
		-- 检测有没有尾部
		self:checkFooterView(self.m_nItemCount)
		--znftodo不知道为什么出错
		if self.checkIsShowArrow_ then
			self:checkIsShowArrow_()
		end
		return self
	end
	-- 加载的起始位置和结束位置
	local nStartIndex = nil
	local nEndIndex = nil
	-- 已经初始化过了
	if(self.m_itemW > 0) then
		local newIndex = 0
		for i=1, count, 1 do
			-- 如果该控件在可视范围内
			if(self:isItemInViewRect(i)) then
				if(not nStartIndex) then
					nStartIndex = i
				end
				nEndIndex = i
				-- 重新获取item的位置
				newIndex = newIndex + 1
				if(self.items_[newIndex]) then
					posX, posY = self:getPositionByIndex(i)
					-- 重置下标值
					self.items_[newIndex].idx_ = i
					-- 重置展示的位置
					self:resetSingleItemPos(self.items_[newIndex], 
						i, posX, posY, false)
				end
			else
				if(nEndIndex) then
					break
				end
			end
		end
		-- 如果还有剩余的不在显示区域内的item，把它回收掉
		local nItemsCount = #self.items_
		for i=nItemsCount, newIndex+1, -1 do
			self:unloadOneItem_(i, true)
		end
	else
		-- 将所有控件放回空闲列表中
		self:removeAllItems()
	end
	-- 执行默认值校验
	nStartIndex = nStartIndex or 1
	nEndIndex = nEndIndex or count
	-- 非分帧加载的模式加载内容
	if(not _bAsync) then
		-- 遍历需要处理的项
		local bFound = false
		-- 重新加载所有控件
		for i=nStartIndex, nEndIndex, 1 do
			-- 获取该item在列表中的位置
			if(self:isItemInViewRect(i)) then
				posX, posY = self:getPositionByIndex(i)
				-- 重置一下item的内容
				item, itemW, itemH = self:loadOneItem_(
					self.items_[i-nStartIndex+1], cc.p(posX, posY), i)
				if(not bFound) then
					bFound = true
				end
			else
				if(bFound) then
					break
				end
			end
		end
		--znftodo不知道为什么出错
		if self.checkIsShowArrow_ then
			self:checkIsShowArrow_()
		end
	else
		self.m_bIsLoadingData = true
		local nFound = 0
		-- 分帧加载内容
		gRefreshViewsAsync(self, nEndIndex-nStartIndex+1, function ( _bEnd, _bIndex )
			if(not _bEnd) then
				local curIndex = _bIndex
				-- 换算成实际的下标
				_bIndex = nStartIndex + _bIndex - 1
				-- 获取该item在列表中的位置
				if(self:isItemInViewRect(_bIndex)) then
					posX, posY = self:getPositionByIndex(_bIndex)
					-- 获取一项新的内容
					local oldView = self.items_[curIndex]
					item, itemW, itemH = self:loadOneItem_(oldView, 
						cc.p(posX, posY), _bIndex)
					-- 执行动画
					if(self.m_bItemAction and (not oldView or _bNew)) then
						gDoListItemAction(item, MScrollLayer.DIRECTION_VERTICAL == self.direction, 1)
					end
					if(nFound == 0) then
						nFound = 1
					end
				else
					if(nFound == 1) then
						nFound = -1
					end
				end
				if(nFound == -1 or _bIndex >= self:getItemCount()) then
					_bEnd = true
				end
			end
			if(_bEnd) then
				if(self.m_callbackEnd) then
					self.m_callbackEnd(self)
				end
				if(self.m_bItemAction) then
					self:performWithDelay(function (  )
						self.m_bIsLoadingData = false
                        self:increaseOrReduceItem_()
					end, 0.03)
				else
					self.m_bIsLoadingData = false
                    self:increaseOrReduceItem_()
				end
				-- 结束自己的分帧
				gRemoveNodeFromPerFrameUpdate(self)
				--
				--znftodo不知道为什么出错
				if self.checkIsShowArrow_ then
					self:checkIsShowArrow_()
				end
			end
		end, self.m_fAsyncTime or 1)
	end

	return self
end

-- start --

--------------------------------
-- 设置delegate函数
-- @function [parent=#MListView] setDelegate
-- @return MListView#MListView 

-- end --

function MListView:setDelegate(delegate)
	self.delegate_[MListView.DELEGATE] = delegate
end

--[[--

调整item中content的布局,
私有函数

]]
function MListView:setPositionByAlignment_(content, w, h, margin)
	local size = content:getContentSize()
	content:ignoreAnchorPointForPosition(false)
	if 0 == margin.left and 0 == margin.right and 0 == margin.top and 0 == margin.bottom then
		if MScrollLayer.DIRECTION_VERTICAL == self.direction then
			if MListView.ALIGNMENT_LEFT == self.alignment then
				content:setPosition(size.width/2, h/2)
			elseif MListView.ALIGNMENT_RIGHT == self.alignment then
				content:setPosition(w - size.width/2, h/2)
			else
				content:setPosition(w/2, h/2)
			end
		else
			if MListView.ALIGNMENT_TOP == self.alignment then
				content:setPosition(w/2, h - size.height/2)
			elseif MListView.ALIGNMENT_RIGHT == self.alignment then
				content:setPosition(w/2, size.height/2)
			else
				content:setPosition(w/2, h/2)
			end
		end
	else
		local posX, posY
		if 0 ~= margin.right then
			posX = w - margin.right - size.width/2
		else
			posX = size.width/2 + margin.left
		end
		if 0 ~= margin.top then
			posY = h - margin.top - size.height/2
		else
			posY = size.height/2 + margin.bottom
		end
		content:setPosition(posX, posY)
	end
end

--[[--

加载一个数据项
私有函数

@param table originPoint 数据项要加载的起始位置
@param number idx 要加载数据的序号
@param boolean bBefore 是否加在已有项的前面

@return MListViewItem item

]]
function MListView:loadOneItem_(_item, originPoint, idx, bBefore)
	-- print("MListView loadOneItem idx:" .. idx)
	-- dump(originPoint, "originPoint:")
	-- 检测有没有头部
	self:checkHeadView(idx)

	local itemW, itemH = 0, 0
	local containerW, containerH = 0, 0
	local posX, posY = originPoint.x, originPoint.y
	local content
	local item = _item or self:getFreeItem()
	local pItemContent = nil
	if(not item) then
	    item = self:newItem()
	end
	pItemContent = item:getContent()

	if pItemContent == nil then
		pItemContent = self.delegate_[MListView.DELEGATE](pItemContent, MListView.CELL_TAG, idx)
		item:addContent(pItemContent)
	else
		self.delegate_[MListView.DELEGATE](pItemContent, MListView.CELL_TAG, idx)
	end
	item.idx_ = idx
	itemW, itemH = item:getItemSize()
	-- 初始化宽高
	if(self.m_itemW <= 0) then
		self.m_itemW = itemW
		self.m_itemH = itemH
	end

	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		-- 重置展示的位置
		posX , posY = self:resetSingleItemPos(item, idx, posX, posY, bBefore)
		containerH = containerH + itemH
	else
		-- 重置展示的位置
		posX , posY = self:resetSingleItemPos(item, idx, posX, posY, bBefore)
		containerW = containerW + itemW
	end

	if(not _item) then
		if bBefore then
			table.insert(self.items_, 1, item)
		else
			table.insert(self.items_, item)
		end
		self.container:addView(item)
	end
	if item.bFromFreeQueue_ then
		item.bFromFreeQueue_ = nil
		item:release()
	end
	-- 检测有没有尾部
	self:checkFooterView(idx, posX , posY)

	return item, itemW, itemH
end
-- 重置单项item的位置
-- _item（Mview）： 当前的item
-- _idx（number）：当前item所处在container中的下标
-- _posX（number）： 计算出来上一项的位置x（上一项的目的是为了沿用之前的逻辑）
-- _posY（number）：计算出来上一项的位置y（上一项的目的是为了沿用之前的逻辑）
-- _bBefore（boolean）：是否插入在前面
function MListView:resetSingleItemPos( _item, _idx, _posX, _posY, _bBefore )
	if(not _item) then
		return
	end
	local itemW = _item:getWidth() or 0
	local itemH = _item:getHeight() or 0
	local originPoint = cc.p(_posX, _posY)
	local content = nil
	if MScrollLayer.DIRECTION_VERTICAL == self.direction then
		if _bBefore then
			_posY = _posY
		else
			_posY = _posY - itemH
		end
		content = _item:getContent()
		content:setAnchorPoint(0.5, 0.5)
		self:setPositionByAlignment_(content, itemW, itemH, _item:getMargin())
		_item:setPosition(0, _posY)
	else
		if _bBefore then
			_posX = _posX - itemW
		end

		content = _item:getContent()
		content:setAnchorPoint(0.5, 0.5)
		self:setPositionByAlignment_(content, itemW, itemH, _item:getMargin())
		_item:setPosition(_posX, 0)
	end
	return _posX, _posY
end

--[[--

移除一个数据项
私有函数
_bListIdex(boolean): 是否为self.items_中的下标，true为是，false为container中的位置


]]
function MListView:unloadOneItem_(idx, _bListIdex)
	-- print("MListView unloadOneItem idx:" .. idx)
	if(_bListIdex == nil) then
		_bListIdex = false
	end

	local unloadIdx = nil
	local item = nil
	if(not _bListIdex) then
		item = self.items_[1]

		if nil == item then
			return
		end
		if item.idx_ > idx then
			return
		end
		unloadIdx = idx - item.idx_ + 1
	else
		unloadIdx = idx
	end
	item = self.items_[unloadIdx]
	if nil == item then
		return
	end
	-- 如果是self.items_中的下标，获取在container中的下标
	if(_bListIdex) then
		idx = item.idx_
	end
	table.remove(self.items_, unloadIdx)
	self:addFreeItem_(item)
	-- item:removeFromParentAndCleanup(false)
	self.container:removeChild(item, false)

	self.delegate_[MListView.DELEGATE](self, MListView.UNLOAD_CELL_TAG, idx)
end

--[[--

加一个空项到空闲列表中
私有函数

]]
function MListView:addFreeItem_(item)
	item:retain()
	table.insert(self.itemsFree_, item)
end

--[[--

释放所有的空闲列表项
私有函数

]]
function MListView:releaseAllFreeItems_()
    if #self.itemsFree_ == 0 then
        return
    end

	for i,v in ipairs(self.itemsFree_) do
--		-- 执行对缓存的释放行为
--		if(v.releaseToPool) then
--			v:releaseToPool()
--		end
		v:release()
	end
	self.itemsFree_ = {}
end

function MListView:createCloneInstance_()
    return MListView.new(unpack(self.args_))
end

function MListView:copyClonedWidgetChildren_(node)
    local children = node.items_
    if not children or 0 == #children then
        return
    end

    for i, child in ipairs(children) do
        local cloneItem = self:newItem()
        local content = child:getContent()
        local cloneContent = content:clone()
        cloneItem:addContent(cloneContent)
        cloneItem:copySpecialProperties_(child)
        self:addItem(cloneItem)
    end
end

-- 分帧加载数据
-- _count（int）：列表的总个输
-- _index（int）：当前要展示第几项
-- _everycallback（function）：每一帧的回调
-- _endcallback（function）：加载完成的回调
-- _fTime(number): 分帧的时间间隔
function MListView:loadDataAsync( _count, _index, _everycallback, _endcallback, _fTime )
	self:setAsyncDisTime(_fTime)
	self:setItemCount(_count)
	self:setItemCallback(_everycallback)
	self:setEndCallback(_endcallback)
	-- 执行加载
	self:reload(true)
end
-- 每帧重新刷新实际的界面缩放大小，与父控件有关
function MListView:resetContainerScale()
	self.m_tmpScaleX = 1
	self.m_tmpScaleY = 1
	local pPar = self
	while(pPar ~= nil) do
		self.m_tmpScaleX = self.m_tmpScaleX * pPar:getScaleX()
		self.m_tmpScaleY = self.m_tmpScaleY * pPar:getScaleY()
		pPar = pPar:getParent()
	end
end
-- 设置item是否需要执行动画
-- _b（bool）：是否需要执行动画
function MListView:setItemNeedAction( _b )
	self.m_bItemAction = _b
end
-- 获取列表可视化的下标
-- return(int, int): 起始下标和结束下标
function MListView:getVisibleIndexes(  )
	local nTotalCount = self:getItemCount()
	local nStart, nEnd = nil, nil
	if(nTotalCount and nTotalCount > 0) then
		for i=1, nTotalCount, 1 do
			local bVis = self:isItemInViewRect(i)
			if(bVis) then
				if(not nStart) then
					nStart = i
				end
				nEnd = i
			else
				-- 如果已经找到全部了，直接结束
				if(nEnd) then
					break
				end
			end
		end
	end
	return nStart, nEnd
end
-- 检测滑动的最大范围
-- _fx(float): 老的x值
-- _fy(number):老的y值
-- _fScale(number): 父控件的高度比，默认是1/4
function MListView:__checkMaxState( _fx, _fy, _fScale )
	if(self.m_itemW > 0) then
		local nTotalCount = self:getItemCount()
		if(nTotalCount and nTotalCount > 0) then
			local viewRect = self:getViewRect()
			local fScale = _fScale or 1/4
			if MScrollLayer.DIRECTION_VERTICAL == self.direction then
				local allHeight = self.m_itemH * nTotalCount
				if self.pHeaderView then
					allHeight = allHeight + self.pHeaderView:getHeight()
				end
				if self.pFooterView then
					allHeight = allHeight + self.pFooterView:getHeight()
				end
				if(allHeight < viewRect.height) then
					allHeight = viewRect.height
				end
				local minY = viewRect.height - viewRect.height*fScale
				local maxY = allHeight + viewRect.height*fScale
				if(_fy < minY) then
					_fy = minY
				elseif(_fy > maxY) then
					_fy = maxY
				end
			elseif(MScrollLayer.DIRECTION_HORIZONTAL == self.direction) then
				local allWidth = self.m_itemW * nTotalCount
				if self.pHeaderView then
					allWidth = allWidth + self.pHeaderView:getWidth()
				end
				if self.pFooterView then
					allWidth = allWidth + self.pFooterView:getWidth()
				end
				if(allWidth < viewRect.width) then
					allWidth = viewRect.width
				end
				local minX = - allWidth + viewRect.width - viewRect.width*fScale
				local maxX = viewRect.width*fScale
				if(_fx < minX) then
					_fx = minX
				elseif(_fx > maxX) then
					_fx = maxX
				end
			end
		end
	end
    if _fy == 847.5 then
        local x = 1
        local y = 2
    end
	return _fx, _fy
end
-- 检查是否获取了第一项，如果获取好了，保存到空闲列表中
function MListView:checkFirstItem(  )
	-- 已经初始化了，或个数为0，或没有设置回调函数，都返回
	if(self.m_itemW > 0 or (self:getItemCount() <= 0) or (not self.m_callbackItem)) then
		return
	end
	-- 新建一个item
	local firstItem = self:newItem()
	local pItemContent = self.m_callbackItem(1, nil)
	firstItem:addContent(pItemContent)
	-- 记录item的大小
	self.m_itemW, self.m_itemH = firstItem:getItemSize()
	-- 放置到空闲列表中
	self:addFreeItem_(firstItem)
end

-- 上下箭头检测
function MListView:checkIsShowArrow_( event )
	if not self.bIsOpenCheckArrow then
		return
	end

	local pScrollView = self:getScrollNode()
	if pScrollView then
		if self.direction == MUI.MScrollView.DIRECTION_HORIZONTAL then
			local pScrollSize = pScrollView:getContentSize()
	    	local nMaxLength = self.m_nItemCount * self.m_itemW + self.headerViewW + self.footerViewW
	    	local nOriginX, nOriginY = pScrollView:getPosition()
	    	local pSize = self:getContentSize()
	    	nOriginY = nOriginY - nMaxLength
	        
	        if (nOriginX + nMaxLength) > pSize.width then
	            self.pRightArrow:setVisible(true)
	        else
	            self.pRightArrow:setVisible(false)
	        end

	        if nOriginX < 0 then
	            self.pLeftArrow:setVisible(true)
	        else
	            self.pLeftArrow:setVisible(false)
	        end
		elseif self.direction == MUI.MScrollView.DIRECTION_VERTICAL then
	    	local pScrollSize = pScrollView:getContentSize()
	    	local nMaxLength = self.m_nItemCount * self.m_itemH + self.headerViewH + self.footerViewH
	    	local nOriginX, nOriginY = pScrollView:getPosition()
	    	local pSize = self:getContentSize()
	    	nOriginY = nOriginY - nMaxLength
	        
	        if (nOriginY + nMaxLength) > pSize.height then
	            self.pUpArrow:setVisible(true)
	        else
	            self.pUpArrow:setVisible(false)
	        end

	        if nOriginY < 0 then
	            self.pDownArrow:setVisible(true)
	        else
	            self.pDownArrow:setVisible(false)
	        end
		end
    end
end

return MListView
