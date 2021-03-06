------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:13:51
-- @Description: 布局类型，对齐方式的定义，包括权重和层级
------------------------------

--------------------------------
-- @module MBoxLayout


local MLayout = import(".MLayout")
local MBoxLayout = myclass("MBoxLayout", MLayout)

-- start --

--------------------------------
-- MBoxLayout的构造函数
-- @function [parent=#cc.MBoxLayout] new
-- @param integer direction 布局方向
-- @param string name 布局名字
-- @return MBoxLayout#MBoxLayout  结果

-- end --

function MBoxLayout:ctor(direction, name)
    MBoxLayout.super.ctor(self, name)
    self.direction_ = direction or display.LEFT_TO_RIGHT
end

-- start --

--------------------------------
-- 返回方向
-- @function [parent=#cc.MBoxLayout] new
-- @return integer#integer 布局方向

-- end --

function MBoxLayout:getDirection()
    return self.direction_
end

-- start --

--------------------------------
-- 设置方向
-- @function [parent=#cc.MBoxLayout] new
-- @param integer direction 方向
-- @return MBoxLayout#MBoxLayout 布局方向

-- end --

function MBoxLayout:setDirection(direction)
    self.direction_ = direction
    return self
end

local depth_ = 0

-- start --

--------------------------------
-- 应用布局
-- @function [parent=#MBoxLayout] apply
-- @param node container 要布局到的node,为空就布局到自身

-- end --

function MBoxLayout:apply(container)
    if table.nums(self.widgets_) == 0 then return end
    if not container then container = self end

    if DEBUG > 1 then
        local prefix = string.rep("  ", depth_)
        printInfo("%sAPPLY LAYOUT %s", prefix, self:getName())
    end

    -- step 1
    -- 1. calculate total weight for all widgets
    -- 2. calculate total fixed size
    -- 3. calculate max widget size
    local isHBox = self.direction_ == display.LEFT_TO_RIGHT or self.direction_ == display.RIGHT_TO_LEFT
    local totalWeightH, totalWeightV = 0, 0
    local fixedWidth, fixedHeight = 0, 0
    local maxWidth, maxHeight = 0, 0
    local widgets = {}
    for widget, v in pairs(self.widgets_) do
        local item = {widget = widget, weight = v.weight, order = v.order}
        local widgetSizeWidth, widgetSizeHeight = widget:getLayoutSize()
        local widgetSizePolicyH, widgetSizePolicyV = widget:getLayoutSizePolicy()
        local marginTop, marginRight, marginBottom, marginLeft = widget:getLayoutMargin()

        if widgetSizePolicyH == display.FIXED_SIZE then
            fixedWidth = fixedWidth + widgetSizeWidth + marginLeft + marginRight
            item.width = widgetSizeWidth
        else
            totalWeightH = totalWeightH + v.weight
        end

        if widgetSizePolicyV == display.FIXED_SIZE then
            fixedHeight = fixedHeight + widgetSizeHeight
            item.height = widgetSizeHeight
        else
            totalWeightV = totalWeightV + v.weight
        end

        if widgetSizeWidth > maxWidth then
            maxWidth = widgetSizeWidth
        end
        if widgetSizeHeight > maxHeight then
            maxHeight = widgetSizeHeight
        end

        widgets[#widgets + 1] = item
    end

    -- sort all widgets by order
    table.sort(widgets, function(a, b)
        return a.order < b.order
    end)

    -- step 2
    local containerLayoutSizeWidth, containerLayoutSizeHeight = container:getLayoutSize()
    local containerPaddingTop, containerPaddingRight, containerPaddingBottom, containerPaddingLeft = container:getLayoutPadding()
    containerLayoutSizeWidth = containerLayoutSizeWidth - containerPaddingLeft - containerPaddingRight
    containerLayoutSizeHeight = containerLayoutSizeHeight - containerPaddingTop - containerPaddingBottom

    if isHBox then
        maxHeight = containerLayoutSizeHeight
    else
        maxWidth = containerLayoutSizeWidth
    end

    local x, y, negativeX, negativeY
    local left = containerPaddingLeft
    local top = containerLayoutSizeHeight + containerPaddingBottom
    local right = containerLayoutSizeWidth + containerPaddingLeft
    local bottom = containerPaddingBottom
    if self.direction_ == display.LEFT_TO_RIGHT then
        x = left
        y = bottom
        negativeX, negativeY = 1, 0
    elseif self.direction_ == display.RIGHT_TO_LEFT then
        x = right
        y = bottom
        negativeX, negativeY = -1, 0
    elseif self.direction_ == display.TOP_TO_BOTTOM then
        x = left
        y = top
        negativeX, negativeY = 0, -1
    elseif self.direction_ == display.BOTTOM_TO_TOP then
        x = left
        y = bottom
        negativeX, negativeY = 0, 1
    else
        printError("MBoxLayout:apply() - invalid direction %s", tostring(self.direction_))
        return
    end

    if iskindof(container, "MLayout") then
        local cx, cy = container:getPosition()
        x = x + cx
        y = y + cy
    end

    -- step 3
    local containerWidth = containerLayoutSizeWidth - fixedWidth
    local remainingWidth = containerWidth
    local containerHeight = containerLayoutSizeHeight - fixedHeight
    local remainingHeight = containerHeight
    local count = #widgets
    local lastWidth, lastHeight = 0, 0
    local actualSize = {}
    for index, item in ipairs(widgets) do
        local width, height

        if isHBox then
            if item.width then
                width = item.width
            else
                if index ~= count then
                    width = item.weight / totalWeightH * containerWidth
                else
                    width = remainingWidth
                end
                remainingWidth = remainingWidth - width
            end
            if index == count then lastWidth = width end
            height = item.height or maxHeight
        else
            if item.height then
                height = item.height
            else
                if index ~= count then
                    height = item.weight / totalWeightV * containerHeight
                else
                    height = remainingHeight
                end
                remainingHeight = remainingHeight - height
            end
            if index == count then lastHeight = height end
            width = item.width or maxWidth
        end

        local actualWidth, actualHeight
        local widget = item.widget
        local marginTop, marginRight, marginBottom, marginLeft = widget:getLayoutMargin()
        if item.width then
            width = width + marginLeft + marginRight
        end
        actualWidth = width - marginLeft - marginRight
        if item.height then
            actualHeight = height + marginTop + marginBottom
        else
            actualHeight = height - marginTop - marginBottom
        end

        local wx = x + marginLeft
        if self.direction_ == display.RIGHT_TO_LEFT then
            wx = x - marginRight
        end
        local wy = y + marginBottom
        if self.direction_ == display.TOP_TO_BOTTOM then
            wy = y - marginTop
        end

        local widgetAnchorPoint = widget:getAnchorPoint()
        if isHBox then
            wx = wx + actualWidth * widgetAnchorPoint.x
            wy = wy + maxHeight * widgetAnchorPoint.y
        else
            wx = wx + maxWidth * widgetAnchorPoint.x
            wy = wy + actualHeight * widgetAnchorPoint.y
        end

        widget:setPosition(wx, wy)
        depth_ = depth_ + 1
        widget:setLayoutSize(actualWidth, actualHeight)
        depth_ = depth_ - 1
        actualSize[#actualSize + 1] = {width = actualWidth, height = actualHeight}

        if isHBox then
            x = x + width * negativeX
        else
            y = y + height * negativeY
        end
    end

    if self.direction_ == display.TOP_TO_BOTTOM then
        for index, item in ipairs(widgets) do
            local widget = item.widget
            widget:setPositionY(widget:getPositionY() - actualSize[index].height)
        end
    elseif self.direction_ == display.RIGHT_TO_LEFT then
        for index, item in ipairs(widgets) do
            local widget = item.widget
            widget:setPositionX(widget:getPositionX() - actualSize[index].width)
        end
    end

    depth_ = depth_ + 1
    for index, item in ipairs(widgets) do
        local widget = item.widget
        if iskindof(widget, "MLayout") then
            widget:apply()
        end
    end
    depth_ = depth_ - 1
end

return MBoxLayout
