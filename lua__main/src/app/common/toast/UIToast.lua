-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-15 09:50:22 星期三
-- Description: 展示提示语
-----------------------------------------------------

local nMaxShowCount = 10 -- 同时展示的最多个数
local tAllToastTips = {} -- 循环展示的个数
local iHorizontalMargin = 20 -- （int）水平边距
local iVerticalMargin = 10 -- （int)垂直边距
local nCurShowIndex = 0 -- 当前显示的下标
local tAllShowMsgs = {} --所有需要展示的提示语
local bSHowing = false --当前是否在展示中
local tLastMsgs = {}

-- 初始化
function doInitShowToast(  )
	-- 建立内容的控件
	for i=1, nMaxShowCount, 1 do
		local pLabelView = MUI.MLabel.new({
		    text = "0",
		    size = 22,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(display.width - iHorizontalMargin * 8, 0),
		    })
		pLabelView:setName("777")
		local w = display.width
		local h = pLabelView:getHeight() + iVerticalMargin * 2
		-- 创建背景
		local pScale = display.newScale9Sprite("ui/v1_img_tishichangtiao.png")
		local fTempH = pScale:getContentSize().height

		if(fTempH < h) then
			fTempH = h 
		end
		pScale:setTag(888)
		pScale:setContentSize(cc.size(pScale:getContentSize().width,fTempH));
		-- 使用层把背景和内容控件放在一起
		local pViewGroup = MUI.MLayer.new()
		pViewGroup:setContentSize(cc.size(w, h))
		centerInView(pViewGroup,pLabelView)
		centerInView(pViewGroup,pScale)
		pViewGroup:addChild(pScale,-1)
		pViewGroup:addView(pLabelView)
		pViewGroup:retain()
		pViewGroup:setTag(999)
		table.insert(tAllToastTips, pViewGroup)
	end
end

-- 执行初始化行为
doInitShowToast()


-- 弹出提示语
-- __str（string）：提示语的内容
-- _bIsOnly: 是否只显示一次（表里只允许一个)
function TOAST( __str, _bIsOnly)

    if tLastMsgs.str then --存在数据
        if tLastMsgs.str == __str then --判断是否同个时间内
            local fCurTime = getSystemTime()
            if fCurTime - tLastMsgs.fLastTime <= 0.5 then --短暂时间内直接返回
                -- tLastMsgs.fLastTime = getSystemTime()
                return
            end
        end
    end
    --是否只允许一个
    if _bIsOnly then
        for i=1,#tAllShowMsgs do
            if tAllShowMsgs[i] == __str then
                return
            end
        end
    end
    if(getCurConStatus() ~= e_network_status.nor) then
    else
        --插入表中
        table.insert(tAllShowMsgs, 1, __str)
    end

    if not bSHowing then --没有在展示中
        bSHowing = true
        reallyToast()
    end
end

--展示提示语
function reallyToast(  )
    -- body
    if not tAllShowMsgs or table.nums(tAllShowMsgs) <= 0 then
        bSHowing = false
        return 
    end
    -- 如果已经进入游戏了
    if(Player:getUIHomeLayer()) then
        -- 如果网络不正常
        if(getCurConStatus() ~= e_network_status.nor) then
            bSHowing = false
            return
        end
    end
    --获取最后一条提示语
    local nSize = table.nums(tAllShowMsgs)
    local __str = tAllShowMsgs[nSize]
    tAllShowMsgs[nSize] = nil
    --保存最后一条提示语相关数据
    tLastMsgs.str = __str
    tLastMsgs.fLastTime = getSystemTime()

    -- 增加计数器
    nCurShowIndex = nCurShowIndex + 1
    -- 判断不超过总个数
    if(nCurShowIndex > #tAllToastTips) then
        nCurShowIndex = 1
    end
    local pView = tAllToastTips[nCurShowIndex]
    if(pView) then
        -- 从父节点移除，停止所有动画
        pView:removeSelf()
        pView:stopAllActions()
        pView:setOpacity(255)
    end
    local pRootLayer = RootLayerHelper:getCurRootLayer()
    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if(pParView) then
        pParView:addView(pView)
        local pTxt = pView:findViewByName("777") -- 文本
        local pBg = pView:getChildByTag(888) -- 背景
        pTxt:setString(__str or "",false)
        local h = pTxt:getHeight() + iVerticalMargin * 2
        -- local fTempH = pBg:getContentSize().height
        -- if(fTempH < h) then
        --     fTempH = h 
        -- end
        --底图宽度拉伸
        local nW = 276
        if pTxt:getWidth() > 200 then 
            nW = pTxt:getWidth() + 80
        end
        pBg:setContentSize(cc.size(nW,h))
        pView:setContentSize(cc.size(pView:getWidth(), h))
        centerInView(pView,pTxt)
        pTxt:setPositionY(pTxt:getPositionY())
        centerInView(pView,pBg)
        centerInView(pParView,pView)
        pView:setPositionY(display.height*0.7)

        --表现动作
        local pAction1 = cc.MoveBy:create(0.35, cc.p(pView:getPositionX(),
            10)) -- 上移一定的像素点
        local pAction2 = cc.DelayTime:create(0.5) -- 停留一定时间
        local pAction3 = cc.Spawn:create(
            cc.MoveBy:create(0.45, cc.p(pView:getPositionX(), 30)), -- 上移
            cc.FadeOut:create(0.45)) -- 渐隐
        local pAction4 = cc.CallFunc:create(function (  )
            pView:removeSelf()
        end)
        --自身的表现集合
        local actionsStep1 = cc.Sequence:create(pAction1,pAction2,pAction3,pAction4)
        --啥时候播放下一条提示语
        local actionsDelay = cc.DelayTime:create(1.0)
        local actionNext = cc.CallFunc:create(function (  )
            -- body
            --执行下一次的提示语
            reallyToast()
        end)
        local actionsStep2 = cc.Sequence:create(actionsDelay,actionNext)
        --同时执行
        local allActions = cc.Spawn:create(actionsStep1,actionsStep2)
        pView:runAction(allActions)
    end
end