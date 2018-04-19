------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:40:02
-- @Description: 自定义组控件
------------------------------

--------------------------------
-- @module MLayer


local MView = import(".MView")
local MImage = import(".MImage")
local MClippingNode = import(".MClippingNode")

local MLayer = myclass("MLayer", function()
    local pLayer = MView.new(MUI.VIEW_TYPE.layer)
    pLayer.__removeAllViews = pLayer.removeAllChildren
    pLayer.__getChildViews = pLayer.getChildren
    pLayer.__getChildViewsCount = pLayer.getChildrenCount
    pLayer.__setViewTouched = pLayer.setViewTouched
    pLayer.__findViewByTag = pLayer.findViewByTag
    pLayer.__findViewByName = pLayer.findViewByName
        
    pLayer.__getChildByTag = pLayer.getChildByTag
    pLayer.__getChildByName = pLayer.getChildByName
    return pLayer
end)

-- start --

--------------------------------
-- MLayer构建函数
-- @function [parent=#MLayer] new

-- end --

function MLayer:ctor( bClipping )
    self:__mlayerInit()
    -- 根据参数初始化内容
    self:__resetOptions(true, bClipping)

--    self:onNodeEvent("exit", function (  )        
--        if self.UserControlToObjPool ~= nil then
--            self:UserControlToObjPool()
--        end
--    end)

end
-- 重置特殊需求的控制
-- 这里的参数与ctor方法的参数一样
-- _bNew(bool): 是否从ctor中new出来的
function MLayer:__resetOptions(_bNew,  bClipping )
    if(_bNew == nil) then
        _bNew = true
    end
    self:setClipping(bClipping)
    self:align(display.LEFT_BOTTOM)
    -- 默认不开启触摸控制
    self:setTouchEnabled(false)
    -- 当前触摸到的控件
    self.pCurTouchedView = nil
    if(not _bNew) then
        self:removeBackground()
        -- 取消置灰的控制
        self:setViewEnabled(true)
        self:setToGray(false)
        -- 恢复透明度
        self:setOpacity(255)
        --取消点击事件
        self:setViewTouched(false)
        self:onMViewClicked(nil)
        -- 恢复颜色值
        self:setColor(cc.c3b(255, 255, 255))
    end
end
function MLayer:__mlayerInit( )
    self.m_bClipping = false -- 是否可以裁剪
end
-- 执行单点触摸判断
-- @param type paramname
-- @param type paramname-- @return
function MLayer:__dispatchTouchEvent( event )
    -- 执行自身的触摸判断
    return __doMViewDispatchTouchEvent(self, event)
end

-- 执行多点触摸判断
-- @param type paramname
-- @param type paramname-- @return
function MLayer:__dispatchMultiTouchEvent( event )
    -- body
    return __doMViewDispatchMultiTouchEvent(self, event)
end

-- 克隆的处理
function MLayer:clone_()
    reAddMUIComponent_(self)
end
-- 创建新的裁剪节点
function MLayer:__refreshClippingNode( )
    if(not self.m_bClipping) then
        return
    end
    -- 添加可切割的node
    if(not self.m_pClipNode) then
        self.m_pClipNode = MClippingNode.new()
        self.m_pClipNode:setName("MClippingNode")
        self:addChild(self.m_pClipNode)
    end
    -- 设置裁剪区域
    self.m_pClipNode:setClippingRegion(cc.rect(0, 
        0, self:getWidth(), self:getHeight()))
end
-- 刷新是否可用的状态
function MLayer:__onRefreshEnableState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewEnabled()
    end
    -- 处理背景的刷新
    if(self.backgroundSprite_) then
        changeSpriteEnabledShowState(self.backgroundSprite_, self:isViewEnabled())
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

-- 刷新是否可用的状态
function MLayer:__onRefreshGrayState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewGray()
         _bEn = not _bEn
    end
    -- 处理背景的刷新
    if(self.backgroundSprite_) then
        changeSpriteEnabledShowState(self.backgroundSprite_, _bEn)
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
-- start --

--------------------------------
-- 设置大小
-- @function [parent=#MLayer] setLayoutSize
-- @param number width
-- @param number height
-- @return MLayer#MLayer 

-- end --

function MLayer:setLayoutSize(width, height)
    self:setContentSize(cc.size(width, height))
    if self.backgroundSprite_ then
        self.backgroundSprite_:setLayoutSize(self:getLayoutSize())
        -- 居中显示
        centerInView(self, self.backgroundSprite_)
    end
    -- 重新刷新裁剪的范围
    self:__refreshClippingNode()
    -- 是否需要刷新内容
    if(self.requestLayout) then
        self:requestLayout()
    end
    return self
end
-- 获取当前界面的文件大小
-- param1(type): 参数1说明
-- param2(type): 参数2说明
-- return(type): 返回值说明
function MLayer:getLayoutSize(  )
    local size = self:getContentSize()
    return size.width, size.height
end

-- start --

function MLayer:removeBackground(  )
    -- 如果需要新建，清除旧的背景
    if(self.backgroundSprite_ and tolua.isnull(self.backgroundSprite_) == false and self.backgroundSprite_.addChild) then
        self.backgroundSprite_:removeSelf()
        self.backgroundSprite_ = nil
    end
end

--------------------------------
-- 设置背景图片
-- @function [parent=#MLayer] setBackgroundImage
-- @param string filename 图片名
-- @param table args 图片控件的参数表
-- @param boolean bNew 是否需要新建一个新的sprite
-- @return MLayer#MLayer 
-- @see MLayer

-- end --

function MLayer:setBackgroundImage(filename, args, bNew)
    if(bNew == nil) then
        bNew = false
    end
    if(bNew and self.backgroundSprite_) then
        self:removeBackground()
    end
    if(not self.backgroundSprite_) then
        self.backgroundSprite_ = MImage.new(filename, args)
        self.backgroundSprite_:setName("layerBackground")
        self.backgroundSprite_:setIgnoreOtherHeight(true)
        -- 必须设置背景图片的大小，特别是点9图
        if(args and args.scale9) then
            self.backgroundSprite_:setLayoutSize(self:getWidth(), self:getHeight())
        end
        -- 故意取消这个背景的的MView类型
        self.backgroundSprite_.bMView = false
        if(self:getFinalClippingView()) then
            self:getFinalClippingView():addChild(self.backgroundSprite_,MUI.LAYER_BG_ZORDER)
        else
            self:addChild(self.backgroundSprite_,MUI.LAYER_BG_ZORDER)
        end
    else
        local cap = nil
        if(args and args.capInsets) then
            cap = args.capInsets
        end
        -- 必须设置背景图片的大小，特别是点9图
        if(args and args.scale9) then
            self.backgroundSprite_:setLayoutSize(self:getWidth(), self:getHeight())
        end
        self.backgroundSprite_:setCurrentImage(filename, cap)
    end
    -- 居中显示
    centerInView(self, self.backgroundSprite_)
    return self
end

-- 增加一个子的MView
-- pChildView(MView): 子项，类型必须是MView
-- nZOrder(int): 层级值
-- nTag(int): 控件的标识
-- return(MView): 返回子项
function MLayer:addView( pChildView, nZOrder, nTag )
    if(not pChildView) then
        printMUI("子项为空")
        return
    end
    --相机类型特殊处理
    if pChildView.bMView and pChildView.getMViewType then
        if pChildView:getMViewType() == MUI.VIEW_TYPE.label
        or pChildView:getMViewType() == MUI.VIEW_TYPE.input
        or pChildView:getMViewType() == MUI.VIEW_TYPE.labelatlas then --label 和 数字标签 和输入框
            -- pChildView:setCameraMask(MUI.CAMERA_FLAG.USER2,true)
        end
    end
    nZOrder = nZOrder or pChildView:getLocalZOrder()
    nTag = nTag or pChildView:getTag()
    if(self:getFinalClippingView()) then
        self:getFinalClippingView():addChild(pChildView, nZOrder, nTag)
    else
        self:addChild(pChildView, nZOrder, nTag)
    end
    if(pChildView.bMView) then
        -- 如果是不可用，要刷新状态
        if(not self:isViewEnabled()) then
            self:__onRefreshEnableState()
        end
    end
    
end

--设置使用自定义相机的标志
function MLayer:setUseMyCameraType( nType )
    -- body
    self.nUseMyCamera = nType
end

--获得使用自定义相机的标志（没有自定义相机则返回nil）
function MLayer:getUseMyCameraType(  )
    -- body
    return self.nUseMyCamera
end

-- 设置是否可以裁剪
-- bClipped(boolean): 是否可以裁剪
function MLayer:setClipping( bClipped )    
    self.m_bClipping = bClipped
    if(self.m_bClipping == nil) then
        self.m_bClipping = false
    end
    if(self.m_bClipping) then
        self:__refreshClippingNode()
    else
        if(self.m_pClipNode) then
            self.m_pClipNode:removeSelf()
            self.m_pClipNode = nil
        end
    end
end
-- 获取直接的子控件
function MLayer:getFinalClippingView(  )
    if(self.m_pClipNode) then
        return self.m_pClipNode
    end
    return self
end
-- 获得所有的子控件
function MLayer:getChildren()
    if(self.m_pClipNode) then
        return self.m_pClipNode:getChildren()
    end
    return self:__getChildViews()
end
-- 获取子控件
function MLayer:getChildByTag(_nTag)
    if(self.m_pClipNode) then
        return self.m_pClipNode:getChildByTag(_nTag)
    end
    return self:__getChildByTag(_nTag)
end
-- 获取子控件
function MLayer:getChildByName(_sName)
    if(self.m_pClipNode) then
        return self.m_pClipNode:getChildByName(_sName)
    end
    return self:__getChildByName(_sName)
end
-- 获取子控件的个数
function MLayer:getChildrenCount( )
    if(self.m_pClipNode) then
        return self.m_pClipNode:getChildrenCount()
    end
    return self:__getChildViewsCount()
end
-- 返回是否裁剪
function MLayer:isClipping(  )
    return self.m_bClipping
end
-- 移除所有的子控件
function MLayer:removeAllChildren(  )
    if(self.m_pClipNode) then
        return self.m_pClipNode:removeAllChildren()
    end
    return self:__removeAllViews()
end
-- 特殊的控制触摸开关，为了修改锚点
-- _isTouched（bool）：是否可以触摸
function MLayer:setViewTouched( _isTouched )
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:ignoreAnchorPointForPosition(true)
    -- 调用父类的方法
    self:__setViewTouched(_isTouched)
end

--控制触摸开关, 跟锚点没有关系
function MLayer:setViewTouchEnable( _isTouched )
    -- 调用父类的方法
    self:__setViewTouched(_isTouched)
end

---- 通过tag值搜索控件
---- _tag(int): 控件的tag
--function MLayer:findViewByTag( _tag )
--    local pView = nil
--    local tChilds = self:getChildren()
--    for i, v in pairs(tChilds) do
--        if(v.findViewByTag) then
--            pView = v:findViewByTag(_tag)
--        else
--            pView = v:getChildByTag(_tag)
--        end
--        if(pView) then
--            return pView
--        end
--    end
--    -- 查询自身
--    return self:__findViewByTag(_tag)
--end

---- 通过_name值搜索控件
---- _name(string): 控件的名称
--function MLayer:findViewByName( _name )
--    local pView = nil
--    local tChilds = self:getChildren()
--    for i, v in pairs(tChilds) do
--        if(v.findViewByName) then
--            pView = v:findViewByName(_name)
--        else
--            local x = 1
--            pView = v:getChildByName(_name)
--        end
--        if(pView) then
--            return pView
--        end
--    end
--    -- 查询自身
--    return self:__findViewByName(_name)
--end

---- 将控件释放回缓存池中
--function MLayer:__layerReleaseToPool( )
--    if(not MViewPool:getInstance():isReady()) then
--        return
--    end
--    -- 获取所有的子节点
--    local pChilds = self:getChildren()
--    -- 获取子节点的总个数
--    local nChildCount = #pChilds
--    -- 倒序放回缓存池中
--    for i=nChildCount, 1, -1 do
--        local pChild = pChilds[i]
--        -- 释放子控件
--        if(pChild.releaseToPool) then
--            pChild:releaseToPool()
--        end
--    end
--    -- 清除背景
--    self:removeBackground()
--    -- 清除所有其他子节点
--    self:removeAllChildren()
--end


-- 继承removeFromParent
--function MLayer:removeFromParent(_bCleanUp, _bAutoRelease, _bFromViewPool)
--    if (MViewPool:getInstance():isReady() and _bFromViewPool ~= true) then
--        self:releaseToPool()
--    end

--    if self:getParent() ~= nil then
--        getmetatable(self).removeFromParent(self, true)
--    end    
--end

-- 客户控件入对象池
--function MLayer:UserControlToObjPool()
--    if self.__poolTmpName == nil then
--        return
--    end

--    pushViewToPool(self, nil, false)
--    self:setParent(nil)
--end



return MLayer
