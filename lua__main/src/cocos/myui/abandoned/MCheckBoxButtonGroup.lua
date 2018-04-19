----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 20:19:26 
-- Description: 自定义复选框组合控件
-----------------------------------------------------

--------------------------------
-- @module MCheckBoxButtonGroup

local MBoxLayout = import(".MBoxLayout")
local MCheckBoxButton = import("cocos.myui.MCheckBoxButton")

local MGroup = import(".MGroup")
local MCheckBoxButtonGroup = myclass("MCheckBoxButtonGroup", MGroup)

MCheckBoxButtonGroup.BUTTON_SELECT_CHANGED = "BUTTON_SELECT_CHANGED"

-- start --

--------------------------------
-- MCheckBoxButtonGroup构建函数
-- @function [parent=#MCheckBoxButtonGroup] new
-- @param integer direction checkBox排列方向

-- end --

function MCheckBoxButtonGroup:ctor(direction)
    MCheckBoxButtonGroup.super.ctor(self)
    self.buttons_ = {}
    self.currentSelectedIndex_ = 0

    self.args_ = {direction}
end

-- start --

--------------------------------
-- 加入一个checkBox
-- @function [parent=#MCheckBoxButtonGroup] addButton
-- @param MCheckBoxButton button checkBox
-- @return MCheckBoxButtonGroup#MCheckBoxButtonGroup  自身
-- @see MCheckBoxButton

-- end --

function MCheckBoxButtonGroup:addButton(button)
    self:addChild(button)
    self.buttons_[#self.buttons_ + 1] = button
    self:getLayout():addWidget(button):apply(self)
    button:onButtonClicked(handler(self, self.onButtonStateChanged_))
    button:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    return self
end

-- start --

--------------------------------
-- 按index移除掉一个checkBox
-- @function [parent=#MCheckBoxButtonGroup] removeButtonAtIndex
-- @param integer index 要移除checkBox的位置
-- @return MCheckBoxButtonGroup#MCheckBoxButtonGroup  自身

-- end --

function MCheckBoxButtonGroup:removeButtonAtIndex(index)
    assert(self.buttons_[index] ~= nil, "MCheckBoxButtonGroup:removeButtonAtIndex() - invalid index")

    local button = self.buttons_[index]
    local layout = self:getLayout()
    layout:removeWidget(button)
    layout:apply(self)

    button:removeFromParent()
    table.remove(self.buttons_, index)

    if self.currentSelectedIndex_ == index then
        self:updateButtonState_(nil)
    elseif index < self.currentSelectedIndex_ then
        self:updateButtonState_(self.buttons_[self.currentSelectedIndex_ - 1])
    end

    return self
end

-- start --

--------------------------------
-- 按index获取checkBox
-- @function [parent=#MCheckBoxButtonGroup] getButtonAtIndex
-- @param integer index 要获取checkBox的位置
-- @return MCheckBoxButton#MCheckBoxButton 

-- end --

function MCheckBoxButtonGroup:getButtonAtIndex(index)
    return self.buttons_[index]
end

-- start --

--------------------------------
-- 得到UICheckBoxButton的总数
-- @function [parent=#MCheckBoxButtonGroup] getButtonsCount
-- @return integer#integer 

-- end --

function MCheckBoxButtonGroup:getButtonsCount()
    return #self.buttons_
end

-- start --

--------------------------------
-- 设置margin
-- @function [parent=#MCheckBoxButtonGroup] setButtonsLayoutMargin
-- @param number top 上边的空白
-- @param number right 右边的空白
-- @param number bottom 下边的空白
-- @param number left 左边的空白
-- @return MCheckBoxButtonGroup#MCheckBoxButtonGroup  自身

-- end --

function MCheckBoxButtonGroup:setButtonsLayoutMargin(top, right, bottom, left)
    for _, button in ipairs(self.buttons_) do
        button:setLayoutMargin(top, right, bottom, left)
    end
    self:getLayout():apply(self)
    return self
end

function MCheckBoxButtonGroup:addButtonSelectChangedEventListener(callback)
    return self:addEventListener(MCheckBoxButtonGroup.BUTTON_SELECT_CHANGED, callback)
end

-- start --

--------------------------------
-- 注册checkbox状态变化listener
-- @function [parent=#MCheckBoxButtonGroup] onButtonSelectChanged
-- @param function callback
-- @return MCheckBoxButtonGroup#MCheckBoxButtonGroup  自身

-- end --

function MCheckBoxButtonGroup:onButtonSelectChanged(callback)
    self:addButtonSelectChangedEventListener(callback)
    return self
end

function MCheckBoxButtonGroup:onButtonStateChanged_(event)
    if event.name == MCheckBoxButton.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end
    self:updateButtonState_(event.target)
end

function MCheckBoxButtonGroup:updateButtonState_(clickedButton)
    local currentSelectedIndex = 0
    for index, button in ipairs(self.buttons_) do
        if button == clickedButton then
            currentSelectedIndex = index
            if not button:isButtonSelected() then
                button:setButtonSelected(true)
            end
        else
            if button:isButtonSelected() then
                button:setButtonSelected(false)
            end
        end
    end
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        local last = self.currentSelectedIndex_
        self.currentSelectedIndex_ = currentSelectedIndex
        self:dispatchEvent({name = MCheckBoxButtonGroup.BUTTON_SELECT_CHANGED, selected = currentSelectedIndex, last = last})
    end
end

function MCheckBoxButtonGroup:createCloneInstance_()
    return MCheckBoxButtonGroup.new(unpack(self.args_))
end

function MCheckBoxButtonGroup:copyClonedWidgetChildren_(node)
    local count = node:getButtonsCount()
    local btn
    local cloneBtn

    for i=1, count do
        btn = node:getButtonAtIndex(i)
        cloneBtn = btn:clone()
        if cloneBtn then
            self:addButton(cloneBtn)
        end
    end
end

function MCheckBoxButtonGroup:copySpecialProperties_(node)
    self:setButtonsLayoutMargin(node:getLayoutMargin())
end

return MCheckBoxButtonGroup
