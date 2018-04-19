------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:23:15
-- @Description: 布局类型，对齐方式的定义，包括权重和层级
------------------------------

local MStretch = import(".MStretch")

local MLayout = myclass("MLayout")

local nameIndex_ = 1

-- start --

--------------------------------
-- 布局控件构建函数
-- @function [parent=#MLayout] new
-- @param string name 布局控件名字

-- end --

function MLayout:ctor(name)
    cc(self):addComponent("components.ui.LayoutProtocol"):exportMethods()
    if not name then
        name = string.format("layout-%d", nameIndex_)
        nameIndex_ = nameIndex_ + 1
    end
    self.name_ = name
    self.position_ = {x = 0, y = 0}
    self.anchorPoint_ = display.ANCHOR_POINTS[display.CENTER]
    self.order_ = 0

    self.widgets_ = {}
    local m = {__mode = "k"}
    setmetatable(self.widgets_, m)

    self.persistent_ = {}
end

-- start --

--------------------------------
-- 返回布局控件名字
-- @function [parent=#MLayout] getName
-- @return string#string 

-- end --

function MLayout:getName()
    return self.name_
end

-- start --

--------------------------------
-- 添加一个布局
-- @function [parent=#MLayout] addLayout
-- @param node layout 布局node
-- @param number weight 布局所占的weight,默认为1
-- @return MLayout#MLayout 

-- end --

function MLayout:addLayout(layout, weight)
    self:addWidget(layout, weight)
    self.persistent_[#self.persistent_ + 1] = layout
    return self
end

-- start --

--------------------------------
-- 添加一个widget
-- @function [parent=#MLayout] addWidget
-- @param node widget 控件
-- @param number weight 控件所占的weight,默认为1
-- @return MLayout#MLayout 

-- end --

function MLayout:addWidget(widget, weight)
    self.order_ = self.order_ + 1
    self.widgets_[widget] = {weight = weight or 1, order = self.order_}
    return self
end

-- start --

--------------------------------
-- 移除一个widget
-- @function [parent=#MLayout] removeWidget
-- @param node widget 要移除的控件
-- @return MLayout#MLayout 

-- end --

function MLayout:removeWidget(widget)
    for w, _ in pairs(self.widgets_) do
        if w == widget then
            self.widgets_[w] = nil
            break
        end
    end
    return self
end

-- start --

--------------------------------
-- 增加一个可伸展的布局
-- @function [parent=#MLayout] addStretch
-- @param number weight 可伸展布展所占的weight
-- @return MLayout#MLayout 

-- end --

function MLayout:addStretch(weight)
    local stretch = MStretch.new()
    self:addWidget(stretch, weight)
    self.persistent_[#self.persistent_ + 1] = stretch
    return self
end

-- start --

--------------------------------
-- 返回位置信息
-- @function [parent=#MLayout] getPosition
-- @return number#number  x
-- @return number#number  y

-- end --

function MLayout:getPosition()
    return self.position_.x, self.position_.y
end

-- start --

--------------------------------
-- 返回x位置信息
-- @function [parent=#MLayout] getPositionX
-- @return number#number  x

-- end --

function MLayout:getPositionX()
    return self.position_.x
end

-- start --

--------------------------------
-- 返回y位置信息
-- @function [parent=#MLayout] getPositionY
-- @return number#number  y

-- end --

function MLayout:getPositionY()
    return self.position_.y
end

-- start --

--------------------------------
-- 设置位置信息
-- @function [parent=#MLayout] setPosition
-- @param number x
-- @param number y

-- end --

function MLayout:setPosition(x, y)
    self.position_.x, self.position_.y = x, y
end

-- start --

--------------------------------
-- 设置x位置信息
-- @function [parent=#MLayout] setPositionX
-- @param number x

-- end --

function MLayout:setPositionX(x)
    self.position_.x = x
end

-- start --

--------------------------------
-- 设置y位置信息
-- @function [parent=#MLayout] setPositionY
-- @param number y

-- end --

function MLayout:setPositionY(y)
    self.position_.y = y
end

-- start --

--------------------------------
-- 返回锚点信息
-- @function [parent=#MLayout] getAnchorPoint
-- @return table#table  锚点位置

-- end --

function MLayout:getAnchorPoint()
    return self.anchorPoint_
end

-- start --

--------------------------------
-- 设置锚点信息
-- @function [parent=#MLayout] setAnchorPoint
-- @param table 锚点位置

-- end --

function MLayout:setAnchorPoint(ap)
    self.anchorPoint_ = ap
end

function MLayout:apply(container)
end

return MLayout
