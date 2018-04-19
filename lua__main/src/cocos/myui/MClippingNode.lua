------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-17 11:30:42
-- @Description: 切割类型的layout
------------------------------

local MView = import(".MView")

local MClippingNode = myclass("MClippingNode", function (  )
    local pView = MView.new(MUI.VIEW_TYPE.clippingnode)
    pView.__setClippingRegion = pView.setClippingRegion
	return pView
end)
function MClippingNode:ctor(  )
	
end
-- 执行触摸判断
-- @param type paramname
-- @param type paramname
function MClippingNode:__dispatchTouchEvent( event )
    -- 执行自身的触摸判断
    return __doMViewDispatchTouchEvent(self, event)
end

-- 执行多点触摸判断
-- @param type paramname
-- @param type paramname-- @return
function MClippingNode:__dispatchMultiTouchEvent( event )
    -- body
    return __doMViewDispatchMultiTouchEvent(self, event)
end

-- 刷新是否可用的状态
function MClippingNode:__onRefreshEnableState( _bEn )
	if(_bEn == nil) then
		_bEn = self:isViewEnabled()
	end
    -- 获取所有的子节点
    local pChilds = self:getChildren()
    -- 获取子节点的总个数
    local nChildCount = #pChilds
    -- 一定要倒序获取触摸
    for i=nChildCount, 1, -1 do
        local pChild = pChilds[i]
        -- 必须是MView
        if(pChild and pChild.bMView and pChild.__onRefreshEnableState) then
        	pChild:__onRefreshEnableState(_bEn)
        end
    end
end
-- 刷新按钮状态是否置灰
function MClippingNode:__onRefreshGrayState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewGray()
        _bEn = not _bEn
    end
   
    -- 获取所有的子节点
    local pChilds = self:getChildren()
    -- 获取子节点的总个数
    local nChildCount = #pChilds
    -- 一定要倒序获取触摸
    for i=nChildCount, 1, -1 do
        local pChild = pChilds[i]
        -- 必须是MView
        if(pChild and pChild.bMView and pChild.__onRefreshGrayState) then
            pChild:__onRefreshGrayState(_bEn)
        end
    end
end
function MClippingNode:setClippingRegion( _rect )
    self:__setClippingRegion(_rect)
    self:setContentSize(_rect.width, _rect.height)
end
return MClippingNode