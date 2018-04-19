------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-10 12:47:34
-- @Description: 自定义的父类控件
------------------------------
local N_IDENTIFY_INDEX = 1 -- 标识的下标

local MView = myclass("MView", function ( ... )
	local tParams = {...}
	local eType = tParams[1]
	local pNode = nil
	if(eType == MUI.VIEW_TYPE.group) then -- MGroup
		pNode = display.newNode()
	elseif(eType == MUI.VIEW_TYPE.layer) then -- MLayer
		pNode = display.newLayer()
	elseif(eType == MUI.VIEW_TYPE.image) then -- MImage
		local filename = tParams[2]
		local options= tParams[3]

        getSpriteFrameByName(filename)

		pNode = display.newSprite(filename)
	elseif(eType == MUI.VIEW_TYPE.imagenine) then -- MImage 点9
		local filename = tParams[2]
		local options= tParams[3]
	    pNode = display.newScale9Sprite(filename, nil, nil, nil, options.capInsets)
	elseif(eType == MUI.VIEW_TYPE.label
		or eType == MUI.VIEW_TYPE.labelbm) then -- MLabel or MLabelBm
		local options = tParams[2]
		if not options then
			pNode = nil
		end
		if 1 == options.UILabelType then
			pNode = newBMFontLabel_(options)
		elseif not options.UILabelType or 2 == options.UILabelType then
			pNode = newTTFLabel_(options)
		else
			printInfo("MLabel unkonw UILabelType")
		end
	elseif(eType == MUI.VIEW_TYPE.labelatlas) then -- MLabelAtlas
		local options = tParams[2]
		pNode = __newLabelAtlas(options)
	elseif(eType == MUI.VIEW_TYPE.button) then -- MButton
		pNode = display.newNode()
	elseif(eType == MUI.VIEW_TYPE.slider) then -- MSlider
		pNode = display.newNode()
	elseif(eType == MUI.VIEW_TYPE.loadingbar) then -- MLoadingBar
		pNode = display.newNode()
	elseif(eType == MUI.VIEW_TYPE.scrollview) then -- MScrollView
		pNode = display.newLayer()
	elseif(eType == MUI.VIEW_TYPE.clippingnode) then -- MClippingNode
		return cc.ClippingRectangleNode:create()
	elseif(eType == MUI.VIEW_TYPE.input) then -- MInput
		local options = tParams[2]
		if not options or not options.UIInputType or 1 == options.UIInputType then
			pNode = __newEditBox(options)
	        pNode.UIInputType = 1
		elseif 2 == options.UIInputType then
			pNode = __newTextField(options)
	        pNode.UIInputType = 2
		else
		end
	else
		pNode = display.newNode()
	end
	pNode.__setParPosition = pNode.setPosition
	pNode.__setParPositionX = pNode.setPositionX
	pNode.__setParPositionY = pNode.setPositionY
	pNode.__setVisible = pNode.setVisible
	-- 返回默认的node就行
	return pNode
end)
function MView:ctor( _eType )
	if(self.setRefreshChildOpAndColor) then
		self:setRefreshChildOpAndColor(false)
		self:setCascadeOpacityEnabled(true)
    	self:setCascadeColorEnabled(true)
	end
	self:__mviewInit()
	self:__setViewType(_eType)
    --self:onNodeEvent("cleanup", function() end)
    -- 设置不能点击
    self:setViewTouched(false)
end
function MView:__mviewInit(  )
	-- 记录是自定义控件类型
    self.bMView = true
    -- 是否运行中
    self.bRunning = true
    -- 是否可用
    self.__isViewEnabled = true
    -- 扩充前的原始位置，该值在setPosition的时候不会发生改变
    self.m_tBasePosition = nil
    -- 点击时是否需要缩放
    self.m_bPressNeedScale = true
    -- 点击时是否需要增加颜色
    self.m_bPressNeedColor = true
    -- 唯一标识,保留2位小数点
    N_IDENTIFY_INDEX = tonumber(string.format("%.2f", N_IDENTIFY_INDEX + 0.01))
    self.m_nIdentify = N_IDENTIFY_INDEX
    -- 长按Tag值
    self.m_nLongTag = 7777444
    -- 是否已经响应长按事件
    self.m_bHadLongClicked = false 
    --点击次数
    self.nClickedNum = 0
    -- 双击Tag值
    self.m_nDoubleTag = 555689
    -- 在列表中触摸时是否直接截获掉触摸事件
    self.m_bTouchCatchedInList = false
end
-- 设置控件类型
-- @param type paramname
-- @param type paramname-- @return
function MView:__setViewType( eType )
	self.eViewType = eType
end
-- 执行新建时参数的重置
-- _tOptions（table）：参数
function MView:__resetOptions( ... )
	if(self.__resetSpecialOptions) then
		self:__resetSpecialOptions(...)
	end
end
---- 执行释放MRootLayer的回调函数
function MView:__onMViewDestroy(  )
	-- 判断是否存在特殊的析构行为
	if(self.__onSpecialDestroy) then
		self:__onSpecialDestroy()
	end
	-- 停止执行了
	self.bRunning = false
    if(self.__nDestroyCallback) then
        self.__nDestroyCallback()
    end 

    if self.__bRemove2ObjPoolFlag == true then
        pushViewToPool(self, nil, false)
        self:setParent(nil)
    end
end

-- 设置子类的触摸区域检测
-- @param function nCallback 子类的触摸回调
function MView:__setChildCheckTouchInSprite( nCallback )
	self.nChildCheckTouchInSpriteListener = nCallback
end
-- 设置子类的触摸分发控制回调函数
-- @param function nCallback 子类的触摸回调
function MView:__setChildOnTouchEvent( nCallback )
	self.__nChildOnTouchListener = nCallback
end

-- 检测是否在点击的区域内
-- @param number x 当前的位置x
-- @param number y 当前的位置y
function MView:__checkTouchInSprite( x, y, bEnd)
	if(self.nChildCheckTouchInSpriteListener) then
		return self.nChildCheckTouchInSpriteListener(x, y, bEnd)
	end
	-- 将世界坐标转为当前界面的坐标
	x, y = __convertToRealPoint(self, x, y)
	if(not bEnd or not self.__pOldBoundingBox) then
		return self and self:getBoundingBox():containsPoint(cc.p(x, y))
    else
    	return self and self.__pOldBoundingBox:containsPoint(cc.p(x, y))
	end
end
-- 检测控件的触摸情况
-- event(table): 触摸时间，{name,x,y}
-- return(bool): 返回值说明
function MView:__dispatchTouchEvent( event )
	return self:__onTouchEvent(event)
end
-- 检测控件的触摸情况
-- event(table): 触摸时间，{name,x,y}
-- return(bool): 返回值说明
function MView:__onTouchEvent( event )
	if self:isCanTouchBefore() then
		if self.__nTouchBeforeCallback then
			self.__nTouchBeforeCallback()
		end
		return false
	end
	-- 如果是不能触摸的，直接返回false
	if(not self:isViewTouched() or not self:isVisible()) then
		return false
	end
	if(self.__nChildOnTouchListener) then
		return self.__nChildOnTouchListener(event)
	end
	local fCurX = event.x
	local fCurY = event.y
	if("began" == event.name) then
		-- 记录原始位置
		self.touchBeganX = fCurX
		self.touchBeganY = fCurY
		local bTouched = self:__checkTouchInSprite(event.x, event.y, false)
		if(bTouched) then
			-- 记录最后的控件大小
			self.__pOldBoundingBox = self:getBoundingBox()
			self:__doPressedEvent(event)
			-- 长按事件监听
			self:__doLongClickedEvent(event)
		end
		return bTouched
	end
	-- 如果没有触摸的起点
	if(not self.touchBeganX or not self.touchBeganY) then
		return false
	end
	local touchInTarget = event.__ftc or self:__checkTouchInSprite(self.touchBeganX, self.touchBeganY, true)
        and self:__checkTouchInSprite(fCurX, fCurY, true)
    -- 如果已经超出范围了，取消触摸行为
    if(not touchInTarget) then
    	-- 执行取消的行为
    	self:__doCancelEvent(event)
    	-- 取消起点记录
    	self.touchBeganX = nil
    	self.touchBeganY = nil
    	-- 取消长按
    	self:__doCancelLongClickedEvent()
    	if self.m_bHadLongClicked then
    		self.m_bHadLongClicked = false
    	end
    	return false
    end
	if("moved" == event.name) then
		self:__doPressedEvent(event)
	elseif ("ended" == event.name) then
	    -- 取消长按
		self:__doCancelLongClickedEvent()
		self:__doReleaseEvent(event)
		if self.m_bHadLongClicked then
			self.m_bHadLongClicked = false
		end
	end
	return true
end
-- 自定义特殊的触摸控制
-- @event table 触摸事件
function MView:__doSpecialEvent( event )
	if(self.eViewType == MUI.VIEW_TYPE.pushbutton) then -- 执行按钮的特殊事件
		if(self.__onButtonTouchEvent) then
			self:__onButtonTouchEvent(event)
			return
		end
	elseif(self.eViewType == MUI.VIEW_TYPE.checkbutton) then -- 执行复选框的特殊事件
		if(self.__onCheckButtonTouchEvent) then
			self:__onCheckButtonTouchEvent(event)
			return
		end
	end
end
-- 执行取消行为
-- event(table): 取消的事件
function MView:__doCancelEvent( event )
	-- 取消缩放行为
	__removePressedScaleAction(self)
	-- 执行取消回调
	if(self.__nCanceledCallback) then
		self.__nCanceledCallback(event)
	end
	-- 执行特殊的触摸事件
	self:__doSpecialEvent(event)
end
-- 执行按着的状态
-- event(table): 按下的状态
function MView:__doPressedEvent( event )
	if(event.name == "began") then
		__doPressedScaleAction(self)
	end
	if(self.__nPressedCallback) then
		self.__nPressedCallback(event)
	end
	-- 执行特殊的触摸事件
	self:__doSpecialEvent(event)
end

-- 执行按着的状态
-- event(table): 按下的状态
function MView:__doReleaseEvent( event )
	-- 取消缩放行为
	__removePressedScaleAction(self)
	if event.hadMulTouched == true then
	else
		-- 执行点击事件
		self:performClick()
	end
	-- 执行抬手的回调
	if(self.__nReleaseCallback) then
		self.__nReleaseCallback(event)
	end
	-- 执行特殊的触摸事件
	if(self.__doSpecialEvent) then
		self:__doSpecialEvent(event)
	end
end

-- 执行长按状态
-- event(table): 按下的状态
function MView:__doLongClickedEvent( event )
	-- body
	if(event.name == "began") then
		--存在注册才做判断
		if self.__nLongClickedCallback then
			self.nLoCliAction = cc.Sequence:create(
			    cc.DelayTime:create(0.7),
			    cc.CallFunc:create(function (  )
			    	self.m_bHadLongClicked = true
			        self.__nLongClickedCallback(self)
			        self:stopActionByTag(self.m_nLongTag)
			    end))
			self.nLoCliAction:setTag(self.m_nLongTag)
			self:runAction(self.nLoCliAction)
		end
	end
end

-- 取消长按行为
-- event(table): 取消的事件
function MView:__doCancelLongClickedEvent(  )
	self:stopActionByTag(self.m_nLongTag)
end

-- 初始化基础位置的坐标
-- _x(float)：初始的x值
-- _y(float)：初始的y值
function MView:__initBasePosition( _x, _y )
	if(self.m_tBasePosition == nil) then
		self.m_tBasePosition = {}
	end
	if(_x and self.m_tBasePosition.x == nil) then
		self.m_tBasePosition.x = _x
	end
	if(_y and self.m_tBasePosition.y == nil) then
		self.m_tBasePosition.y = _y
	end
end

------------------ 上面的方法是私有的，下面的方法是共有的 ---------------------------------------
-- 执行点击事件
--bForce：是否是强制调用的
function MView:performClick( bForce )
	--如果已经执行了长按事件回调，那么直接返回
	if self.m_bHadLongClicked then
		return
	end
	if bForce == nil then
		bForce = false
	end
	if not bForce and self.CLICK_ACTIONING then
		return
	end
	local fDelayTime = 0.1 -- 延迟0.1秒执行回调事件
	if(self:isViewEnabled()) then -- 执行点击事件
		-- 输入框执行特殊的处理
		if(self:getMViewType() == MUI.VIEW_TYPE.input) then
			--播放点击音效
			if not bForce then --非强制的才调用音效
				if playClickSoundEffect then
					playClickSoundEffect()
				end
			end
			self:doInputClicked()
			return
		end

		--如果存在双击注册时间，才执行分类判断
		if self.__nDoubleClickedCallback then
    		self.nClickedNum = self.nClickedNum + 1
    		if self.nClickedNum == 1 then
    			self.action = cc.Sequence:create(
    			    cc.DelayTime:create(0.2),
    			    cc.CallFunc:create(function ()
    			        if self.nClickedNum == 1 then
    			        	if(self.__nClickedCallback) then
    			        		__performActionDelay(self, function (  )
					    			self.__nClickedCallback(self)
								end, fDelayTime)
    			        		self.nClickedNum = 0
    			        	end
    			        end
    			    end))
    			self.action:setTag(self.m_nDoubleTag)
    			self:runAction(self.action)
    		elseif self.nClickedNum == 2 then
    			self.nClickedNum = 0
                self:stopActionByTag(self.m_nDoubleTag)
                --播放点击音效
                if not bForce then --非强制的才调用音效
                	if playClickSoundEffect then
                		playClickSoundEffect()
                	end
                end
                self.CLICK_ACTIONING = true -- 记录控件的点击状态
                __performActionDelay(self, function (  )
                	self.CLICK_ACTIONING = false
                	self.__nDoubleClickedCallback(self)
				end, fDelayTime)
    		end
    	else
    		if(self.__nClickedCallback) then
    			--播放点击音效
    			if not bForce then --非强制的才调用音效
    				if playClickSoundEffect then
    					playClickSoundEffect()
    				end
    			end
    			self.CLICK_ACTIONING = true -- 记录控件的点击状态
    			__performActionDelay(self, function (  )
	    			self.CLICK_ACTIONING = false
	    			self.__nClickedCallback(self)
				end, 0.035)
    		end
		end
		
	else  -- 执行无效时的点击事件
		if(self.__nUnenabledCallback) then
			--播放点击音效
			if not bForce then --非强制的才调用音效
				if playClickSoundEffect then
					playClickSoundEffect()
				end
			end
			__performActionDelay(self, function (  )
				self.__nUnenabledCallback(self)
			end, fDelayTime)
		end
	end
end
-- 设置是否可以点击
-- bTouched(bool): 是否可以触摸到
-- 这里特意与CCNode的 setTouchEnabled 做区分
function MView:setViewTouched( bTouched )
	self.__bViewTouched = bTouched
end
-- 获取是否可以触摸到
-- return(bool): 返回是否可以触摸
function MView:isViewTouched(  )
	return self.__bViewTouched
end
--设置是否可穿透点击
function MView:setIsTouchBeforeClick( bTouchBefore )
	-- body
	self.__bTouchBefore = bTouchBefore
end
--获取是否可穿透点击
function MView:isCanTouchBefore(  )
	-- body
	return self.__bTouchBefore
end

-- 获取控件的宽度
-- return(float):  宽度值
function MView:getWidth(  )
	local fw, fh = self:getWidthAndHeight()
	return fw
end
-- 获取控件的高度
-- return(float):  高度值
function MView:getHeight(  )
	local fw, fh = self:getWidthAndHeight()
	return fh
end
-- 获取当前的宽度和高度
-- return(float, float):  宽度值，高度值
function MView:getWidthAndHeight(  )
	local fw, fh = nil, nil

	if self.getViewRect then
		local rect = self:getViewRect()
		if rect then --MScorllView有getViewRect，但是返回值需要判空
			fw, fh = rect.width, rect.height
		end
	end

	if fw == nil or fh == nil then
		if(self.getContentSize) then
            local size = self:getContentSize()
			fw, fh = size.width, size.height
		else
			fw, fh = self:getLayoutSize()
		end
	end
	return fw, fh
end
-- 获取缩放之后当前的宽度和高度
-- return(float, float):  控件缩放后的宽度值，控件缩放后的高度值
function MView:getScaledWidthAndHeight(  )
	local fw, fh = self:getWidthAndHeight()
	fw = fw * self:getScaleX()
	fh = fh * self:getScaleY()
	return fw, fh
end
-- 设置控件特殊回调事件
-- nCallback(function): 回调函数
function MView:setSpecialDestroyCallback( nCallback )
    if self.__onSpecialDestroy == nil then
	    self.__onSpecialDestroy = self:onNodeEvent("cleanup", nCallback)
    end
end
-- 设置控件释放时的回调事件
-- nCallback(function): 回调函数
function MView:setDestroyCallback( nCallback )
    if self.__nDestroyCallback == nil then
	    self.__nDestroyCallback = self:onNodeEvent("cleanup", nCallback)
    end
end
-- 设置控件回收到对象池标志
function MView:setDestory2ObjPoolFlag()
    -- 注册析构的回调处理
    if self.__nDestory2ObjPoolCallback == nil then
        self.__nDestory2ObjPoolCallback = self:onNodeEvent("cleanup", function (  )
            pushViewToPool(self, nil, false)
            self:setParent(nil) 
        end)
    end
end
-- 设置点击回调
-- @param function nCallback 回调函数
function MView:onMViewClicked( nCallback )
    self.__nClickedCallback = nCallback
end
-- 设置长按回调
-- @param function nCallback 回调函数
function MView:onMViewLongClicked( nCallback )
	-- body
	self.__nLongClickedCallback = nCallback
end
-- 设置双击回调
-- @param function nCallback 回调函数
function MView:onMViewDoubleClicked( nCallback )
	-- body
	self.__nDoubleClickedCallback = nCallback
end
-- 设置穿透点击回调
-- @param function nCallback 回调函数
function MView:onTouchBeforeClicked( nCallback )
	-- body
	 self.__nTouchBeforeCallback = nCallback
end
-- 设置按下回调
-- @param function nCallback 回调函数
function MView:onMViewPressed( nCallback )
    self.__nPressedCallback = nCallback
end
-- 设置释放回调
-- @param function nCallback 回调函数
function MView:onMViewRelease( nCallback )
    self.__nReleaseCallback = nCallback
end
-- 设置取消回调
-- @param function nCallback 回调函数
function MView:onMViewCanceled( nCallback )
    self.__nCanceledCallback = nCallback
end
-- 设置无效事件回调
-- @param function nCallback 回调函数
function MView:onMViewDisabledClicked( nCallback )
	self.__nUnenabledCallback = nCallback
end
-- 设置是否可用
-- _bEnabled（bool）；是否可以用，若为不可用，置灰
function MView:setViewEnabled( _bEnabled )
    self.__isViewEnabled = _bEnabled
    -- 如果存在刷新状态的行为
    if(self.__onRefreshEnableState) then
    	self:__onRefreshEnableState()
    end
end
-- 返回是否控件可以正常使用
function MView:isViewEnabled(  )
	return self.__isViewEnabled
end
-- 设置是否置灰
-- _bEnabled（bool）；是否置灰
function MView:setToGray( _bEnabled )
    self.__isViewGray = _bEnabled
    -- 如果存在刷新状态的行为
    if(self.__onRefreshGrayState) then
    	self:__onRefreshGrayState()
    end
end
-- 返回是否控件置灰
function MView:isViewGray(  )
	return self.__isViewGray
end
-- 获取控件类型
-- return(int):(MUI.VIEW_TYPE),实际的控件类型
function MView:getMViewType(  )
	return self.eViewType
end
-- 重新设置控件的位置
-- _x(float or table): float代表新x值， table的话代表{x=??,y=??}
-- _y(float): 新的y值
function MView:setPosition( _x, _y )
	if(_x and type(_x) == "table") then
		_y = _x.y
		_x = _x.x
	end
	local fOldY = self:getPositionY()
	if(self.__setParPosition) then
		_x = _x or 0
		_y = _y or 0
		self:__setParPosition(_x, _y)
	end
	-- 执行位置的初始化记录
	self:__initBasePosition(_x, _y)
	-- y值发生了变化，看看是否需要刷新位置
	if(_y ~= fOldY) then
		local pPar = self:getParent()
		-- 如果父控件是扩充类型的话，刷新线性排序
		if(pPar and pPar.bMView 
			and pPar:getMViewType() == MUI.VIEW_TYPE.filllayer) then
			pPar:requestLayout()
		end
	end
end
-- 重新设置控件的X位置
-- _x(float): 新的x值
function MView:setPositionX( _x )
	if(self.__setParPositionX) then
		self:__setParPositionX(_x)
	end
	-- 执行位置的初始化记录
	self:__initBasePosition(_x)
end
-- 重新设置控件的Y位置
-- _y(float): 新的y值
function MView:setPositionY( _y )
	local fOldY = self:getPositionY()
	if(self.__setParPositionY) then
		self:__setParPositionY(_y)
	end
	-- 执行位置的初始化记录
	self:__initBasePosition(nil, _y)
	-- y值发生了变化，看看是否需要刷新位置
	if(_y ~= fOldY) then
		local pPar = self:getParent()
		-- 如果父控件是扩充类型的话，刷新线性排序
		if(pPar and pPar.bMView 
			and pPar:getMViewType() == MUI.VIEW_TYPE.filllayer) then
			pPar:requestLayout()
		end
	end
end
-- 设置扩充前的位置
-- _tD（table）：扩充前的位置｛x=???, y=????｝
function MView:setBasePosition( _x, _y )
    if(not _x and not _y) then
        return self.m_tBasePosition
    end
    if(not self.m_tBasePosition) then
    	self.m_tBasePosition = {}
    end
    if(_x) then
        self.m_tBasePosition.x = _x
    end
    if(_y) then
        self.m_tBasePosition.y = _y
    end
    return self.m_tBasePosition
end
-- 获取扩充前位置的y值
-- return(float): 返回y值
function MView:getBasePositionY(  )
    if(self.m_tBasePosition and self.m_tBasePosition.y) then
        return self.m_tBasePosition.y
    end
    return self:getPositionY()
end
-- 获取控件的唯一标识
function MView:getViewIdentify(  )
	return self.m_nIdentify
end
-- 设置是否可见
-- _bIs（bool）：设置是否可见
function MView:setVisible( _bIs )
	self:__setVisible(_bIs)
	-- 当其可见度发生变化时，要舒心一下线性布局
	local pPar = self:getParent()
	-- 如果父控件是扩充类型的话，刷新线性排序
	if(pPar and pPar.bMView 
		and pPar:getMViewType() == MUI.VIEW_TYPE.filllayer) then
		pPar:requestLayout()
	end
end
-- 设置点击时是否需要缩放
-- _bIs(bool): 是否需要缩放
-- function MView:setIsPressedNeedScale( _bIs )
-- 	self.m_bPressNeedScale = _bIs
-- end
-- 设置点击时是否需要缩放
-- _bIs(bool): 是否需要缩放
function MView:setIsPressedNeedScale( _bIs )    
    if(_bIs == false
        and self.m_bPressNeedScale == true 
        and self.__nUnderPressedCount 
        and self.__nUnderPressedCount > 0
        and self.fFinalSx 
        and self.fFinalSy) then
        --fix:在点击的过程中，被乱入中断缩放
        local pAction = cc.ScaleTo:create(0.05, self.fFinalSx, self.fFinalSy)
        pAction:setTag(N_TAG_MVIEW_SCALE_ACTION)
        self:runAction(cc.Sequence:create(pAction,
            cc.CallFunc:create(function (  )
                -- 重置次数计数器（和MPrivateUtils的__removePressedScaleAction对应）
                self.__nUnderPressedCount = 0
            end)))
    end

	self.m_bPressNeedScale = _bIs
end

-- 获取点击时是否需要缩放
-- return(bool): 是否需要缩放
function MView:getIsPressedNeedScale()
	return self.m_bPressNeedScale
end
-- 设置点击时是否需要颜色
-- _bIs(bool): 是否需要颜色
function MView:setIsPressedNeedColor( _bIs )
	if(_bIs == false and self.m_bPressNeedColor == true) then
        self:setColor(cc.c3b(255, 255, 255))
	end
	self.m_bPressNeedColor = _bIs
end
-- 获取点击时是否需要颜色
-- return(bool): 是否需要颜色
function MView:getIsPressedNeedColor()
	return self.m_bPressNeedColor
end

-- 通过tag值搜索控件
-- _tag(int): 控件的tag
function MView:findViewByTag(_tag)
    if (self:getTag() == _tag) then
        return self
    end
    --local childs = self:getChildren()
    local childs = self:getLuaChildren()
    if childs then
        local pView = nil
        for i, v in pairs(childs) do
            if v.findViewByTag then
                pView = v:findViewByTag(_tag)
            else
                pView = v:getChildByTag(_tag)
            end

            if pView then
                return pView
            end
        end
    end
end

-- 通过_name值搜索控件
-- _name(string): 控件的名称
function MView:findViewByName(_name)
    if (self:getName() == _name) then
        return self
    end
    --local childs = self:getChildren()
    local childs = self:getLuaChildren()
    local pView = nil
    if childs then
        for i, v in pairs(childs) do
            if v.findViewByName then
                pView = v:findViewByName(_name)
            else
                pView = v:getChildByName(_name)
            end

            if pView then
                return pView
            end
        end
    end
end

-- 在列表中触摸时，是否截获触摸事件，不渗透到list中
-- _bIs(bool): 是否截获，true为截获，false为不截获
function MView:setTouchCatchedInList( _bIs )
	if(_bIs == nil) then
		_bIs = false
	end
	self.m_bTouchCatchedInList = _bIs
end
-- 在列表中触摸时，是否截获触摸事件，不渗透到list中
-- return(bool): 是否截获，true为截获，false为不截获
function MView:getTouchCatchedInList( )
	return self.m_bTouchCatchedInList
end

---- 将自己释放到缓存池中
--function MView:releaseToPool( )
--	if(not MViewPool:getInstance():isReady()) then
--		return
--	end
--	-- 如果是一个业务层定义的缓存控件,优先放回全局的缓存池中
--	if(self.__poolTmpName) then
--		pushViewToPool(self)
--		return
--	end
--	if(self.__layerReleaseToPool) then -- 执行layer的释放,只释放子，不包含自己
--		self:__layerReleaseToPool()
--	end
--	-- 取消初始位置的设置
--	self.m_tBasePosition = nil
--	-- 存放回缓存池中
--	MViewPool:getInstance():push(self)
--end

function MView:setLayoutSize( _w, _h )
	if(type(_w) ~= "number") then
		_h = _w.height
		_w = _w.width
	end
	self:setContentSize(_w, _h)
end
function MView:getLayoutSize( )
	local size = self:getContentSize()
	return size.width, size.height
end

-- 适配时是否忽略同级的高(在适配时，不修改高度，MFillLayer除外)
function MView:setIgnoreOtherHeight( _bIgnore )
    self.m_bIgnoreOtherHeight = _bIgnore
end

return MView
