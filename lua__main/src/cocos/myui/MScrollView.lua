----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 20:26:04 
-- Description: 自定义滚动列表
-----------------------------------------------------

--------------------------------
-- @module MScrollView

local MView = import(".MView")

local MScrollView = myclass("MScrollView", function()
	return MView.new(MUI.VIEW_TYPE.scrollview)
end)

MScrollView.BG_ZORDER 				= -100
MScrollView.TOUCH_ZORDER 			= -99
MScrollView.SCROLLNODE_ZODER    	= -88

MScrollView.DIRECTION_BOTH			= 0
MScrollView.DIRECTION_VERTICAL		= 1
MScrollView.DIRECTION_HORIZONTAL	= 2

-- start --

--------------------------------
-- 滚动控件的构建函数
-- @function [parent=#MScrollView] new
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

function MScrollView:ctor(params)
	self.bBounce = true
	self.nShakeVal = 5
	self.direction = MScrollView.DIRECTION_BOTH
	self.layoutPadding = {left = 0, right = 0, top = 0, bottom = 0}
	self.speed = {x = 0, y = 0}
	self.fSpeedScale = 1 -- 滚动速度的倍数

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
		self.sbH = display.newScale9Sprite(params.scrollbarImgH, 100):addTo(self)
	end
	if params.scrollbarImgV then
		self.sbV = display.newScale9Sprite(params.scrollbarImgV, 100):addTo(self)
	end

	-- touchOnContent true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
	-- 当内容小于显示区域时，两者就有区别了
	self:setTouchType(params.touchOnContent or true)

	self:addBgColorIf(params)
	self:addBgGradientColorIf(params)
	self:addBgIf(params)

	-- 暂时取消
	self:onNodeEvent("enter", function(...)
			self:update_(...)
		end)
	self:scheduleUpdate(handler(self, self.update_))

	self.args_ = {params}
end

function MScrollView:addBgColorIf(params)
	if not params.bgColor then
		return
	end

	-- display.newColorLayer(params.bgColor)
	cc.LayerColor:create(params.bgColor)
		:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x, params.viewRect.y)
		:addTo(self, MScrollView.BG_ZORDER)
		:setTouchEnabled(false)
end

function MScrollView:addBgGradientColorIf(params)
	if not params.bgStartColor or not params.bgEndColor then
		return
	end

	local layer = cc.LayerGradient:create(params.bgStartColor, params.bgEndColor)
		:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x, params.viewRect.y)
		:addTo(self, MScrollView.BG_ZORDER)
		:setTouchEnabled(false)
	layer:setVector(params.bgVector)
end

function MScrollView:addBgIf(params)
	if not params.bg then
		return
	end

	local bg
	if params.bgScale9 then
		bg = display.newScale9Sprite(params.bg, nil, nil, nil, params.capInsets)
	else
		bg = display.newSprite(params.bg)
	end

	bg:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x + params.viewRect.width/2,
			params.viewRect.y + params.viewRect.height/2)
		:addTo(self, MScrollView.BG_ZORDER)
		:setTouchEnabled(false)
end

function MScrollView:setViewRect(rect)
	-- 暂时取消裁剪行为
	-- self:setClippingRegion(rect)
	self.viewRect_ = rect
	self.viewRectIsNodeSpace = false

	return self
end

-- start --

--------------------------------
-- 得到滚动控件的显示区域
-- @function [parent=#MScrollView] getViewRect
-- @return Rect#Rect 

-- end --

function MScrollView:getViewRect()
	return self.viewRect_
end
--- 获取控件大小
-- return(float, float): 控件宽度，控件高度
-- function MScrollView:getLayoutSize( )
-- 	return self.:getViewRect().width, self:getViewRect().height
-- end

-- start --

--------------------------------
-- 设置布局四周的空白
-- @function [parent=#MScrollView] setLayoutPadding
-- @param number top 上边的空白
-- @param number right 右边的空白
-- @param number bottom 下边的空白
-- @param number left 左边的空白
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:setLayoutPadding(top, right, bottom, left)
	if not self.layoutPadding then
		self.layoutPadding = {}
	end
	self.layoutPadding.top = top
	self.layoutPadding.right = right
	self.layoutPadding.bottom = bottom
	self.layoutPadding.left = left

	return self
end

function MScrollView:setActualRect(rect)
	self.actualRect_ = rect
end

-- start --

--------------------------------
-- 设置滚动方向
-- @function [parent=#MScrollView] setDirection
-- @param number dir 滚动方向
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:setDirection(dir)
	self.direction = dir

	return self
end

-- start --

--------------------------------
-- 获取滚动方向
-- @function [parent=#MScrollView] getDirection
-- @return number#number 

-- end --

function MScrollView:getDirection()
	return self.direction
end

-- start --

--------------------------------
-- 设置滚动控件是否开启回弹功能
-- @function [parent=#MScrollView] setBounceable
-- @param boolean bBounceable 是否开启回弹
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:setBounceable(bBounceable)
	self.bBounce = bBounceable

	return self
end

-- start --

--------------------------------
-- 设置触摸响应方式
-- true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
-- 内容大于显示区域时，两者无差别
-- 内容小于显示区域时，true:在空白区域触摸无效,false:在空白区域触摸也可滚动内容
-- @function [parent=#MScrollView] setTouchType
-- @param boolean bTouchOnContent 是否触控到滚动内容上才有效
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:setTouchType(bTouchOnContent)
	self.touchOnContent = bTouchOnContent

	return self
end

--[[--

重置位置,主要用在纵向滚动时

]]
function MScrollView:resetPosition()
	if MScrollView.DIRECTION_VERTICAL ~= self.direction then
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
-- @function [parent=#MScrollView] isItemInViewRect
-- @param node item scrollView中的项
-- @return boolean#boolean 

-- end --

function MScrollView:isItemInViewRect(item)
	if "userdata" ~= type(item) then
		item = nil
	end

	if not item then
		print("MScrollView - isItemInViewRect item is not right")
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
-- @function [parent=#MScrollView] setTouchEnabled
-- @param boolean bEnabled 是否开启触摸
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:setTouchEnabled(bEnabled)
	if not self.scrollNode then
		return
	end
	self.scrollNode:setTouchEnabled(bEnabled)

	return self
end

-- start --

--------------------------------
-- 将要显示的node加到scrollview中,scrollView只支持滚动一个node
-- @function [parent=#MScrollView] addScrollNode
-- @param node node 要显示的项
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:addScrollNode(node)
	self:addChild(node, MScrollView.SCROLLNODE_ZODER)
	self.scrollNode = node

	if not self.viewRect_ then
		self.viewRect_ = self.scrollNode:getCascadeBoundingBox()
		self:setViewRect(self.viewRect_)
	end
	node:setTouchSwallowEnabled(false)
	node:setTouchEnabled(true)

	node:enableNodeEvents()
	node:onNodeEvent("ddd", function ( )
		
	end)
    -- node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
    --     return self:onTouchCapture_(event)
    -- end)
	self:addTouchNode()

    return self
end

-- start --

--------------------------------
-- 返回scrollView中的滚动node
-- @function [parent=#MScrollView] getScrollNode
-- @return node#node  滚动node

-- end --

function MScrollView:getScrollNode()
	return self.scrollNode
end

-- start --

--------------------------------
-- 注册滚动控件的监听函数
-- @function [parent=#MScrollView] onScroll
-- @param function listener 监听函数
-- @return MScrollView#MScrollView 

-- end --

function MScrollView:onScroll(listener)
	self.scrollListener_ = listener

    return self
end

-- private

function MScrollView:calcLayoutPadding()
	local boundBox = self.scrollNode:getCascadeBoundingBox()

	self.layoutPadding.left = boundBox.x - self.actualRect_.x
	self.layoutPadding.right =
		self.actualRect_.x + self.actualRect_.width - boundBox.x - boundBox.width
	self.layoutPadding.top = boundBox.y - self.actualRect_.y
	self.layoutPadding.bottom =
		self.actualRect_.y + self.actualRect_.height - boundBox.y - boundBox.height
end

function MScrollView:update_(dt)
	self:drawScrollBar()
end

function MScrollView:onTouchCapture_(event)
	if ("began" == event.name or "moved" == event.name or "ended" == event.name)
		and self:isTouchInViewRect(event) then
		return true
	else
		return false
	end
end

function MScrollView:onTouch_(event)
	if "began" == event.name and not self:isTouchInViewRect(event) then
		printInfo("MScrollView - touch didn't in viewRect")
		return false
	end

	if "began" == event.name and self.touchOnContent then
		local cascadeBound = self.scrollNode:getCascadeBoundingBox()
		if not cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y)) then
			return false
		end
	end

	if "began" == event.name then
		self.prevX_ = event.x
		self.prevY_ = event.y
		self.bDrag_ = false
		local x,y = self.scrollNode:getPosition()
		self.position_ = {x = x, y = y}

		transition.stopTarget(self.scrollNode)
		self:callListener_{name = "began", x = event.x, y = event.y}

		self:enableScrollBar()
		-- self:changeViewRectToNodeSpaceIf()

		self.scaleToWorldSpace_ = self:scaleToParent_()

		return true
	elseif "moved" == event.name then
		if self:isShake(event) then
			return
		end

		self.bDrag_ = true
		self.speed.x = event.x - event.prevX
		self.speed.y = event.y - event.prevY

		if self.direction == MScrollView.DIRECTION_VERTICAL then
			self.speed.x = 0
		elseif self.direction == MScrollView.DIRECTION_HORIZONTAL then
			self.speed.y = 0
		else
			-- do nothing
		end

		self:scrollBy(self.speed.x, self.speed.y)
		self:callListener_{name = "moved", x = event.x, y = event.y}
	elseif "ended" == event.name then
		if self.bDrag_ then
			self.bDrag_ = false
			self:scrollAuto()

			self:callListener_{name = "ended", x = event.x, y = event.y}

			self:disableScrollBar()
		else
			self:callListener_{name = "clicked", x = event.x, y = event.y}
		end
	end
end

function MScrollView:isTouchInViewRect(event)
	-- dump(self.viewRect_, "viewRect:")
	local viewRect = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
	viewRect.width = self.viewRect_.width
	viewRect.height = self.viewRect_.height
	-- dump(viewRect, "new viewRect:")

	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function MScrollView:isTouchInScrollNode(event)
	local cascadeBound = self:getScrollNodeRect()
	return cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y))
end

function MScrollView:scrollTo(p, y)
	local x_, y_
	if "table" == type(p) then
		x_ = p.x or 0
		y_ = p.y or 0
	else
		x_ = p
		y_ = y
	end

	self.position_ = cc.p(x_, y_)
	self.scrollNode:setPosition(self.position_)
end

function MScrollView:moveXY(orgX, orgY, speedX, speedY)
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

function MScrollView:scrollBy(x, y)
	self.position_.x, self.position_.y = self:moveXY(self.position_.x, self.position_.y, x, y)
	-- self.position_.x = self.position_.x + x
	-- self.position_.y = self.position_.y + y
	self.scrollNode:setPosition(self.position_)

	if self.actualRect_ then
		self.actualRect_.x = self.actualRect_.x + x
		self.actualRect_.y = self.actualRect_.y + y
	end
end

function MScrollView:scrollAuto()
	if self:twiningScroll() then
		return
	end
	self:elasticScroll()
end

-- fast drag
function MScrollView:twiningScroll()
	if self:isSideShow() then
		-- printInfo("MScrollView - side is show, so elastic scroll")
		return false
	end

	if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
		-- printInfo("#DEBUG, MScrollView - isn't twinking scroll:"
		-- 	.. self.speed.x .. " " .. self.speed.y)
		return false
	end

	local disX, disY = self:moveXY(0, 0, self.speed.x*6*self.fSpeedScale, 
		self.speed.y*6*self.fSpeedScale)

	transition.moveBy(self.scrollNode,
		{x = disX, y = disY, time = 0.3,
		easing = "sineOut",
		onComplete = function()
			self:elasticScroll()
		end})
end

function MScrollView:elasticScroll()
	local cascadeBound = self:getScrollNodeRect()
	local disX, disY = 0, 0
	local viewRect = self:getViewRect() -- InWorldSpace()
	local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))

	cascadeBound.x = t.x
	cascadeBound.y = t.y
	self.scaleToWorldSpace_ = self.scaleToWorldSpace_ or {x=1,y=1}
	cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
	cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y

	-- dump(self.scaleToWorldSpace_, "MScrollView - scaleToWorldSpace_:")
	-- dump(cascadeBound, "MScrollView - cascBoundingBox:")
	-- dump(viewRect, "MScrollView - viewRect:")

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
		return
	end

	transition.moveBy(self.scrollNode,
		{x = disX, y = disY, time = 0.3,
		easing = "backout",
		onComplete = function()
			self:callListener_{name = "scrollEnd"}
		end})
end

function MScrollView:getScrollNodeRect()
	local bound = self.scrollNode:getCascadeBoundingBox()
	-- bound.x = bound.x - self.layoutPadding.left
	-- bound.y = bound.y - self.layoutPadding.bottom
	-- bound.width = bound.width + self.layoutPadding.left + self.layoutPadding.right
	-- bound.height = bound.height + self.layoutPadding.bottom + self.layoutPadding.top

	return bound
end

function MScrollView:getViewRectInWorldSpace()
	local rect = self:convertToWorldSpace(
		cc.p(self.viewRect_.x, self.viewRect_.y))
	rect.width = self.viewRect_.width
	rect.height = self.viewRect_.height

	return rect
end

-- 是否显示到边缘
function MScrollView:isSideShow()
	local bound = self.scrollNode:getCascadeBoundingBox()
    local localPos = self:convertToNodeSpace(cc.p(bound.x, bound.y))
    local verticalSideShow = (localPos.y > self.viewRect_.y) 
                           or (localPos.y + bound.height < self.viewRect_.y + self.viewRect_.height)
    local horizontalSideShow = (localPos.x > self.viewRect_.x)
                             or (localPos.x + bound.width < self.viewRect_.x + self.viewRect_.width)
    if MScrollView.DIRECTION_VERTICAL == self.direction then
        return verticalSideShow
    elseif MScrollView.DIRECTION_HORIZONTAL == self.direction then
        return horizontalSideShow
    else
        return (verticalSideShow or horizontalSideShow)
    end

	return false
end

function MScrollView:callListener_(event)
	if not self.scrollListener_ then
		return
	end
	event.scrollView = self

	self.scrollListener_(event)
end

function MScrollView:enableScrollBar()
	local bound = self.scrollNode:getCascadeBoundingBox()
	if self.sbV then
		self.sbV:setVisible(false)
		transition.stopTarget(self.sbV)
		self.sbV:setOpacity(128)
		local size = self.sbV:getContentSize()
		if self.viewRect_.height < bound.height then
			local barH = self.viewRect_.height*self.viewRect_.height/bound.height
			if barH < size.width then
				-- 保证bar不会太小
				barH = size.width
			end
			self.sbV:setContentSize(size.width, barH)
			self.sbV:setPosition(
				self.viewRect_.x + self.viewRect_.width - size.width/2, self.viewRect_.y + barH/2)
		end
	end
	if self.sbH then
		self.sbH:setVisible(false)
		transition.stopTarget(self.sbH)
		self.sbH:setOpacity(128)
		local size = self.sbH:getContentSize()
		if self.viewRect_.width < bound.width then
			local barW = self.viewRect_.width*self.viewRect_.width/bound.width
			if barW < size.height then
				barW = size.height
			end
			self.sbH:setContentSize(barW, size.height)
			self.sbH:setPosition(self.viewRect_.x + barW/2,
				self.viewRect_.y + size.height/2)
		end
	end
end

function MScrollView:disableScrollBar()
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

function MScrollView:drawScrollBar()
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

function MScrollView:addScrollBarIf()

	if not self.sb then
		self.sb = cc.DrawNode:create():addTo(self)
	end

	drawNode = cc.DrawNode:create()
    drawNode:drawSegment(points[1], points[2], radius, borderColor)
end

function MScrollView:changeViewRectToNodeSpaceIf()
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

function MScrollView:isShake(event)
	if math.abs(event.x - self.prevX_) < self.nShakeVal
		and math.abs(event.y - self.prevY_) < self.nShakeVal then
		return true
	end
end

function MScrollView:scaleToParent_()
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
function MScrollView:addTouchNode()
	local node

	if self.touchNode_ then
		node = self.touchNode_
	else
		node = display.newNode()
		self.touchNode_ = node

		node:setLocalZOrder(MScrollView.TOUCH_ZORDER)
		node:setTouchSwallowEnabled(true)
		node:setTouchEnabled(true)
		-- 暂时取消
		-- node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
	 --        return self:onTouch_(event)
	 --    end)

	    self:addChild(node)
	end

	node:setContentSize(self.viewRect_.width, self.viewRect_.height)
	node:setPosition(self.viewRect_.x, self.viewRect_.y)

    return self
end

--[[--

scrollView的填充方法，可以自动把一个table里的node有序的填充到scrollview里。

~~~ lua

--填充100个相同大小的图片。
    local view =  cc.ui.MScrollView.new(
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

function MScrollView:fill(nodes,params)
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
  local innerContainer = display.newNode()
  --初始容器大小为视图大小
  S_SIZE(innerContainer , self:getViewRect().width , self:getViewRect().height)
  self:addScrollNode(innerContainer)
  S_XY(innerContainer , self.viewRect_.x , self.viewRect_.y)

  --如果是纵向布局
  if self.direction == MUI.MScrollView.DIRECTION_VERTICAL then

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
    --  elseif(self.direction==cc.ui.MScrollView.DIRECTION_HORIZONTAL) then
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

function MScrollView:createCloneInstance_()
    return MScrollView.new(unpack(self.args_))
end

function MScrollView:copyClonedWidgetChildren_(node)
	local scrollNode = node:getScrollNode()
	local cloneScrollNode = scrollNode:clone()
	self:addScrollNode(cloneScrollNode)
end

function MScrollView:copySpecialProperties_(node)
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
function MScrollView:setSpeedScale( fScale )
	self.fSpeedScale = fScale
end

return MScrollView
