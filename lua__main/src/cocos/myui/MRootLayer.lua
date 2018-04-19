------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:40:02
-- @Description: 自定义带触摸控制的控件
------------------------------

--------------------------------
-- @module MRootLayer
-- 不能继承自MFillLayer，因为涉及到对话框的添加问题

LAST_TOUCHED_TIME = nil -- 最后触摸的时间

local MLayer = import(".MLayer")

local MRootLayer = myclass("MRootLayer", MLayer)

-- start --

--------------------------------
-- MRootLayer构建函数
-- @function [parent=#MRootLayer] new

-- end --

function MRootLayer:ctor()
    MRootLayer.super.ctor(self)
    self:__mrootlayerInit()
    self:setClipping(true)
    -- 左下角对齐方式
    self:align(display.LEFT_BOTTOM)
    self:__setMulitTouch(true)
    -- 设置触摸事件
    self:onTouch(handler(self, self.__onRootLayerTouch), false, true)
end
-- 初始化数据
function MRootLayer:__mrootlayerInit(  )
    -- 记录类型为rootlayer
    self:__setViewType(MUI.VIEW_TYPE.rootlayer)
    -- 默认开启触摸功能
    self:setTouchEnabled(true)
end
-- 处理触摸事件
function MRootLayer:__onRootLayerTouch(  event )
    if(not self:isVisible()) then
        return
    end
    if not event or not event.points then
        return
    end
    g_cur_rootlayer = self -- 记录当前可触摸的界面
    if(event.name ~= "began") then
        self:closeKeyboard()
    end

    if event.name == "added" or event.name == "removed" then   --多点触摸行为
        --标志有多点触摸行为
        MultiTouched = true
        return self:__dispatchMultiTouchEvent(event)
    elseif MultiTouched and event.name == "moved" then --如果触发了多点触摸并且是move事件
        return self:__dispatchMultiTouchEvent(event)
    else                                                       --单点触摸行为                            
        --第一个
        local tKeys = table.keys(event.points)
        --转化为可解析的格式
        local tMyEvent = {}
        tMyEvent.mode = 1
        tMyEvent.name = event.name
        tMyEvent.phase = event.phase
        tMyEvent.id = event.points[tKeys[1]].id
        tMyEvent.prevX = event.points[tKeys[1]].prevX
        tMyEvent.prevY = event.points[tKeys[1]].prevY
        tMyEvent.x = event.points[tKeys[1]].x
        tMyEvent.y = event.points[tKeys[1]].y
        -- 执行自己的触摸
        return self:__dispatchTouchEvent(tMyEvent)
    end
end
-- 关闭输入框
function MRootLayer:closeKeyboard(  )
    return gCloseKeyboard(self)
end

--设置是否开启多点触摸
function MRootLayer:__setMulitTouch( _bCan )
    -- body
    if _bCan then
        self:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE) -- 多点
    else
        self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE) -- 单点（默认模式）
    end
end

return MRootLayer
