------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 14:57:24
-- @Description: 只有3种状态的按钮
------------------------------

--------------------------------
-- @module MPushButton

--[[--

quick 按钮控件

]]

local MButton = import(".MButton")
local MPushButton = myclass("MPushButton", MButton)

MPushButton.NORMAL   = "normal"
MPushButton.PRESSED  = "pressed"
MPushButton.DISABLED = "disabled"

-- start --

--------------------------------
-- 按钮控件构建函数
-- @function [parent=#MPushButton] ctor
-- @param table images 各种状态的图片
-- @param table options 参数表 其中scale9为是否缩放

--[[--

按钮控件构建函数

状态值:
-   normal 正常状态
-   pressed 按下状态
-   disabled 无效状态

]]
-- end --

function MPushButton:ctor(images, options)
    MPushButton.super.ctor(self, {
        {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
        {name = "enable",  from = {"disabled"}, to = "normal"},
        {name = "press",   from = "normal",  to = "pressed"},
        {name = "release", from = "pressed", to = "normal"},
    }, "normal", options)
    if type(images) ~= "table" then images = {normal = images} end
    self:__setButtonImage(MPushButton.NORMAL, images["normal"], true)
    self:__setButtonImage(MPushButton.PRESSED, images["pressed"], true)
    self:__setButtonImage(MPushButton.DISABLED, images["disabled"], true)

    self.args_ = {images, options}
    -- 设置类型
    self:__setViewType(MUI.VIEW_TYPE.pushbutton)
end

function MPushButton:__setButtonImage(state, image, ignoreEmpty)
    assert(state == MPushButton.NORMAL
        or state == MPushButton.PRESSED
        or state == MPushButton.DISABLED,
        string.format("MPushButton:__setButtonImage() - invalid state %s", tostring(state)))
    MPushButton.super.setButtonImage(self, state, image, ignoreEmpty)
    -- 取消按下和取消状态的默认使用
    -- if state == MPushButton.NORMAL then
    --     if not self.images_[MPushButton.PRESSED] then
    --         self.images_[MPushButton.PRESSED] = image
    --     end
    --     if not self.images_[MPushButton.DISABLED] then
    --         self.images_[MPushButton.DISABLED] = image
    --     end
    -- end

    return self
end

function MPushButton:createCloneInstance_()
    return MPushButton.new(unpack(self.args_))
end
-- 自定按钮的处理事件
-- @param type paramname
-- @param type paramname-- @return
function MPushButton:__onButtonTouchEvent( event )
    if(not self:isViewEnabled(  )) then
        return 
    end
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:__checkTouchInSprite(x, y, false) then return false end
        self.fsm_:doEvent("press")
        return true
    end

    local touchInTarget = self:__checkTouchInSprite(self.touchBeganX, self.touchBeganY, true)
                        and self:__checkTouchInSprite(x, y, true)
    if name == "moved" then
        if touchInTarget and self.fsm_:canDoEvent("press") then
            self.fsm_:doEvent("press")
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
        end
    else
        if self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
        end
    end
end
-- 设置按钮上的文字
-- _labelparams（table or string）：按钮的参数
function MPushButton:setString( _labelparams )
    if(not _labelparams) then
        printMUI("请输入按钮文字的内容和参数")
        return
    end
    -- 只处理正常状态的文字
    local pLabel = self.labels_["normal"]
    if(not pLabel) then -- 不存在，创建一个新的
        self:setButtonLabel("normal",  MUI.MLabel.new({text="",
            size=22, color=cc.c3b(255, 255, 255)}))
        pLabel = self.labels_["normal"]
    end
    local tDa = _labelparams
    if(type(_labelparams) == "string") then
        tDa = {}
        tDa.text = _labelparams
    end
    if(pLabel) then
        pLabel:setString(tDa.text or "",false)
        pLabel:setTextColor(tDa.color or pLabel:getTextColor())
        pLabel:setSystemFontSize(tDa.size or pLabel:getSystemFontSize() or 22)
    end
end
-- 设置图片的名称（直接对normal状态进行处理）
-- _image(string): 当前图片的相对路径
function MPushButton:setButtonImage( _image, _state )
    if(not _image) then
        return
    end
    if _state == nil then
        self:__setButtonImage(MPushButton.NORMAL, _image, false)
    else
        self:setButtonImageForce(MPushButton.NORMAL, _image, false)
    end
    self:updateButtonLable_()
end

return MPushButton
