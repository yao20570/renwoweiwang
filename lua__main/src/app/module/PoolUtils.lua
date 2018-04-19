----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-07-07 16:16:43 
-- Description: 缓存池的管理工具
-----------------------------------------------------
-- 刷新横向列表的数据
-- _layer（MLayer）: 当前横向列表的父容器
-- _datas (table): 能够使用在icongoods上的数据类
--左，右
--bHide是否隐藏底部文字
-- return (MListView): 返回创建好的横向列表
function gRefreshHorizontalList( _layer, _datas, nLeft, nRight, bHide)
    if(not _layer) then
        print("refreshHorizontalList请传入有效的MLayer")
        return
    end
    if(not _datas) then
        print("refreshHorizontalList请传入有效的数据")
        return
    end
    local iconHeight = 148
    if bHide then
        iconHeight = 108
    end
    local pListView = _layer:findViewByName("horizontallist")
    if(not pListView) then
        local scale = _layer:getHeight()/iconHeight
        local width = _layer:getWidth() / scale
        local height = _layer:getHeight() / scale
        pListView = MUI.MListView.new {
            viewRect   = cc.rect(0, 0, width, height),
            direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
            itemMargin = {left = nLeft or 5,
                 right = nRight or 5,
                 top = 0 ,
                 bottom =  0},
        }
        -- 设置缩放比例
        pListView:setScale(scale)
        pListView:setAsyncDisTime(0.03)
        -- 设置控件名称
        pListView:setName("horizontallist")
        pListView:setItemCount(0)
        -- 创建的时候，可以添加这个处理
        pListView:reload(false)
        _layer:addView(pListView)
        -- 设置摆放位置
        pListView:setPosition(0, 0)
    end
    pListView:setItemCallback(function ( _index, _pView )
        local tTempData = _datas[_index]
        if(not _pView) then
            if bHide then
                _pView = gNewIconGoods()
            else
                _pView = gNewIconGoodsMore()
            end
            
        end
        -- 刷新内容
        if(tTempData) then
            _pView:setCurData(tTempData)
            _pView:setMoreTextColor(getColorByQuality(tTempData.nQuality))
            _pView:setNumber(tTempData.nCt)
        end
        return _pView
    end)
    pListView:setItemCount(#_datas)
    -- 刷新实际数据
    pListView:notifyDataSetChange( true )
    -- 滑动到第一项
    pListView:scrollTo(0, 0)
    return pListView
end

-- 创建一个IconGoods，带有底部名称的，并且带有右下角数量展示的
function gNewIconGoods(  )
    local _pView = popViewFromPool("icongoodsNoMore")
    if(not _pView) then
        -- 如果缓存池中不够，直接创建一个新的
        local IconGoods = require("app.common.iconview.IconGoods")
        _pView = IconGoods.new(TypeIconGoods.NORMAL, type_icongoods_show.itemnum)
        _pView.__poolTmpName = "icongoodsNoMore"
        _pView:setDestory2ObjPoolFlag()
    end
    if(_pView) then
        _pView:setScale(1)
    end
    return _pView
end

-- 创建一个IconGoods，带有底部名称的，并且带有右下角数量展示的
function gNewIconGoodsMore(  )
    local _pView = popViewFromPool("icongoods")
    if(not _pView) then
        -- 如果缓存池中不够，直接创建一个新的
        local IconGoods = require("app.common.iconview.IconGoods")
        _pView = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)
        _pView.__poolTmpName = "icongoods"
        _pView:setDestory2ObjPoolFlag()
    end
    if(_pView) then
        _pView:setScale(1)
    end
    return _pView
end

-- 创建一个MImage
function gNewMapDotMore(  )
    local _pView = popViewFromPool("mapdot")
    if(not _pView) then
        -- 如果缓存池中不够，直接创建一个新的
        _pView = MUI.MImage.new("ui/daitu.png")
    end
    if(_pView) then
        _pView:setScale(1)
    end
    return _pView
end

-- 刷新横向列表的数据
-- _layer（MLayer）: 当前横向列表的父容器
-- _datas (table): 能够使用在icongoods上的数据类
-- _distance (number): 间距 
-- _isCenter : 是否居中
-- return (MListView): 返回创建好的横向列表
function gRefreshHorizontalIcons( _layer, _datas, _distance, _isCenter)
    if not _layer then
        return
    end

    local iconHeight = 148
    if not _distance then
        if #_datas == 1 then
            _distance = 10
        else
            _distance = (_layer:getWidth() - #_datas*108)/(#_datas-1)
        end
    end
    local nDis = _distance + 108
    local nStart = 0
    if _isCenter then
        local nNum = #_datas
        if nNum%2 == 1 then
            if nNum == 1 then
                nStart = _layer:getWidth()/2
            else
                nStart = _layer:getWidth()/2 - 108/2 - (nNum-1)/2*nDis
            end
        else
            nStart = nNum/2*nDis - _distance/2
        end
    end
    for k, v in ipairs(_datas) do
        local pIcon = gNewIconGoodsMore()
        if(v) then
            pIcon:setCurData(v)
            pIcon:setMoreTextColor(getColorByQuality(v.nQuality))
            pIcon:setNumber(v.nCt)
        end
        _layer:addView(pIcon);
        pIcon:setAnchorPoint(cc.p(0.5, 0.5))
        if not _isCenter then
            pIcon:setPosition((k-1)*nDis+108/2, 54)
            pIcon:setScale(_layer:getHeight()/iconHeight)
        else
            print("oooooooooooooooooooooooooooooooo  :", (nStart + (k-1)*nDis))
            pIcon:setPosition(nStart + (k-1)*nDis, 54)
        end
    end
end
