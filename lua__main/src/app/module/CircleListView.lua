----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-09-04 19:42:50
-- Description: 环形拖动层
-----------------------------------------------------
local shadowZorder = 999 --遮罩层
local fOtherScale = 0.84
local fCenterScale = 1
local fActionT = 0.4
local nSubNum = 3

local CircleListView = class("CircleListView", function (size)
	local pView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, size.width, size.height),
        touchOnContent = false,
        direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
        bothSize=cc.size(size.width, size.height)
        })
	return pView
end)


--pSize 显示大小
--pSubSize 子控件大小
--nMargin 子控件间隔
function CircleListView:ctor( pSize, pSubSize, nMargin )
	-- 添加触摸事件
	self:setBounceable(false)
	self:onScroll(handler(self, self.onScrollViewTouch))

	--创建滚动层
	self.pMapViewGroup = MUI.MLayer.new()
	self.pMapViewGroup:setLayoutSize(pSize.width, pSize.height)
	self:addView(self.pMapViewGroup)

	--容器数
	self.pLaySubList = {}
	local nCenterPos = cc.p(pSize.width/2, pSize.height/2)
	self.pSubPosList = {
		nCenterPos,
		cc.p(nCenterPos.x + nMargin, nCenterPos.y), --2是右边
		cc.p(nCenterPos.x - nMargin, nCenterPos.y), --3是左边
	}
	for i=1,nSubNum do
		local pLaySub = MUI.MLayer.new()
		pLaySub:setLayoutSize(pSubSize.width, pSubSize.height)
		pLaySub:setAnchorPoint(0.5, 0.5)
		pLaySub:ignoreAnchorPointForPosition(false)
		self.pMapViewGroup:addView(pLaySub)
		local pLayerColor = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, pSubSize.width, pSubSize.height)
		pLaySub:addView(pLayerColor, shadowZorder)
		pLaySub.pLayShadow = pLayerColor
		table.insert(self.pLaySubList, pLaySub)
	end

	--移动数量
	self.nMoving = 0
end

-- scrollView的触摸事件回调
function CircleListView:onScrollViewTouch(event)
	--是否移动中
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
		self.pPrevX = x
	elseif sEvent == "moved" then
	elseif sEvent == "ended" then
		if x > self.pPrevX  then
			self:moveToPrev()
		else
			self:moveToNext()
		end
	else
	end
end

--设置显示的数量(外部调用)
function CircleListView:setItemCount( nNum )
	self.nDataNum = nNum
end

--设置子控件显示回调(外部调用)
function CircleListView:setItemCallback( nFunc )
	self.nItemCallBack = nFunc
end

--设置移动回显示回调(后部调用)
function CircleListView:setMovedCallback( nFunc )
	self.nMovedCallBack = nFunc
end

--设置是否可以移动
function CircleListView:setIsCanMoveCallback( nFunc )
	self.nIsCanMoveCallBack = nFunc
end

--移动完回调
function CircleListView:movedCallback(  )
	--遮罩层
	for i=1,#self.pLaySubList do
		local pLaySub = self.pLaySubList[i]
		if i == 1 then
			pLaySub.pLayShadow:setVisible(false)
		elseif i == 2 then
			pLaySub.pLayShadow:setVisible(true)
		elseif i == 3 then
			pLaySub.pLayShadow:setVisible(true)
		end
	end

	if self.nMovedCallBack then
		self.nMovedCallBack(self.nCurrIndex)
	end
end

--设置默认下标显示
function CircleListView:setDefaultIndex( nIndex )
	if not self.nDataNum then
		print("self.nDataNum is nil")
		return
	end
	if not self.nItemCallBack then
		print("self.nItemCallBack is nil")
		return
	end
	if not nIndex then
		print("nIndex is nil")
		return
	end

	self:changeViewByIndex(nIndex)

	--移动完回调
	self:movedCallback()
end

function CircleListView:changeViewByIndex( nIndex )
	self.nCurrIndex = nIndex

	--重置和显示
	for i=1,#self.pLaySubList do
		local pLaySub = self.pLaySubList[i]
		pLaySub:setPosition(self.pSubPosList[i])
		if i == 1 then
			pLaySub:setLocalZOrder(3)
			pLaySub:setScale(fCenterScale)
		elseif i == 2 then
			pLaySub:setLocalZOrder(2)
			pLaySub:setScale(fOtherScale)
		elseif i == 3 then
			pLaySub:setLocalZOrder(1)
			pLaySub:setScale(fOtherScale)
		end
		pLaySub:setVisible(false)
	end

	--显示控件
	if nIndex - 1 >= 0 then
		self:showUiData(1, nIndex)
		self:showUiData(2, nIndex + 1)
		self:showUiData(3, nIndex - 1)
	else
		self:showUiData(1, nIndex)
		self:showUiData(2, nIndex + 1)
		self:showUiData(3, nIndex + 2)
	end
end

--设置默认下标显示
function CircleListView:refreshData(  )
	self:setDefaultIndex(self.nCurrIndex)
end

--显示控件
function CircleListView:showUiData( nLayIndex, nDataIndex)
	local pLaySub = self.pLaySubList[nLayIndex]
	if not pLaySub then
		return
	end
	--显示回调
	if nDataIndex > 0 and nDataIndex <= self.nDataNum then
		pLaySub:setVisible(true)
		self.nItemCallBack(pLaySub, nDataIndex)
	else
		pLaySub:setVisible(false)
	end
end


--移动结束
function CircleListView:actionEnd(  )
	self.nMoving = self.nMoving - 1
	if self.nMoving <= 0 then
		--重置排列
		if self.bMoveNext then
			self.bMoveNext = false
			--之前是3，1，2，移动后的排列是1，2，3，要重置(注意取的是下标的位置，顺序 ，中（2），右（3），左（1）)
			local pLaySubList = {}
			table.insert(pLaySubList, self.pLaySubList[2])
			table.insert(pLaySubList, self.pLaySubList[3])
			table.insert(pLaySubList, self.pLaySubList[1])
			self.pLaySubList = pLaySubList
		end
		if self.bMovePrev then
			self.bMovePrev = false
			--之前是3，1，2，移动后的排列是2，3，1，要重置(注意取的是下标的位置，顺序 ，中（3），右（1），左（2）)
			local pLaySubList = {}
			table.insert(pLaySubList, self.pLaySubList[3])
			table.insert(pLaySubList, self.pLaySubList[1])
			table.insert(pLaySubList, self.pLaySubList[2])
			self.pLaySubList = pLaySubList
		end
		--执行结束回调
		self:movedCallback()
	end
end

--子层移动
function CircleListView:subMove( nIndex, nMoveIndex, nSetUiFunc)
	local pLayTarget = self.pLaySubList[nIndex]
	pLayTarget.pLayShadow:setVisible(true)
	local nOffsetX = self.pSubPosList[nMoveIndex].x - self.pSubPosList[nIndex].x
	local nOffsetY = self.pSubPosList[nMoveIndex].y - self.pSubPosList[nIndex].y
	local nActPos1 = cc.p(nOffsetX/2, nOffsetY/2)
	local nActScale1 = fOtherScale
	if nMoveIndex == 1 then
		nActScale1 = fOtherScale + (fCenterScale - fOtherScale)/2
	end
	local nActT1 = fActionT/2
	--设置层次和遮罩
	local function setZorderAndShadow( )
		--显示遮罩
		if nMoveIndex == 1 then
			pLayTarget:setLocalZOrder(3)
		elseif nIndex == 1 then
			pLayTarget:setLocalZOrder(2)
		else
			pLayTarget:setLocalZOrder(1)
		end
		if nSetUiFunc then
			nSetUiFunc()
		end
	end
	local nActPos2 = self.pSubPosList[nMoveIndex]
	local nActScale2 = fOtherScale
	if nMoveIndex == 1 then
		nActScale2 = fCenterScale
	end
	local nActT2 = fActionT/2
	--动作
	local pSeqAct = cc.Sequence:create({
		--缩小+移动
		cc.Spawn:create({
			cc.ScaleTo:create(nActT1, nActScale1),
			cc.MoveBy:create(nActT1, nActPos1),
		}),
		cc.CallFunc:create(setZorderAndShadow),
		--缩小+移动
		cc.Spawn:create({
			cc.ScaleTo:create(nActT2, nActScale2),
			cc.MoveTo:create(nActT2, nActPos2),
		}),
		cc.CallFunc:create(handler(self, self.actionEnd)),
	})
	pLayTarget:runAction(pSeqAct)
	self.nMoving = self.nMoving + 1
end

--前面的移上来
function CircleListView:moveToNext( )
	if self.nCurrIndex >= self.nDataNum then
		print("已是最后一个")
		return
	end

	if self.nIsCanMoveCallBack then
		local bIsCan = self.nIsCanMoveCallBack(self.nCurrIndex + 1)
		if not bIsCan then
			return
		end
	end

	self.nCurrIndex = self.nCurrIndex + 1
	--是前面的移上来
	self.bMoveNext = true
	--第一个(中间,往左移)
	self:subMove(1, 3)
	--第二个(最右边,征右移)
	self:subMove(2, 1)
	self.pLaySubList[2]:setLocalZOrder(2)
	--第三个(最左边,往左移)
	self:subMove(3, 2, function (  )
		self:showUiData(3, self.nCurrIndex + 1)
	end)
	self.pLaySubList[3]:setLocalZOrder(1)
end

--后面的移上来
function CircleListView:moveToPrev( )
	if self.nCurrIndex <= 1 then
		print("已是开始一个")
		return
	end

	if self.nIsCanMoveCallBack then
		local bIsCan = self.nIsCanMoveCallBack(self.nCurrIndex - 1)
		if not bIsCan then
			return
		end
	end

	self.nCurrIndex = self.nCurrIndex - 1
	--是向后移动
	self.bMovePrev = true
	--第一个(中间,往右移)
	self:subMove(1, 2)
	--第二个(最右边,往左移)
	self:subMove(2, 3, function (  )
		self:showUiData(2, self.nCurrIndex - 1)
	end)
	self.pLaySubList[2]:setLocalZOrder(1)
	--第三个(最左边,往右移)
	self:subMove(3, 1)
	self.pLaySubList[3]:setLocalZOrder(2)
end


function CircleListView:jumpToNearly( nIndex )

	if self:getIsMoving() or self.nCurrIndex == nIndex then
		return
	end

	if not self.nCurrIndex then
		self:changeViewByIndex( nIndex )
	else
		if nIndex > self.nCurrIndex then
			self:moveToNext()
		elseif nIndex < self.nCurrIndex then
			self:moveToPrev()
		end
	end

end

--是否移动中
function CircleListView:getIsMoving( )
	return self.nMoving > 0
end

--获取当前中间下标
function CircleListView:getCurrentIndex( )
	return self.nCurrIndex
end

return CircleListView



	