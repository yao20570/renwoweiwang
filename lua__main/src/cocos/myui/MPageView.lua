----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-11-10 17:25:30 
-- Description: 分页列表
-----------------------------------------------------

--------------------------------
-- @module MPageView

--[[--

quick page控件

]]
local MLayer = import(".MLayer")
local MFillLayer = import(".MFillLayer")

local MPageViewItem = import(".MPageViewItem")

local MPageView = myclass("MPageView", MLayer)

-- start --

--------------------------------
-- UIPageView构建函数
-- @function [parent=#MPageView] new
-- @param table params 参数表

--[[--

UIPageView构建函数

可用参数有：

-   column 每一页的列数，默认为1
-   row 每一页的行数，默认为1
-   columnSpace 列之间的间隙，默认为0
-   rowSpace 行之间的间隙，默认为0
-   viewRect 页面控件的显示区域
-   padding 值为一个表，页面控件四周的间隙
    -   left 左边间隙
    -   right 右边间隙
    -   top 上边间隙
    -   bottom 下边间隙
-   bCirc 页面是否循环,默认为false

]]
-- end --

function MPageView:ctor(params)
	MPageView.super.ctor(self)
	self:__mpageviewInit()

    self:setSpecialDestroyCallback(handler(self, self.onSpecialDestroy))

	self:setViewRect(params.viewRect or cc.rect(0, 0, display.width, display.height))
	self.column_ = params.column or 1
	self.row_ = params.row or 1
	self.columnSpace_ = params.columnSpace or 0
	self.rowSpace_ = params.rowSpace or 0
	self.padding_ = params.padding or {left = 0, right = 0, top = 0, bottom = 0}
	self.bCirc = params.bCirc or false
	self.defaultIdx_ = params.defaultIdx or 1

	-- 设置自定义的触摸回调
	-- self:__setChildOnTouchEvent(handler(self, self.onTouchEvent_))
	self.args_ = {params}
end
-- 初始化方法
function MPageView:__mpageviewInit(  )
	self:__setViewType(MUI.VIEW_TYPE.pageview)
	self:setClipping(true)
	self.items_ = {}
	self.m_bIsLoadingData = false -- 是否处于分帧加载数据中
	self.curPageIdx_ = 1 -- 当前展示的页数
	self.m_nScrollSensitivity = 5 -- 滑动的占比灵敏值
	self.m_nAutoScrollTime = 0.2 -- 自动滑动的时间
end

function MPageView:onSpecialDestroy()
	-- 清除掉定时器
	if(self.m_updateGlobalInit) then
		MUI.scheduler.unscheduleGlobal(self.m_updateGlobalInit)
	end
end

-- start --

--------------------------------
-- 创建一个新的页面控件项
-- @function [parent=#MPageView] newItem
-- @return MPageViewItem#MPageViewItem 

-- end --

function MPageView:newItem()
	local item = MPageViewItem.new()
	local itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right
				- self.columnSpace_*(self.column_ - 1)) / self.column_
	local itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom
				- self.rowSpace_*(self.row_ - 1)) / self.row_
	item:setLayoutSize(itemW, itemH)

	return item
end

--子页填充
function MPageView:newFillItem()
	local item = MUI.MFillLayer.new()
	local itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right
				- self.columnSpace_*(self.column_ - 1)) / self.column_
	local itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom
				- self.rowSpace_*(self.row_ - 1)) / self.row_
	item:setLayoutSize(itemW, itemH)

	return item
end

-- start --

--------------------------------
-- 添加一项到页面控件中
-- @function [parent=#MPageView] addItem
-- @param node item 页面控件项
-- @return MPageView#MPageView 

-- end --

function MPageView:addItem(item)
	table.insert(self.items_, item)

	return self
end

-- start --

--------------------------------
-- 移除一项
-- @function [parent=#MPageView] removeItem
-- @param number idx 要移除项的序号
-- @return MPageView#MPageView 

-- end --

function MPageView:removeItem(item)
	local itemIdx
	for i,v in ipairs(self.items_) do
		if v == item then
			itemIdx = i
		end
	end

	if not itemIdx then
		print("ERROR! item isn't exist")
		return self
	end

	if itemIdx then
		table.remove(self.items_, itemIdx)
	end

	self:reload(self.curPageIdx_)

	return self
end

-- start --

--------------------------------
-- 移除所有页面
-- @function [parent=#MPageView] removeAllItems
-- @return MPageView#MPageView 

-- end --

function MPageView:removeAllItems()
	self.items_ = {}

	self:reload(self.curPageIdx_)

	return self
end

-- start --

--------------------------------
-- 获取item列表
-- @function [parent=#MPageView] getItems
-- @return items_ 

-- end --

function MPageView:getItems()
	return self.items_
end


-- start --

--------------------------------
-- 注册一个监听函数
-- @function [parent=#MPageView] onTouch
-- @param function listener 监听函数
-- @return MPageView#MPageView 

-- end --

function MPageView:onTouch(listener)
	self.touchListener = listener

	return self
end

-- start --

--------------------------------
-- 加载数据，各种参数
-- @function [parent=#MPageView] reload
-- @param number page index加载完成后,首先要显示的页面序号,为空从第一页开始显示
-- @return MPageView#MPageView 

-- end --

function MPageView:reload(idx)
	local page
	local pageCount

	-- retain all items
	if(not self.m_bIsLoadingData) then
		self.pages_ = {}
		for i,v in ipairs(self.items_) do
			v:retain()
		end
		self:removeAllChildren()
		pageCount = self:getPageCount()
		if pageCount < 1 then
			return self
		end
		if pageCount > 0 then
			for i = 1, pageCount do
				page = self:createPage_(i)
				page:setVisible(false)
				table.insert(self.pages_, page)
				page:setPosition(0, 0)
				self:addView(page)
			end
		end
		-- release all items
		
		for i,v in ipairs(self.items_) do
			v:release()
		end
	else
		self.pages_ = self.pages_ or {}
		pageCount = self:getPageCount()
		if pageCount < 1 then
			self:removeAllChildren()
			return self
		end
		-- 只增加额外的部分
		if(pageCount > #self.pages_) then
			for i=#self.pages_+1, pageCount do
				page = self:createPage_(i)
				page:setVisible(false)
				table.insert(self.pages_, page)
				page:setPosition(0, 0)
				self:addView(page)
			end
		end
	end

	if idx and idx < 1 then
		idx = 1
	elseif idx and idx > pageCount then
		idx = 1
	end
	self.curPageIdx_ = idx or self.curPageIdx_
	self.pages_[self.curPageIdx_]:setVisible(true)
	self.pages_[self.curPageIdx_]:setPosition(0, 0)

	return self
end

-- start --

--------------------------------
-- 跳转到特定的页面
-- @function [parent=#MPageView] gotoPage
-- @param integer pageIdx 要跳转的页面的位置
-- @param boolean bSmooth 是否需要跳转动画
-- @param bLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右
-- @return MPageView#MPageView 

-- end --

function MPageView:gotoPage(pageIdx, bSmooth, bLeftToRight)
	if pageIdx < 1 or pageIdx > self:getPageCount() then
		return self
	end
	if pageIdx == self.curPageIdx_ and bSmooth then
		return self
	end

	if bSmooth then
		self:resetPagePos(pageIdx, bLeftToRight)
		self:scrollPagePos(pageIdx, bLeftToRight)
	else
		self.pages_[self.curPageIdx_]:setVisible(false)
		self.pages_[pageIdx]:setVisible(true)
		self.pages_[pageIdx]:setPosition(
			0, 0)
		self.curPageIdx_ = pageIdx

		-- self.notifyListener_{name = "clicked",
		-- 		item = self.items_[clickIdx],
		-- 		itemIdx = clickIdx,
		-- 		pageIdx = self.curPageIdx_}
		self:notifyListener_{name = "pageChange"}
	end

	return self
end

-- start --

--------------------------------
-- 得到页面的总数
-- @function [parent=#MPageView] getPageCount
-- @return number#number 

-- end --

function MPageView:getPageCount()
	return math.ceil(table.nums(self.items_)/(self.column_*self.row_))
end

-- start --

--------------------------------
-- 得到当前页面的位置
-- @function [parent=#MPageView] getCurPageIdx
-- @return number#number 

-- end --

function MPageView:getCurPageIdx()
	return self.curPageIdx_
end

-- start --

--------------------------------
-- 设置页面控件是否为循环
-- @function [parent=#MPageView] setCirculatory
-- @param boolean bCirc 是否循环
-- @return MPageView#MPageView 

-- end --

function MPageView:setCirculatory(bCirc)
	self.bCirc = bCirc

	return self
end

-- private

function MPageView:createPage_(pageNo)
	local page = MUI.MLayer.new()
	local item
	local beginIdx = self.row_*self.column_*(pageNo-1) + 1
	local itemW, itemH

	itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right
				- self.columnSpace_*(self.column_ - 1)) / self.column_
	itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom
				- self.rowSpace_*(self.row_ - 1)) / self.row_
	local bBreak = false
	for row=1,self.row_ do
		for column=1,self.column_ do
			item = self.items_[beginIdx]
			beginIdx = beginIdx + 1
			if not item then
				bBreak = true
				break
			end
			page:addView(item)
		end
		if bBreak then
			break
		end
	end

	page:setTag(1500 + pageNo)

	return page
end

function MPageView:isTouchInViewRect_(event, rect)
	rect = rect or self.viewRect_
	local viewRect = self:convertToWorldSpace(cc.p(rect.x, rect.y))
	viewRect.width = rect.width
	viewRect.height = rect.height

	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function MPageView:__onTouchEvent(event)
    local nHandleType = nil
    if "began" == event.name then
        if not self:isTouchInViewRect_(event) then
            printInfo("MPageView - touch didn't in viewRect")
            return false, nHandleType
        end
        self:stopAllTransition()
        self.bDrag_ = false
        self.tTouchBeganEvent = event 
        self.bSwallowed = nil

    elseif "moved" == event.name then
        nHandleType = MUI.TOUCH_HANDLE_TYPE.MOVED
        local sy = math.abs(event.y - self.tTouchBeganEvent.y)
        local sx = math.abs(event.x - self.tTouchBeganEvent.x)
        if (sy > 15 or sx > 15) then
            if self.bSwallowed == nil then
                self.bSwallowed = sy < sx
            end

            if self.bSwallowed then
                self.bDrag_ = true
                self.speed = event.x - event.prevX
                self:scroll(self.speed)
                return false, nHandleType
            else
                return true, nHandleType
            end
        else
            return false, nHandleType
        end

    elseif "ended" == event.name then
        if self.bDrag_ then
            self:scrollAuto()
        else
            self:resetPages_()
            self:onClick_(event)
        end

    end

    return true, nHandleType
end

--[[--

重置页面,检查当前页面在不在初始位置
用于在动画被stopAllTransition的情况

]]
function MPageView:resetPages_()
	local x,y = self.pages_[self.curPageIdx_]:getPosition()

	if x == 0 then
		return
	end
	print("MPageView - resetPages_")
	-- self.pages_[self.curPageIdx_]:getPosition(self.viewRect_.x, y)
	self:disablePage()
	self:gotoPage(self.curPageIdx_)
end

--[[--

重置相关页面的位置

@param integer pos 要移动到的位置
@param bLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右

]]
function MPageView:resetPagePos(pos, bLeftToRight)
	local pageIdx = self.curPageIdx_
	local page
	local pageWidth = self.viewRect_.width
	local dis
	local count = #self.pages_

	dis = pos - pageIdx
	if self.bCirc then
		local disL,disR
		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if nil == bLeftToRight then
			dis = ((math.abs(disL) > math.abs(disR)) and disR) or disL
		elseif bLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self.pages_[pageIdx]:getPosition()

	for i=1,disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
			x = x + pageWidth
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
			x = x - pageWidth
		end
		pageIdx = pageIdx % count
		if 0 == pageIdx then
			pageIdx = count
		end
		page = self.pages_[pageIdx]
		if page then
			page:setVisible(true)
			page:setPosition(x, 0)
		end
	end
end

--[[--

移动到相对于当前页的某个位置

@param integer pos 要移动到的位置
@param bLeftToRight 移动的方向,在可循环下有效, nil:自动调整方向,false:从右向左,true:从左向右

]]
function MPageView:scrollPagePos(pos, bLeftToRight)
	local pageIdx = self.curPageIdx_
	local page
	local pageWidth = self.viewRect_.width
	local dis
	local count = #self.pages_

	dis = pos - pageIdx
	if self.bCirc then
		local disL,disR
		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if nil == bLeftToRight then
			dis = ((math.abs(disL) > math.abs(disR)) and disR) or disL
		elseif bLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = 0
	local movedis = dis*pageWidth

	for i=1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
		end
		pageIdx = pageIdx % count
		if 0 == pageIdx then
			pageIdx = count
		end
		page = self.pages_[pageIdx]
		if page then
			page:setVisible(true)
			transition.moveBy(page,
					{x = -movedis, y = 0, time = 0.3})
		end
	end
	transition.moveBy(self.pages_[self.curPageIdx_],
					{x = -movedis, y = 0, time = 0.3,
					onComplete = function()
						local pageIdx = (self.curPageIdx_ + dis + count)%count
						if 0 == pageIdx then
							pageIdx = count
						end
						self.curPageIdx_ = pageIdx
						self:disablePage()
						self:notifyListener_{name = "pageChange"}
					end})
end

function MPageView:stopAllTransition()
	for i,v in ipairs(self.pages_) do
		transition.stopTarget(v)
	end
end

function MPageView:disablePage()
	local pageIdx = self.curPageIdx_
	local page

	for i,v in ipairs(self.pages_) do
		if i ~= self.curPageIdx_ then
			v:setVisible(false)
		end
	end
end

function MPageView:scroll(dis)
	local threePages = {}
	local count
	if self.pages_ then
		count = #self.pages_
	else
		count = 0
	end

	local page
	if 0 == count then
		return
	elseif 1 == count then
		table.insert(threePages, false)
		table.insert(threePages, self.pages_[self.curPageIdx_])
	elseif 2 == count then
		local posX, posY = self.pages_[self.curPageIdx_]:getPosition()
		if posX > 0 then
			page = self:getNextPage(false)
			if not page then
				page = false
			end
			table.insert(threePages, page)
			table.insert(threePages, self.pages_[self.curPageIdx_])
		else
			table.insert(threePages, false)
			table.insert(threePages, self.pages_[self.curPageIdx_])
			table.insert(threePages, self:getNextPage(true))
		end
	else
		page = self:getNextPage(false)
		if not page then
			page = false
		end
		table.insert(threePages, page)
		table.insert(threePages, self.pages_[self.curPageIdx_])
		table.insert(threePages, self:getNextPage(true))
	end

	self:scrollLCRPages(threePages, dis)
end

function MPageView:scrollLCRPages(threePages, dis)
	local posX, posY
	local pageL = threePages[1]
	local page = threePages[2]
	local pageR = threePages[3]

	-- current
	posX, posY = page:getPosition()
	posX = posX + dis
	page:setPosition(posX, posY)

	-- left
	posX = posX - self.viewRect_.width
	if pageL and "boolean" ~= type(pageL) then
		pageL:setPosition(posX, posY)
		if not pageL:isVisible() then
			pageL:setVisible(true)
		end
	end

	posX = posX + self.viewRect_.width * 2
	if pageR then
		pageR:setPosition(posX, posY)
		if not pageR:isVisible() then
			pageR:setVisible(true)
		end
	end
end

function MPageView:scrollAuto()
	if not self.curPageIdx_ then
		print("MPageView:scrollAuto self.curPageIdx_ = nil")
		return
	end
	if not self.pages_[self.curPageIdx_] then
		print("MPageView:scrollAuto 找不到下标 "..tostring(self.curPageIdx_))
		return
	end
	local page = self.pages_[self.curPageIdx_]
	local pageL = self:getNextPage(false) -- self.pages_[self.curPageIdx_ - 1]
	local pageR = self:getNextPage(true) -- self.pages_[self.curPageIdx_ + 1]
	local bChange = false
	local posX, posY = page:getPosition()
	local dis = posX - 0

	local pageRX = 0 + self.viewRect_.width
	local pageLX = 0 - self.viewRect_.width

	local count = #self.pages_
	if 0 == count then
		return
	elseif 1 == count then
		pageL = nil
		pageR = nil
	end
	if (dis > self.viewRect_.width/self.m_nScrollSensitivity or self.speed > 10)
		and (self.curPageIdx_ > 1 or self.bCirc)
		and count > 1 then
		bChange = true
	elseif (-dis > self.viewRect_.width/self.m_nScrollSensitivity or -self.speed > 10)
		and (self.curPageIdx_ < self:getPageCount() or self.bCirc)
		and count > 1 then
		bChange = true
	end

	if dis > 0 then
		if bChange then
			transition.moveTo(page,
				{x = pageRX, y = posY, time = self.m_nAutoScrollTime,
				onComplete = function()
					self.curPageIdx_ = self:getNextPageIndex(false)
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			transition.moveTo(pageL,
				{x = 0, y = posY, time = self.m_nAutoScrollTime})
		else
			transition.moveTo(page,
				{x = 0, y = posY, time = self.m_nAutoScrollTime,
				onComplete = function()
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageL then
				transition.moveTo(pageL,
					{x = pageLX, y = posY, time = self.m_nAutoScrollTime})
			end
		end
	else
		if bChange then
			transition.moveTo(page,
				{x = pageLX, y = posY, time = self.m_nAutoScrollTime,
				onComplete = function()
					self.curPageIdx_ = self:getNextPageIndex(true)
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			transition.moveTo(pageR,
				{x = 0, y = posY, time = self.m_nAutoScrollTime})
		else
			transition.moveTo(page,
				{x = 0, y = posY, time = self.m_nAutoScrollTime,
				onComplete = function()
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageR then
				transition.moveTo(pageR,
					{x = pageRX, y = posY, time = self.m_nAutoScrollTime})
			end
		end
	end
end

function MPageView:onClick_(event)
	local itemW, itemH

	itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right
				- self.columnSpace_*(self.column_ - 1)) / self.column_
	itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom
				- self.rowSpace_*(self.row_ - 1)) / self.row_

	local itemRect = {width = itemW, height = itemH}

	local clickIdx
	for row = 1, self.row_ do
		itemRect.y = 0 + self.viewRect_.height - self.padding_.top - row*itemH - (row - 1)*self.rowSpace_
		for column = 1, self.column_ do
			itemRect.x = 0 + self.padding_.left + (column - 1)*(itemW + self.columnSpace_)

			if self:isTouchInViewRect_(event, itemRect) then
				clickIdx = (row - 1)*self.column_ + column
				break
			end
		end
		if clickIdx then
			break
		end
	end

	if not clickIdx then
		-- not found, maybe touch in space
		return
	end

	clickIdx = clickIdx + (self.column_ * self.row_) * (self.curPageIdx_ - 1)

	self:notifyListener_{name = "clicked",
		item = self.items_[clickIdx],
		itemIdx = clickIdx}
end

function MPageView:notifyListener_(event)
	if not self.touchListener then
		return
	end

	event.pageView = self
	event.pageIdx = self.curPageIdx_
	self.touchListener(event)
end

function MPageView:getNextPage(bRight)
	if not self.pages_ then
		return
	end

	if self.pages_ and #self.pages_ < 2 then
		return
	end

	local pos = self:getNextPageIndex(bRight)

	return self.pages_[pos]
end

function MPageView:getNextPageIndex(bRight)
	local count = #self.pages_
	local pos
	if bRight then
		pos = self.curPageIdx_ + 1
	else
		pos = self.curPageIdx_ - 1
	end

	if self.bCirc then
		pos = pos + count
		pos = pos%count
		if 0 == pos then
			pos = count
		end
	end

	return pos
end
-- 设置显示区域
function MPageView:setViewRect(rect)
	-- 这里不能直接赋值给self.viewRect_,要使得起点是0，0开始
	-- self.viewRect_ = rect
	self.viewRect_ = cc.rect(0, 0, rect.width, rect.height)
	self:setPosition(rect.x, rect.y)
	self:setLayoutSize(rect.width, rect.height)

	return self
end

function MPageView:createCloneInstance_()
    return MPageView.new(unpack(self.args_))
end

function MPageView:copyClonedWidgetChildren_(node)
    local children = node.items_
    if not children or 0 == #children then
        return
    end

    for i, child in ipairs(children) do
        local cloneChild = child:clone()
        if cloneChild then
            self:addItem(cloneChild)
        end
    end
end

function MPageView:copySpecialProperties_(node)
    self.bCirc = node.bCirc
end
-- 分帧加载数据
-- _count（int）：分页的总个数
-- _index（int）：当前要展示第几项
-- _everycallback（function）：每一帧的回调
-- _endcallback（function）：加载完成的回调
function MPageView:loadDataAsync( _count, _index, _everycallback, _endcallback )
	if(self.m_bIsLoadingData) then
		printMUI("不能重复执行异步行为")
		return
	end
	if(not _everycallback) then
		printMUI("请提供每帧的回调行为")
		return
	end
	self.m_bIsLoadingData = true
	self.m_loadingCount = _count or 1
	self.m_showingIndex = _index or 1
	self.m_loadingIndex = 0
	self._everycallback = _everycallback
	self._endcallback = _endcallback
	self.m_updateGlobalInit = MUI.scheduler.scheduleUpdateGlobal(function (  )
		self.m_loadingIndex = self.m_loadingIndex + 1
		if(self._everycallback) then
			local pItem = self._everycallback(self, self.m_loadingIndex)
			self:addItem(pItem)
			local idx = nil
			if(self.m_showingIndex == self.m_loadingIndex) then
				idx = self.m_showingIndex
			end
			self:reload(idx)
		end
		if(self.m_loadingIndex >= self.m_loadingCount) then
			MUI.scheduler.unscheduleGlobal(self.m_updateGlobalInit)
			self.m_updateGlobalInit = nil			
			if self.defaultIdx_ <= 0 then
				self.defaultIdx_ = 1
			elseif self.defaultIdx_ > self.m_loadingCount then
				self.defaultIdx_ = self.m_loadingCount
			end 
			self:gotoPage(self.defaultIdx_)
            if(self._endcallback) then
				self._endcallback(self)
			end
			self.m_bIsLoadingData = false
			self.m_loadingCount = nil
			self._everycallback = nil
			self._endcallback = nil
			self.m_showingIndex = nil
			self.m_loadingIndex = nil
		end
	end)
end
-- 设置滑动的灵敏度
-- _nValue(int): 灵敏值，指的是暂用单个page的width的积几分之一
function MPageView:setScrollSensitivity( _nValue )
	self.m_nScrollSensitivity = _nValue
	-- 最小比例是5分之1，最大比例是2分之1
	if(self.m_nScrollSensitivity > 5) then
		self.m_nScrollSensitivity = 5
	elseif(self.m_nScrollSensitivity < 2) then
		self.m_nScrollSensitivity = 2
	end
end
-- 获取灵敏值
function MPageView:getScrollSensitivity(  )
	return self.m_nScrollSensitivity
end


return MPageView
