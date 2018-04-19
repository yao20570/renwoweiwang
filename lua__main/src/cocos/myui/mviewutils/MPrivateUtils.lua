------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-11-12 00:22:15
-- @Description: 私有工具类
------------------------------
N_TAG_MVIEW_SCALE_ACTION = 38792 -- 执行缩放动画的action
--[[--

创建一个文字输入框，并返回 EditBox 对象。

可用参数：

-   image: 输入框的图像，可以是图像名或者是 Sprite9Scale 显示对象。用 display.newScale9Sprite() 创建 Sprite9Scale 显示对象。
-   imagePressed: 输入状态时输入框显示的图像（可选）
-   imageDisabled: 禁止状态时输入框显示的图像（可选）
-   listener: 回调函数
-   size: 输入框的尺寸，用 cc.size(宽度, 高度) 创建
-   x, y: 坐标（可选）

~~~ lua

local function onEdit(event, editbox)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

local editbox = ui.newEditBox({
    image = "EditBox.png",
    listener = onEdit,
    size = cc.size(200, 40)
})

~~~

注意: 使用setInputFlag(0) 可设为密码输入框。

注意：构造输入框时，请使用setPlaceHolder来设定初始文本显示。setText为出现输入法后的默认文本。

注意：事件触发机制，player模拟器上与真机不同，请使用真机实测(不同ios版本貌似也略有不同)。

注意：changed事件中，需要条件性使用setText（如trim或转化大小写等），否则在某些ios版本中会造成死循环。

~~~ lua

--错误，会造成死循环

editbox:setText(string.trim(editbox:getText()))

~~~

~~~ lua

--正确，不会造成死循环
local _text = editbox:getText()
local _trimed = string.trim(_text)
if _trimed ~= _text then
    editbox:setText(_trimed)
end

~~~

@param table params 参数表格对象

@return EditBox 文字输入框

]]
function __newEditBox(params)
    local imageNormal = params.image
    local imagePressed = params.imagePressed
    local imageDisabled = params.imageDisabled

    if type(imageNormal) == "string" then
        imageNormal = display.newScale9Sprite(imageNormal)
    end
    if type(imagePressed) == "string" then
        imagePressed = display.newScale9Sprite(imagePressed)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newScale9Sprite(imageDisabled)
    end

    local editboxCls
    if cc.bPlugin_ then
        editboxCls = ccui.EditBox
    else
        editboxCls = cc.EditBox
    end
    local editbox = editboxCls:create(params.size, imageNormal, imagePressed, imageDisabled)

    if editbox then
        if params.font then
            editbox:setFontName(params.font)
        else
            editbox:setFontName(MUI.DEFAULT_FONT)
        end
        if params.fontColor then
            editbox:setFontColor(cc.c3b(params.fontColor.r or 255, params.fontColor.g or 255, params.fontColor.b or 255))
        end
        if params.fontSize then
            editbox:setFontSize(params.fontSize)
        end
        if params.placeHolder then
            editbox:setPlaceHolder(params.placeHolder)
        end
        if params.maxLength and 0 ~= params.maxLength then
            editbox:setMaxLength(params.maxLength)
        end
        if params.passwordEnable then
            editbox:setInputFlag(MUI.MINPUT_FLAG.PASSWORD)
        end
        if params.listener then
            editbox:registerScriptEditBoxHandler(params.listener)
        end
        if params.x and params.y then
            editbox:setPosition(params.x, params.y)
        end
        if params.text then
            if editbox.setString then
                editbox:setString(params.text)
            else
                editbox:setText(params.text)
            end
        end
        
        

    end

    return editbox
end

--[[--

创建一个文字输入框，并返回 Textfield 对象。

可用参数：

-   listener: 回调函数
-   size: 输入框的尺寸，用 cc.size(宽度, 高度) 创建
-   x, y: 坐标（可选）
-   placeHolder: 占位符(可选)
-   text: 输入文字(可选)
-   font: 字体
-   fontSize: 字体大小
-   maxLength:
-   passwordEnable:开启密码模式
-   passwordChar:密码代替字符

~~~ lua

local function onEdit(textfield, eventType)
    if event == 0 then
        -- ATTACH_WITH_IME
    elseif event == 1 then
        -- DETACH_WITH_IME
    elseif event == 2 then
        -- INSERT_TEXT
    elseif event == 3 then
        -- DELETE_BACKWARD
    end
end

local textfield = MInput.new({
    UIInputType = 2,
    listener = onEdit,
    size = cc.size(200, 40)
})

~~~

@param table params 参数表格对象

@return Textfield 文字输入框

]]
function __newTextField(params)
    local textfieldCls
    if cc.bPlugin_ then
        textfieldCls = ccui.TextField
    else
        textfieldCls = cc.TextField
    end
    local editbox = textfieldCls:create()
    if(params.image) then
        local imageNormal = display.newScale9Sprite(params.image)
        if(params.size) then
            imageNormal:setContentSize(params.size)
        end
        editbox:addChild(imageNormal, -10)
    end
    editbox:setPlaceHolder(params.placeHolder)
    local ppp = editbox:getVirtualRenderer()
    if params.x and params.y then
        editbox:setPosition(params.x, params.y)
    end
    if params.listener then
        editbox:addEventListener(params.listener)
    end
    if params.size then
        editbox:setTextAreaSize(params.size)
        editbox:setTouchSize(params.size)
        editbox:setTouchAreaEnabled(true)
    end
    if params.text then
        if editbox.setString then
            editbox:setString(params.text)
        else
            editbox:setText(params.text)
        end
    end
    if params.font then
        editbox:setFontName(params.font)
    end
    if params.fontSize then
        editbox:setFontSize(params.fontSize)
    end
    if params.fontColor then
        editbox:setTextColor(cc.c4b(params.fontColor.R or 255, params.fontColor.G or 255, params.fontColor.B or 255, 255))
    end
    if params.maxLength and 0 ~= params.maxLength then
        editbox:setMaxLengthEnabled(true)
        editbox:setMaxLength(params.maxLength)
    end
    if params.passwordEnable then
        editbox:setPasswordEnabled(true)
    end
    if params.passwordChar then
        editbox:setPasswordStyleText(params.passwordChar)
    end

    return editbox
end
-- 创建一个新的数字标签
-- params（table）：数字标签的参数
function __newLabelAtlas( params )
    local pView = nil
    local txt = params.text or "" -- 文本内容
    local pngname = params.png -- png图片的相对路径
    local itemw = params.pngw -- png图片的宽度
    local itemh = params.pngh -- png图片的高度
    local startCharMap = params.scm -- 开始字符的unicode值
    pView = cc.Label:createWithCharMap(pngname, itemw, itemh, params.scm)
    pView:setString(txt)
    return pView
end

MultiTouched = false --是否处于多点触摸情况下

-- 执行MView的多点触摸捕获事件
-- _pView(MView): 当前的控件
-- event(table): 当前触摸的事件
function __doMViewDispatchMultiTouchEvent( _pView, event )
    -- body
    if _pView.eViewType == MUI.VIEW_TYPE.scrollview then
        if _pView.onMuiTouch_ then
            _pView:onMuiTouch_(event)
        end
        return false
    end

    -- 获取所有的子节点
    local pChilds = _pView:getChildren()
    -- 获取子节点的总个数
    local nChildCount = #pChilds
    -- 一定要倒序获取触摸
    for i=nChildCount, 1, -1 do
        local pChild = pChilds[i]
        -- 必须是MView
        if pChild and pChild.bMView and pChild:isVisible() and pChild.__dispatchMultiTouchEvent 
        and pChild:__dispatchMultiTouchEvent(event) == false then
            return false
        end
    end
    return true
end
-- 是否为复杂的触摸控件
-- _pView(MView)：当前控件
function __isComplicatedTouchView( _pView )
    if(not _pView or not _pView.eViewType) then
        return false
    end
    if(_pView.eViewType == MUI.VIEW_TYPE.scrollview
        or _pView.eViewType == MUI.VIEW_TYPE.pageview
        or _pView.eViewType == MUI.VIEW_TYPE.listview) then
        return true
    end
    return false
end

local SWALLOWED_TOUCHED_NODE = nil -- 吞噬节点
local SIMPLE_TOUCHED_NODE = nil -- 当前选中的简单节点
-- 执行MView的触摸捕获事件
-- _pView(MView): 当前的控件
-- event(table): 当前触摸的事件
-- return(boolean): 返回是否可以继续执行触摸
function __doMViewDispatchTouchEvent( _pView, event )
    local bResult, nHandleType = nil, nHandleType
    if(_pView.eViewType == MUI.VIEW_TYPE.scrollview
        or _pView.eViewType == MUI.VIEW_TYPE.pageview
        or _pView.eViewType == MUI.VIEW_TYPE.listview) then
        if(SWALLOWED_TOUCHED_NODE == nil) then -- 是否存在吞噬节点
            bResult, nHandleType = _pView:__onTouchEvent(event)
            if not bResult then
                if(event.name == "began") then
                    --取消多点触摸控制
                    MultiTouched = false
                    return false
                elseif(event.name == "moved") then
                    return false
                end
            end
        end
    end
    if(event.name == "began") then
        --取消多点触摸控制
        MultiTouched = false
        -- 重置触摸的控件
        _pView.pCurTouchedView = nil
        SWALLOWED_TOUCHED_NODE = nil
        SIMPLE_TOUCHED_NODE = nil
        -- 获取所有的子节点
        local pChilds = _pView:getChildren()
        -- 获取子节点的总个数
        local nChildCount = #pChilds
        local inSideScreen = true
        -- 一定要倒序获取触摸
        for i=nChildCount, 1, -1 do
            local pChild = pChilds[i]
            -- 判断是否在屏幕范围内，默认是true
            inSideScreen = true
            if(pChild and pChild.isInsideScreen and not pChild:isInsideScreen()) then
                inSideScreen = false
            end
            -- 必须是MView
            if(inSideScreen 
                and pChild 
                and pChild.bMView 
                and pChild:isVisible() 
                and pChild.__dispatchTouchEvent
                and pChild:__dispatchTouchEvent(event)) then

                _pView.pCurTouchedView = pChild
                -- 记录最后选中的拖动条
                if(pChild.getTouchCatchedInList and pChild:getTouchCatchedInList()) then
                    SWALLOWED_TOUCHED_NODE = pChild
                end
                if(not __isComplicatedTouchView(pChild)) then
                    if(SIMPLE_TOUCHED_NODE == nil) then
                        SIMPLE_TOUCHED_NODE = pChild
                    end
                end
                return true
            end
        end
    end
    -- 如果在拖动了列表，取消子控件的触摸事件
    if(event.name == "moved") then
        if(nHandleType == MUI.TOUCH_HANDLE_TYPE.MOVED) then
            if(_pView.pCurTouchedView 
                and _pView.pCurTouchedView.m_nIdentify == SIMPLE_TOUCHED_NODE.m_nIdentify 
                and _pView.pCurTouchedView.__dispatchTouchEvent) then

                local tEv = {}
                tEv.name = "ended"
                -- 刻意增加x的值，取消当前控件的触摸选中状态
                tEv.x = event.x+10000
                tEv.y = event.y
                tEv.prevX = event.prevX
                tEv.prevY = event.prevY
                local bResult = _pView.pCurTouchedView:__dispatchTouchEvent( tEv )
                _pView.pCurTouchedView = nil
                SIMPLE_TOUCHED_NODE = nil
                return true
            end
        end
    end
    -- 取消全局触摸的拖动条
    if(event.name == "ended" and _pView.pCurTouchedView 
        and _pView.pCurTouchedView.getTouchCatchedInList
        and _pView.pCurTouchedView:getTouchCatchedInList()) then
        SWALLOWED_TOUCHED_NODE = nil
    end
    if(_pView.pCurTouchedView and _pView.pCurTouchedView.__dispatchTouchEvent) then
        event.hadMulTouched = MultiTouched
        -- 强制设置了点击事件(特地为聊天的发送按钮指定的)
        if(_pView.pCurTouchedView.__ftc) then
            event.__ftc = true
        end
        local bResult = _pView.pCurTouchedView:__dispatchTouchEvent( event )
        -- 结束后关闭触摸的控件
        if(event.name == "ended") then
            _pView.pCurTouchedView = nil
            SIMPLE_TOUCHED_NODE = nil
        end
        return bResult
    end
    -- 如果已经执行过了回调，直接返回回调结果
    if(bResult ~= nil) then
        return bResult
    end
    -- 执行自身的触摸判断
    return _pView:__onTouchEvent(event)
end
-- 执行触摸时缩放的Action
-- _pView(MView): 当前选中的MView
function __doPressedScaleAction( _pView )
    if(not _pView:getIsPressedNeedScale() and not _pView:getIsPressedNeedColor()) then
        return
    end
    if(_pView:getIsPressedNeedScale()) then
        -- 使用计数器记录按下缩放的次数，只保留第一次的原始缩放比例
        _pView.__nUnderPressedCount = _pView.__nUnderPressedCount or 0
        if(_pView.__nUnderPressedCount == 0) then
            -- 如果没有在触摸的状态下，记录当前的缩放大小
            _pView.fFinalSx = _pView:getScaleX() 
            _pView.fFinalSy = _pView:getScaleY()
        end
        local fCurSx = _pView.fFinalSx * 0.8
        local fCurSy = _pView.fFinalSy * 0.8
        _pView.__nUnderPressedCount = _pView.__nUnderPressedCount + 1
        local pAction = cc.ScaleTo:create(0.05, fCurSx, fCurSy)
        pAction:setTag(N_TAG_MVIEW_SCALE_ACTION)
        _pView:runAction(pAction)
    end
    if(_pView:getIsPressedNeedColor()) then
        _pView:setColor(cc.c3b(100, 100, 100))
    end
end
-- 释放点击时的缩放动作
-- _pView(MView): 当前选中的MView
function __removePressedScaleAction( _pView )
    if(not _pView:getIsPressedNeedScale() and not _pView:getIsPressedNeedColor()) then
        return
    end
    if(_pView:getIsPressedNeedScale()) then
        local pAction = cc.ScaleTo:create(0.05, _pView.fFinalSx, _pView.fFinalSy)
        pAction:setTag(N_TAG_MVIEW_SCALE_ACTION)
        _pView:runAction(cc.Sequence:create(pAction,
            cc.CallFunc:create(function (  )
                -- 减少按下缩放的次数计数器
                _pView.__nUnderPressedCount = _pView.__nUnderPressedCount - 1
            end)))
    end
    if(_pView:getIsPressedNeedColor()) then
        _pView:setColor(cc.c3b(255, 255, 255))
    end
end
-- 根据类型获取是否可以增加子MView
-- _eType（MUI.VIEW_TYPE）：当前类型
function __isCanAddMView( _eType )
    if(_eType == MUI.VIEW_TYPE.image
        or _eType == MUI.VIEW_TYPE.label
        or _eType == MUI.VIEW_TYPE.button
        or _eType == MUI.VIEW_TYPE.slider
        or _eType == MUI.VIEW_TYPE.checkbutton
        or _eType == MUI.VIEW_TYPE.loadingbar
        or _eType == MUI.VIEW_TYPE.input
        or _eType == MUI.VIEW_TYPE.pushbutton) then
        return false
    end
    return true
end
-- 将世界坐标转成当前节点的父控件的坐标系坐标
-- 目的是为了配合当前节点的getBoundingBox方法
-- _view(CCNode): 当前节点
-- _x(float): 当前世界坐标的x值
-- _y(float): 当前世界坐标的y值
function __convertToRealPoint( _view, _x, _y )
    local pParView = _view:getParent()
    if(pParView) then
        local curPoint = pParView:convertToNodeSpace(cc.p(_x, _y))
        return curPoint.x, curPoint.y
    end
    return 0, 0
end
-- 延迟执行某个行为
-- _view（ccnode）：需要执行的控件
-- _handler（function）：延迟后的回调函数
-- _time（float）：延迟时间
function __performActionDelay( _view, _handler, _time )
    local action = cc.Sequence:create(
        cc.DelayTime:create(_time),
        cc.CallFunc:create(function ()
            _handler()
        end))
    _view:runAction(action)
end

-- 关闭输入框
function gCloseKeyboard( _pView )	
    -- 不能用tolua来判断，因为SHOWING_EDITBOX有可能已被释放，但java或ios的输入框和键盘还在
    if SHOWING_EDITBOX == nil then    
        return false
    end

    -- 有可能IS_SHOW_KEYBROAD没来得及设置，SHOWING_EDITBOX就被释放了
    if tolua.isnull(SHOWING_EDITBOX) == true then        
        IS_SHOW_KEYBROAD = true 
    end

    -- android在打开输入0.2秒(lua设置了0.3)后才开始打开键盘
    if IS_SHOW_KEYBROAD == false then        
        return false
    end

    --延迟执行输入框的显示
    if(g_cur_rootlayer and g_cur_rootlayer.performWithDelay) then  
        -- 正在关闭中
        if(g_editclosing == true) then          
            return false
        end          
        g_editclosing = true
        g_cur_rootlayer:performWithDelay(function (  )        	
            if tolua.isnull(SHOWING_EDITBOX) == false then
                SHOWING_EDITBOX:setVisible(true)
            end
            -- 强制置为空
            SHOWING_EDITBOX = nil
            g_editclosing = false
        end, 0.25)
    end


    if(device.platform == "android") then        
        -- call Java method
        local javaClassName = "com/andgame/mgr/GameBridge"
        local javaMethodName = "endGlobalEditText"
        local javaParams = {}
        local javaMethodSig = "()V"
        luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
    elseif(device.platform == "ios") then
        local param = {}
        local luaoc = require("framework.luaoc")
        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", "closeKeyboard", param)
    end
    
    return true
end
