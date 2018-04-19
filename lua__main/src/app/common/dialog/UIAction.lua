-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-16 13:55:10 星期四
-- Description: 对话框管理类
-----------------------------------------------------

UIAction = {}

function UIAction.init()
    
end
-- 执行初始化
UIAction.init()

-- 进入非全屏对话框: 需要将主界面设tag: UIAction.TAG_SMALL_DLG
-- 进入全屏对话框: 需要将主界面设tag: UIAction.TAG_BIG_DLG
UIAction.TAG_SMALL_DLG = "uiaction_tag_small_dlg"
UIAction.TAG_BIG_DLG = "uiaction_tag_big_dlg"

UIAction.fDlgEnterDuration = 0.2 -- 对话框进入动画时长
UIAction.fDlgExitDuration = 0.2 -- 对话框退出动画时长

--展示对话框方法
-- _dlg: 需要显示的对话框
-- _rootlayer: 显示对话框所在的层上
-- _bIsNew(bool): 是否该对话框是新建的，false为已存在，true为新建
-- _isQue(bool): 当有上层对话框的时候 自身是否需要隐藏
-- _bIsNeedAction（bool）:是否需要播放动画 
-- 注意：有动画的界面需要设置 UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG
function UIAction.enterDialog( _dlg, _rootlayer, _bIsNew, _isQue, _bIsNeedAction )

	if(not _dlg) then
        return
    end

    -- 初始化默认值
    _rootlayer = _rootlayer or RootLayerHelper:getCurRootLayer()

    if(_bIsNew == nil) then -- 默认是新建
        _bIsNew = true
    end
    if _isQue == nil then -- 默认不隐藏
        _isQue = false
    end
    if(_bIsNeedAction == nil) then -- 判断是否需要执行动画(默认执行动画)
        _bIsNeedAction = true
    end

    --设置当前的对话框有上层的时候 是否需要隐藏
    _dlg.bNeedHide = _isQue

    --这里过滤掉一些没必要的操作
    if not _bIsNew then --不是最新的
        local pCheckDlg = getDlgByType(_dlg.eDlgType)
        if pCheckDlg and pCheckDlg.fLsatShowTime then
            local fCurTime = getSystemTime(false)
            if fCurTime - pCheckDlg.fLsatShowTime < 1000 then --判断是否在允许的时间内
                pCheckDlg.fLsatShowTime = fCurTime --再次赋值
                return
            end
        end
    end

    local pFillDlg = _dlg:findViewByName(UIAction.TAG_BIG_DLG) --全屏对话框
    local pSmallDlg = _dlg:findViewByName(UIAction.TAG_SMALL_DLG) --小的对话框
    --如果当前是全屏对话框那么他下面所有的对话框都需要隐藏
    if pFillDlg then
        --获得需要隐藏的对话框
    	_dlg.tNeedHideDlgs = getShowingDlgs()
        --全屏对话框 设置为透明
        _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
    else
    	--获得需要隐藏的对话框
    	_dlg.tNeedHideDlgs = getShowingAndNeedHideDlgs()
    end

    --强行去掉过程动画
    if b_force_close_filldlg_enter_action and pFillDlg then
        _bIsNeedAction = false
    end

    _dlg.bHadEnterAction = _bIsNeedAction --是否有进场动画赋值

    --执行判断是否为新创建的对话框
    if _bIsNew == true then

        -- 增加一个层级控制
        local eLayerType = e_layer_order_type.normallayer
        if(_dlg.eDlgType == e_dlg_index.unabletouch or _dlg.eDlgType == e_dlg_index.loading) then -- 不可点击层
            eLayerType = e_layer_order_type.unablelayer
        elseif(_dlg.eDlgType == e_dlg_index.exitalert -- 退出框
            or _dlg.eDlgType == e_dlg_index.reconnect) then  -- 重连框
             eLayerType = e_layer_order_type.exitlayer
        end

        -- 新手引导过程，提升等级对话框的层级
        if(Player:getIsGuiding() == true) then
            eLayerType = e_layer_order_type.unablelayer
        end

        --获得正式的对话框挂载层
        local pParView = getRealShowLayer(_rootlayer, eLayerType)
    	_dlg:showDialog(pParView)
        --最后展示的时间赋值
        _dlg.fLsatShowTime = getSystemTime(false)
    else
        --调用onResume方法
        if _dlg.onResume then
            -- 参数定义为再次进入展示范围而已
            _dlg:onResume(true)
        end
    	_dlg:visibleDialog()
        --最后展示的时间赋值
        _dlg.fLsatShowTime = getSystemTime(false)
    end
    -- 检测对话框队列
    checkAllDlgSequence()
    --发送消息隐藏特定层
    sendMsgToHideHome(_dlg.eDlgType)

    if _bIsNeedAction then --如果是有进场动画
        --判断是否有设置对话框类型值（UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG）
        --目前只对全屏对话框类型做动画效果，小对话框以后有需求再添加
        if pFillDlg then       
            showUnableTouchDlg()
            -- _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
            -- 增加进场动画
            actionEnterScene(pFillDlg, UIAction.fDlgEnterDuration,
                function (  )
                    hideUnableTouchDlg()
                    --展示对话框相关操作
                    handlerForShowDlg(_dlg)
                    --有进场动画 在这里回调到外部
                    if _dlg.__nShowHandler then
                        _dlg:__nShowHandler()
                    end
                end,1) 
        elseif pSmallDlg then 
            --展示对话框相关操作
            handlerForShowDlg(_dlg)
            if _dlg.__nShowHandler then
                _dlg:__nShowHandler()
            end
        else
            --展示对话框相关操作
            handlerForShowDlg(_dlg)
            --有进场动画 在这里回调到外部
            if _dlg.__nShowHandler then
                _dlg:__nShowHandler()
            end
        end
    else
        -- 检测是否需要增加过度层
        if(_bIsNew) then
            checkOverDlg(_dlg, function (  )
                --展示对话框相关操作
                handlerForShowDlg(_dlg)
            end)
        else
            --展示对话框相关操作
            handlerForShowDlg(_dlg)
        end
    end

    
end

--展示对话框相关操作
function handlerForShowDlg( _dlg )
    --隐藏需要隐藏的对话框
    if _dlg.tNeedHideDlgs and table.nums(_dlg.tNeedHideDlgs) > 0 then
        for k, v in pairs (_dlg.tNeedHideDlgs) do
            --如果有包含自己的 不需要隐藏
            if v.eDlgType ~= _dlg.eDlgType then
                if getDlgByType(v.eDlgType) then
                    v:hideDialog()
                end
            end
        end
    end

    --特殊对话框为全透明(屏蔽对话框 )
    if _dlg.eDlgType == e_dlg_index.unabletouch  
        or _dlg.eDlgType == e_dlg_index.reconnect
        or _dlg.eDlgType == e_dlg_index.register
        or _dlg.eDlgType == e_dlg_index.loading then
         -- 设置背景全透明色
        _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
    elseif _dlg.eDlgType == e_dlg_index.gettaskprize then --任务奖励对话框写死为不透明
        -- 设置背景半透明色
        _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)
    else
        --获得除了特定对话框之外当前正在展示中的(非透明)对话框
        local tSpe = getShowingDlgSWithoutSpe(_dlg)
        if tSpe and table.nums(tSpe) > 0 then
            --先把之前有非透明色的设置为全透明，当前最新的设置为半透明
            for k,v in pairs(tSpe) do
                v:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
            end
            _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)
            -- 设置背景全透明色
            -- _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
        else
            local pFillDlg = _dlg:findViewByName(UIAction.TAG_BIG_DLG) --全屏对话框
            if pFillDlg then
                -- 设置背景全透明色
                _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
            else
                -- 设置背景半透明色
                _dlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)
            end
            

        end
    end
    
end

--退出对话框
-- _dlg: 需要显示的对话框
-- _bIsNeedAction（bool）:是否需要播放动画
function UIAction.exitDialog( _dlg, _bIsNeedAction)
    if not _dlg then
        return
    end
	if(_bIsNeedAction == nil) then
        _bIsNeedAction = false 
    end

    if _bIsNeedAction then --如果是有出场动画
        --判断是否有设置对话框类型值（UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG）
        local pFillDlg = _dlg:findViewByName(UIAction.TAG_BIG_DLG) --全屏对话框
        local pSmallDlg = _dlg:findViewByName(UIAction.TAG_SMALL_DLG) --小的对话框
        --目前只对全屏对话框类型做动画效果，小对话框以后有需求再添加
        if pFillDlg then       
            -- showUnableTouchDlg()
            -- 增加出场动画
            actionExitScene(pFillDlg, UIAction.fDlgExitDuration,
                function (  )
                    -- hideUnableTouchDlg()
                    --关闭对话框相关操作
                    handlerForCloseDlg(_dlg)
                end) 
            
        elseif pSmallDlg then 
            --动画效果待添加

            --关闭对话框相关操作
            handlerForCloseDlg(_dlg)
        else
            print("没有设置UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG：" .. _dlg.eDlgType)
             --关闭对话框相关操作
            handlerForCloseDlg(_dlg)
        end
    else
        --关闭对话框相关操作
        handlerForCloseDlg(_dlg)
    end

   
end

--关闭对话框相关操作
function handlerForCloseDlg( _dlg )
    -- body
    local bNeedBgCon = true
    local curDlgType = _dlg.eDlgType
    if curDlgType == e_dlg_index.loading then --如果是loading对话框
        bNeedBgCon = false
    end

    --发送消息展示隐藏层
    sendMsgToShowHome(curDlgType)

    -- 从队列中删除
    removeDlgFromArray(_dlg)
    if _dlg.tNeedHideDlgs and table.nums(_dlg.tNeedHideDlgs) > 0 then
        for k, v in pairs (_dlg.tNeedHideDlgs) do
            if v then
                --判断当前对话框是否还存在
                if getDlgByType(v.eDlgType) and not v:isPausing() then
                    v:setVisible(true) --注意 这里不能调用MDiaolg的visibleDialog方法，因为那个方法会改变层级
                end
            end
        end
    end
    _dlg.tNeedHideDlgs = nil
    --再次检测是否有在展示列表中保存的全屏对话框，但是没有展示状态下的，需要清理一下
    checkToShowHome()
    
    _dlg:closeDialog()

    -- 回收没用到的texture, spriteFrame
    local tDlgParam = tDlgParams[tostring(curDlgType)]
    if tDlgParam and tDlgParam.gct then
        removeUnusedTextures()   
        
        -- 延迟一帧后gc lua，因为dlg移除很耗时，GCMgr:gc也很耗时
        MUI.scheduler.performWithDelayGlobal(function ()
            GCMgr:gcByMax()
        end, 0.01)     
    end

    --背景控制
    if bNeedBgCon then
        handlerDlgBg()
    end
end

--隐藏对话框
-- _dlg: 需要显示的对话框
-- _bIsNeedAction（bool）:是否需要播放动画
function UIAction.hideDialog( _dlg, _bIsNeedAction)
    if not _dlg then
        return
    end
	if(_bIsNeedAction == nil) then
        _bIsNeedAction = false 
    end
    --调用onPause方法
    if _dlg.onPause then
        _dlg:onPause()
    end

    if _bIsNeedAction then --如果是有出场动画
        --判断是否有设置对话框类型值（UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG）
        local pFillDlg = _dlg:findViewByName(UIAction.TAG_BIG_DLG) --全屏对话框
        local pSmallDlg = _dlg:findViewByName(UIAction.TAG_SMALL_DLG) --小的对话框
        --目前只对全屏对话框类型做动画效果，小对话框以后有需求再添加
        if pFillDlg then       
            -- showUnableTouchDlg()
            -- 增加出场动画
            actionExitScene(pFillDlg, UIAction.fDlgExitDuration,
                function (  )
                    -- hideUnableTouchDlg()
                    --关闭对话框相关操作
                    handlerForHideDlg(_dlg)
                end) 
            
        elseif pSmallDlg then 
            --动画效果待添加

            --关闭对话框相关操作
            handlerForHideDlg(_dlg)
        else
            print("没有设置UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG：" .. _dlg.eDlgType)
             --关闭对话框相关操作
            handlerForHideDlg(_dlg)
        end
    else
        --关闭对话框相关操作
        handlerForHideDlg(_dlg)
    end



end

--关闭对话框相关操作
function handlerForHideDlg( _dlg )
    -- body
    if _dlg.tNeedHideDlgs and table.nums(_dlg.tNeedHideDlgs) > 0 then
        for k, v in pairs (_dlg.tNeedHideDlgs) do
            if v then
                --判断当前对话框是否还存在
                if getDlgByType(v.eDlgType) and not v:isPausing()  then
                    v:setVisible(true) --注意 这里不能调用MDiaolg的visibleDialog方法，因为那个方法会改变层级
                end
            end
        end
    end
    --发送消息展示隐藏层
    sendMsgToShowHome(_dlg.eDlgType)

    _dlg.tNeedHideDlgs = nil
    --再次检测是否有在展示列表中保存的全屏对话框，但是没有展示状态下的，需要清理一下
    checkToShowHome()
    _dlg:hideDialog()

    --背景控制
    handlerDlgBg()
end

--对话框背景层控制管理
function handlerDlgBg(  )
    -- body
    --获得当前正在展示的对话框
    local tShowingdlgs = getShowingDlgs()
    if tShowingdlgs then
        local nIndex = 0
        --查找当前展示中的对话框是否有半透明层（特殊对话框除外）
        local bIsFind = false
        for k, v in pairs (tShowingdlgs) do
            if v.eDlgType ~= e_dlg_index.unabletouch 
                and v.eDlgType ~= e_dlg_index.loading then
                if isEqualC4B(v:getDialogBgColor(),GLOBAL_DIALOG_BG_COLOR_DEFAULT) then
                    if bIsFind == false then
                        bIsFind = true
                    else
                        v:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
                    end
                else
                    nIndex = nIndex + 1
                end
            end
        end
        --找不到的情况下需要处理
        if bIsFind == false and nIndex >= 1 and tShowingdlgs[1] then
            local pFillDlg = tShowingdlgs[1]:findViewByName(UIAction.TAG_BIG_DLG) --全屏对话框
            --非全屏才需要颜色
            if not pFillDlg then
                tShowingdlgs[1]:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)
            end
        end
    end
end
-- 小对话框的经常动画
function actionEnterSmallDlg( _pView, _fTime, _nHandler )
    if(not _pView) then
        print("对话框错误，请检查代码！！！")
        return
    end
    _fTime = _fTime or UIAction.fDlgEnterDuration
    local pInView = _pView.pAlertDlgView
    if(not pInView) then
        pInView = _pView.pComDlgView
    end
    if(not pInView) then
        print("没有需要执行动画的view，所有忽略动作行为！！！")
        _nHandler()
        return
    end
    pInView:ignoreAnchorPointForPosition(true)
    pInView:setScale(0.3)
    pInView:setOpacity(1)
    pInView:setVisible(false)
    scheduleOnceCallback(RootLayerHelper:getCurRootLayer(), function (  )
        if(tolua.isnull(pInView)) then
            myprint("控件为空===========actionEnterScene")
            return
        end
        pInView:setVisible(true)
        -- 移动界面
        local scale = cc.ScaleTo:create(_fTime, 1)
        local fade = cc.FadeIn:create(_fTime)
        local sqawn = cc.Spawn:create(cc.EaseBackOut:create(scale), fade)
        -- 移动后携带的参数
        local tParams = {}
        tParams.onComplete = function()
                _nHandler()
            end
        -- 执行动作
        transition.execute(pInView, sqawn , tParams) 
    end, 1)
end

-- 界面的进场动画
-- pView（SView）：当前界面
-- fTime（float）：进入界面的时间
-- nHandler（function）：进入界面后的回调函数
-- nMode（int）: 进入动画类型  1：从左到右    2：从右到左
function actionEnterScene(pView, fTime, nHandler, nMode)
    local nMode = nMode or 1
    fTime = fTime or UIAction.fDlgEnterDuration
    local moveVec = nil
    if nMode == 1 then
        moveVec = cc.p(pView:getWidth()*2/3, 0)
        pView:setPositionX(pView:getPositionX() - moveVec.x)
    elseif nMode == 2 then
        moveVec = cc.p(-pView:getWidth()*2/3, 0)
        pView:setPositionX(pView:getPositionX() - moveVec.x)
    end
    pView:setPositionY(pView:getPositionY() - moveVec.y)
    pView:setVisible(false)
    pView:setOpacity(1)
    scheduleOnceCallback(RootLayerHelper:getCurRootLayer(), function (  )
        if(tolua.isnull(pView)) then
            myprint("控件为空===========actionEnterScene")
            return
        end
        pView:setVisible(true)
        -- 移动界面
        local moveBy = cc.MoveBy:create(fTime, moveVec)
        local fadein = cc.FadeIn:create(fTime)
        local action = cc.Spawn:create(moveBy, fadein)
        -- 移动后携带的参数
        local tParams = {}
        tParams.onComplete = function()
                nHandler()
            end
        -- 执行动作
        transition.execute(pView, action, tParams) 
    end, 1)
end


-- 界面的出场动画
-- pView（SView）：当前界面
-- fTime（float）：进入界面的时间
-- nHandler（function）：进入界面后的回调函数
function actionExitScene(pView, fTime, nHandler)
    fTime = fTime or UIAction.fDlgExitDuration
    local moveVec = cc.p(pView:getWidth(), 0)
    pView:setPositionX(pView:getPositionX())
    pView:setPositionY(pView:getPositionY() - moveVec.y)
    scheduleOnceCallback(RootLayerHelper:getCurRootLayer(), function (  )
        if(tolua.isnull(pView)) then
            myprint("控件为空===========actionExitScene")
            return
        end
        -- 移动界面
        local moveBy = cc.MoveBy:create(fTime, moveVec)
        -- 移动后携带的参数
        local tParams = {}
        tParams.onComplete = function()
                nHandler()
            end
        -- 执行动作
        transition.execute(pView, moveBy, tParams) 
    end, 1)
end