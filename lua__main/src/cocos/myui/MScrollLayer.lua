----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 17:02:47 
-- Description: 自定义列表
-----------------------------------------------------

--------------------------------
-- @module MScrollLayer

local MFillLayer = import(".MFillLayer")
local MView = import(".MView")

local MScrollLayer = myclass("MScrollLayer", MFillLayer)

MScrollLayer.BG_ZORDER 				= -100
MScrollLayer.TOUCH_ZORDER 			= -99
MScrollLayer.SCROLLNODE_ZODER    	= -88

MScrollLayer.DIRECTION_BOTH			= 0
MScrollLayer.DIRECTION_VERTICAL		= 1
MScrollLayer.DIRECTION_HORIZONTAL	= 2

MScrollLayer.SCROLL_TIME 			= 0.4	

-- start --

--------------------------------
-- 滚动控件的构建函数
-- @function [parent=#MScrollLayer] new
-- @param table params 参数表

--[[--

滚动控件的构建函数

可用参数有：

-   direction 滚动控件的滚动方向，默认为垂直与水平方向都可滚动
-   viewRect 列表控件的显示区域
-   scrollbarImgH 水平方向的滚动条
-   scrollbarImgV 垂直方向的滚动条
-   bgColor 背景色,nil表示无背景色
-   bgStartColor 渐变背景开始色,nil表示无背景色
-   bgEndColor 渐变背景结束色,nil表示无背景色
-   bg 背景图
-   bgScale9 背景图是否可缩放
-	capInsets 缩放区域

]]
-- end --

function MScrollLayer:ctor(params)
	MScrollLayer.super.ctor(self)
	self:scrolllayerInit()
	self.direction = MScrollLayer.DIRECTION_BOTH
	self.layoutPadding = {left = 0, right = 0, top = 0, bottom = 0}
	self.speed = {x = 0, y = 0}
	self.fSpeedScale = 15 -- 滚动速度的倍数
	self.m_bothSize = params.bothSize
	self.bCanScrolled = true --设置是否可以拖动（位置坐标照样返回）
	self.__pScrollBothContentView = nil --scrollBoth类型的内容存放容器
	self.bUseForDrag = false --该scrollLayer是否用于拖拽交换

	if not params then
		return
	end

	if params.viewRect then
		self:setViewRect(params.viewRect)
	end
	if params.direction then
		self:setDirection(params.direction)
	end
	if params.scrollbarImgH then
		self.sbH = display.newScale9Sprite(params.scrollbarImgH, 100)
		self:getFinalClippingView():addChild(self.sbH, 10000)
		self:enableScrollBar()
	end
	if params.scrollbarImgV then
		self.sbV = display.newScale9Sprite(params.scrollbarImgV, 100)
		self:getFinalClippingView():addChild(self.sbV, 20000)
		self:enableScrollBar()
	end

	-- touchOnContent true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
	-- 当内容小于显示区域时，两者就有区别了
	if(params.touchOnContent == nil) then
		params.touchOnContent = true
	end
	self:setTouchType( params.touchOnContent)

	self:addBgIf(params)

	self:onNodeEvent("enter", function(...)
			self:update_(...)
		end)
	self:onUpdate(handler(self, self.update_))

	self.args_ = {params}
	-- 设置点击事件
	self:setViewTouched(true)
	-- 设置自定义的触摸回调
	self:__setChildOnTouchEvent(handler(self, self.onTouch_))
	-- 添加一个默认的触摸控件层
	self:addScrollNode()
end

-- 设置需要可拖动事件
function MScrollLayer:setNeedScrollAction(bIsNeed)
    self._bIsNeedScrollAction = bIsNeed 
end 
--子项大小变化时候整体刷新子项位置
function MScrollLayer:updateSizeFromChild( )
	-- body
	self:__requestVertical(nil)
end

function MScrollLayer:__isNeedScrollAction(  )    	
	return self._bIsNeedScrollAction or true
end

function MScrollLayer:__checkMaxState( _fx, _fy )
	local fScale = 4
	local totalW, totalH = self.scrollNode:getLayoutSize()
	if(MScrollLayer.DIRECTION_VERTICAL == self.direction) then
        local height = self:getHeight()
		local minY = -totalH + height - height/fScale
		local maxY = height/fScale
		if(totalH < height) then
			minY = height - totalH - height/fScale
			maxY = height - totalH + height/fScale
		end
		if(_fy < minY) then
			_fy = minY
		elseif(_fy > maxY) then
			_fy = maxY
		end
	elseif(MScrollLayer.DIRECTION_HORIZONTAL == self.direction) then
        local width = self:getWidth()
		local minX = - totalW + width - width/fScale
		local maxX = width/fScale
		if(totalW < width) then
			minY = -width/fScale
			maxY = width/fScale
		end
		if(_fx < minX) then
			_fx = minX
		elseif(_fx > maxX) then
			_fx = maxX
		end
	end
	return _fx, _fy
end

function MScrollLayer:scrolllayerInit(  )
	self:__setViewType(MUI.VIEW_TYPE.scrollview)
	self:setClipping(true)
	self.bBounce = true
	self.nShakeVal = 5
	self.m_callbackItem = nil -- 每项item的回调
	self.m_callbackEnd = nil -- 加载完成的回调
	self.m_fAsyncTime = 2 -- 每多少帧回调一次
	self.m_nItemCount = nil -- 总共有多少项
	self.m_upItemIndex = 0 -- 递增的item下标，用来做分帧回调标识用的
	self.m_speed = nil --移动速度
end

--设置移动速度
function MScrollLayer:setScrollSpeed( _nSpeed )
	-- body
	self.m_speed = _nSpeed
end

--设置是否用于拖拽交换效果
function MScrollLayer:setUseForDrag( _bUsed )
	-- body
	self.bUseForDrag = _bUsed
end

function MScrollLayer:addBgIf(params)
	if not params.bg then
		return
	end

	local bg
	if params.bgScale9 then
		bg = display.newScale9Sprite(params.bg, nil, nil, nil, params.capInsets)
	else
		bg = display.newSprite(params.bg)
	end

	bg:setContentSize(params.viewRect.width, params.viewRect.height)
		:setPosition(params.viewRect.x + params.viewRect.width/2,
			params.viewRect.y + params.viewRect.height/2)
		:addTo(self, MScrollLayer.BG_ZORDER)
		:setTouchEnabled(false)
end

function MScrollLayer:setViewRect(rect)
	-- 这里不能直接赋值给self.viewRect_,要使得起点是0，0开始
	self.viewRect_ = cc.rect(0, 0, rect.width, rect.height)
	self.viewRectIsNodeSpace = false
	self:setPosition(rect.x, rect.y)
	self:setLayoutSize(rect.width, rect.height)

	return self
end

-- start --

--------------------------------
-- 得到滚动控件的显示区域
-- @function [parent=#MScrollLayer] getViewRect
-- @return Rect#Rect 

-- end --

function MScrollLayer:getViewRect()
	return self.viewRect_
end
--- 获取控件大小
-- return(float, float): 控件宽度，控件高度
-- function MScrollLayer:getLayoutSize( )
-- 	return self.:getViewRect().width, self:getViewRect().height
-- end

-- start --

--------------------------------
-- 设置布局四周的空白
-- @function [parent=#MScrollLayer] setLayoutPadding
-- @param number top 上边的空白
-- @param number right 右边的空白
-- @param number bottom 下边的空白
-- @param number left 左边的空白
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:setLayoutPadding(top, right, bottom, left)
	if not self.layoutPadding then
		self.layoutPadding = {}
	end
	self.layoutPadding.top = top
	self.layoutPadding.right = right
	self.layoutPadding.bottom = bottom
	self.layoutPadding.left = left

	return self
end

function MScrollLayer:setActualRect(rect)
	self.actualRect_ = rect
end

-- start --

--------------------------------
-- 设置滚动方向
-- @function [parent=#MScrollLayer] setDirection
-- @param number dir 滚动方向
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:setDirection(dir)
	self.direction = dir

	return self
end

-- start --

--------------------------------
-- 获取滚动方向
-- @function [parent=#MScrollLayer] getDirection
-- @return number#number 

-- end --

function MScrollLayer:getDirection()
	return self.direction
end

-- start --

--------------------------------
-- 设置滚动控件是否开启回弹功能
-- @function [parent=#MScrollLayer] setBounceable
-- @param boolean bBounceable 是否开启回弹
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:setBounceable(bBounceable)
	self.bBounce = bBounceable

	return self
end

-- start --

--------------------------------
-- 设置触摸响应方式
-- true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
-- 内容大于显示区域时，两者无差别
-- 内容小于显示区域时，true:在空白区域触摸无效,false:在空白区域触摸也可滚动内容
-- @function [parent=#MScrollLayer] setTouchType
-- @param boolean bTouchOnContent 是否触控到滚动内容上才有效
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:setTouchType(bTouchOnContent)
	self.touchOnContent = bTouchOnContent

	return self
end

--[[--

重置位置,主要用在纵向滚动时

]]
function MScrollLayer:resetPosition()
	if MScrollLayer.DIRECTION_VERTICAL ~= self.direction then
		return
	end

	local x, y = self.scrollNode:getPosition()
	local bound = self.scrollNode:getCascadeBoundingBox()
	local disY = self.viewRect_.y + self.viewRect_.height - bound.y - bound.height
	y = y + disY
	self.scrollNode:setPosition(x, y)
end

-- start --

--------------------------------
-- 判断一个node是否在滚动控件的显示区域中
-- @function [parent=#MScrollLayer] isItemInViewRect
-- @param node item scrollView中的项
-- @return boolean#boolean 

-- end --

function MScrollLayer:isItemInViewRect(item)
	if "userdata" ~= type(item) then
		item = nil
	end

	if not item then
		print("MScrollLayer - isItemInViewRect item is not right")
		return
	end

	local bound = item:getCascadeBoundingBox()
	-- local point = cc.p(bound.x, bound.y)
	-- local parent = item
	-- while true do
	-- 	parent = parent:getParent()
	-- 	point = parent:convertToNodeSpace(point)
	-- 	if parent == self.scrollNode then
	-- 		break
	-- 	end
	-- end
	-- bound.x = point.x
	-- bound.y = point.y
	return cc.rectIntersectsRect(self:getViewRectInWorldSpace(), bound)
end

-- start --

--------------------------------
-- 设置scrollview可触摸
-- @function [parent=#MScrollLayer] setTouchEnabled
-- @param boolean bEnabled 是否开启触摸
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:setScrollTouchEnabled(bEnabled)
	if not self.scrollNode then
		return
	end
	self.scrollNode:setTouchEnabled(bEnabled)

	return self
end

-- start --

--------------------------------
-- 将要显示的node加到scrollview中,scrollView只支持滚动一个node
-- @function [parent=#MScrollLayer] addScrollNode
-- @param node node 要显示的项
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:addScrollNode(node)
	if(not node) then
		-- 增加一个默认的触摸层
		node = MUI.MLayer.new()
    	-- 根据不同类型，控制不同的触摸层大小
		if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
    		node:setLayoutSize(self:getWidth(), 1)
    	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
    		node:setLayoutSize(1, self:getHeight())
    	else
    		if(not self.m_bothSize) then
    			self.m_bothSize = cc.size(self:getWidth(), self:getHeight())
    		end
    		node:setLayoutSize(self.m_bothSize.width, self.m_bothSize.height)
		end
	end
	-- 如果已经存在，清除原来的
	if(self.scrollNode ~= nil) then
		self.scrollNode:removeSelf()
		self.scrollNode = nil
	end
	MScrollLayer.super.addView(self, node, MScrollLayer.SCROLLNODE_ZODER)
	self.scrollNode = node
	-- 强制取消屏幕范围内判断的逻辑，因为MListView中scrollNode的宽高暂定处理为0
	if(node and node.setNeedCheckScreen) then
		node:setNeedCheckScreen(false)
	end

	if not self.viewRect_ then
		self.viewRect_ = node:getCascadeBoundingBox()
		self:setViewRect(self.viewRect_)
	end
	node:setPositionY(self:getHeight()-node:getHeight())
	-- self:addTouchNode()
	-- 直接定位到顶部
	self:scrollTo(0,self:getHeight()-node:getHeight())

    return self
end

-- start --

--------------------------------
-- 返回scrollView中的滚动node
-- @function [parent=#MScrollLayer] getScrollNode
-- @return node#node  滚动node

-- end --

function MScrollLayer:getScrollNode()
	return self.scrollNode
end

-- start --

--------------------------------
-- 注册滚动控件的监听函数
-- @function [parent=#MScrollLayer] onScroll
-- @param function listener 监听函数
-- @return MScrollLayer#MScrollLayer 

-- end --

function MScrollLayer:onScroll(listener)
	self.scrollListener_ = listener

    return self
end

-- private

function MScrollLayer:calcLayoutPadding()
	local boundBox = self.scrollNode:getCascadeBoundingBox()

	self.layoutPadding.left = boundBox.x - self.actualRect_.x
	self.layoutPadding.right =
		self.actualRect_.x + self.actualRect_.width - boundBox.x - boundBox.width
	self.layoutPadding.top = boundBox.y - self.actualRect_.y
	self.layoutPadding.bottom =
		self.actualRect_.y + self.actualRect_.height - boundBox.y - boundBox.height
end

function MScrollLayer:update_(dt)
	self:drawScrollBar()
end

-- 获取所有可视的控件（已排序的）和总长度
-- return(table, float): 所有可视的控件，总长度
function MScrollLayer:__getShowViewsAndLong(  )
	local pChilds = self.scrollNode:getLuaChildren() -- 所有的子控件
    local tHandleViews = {} -- 取得所有MView的控件
    local fTotal = 0 -- 总高度
    local nDirection = self.direction
    for i, v in pairs(pChilds) do
        if(v and v.bMView and v:isVisible()) then
            -- 记录所有MView的控件
            tHandleViews[#tHandleViews+1] = v
            if(nDirection == MScrollLayer.DIRECTION_VERTICAL) then
	            -- 计算剩余高度
	            fTotal = fTotal + v:getHeight()
	        elseif(nDirection == MScrollLayer.DIRECTION_HORIZONTAL) then
	        	-- 计算剩余高度
            	fTotal = fTotal + v:getWidth()
            else
            end
        end
    end
    -- 按照y值的降序来排
    table.sort(tHandleViews, function ( _pView1, _pView2 )
        if(_pView1 and _pView2) then
            local f1 = _pView1.m_listOrder
            local f2 = _pView2.m_listOrder
            if(f1 > f2) then
                return true
            elseif(f1 == f2) then
                return false
            else
                return false
            end
        end
        return false
    end)
    return tHandleViews, fTotal
end
-- 获取新的y值
-- _index（int）：当前需要插入的位置
function MScrollLayer:__getNewPosition( _index )
	local fValue = 0
	local tHandleViews, fTotal = self:__getShowViewsAndLong()
	if(not tHandleViews or #tHandleViews == 0) then
		fValue = 999999
	else
		local nDis = 0.01
		if(_index == nil) then
			_index = #tHandleViews
			nDis = -1 -- 加载后面的，所以要负数
		end
		-- 特地降低y值
		if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
			fValue = tHandleViews[_index].m_listOrder + nDis
		elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
			fValue = tHandleViews[_index].m_listOrder + nDis
		end
	end
	return fValue
end
-- 刷新垂直方向的布局
-- _nHeight：高度变化
function MScrollLayer:__requestVertical( _nHeight )
    local pScrollNode = self.scrollNode
	if(not pScrollNode) then
		return
	end

    local tHandleViews, fTotalHeight = self:__getShowViewsAndLong()

    pScrollNode:setLayoutSize(pScrollNode:getWidth(), fTotalHeight)

    local fLeftHeight = fTotalHeight
    for i, v in pairs(tHandleViews) do
        -- 重新调整y值
        local cp = v:getAnchorPoint()
        local fH = v:getHeight()
        fLeftHeight = fLeftHeight - fH
        local fY = fLeftHeight + fH * cp.y
        v:setPosition(v:getPositionX(), fY)
    end

    if(_nHeight) then
    	-- 重置位置
        local y = pScrollNode:getPositionY() + _nHeight
    	pScrollNode:setPositionY(y)
    end

end
-- 刷新水平方向的布局
-- nWidth：宽度变化
function MScrollLayer:__requestHorizontal( nWidth )
	if(not self.scrollNode) then
		return
	end
    local tHandleViews, fTotalWidth = self:__getShowViewsAndLong()
    self.scrollNode:setLayoutSize(fTotalWidth, self.scrollNode:getHeight())
    local fLeftWidth = fTotalWidth
    for i, v in pairs(tHandleViews) do
        -- 重新调整y值
        local cp = v:getAnchorPoint()
        local fW = v:getWidth()
        fLeftWidth = fLeftWidth - fW
        local fX = fLeftWidth + fW * cp.x
        v:setPositionX(fTotalWidth-fX)
    end
    if(nWidth) then
    	-- 重置位置
    	self.scrollNode:setPositionX(self.scrollNode:getPositionX() + nWidth)
    end
end

function MScrollLayer:onTouchCapture_(event)
	if ("began" == event.name or "moved" == event.name or "ended" == event.name)
		and self:isTouchInViewRect(event) then
		return true
	else
		return false
	end
end

function MScrollLayer:setIsCanScroll( _bEnabled )
	-- body
	self.bCanScrolled = _bEnabled
end

--设置是否开启多点触摸
function MScrollLayer:setMultiTouch( bCan )
	-- body
	self.__bMultiTouch = bCan
end

--设置最小缩放值
function MScrollLayer:setMinScale( fScale )
	-- body
	self.nMinScale = fScale 
end

--设置最大缩放值
function MScrollLayer:setMaxScale( fScale )
	-- body
	self.nMaxScale = fScale 
end

--scrollLayer上的某个点移动到屏幕上某个点
function MScrollLayer:movePointToScreenPoint( _tStartPoint,_tEndPoint,_bAction,_handler,_bLimit )
	-- body
	if not _tStartPoint or not _tEndPoint then
		return
	end

	if _bAction == nil then
		_bAction = false
	end

	if _bLimit == nil then
		_bLimit = true
	end

	local pCenterPoint = self.scrollNode:convertToNodeSpace(_tEndPoint)
	--计算差值
	local nXv = pCenterPoint.x - _tStartPoint.x
	local nYv = pCenterPoint.y - _tStartPoint.y
	local nSx = self.scrollNode:getPositionX() + nXv
	local nSy = self.scrollNode:getPositionY() + nYv
	if _bLimit then
		self:scrollToForBoth(nSx,nSy,_bAction,_handler)
	else
		self:scrollTo(nSx,nSy,_bAction,_handler)
	end
end

--获得屏幕的缩放值
function MScrollLayer:getScrollBothScale(  )
	-- body
	if self.__pScrollBothContentView then
		return self.__pScrollBothContentView:getScale()
	end
	return 1
end

--获得左下角坐标
function MScrollLayer:getOriginPoision(  )
	-- body
	return self.position_
end

--设置点击音效
function MScrollLayer:setNeedClickSound( _bNeed )
	-- body
	self.bNeedSound = _bNeed
end

--设置缩放值（位置）
function MScrollLayer:setScrollBothScale( _fScale, _x, _y, _bAction )
	-- body
	if not _fScale then
		return
	end

	if _bAction == nil then
		_bAction = true
	end
	local nX = _x or 0
	local nY = _y or 0
	local pMidPoint = cc.p(nX,nY)
	--获取转换后的坐标
	pMidPoint = self.scrollNode:convertToNodeSpace(pMidPoint)

    local pScrollBothContentView = self.__pScrollBothContentView
	if pScrollBothContentView then
        local contentSize = pScrollBothContentView:getContentSize()
		local minScale = self.nMinScale or 1.0
		local maxScale = self.nMaxScale or 1.7
		local fOscale = pScrollBothContentView:getScale()
		local newScale = _fScale 
		if(newScale <= minScale) then
			newScale = minScale
		elseif(newScale >= maxScale) then
			newScale = maxScale
		end
		pScrollBothContentView:setScale(newScale)
		--旧的大小
		local pOldSize = self.scrollNode:getContentSize()
		--设置大小
		self.scrollNode:setLayoutSize(
			contentSize.width * pScrollBothContentView:getScale(),
			contentSize.height * pScrollBothContentView:getScale())
		--获取大小
		local w, h = self.scrollNode:getLayoutSize()
		--重新计算位置
		local pNewMidPoint = cc.p(pMidPoint.x / (pOldSize.width) * w,
			pMidPoint.y/(pOldSize.height) * h)
		--计算滚动到的位置
		local nSx = self.scrollNode:getPositionX() - (pNewMidPoint.x-pMidPoint.x)
		local nSy = self.scrollNode:getPositionY() - (pNewMidPoint.y-pMidPoint.y)
		--(最大值)
		if nSx > 0 then
			nSx = 0
		end
		if nSy > 0 then
			nSy = 0 
		end
		--(最小值)
		local nMinY = -1 * contentSize.height * newScale + self.viewRect_.height
		local nMinX = -1 * contentSize.width * newScale + self.viewRect_.width
		if nSx < nMinX then
			nSx = nMinX
		end
		if nSy < nMinY then
			nSy = nMinY 
		end
		self:scrollTo(nSx,nSy,_bAction)
	end
end

--多点触摸
function MScrollLayer:onMuiTouch_( event )
	-- body
	--是否开启多点触摸
	if self.__bMultiTouch then
		if "moved" == event.name then --移动过程中
			if event.points and table.nums(event.points) >= 2 then
				if event.points["0"] and event.points["1"] then --最先两根手指还在
					local tEv1 = event.points["0"]
					local tEv2 = event.points["1"]
					--获得两根手指的新旧坐标
					local tOldPoint1 = cc.p(tEv1.prevX,tEv1.prevY)
					local tOldPoint2 = cc.p(tEv2.prevX,tEv2.prevY)
					local tNewPoint1 = cc.p(tEv1.x,tEv1.y)
					local tNewPoint2 = cc.p(tEv2.x,tEv2.y)
					--计算新旧距离
					local fOldDis = math.sqrt((tOldPoint1.x - tOldPoint2.x)
							* (tOldPoint1.x - tOldPoint2.x) 
							+ (tOldPoint1.y - tOldPoint2.y) 
							* (tOldPoint1.y - tOldPoint2.y))
					local fNewDis = math.sqrt((tNewPoint1.x - tNewPoint2.x)
							* (tNewPoint1.x - tNewPoint2.x) 
							+ (tNewPoint1.y - tNewPoint2.y) 
							* (tNewPoint1.y - tNewPoint2.y))
					if self.scrollNode then
						if self.__pScrollBothContentView then
							local minScale = self.nMinScale or 1.0
							local maxScale = self.nMaxScale or 1.7
							--获取初始中点
							local pMidPoint = cc.p((tOldPoint1.x + tOldPoint2.x) / 2,(tOldPoint1.y + tOldPoint2.y) / 2)
							--获取转换后的坐标
							pMidPoint = self.scrollNode:convertToNodeSpace(pMidPoint)
							--旧的缩放比例
							local fOscale = self.__pScrollBothContentView:getScale()
							local newScale = fOscale*fNewDis/fOldDis
							if(newScale <= minScale) then
								newScale = minScale
							elseif(newScale >= maxScale) then
								newScale = maxScale
							end
							self.__pScrollBothContentView:setScale(newScale)
							--旧的大小
							local pOldSize = self.scrollNode:getContentSize()
							--设置大小
							self.scrollNode:setLayoutSize(
								self.__pScrollBothContentView:getContentSize().width * self.__pScrollBothContentView:getScale(),
								self.__pScrollBothContentView:getContentSize().height * self.__pScrollBothContentView:getScale())
							--获取大小
							local w, h = self.scrollNode:getLayoutSize()
							--重新计算位置
							local pNewMidPoint = cc.p(pMidPoint.x / (pOldSize.width) * w,
								pMidPoint.y/(pOldSize.height) * h)
							--计算滚动到的位置
							local nSx = self.scrollNode:getPositionX() - (pNewMidPoint.x-pMidPoint.x)
							local nSy = self.scrollNode:getPositionY() - (pNewMidPoint.y-pMidPoint.y)
							--边界判断
							--(最大值)
							if nSx > 0 then
								nSx = 0
							end
							if nSy > 0 then
								nSy = 0 
							end
							--(最小值)
							local nMinY = -1 * self.__pScrollBothContentView:getContentSize().height * newScale + self.viewRect_.height
							local nMinX = -1 * self.__pScrollBothContentView:getContentSize().width * newScale + self.viewRect_.width
							if nSx < nMinX then
								nSx = nMinX
							end
							if nSy < nMinY then
								nSy = nMinY 
							end
							self:scrollTo(nSx,nSy)
						end
					end
				end
			end
		elseif "added" == event.name then --添加手指
			
		elseif "removed" == event.name then --移除手指
			
		end
	else
		return
	end
end

--单点触摸
function MScrollLayer:onTouch_(event)
	if(not self.scrollNode) then
		printMUI("请添加一个ScrollLayer的子控件")
		return
	end
	local nHandleType = nil
	if "began" == event.name and not self:isTouchInViewRect(event) then
		printInfo("MScrollLayer - touch didn't in viewRect")
		return false, nHandleType
	end

	if "began" == event.name and self.touchOnContent then
		local cascadeBound = self.scrollNode:getCascadeBoundingBox()
		if not cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y)) then
			return false, nHandleType
		end
	end

	if "began" == event.name then
		self.prevX_ = event.x
		self.prevY_ = event.y
		self.bDrag_ = false
		local x,y = self.scrollNode:getPosition()
		self.position_ = {x = x, y = y}
		transition.stopTarget(self.scrollNode)
		self:callListener_{name = "began", x = event.x, y = event.y, 
			originX = self.scrollNode:getPositionX(),
			originY = self.scrollNode:getPositionY()}

		self:enableScrollBar()

		self.scaleToWorldSpace_ = self:scaleToParent_()

        if self.bScrolling_ == false then
            self.speed.x = 0
            self.speed.y = 0
        end

		return true, nHandleType
	elseif "moved" == event.name then
		--多点触摸行为下不能移动
		if MultiTouched then
			return
		end
		if self:isShake(event) then
			return
		end
		if not self.bCanScrolled then
			return
		end

		self.bDrag_ = true
		self.speed.x = event.x - event.prevX
		self.speed.y = event.y - event.prevY

		if self.direction == MScrollLayer.DIRECTION_VERTICAL then
			self.speed.x = 0
		elseif self.direction == MScrollLayer.DIRECTION_HORIZONTAL then
			self.speed.y = 0
		else
			-- do nothing
		end
		nHandleType = MUI.TOUCH_HANDLE_TYPE.MOVED

		self:scrollBy(self.speed.x, self.speed.y)
		
		self:callListener_{name = "moved", x = event.x, y = event.y,
			originX = self.scrollNode:getPositionX(),
			originY = self.scrollNode:getPositionY()}
	elseif "ended" == event.name then
        
        self:scrollAuto()
		if self.bDrag_ then
			self.bDrag_ = false
            
			self:callListener_{name = "ended", x = event.x, y = event.y,
				originX = self.scrollNode:getPositionX(),
				originY = self.scrollNode:getPositionY()}

			self:disableScrollBar()
		else
			if self.bNeedSound and not MultiTouched then --开启了音效，并且没有多点触摸
				--播放点击音效
				if playClickSoundEffect then
					playClickSoundEffect()
				end
			end
			self:callListener_{name = "clicked", x = event.x, y = event.y,
				originX = self.scrollNode:getPositionX(),
				originY = self.scrollNode:getPositionY()}
		end
	end
	return true, nHandleType
end

function MScrollLayer:isTouchInViewRect(event)
	local x, y = __convertToRealPoint(self, event.x, event.y)
	return cc.rectContainsPoint(self:getBoundingBox(), cc.p(x, y))
end

function MScrollLayer:isTouchInScrollNode(event)
	local x, y = __convertToRealPoint(self, event.x, event.y)
	local cascadeBound = self.scrollNode:getBoundingBox()
	return cc.rectContainsPoint(cascadeBound, cc.p(x, y))
end

function MScrollLayer:scrollToPosition( _nPos, _bAction )
	-- body
	if _bAction == nil then
		_bAction = true
	end
	if _nPos <=0 then
		return
	end
	--双向拖动的不能移动到某个位置
	if self.direction == MScrollLayer.DIRECTION_BOTH then
		return
	end

	local tHandleViews, fTotal = self:__getShowViewsAndLong()
	local nSize = table.nums(tHandleViews) 
	--计算高度
	local nLength = 0
	if tHandleViews and nSize > 0 then
		--下标超过总个数 直接返回
		if _nPos > nSize then
			return
		end
		for k, v in pairs (tHandleViews) do
			if k >= _nPos then
				break
			else
				if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
					nLength = nLength + v:getHeight()
				elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
					nLength = nLength + v:getWidth()
				end
			end
		end
	end
	if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
		local y__ = self.viewRect_.height - (fTotal - nLength)
		if y__ > 0 then
			y__ = 0
		end
		self:scrollTo(self.scrollNode:getPositionX(), y__, _bAction)
	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
		local nMax = self.viewRect_.width - fTotal
		local x__ = -nLength 
		if x__ < nMax then
			x__ = nMax
		end
		self:scrollTo(x__, self.scrollNode:getPositionY(), _bAction)
	end
	--znftodo不知道为什么出错
	if self.checkIsShowArrow_ then
		self:checkIsShowArrow_()
	end
end

function MScrollLayer:scrollToBegin( _bAction )
	-- body
	self:scrollToPosition(1,_bAction)
end

function MScrollLayer:scrollToEnd( _bAction )
	-- body
	local tHandleViews, fTotal = self:__getShowViewsAndLong()
	local nSize = table.nums(tHandleViews) 
	self:scrollToPosition(nSize,_bAction)
end

function MScrollLayer:scrollToForBoth( p, y, _bAction, _handler )
	-- body
	--双向拖动的情况下，处理边界判断
	if self.direction == MScrollLayer.DIRECTION_BOTH then
		local x_, y_
		if "table" == type(p) then
			x_ = p.x or 0
			y_ = p.y or 0
		else
			x_ = p
			y_ = y
		end

		if x_ > 0 then
			x_ = 0
		end
		if y_ > 0 then
			y_ = 0 
		end
		--(最小值)__pScrollBothContentView
		local nMinY = -1 * self.__pScrollBothContentView:getContentSize().height * self:getScrollBothScale() + self.viewRect_.height
		local nMinX = -1 * self.__pScrollBothContentView:getContentSize().width * self:getScrollBothScale() + self.viewRect_.width
		if x_ < nMinX then
			x_ = nMinX
		end
		if y_ < nMinY then
			y_ = nMinY 
		end
		self:scrollTo(x_,y_,_bAction, _handler)
	end
end

function MScrollLayer:scrollTo(p, y, _bAction, _handler)
	local x_, y_
	if "table" == type(p) then
		x_ = p.x or 0
		y_ = p.y or 0
	else
		x_ = p
		y_ = y
	end

	self.position_ = cc.p(x_, y_)
	if _bAction then
		self.bScrolling_ = true
		local fTime = MScrollLayer.SCROLL_TIME
		if self.m_speed then --存在速度（需要计算时间）
			local nDis =  math.sqrt((self.position_.x - self.scrollNode:getPositionX())
									* (self.position_.x - self.scrollNode:getPositionX()) 
									+ (self.position_.y - self.scrollNode:getPositionY()) 
									* (self.position_.y - self.scrollNode:getPositionY()))
			fTime = nDis / self.m_speed
		end
		--先取消所有的动作
		self.scrollNode:stopAllActions()
		transition.moveTo(self.scrollNode,{x = self.position_.x, 
			y = self.position_.y, time = fTime,
			-- easing = "sineOut",
			onComplete = function()
				self.bScrolling_ = false -- 必须在_handler之前赋值，因为_handler有可能将self.bScrolling_设置为true
				if _handler then
					_handler()
				end
			end})
	else
		-- 这里的false重置在MListView的increaseOrReduceItem_中去处理
		self.bReposing_ = true
		self.scrollNode:setPosition(self.position_)
		if _handler then
			_handler()
		end
	end
	
end

function MScrollLayer:moveXY(orgX, orgY, speedX, speedY)
	if self.bBounce then
		-- bounce enable
		return orgX + speedX, orgY + speedY
	end

	local cascadeBound = self:getScrollNodeRect()
	local viewRect = self:getViewRectInWorldSpace()
	local x, y = orgX, orgY
	local disX, disY

	if speedX > 0 then
		if cascadeBound.x < viewRect.x then
			disX = viewRect.x - cascadeBound.x
			disX = disX / self.scaleToWorldSpace_.x
			x = orgX + math.min(disX, speedX)
		end
	else
		if cascadeBound.x + cascadeBound.width > viewRect.x + viewRect.width then
			disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
			disX = disX / self.scaleToWorldSpace_.x
			x = orgX + math.max(disX, speedX)
		end
	end

	if speedY > 0 then
		if cascadeBound.y < viewRect.y then
			disY = viewRect.y - cascadeBound.y
			disY = disY / self.scaleToWorldSpace_.y
			y = orgY + math.min(disY, speedY)
		end
	else
		if cascadeBound.y + cascadeBound.height > viewRect.y + viewRect.height then
			disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
			disY = disY / self.scaleToWorldSpace_.y
			y = orgY + math.max(disY, speedY)
		end
	end

	return x, y
end

function MScrollLayer:scrollBy(x, y)
	self.position_.x, self.position_.y = self:moveXY(self.position_.x, self.position_.y, x, y)
	-- self.position_.x = self.position_.x + x
	-- self.position_.y = self.position_.y + y
    	
	if self.eViewType == MUI.VIEW_TYPE.scrollview and self.direction ~= MScrollLayer.DIRECTION_BOTH then
		local bIsNeed = self:__isNeedScrollAction()
		if not bIsNeed then
			return
		end
	end
	
	self.scrollNode:setPosition(self.position_)

	if self.actualRect_ then
		self.actualRect_.x = self.actualRect_.x + x
		self.actualRect_.y = self.actualRect_.y + y
	end
end
-- 自动滚动定位到可视范围
-- _bAction(bool): 是否需要执行动画
function MScrollLayer:scrollAuto( _bAction )
	if self.bUseForDrag then --如果用于拖拽交换 那么直接返回
		return
	end
	if(_bAction == nil) then
		_bAction = true
	end
	if self:twiningScroll(_bAction) then
		return
	end
	self:elasticScroll(_bAction)
end

-- fast drag
function MScrollLayer:twiningScroll( _bAction )
	if(_bAction == nil) then
		_bAction = true
	end
	-- if self:isSideShow() then
	-- 	return false
	-- end

	if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
		return false
	end

	local disX, disY = self:moveXY(0, 0, self.speed.x*self.fSpeedScale, self.speed.y*self.fSpeedScale)
	local fx = self.scrollNode:getPositionX()+disX
	local fy = self.scrollNode:getPositionY()+disY
	-- 判断不能超过滑动范围
	if(self.__checkMaxState) then
		fx, fy = self:__checkMaxState(fx, fy)
	end
	-- 执行滑动
	self:scrollTo(fx, fy,
		_bAction, function (  )
			self:elasticScroll()
		end)
	return true
end

function MScrollLayer:elasticScroll( _bAction )
	if(_bAction == nil) then
		_bAction = true
	end
	local cascadeBound = self:getScrollNodeRect()
	local disX, disY = 0, 0
	local viewRect = self:getViewRect() -- InWorldSpace()
	local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))

	cascadeBound.x = t.x
	cascadeBound.y = t.y
	self.scaleToWorldSpace_ = self.scaleToWorldSpace_ or {x=1,y=1}
	cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
	cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y


	if cascadeBound.width < viewRect.width then
		disX = viewRect.x - cascadeBound.x
	else
		if cascadeBound.x > viewRect.x then
			disX = viewRect.x - cascadeBound.x
		elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
			disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
		end
	end

	if cascadeBound.height < viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
	else
		if cascadeBound.y > viewRect.y then
			disY = viewRect.y - cascadeBound.y
		elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
			disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
		end
	end

	if 0 == disX and 0 == disY then
		self:callListener_{name = "scrollEnd",
			originX = self.scrollNode:getPositionX(),
			originY = self.scrollNode:getPositionY()}
		return
	end
	local fx = self.scrollNode:getPositionX()+disX
	local fy = self.scrollNode:getPositionY()+disY
	-- 判断不能超过滑动范围
	if(self.__checkMaxState) then
		fx, fy = self:__checkMaxState(fx, fy)
	end
	-- 执行滑动
	self:scrollTo(fx, fy,
		_bAction, function (  )
			self:callListener_{name = "scrollEnd",
				originX = self.scrollNode:getPositionX(),
				originY = self.scrollNode:getPositionY()}
			--目前只对竖做回调
			if disY <= -100 then
				self:callListener_{name = "scrollToFooter"}
			elseif disY >= 100 then
				self:callListener_{name = "scrollToHeader"}
			end
		end)
end


function MScrollLayer:getScrollNodeRect()
	local bound = nil
    local scrollNode = self.scrollNode
	if(self.direction == MScrollLayer.DIRECTION_BOTH) then		
		bound = scrollNode:getBoundingBox()
        local worldPos = scrollNode:convertToWorldSpace(cc.p(0, 0))
        bound.x = worldPos.x
        bound.y = worldPos.y
	else
		bound = scrollNode:getCascadeBoundingBox()
	end
	-- bound.x = bound.x - self.layoutPadding.left
	-- bound.y = bound.y - self.layoutPadding.bottom
	-- bound.width = bound.width + self.layoutPadding.left + self.layoutPadding.right
	-- bound.height = bound.height + self.layoutPadding.bottom + self.layoutPadding.top

	return bound
end

function MScrollLayer:getViewRectInWorldSpace()
	local rect = self:convertToWorldSpace(
		cc.p(self.viewRect_.x, self.viewRect_.y))	
	if(self.direction == MScrollLayer.DIRECTION_BOTH) then	
		rect.width = self.viewRect_.width
		rect.height = self.viewRect_.height
	else
		local scrollNode = self.scrollNode
		local pSize = scrollNode:getContentSize()
		local pRect = self:getScrollNodeRect()
		rect.width = self.viewRect_.width*pRect.width/pSize.width
		rect.height = self.viewRect_.height*pRect.height/pSize.height		
	end
	return rect
end

-- 是否显示到边缘
function MScrollLayer:isSideShow()
	local bound = self.scrollNode:getCascadeBoundingBox()
    local localPos = self:convertToNodeSpace(cc.p(bound.x, bound.y))
    local verticalSideShow = (localPos.y > self.viewRect_.y) 
                           or (localPos.y + bound.height < self.viewRect_.y + self.viewRect_.height)
    local horizontalSideShow = (localPos.x > self.viewRect_.x)
                             or (localPos.x + bound.width < self.viewRect_.x + self.viewRect_.width)
    if MScrollLayer.DIRECTION_VERTICAL == self.direction then
        return verticalSideShow
    elseif MScrollLayer.DIRECTION_HORIZONTAL == self.direction then
        return horizontalSideShow
    else
        return (verticalSideShow or horizontalSideShow)
    end

	return false
end

function MScrollLayer:callListener_(event)
	if not self.scrollListener_ then
		return
	end
	event.scrollView = self
	-- 记录屏幕的原始坐标
	event.screenX = event.x
	event.screenY = event.y
	--转换为scrollView对应坐标系的坐标
	if event.x and event.y then
		local tRealPos = self.scrollNode:convertToNodeSpace(cc.p(event.x, event.y))
		if tRealPos then
			event.x = tRealPos.x
			event.y = tRealPos.y
		end
	end
	self.scrollListener_(event)
	--znftodo不知道为什么出错
	if self.checkIsShowArrow_ then
		self:checkIsShowArrow_(event)
	end
end

function MScrollLayer:enableScrollBar()
	local bound = nil
	if(self.scrollNode) then
		bound = self.scrollNode:getCascadeBoundingBox()
	end
	if self.sbV then
		self.sbV:setVisible(false)
		transition.stopTarget(self.sbV)
		self.sbV:setOpacity(128)
		local size = self.sbV:getContentSize()
		if bound and self.viewRect_.height < bound.height then
			local barH = self.viewRect_.height*self.viewRect_.height/bound.height
			if barH < size.width then
				-- 保证bar不会太小
				barH = size.width
			end
			self.sbV:setContentSize(size.width, barH)
			self.sbV:setPosition(
				self.viewRect_.x + self.viewRect_.width - size.width/2, self.viewRect_.y + barH/2)
		else
			self.sbV:setPosition(
				self.viewRect_.x + self.viewRect_.width - size.width/2, 
				self.viewRect_.y + size.height/2)
		end
	end
	if self.sbH then
		self.sbH:setVisible(false)
		transition.stopTarget(self.sbH)
		self.sbH:setOpacity(128)
		local size = self.sbH:getContentSize()
		if bound and self.viewRect_.width < bound.width then
			local barW = self.viewRect_.width*self.viewRect_.width/bound.width
			if barW < size.height then
				barW = size.height
			end
			self.sbH:setContentSize(barW, size.height)
			self.sbH:setPosition(self.viewRect_.x + barW/2,
				self.viewRect_.y + size.height/2)
		else
			self.sbH:setPosition(self.viewRect_.x + barW/2,
				self.viewRect_.y + size.height/2)
		end
	end
end

function MScrollLayer:disableScrollBar()
	if self.sbV then
		transition.fadeOut(self.sbV,
			{time = 0.3,
			onComplete = function()
				self.sbV:setOpacity(128)
				self.sbV:setVisible(false)
			end})
	end
	if self.sbH then
		transition.fadeOut(self.sbH,
			{time = 1.5,
			onComplete = function()
				self.sbH:setOpacity(128)
				self.sbH:setVisible(false)
			end})
	end
end

function MScrollLayer:drawScrollBar()
	if not self.bDrag_ then
		return
	end
	if not self.sbV and not self.sbH then
		return
	end

	local bound = self.scrollNode:getCascadeBoundingBox()
	if self.sbV then
		self.sbV:setVisible(true)
		local size = self.sbV:getContentSize()

		local posY = (self.viewRect_.y - bound.y)*(self.viewRect_.height - size.height)/(bound.height - self.viewRect_.height)
			+ self.viewRect_.y + size.height/2
		local x, y = self.sbV:getPosition()
		self.sbV:setPosition(x, posY)
	end
	if self.sbH then
		self.sbH:setVisible(true)
		local size = self.sbH:getContentSize()

		local posX = (self.viewRect_.x - bound.x)*(self.viewRect_.width - size.width)/(bound.width - self.viewRect_.width)
			+ self.viewRect_.x + size.width/2
		local x, y = self.sbH:getPosition()
		self.sbH:setPosition(posX, y)
	end
end

function MScrollLayer:addScrollBarIf()

	if not self.sb then
		self.sb = cc.DrawNode:create():addTo(self)
	end

	drawNode = cc.DrawNode:create()
    drawNode:drawSegment(points[1], points[2], radius, borderColor)
end

function MScrollLayer:changeViewRectToNodeSpaceIf()
	if self.viewRectIsNodeSpace then
		return
	end

	-- local nodePoint = self:convertToNodeSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
	local posX, posY = self:getPosition()
	local ws = self:convertToWorldSpace(cc.p(posX, posY))
	self.viewRect_.x = self.viewRect_.x + ws.x
	self.viewRect_.y = self.viewRect_.y + ws.y
	self.viewRectIsNodeSpace = true
end

function MScrollLayer:isShake(event)
	if math.abs(event.x - self.prevX_) < self.nShakeVal
		and math.abs(event.y - self.prevY_) < self.nShakeVal then
		return true
	end
end

function MScrollLayer:scaleToParent_()
	local parent
	local node = self
	local scale = {x = 1, y = 1}

	while true do
		scale.x = scale.x * node:getScaleX()
		scale.y = scale.y * node:getScaleY()
		parent = node:getParent()
		if not parent then
			break
		end
		node = parent
	end

	return scale
end

--[[--

加一个大小为viewRect的touch node

]]
function MScrollLayer:addTouchNode()
	local node

	if self.touchNode_ then
		node = self.touchNode_
	else
		node = MUI.MView.new()
		self.touchNode_ = node

		node:setLocalZOrder(MScrollLayer.TOUCH_ZORDER)

	    self:addView(node)
	end

	node:setContentSize(self.viewRect_.width, self.viewRect_.height)
	node:setPosition(self.viewRect_.x, self.viewRect_.y)

    return self
end

--[[--

scrollView的填充方法，可以自动把一个table里的node有序的填充到scrollview里。

~~~ lua

--填充100个相同大小的图片。
    local view =  cc.ui.MScrollLayer.new(
        {viewRect = cc.rect(100,100, 400, 400), direction = 2})
    self:addChild(view);

    local t = {}
    for i = 1, 100 do
        local png  = cc.ui.UIImage.new("GreenButton.png")
        t[#t+1] = png
        cc.ui.UILabel.new({text = i, size = 24, color = cc.c3b(100,100,100)})
            :align(display.CENTER, png:getContentSize().width/2, png:getContentSize().height/2)
            :addTo(png)
    end
    view:fill(t, {itemSize = (t[#t]):getContentSize()})
~~~

注意：参数nodes 是table结构，且一定要是{node1,node2,node3,...}不能是{a=node1,b=node2,c=node3,...}

@param nodes node集
@param params 参见fill函数头定义。  -- params = extend({ ...

]]

function MScrollLayer:fill(nodes,params)
  --参数的继承用法,把param2的参数增加覆盖到param1中。
  local extend = function(param1,param2)
    if not param2 then
      return param1
    end
    for k , v in pairs(param2) do
      param1[k] = param2[k]
    end
    return param1
  end

  local params = extend({
    --自动间距
    autoGap = true,
    --宽间距
    widthGap = 0,
    --高间距
    heightGap = 0,
    --自动行列
    autoTable = true,
    --行数目
    rowCount = 3,
    --列数目
    cellCount = 3,
    --填充项大小
    itemSize = cc.size(50 , 50)
  },params)

  if #nodes == 0 then
    return nil
  end

  --基本坐标工具方法
  local SIZE = function(node) return node:getContentSize() end
  local W = function(node) return node:getContentSize().width end
  local H = function(node) return node:getContentSize().height end
  local S_SIZE = function(node , w , h) return node:setContentSize(cc.size(w , h)) end
  local S_XY = function(node , x , y) node:setPosition(x,y) end
  local AX = function(node) return node:getAnchorPoint().x end
  local AY = function(node) return node:getAnchorPoint().y end

  --创建一个容器node
  local innerContainer = MUI.MView.new()
  --初始容器大小为视图大小
  S_SIZE(innerContainer , self:getViewRect().width , self:getViewRect().height)
  self:addScrollNode(innerContainer)
  S_XY(innerContainer , self.viewRect_.x , self.viewRect_.y)

  --如果是纵向布局
  if self.direction == MUI.MScrollLayer.DIRECTION_VERTICAL then

    --自动布局
    if params.autoTable then
      params.cellCount = math.floor(self.viewRect_.width / params.itemSize.width)
    end

    --自动间隔
    if params.autoGap then
      params.widthGap = (self.viewRect_.width - (params.cellCount * params.itemSize.width)) / (params.cellCount + 1)
      params.heightGap = params.widthGap
    end

    --填充量
    params.rowCount = math.ceil(#nodes / params.cellCount)
    --避免动态尺寸少于设计尺寸
    local v_h = (params.itemSize.height + params.heightGap) * params.rowCount + params.heightGap
    if v_h < self.viewRect_.height then v_h = self.viewRect_.height end
    S_SIZE(innerContainer , self.viewRect_.width , v_h)

    for i = 1 , #nodes do

      local n = nodes[i]
      local x = 0.0
      local y = 0.0

      --不管描点如何，总是有标准居中方式设置坐标。
      x = params.widthGap + math.floor((i - 1) % params.cellCount) * (params.widthGap + params.itemSize.width)
      y = H(innerContainer) - (math.floor((i - 1) / params.cellCount) + 1) * (params.heightGap + params.itemSize.height)
      x = x + W(n) * AX(n)
      y = y + H(n) * AY(n)

      S_XY(n , x ,y)
      n:addTo(innerContainer)

    end
    --如果是横向布局
    --  elseif(self.direction==cc.ui.MScrollLayer.DIRECTION_HORIZONTAL) then
  else
    if params.autoTable then
      params.rowCount = math.floor(self.viewRect_.height / params.itemSize.height)
    end

    if params.autoGap then
      params.heightGap = (self.viewRect_.height - (params.rowCount * params.itemSize.height)) / (params.rowCount + 1)
      params.widthGap = params.heightGap
    end

    params.cellCount = math.ceil(#nodes / params.rowCount)
    --避免动态尺寸少于设计尺寸。
    local v_w = (params.itemSize.width + params.widthGap) * params.cellCount + params.widthGap
    if v_w < self.viewRect_.width then v_h = self.viewRect_.width end
    S_SIZE(innerContainer , v_w ,self.viewRect_.height)

    for i = 1, #nodes do

      local n = nodes[i]
      local x = 0.0
      local y = 0.0

      --不管描点如何，总是有标准居中方式设置坐标。
      x = params.widthGap +  math.floor((i - 1) / params.rowCount ) * (params.widthGap + params.itemSize.width)
      y = H(innerContainer) - (math.floor((i - 1) % params.rowCount ) +1 ) * (params.heightGap + params.itemSize.height)
      x = x + W(n) * AX(n)
      y = y + H(n) * AY(n)

      S_XY(n , x , y)
      n:addTo(innerContainer)

    end

  end

end

function MScrollLayer:createCloneInstance_()
    return MScrollLayer.new(unpack(self.args_))
end

function MScrollLayer:copyClonedWidgetChildren_(node)
	local scrollNode = node:getScrollNode()
	local cloneScrollNode = scrollNode:clone()
	self:addScrollNode(cloneScrollNode)
end

function MScrollLayer:copySpecialProperties_(node)
	self:setViewRect(node.viewRect_)
	self:setDirection(node:getDirection())
	self:setLayoutPadding(
		node.layoutPadding.top,
		node.layoutPadding.right,
		node.layoutPadding.bottom,
		node.layoutPadding.left)
	self:setBounceable(node.bBounce)
	self:setTouchType(node.touchOnContent)
end
-- 设置滚动惯性的速度
-- param1(type): 参数1说明
-- param2(type): 参数2说明
-- return(type): 返回值说明
function MScrollLayer:setSpeedScale( fScale )
	self.fSpeedScale = fScale
end
-- 重写addView的控制
function MScrollLayer:addView( _pChildView, _nZOrder, _nTag)
	if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
		_pChildView.m_listOrder = self:__getNewPosition()
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView, _nZOrder, _nTag)
		end
		self:__requestVertical(-_pChildView:getHeight())
	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
		_pChildView.m_listOrder = self:__getNewPosition()
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView, _nZOrder, _nTag)
		end
		self:__requestHorizontal(-_pChildView:getWidth())
	else
		self.__pScrollBothContentView = _pChildView
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView, _nZOrder, _nTag)
		end
	end
	-- 记录递增标识
	if(_pChildView) then
		self.m_upItemIndex = self.m_upItemIndex + 1
		_pChildView.__upItemIndex = self.m_upItemIndex
	end
end
-- 增加控件插入内容的方法
function MScrollLayer:insertView( _pChildView, _index )
	if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
		_pChildView.m_listOrder = self:__getNewPosition(_index)
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView)
		end
		self:__requestVertical(-_pChildView:getHeight())
	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
		_pChildView.m_listOrder = self:__getNewPosition(_index)
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView)
		end
		self:__requestHorizontal(-_pChildView:getWidth())
	else
		if(self.scrollNode) then
			self.scrollNode:addView(_pChildView)
		end
	end
	-- 记录递增标识
	if(_pChildView) then
		self.m_upItemIndex = self.m_upItemIndex + 1
		_pChildView.__upItemIndex = self.m_upItemIndex
	end

	--znftodo不知道为什么出错
	if self.checkIsShowArrow_ then
		self:checkIsShowArrow_()
	end
end
-- 移除一个子控件
function MScrollLayer:removeView( _params )
	local pView = nil
	if(type(_params) == "number") then
		local tHandleViews, fTotalWidth = self:__getShowViewsAndLong()
		if(_params > 0 and _params <= #tHandleViews) then
			pView = tHandleViews[_params]
		end
	else
		pView = _params
	end

	if(self.direction == MScrollLayer.DIRECTION_VERTICAL) then
		local nHeight = 0
		if(pView) then
			--记录高度
			nHeight = pView:getHeight()
			pView:removeSelf()
		end
		self:__requestVertical(nHeight)
	elseif(self.direction == MScrollLayer.DIRECTION_HORIZONTAL) then
		local nWidth = 0
		if(pView) then
			--记录高度
			nWidth = pView:getWidth()
			pView:removeSelf()
		end
		self:__requestHorizontal(nWidth)
	end

	--znftodo不知道为什么出错
	if self.checkIsShowArrow_ then
		self:checkIsShowArrow_()
	end
end

--根据位置获得一个子项
function MScrollLayer:getItemByPos( _pos )
	local pView = nil
	if(type(_pos) == "number") then
		local tHandleViews, fTotalWidth = self:__getShowViewsAndLong()
		if(_pos > 0 and _pos <= #tHandleViews) then
			pView = tHandleViews[_pos]
		end
	end
	return pView
end
-- 分帧加载控件
-- _count（number）：总共需要加载多少项
-- _everycallback（function）：每帧item的回调,带一个参数是下标值,返回创建好的view
-- _fTime（number）：分帧的时间间隔
function MScrollLayer:loadDataAsync( _count, _everycallback, _endcallback, _fTime )
	if(not _count or _count <= 0) then
		_endcallback()
		return
	end
	self:setItemCount(_count)
	self:setItemCallback(_everycallback)
	self:setEndCallback(_endcallback)
	self:setAsyncDisTime(_fTime)
	-- 执行分帧加载
	self:reload(true)
end
--------------------------------
-- 加载列表
-- @function [parent=#MScrollLayer] reload
-- @param _async boolean 是否使用分帧模式
-- @return MScrollLayer#MScrollLayer 
-- end --

function MScrollLayer:reload( _async )
	if(_async == nil) then
		_async = false
	end
	-- 执行实际的加载行为
	self:asyncLoad_(true, _async)

	return self
end
--------------------------------
-- 刷新列表数据
-- @function [parent=#MScrollLayer] notifyDataSetChange
-- @param boolean _bAsync：是否分帧刷新
-- @return MScrollLayerItem#MScrollLayerItem 

-- end --
function MScrollLayer:notifyDataSetChange( _bAsync )
	-- body
	if _bAsync == nil then
		_bAsync = true
	end
	-- 重新加载数据
	self:asyncLoad_(false, _bAsync)
end
-- 实际加载数据的回调方法
function MScrollLayer:asyncLoad_( _bNew, _async )
	if(not self.scrollNode) then
		print("MScrollLayer未设置容器节点")
		return
	end
	if(_bNew) then
		self.scrollNode:removeAllChildren()
	end
	local count = self:getItemCount()
	if(count <= 0) then
		return
	end
	-- 获取所有的控件
	local tHandleViews, nTotal = self:__getShowViewsAndLong()
	if(not _async) then
		if(_bNew) then
			for i=1, count, 1 do
				if(self.m_callbackItem) then
					-- 回调外部，让外部去执行增加和插入行为
					self.m_callbackItem(nil, i)
				end
			end
		else
			local tag = 0
			for i=1, #tHandleViews, 1 do
				if(self.m_callbackItem) then
					if(tHandleViews[i]) then
						tag = tHandleViews[i].__upItemIndex
					else
						tag = i
					end
					-- 回调外部，让外部去执行增加和插入行为
					self.m_callbackItem(tHandleViews[i], tag)
				end
			end
		end
		-- 执行结束回调
		if(self.m_callbackEnd) then
			self.m_callbackEnd()
		end
		--znftodo不知道为什么出错
		if self.checkIsShowArrow_ then
			self:checkIsShowArrow_()
		end
	else
		if(_bNew) then
			-- 分帧执行刷新
			gRefreshViewsAsync(self, count, function ( _bEnd, _index )
				if(_bEnd) then
					-- 执行结束回调
					if(self.m_callbackEnd) then
						self.m_callbackEnd()
					end
					--znftodo不知道为什么出错
					if self.checkIsShowArrow_ then
						self:checkIsShowArrow_()
					end
				else
					if(self.m_callbackItem) then
						self.m_callbackItem(nil, _index)
					end
				end
			end, self.m_fAsyncTime or 2)
		else
			local tag = 0
			-- 分帧执行刷新
			gRefreshViewsAsync(self, #tHandleViews, function ( _bEnd, _index )
				if(_bEnd) then
					-- 执行结束回调
					if(self.m_callbackEnd) then
						self.m_callbackEnd()
					end
					--znftodo不知道为什么出错
					if self.checkIsShowArrow_ then
						self:checkIsShowArrow_()
					end
				else
					if(self.m_callbackItem) then
						tag = _index
						local pView = tHandleViews[_index]
						if(pView) then
							tag = pView.__upItemIndex
						end
						self.m_callbackItem(pView, tag)
					end
				end
			end, self.m_fAsyncTime or 2)
		end
	end
end
-- 设置获取单项的接口
function MScrollLayer:setItemCallback( _callback )
	self.m_callbackItem = _callback
end
-- 设置初始化结束的回调接口
function MScrollLayer:setEndCallback( _callback )
	self.m_callbackEnd = _callback
end
-- 设置多少帧回调一次
-- _nTime（number）：多少帧回调一次
function MScrollLayer:setAsyncDisTime( _nTime )
	self.m_fAsyncTime = _nTime or 2
end
-- 设置列表item的总个数
-- _count（int）：总个数
function MScrollLayer:setItemCount( _count )
	self.m_nItemCount = _count
end
-- 获取item的总个数
-- return（int）：item的个数
function MScrollLayer:getItemCount(  )
	return self.m_nItemCount
end
-- 获取列表可视化的下标
-- return(int, int): 起始下标和结束下标
function MScrollLayer:getVisibleIndexes(  )
	local tViews, fTotal = self:__getShowViewsAndLong()
	local nStart, nEnd = nil, nil
	if(tViews) then
		for i, v in pairs(tViews) do
			local bVis = self:isItemInViewRect(v)
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


function MScrollLayer:requestLayout()
    MScrollLayer.super.requestLayout(self)

    if self.pUpArrow and self.pDownArrow then
        local pSize = self:getContentSize()
        local nX = pSize.width/2

        local nY = pSize.height - self.pUpArrow:getContentSize().height/2 - 10
        self.pUpArrow:setPosition(nX, nY)
        self.pUpArrow:setVisible(false)

        local nY = self.pDownArrow:getContentSize().height/2 + 10
        self.pDownArrow:setPosition(nX, nY)
        self.pDownArrow:setVisible(false)
    end
end

--设置上下箭头
--pUpArrow上箭头
--pDownArrow左箭头
--bIsAdded 是否已加入了节点
function MScrollLayer:setUpAndDownArrow( pUpArrow, pDownArrow, bIsAdded)
	self.pUpArrow = pUpArrow
	self.pDownArrow = pDownArrow
	if not bIsAdded then
		self:addChild(self.pDownArrow, 999)
		self:addChild(self.pUpArrow, 999)

        local pSize = self:getContentSize()
        local nX = pSize.width/2

        local nY = pSize.height - pUpArrow:getContentSize().height/2 - 10
        pUpArrow:setPosition(nX, nY)
        pUpArrow:setVisible(false)

        local nY = pDownArrow:getContentSize().height/2 + 10
        pDownArrow:setPosition(nX, nY)
        pDownArrow:setVisible(false)
        self.bIsOpenCheckArrow = true
	end
end

function MScrollLayer:setLeftAndRightArrow( pLeftArrow, pRightArrow, bIsAdded)
	self.pLeftArrow = pLeftArrow
	self.pRightArrow = pRightArrow
	if not bIsAdded then
		self:addChild(self.pLeftArrow, 999)
		self:addChild(self.pRightArrow, 999)

        local pSize = self:getContentSize()
        local nY = pSize.height/2

        local nX = pLeftArrow:getContentSize().width/2 - 20
        pLeftArrow:setPosition(nX, nY)
        pLeftArrow:setVisible(false)

        local nX = pSize.width - pRightArrow:getContentSize().width/2 + 20
        pRightArrow:setPosition(nX, nY)
        pRightArrow:setVisible(false)
        self.bIsOpenCheckArrow = true
	end
end

-- 上下箭头检测
function MScrollLayer:checkIsShowArrow_( event )
	if not self.bIsOpenCheckArrow then
		return
	end

	if event then
        if event.name == "scrollEnd" then
	        local pScrollView = self:getScrollNode()
	        if pScrollView then
		        local pScrollSize = pScrollView:getContentSize()
		        local pSize = self:getContentSize()
		        if (event.originY + pScrollSize.height) > pSize.height then
		            self.pUpArrow:setVisible(true)
		        else
		            self.pUpArrow:setVisible(false)
		        end

		        if event.originY < 0 then
		            self.pDownArrow:setVisible(true)
		        else
		            self.pDownArrow:setVisible(false)
		        end
		    end
	    end
	else
    	local pScrollView = self:getScrollNode()
    	if pScrollView then
	    	local pScrollSize = pScrollView:getContentSize()
	    	local nOriginX, nOriginY = pScrollView:getPosition()
	        local pSize = self:getContentSize()
	        if (nOriginY + pScrollSize.height) > pSize.height then
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



return MScrollLayer