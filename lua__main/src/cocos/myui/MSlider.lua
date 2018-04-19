----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2016-07-11 17:03:33 
-- Description: 自定义拖动条
-----------------------------------------------------

--------------------------------
-- @module MSlider

local MView = import(".MView")

local MSlider = myclass("MSlider", function()
    return MView.new(MUI.VIEW_TYPE.slider)
end)

MSlider.BAR             = "bar"
MSlider.BUTTON          = "button"
MSlider.BAR_PRESSED     = "bar_pressed"
MSlider.BUTTON_PRESSED  = "button_pressed"
MSlider.BAR_DISABLED    = "bar_disabled"
MSlider.BUTTON_DISABLED = "button_disabled"

MSlider.PRESSED_EVENT = "PRESSED_EVENT"
MSlider.RELEASE_EVENT = "RELEASE_EVENT"
MSlider.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT"
MSlider.VALUE_CHANGED_EVENT = "VALUE_CHANGED_EVENT"

MSlider.BAR_ZORDER = 0     -- background bar
MSlider.BARFG_ZORDER = 1   -- foreground bar
MSlider.BUTTON_ZORDER = 2

-- start --

--------------------------------
-- 滑动控件的构建函数
-- @function [parent=#MSlider] new
-- @param number direction 滑动的方向
-- @param table images 各种状态对应的图片路径
-- @param table options 参数表

--[[--

滑动控件的构建函数

图片对应的状态:

-   bar 滑动图片
-   button 背景图片


可用参数有：

-   scale9 图片是否可缩放
-   min 最小值
-   max 最大值
-   touchInButton 是否只在触摸在滑动块上时才有效，默认为真

]]
-- end --

function MSlider:ctor(direction, images, options)
    makeMUIControl_(self)
    self.fsm_ = {}
    cc(self.fsm_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.fsm_:setupState({
        initial = {state = "normal", event = "startup", defer = false},
        events = {
            {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
            {name = "enable",  from = {"disabled"}, to = "normal"},
            {name = "press",   from = "normal",  to = "pressed"},
            {name = "release", from = "pressed", to = "normal"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_),
        }
    })

    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

    options = checktable(options)
    self.direction_ = direction
    self.isHorizontal_ = direction == display.LEFT_TO_RIGHT or direction == display.RIGHT_TO_LEFT
    self.images_ = clone(images)
    self.scale9_ = options.scale9
    self.scale9Size_ = nil
    self.min_ = checknumber(options.min or 0)
    self.max_ = checknumber(options.max or 100)
    self.value_ = self.min_
    self.buttonPositionRange_ = {min = 0, max = 0}
    self.buttonPositionOffset_ = {x = 0, y = 0}
    self.touchInButtonOnly_ = true
    if type(options.touchInButton) == "boolean" then
        self.touchInButtonOnly_ = options.touchInButton
    end

    self.buttonRotation_ = 0
    self.barSprite_ = nil
    self.buttonSprite_ = nil
    self.currentBarImage_ = nil
    self.currentButtonImage_ = nil

    self:setAnchorPoint(cc.p(0.5, 0.5))

    self:updateImage_()
    self:updateButtonPosition_()

    self.args_ = {direction, images, options}
    self:__setChildOnTouchEvent(handler(self, self.__onSliderTouchEvent))
    -- 默认是可以触摸的
    self:setViewTouched(true)
    -- 默认截获触摸事件
    self:setTouchCatchedInList(true)

    self:onUpdate(function (  )
        -- body
        if self.nAutoShow == true and self.nStart and self.nEnd then
            self.fEvery = self.fEvery or 1
            self.nStart = self.nStart + self.fEvery
            if self.nStart <= self.nEnd then
                self:setSliderValue(self.nStart)
            else
                if self.nAutoHandler then
                    self.nAutoHandler()
                end
                self.nAutoHandler = nil
                self.nAutoShow = nil
                self.nStart = nil
                self.nEnd = nil
            end
        end
    end)
end
-- 刷新无效的状态
-- _bEn（bool）：当前状态
function MSlider:__onRefreshEnableState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewEnabled()
    end
    if(self.barSprite_) then
        changeSpriteEnabledShowState(self.barSprite_, _bEn)
    end
    if(self.buttonSprite_) then
        changeSpriteEnabledShowState(self.buttonSprite_, _bEn)
    end
    if(self.barfgSprite_) then
        changeSpriteEnabledShowState(self.barfgSprite_, _bEn)
    end
end

-- 刷新按钮状态是否置灰
-- _bEn（bool）：当前状态
function MSlider:__onRefreshGrayState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewGray()
        _bEn = not _bEn
    end
    
    if(self.barSprite_) then
        changeSpriteEnabledShowState(self.barSprite_, _bEn)
    end
    if(self.buttonSprite_) then
        changeSpriteEnabledShowState(self.buttonSprite_, _bEn)
    end
    if(self.barfgSprite_) then
        changeSpriteEnabledShowState(self.barfgSprite_, _bEn)
    end
end
-- start --

--------------------------------
-- 设置滑动控件的大小
-- @function [parent=#MSlider] setSliderSize
-- @param number width 宽度
-- @param number height 高度
-- @return MSlider#MSlider 

-- end --

function MSlider:setSliderSize(width, height)
    -- assert(self.scale9_, "MSlider:setSliderSize() - can't change size for non-scale9 slider")
    self.scale9Size_ = {width, height}
    if self.barSprite_ then
        if self.scale9_ then
            self.barSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            self:setFgBarSize_(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        else
            self:setContentSizeAndScale_(self.barSprite_, cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        end
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件的是否起效
-- @function [parent=#MSlider] setSliderEnabled
-- @param boolean enabled 有效与否
-- @return MSlider#MSlider 

-- end --

function MSlider:setSliderEnabled(enabled)
    self:setTouchEnabled(enabled)
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = MSlider.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = MSlider.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件停靠位置
-- @function [parent=#MSlider] align
-- @param integer align 停靠方式
-- @param integer x X方向位置
-- @param integer y Y方向位置
-- @return MSlider#MSlider 

-- end --

function MSlider:align(align, x, y)
    display.align(self, align, x, y)
    self:updateImage_()
    return self
end

-- start --

--------------------------------
-- 滑动控件是否有效
-- @function [parent=#MSlider] isButtonEnabled
-- @return boolean#boolean 

-- end --

function MSlider:isButtonEnabled()
    return self.fsm_:canDoEvent("disable")
end

-- start --

--------------------------------
-- 得到滑动进度的值
-- @function [parent=#MSlider] getSliderValue
-- @return number#number 

-- end --

function MSlider:getSliderValue()
    return self.value_
end
-- 为了统一性，新增此方法
function MSlider:getPercent(  )
    return self:getSliderValue()
end

-- start --

--------------------------------
-- 设置滑动进度的值
-- @function [parent=#MSlider] setSliderValue
-- @param number value 进度值
-- @return MSlider#MSlider 

-- end --

function MSlider:setSliderValue(value)
    assert(value >= self.min_ and value <= self.max_, "MSlider:setSliderValue() - invalid value")
    if self.value_ ~= value then
        self.value_ = value
        self:updateButtonPosition_()
        self:dispatchEvent({name = MSlider.VALUE_CHANGED_EVENT, value = self.value_})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动进度区间（开始到结束）
-- @function [parent=#MSlider] setPercentFromTo
-- @param number nStart 进度值开始值
-- @param number nEnd 进度值结束值
-- @param callback nHandler 回调方法
-- @return MSlider#MSlider 

-- end --
function MSlider:setPercentFromTo( nStart, nEnd, nHandler )
    -- body
    if nStart == nil or nStart < 0 then
        print("开始值不能小于0")
        return
    end
    if nEnd == nil or nEnd > 100 then
        print("结束值不能大于100")
        return
    end
    self.nAutoShow = true
    self.nStart = nStart --开始值
    self.nEnd = nEnd --结束值
    self.nAutoHandler = nHandler --回调方法
    self:setSliderValue(self.nStart)
end

-- start --

--------------------------------
-- 在某个时间内自动滑动进度区间
-- @function [parent=#MSlider] setPercentToByTime
-- @param number fTime 时间
-- @param number nEnd 进度值结束值
-- @param callback nHandler 回调方法
-- @return MSlider#MSlider 

-- end --
function MSlider:setPercentToByTime( fTime, nEnd, nHandler )
    -- body
    if fTime == nil or fTime < 0 then
        print("时间不能小于0")
        return
    end
    if nEnd == nil or nEnd > 100 then
        print("结束值不能大于100")
        return
    end
    --计算每帧进度值
    self.fEvery = (nEnd - self.value_) / fTime / 60
    self.nAutoShow = true
    self.nStart = self.value_ --开始值
    self.nEnd = nEnd --结束值
    self.nAutoHandler = nHandler --回调方法
end

-- start --

--------------------------------
-- 设置滑动控件的旋转度
-- @function [parent=#MSlider] setSliderButtonRotation
-- @param number rotation 旋转度
-- @return MSlider#MSlider 

-- end --

function MSlider:setSliderButtonRotation(rotation)
    self.buttonRotation_ = rotation
    self:updateImage_()
    return self
end

function MSlider:addSliderValueChangedEventListener(callback)
    return self:addEventListener(MSlider.VALUE_CHANGED_EVENT, 
        handler(self, self.__onSliderChanged))
end

function MSlider:__onSliderChanged( event )
    if(event) then
        event.percent = math.floor(event.value)
    end
    if(self.m_valueChangedCallback) then
        self.m_valueChangedCallback(event)
    end
end
-- start --

--------------------------------
-- 注册用户滑动监听
-- @function [parent=#MSlider] onSliderValueChanged
-- @param function callback 监听函数
-- @return MSlider#MSlider 

-- end --

function MSlider:onSliderValueChanged(callback)
    self:addSliderValueChangedEventListener()
    self.m_valueChangedCallback = callback
    return self
end

function MSlider:addSliderPressedEventListener(callback)
    return self:addEventListener(MSlider.PRESSED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户按下监听
-- @function [parent=#MSlider] onSliderPressed
-- @param function callback 监听函数
-- @return MSlider#MSlider 

-- end --

function MSlider:onSliderPressed(callback)
    self:addSliderPressedEventListener(callback)
    return self
end

function MSlider:addSliderReleaseEventListener(callback)
    return self:addEventListener(MSlider.RELEASE_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户抬起或离开监听
-- @function [parent=#MSlider] onSliderRelease
-- @param function callback 监听函数
-- @return MSlider#MSlider 

-- end --

function MSlider:onSliderRelease(callback)
    self:addSliderReleaseEventListener(callback)
    return self
end

function MSlider:addSliderStateChangedEventListener(callback)
    return self:addEventListener(MSlider.STATE_CHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册滑动控件状态改变监听
-- @function [parent=#MSlider] onSliderStateChanged
-- @param function callback 监听函数
-- @return MSlider#MSlider 

-- end --

function MSlider:onSliderStateChanged(callback)
    self:addSliderStateChangedEventListener(callback)
    return self
end

function MSlider:__onSliderTouchEvent(event)
    if(not self:isViewEnabled()) then
        return false
    end
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
        if not self:checkTouchInButton_(x, y) then return false end
        local posx, posy = self.buttonSprite_:getPosition()
        local buttonPosition = self:convertToWorldSpace(cc.p(posx, posy))
        self.buttonPositionOffset_.x = buttonPosition.x - x
        self.buttonPositionOffset_.y = buttonPosition.y - y
        self.fsm_:doEvent("press")
        self:dispatchEvent({name = MSlider.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end

    local touchInTarget = self:checkTouchInButton_(x, y)
    x = x + self.buttonPositionOffset_.x
    y = y + self.buttonPositionOffset_.y
    local buttonPosition = self:convertToNodeSpace(cc.p(x, y))
    x = buttonPosition.x
    y = buttonPosition.y
    local offset = 0

    if self.isHorizontal_ then
        if x < self.buttonPositionRange_.min then
            x = self.buttonPositionRange_.min
        elseif x > self.buttonPositionRange_.max then
            x = self.buttonPositionRange_.max
        end
        if self.direction_ == display.LEFT_TO_RIGHT then
            offset = (x - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        else
            offset = (self.buttonPositionRange_.max - x) / self.buttonPositionRange_.length
        end
    else
        if y < self.buttonPositionRange_.min then
            y = self.buttonPositionRange_.min
        elseif y > self.buttonPositionRange_.max then
            y = self.buttonPositionRange_.max
        end
        if self.direction_ == display.TOP_TO_BOTTOM then
            offset = (self.buttonPositionRange_.max - y) / self.buttonPositionRange_.length
        else
            offset = (y - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        end
    end

    self:setSliderValue(offset * (self.max_ - self.min_) + self.min_)

    if name ~= "moved" and self.fsm_:canDoEvent("release") then
        self.fsm_:doEvent("release")
        self:dispatchEvent({name = MSlider.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
    end
end

function MSlider:checkTouchInButton_(x, y)
    if not self.buttonSprite_ then return false end
    if self.touchInButtonOnly_ then
        return self.buttonSprite_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    else
        return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    end
end

function MSlider:getSliderBarBall(  )
    -- body
    return self.buttonSprite_
end

function MSlider:updateButtonPosition_()
    if not self.barSprite_ or not self.buttonSprite_ then return end

    local x, y = 0, 0
    local barSize = self.barSprite_:getContentSize()
    barSize.width = barSize.width * self.barSprite_:getScaleX()
    barSize.height = barSize.height * self.barSprite_:getScaleY()
    local buttonSize = self.buttonSprite_:getContentSize()
    local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
    local ap = self:getAnchorPoint()

    if self.isHorizontal_ then
        x = x - barSize.width * ap.x
        y = y + barSize.height * (0.5 - ap.y)

        --这里处理力如果是检测更新中的透明图片 那么久不计算宽度
        local fNeedSubWidth = buttonSize.width
        if self.currentButtonImage_ == "ui/update_bin/v1_ball.png" or self.currentButtonImage_ == "ui/bar/v2_btn_tuodong.png" then
            fNeedSubWidth = 0
        end

        self.buttonPositionRange_.length = barSize.width - fNeedSubWidth
        self.buttonPositionRange_.min = x + buttonSize.width / 2
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
        
        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self.scale9Size_ then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(offset * self.buttonPositionRange_.length, self.scale9Size_[2]))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self.direction_ == display.LEFT_TO_RIGHT then
            x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
        else
            if self.barfgSprite_ and self.scale9Size_ then
                lbPos.x = lbPos.x + (1-offset)*self.buttonPositionRange_.length
            end
            x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        end
        if self.barfgSprite_ and self.scale9Size_ then
            self.barfgSprite_:setPosition(lbPos)
        end
    else
        x = x - barSize.width * (0.5 - ap.x)
        y = y - barSize.height * ap.y
        self.buttonPositionRange_.length = barSize.height - buttonSize.height
        self.buttonPositionRange_.min = y + buttonSize.height / 2
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self.scale9Size_ then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1], offset * self.buttonPositionRange_.length))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self.direction_ == display.TOP_TO_BOTTOM then
            y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
            if self.barfgSprite_ and self.scale9Size_ then
                lbPos.y = lbPos.y + (1-offset)*self.buttonPositionRange_.length
            end
        else
            y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
            if self.barfgSprite_ then
            end
        end
        if self.barfgSprite_ and self.scale9Size_ then
            self.barfgSprite_:setPosition(lbPos)
        end
    end

    if self.currentButtonImage_ == "ui/bar/v2_btn_tuodong.png" then
        self.buttonSprite_:setPosition(x - self.buttonSprite_:getContentSize().width / 2 , y)
    else
        self.buttonSprite_:setPosition(x, y)
    end
end

function MSlider:updateImage_()
    local state = self.fsm_:getState()

    local barImageName = "bar"
    local barfgImageName = "barfg"
    local buttonImageName = "button"
    local barImage = self.images_[barImageName]
    local barfgImage = self.images_[barfgImageName]
    local buttonImage = self.images_[buttonImageName]
    if state ~= "normal" then
        barImageName = barImageName .. "_" .. state
        buttonImageName = buttonImageName .. "_" .. state
    end

    if self.images_[barImageName] then
        barImage = self.images_[barImageName]
    end
    if self.images_[buttonImageName] then
        buttonImage = self.images_[buttonImageName]
    end

    if barImage then
        if self.currentBarImage_ ~= barImage then
            if self.barSprite_ then
                self.barSprite_:removeFromParent(true)
                self.barSprite_ = nil
            end

            if self.scale9_ then
                self.barSprite_ = display.newScale9Sprite(barImage)
                if not self.scale9Size_ then
                    local size = self.barSprite_:getContentSize()
                    self.scale9Size_ = {size.width, size.height}
                else
                    self.barSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                end
            else
                self.barSprite_ = display.newSprite(barImage)
                if not self.scale9Size_ then
                    local size = self.barSprite_:getContentSize()
                    self.scale9Size_ = {size.width, size.height}
                end
                self:setContentSizeAndScale_(self.barSprite_, cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            end
            self:addChild(self.barSprite_, MSlider.BAR_ZORDER)
        end

        self.barSprite_:setAnchorPoint(self:getAnchorPoint())
        self.barSprite_:setPosition(0 , 0)
    else
        printError("MSlider:updateImage_() - not set bar image for state %s", state)
    end

    if barfgImage then
        if not self.barfgSprite_ then
            if self.scale9_ then
                self.barfgSprite_ = display.newScale9Sprite(barfgImage)
                self.barfgSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            else
                self.barfgSprite_ = display.newSprite(barfgImage)
            end

            self:addChild(self.barfgSprite_, MSlider.BARFG_ZORDER)
            self.barfgSprite_:setAnchorPoint(cc.p(0, 0))
            self.barfgSprite_:setPosition(self.barSprite_:getPosition())
        end
    end

    if buttonImage then
        if self.currentButtonImage_ ~= buttonImage then
            if self.buttonSprite_ then
                self.buttonSprite_:removeFromParent(true)
                self.buttonSprite_ = nil
            end
            self.buttonSprite_ = display.newSprite(buttonImage)
            self:addChild(self.buttonSprite_, MSlider.BUTTON_ZORDER)
            self.currentButtonImage_ = buttonImage
        end

        self.buttonSprite_:setPosition(0, 0)
        self.buttonSprite_:setRotation(self.buttonRotation_)
        self:updateButtonPosition_()
    else
        printError("MSlider:updateImage_() - not set button image for state %s", state)
    end
end

-- 修改拖动条
-- _image(string)：进度条图片相对路径
function MSlider:setSliderImage( barfgImage )
    -- body
    if(not barfgImage) then
        return
    end
    --重置图片内容
    self.images_["barfg"] = barfgImage

    if not self.barfgSprite_ then
        if self.scale9_ then
            self.barfgSprite_ = display.newScale9Sprite(barfgImage)
            self.barfgSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        else
            self.barfgSprite_ = display.newSprite(barfgImage)
        end

        self:addChild(self.barfgSprite_, MSlider.BARFG_ZORDER)
        self.barfgSprite_:setAnchorPoint(cc.p(0, 0))
        self.barfgSprite_:setPosition(self.barSprite_:getPosition())
    else
        -- 这里直接使用纹理去处理，后续再考虑是否添加到缓存池中
        self.barfgSprite_:setTexture(barfgImage)
    end
end

function MSlider:onChangeState_(event)
    if self:isRunning() then
        self:updateImage_()
    end
end

function MSlider:setFgBarSize_(size)
    if not self.barfgSprite_ then
        return
    end
    self.barfgSprite_:setContentSize(size)
end

function MSlider:getbgSpriteLeftBottomPoint_()
    if not self.barSprite_ then
        return cc.p(0, 0)
    end

    local posX, posY = self.barSprite_:getPosition()
    local size = self.barSprite_:getBoundingBox()
    local ap = self.barSprite_:getAnchorPoint()
    posX = posX - size.width*ap.x
    posY = posY - size.height*ap.y

    local point = cc.p(posX, posY)
    return point
end

function MSlider:setContentSizeAndScale_(node, s)
    if not node then
        return
    end
    local size = node:getContentSize()
    local scaleX
    local scaleY
    scaleX = s.width/size.width
    scaleY = s.height/size.height
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
end


function MSlider:createCloneInstance_()
    return MSlider.new(unpack(self.args_))
end

function MSlider:copySpecialProperties_(node)
    if node.scale9Size_ then
        self:setSliderSize(unpack(node.scale9Size_))
    end

    self:setSliderEnabled(node:isButtonEnabled())
    self:setSliderValue(node:getSliderValue())
    self:setSliderButtonRotation(node.buttonRotation_)
end

function MSlider:copyClonedWidgetChildren_()
end

return MSlider
