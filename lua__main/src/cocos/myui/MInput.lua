----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 16:58:30 
-- Description: 自定义输入框
-----------------------------------------------------


--------------------------------
-- @module MInput
local MView = import(".MView")


local MInput = myclass("MInput", function(options)
    local pView = MView.new(MUI.VIEW_TYPE.input, options)
    pView.__setFontSize = pView.setFontSize
    pView.__setFontColor = pView.setFontColor
    pView.__setTextColor = pView.setTextColor
    pView.__setPlaceHolder = pView.setPlaceHolder
    pView.__registerScriptEditBoxHandler = pView.registerScriptEditBoxHandler
	pView.__setText = pView.setText
    pView.mview_setVisible = pView.setVisible
    pView.__getText = pView.getText
    return pView
end)

-- start --

--------------------------------
-- 输入构建函数
-- @function [parent=#MInput] new
-- @param table params 参数表格对象
-- @return mixed#mixed  editbox/textfield文字输入框

--[[--

输入构建函数

创建一个文字输入框，并返回 EditBox/textfield 对象。

options参灵敏:
-   UIInputType: 1或nil 表示创建editbox输入控件
-   UIInputType: 2 表示创建textfield输入控件

]]
-- end --

function MInput:ctor(options)
    -- make editbox and textfield have same getText function
    if 2 == options.UIInputType then
        self.getText = self.getStringValue
    end
    self:setViewTouched(true)
    self:setIsPressedNeedScale(false)
    self:setIsPressedNeedColor(false)
    self.bSingleLine = true
    if(not options.fontColor) then
        options.fontColor = cc.c3b(255, 255, 255)
    end
    self.tmpR = options.fontColor.r or 255
    self.tmpG = options.fontColor.g or 255
    self.tmpB = options.fontColor.b or 255
    self.tmpFontSize = options.fontSize or 20
    if(self.__registerScriptEditBoxHandler) then
        self:__registerScriptEditBoxHandler(function ( _eventType )
            if(_eventType == "return" or _eventType == "ended") then
                if IS_SHOW_KEYBROAD == true then
                    if(device.platform == "android" or device.platform == "ios") then
                        self:setVisible(true)
                        print("self:__registerScriptEditBoxHandler1")
                    end
                    -- 去除输入框状态
                    SHOWING_EDITBOX = nil
                    IS_SHOW_KEYBROAD = false
                end
                -- 刷新多行内容的显示
                self:updateCoupleLineLabel()
            end
            if(self.tmpEditCallback) then
                self.tmpEditCallback(_eventType)
            end
        end)
    end

    self.args_ = options
end
-- 执行输入框的点击事件
function MInput:doInputClicked(  )
    -- 如果有另外一个输入框正在显示，不执行新的行为
    if SHOWING_EDITBOX then
        return
    end
    -- 将状态改为正在显示输入框
    SHOWING_EDITBOX = self
    IS_SHOW_KEYBROAD = false
    -- 设置初始内容
    self:resetGlobalEdit()
    -- 打开输入法
    self:touchDownAction(nil, 2)
    -- 隐藏自己
    if(device.platform == "android" or device.platform == "ios") then
        self:setVisible(false)
        -- 延迟1秒后，刷新一下特定控件的位置
        self:performWithDelay(function ()
            self:refreshEditPos()
        end, 1)
    end

    -- Android设置延迟了0.2秒才开始打开键盘
    self:performWithDelay(function ()
        IS_SHOW_KEYBROAD = true
    end, 0.5)
end
-- 刷新特定控件的位置
function MInput:refreshEditPos(  )
    if(device.platform == "android") then
        local className = "com/andgame/mgr/GameBridge"
        local methodName = "refreshShowingEditText"
        local result, ret = luaj.callStaticMethod(className, methodName, {}, "()V")
    end
end
-- 设置字体大小
-- _size（int）：字体大小
function MInput:setFontSize( _size )
    if(not _size) then
        return
    end
    self.tmpFontSize = _size
    self:__setFontSize(_size)
    if(self.m__coupleLineLabel) then
        self.m__coupleLineLabel:setSystemFontSize(_size)
    end
end
-- 设置字体颜色
-- _color（c3b）: 设置字体颜色
function MInput:setFontColor( _color )
    if(not _color) then
        return
    end
    self.tmpR = _color.r or 255
    self.tmpG = _color.g or 255
    self.tmpB = _color.b or 255
    self:__setFontColor(_color)
    if(self.m__coupleLineLabel) then
        self.m__coupleLineLabel:setTextColor(_color)
    end
end
-- 设置字体颜色
-- _color（c4b）: 设置字体颜色
function MInput:setTextColor( _color )
    if(not _color) then
        return
    end
    self.tmpR = _color.r or 255
    self.tmpG = _color.g or 255
    self.tmpB = _color.b or 255
    self:__setTextColor(_color)
    if(self.m__coupleLineLabel) then
        self.m__coupleLineLabel:setTextColor(_color)
    end
end

-- 设置输入框的相关参数
function MInput:resetGlobalEdit(  )
    if(device.platform == "android") then
        -- call Java method
        local point = self:convertToWorldSpace(cc.p(0, 0))
        local scaleX = 1 / display.width  * display.widthInPixels
        local scaleY = 1 / display.height * display.heightInPixels
        local x = point.x * scaleX - 15 * scaleX
        local y = display.heightInPixels - (point.y + self:getHeight() + 1) * scaleY
        local w = (self:getWidth() + 15 * 2) * scaleX
        -- 刻意增加10个像素点的高度
        local h = self:getHeight() * scaleY + 8 * scaleY
        local singleLine = 1 -- 是否单行输入
        if(not self.bSingleLine) then
            singleLine = 0
        end
        local javaClassName = "com/andgame/mgr/GameBridge"
        local javaMethodName = "resetGlobalEditText"
        local javaParams = {x, y, w, h, self.tmpFontSize*scaleX, self.tmpR, self.tmpG, self.tmpB, singleLine, self:getPlaceHolder()}
        local javaMethodSig = "(FFFFIIIIILjava/lang/String;)V"
        luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
    end
end
-- 设置是否单行显示
function MInput:setIsSingleLine( _b )
    self.bSingleLine = _b
    local par = self:getParent()
    if(not par) then
        print("MInput:setIsSingleLine", "请执行addView后再执行此方法")
        return
    end
    self:updateCoupleLineLabel()
end
-- 设置是否可见
function MInput:setVisible( _b )
    -- body
    if(self.bSingleLine) then
        self:mview_setVisible(_b)
    else
        if(self.m__coupleLineLabel) then
            self.m__coupleLineLabel:setVisible(_b)
        else
            self:mview_setVisible(_b)
        end
    end
end
-- 刷新多行输入框内容
function MInput:updateCoupleLineLabel(  )
    if(self.bSingleLine) then
        return
    end
    local par = self:getParent()
    if(not self.m__coupleLineLabel) then
        self.m__coupleLineLabel = MUI.MLabel.new({text="", color=cc.c3b(255, 255, 255), 
            size=20})
        self.m__coupleLineLabel:setAnchorPoint(cc.p(0, 1))
        self.m__coupleLineLabel:setDimensions(self:getContentSize().width, 0)
        local po = self:getAnchorPoint()
        par:addChild(self.m__coupleLineLabel, 977892323)
        if(par and par.bMView) then
            par:setViewTouched(true)
            par:onMViewClicked(function (  )
                self:doInputClicked()
            end)
        end
        self:mview_setVisible(false)
    end
    local str = self:getText()
    if(str == nil or string.len(str) <= 0) then
        str = self.m_placeHolder or ""
    end
    self.m__coupleLineLabel:setString(str)
end
function MInput:getCoupleLineLabel(  )
    return self.m__coupleLineLabel
end
function MInput:registerScriptEditBoxHandler( _callback )
    self.tmpEditCallback = _callback
end
--设置文字
function MInput:setText(_string )
    -- body
    --设置相机类型
    -- self:setCameraMask(MUI.CAMERA_FLAG.USER2,true)
    self:__setText(_string)
    self:updateCoupleLineLabel()
end
function MInput:setPlaceHolder( _st )
    self:__setPlaceHolder(_st)
    self.m_placeHolder = _st
end


function MInput:createcloneInstance_()
    return MInput.new(unpack(self.args_))
end

function MInput:getText( )
    local str = self:__getText()
    -- 干掉[0xaadd112]等手机表情,用*替换
    --[0x]
    str = string.gsub(str,"%[0x.-%]","*")
    return str
end
return MInput
