----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 19:44:02 
-- Description: 自定义拉伸控件
-----------------------------------------------------

--------------------------------
-- @module MStretch


local MStretch = myclass("MStretch")

-- start --

--------------------------------
-- @function [parent=#MStretch] new

-- end --

function MStretch:ctor()
    cc(self):addComponent("components.ui.LayoutProtocol"):exportMethods()
    self.position_ = {x = 0, y = 0}
    self.anchorPoint_ = display.ANCHOR_POINTS[display.CENTER]
end

-- start --

--------------------------------
-- 得到位置信息
-- @function [parent=#MStretch] getPosition
-- @return number#number  x
-- @return number#number  y

-- end --

function MStretch:getPosition()
    return self.position_.x, self.position_.y
end

-- start --

--------------------------------
-- 得到x位置信息
-- @function [parent=#MStretch] getPositionX
-- @return number#number  x

-- end --

function MStretch:getPositionX()
    return self.position_.x
end

-- start --

--------------------------------
-- 得到y位置信息
-- @function [parent=#MStretch] getPositionY
-- @return number#number  y

-- end --

function MStretch:getPositionY()
    return self.position_.y
end

-- start --

--------------------------------
-- 设置位置信息
-- @function [parent=#MStretch] setPosition
-- @param number x x的位置
-- @param number y y的位置

-- end --

function MStretch:setPosition(x, y)
    self.position_.x, self.position_.y = x, y
end

-- start --

--------------------------------
-- 设置x位置信息
-- @function [parent=#MStretch] setPositionX
-- @param number x x的位置

-- end --

function MStretch:setPositionX(x)
    self.position_.x = x
end

-- start --

--------------------------------
-- 设置y位置信息
-- @function [parent=#MStretch] setPositionY
-- @param number y y的位置

-- end --

function MStretch:setPositionY(y)
    self.position_.y = y
end

-- start --

--------------------------------
-- 得到锚点位置信息
-- @function [parent=#MStretch] getAnchorPoint
-- @return table#table  位置信息

-- end --

function MStretch:getAnchorPoint()
    return self.anchorPoint_
end

-- start --

--------------------------------
-- 设置锚点位置
-- @function [parent=#MStretch] setAnchorPoint
-- @param ap 锚点

-- end --

function MStretch:setAnchorPoint(ap)
    self.anchorPoint_ = ap
end


return MStretch
