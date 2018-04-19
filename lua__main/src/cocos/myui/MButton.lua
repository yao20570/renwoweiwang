------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 16:10:46
-- @Description: 自定义按钮，这个类作为基类，一般不new出来
------------------------------

local MView = import(".MView")

local MButton = myclass("MButton", function ( )
    return MView.new(MUI.VIEW_TYPE.button)
end)

MButton.IMAGE_ZORDER = -100
MButton.LABEL_ZORDER = 0

-- start --

--------------------------------
-- MButton构建函数
-- @function [parent=#MButton] new
-- @param table events 按钮状态表
-- @param string initialState 初始状态
-- @param table options 参数表

-- end --

function MButton:ctor(events, initialState, options)
    self.args_ = {events, initialState, options}
    makeMUIControl_(self)

    self.fsm_ = {}
    cc(self.fsm_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()

    self.fsmState_ = {
        initial = {state = initialState, event = "startup", defer = false},
        events = events,
        callbacks = {
            onchangestate = handler(self, self.onChangeState_),
        }
    }
    self.fsm_:setupState(self.fsmState_)
    
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)
    -- self:__setButtonEnabled(true)

    self.touchInSpriteOnly_ = options and options.touchInSprite
    self.currentImage_ = nil
    self.images_ = {}
    self.sprite_ = {}
    self.scale9_ = options and options.scale9
    self.flipX_ = options and options.flipX
    self.flipY_ = options and options.flipY
    self.scale9Size_ = nil
    self.labels_ = {}
    self.labelOffset_ = {0, 0}
    self.labelAlign_ = display.CENTER
    self.initialState_ = initialState

    display.align(self, display.CENTER)

    if "boolean" ~= type(self.flipX_) then
        self.flipX_ = false
    end
    if "boolean" ~= type(self.flipY_) then
        self.flipY_ = false
    end

    self:onNodeEvent("enter", function (  )
        -- 执行清理回调
        self:updateButtonImage_()
    end)
    self:setViewTouched(true)
    -- 注册自己的检测范围
    self:__setChildCheckTouchInSprite(handler(self, self.childCheckTouchInSprite_))
end
-- 刷新按钮状态
function MButton:__onRefreshEnableState( bEn )
    if(bEn == nil) then
        bEn = self:isViewEnabled()
    end
    -- 刷新按钮使用图片的状态
    self:__setButtonEnabled(bEn)
    -- 刷新图片的状态
    if(self.sprite_) then
        for i, v in pairs(self.sprite_) do
            changeSpriteEnabledShowState(v, bEn)
        end
    end
end

-- 刷新按钮状态是否置灰
function MButton:__onRefreshGrayState( bEn )
    if(bEn == nil) then
        bEn = self:isViewGray()
         bEn = not bEn
    end
    -- 刷新图片的状态
    if(self.sprite_) then
        for i, v in pairs(self.sprite_) do
            changeSpriteEnabledShowState(v, bEn)
        end
    end
end

-- start --

--------------------------------
-- 停靠位置
-- @function [parent=#MButton] align
-- @param number align 锚点位置
-- @param number x
-- @param number y
-- @return MButton#MButton 

-- end --

function MButton:align(align, x, y)
    display.align(self, align, x, y)
    self:updateButtonImage_()
    self:updateButtonLable_()

    local size = self:getCascadeBoundingBox().size
    local ap = self:getAnchorPoint()

    -- self:setPosition(x + size.width * (ap.x - 0.5), y + size.height * (0.5 - ap.y))
    return self
end

-- start --

--------------------------------
-- 设置按钮特定状态的图片
-- @function [parent=#MButton] setButtonImage
-- @param string state 状态
-- @param string image 图片路径
-- @param boolean ignoreEmpty 是否忽略空的图片路径
-- @return MButton#MButton 

-- end --

function MButton:setButtonImage(state, image, ignoreEmpty)
    if ignoreEmpty and image == nil then return end
    self.images_[state] = image
    if state == self.fsm_:getState() then
        self:updateButtonImage_()
    end
    return self
end

--强制设置按钮图片（忽略状态）
function MButton:setButtonImageForce(state, image, ignoreEmpty)
    if ignoreEmpty and image == nil then return end
    self.images_[state] = image
    self:updateButtonImage_()
    return self
end

-- start --

--------------------------------
-- 设置按钮特定状态的文字node
-- @function [parent=#MButton] setButtonLabel
-- @param string state 状态
-- @param node label 文字node
-- @return MButton#MButton 

-- end --

function MButton:setButtonLabel(state, label)
    if not label then
        label = state
        state = self:getDefaultState_()
    end
    assert(label ~= nil, "MButton:setButtonLabel() - invalid label")

    if type(state) == "table" then state = state[1] end
    local currentLabel = self.labels_[state]
    if currentLabel then currentLabel:removeSelf() end

    self.labels_[state] = label
    self:addChild(label, MButton.LABEL_ZORDER)
    self:updateButtonLable_()
    return self
end

-- start --

--------------------------------
-- 返回按钮特定状态的文字
-- @function [parent=#MButton] getButtonLabel
-- @param string state 状态
-- @return node#node  文字label

-- end --

function MButton:getButtonLabel(state)
    if not state then
        state = self:getDefaultState_()
    end
    if type(state) == "table" then state = state[1] end
    return self.labels_[state]
end

-- start --

--------------------------------
-- 设置按钮特定状态的文字
-- @function [parent=#MButton] setButtonLabelString
-- @param string state 状态
-- @param string text 文字
-- @return MButton#MButton 

-- end --

function MButton:setButtonLabelString(state, text)
    assert(self.labels_ ~= nil, "MButton:setButtonLabelString() - not add label")
    if text == nil then
        text = state
        for _, label in pairs(self.labels_) do
            label:setString(text)
        end
    else
        local label = self.labels_[state]
        if label then label:setString(text) end
    end
    return self
end

-- start --

--------------------------------
-- 设置按钮特定状态的文字
-- @function [parent=#MButton] setButtonLabelString
-- @param string state 状态
-- @param string text 文字
-- @return MButton#MButton 

-- end --

function MButton:getButtonLabelString()
    assert(self.labels_ ~= nil, "MButton:setButtonLabelString() - not add label")
    local label = self.labels_["normal"]
    if label then
        return label:getString()
    else
        return ""
    end
end


-- start --

--------------------------------
-- 返回文字标签的偏移
-- @function [parent=#MButton] getButtonLabelOffset
-- @return number#number  x
-- @return number#number  y

-- end --

function MButton:getButtonLabelOffset()
    return self.labelOffset_[1], self.labelOffset_[2]
end

-- start --

--------------------------------
-- 设置文字标签的偏移
-- @function [parent=#MButton] setButtonLabelOffset
-- @param number ox
-- @param number oy
-- @return MButton#MButton 

-- end --

function MButton:setButtonLabelOffset(ox, oy)
    self.labelOffset_ = {ox, oy}
    self:updateButtonLable_()
    return self
end

-- start --

--------------------------------
-- 得到文字标签的停靠方式
-- @function [parent=#MButton] getButtonLabelAlignment
-- @return number#number 

-- end --

function MButton:getButtonLabelAlignment()
    return self.labelAlign_
end

-- start --

--------------------------------
-- 设置文字标签的停靠方式
-- @function [parent=#MButton] setButtonLabelAlignment
-- @param number align
-- @return MButton#MButton 

-- end --

function MButton:setButtonLabelAlignment(align)
    self.labelAlign_ = align
    self:updateButtonLable_()
    return self
end

function MButton:addButtonStateChangedEventListener(callback)
    return self:addEventListener(MUI.STATE_CHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册按钮状态变化监听
-- @function [parent=#MButton] onButtonStateChanged
-- @param function callback 监听函数
-- @return MButton#MButton 

-- end --

function MButton:onButtonStateChanged(callback)
    if(not self.__nButtonStateChangedCallback) then
        self:addEventListener(MUI.STATE_CHANGED_EVENT, 
            handler(self, self.__doButtonStateChanged))
    end
    self.__nButtonStateChangedCallback = callback
    return self
end
-- 执行状态变化的回调
-- @event table 状态的变化， event.state="on"为选中，event.state="off"为未选中
function MButton:__doButtonStateChanged( event )
    if(self.__nButtonStateChangedCallback) then
        self.__nButtonStateChangedCallback(event.state=="on")
    end
end

-- start --

--------------------------------
-- 设置按钮的大小
-- @function [parent=#MButton] setButtonSize
-- @param number width
-- @param number height
-- @return MButton#MButton 

-- end --

function MButton:setButtonSize(width, height)
    -- assert(self.scale9_, "MButton:setButtonSize() - can't change size for non-scale9 button")
    self.scale9Size_ = {width, height}
    for i,v in ipairs(self.sprite_) do
        if self.scale9_ then
            v:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        else
            local size = v:getContentSize()
            local scaleX = 1
            local scaleY = 1
            -- scaleX = v:getScaleX()
            -- scaleY = v:getScaleY()
            scaleX = scaleX * self.scale9Size_[1]/size.width
            scaleY = scaleY * self.scale9Size_[2]/size.height
            v:setScaleX(scaleX)
            v:setScaleY(scaleY)
        end
    end
    return self
end

-- start --

--------------------------------
-- 设置按钮是否有效
-- @function [parent=#MButton] __setButtonEnabled
-- @param boolean enabled 是否有效
-- @return MButton#MButton 

-- end --

function MButton:__setButtonEnabled(enabled)
    -- self:setTouchEnabled(enabled) --如果true,触摸事件被ccNode捕获了，这个注释掉
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = MUI.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = MUI.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    return self
end

-- start --

--------------------------------
-- 返回按钮是否有效
-- @function [parent=#MButton] __isButtonEnabled
-- @return boolean#boolean 

-- end --

function MButton:__isButtonEnabled()
    return self.fsm_:canDoEvent("disable")
end

function MButton:onChangeState_(event)
    if self:isRunning() then
        self:updateButtonImage_()
        self:updateButtonLable_()
    end
end

function MButton:updateButtonImage_()
    local state = self.fsm_:getState()
    local image = self.images_[state]

    if not image then
        for _, s in pairs(self:getDefaultState_()) do
            image = self.images_[s]
            if image then break end
        end
    end
    if image then
        if self.currentImage_ ~= image then
            for i,v in ipairs(self.sprite_) do
                v:removeFromParent(true)
            end
            self.sprite_ = {}
            self.currentImage_ = image

            if "table" == type(image) then
                for i,v in ipairs(image) do
                    if self.scale9_ then
                        self.sprite_[i] = display.newScale9Sprite(v)
                        if not self.scale9Size_ then
                            local size = self.sprite_[i]:getContentSize()
                            self.scale9Size_ = {size.width, size.height}
                        else
                            self.sprite_[i]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                        end
                    else
                        self.sprite_[i] = display.newSprite(v)
                    end
                    self:addChild(self.sprite_[i], MButton.IMAGE_ZORDER)
                    if self.sprite_[i].setFlippedX then
                        if self.flipX_ then
                            self.sprite_[i]:setFlippedX(self.flipX_ or false)
                        end
                        if self.flipY_ then
                            self.sprite_[i]:setFlippedY(self.flipY_ or false)
                        end
                    end
                end
            else
                if self.scale9_ then
                    self.sprite_[1] = display.newScale9Sprite(image)
                    if not self.scale9Size_ then
                        local size = self.sprite_[1]:getContentSize()
                        self.scale9Size_ = {size.width, size.height}
                    else
                        self.sprite_[1]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                    end
                else
                    self.sprite_[1] = display.newSprite(image)
                end
                if self.sprite_[1].setFlippedX then
                    if self.flipX_ then
                        self.sprite_[1]:setFlippedX(self.flipX_ or false)
                    end
                    if self.flipY_ then
                        self.sprite_[1]:setFlippedY(self.flipY_ or false)
                    end
                end
                self:addChild(self.sprite_[1], MButton.IMAGE_ZORDER)
            end
        end

        if self.sprite_[1] then
            local spriteSize = self.sprite_[1]:getContentSize()
            self:setContentSize(cc.size(spriteSize.width,spriteSize.height))
        end
        
        for i,v in ipairs(self.sprite_) do
            v:setAnchorPoint(self:getAnchorPoint())
            v:setPosition(v:getContentSize().width / 2, v:getContentSize().height / 2)
        end
    elseif not self.labels_ then
        printError("MButton:updateButtonImage_() - not set image for state %s", state)
    end
end

function MButton:updateButtonLable_()
    if not self.labels_ then return end
    local state = self.fsm_:getState()
    local label = self.labels_[state]

    if not label then
        for _, s in pairs(self:getDefaultState_()) do
            label = self.labels_[s]
            if label then break end
        end
    end

    local ox, oy = self.labelOffset_[1], self.labelOffset_[2]
    if self.sprite_[1] then
        local ap = self:getAnchorPoint()
        local spriteSize = self.sprite_[1]:getContentSize()
        ox = ox + spriteSize.width * (0.5)
        oy = oy + spriteSize.height * (0.5)
    end

    for _, l in pairs(self.labels_) do
        l:setVisible(l == label)
        l:align(self.labelAlign_, ox, oy)
    end
end

function MButton:getDefaultState_()
    return {self.initialState_}
end

function MButton:childCheckTouchInSprite_(x, y, bEnd)
    x, y = __convertToRealPoint(self, x, y)
    if(not bEnd or not self.__pOldBoundingBox) then
        if self.touchInSpriteOnly_ then
            return self.sprite_[1] and self.sprite_[1]:getBoundingBox():containsPoint(cc.p(x, y))
        else
            return self:getBoundingBox():containsPoint(cc.p(x, y))
        end
    else
        return self.__pOldBoundingBox:containsPoint(cc.p(x, y))
    end
end

function MButton:createCloneInstance_()
    return MButton.new(unpack(self.args_))
end

function MButton:copyClonedWidgetChildren_(node)
    for state, label in pairs(node.labels_) do
        self:setButtonLabel(state, label:clone())
    end

    self:updateButtonImage_()
    self:updateButtonLable_()
end

function MButton:copySpecialProperties_(node)
    if node.scale9Size_ then
        self:setButtonSize(unpack(node.scale9Size_))
    end
    self.labelAlign_ = node.labelAlign_
    self.labelOffset_ = clone(node.labelOffset_)
    self.images_ = clone(node.images_)
    self:__setButtonEnabled(node:__isButtonEnabled())
end

return MButton
