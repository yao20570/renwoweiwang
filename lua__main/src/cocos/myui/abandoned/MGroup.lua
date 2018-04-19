------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:40:02
-- @Description: 自定义组控件
------------------------------

--------------------------------
-- @module MGroup


local MView = require("cocos.myui.MView")
local MBoxLayout = import(".MBoxLayout")
local MImage = import("cocos.myui.MImage")

local MGroup = myclass("MGroup", function()
    return MView.new(MUI.VIEW_TYPE.group)
end)

-- start --

--------------------------------
-- MGroup构建函数
-- @function [parent=#MGroup] new

-- end --

function MGroup:ctor()
    self:align(display.LEFT_BOTTOM)
end

-- start --

--------------------------------
-- 添加一个控件
-- @function [parent=#MGroup] addWidget
-- @param node widget 控件
-- @return MGroup#MGroup 

-- end --

function MGroup:addWidget(widget)
    self:addChild(widget)
    self:getLayout():addWidget(widget)
    return self
end

-- start --

--------------------------------
-- 触摸监听函数,如果不需要，记得重置为空
-- @function [parent=#MGroup] onTouch
-- @param function listener 函数
-- @return MGroup#MGroup 

-- end --

function MGroup:onCustomTouchListener(listener)
    self.nCustomTouchListener = listener
end

-- start --

--------------------------------
-- 打开触摸功能
-- @function [parent=#MGroup] enableTouch
-- @param boolean enabled
-- @return MGroup#MGroup 

-- end --

function MGroup:enableTouch(enabled)
    self:setTouchEnabled(enabled)
    return self
end

-- start --

--------------------------------
-- 设置大小
-- @function [parent=#MGroup] setLayoutSize
-- @param number width
-- @param number height
-- @return MGroup#MGroup 

-- end --

function MGroup:setLayoutSize(width, height)
    self:setContentSize(width, height)
    if self.backgroundSprite_ then
        self.backgroundSprite_:setLayoutSize(self:getLayoutSize())
        -- 居中显示
        centerInView(self, self.backgroundSprite_)
    end
    return self
end

-- start --

--------------------------------
-- 设置背景图片
-- @function [parent=#MGroup] setBackgroundImage
-- @param string filename 图片名
-- @param table args 图片控件的参数表
-- @param boolean bNew 是否需要新建一个新的sprite
-- @return MGroup#MGroup 
-- @see MGroup

-- end --

function MGroup:setBackgroundImage(filename, args, bNew)
    if(bNew == nil) then
        bNew = false
    end
    if(bNew and self.backgroundSprite_) then
        -- 如果需要新建，清除旧的背景
        self.backgroundSprite_:removeFromParent()
        self.backgroundSprite_ = nil
    end
    if(not self.backgroundSprite_) then
        self.backgroundSprite_ = MImage.new(filename, args):setLayoutSize(self:getLayoutSize())
        self:addChild(self.backgroundSprite_)
    else
        self.backgroundSprite_:setCurrentImage(filename)
    end
    -- 居中显示
    centerInView(self, self.backgroundSprite_)
    return self
end

function MGroup:clone_()
    reAddMUIComponent_(self)
end

return MGroup
