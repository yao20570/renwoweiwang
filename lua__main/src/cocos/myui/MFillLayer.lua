------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:40:02
-- @Description: 自定义扩充控件
------------------------------

--------------------------------
-- @module MLayer
local MLayer = import(".MLayer")

local MFillLayer = myclass("MFillLayer", MLayer)

--------------------------------
-- MLayer构建函数
-- @function [parent=#MLayer] new

function MFillLayer:ctor(  )
    MFillLayer.super.ctor(self)
    self:__filllayerInit()
    self:__setViewType(MUI.VIEW_TYPE.filllayer)

end
function MFillLayer:__filllayerInit( )
    -- 是否每次增加控件都刷新一下内容
    self.m_bRefreverytime = true
    self.m_bIsFill = true
end
-- 增加一个子的MView
-- pChildView(MView): 子项，类型必须是MView
-- nZOrder(int): 层级值
-- nTag(int): 控件的标识
-- return(MView): 返回子项
function MFillLayer:addView( pChildView, nZOrder, nTag )
    -- 执行父类的函数
    MFillLayer.super.addView(self, pChildView, nZOrder, nTag)
    if(self.m_bRefreverytime) then
        self:requestLayout()
    end
end

-- 设置是否每次增加控件都刷新内容
-- _bIs（bool）：是否每次增加控件都刷新内容
function MFillLayer:setRefreshEveryTime( _bIs )
    self.m_bRefreverytime = _bIs
end

-- 刷新控件的扩充效果
function MFillLayer:requestLayout(  )

    if not self.m_bRefreverytime then
        return
    end

    self.m_bRefreverytime = false

    local tIgonreHeight = nil -- 忽略同级其它控件高度，填满高度的控件
    local nFillViewCount = 0 --  需要扩充的控件数量
    local pChilds = self:getChildren() -- 所有的子控件
    local tHandleViews = {} -- 取得所有MView的控件
    local fTotalHeight = self:getHeight() -- 总高度
    local fLeftHeight = fTotalHeight -- 剩余的高度
    for i, v in pairs(pChilds) do
        if(v and v.bMView and v:isVisible()) then
            -- 记录所有MView的控件
            tHandleViews[#tHandleViews+1] = v
            if (v.m_bIgnoreOtherHeight) then
                -- 填满总高度的
            elseif(v.m_bIsFill) then
                nFillViewCount = nFillViewCount + 1
            else
                -- 计算剩余高度
                fLeftHeight = fLeftHeight - v:getHeight() * v:getScaleY()
            end
        end
    end
    -- 按照y值的降序来排
    table.sort(tHandleViews, function ( _pView1, _pView2 )
        if(_pView1 and _pView2) then
            local y1 = _pView1:getBasePositionY()
            local y2 = _pView2:getBasePositionY()
            if(y1 > y2) then
                return true  
            end

            if y1 == y2 then
                local z1 = _pView1:getLocalZOrder()
                local z2 = _pView2:getLocalZOrder()
                if(z1 < z2) then
                    return true            
                end
            end
        end
        return false
    end)

    -- fix
    if fLeftHeight < 0 then
        fLeftHeight = 0
    end

    -- 计算平均的高度
    local fEvenHeight = 0
    if nFillViewCount > 0 then
        fEvenHeight = fLeftHeight / nFillViewCount
    end
    fLeftHeight = fTotalHeight
    for i, v in pairs(tHandleViews) do
        -- 是否需要请求布局
        local isNeedRequestLayout = false
        -- 调整扩充后的高度
        if v.m_bIsFill then
            -- 如果存在需要调整显示区域的，刷新显示区域的内容
            if v.setViewRect then
                local oldRect = v:getViewRect()
                local x = v:getPositionX()
                local y = v:getPositionY()
                local w = v:getWidth()
                local h = fEvenHeight
                if v.m_bIgnoreOtherHeight then
                    h = fTotalHeight
                end
                if oldRect.x ~= x or oldRect.y ~= y or oldRect.width ~= w or oldRect.height ~= h then
                    isNeedRequestLayout = true
                    v:setViewRect(cc.rect(x, y, w, h))
                end
            else
                local oldSize = v:getContentSize()
                local w = v:getWidth()
                local h = fEvenHeight
                if v.m_bIgnoreOtherHeight then
                    h = fTotalHeight
                end
                if oldSize.width ~= w or oldSize.height ~= h then
                    isNeedRequestLayout = true
                    v:setLayoutSize(w, h)
                end
            end
        end

        if v.m_bIgnoreOtherHeight then
            --v:setPositionY(0)
        else
            local fH = v:getHeight() * v:getScaleY()
            fLeftHeight = fLeftHeight - fH
            local fY = fLeftHeight 
            v:setPositionY(fY)
        end        

        -- 执行子控件的线性排列
        --isNeedRequestLayout = true
        if (isNeedRequestLayout and v.m_bIsFill) then
            v:requestLayout()
        end
    end

    self.m_bRefreverytime = true
end
return MFillLayer
