------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 10:32:52
-- @Description: 自定义复选框
------------------------------

--------------------------------
-- @module MCheckBoxButton

local MButton = import(".MButton")
local MCheckBoxButton = myclass("MCheckBoxButton", MButton)

MCheckBoxButton.OFF          = "off"
MCheckBoxButton.OFF_PRESSED  = "off_pressed"
MCheckBoxButton.OFF_DISABLED = "off_disabled"
MCheckBoxButton.ON           = "on"
MCheckBoxButton.ON_PRESSED   = "on_pressed"
MCheckBoxButton.ON_DISABLED  = "on_disabled"

-- start --

--------------------------------
-- UICheckBoxButton构建函数
-- @function [parent=#MCheckBoxButton] new
-- @param table images checkButton各种状态的图片表
-- @param table options 参数表

-- end --

function MCheckBoxButton:ctor(images, options)
    MCheckBoxButton.super.ctor(self, {
        {name = "disable",  from = {"off", "off_pressed"}, to = "off_disabled"},
        {name = "disable",  from = {"on", "on_pressed"},   to = "on_disabled"},
        {name = "enable",   from = {"off_disabled"}, to = "off"},
        {name = "enable",   from = {"on_disabled"},  to = "on"},
        {name = "press",    from = "off", to = "off_pressed"},
        {name = "press",    from = "on",  to = "on_pressed"},
        {name = "release",  from = "off_pressed", to = "off"},
        {name = "release",  from = "on_pressed", to = "on"},
        {name = "select",   from = "off", to = "on"},
        {name = "select",   from = "off_disabled", to = "on_disabled"},
        {name = "unselect", from = "on", to = "off"},
        {name = "unselect", from = "on_disabled", to = "off_disabled"},
    }, "off", options)
    self:setButtonImage(MCheckBoxButton.OFF, images["off"], true)
    self:setButtonImage(MCheckBoxButton.OFF_PRESSED, images["off_pressed"], true)
    self:setButtonImage(MCheckBoxButton.OFF_DISABLED, images["off_disabled"], true)
    self:setButtonImage(MCheckBoxButton.ON, images["on"], true)
    self:setButtonImage(MCheckBoxButton.ON_PRESSED, images["on_pressed"], true)
    self:setButtonImage(MCheckBoxButton.ON_DISABLED, images["on_disabled"], true)
    self.labelAlign_ = display.CENTER

    self.args_ = {images, options}
    -- 设置类型
    self:__setViewType(MUI.VIEW_TYPE.checkbutton)
end

-- start --

--------------------------------
-- 设置单个状态的图片
-- @function [parent=#MCheckBoxButton] setButtonImage
-- @param string state checkButton状态
-- @param string image 图片路径
-- @param boolean ignoreEmpty 忽略image为nil
-- @return MCheckBoxButton#MCheckBoxButton  自身

-- end --

function MCheckBoxButton:setButtonImage(state, image, ignoreEmpty)
    assert(state == MCheckBoxButton.OFF
        or state == MCheckBoxButton.OFF_PRESSED
        or state == MCheckBoxButton.OFF_DISABLED
        or state == MCheckBoxButton.ON
        or state == MCheckBoxButton.ON_PRESSED
        or state == MCheckBoxButton.ON_DISABLED,
        string.format("MCheckBoxButton:setButtonImage() - invalid state %s", tostring(state)))
    MCheckBoxButton.super.setButtonImage(self, state, image, ignoreEmpty)
    if state == MCheckBoxButton.OFF then
        if not self.images_[MCheckBoxButton.OFF_PRESSED] then
            self.images_[MCheckBoxButton.OFF_PRESSED] = image
        end
        if not self.images_[MCheckBoxButton.OFF_DISABLED] then
            self.images_[MCheckBoxButton.OFF_DISABLED] = image
        end
    elseif state == MCheckBoxButton.ON then
        if not self.images_[MCheckBoxButton.ON_PRESSED] then
            self.images_[MCheckBoxButton.ON_PRESSED] = image
        end
        if not self.images_[MCheckBoxButton.ON_DISABLED] then
            self.images_[MCheckBoxButton.ON_DISABLED] = image
        end
    end

    return self
end

-- start --

--------------------------------
-- 是否选中状态
-- @function [parent=#MCheckBoxButton] isButtonSelected
-- @return boolean#boolean  选中与否

-- end --

function MCheckBoxButton:isButtonSelected()
    return self.fsm_:canDoEvent("unselect")
end

-- start --

--------------------------------
-- 设置选中状态
-- @function [parent=#MCheckBoxButton] setButtonSelected
-- @param boolean selected 选中与否
-- @return MCheckBoxButton#MCheckBoxButton  自身

-- end --

function MCheckBoxButton:setButtonSelected(selected)
    if self:isButtonSelected() ~= selected then
        if selected then
            self.fsm_:doEventForce("select")
        else
            self.fsm_:doEventForce("unselect")
        end
        self:dispatchEvent({name = MUI.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    return self
end

-- 执行自定义的触摸事件
-- @event table 触摸事件数据
function MCheckBoxButton:__onCheckButtonTouchEvent(event)
    if(not self:isViewEnabled()) then
        return
    end
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
        if not self:__checkTouchInSprite(x, y, false) then return false end
        self.fsm_:doEvent("press")
        return true
    end

    local touchInTarget = self:__checkTouchInSprite(x, y, true)
    if name == "moved" then
        if touchInTarget and self.fsm_:canDoEvent("press") then
            self.fsm_:doEvent("press")
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
        end
    else
        __removePressedScaleAction(self)
        if self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
        end
        if name == "ended" and touchInTarget then
            self:setButtonSelected(self.fsm_:canDoEvent("select"))
        end
    end
    return true
end

function MCheckBoxButton:getDefaultState_()
    local state = self.fsm_:getState()
    if state == MCheckBoxButton.ON or state == MCheckBoxButton.ON_DISABLED or state == MCheckBoxButton.ON_PRESSED then
        return {MCheckBoxButton.ON, MCheckBoxButton.OFF}
    else
        return {MCheckBoxButton.OFF, MCheckBoxButton.ON}
    end
end

function MCheckBoxButton:createCloneInstance_()
    return MCheckBoxButton.new(unpack(self.args_))
end

return MCheckBoxButton
