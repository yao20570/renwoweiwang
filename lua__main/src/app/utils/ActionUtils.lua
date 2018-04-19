-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-03 15:00:44 星期一
-- Description: 动作表现特效
-----------------------------------------------------

--呼吸效果
function showBreathTx( _pView ,_nDt)
	local nDt = _nDt or 0.5
	-- body
	_pView:stopAllActions()
	local scaleTo1  = cc.ScaleTo:create(nDt, 0.93)
	local scaleTo2  = cc.ScaleTo:create(nDt, 1)
	local actions = cc.RepeatForever:create(cc.Sequence:create(scaleTo1, scaleTo2))
	_pView:runAction(actions)
	--图标变亮
	_pView:setToGray(false)
end

--摇摆效果
function showRockTx( _pView )
	-- body
	_pView:stopAllActions()
	local rotate1 = cc.RotateTo:create(0.21, 3)
	local rotate2 = cc.RotateTo:create(0.17, -3)
	local rotate3 = cc.RotateTo:create(0.2, 5)
	local rotate4 = cc.RotateTo:create(0.25, -5)
	local rotate5 = cc.RotateTo:create(0.17, 0)
	local actions = cc.RepeatForever:create(cc.Sequence:create(rotate1, rotate2, rotate3, rotate4, rotate5))
	_pView:runAction(actions)
     --图标变亮
    _pView:setToGray(false)
end

--宝箱呼吸效果
function showRockTx2( _pView )
	-- body
	_pView:stopAllActions()
	local action1  = cc.RotateTo:create(0.17, 8)
	local action2  = cc.RotateTo:create(0.16, -6)
	local action3  = cc.RotateTo:create(0.17, 5)
	local action4  = cc.RotateTo:create(0.17, -4)
	local action5  = cc.RotateTo:create(0.12, 5)
	local action6  = cc.RotateTo:create(0.12, 0)
	local action7  = cc.ScaleTo:create(0.92, 0.75)
	local action8  = cc.ScaleTo:create(1.0, 0.7)

	local actions = cc.RepeatForever:create(cc.Sequence:create(action1, action2, action3, 
		action4, action5, action6, action7, action8))
	_pView:runAction(actions)
end

--宝箱摇摆效果
function showBreathTx2( _pView )
	-- body
	_pView:stopAllActions()
	local action1_1 = cc.FadeTo:create(0.17, 255*0.3)
	local action1_2 = cc.RotateTo:create(0.17, 8)
	local action1   = cc.Spawn:create(action1_1, action1_2)

	local action2   = cc.RotateTo:create(0.16, -6)
	local action3   = cc.RotateTo:create(0.17, 5)
	local action4   = cc.RotateTo:create(0.17, -4)
	local action5   = cc.RotateTo:create(0.12, 5)
	local action6   = cc.RotateTo:create(0.12, 0)

	local action7_1 = cc.FadeTo:create(0.92, 255*0.6)
	local action7_2 = cc.ScaleTo:create(0.92, 0.75)
	local action7   = cc.Spawn:create(action7_1, action7_2)

	local action8_1 = cc.FadeTo:create(1.0, 255*0.3)
	local action8_2 = cc.ScaleTo:create(1.0, 0.7)
	local action8   = cc.Spawn:create(action8_1, action8_2)

	local actions = cc.RepeatForever:create(cc.Sequence:create(action1, action2, action3, 
		action4, action5, action6, action7, action8))
	_pView:runAction(actions)
end

--宝箱上下浮动效果
function showFloatTx(_pView, _nTime, _opacity1,_opacity2)
	-- body
	local nTime = _nTime or 1
	_pView:stopAllActions()
	local nPosX, nPosY = _pView:getPositionX(), _pView:getPositionY()
	local action1, action2
	if _opacity1 then
		local action1_1   = cc.MoveTo:create(nTime, cc.p(nPosX, nPosY + 3))
		local action1_2   = cc.FadeTo:create(nTime, _opacity1)
		action1   = cc.Spawn:create(action1_1, action1_2)
		local action2_1   = cc.MoveTo:create(nTime, cc.p(nPosX, nPosY))
		local action2_2   = cc.FadeTo:create(nTime, _opacity2 or 0)
		action2   = cc.Spawn:create(action2_1, action2_2)
	else
		action1   = cc.MoveTo:create(nTime, cc.p(nPosX, nPosY + 3))
		action2   = cc.MoveTo:create(nTime, cc.p(nPosX, nPosY))
	end
	local actions = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	_pView:runAction(actions)
end

function showFloatTx2( _pView )
	-- body
	_pView:stopAllActions()
	local nPosX, nPosY = _pView:getPositionX(), _pView:getPositionY()
	local action1_1   = cc.FadeTo:create(0.5, 255)
	local action1_2   = cc.MoveTo:create(0.5, cc.p(nPosX, nPosY + 1.5))
	local action1     = cc.Spawn:create(action1_1, action1_2)

	local action2_1   = cc.FadeTo:create(0.5, 0)
	local action2_2   = cc.MoveTo:create(0.5, cc.p(nPosX, nPosY + 3))
	local action2     = cc.Spawn:create(action2_1, action2_2)

	local action3_1   = cc.FadeTo:create(0.5, 255)
	local action3_2   = cc.MoveTo:create(0.5, cc.p(nPosX, nPosY + 1.5))
	local action3     = cc.Spawn:create(action3_1, action3_2)

	local action4_1   = cc.FadeTo:create(0.5, 0)
	local action4_2   = cc.MoveTo:create(0.5, cc.p(nPosX, nPosY))
	local action4     = cc.Spawn:create(action4_1, action4_2)

	local actions = cc.RepeatForever:create(cc.Sequence:create(action1, action2, action3, action4))
	_pView:runAction(actions)
end

--置灰效果
function showGrayTx( _pView, _bGray )
	-- body
	_pView:stopAllActions()
	_pView:setToGray(_bGray)
end

--睡眠效果 Zzz...
function getSleepTx(  )
	-- body
	--创建内容层和三个Z
	local pLayer = MUI.MLayer.new()
	local pImgZ1 = MUI.MImage.new("#sg_sj_zzz__01.png")
	local pImgZ2 = MUI.MImage.new("#sg_sj_zzz__01.png")
	local pImgZ3 = MUI.MImage.new("#sg_sj_zzz__01.png")
	pLayer:setLayoutSize(pImgZ1:getWidth(), pImgZ1:getHeight())
	pImgZ1:setScale(0.58)
	pImgZ1:setOpacity(0)
	pLayer:addView(pImgZ1)
	centerInView(pLayer, pImgZ1)
	pImgZ2:setScale(0.58)
	pImgZ2:setOpacity(0)
	pLayer:addView(pImgZ2)
	centerInView(pLayer, pImgZ1)
	pImgZ3:setScale(0.58)
	pImgZ3:setOpacity(0)
	pLayer:addView(pImgZ3)
	centerInView(pLayer, pImgZ1)

    local pos = cc.p(0, 0)

	--第一个Z
	local runActions1 = function (  )
		-- body
        local x = pImgZ1:getPositionX()
        local y = pImgZ1:getPositionY()

        pos.x = x + 9
        pos.y = y + 9.8
		local action1_1 = cc.MoveTo:create(0.42, pos)
		local action1_2 = cc.ScaleTo:create(0.42, 0.71)
		local action1_3 = cc.RotateTo:create(0.42, 2)
		local action1_4 = cc.FadeTo:create(0.42, 255)
		local actions1  = cc.Spawn:create(action1_1,action1_2,action1_3,action1_4)

        pos.x = x + 15.1
        pos.y = y + 15.8
		local action2_1 = cc.MoveTo:create(0.29, pos)
		local action2_2 = cc.ScaleTo:create(0.29, 0.8)
		local action2_3 = cc.RotateTo:create(0.29, 3.4)
		local actions2  = cc.Spawn:create(action2_1,action2_2,action2_3)

        pos.x = x + 34.7
        pos.y = y + 36.3
		local action3_1 = cc.MoveTo:create(0.92, pos)
		local action3_2 = cc.RotateTo:create(0.92, 7.8)
		local actions3  = cc.Spawn:create(action3_1,action3_2)

        pos.x = x + 44.5
        pos.y = y + 46.5
		local action4_1 = cc.MoveTo:create(0.37, pos)
		local action4_2 = cc.RotateTo:create(0.37, 10)
		local action4_3 = cc.FadeTo:create(0.37, 0)
		local actions4  = cc.Spawn:create(action4_1,action4_2,action4_3)

		local actionEnd = cc.CallFunc:create(function (  )
			-- body
			--重置位置
			pImgZ1:setPosition(pLayer:getWidth() / 2,pLayer:getHeight() / 2)
			pImgZ1:setScale(0.58)
		end)

		local allActions = cc.Sequence:create(actions1,actions2,actions3,actions4,actionEnd)
		pImgZ1:runAction(allActions)
	end

	--第二个Z
	local runActions2 = function (  )
		-- body
        local x = pImgZ2:getPositionX()
        local y = pImgZ2:getPositionY()

		local actions1 = cc.DelayTime:create(1.29)

        pos.x = x + 13
        pos.y = y + 15.6
		local action2_1 = cc.MoveTo:create(0.42, pos)
		local action2_2 = cc.ScaleTo:create(0.42, 0.74)
		local action2_3 = cc.RotateTo:create(0.42, -2)
		local action2_4 = cc.FadeTo:create(0.42, 255)
		local actions2  = cc.Spawn:create(action2_1,action2_2,action2_3,action2_4)

        pos.x = x + 22
        pos.y = y + 27
		local action3_1 = cc.MoveTo:create(0.29, pos)
		local action3_2 = cc.ScaleTo:create(0.29, 0.85)
		local action3_3 = cc.RotateTo:create(0.29, -3.4)
		local actions3  = cc.Spawn:create(action3_1,action3_2,action3_3)

        pos.x = x + 51
        pos.y = y + 61
		local action4_1 = cc.MoveTo:create(0.92, pos)
		local action4_2 = cc.RotateTo:create(0.92, -7.8)
		local actions4  = cc.Spawn:create(action4_1,action4_2)

        pos.x = x + 65
        pos.y = y + 78
		local action5_1 = cc.MoveTo:create(0.37, pos)
		local action5_2 = cc.RotateTo:create(0.37, -10)
		local action5_3 = cc.FadeTo:create(0.37, 0)
		local actions5  = cc.Spawn:create(action5_1,action5_2,action5_3)

		local actionEnd = cc.CallFunc:create(function (  )
			-- body
			--重置位置
			pImgZ2:setPosition(pLayer:getWidth() / 2,pLayer:getHeight() / 2)
			pImgZ2:setScale(0.58)
		end)

		local allActions = cc.Sequence:create(actions1,actions2,actions3,actions4,actions5,actionEnd)
		pImgZ2:runAction(allActions)
	end

	--第三个Z
	local runActions3 = function (  )
		-- body
        local x = pImgZ3:getPositionX()
        local y = pImgZ3:getPositionY()

		local actions1 = cc.DelayTime:create(2.5)

        pos.x = x + 5
        pos.y = y + 13
		local action2_1 = cc.MoveTo:create(0.42, pos)
		local action2_2 = cc.ScaleTo:create(0.42, 0.71)
		local action2_3 = cc.RotateTo:create(0.42, -2)
		local action2_4 = cc.FadeTo:create(0.42, 255)
		local actions2  = cc.Spawn:create(action2_1,action2_2,action2_3,action2_4)

        pos.x = x + 8.3
        pos.y = y + 22
		local action3_1 = cc.MoveTo:create(0.29, pos)
		local action3_2 = cc.ScaleTo:create(0.29, 0.80)
		local action3_3 = cc.RotateTo:create(0.29, -3.4)
		local actions3  = cc.Spawn:create(action3_1,action3_2,action3_3)

        pos.x = x + 19
        pos.y = y + 51
		local action4_1 = cc.MoveTo:create(0.92, pos)
		local action4_2 = cc.RotateTo:create(0.92, -7.8)
		local actions4  = cc.Spawn:create(action4_1,action4_2)

        pos.x = x + 24.5
        pos.y = y + 65
		local action5_1 = cc.MoveTo:create(0.37, pos)
		local action5_2 = cc.RotateTo:create(0.37, -10)
		local action5_3 = cc.FadeTo:create(0.37, 0)
		local actions5  = cc.Spawn:create(action5_1,action5_2,action5_3)

		local actionEnd = cc.CallFunc:create(function (  )
			-- body
			--重置位置
			pImgZ3:setPosition(pLayer:getWidth() / 2,pLayer:getHeight() / 2)
			pImgZ3:setScale(0.58)
			if pLayer.runAllAcrions then
				pLayer:runAllAcrions()
			end
		end)

		local allActions = cc.Sequence:create(actions1,actions2,actions3,actions4,actions5,actionEnd)
		pImgZ3:runAction(allActions)
	end

	local runAllAcrions = function (  )
		-- body
		runActions1()
		runActions2()
		runActions3()
	end

	runAllAcrions()
	pLayer.runAllAcrions = runAllAcrions

	return pLayer
end

--光圈扩散效果
function getCircleLightRing( )
	-- body
	local pImgCircle = MUI.MImage.new("#sg_zjm_kaiqizt_hs_002.png")
	pImgCircle:setScale(0.85)
	pImgCircle:setOpacity(0)

	local action1_1 = cc.ScaleTo:create(0.4, 1)
	local action1_2 = cc.FadeTo:create(0.4, 255)
	local actions1 = cc.Spawn:create(action1_1,action1_2)

	local action2_1 = cc.ScaleTo:create(0.4, 1.13)
	local action2_2 = cc.FadeTo:create(0.4, 0)
	local actions2 = cc.Spawn:create(action2_1,action2_2)

	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		pImgCircle:setScale(0.85)
	end)

	local allActions = cc.RepeatForever:create(cc.Sequence:create(actions1, actions2, actionEnd))
	pImgCircle:runAction(allActions)

	return pImgCircle
end
-- 执行控件的弹出效果
-- _pView(CCNode)：当前控件
-- _sName(string): 特效进场类型，pop, left, right, bottom, top
-- _fTime（number）：特效时长
-- _nHandler（function）：特效执行完成的回调
function ActionIn( _pView, _sName, _fTime, _nHandler )
	if(not _pView) then
		return
	end
	_sName = _sName or "pop"
	local oldAnPoint = _pView:getAnchorPoint()
    local action = nil
	_fTime = _fTime or 0.3
	if(_sName == "pop") then
		-- 移动界面
	    _pView:ignoreAnchorPointForPosition(true)
		_pView:setScale(0.3)
    	_pView:setAnchorPoint( cc.p(0.5, 0.5) )
    	action = cc.ScaleTo:create(_fTime, 1)
	elseif(_sName == "left") then
		local oldPosX = _pView:getPositionX()
		local oldPosY = _pView:getPositionY()
		_pView:setPositionX(oldPosX-_pView:getWidth()*2/3)
	    action = cc.MoveTo:create(_fTime, cc.p(oldPosX, oldPosY))
	elseif(_sName == "right") then
		local oldPosX = _pView:getPositionX()
		local oldPosY = _pView:getPositionY()
		_pView:setPositionX(oldPosX+_pView:getWidth()*2/3)
	    action = cc.MoveTo:create(_fTime, cc.p(oldPosX, oldPosY))
	elseif(_sName == "bottom") then
		local oldPosX = _pView:getPositionX()
		local oldPosY = _pView:getPositionY()
		_pView:setPositionY(oldPosY-_pView:getHeight()*2/3)
	    action = cc.MoveTo:create(_fTime, cc.p(oldPosX, oldPosY))
	elseif(_sName == "top") then
		local oldPosX = _pView:getPositionX()
		local oldPosY = _pView:getPositionY()
		_pView:setPositionY(oldPosY+_pView:getHeight()*2/3)
	    action = cc.MoveTo:create(_fTime, cc.p(oldPosX, oldPosY))
	end
	if(not action) then
		print("不存在该类型的特效", _sName)
		return
	end
	_pView:setOpacity(1)
    local fade = cc.FadeIn:create(_fTime)
    local sqawn = cc.Spawn:create(cc.EaseBackOut:create(action), fade)
    -- 移动后携带的参数
    local tParams = {}
    tParams.onComplete = function()
    	if(_sName == "pop") then
	    	_pView:setAnchorPoint( oldAnPoint )
	    end
    	if(_nHandler) then
            _nHandler()
        end
    end
    -- 执行动作
    transition.execute(_pView, sqawn , tParams) 
end

--展示左右摇摆效果气泡
function showRotateQiPao( _pView )
	-- body
	_pView:stopAllActions()
	_pView:setAnchorPoint(cc.p(0.5,0))
	local action1 = cc.RotateTo:create(0.5, 1.5)
	local action2 = cc.RotateTo:create(0.5, -1.5)
	local allActions = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	_pView:runAction(allActions)
end

--展出缩放效果气泡
function showScaleQiPao( _pView )
	-- body
	_pView:stopAllActions()
	local action1 = cc.ScaleTo:create(0.5, 0.95)
	local action2 = cc.ScaleTo:create(0.5, 1)
	local allActions = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	_pView:runAction(allActions)
end

--展示黄色光圈
--_sNameImg: 黄色光圈里面的图片 _nType为1时才需要填
--_pos偏移位置
function showYellowRing(_pView, _nType, _sNameImg,fScale, _pos,_nSceneType)
	-- body
	tAllYellowTx = {}
	_nType = _nType or 2
	local tAll = {} --复制表
	if _nType == 1 then
		tAll[1] = copyTab(tNormalCusArmDatas["1"])
		--替换图片
		local tT1 = copyTab(tNormalCusArmDatas["2"])
		for k, v in pairs (tT1.tActions) do
			v.sImgName = _sNameImg
		end
		tT1.fScale = fScale
		tAll[2] = copyTab(tT1)
		local tT2 = copyTab(tNormalCusArmDatas["3"])
		for k, v in pairs (tT2.tActions) do
			v.sImgName = _sNameImg
		end
		tT2.fScale = fScale
		tAll[3] = copyTab(tT2)
		tAll[4] = copyTab(tNormalCusArmDatas["4"])
	elseif _nType == 2 then
		tAll[1] = copyTab(tNormalCusArmDatas["4"])
	elseif _nType == 3 then
		tAll[1] = copyTab(tNormalCusArmDatas["4"])
		tAll[1].pos = _pos
		tAll[1].fScale = fScale
	end
	
	-- 8为原来背景图片（v1_img_zjm_wzqph 94）和 现在背景图片（v1_img_zjm_wzqpj 110）的差的一半，然后乘以缩放值

	local nSceneType=_nSceneType or Scene_arm_type.base
	for i = 1, #tAll do
		local pArm = MArmatureUtils:createMArmature(
			tAll[i], 
			_pView, 
			10, 
			cc.p(_pView:getWidth() / 2, _pView:getHeight() / 2 +8 ),
		    function ( _pArm )

		    end, nSceneType)
		if pArm then
			table.insert(tAllYellowTx, pArm)
			pArm:play(-1)
		end
	end
	return tAllYellowTx
end

--展示黄色光圈2  背景图片的大小与上面的不一样，
--_sNameImg: 黄色光圈里面的图片 _nType为1时才需要填
--_pos偏移位置
function showYellowRing2(_pView, _nType, _sNameImg,fScale, _pos,_nSceneType, nBillboardtype)
	-- body
	tAllYellowTx = {}
	_nType = _nType or 2
	local tAll = {} --复制表
	if _nType == 1 then
		tAll[1] = copyTab(tNormalCusArmDatas["1"])
		--替换图片
		local tT1 = copyTab(tNormalCusArmDatas["2"])
		for k, v in pairs (tT1.tActions) do
			v.sImgName = _sNameImg
		end
		tT1.fScale = fScale
		tAll[2] = copyTab(tT1)
		local tT2 = copyTab(tNormalCusArmDatas["3"])
		for k, v in pairs (tT2.tActions) do
			v.sImgName = _sNameImg
		end
		tT2.fScale = fScale
		tAll[3] = copyTab(tT2)
		tAll[4] = copyTab(tNormalCusArmDatas["4"])
	elseif _nType == 2 then
		tAll[1] = copyTab(tNormalCusArmDatas["4"])
	elseif _nType == 3 then
		tAll[1] = copyTab(tNormalCusArmDatas["4"])
		tAll[1].pos = _pos
		tAll[1].fScale = fScale
	end
	
	-- 8为原来背景图片（v1_img_zjm_wzqph 94）和 现在背景图片（v1_img_zjm_wzqpj 110）的差的一半，然后乘以缩放值

	local nSceneType=_nSceneType or Scene_arm_type.base
	for i = 1, #tAll do
		local pArm = MArmatureUtils:createMArmature(
			tAll[i], 
			_pView, 
			10, 
			cc.p(_pView:getWidth() / 2, _pView:getHeight() / 2),
		    function ( _pArm )

		    end, nSceneType, nBillboardtype)
		if pArm then
			table.insert(tAllYellowTx, pArm)
			pArm:play(-1)
		end
	end
	return tAllYellowTx
end

--图片循环转圈
function getCircleRepeatForever( _sImgName, _fTime, _bBlend )
	_fTime = _fTime or 6
    local pImgCircle = MUI.MImage.new(_sImgName)
    if _bBlend then
    	pImgCircle:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
    pImgCircle:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(_fTime, 360)))
    return pImgCircle
end

--新手任务长方形特效
function getRectangleTx()
	-- body
	
	local pLayer = MUI.MLayer.new()
	local pImg = MUI.MImage.new("#sg_xktp_tus_001.png")
	pLayer:setLayoutSize(pImg:getWidth(), pImg:getHeight())

	local function runActions()
		-- body
    	local pImgRect = popViewFromPool("rectangleTx")
    	if not pImgRect then
    		pImgRect = MUI.MImage.new("#sg_xktp_tus_001.png")
    	end
    	pImgRect:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    	pImgRect:setOpacity(0)
    	pImgRect:setScale(1)
    	pLayer:addView(pImgRect)
    	centerInView(pLayer, pImgRect)

		local action1_1 = cc.ScaleTo:create(0.3, 1.025, 1.075)
		local action1_2 = cc.FadeTo:create(0.3, 255)
		local actions1  = cc.Spawn:create(action1_1, action1_2)

		local action2_1 = cc.ScaleTo:create(0.7, 1.075, 1.25)
		local action2_2 = cc.FadeTo:create(0.7, 0)
		local actions2  = cc.Spawn:create(action2_1, action2_2)

		local actionEnd = cc.CallFunc:create(function (  )
			-- body
			pushViewToPool(pImgRect, "rectangleTx")
		end)

		local pSeq = cc.Sequence:create(actions1, actions2, actionEnd)
		pImgRect:runAction(pSeq)

		pLayer:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.6),
        	cc.CallFunc:create(runActions)
		}))
	end

	runActions()


	return pLayer
end

--显示战力发生变化动画
--nPrev:之前战斗力
--nCurr:现在战斗力
local nRandomNumScheduler = nil
local nRandomNumIndexEnd = 0
local nRandomNumIndex = 0
local keep_last_change = nil
local __isPlayingFCTx = false
-- nPrev(int):　前战力值
-- nCurr（int）: 新战力值
-- _rootlayer（MRootLayer）： 如果有传值，则为初始化
--_ntype 1--战力提升 2--竞技场阵容战力提升 默认1
function showFCChangeTx( nPrev, nCurr, _rootlayer, _ntype)
	local nShowType = _ntype or 1
	-- dump(nShowType, "nShowType", 100)	
	if not Player:getUIHomeLayer() then
		return
	end
	if getToastNCState() and getToastNCState() == 1 then
		return
	end
	if not nPrev or not nCurr then
		return
	end
	if nPrev == nCurr then
		return
	end
	local pRootLayer = _rootlayer or RootLayerHelper:getCurRootLayer()
	if not pRootLayer then
		return
	end
	if(__isPlayingFCTx) then
		-- 如果正在播放，直接返回
		keep_last_change = {nPrev, nCurr}
		return
	end

    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
    if pParView then
    	__isPlayingFCTx = true
    	local nTag = 20170801		
		if nShowType == 1 then
			nTag = 20170801				
		elseif nShowType == 2 then
			nTag = 20180228
		end    	
    	-- 关闭特效先
	    local function closeFCChangeTx (  )
	    	--停止倒计时
	    	if nRandomNumScheduler then
	    		MUI.scheduler.unscheduleGlobal(nRandomNumScheduler)
	    		nRandomNumScheduler = nil
	    	end
	    	local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
		    if pParView then
		    	local pLayer = pParView:getChildByTag(nTag)
		    	if(pLayer) then
		    		pLayer:setVisible(false)
		    	end
		    end
		    -- 如果还有缓存中的特效，继续执行
		    __isPlayingFCTx = false
		    if(keep_last_change) then
		    	showFCChangeTx(keep_last_change[1], keep_last_change[2])
		    	keep_last_change = nil
		    end
	    end
    	-- local sTexture = "tx/other/sg_jmtx_zdlts_gx"
    	local pLayer = pParView:getChildByTag(nTag)
    	local pImg1 = nil -- 背景层1
    	local pImg2 = nil -- 背景层2
    	local pImgFc = nil -- 战斗力文字图片
    	local pTxtFcNum = nil -- 战斗力数字
		local pTxtAddFcNum = nil -- 战斗力增加的大小
		local pTxtSubFcNum = nil -- 战斗力较少的大小
		local pLayContent = nil -- 内容层

		-- addTextureToCache(sTexture)
    	if(not pLayer) then
    		
    		--特效层
	    	pLayer = MUI.MLayer.new()
	    	local nX = display.width/2
	    	local nY = display.height*0.8
	    	pLayer:setPosition(nX, nY)
	    	pParView:addView(pLayer)
	    	pLayer:setTag(nTag)
	    	--第一层：
			pImg1 = MUI.MImage.new("#v1_img_zdlxsd.png")
			pImg1:setName("img1")
			pLayer:addView(pImg1, 10)
			--第二层：
			pImg2 = MUI.MImage.new("#v1_img_zdlxsd.png")
			pImg2:setName("img2")
			pLayer:addView(pImg2, 20)
			--战力面板
			pLayContent = MUI.MLayer.new()
			pLayContent:setAnchorPoint(0.5, 0.5)
			pLayContent:setName("laycontent")
			pLayer:addView(pLayContent, 25)
			local sImgPath = "#v1_fonts_zhanlitisheng.png"
			if nShowType == 1 then
				sImgPath = "#v1_fonts_zhanlitisheng.png"				
			elseif nShowType == 2 then
				sImgPath = "#v1_fonts_zhenrongzhanli.png"
			end
			-- dump(sImgPath, "sImgPath2", 100)
			--战力名字
			pImgFc = MUI.MImage.new(sImgPath)
			pImgFc:setAnchorPoint(0, 0)
			pImgFc:setName("imgfc")
			pLayContent:addView(pImgFc, 30)
			-- 战斗力数字
			pTxtFcNum = MUI.MLabelAtlas.new({text= "0", 
				png="ui/atlas/v1_fonts_zhanlisuzi.png", pngw=22, pngh=30, scm=48})
			pTxtFcNum:setAnchorPoint(0, 0)
			pTxtFcNum:setName("txtfcnum")
			pLayContent:addView(pTxtFcNum, 31)
			--在“战力123456”到达100%缩放值（0.21秒）的时候出现“+234”
			-- “+234”效果需要等到战斗力滚动结束后做上升消失动画 

			-- 时间           位移（Y）          透明度
			-- 0秒               0                 100%
			-- 0.6秒           +20                 0%
			--数字名字
			pTxtAddFcNum = MUI.MLabelAtlas.new({text="0", 
				png="ui/atlas/v1_fonts_zhanlisuzilv.png", pngw=198/11, pngh=26, scm=48})
			pLayContent:addView(pTxtAddFcNum, 30)
			pTxtAddFcNum:setName("txtaddfcnum")
    		pTxtAddFcNum:setAnchorPoint(0, 0)
    		--在“战力123456”到达100%缩放值（0.21秒）的时候出现“+234”
			-- “+234”效果需要等到战斗力滚动结束后做上升消失动画 

			-- 时间           位移（Y）          透明度
			-- 0秒               0                 100%
			-- 0.6秒           -20                 0%
			--数字名字
			pTxtSubFcNum = MUI.MLabelAtlas.new({text="0", 
				png="ui/atlas/v1_fonts_zhanlisuzihong.png", pngw=198/11, pngh=26, scm=48})
			pLayContent:addView(pTxtSubFcNum)
			pTxtSubFcNum:setName("txtsubfcnum")
			pTxtSubFcNum:setAnchorPoint(0, 0)
		else
			pImg1 = pLayer:findViewByName("img1")
			pImg2 = pLayer:findViewByName("img2")
			pLayContent = pLayer:findViewByName("laycontent")
			pImgFc = pLayContent:findViewByName("imgfc")
			pTxtFcNum = pLayContent:findViewByName("txtfcnum")
			pTxtAddFcNum = pLayContent:findViewByName("txtaddfcnum")
			pTxtSubFcNum = pLayContent:findViewByName("txtsubfcnum")
    	end
    	if(_rootlayer) then
			pLayer:setVisible(false)
		else
			pLayer:setVisible(true)
    	end
    	if(pImg1) then
			-- “v1_img_zdlxsd”图片中心缩放做出现动画
			-- 同时 
			-- 时间                缩放值                  透明度
			-- 0秒                  40%                     49%
			-- 0.21秒               100%                    100%
			-- 保持状态等待战斗力滚动结束消失
			pImg1:stopAllActions()
			pImg1:setScale(0.4)
			pImg1:setOpacity(0.49*255)
			local pSpawnAct = cc.Spawn:create({
	    			cc.FadeTo:create(0.21, 255),
	    			cc.ScaleTo:create(0.21, 1),
	    		})
			pImg1:runAction(pSpawnAct)
    	end
    	if(pImg2) then
			-- “v1_img_zdlxsd”图片中心缩放做扩散消失动画（加亮，并且层次比第一层低）
			-- 在0.21秒的时候才出现动画，
			-- 时间                缩放值                  透明度
			-- 0.21秒               110%                    50%
			pImg2:stopAllActions()
			pImg2:setVisible(false)
			local pSeqAct = cc.Sequence:create({
				cc.DelayTime:create(0.21),
				cc.Show:create(),
				cc.Spawn:create({
	    			cc.FadeTo:create(0.21, 0.5 * 255),
	    			cc.ScaleTo:create(0.21, 1.1),
	    		}),
	    		cc.Spawn:create({
	    			cc.FadeTo:create(0.83, 0),
	    			cc.ScaleTo:create(0.83, 1.25),
	    		}),
	    	})
	    	pImg2:runAction(pSeqAct)
	    	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    	end
    	--设置位置
		local nX = 0
		local nHeight = 0
		-- 战力文字图片
		pImgFc:setPosition(nX, 0)
		-- 战斗力数字
    	if(pTxtFcNum) then
	    	--数字名字
			local sPrev = tostring(nPrev)
		    local sCurr = tostring(nCurr)
		    local nPrevStrLen = string.len(sPrev)
		    local nCurrStrLen = string.len(sCurr)
		    local sStrFirst = ""
		    if nPrevStrLen == nCurrStrLen then
		    	sStrFirst = sPrev
		    else
		    	sStrFirst = sCurr
		    end
		    pTxtFcNum:setString(sStrFirst)
		    nX = nX + 10 + pImgFc:getContentSize().width
			nHeight = math.max(nHeight, pImgFc:getContentSize().height)
			pTxtFcNum:setPosition(nX, 0)
			nX = nX + 10 + pTxtFcNum:getContentSize().width
			nHeight = math.max(nHeight, pTxtFcNum:getContentSize().height)
		end
		-- 战力增加的大小
		if(pTxtAddFcNum) then
			pTxtAddFcNum:setOpacity(255)
			pTxtAddFcNum:setVisible(false)
    		pTxtAddFcNum:setPosition(nX, 0)
    		pTxtAddFcNum:stopAllActions()
    		pTxtAddFcNum:setString(":"..tostring(nCurr - nPrev))
		end
		if(pTxtSubFcNum) then
			pTxtSubFcNum:setOpacity(255)
	   		pTxtSubFcNum:setVisible(false)
	    	pTxtSubFcNum:setPosition(nX, 0)
	    	pTxtSubFcNum:stopAllActions()
	    	pTxtSubFcNum:setString(":"..tostring(nPrev - nCurr))
	    end

    	--偏移数字移动
    	local function moveOffsetNum( )
    		local pView = nil
    		local fy = 0
    		if nCurr > nPrev then
    			pView = pTxtAddFcNum
    			fy = 20
		    else
		    	pView = pTxtSubFcNum
    			fy = -20
		    end
		    if not tolua.isnull(pView) then
    			local pSeqAct = cc.Sequence:create({
	    			cc.Spawn:create({
		    			cc.FadeOut:create(0.6),
		    			cc.MoveBy:create(0.6, cc.p(0, fy)),
		    		}),
		    		cc.CallFunc:create(closeFCChangeTx),--结束所有
		    	})
	    		pView:runAction(pSeqAct)
	    	end
    	end

		-- 以“战力123456”的中心做缩放的出现动画（这个动画是跟底部框同时出现） 
		-- 时间                缩放值                 透明度
		-- 0秒                  300%                    8%
		-- 0.21秒               100%                   100%

		-- 保持状态等待战斗力滚动结束消失
		--数字滚动动画
		local function playNumAnim( )
	    	--一开始全部变的数字都可以跳
	    	--个位跳完后就停,十位跳完后就停......
	    	--获取两个数变化的数
	    	local sPrev = tostring(nPrev)
	    	local sCurr = tostring(nCurr)
	    	local nPrevStrLen = string.len(sPrev)
	    	local nCurrStrLen = string.len(sCurr)
	    	if nPrevStrLen == nCurrStrLen then
	    		--记录不同的数字进行滚动
	    		--找出不同的下标
	    		for i=1,nCurrStrLen do
	    			local sSubStr1 = string.sub(sPrev, i, i)
	    			local sSubStr2 = string.sub(sCurr, i, i)
	    			if sSubStr1 ~= sSubStr2 then
	    				nRandomNumIndex = i
	    				break
	    			end
	    		end
	    	else
	    		--不同的位数，全部滚动，
	    		nRandomNumIndex = 1
	    	end
	    	nRandomNumIndexEnd = nCurrStrLen

	    	--容错
	    	if nRandomNumIndexEnd <= 0 then
	    		return
	    	end
	    	--播放动画
    		local fCurrT = 0
    		local fChangeT = 0.04
    		local fWei = 1/nRandomNumIndexEnd
    		nRandomNumScheduler = MUI.scheduler.scheduleGlobal(function (  )
    			--一段时间就减少一个随机
    			if fCurrT >= fWei then
    				fCurrT = 0
    				nRandomNumIndex = nRandomNumIndex + 1
    			end
    			local sStr = ""
    			--数字
    			for i=1,nCurrStrLen do
    				local sSubStr = string.sub(sCurr, i, i)
    				if i >= nRandomNumIndex and i <= nRandomNumIndexEnd then
    					sSubStr = math.random(0,9)
    				end
    				sStr = sStr .. sSubStr
    			end
    			if not tolua.isnull(pTxtFcNum) then
    				pTxtFcNum:setString(sStr)
    			end

    			--跳出
    			if nRandomNumIndex > nRandomNumIndexEnd then
    				--显示偏差数字移动
    				moveOffsetNum()
    				--停止倒计时
			    	if nRandomNumScheduler then
			    		MUI.scheduler.unscheduleGlobal(nRandomNumScheduler)
			    		nRandomNumScheduler = nil
			    	end
    			end

    			--累积时间
    			fCurrT = fCurrT + fChangeT
		    end,fChangeT)
		end
		--整体动画
		pLayContent:setScale(4)
		pLayContent:setOpacity(0.08*255)
		local pSeqAct = cc.Sequence:create({
			cc.Spawn:create({
    			cc.FadeTo:create(0.3, 255),
    			cc.ScaleTo:create(0.3, 1),
    		}),
    		cc.DelayTime:create(0.05),--延迟1秒
    		cc.CallFunc:create(function (  )
    			if(nCurr > nPrev) then
    				if(pTxtAddFcNum) then
    					pTxtAddFcNum:setVisible(true)
    				end
    			else
    				if(pTxtSubFcNum) then
    					pTxtSubFcNum:setVisible(true)
    				end
    			end
    		end),--显示偏移数字
    		-- cc.DelayTime:create(0.05),--延迟1秒
    		cc.CallFunc:create(playNumAnim),--播放滚动数字
    	})
		pLayContent:runAction(pSeqAct)

		if nCurr > nPrev then
			--光线特效，0秒的时候跟其他效果一起出现，层次在最上层，盖在其他层的上面。
			local tArmData1  = {
                sPlist = "tx/other/sg_jmtx_zdlts_gx",
                nImgType = 1,
				nFrame = 22, -- 总帧数
				pos = {-10, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1.15,-- 初始的缩放值
				nBlend = 1, -- 需要加亮
			   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
				tActions = {
					 {
						nType = 1, -- 序列帧播放
						sImgName = "sg_jmtx_zdlts_gx_",
						nSFrame = 1, -- 开始帧下标
						nEFrame = 22, -- 结束帧下标
						tValues = nil, -- 参数列表
					},
				},
			}
			local pArm1 = MArmatureUtils:createMArmature(
				tArmData1, 
				pLayer, 
				99, 
				cc.p(0, 0),
				function ( _pArm )
			    	_pArm:removeSelf()
			    	_pArm = nil
			    end, Scene_arm_type.normal)
			if pArm1 then
				pArm1:play(1)
			end

			local tArmData2 = {
				nFrame = 17, -- 总帧数
				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1.4,-- 初始的缩放值
				nBlend = 1, -- 需要加亮
			  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
				tActions = {
					{
						nType = 5, -- 缩放 + 透明度
						sImgName = "sg_jmtx_zdlts_gx_0001",
						nSFrame = 1,
						nEFrame = 6,
						tValues = {-- 参数列表
							{1, 1}, -- 开始, 结束缩放值
							{25, 200}, -- 开始, 结束透明度值
						},
					},
					{
						nType = 5, -- 缩放 + 透明度
						sImgName = "sg_jmtx_zdlts_gx_0001",
						nSFrame = 7,
						nEFrame = 17,
						tValues = {-- 参数列表
							{1, 1}, -- 开始, 结束缩放值
							{190, 0}, -- 开始, 结束透明度值
						},
					},
				},
			}
			local pArm2 = MArmatureUtils:createMArmature(
				tArmData2, 
				pLayer, 
				99, 
				cc.p(0, 0),
			    function ( _pArm )
			    	_pArm:removeSelf()
			    	_pArm = nil
			    end, Scene_arm_type.normal)
			if pArm2 then
				pArm2:play(1)
			end
		end
    	pLayContent:setLayoutSize(nX, nHeight)
    end
end

--数值跳字效果(征收资源，体力，兵力)
--pOffsetPos, 位置
function showNumJump( nNum, bShowPercent )
	if not Player:getUIHomeLayer() then
		return
	end
	-- nNum = 60
	if not nNum then
		return
	end
	if nNum <= 0 then
		return
	end

	local pLayer = MUI.MLayer.new()
	local pTxtAddFcNum = MUI.MLabelAtlas.new({text=":"..nNum, 
			png="ui/atlas/v1_fonts_zhanlisuzilv.png", pngw=198/11, pngh=26, scm=48})
	pTxtAddFcNum:setAnchorPoint(0, 0)
	pLayer:addView(pTxtAddFcNum)
	pLayer:setAnchorPoint(0.5, 0.5)	
	if bShowPercent and bShowPercent == true then
		local pImgPercent = MUI.MImage.new("#v1_fonts_%.png")
		pImgPercent:setAnchorPoint(0, 0.5)
		pImgPercent:setPosition(pTxtAddFcNum:getWidth(), pTxtAddFcNum:getHeight()/2)
		pLayer:addView(pImgPercent)
		pLayer:setContentSize(cc.size(pTxtAddFcNum:getWidth()+pImgPercent:getWidth(), pTxtAddFcNum:getHeight()/2))
	else
		pLayer:setContentSize(pTxtAddFcNum:getContentSize())
	end
	--删除
	local function removeLayer( )
		if not tolua.isnull(pLayer) then
			pLayer:removeSelf()
		end
	end

	--进行动作
	-- 时间(S)         缩放值(%)       位移(Y)         透明度(%)
	-- 0                 70              0                100
	-- 0.17              100             5                100
	-- 0.42              100             12.7             100
	-- 0.67              80              20.4             100
	-- 0.92              80              28              0
	pLayer:setScale(0.7)
	local pSeqAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.ScaleTo:create(0.17, 1),
			cc.MoveBy:create(0.17, cc.p(0, 5)),
		}),
		cc.Spawn:create({
			cc.ScaleTo:create(0.47 - 0.17, 1),
			cc.MoveBy:create(0.47 - 0.17, cc.p(0, 12.7 - 5)),
		}),
		cc.Spawn:create({
			cc.ScaleTo:create(0.67 - 0.47, 0.85),
			cc.MoveBy:create(0.67 - 0.47, cc.p(0, 20.4 - 12.7)),
		}),
		cc.Spawn:create({
			cc.ScaleTo:create(0.92 - 0.67, 0.85),
			cc.MoveBy:create(0.92 - 0.67, cc.p(0, 28 - 20.4)),
			cc.FadeOut:create(0.92 - 0.67),
		}),
		cc.CallFunc:create(removeLayer),
	})
	pLayer:runAction(pSeqAct)
	return pLayer
end
--打造动画
function showHammer( _pView )
	-- body
	if not _pView then
		return
	end
	local pLayer = MUI.MLayer.new(true)
	pLayer:setLayoutSize(40, 40)
	pLayer:setName("Hammer_Action_Layer")
	_pView:addView(pLayer, 1)
	centerInView(_pView, pLayer)

	local pImg1 = MUI.MImage.new("#v1_img_shengqabb2.png", {scale9=false})
	pLayer:addView(pImg1)
	centerInView(pLayer, pImg1)

	local pImg2 = MUI.MImage.new("#v1_img_shengqabb3.png", {scale9=false})
	pImg2:setRotation(-10)
	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLayer:addView(pImg2)
	centerInView(pLayer, pImg2)

	local rotate1 = cc.RotateTo:create(0.4, 10)
	local rotate2 = cc.RotateTo:create(0.8, -10)
	pImg2:runAction(cc.RepeatForever:create(cc.Sequence:create(rotate1, rotate2)))
	return pLayer
end

--删除打造动画
function removeHammer( _pView )
	-- body
	if not _pView then
		return
	end
	print("---------2------------")
	local pLayer = _pView:findViewByName("Hammer_Action_Layer")
	if pLayer then
		pLayer:removeSelf()
		pLayer = nil
	end	
end

--乱军底座转圈效果
-- _scale: 图片缩放大小
function getCircleWhirl(_scale)
	-- body
	local pLayer = MUI.MLayer.new()
	local pImg = MUI.MImage.new("ui/v1_img_hongkuang_zyfb.png")
	if _scale then
		pImg:setScale(_scale)
	end
	-- pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLayer:setLayoutSize(pImg:getWidth(), pImg:getHeight())
	pLayer:addView(pImg, 10)
	pLayer:setScaleX(1.6)
	pLayer:setScaleY(0.6)

	pImg:runAction(cc.RepeatForever:create(
    cc.RotateBy:create(5, 360)))


	return pLayer
end

--箭头指示特效
--_height:位移高度
function getArrowAction(_height, _normal)
	-- body
	local nMoveHeight = _height or 50
	local pLayer = MUI.MLayer.new()
	local pImg
	if _normal then
		pImg = MUI.MImage.new("#v1_img_zhiyin_sj.png")
	else
		pImg = createCCBillBorad("#v1_img_zhiyin_sj.png")
	end
	local nTag = 201708211702
	pImg:setTag(nTag)
	pLayer:setLayoutSize(pImg:getContentSize().width, pImg:getContentSize().height)
	pLayer:addView(pImg, 10)
	centerInView(pLayer, pImg)
	local posX = pImg:getPositionX()
	local posY = pImg:getPositionY()
	local action1 = cc.MoveTo:create(0.7, cc.p(posX, posY + nMoveHeight))
	local action2 = cc.MoveTo:create(0.7, cc.p(posX, posY))

	local seq = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	pImg:runAction(seq)


	return pLayer
end

--已经弃用
--显示竞技场排行发生变化动画
-- local nRankNumScheduler = nil 
-- local nRankNumIndexEnd = 0    
-- local nRankNumIndex = 0       
-- local keep_last_rank_change = nil   
-- local __isPlayingRANkTx = false 
-- -- nPrevRank(int):　前排名值
-- -- nCurrRank（int）: 新排名值
-- -- _rootlayer（MRootLayer）： 如果有传值，则为初始化
-- function showRankChangeTx( nPrevRank, nCurrRank, _rootlayer)
-- 	if not Player:getUIHomeLayer() then
-- 		return
-- 	end
-- 	if getToastNCState() and getToastNCState() == 1 then
-- 		return
-- 	end	
-- 	if not nPrevRank or not nCurrRank then
-- 		return
-- 	end	
-- 	if nPrevRank == nCurrRank then
-- 		return
-- 	end	
-- 	local pRootLayer = _rootlayer or RootLayerHelper:getCurRootLayer()
-- 	if not pRootLayer then
-- 		return
-- 	end	
-- 	if(__isPlayingRANkTx) then
-- 		-- 如果正在播放，直接返回
-- 		keep_last_rank_change = {nPrevRank, nCurrRank}
-- 		return
-- 	end	
--     local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
--     if pParView then
--     	__isPlayingRANkTx = true
--     	local nTag = 20180127
--     	-- 关闭特效先
-- 	    local function closeRankChangeTx (  )
-- 	    	--停止倒计时
-- 	    	if nRankNumScheduler then
-- 	    		MUI.scheduler.unscheduleGlobal(nRankNumScheduler)
-- 	    		nRankNumScheduler = nil
-- 	    	end
-- 	    	local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.toastlayer)
-- 		    if pParView then
-- 		    	local pLayer = pParView:getChildByTag(nTag)
-- 		    	if(pLayer) then
-- 		    		pLayer:setVisible(false)
-- 		    	end
-- 		    end
-- 		    -- 如果还有缓存中的特效，继续执行
-- 		    __isPlayingRANkTx = false
-- 		    if(keep_last_rank_change) then
-- 		    	showRankChangeTx(keep_last_rank_change[1], keep_last_rank_change[2])
-- 		    	keep_last_rank_change = nil
-- 		    end
-- 	    end
--     	-- local sTexture = "tx/other/sg_jmtx_zdlts_gx"
--     	local pLayer = pParView:getChildByTag(nTag)    	

--     	local pImg1 = nil -- 背景层1
--     	local pImg2 = nil -- 背景层2
--     	local pImgFc = nil -- 排行文字图片
--     	local pTxtFcNum = nil -- 排行数字
-- 		local pTxtAddFcNum = nil -- 排行增加的大小
-- 		local pImgArrowUp = nil
-- 		local pTxtSubFcNum = nil -- 排行较少的大小
-- 		local pImgArrowDown = nil
-- 		local pLayContent = nil -- 内容层

-- 		-- addTextureToCache(sTexture)
--     	if(not pLayer) then    		
--     		--特效层
-- 	    	pLayer = MUI.MLayer.new()
-- 	    	local nX = display.width/2
-- 	    	local nY = display.height*0.8
-- 	    	pLayer:setPosition(nX, nY)
-- 	    	pParView:addView(pLayer)
-- 	    	pLayer:setTag(nTag)
-- 	    	--第一层：
-- 			pImg1 = MUI.MImage.new("#v1_img_zdlxsd.png")
-- 			pImg1:setName("img1")
-- 			pLayer:addView(pImg1, 10)
-- 			--第二层：
-- 			pImg2 = MUI.MImage.new("#v1_img_zdlxsd.png")
-- 			pImg2:setName("img2")
-- 			pLayer:addView(pImg2, 20)
-- 			--排行面板
-- 			pLayContent = MUI.MLayer.new()
-- 			pLayContent:setAnchorPoint(0.5, 0.5)
-- 			pLayContent:setName("laycontent")
-- 			pLayer:addView(pLayContent, 25)
-- 			--排行名字
-- 			pImgFc = MUI.MImage.new("#v2_img_paiming.png")
-- 			pImgFc:setAnchorPoint(0, 0)
-- 			pImgFc:setName("imgfc")
-- 			pLayContent:addView(pImgFc, 30)
-- 			--排行数字
-- 			pTxtFcNum = MUI.MLabelAtlas.new({text= "0", 
-- 				png="ui/atlas/v2_img_paiming1.png", pngw=33, pngh=38, scm=48})
-- 			pTxtFcNum:setAnchorPoint(0, 0)
-- 			pTxtFcNum:setName("txtfcnum")
-- 			pLayContent:addView(pTxtFcNum, 31)

-- 			--数字名字
-- 			pTxtAddFcNum = MUI.MLabelAtlas.new({text="0", 
-- 				png="ui/atlas/v2_img_paiming3.png", pngw=29, pngh=30, scm=48})
-- 			pLayContent:addView(pTxtAddFcNum, 30)
-- 			pTxtAddFcNum:setName("txtaddfcnum")
--     		pTxtAddFcNum:setAnchorPoint(0, 0)

--     		--上升箭头
--     		pImgArrowUp = MUI.MImage.new("#v1_img_shengjilvjiantou2.png")
--     		pLayContent:addView(pImgArrowUp, 30)
-- 			pImgArrowUp:setAnchorPoint(0, 0)
-- 			pImgArrowUp:setName("imgarrowup")

-- 			--数字名字
-- 			pTxtSubFcNum = MUI.MLabelAtlas.new({text="0", 
-- 				png="ui/atlas/v2_img_paiming2.png", pngw=29, pngh=30, scm=48})
-- 			pLayContent:addView(pTxtSubFcNum)
-- 			pTxtSubFcNum:setName("txtsubfcnum")
-- 			pTxtSubFcNum:setAnchorPoint(0, 0)

--     		pImgArrowDown = MUI.MImage.new("#v1_img_shengjilvjianto.png")
-- 			pLayContent:addView(pImgArrowDown, 30)
-- 			pImgArrowDown:setFlippedY(true)			
-- 			pImgArrowDown:setName("imgarrowdown")
-- 			pImgArrowDown:setAnchorPoint(0, 0)
-- 		else
-- 			pImg1 = pLayer:findViewByName("img1")
-- 			pImg2 = pLayer:findViewByName("img2")
-- 			pLayContent = pLayer:findViewByName("laycontent")
-- 			pImgFc = pLayContent:findViewByName("imgfc")
-- 			pTxtFcNum = pLayContent:findViewByName("txtfcnum")
-- 			pTxtAddFcNum = pLayContent:findViewByName("txtaddfcnum")
-- 			pImgArrowUp = pLayContent:findViewByName("imgarrowup")
-- 			pTxtSubFcNum = pLayContent:findViewByName("txtsubfcnum")
-- 			pImgArrowDown = pLayContent:findViewByName("imgarrowdown")
--     	end
--     	if(_rootlayer) then
-- 			pLayer:setVisible(false)
-- 		else
-- 			pLayer:setVisible(true)
--     	end
--     	if(pImg1) then
-- 			-- “v1_img_zdlxsd”图片中心缩放做出现动画
-- 			-- 同时 
-- 			-- 时间                缩放值                  透明度
-- 			-- 0秒                  40%                     49%
-- 			-- 0.21秒               100%                    100%
-- 			-- 保持状态等待战斗力滚动结束消失
-- 			pImg1:stopAllActions()
-- 			pImg1:setScale(0.4)
-- 			pImg1:setOpacity(0.49*255)
-- 			local pSpawnAct = cc.Spawn:create({
-- 	    			cc.FadeTo:create(0.21, 255),
-- 	    			cc.ScaleTo:create(0.21, 1),
-- 	    		})
-- 			pImg1:runAction(pSpawnAct)
--     	end
--     	if(pImg2) then
-- 			-- “v1_img_zdlxsd”图片中心缩放做扩散消失动画（加亮，并且层次比第一层低）
-- 			-- 在0.21秒的时候才出现动画，
-- 			-- 时间                缩放值                  透明度
-- 			-- 0.21秒               110%                    50%
-- 			pImg2:stopAllActions()
-- 			pImg2:setVisible(false)
-- 			local pSeqAct = cc.Sequence:create({
-- 				cc.DelayTime:create(0.21),
-- 				cc.Show:create(),
-- 				cc.Spawn:create({
-- 	    			cc.FadeTo:create(0.21, 0.5 * 255),
-- 	    			cc.ScaleTo:create(0.21, 1.1),
-- 	    		}),
-- 	    		cc.Spawn:create({
-- 	    			cc.FadeTo:create(0.83, 0),
-- 	    			cc.ScaleTo:create(0.83, 1.25),
-- 	    		}),
-- 	    	})
-- 	    	pImg2:runAction(pSeqAct)
-- 	    	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
--     	end
--     	--设置位置
-- 		local nX = 0
-- 		local nHeight = 0
-- 		-- 战力文字图片
-- 		pImgFc:setPosition(nX, 0)
-- 		-- 战斗力数字
--     	if(pTxtFcNum) then
-- 	    	--数字名字
-- 			local sPrev = tostring(nPrevRank)
-- 		    local sCurr = tostring(nCurrRank)
-- 		    local nPrevStrLen = string.len(sPrev)
-- 		    local nCurrStrLen = string.len(sCurr)
-- 		    local sStrFirst = ""
-- 		    if nPrevStrLen == nCurrStrLen then
-- 		    	sStrFirst = sPrev
-- 		    else
-- 		    	sStrFirst = sCurr
-- 		    end
-- 		    pTxtFcNum:setString(sStrFirst)
-- 		    nX = nX + 10 + pImgFc:getContentSize().width
-- 			nHeight = math.max(nHeight, pImgFc:getContentSize().height)
-- 			pTxtFcNum:setPosition(nX, 0)
-- 			nX = nX + 10 + pTxtFcNum:getContentSize().width
-- 			nHeight = math.max(nHeight, pTxtFcNum:getContentSize().height)
-- 		end
-- 		-- 战力增加的大小
-- 		if(pTxtAddFcNum) then
-- 			pTxtAddFcNum:setOpacity(255)
-- 			pTxtAddFcNum:setVisible(false)
--     		pTxtAddFcNum:setPosition(nX, 0)
--     		pTxtAddFcNum:stopAllActions()
--     		pTxtAddFcNum:setString(":"..tostring(nPrevRank - nCurrRank))
--     		if(pImgArrowUp) then
-- 				pImgArrowUp:setOpacity(255)
-- 				pImgArrowUp:setVisible(false)
-- 	    		pImgArrowUp:setPosition(nX + pTxtAddFcNum:getContentSize().width, 0)
-- 	    		pImgArrowUp:stopAllActions()
-- 			end
-- 		end

-- 		if(pTxtSubFcNum) then
-- 			pTxtSubFcNum:setOpacity(255)
-- 	   		pTxtSubFcNum:setVisible(false)
-- 	    	pTxtSubFcNum:setPosition(nX, 0)
-- 	    	pTxtSubFcNum:stopAllActions()
-- 	    	pTxtSubFcNum:setString(":"..tostring(nCurrRank - nPrevRank))

-- 		    if (pImgArrowDown) then
-- 				pImgArrowDown:setOpacity(255)
-- 				pImgArrowDown:setVisible(false)
-- 	    		pImgArrowDown:setPosition(nX + pTxtSubFcNum:getContentSize().width, 0)
-- 	    		pImgArrowDown:stopAllActions()	    		    	
-- 		    end	    	
-- 	    end

--     	--偏移数字移动
--     	local function moveOffsetRankNum( )
--     		local pView = nil
--     		local pArrow = nil
--     		local fy = 0
--     		if nCurrRank < nPrevRank then
--     			pView = pTxtAddFcNum
--     			pArrow = pImgArrowUp
--     			fy = 20
-- 		    else
-- 		    	pView = pTxtSubFcNum
-- 		    	pArrow = pImgArrowDown
--     			fy = -20
-- 		    end
-- 		    if not tolua.isnull(pView) then
--     			local pSeqAct = cc.Sequence:create({
-- 	    			cc.Spawn:create({
-- 		    			cc.FadeOut:create(0.6),
-- 		    			cc.MoveBy:create(0.6, cc.p(0, fy)),
-- 		    		}),
-- 		    		cc.CallFunc:create(closeRankChangeTx),--结束所有
-- 		    	})
-- 	    		pView:runAction(pSeqAct)
-- 	    	end
-- 		    if not tolua.isnull(pArrow) then
--     			local pSeqAct = cc.Sequence:create({
-- 	    			cc.Spawn:create({
-- 		    			cc.FadeOut:create(0.6),
-- 		    			cc.MoveBy:create(0.6, cc.p(0, fy)),
-- 		    		}),
-- 		    		--cc.CallFunc:create(closeRankChangeTx),--结束所有
-- 		    	})
-- 	    		pArrow:runAction(pSeqAct)
-- 	    	end	    	
--     	end

-- 		-- 以“战力123456”的中心做缩放的出现动画（这个动画是跟底部框同时出现） 
-- 		-- 时间                缩放值                 透明度
-- 		-- 0秒                  300%                    8%
-- 		-- 0.21秒               100%                   100%

-- 		-- 保持状态等待战斗力滚动结束消失
-- 		--数字滚动动画
-- 		local function playRankNumAnim( )
-- 	    	--一开始全部变的数字都可以跳
-- 	    	--个位跳完后就停,十位跳完后就停......
-- 	    	--获取两个数变化的数
-- 	    	local sPrev = tostring(nPrevRank)
-- 	    	local sCurr = tostring(nCurrRank)
-- 	    	local nPrevStrLen = string.len(sPrev)
-- 	    	local nCurrStrLen = string.len(sCurr)
-- 	    	if nPrevStrLen == nCurrStrLen then
-- 	    		--记录不同的数字进行滚动
-- 	    		--找出不同的下标
-- 	    		for i=1,nCurrStrLen do
-- 	    			local sSubStr1 = string.sub(sPrev, i, i)
-- 	    			local sSubStr2 = string.sub(sCurr, i, i)
-- 	    			if sSubStr1 ~= sSubStr2 then
-- 	    				nRankNumIndex = i
-- 	    				break
-- 	    			end
-- 	    		end
-- 	    	else
-- 	    		--不同的位数，全部滚动，
-- 	    		nRankNumIndex = 1
-- 	    	end
-- 	    	nRankNumIndexEnd = nCurrStrLen

-- 	    	--容错
-- 	    	if nRankNumIndexEnd <= 0 then
-- 	    		return
-- 	    	end
-- 	    	--播放动画
--     		local fCurrT = 0
--     		local fChangeT = 0.04
--     		local fWei = 1/nRankNumIndexEnd
--     		nRankNumScheduler = MUI.scheduler.scheduleGlobal(function (  )
--     			--一段时间就减少一个随机
--     			if fCurrT >= fWei then
--     				fCurrT = 0
--     				nRankNumIndex = nRankNumIndex + 1
--     			end
--     			local sStr = ""
--     			--数字
--     			for i=1,nCurrStrLen do
--     				local sSubStr = string.sub(sCurr, i, i)
--     				if i >= nRankNumIndex and i <= nRankNumIndexEnd then
--     					sSubStr = math.random(0,9)
--     				end
--     				sStr = sStr .. sSubStr
--     			end
--     			if not tolua.isnull(pTxtFcNum) then
--     				pTxtFcNum:setString(sStr)
--     			end

--     			--跳出
--     			if nRankNumIndex > nRankNumIndexEnd then
--     				--显示偏差数字移动
--     				moveOffsetRankNum()
--     				--停止倒计时
-- 			    	if nRankNumScheduler then
-- 			    		MUI.scheduler.unscheduleGlobal(nRankNumScheduler)
-- 			    		nRankNumScheduler = nil
-- 			    	end
--     			end

--     			--累积时间
--     			fCurrT = fCurrT + fChangeT
-- 		    end,fChangeT)
-- 		end
-- 		--整体动画
-- 		pLayContent:setScale(4)
-- 		pLayContent:setOpacity(0.08*255)
-- 		local pSeqAct = cc.Sequence:create({
-- 			cc.Spawn:create({
--     			cc.FadeTo:create(0.3, 255),
--     			cc.ScaleTo:create(0.3, 1),
--     		}),
--     		cc.DelayTime:create(0.05),--延迟1秒
--     		cc.CallFunc:create(function (  )
--     			if(nCurrRank < nPrevRank) then
--     				if(pTxtAddFcNum) then
--     					pTxtAddFcNum:setVisible(true)
--     				end
--     				if(pImgArrowUp) then
--     					pImgArrowUp:setVisible(true)
--     				end
--     			else
--     				if(pTxtSubFcNum) then
--     					pTxtSubFcNum:setVisible(true)
--     				end
--     				if(pImgArrowDown) then
--     					pImgArrowDown:setVisible(true)
--     				end
--     			end
--     		end),--显示偏移数字
--     		-- cc.DelayTime:create(0.05),--延迟1秒
--     		cc.CallFunc:create(playRankNumAnim),--播放滚动数字
--     	})
-- 		pLayContent:runAction(pSeqAct)

-- 		if nCurrRank < nPrevRank then
-- 			--光线特效，0秒的时候跟其他效果一起出现，层次在最上层，盖在其他层的上面。
-- 			local tArmData1  = {
-- 				nFrame = 22, -- 总帧数
-- 				pos = {-10, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 				fScale = 1.15,-- 初始的缩放值
-- 				nBlend = 1, -- 需要加亮
-- 			   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 				tActions = {
-- 					 {
-- 						nType = 1, -- 序列帧播放
-- 						sImgName = "sg_jmtx_zdlts_gx_",
-- 						nSFrame = 1, -- 开始帧下标
-- 						nEFrame = 22, -- 结束帧下标
-- 						tValues = nil, -- 参数列表
-- 					},
-- 				},
-- 			}
-- 			local pArm1 = MArmatureUtils:createMArmature(
-- 				tArmData1, 
-- 				pLayer, 
-- 				99, 
-- 				cc.p(0, 0),
-- 				function ( _pArm )
-- 			    	_pArm:removeSelf()
-- 			    	_pArm = nil
-- 			    end, Scene_arm_type.normal)
-- 			if pArm1 then
-- 				pArm1:play(1)
-- 			end

-- 			local tArmData2 = {
-- 				nFrame = 17, -- 总帧数
-- 				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 				fScale = 1.4,-- 初始的缩放值
-- 				nBlend = 1, -- 需要加亮
-- 			  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 				tActions = {
-- 					{
-- 						nType = 5, -- 缩放 + 透明度
-- 						sImgName = "sg_jmtx_zdlts_gx_0001",
-- 						nSFrame = 1,
-- 						nEFrame = 6,
-- 						tValues = {-- 参数列表
-- 							{1, 1}, -- 开始, 结束缩放值
-- 							{25, 200}, -- 开始, 结束透明度值
-- 						},
-- 					},
-- 					{
-- 						nType = 5, -- 缩放 + 透明度
-- 						sImgName = "sg_jmtx_zdlts_gx_0001",
-- 						nSFrame = 7,
-- 						nEFrame = 17,
-- 						tValues = {-- 参数列表
-- 							{1, 1}, -- 开始, 结束缩放值
-- 							{190, 0}, -- 开始, 结束透明度值
-- 						},
-- 					},
-- 				},
-- 			}
-- 			local pArm2 = MArmatureUtils:createMArmature(
-- 				tArmData2, 
-- 				pLayer, 
-- 				99, 
-- 				cc.p(0, 0),
-- 			    function ( _pArm )
-- 			    	_pArm:removeSelf()
-- 			    	_pArm = nil
-- 			    end, Scene_arm_type.normal)
-- 			if pArm2 then
-- 				pArm2:play(1)
-- 			end
-- 		end
--     	pLayContent:setLayoutSize(nX, nHeight)
--     end
-- end

--显示TLBoss警告动画
function showTLBossWarning( pView, nZoder )
	if not pView then
		return
	end
	
	local pLayer = MUI.MLayer.new()
	pLayer:setContentSize(640, 164)
	pView:addView(pLayer, nZoder)
	centerInView(pView, pLayer)


	local pImgBg1 = MUI.MImage.new("ui/big_img_sep/rwww_ui_dc1_a_01.png")
	pLayer:addView(pImgBg1)
	centerInView(pLayer, pImgBg1)

	local pImgBg2 = MUI.MImage.new("ui/big_img_sep/rwww_ui_dc1_a_02.png")
	pLayer:addView(pImgBg2)
	centerInView(pLayer, pImgBg2)

	local pImgFont = MUI.MImage.new("#v2_fonts_jinggaoBOSS.png")
	pLayer:addView(pImgFont)
	pImgFont:setPosition(640/2, 164/2-10)

	local pImgTrig = MUI.MImage.new("ui/big_img/v2_fonts_jinggaoBOSS2.png")
	pImgTrig:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLayer:addView(pImgTrig)
	pImgTrig:setPosition(640/2 - 50, 164/2+9)

	local pImgLong = MUI.MImage.new("ui/big_img/rwww_ui_lt_a_01.png")
	pLayer:addView(pImgLong)
	pImgLong:setPosition(640/2, 150)

	local pImgLong2 = MUI.MImage.new("ui/big_img/rwww_ui_lt_a_01.png")
	pImgLong2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLayer:addView(pImgLong2)
	pImgLong2:setPosition(640/2, 150)

	-- 第一层：“rwww_ui_dc1_a_01”
	-- 时间     缩放值（仅缩放Y值）   
	-- 0秒           0%   
	-- 0.12秒        0%            
	-- 0.38秒        100%           
	-- 2.58秒        100%       
	-- 2.85秒        0%	
	pImgBg1:setScaleY(0)
	local pAct = cc.Sequence:create({
	cc.DelayTime:create(0.12),
	cc.ScaleTo:create(0.38 - 0.12, 1, 1),
	cc.DelayTime:create(2.58 - 0.38),
	cc.ScaleTo:create(2.85 - 2.58, 1, 0),
	})
	pImgBg1:runAction(pAct)

	-- 第二层：“rwww_ui_dc1_a_02”
	-- 时间     缩放值（仅缩放Y值）       透明度
	-- 0秒           150%                   0% 
	-- 0.12秒        150%                   0%
	-- 0.33秒        100%                  100%
	-- 2.62秒        100%                  100%
	-- 2.85秒        150%                   0%
	pImgBg2:setScaleY(1.5)
	pImgBg2:setOpacity(0)
	local pAct = cc.Sequence:create({
	cc.DelayTime:create(0.12),
	cc.Spawn:create({
    	cc.ScaleTo:create(0.33 - 0.12, 1, 1),
    	cc.FadeTo:create(0.33 - 0.12, 255),
    	}),
	cc.DelayTime:create(2.62 - 0.33),
	cc.Spawn:create({
    	cc.ScaleTo:create(2.85 - 2.62, 1, 1.5),
    	cc.FadeTo:create(2.85 - 2.62, 0),
    	}),
	})
	pImgBg2:runAction(pAct)

	-- 第三层：“v2_fonts_jinggaoBOSS”
	-- 时间          透明度           位置(Y)
	-- 0秒            0%                4
	-- 0.33秒         0%                4
	-- 0.54秒         100%              0
	-- 2.62秒         100%              0
	-- 2.83秒         0%                0
	local nY = pImgFont:getPositionY()
	pImgFont:setPositionY(nY + 4)
	pImgFont:setOpacity(0)
	local pAct = cc.Sequence:create({
	cc.DelayTime:create(0.33),
	cc.Spawn:create({
    	cc.MoveBy:create(0.54 - 0.33, cc.p(0, -4)),
    	cc.FadeTo:create(0.54 - 0.33, 255),
    	}),
	cc.DelayTime:create(2.62 - 0.54),
	cc.FadeTo:create(2.83 - 2.62, 0),
	})
	pImgFont:runAction(pAct)

	-- 第四层：“v2_fonts_jinggaoBOSS2” 摆放在“v2_fonts_jinggaoBOSS”图（Y-54,X+18）的位置上，
	-- 在0.6秒的时候开始播放。  连续播放3次 。
	-- 时间     透明度     缩放     是否加亮
	-- 0秒       100%      100%      加亮
	-- 0.62秒    0%        240%      加亮
	local function func(  )
		pImgTrig:setOpacity(255)
		pImgTrig:setScale(1)
	end
	pImgTrig:setOpacity(0)
	local pAct = cc.Sequence:create({
			cc.DelayTime:create(0.6),
			cc.CallFunc:create(func),
			cc.Spawn:create({
		    	cc.ScaleTo:create(0.62, 2.4),
		    	cc.FadeTo:create(0.62, 0),
	    	}),
			cc.CallFunc:create(func),

			cc.Spawn:create({
		    	cc.ScaleTo:create(0.62, 2.4),
		    	cc.FadeTo:create(0.62, 0),
	    	}),
			cc.CallFunc:create(func),

			cc.Spawn:create({
		    	cc.ScaleTo:create(0.62, 2.4),
		    	cc.FadeTo:create(0.62, 0),
	    	}),
		})
	pImgTrig:runAction(pAct)

	-- 第五层：“rwww_ui_lt_a_01” 
	-- 时间     透明度     缩放值    
	-- 0秒        0%        420%
	-- 0.21秒    100%       100%
	-- 2.62秒    100%       100%
	-- 2.83秒    0          100%
	pImgLong:setOpacity(0)
	pImgLong:setScale(4.2)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
	    	cc.ScaleTo:create(0.21, 1),
	    	cc.FadeTo:create(0.21, 255),
    	}),
    	cc.DelayTime:create(2.62 - 0.21),
    	cc.FadeTo:create(2.83 - 2.62, 0),
	})
	pImgLong:runAction(pAct)

	-- 第六层：“rwww_ui_lt_a_01” 
	-- 时间     透明度     缩放值       是否加亮
	-- 0秒        0%        115%          加亮
	-- 0.20秒     0%        115%          加亮
	-- 0.21秒    100%       115%          加亮
	-- 0.29秒     50%       111%          加亮
	-- 0.54秒     32%       100%          加亮 
	-- 1秒        0%        100%           加亮
	pImgLong2:setOpacity(0)
	pImgLong2:setScale(1.15)
	local pAct = cc.Sequence:create({
		cc.DelayTime:create(0.2),
		cc.FadeTo:create(0.21 - 0.2, 255),
		cc.Spawn:create({
	    	cc.ScaleTo:create(0.29 - 0.21, 1.11),
	    	cc.FadeTo:create(0.29 - 0.21, 255 * 0.5),
    	}),
    	cc.Spawn:create({
	    	cc.ScaleTo:create(0.54 - 0.29, 1),
	    	cc.FadeTo:create(0.54 - 0.29, 255 * 0.32),
    	}),
    	cc.FadeTo:create(1 - 0.54, 0),
	})
	pImgLong2:runAction(pAct)

	--播放完之后要移除
	local pAct = cc.Sequence:create({
		cc.DelayTime:create(2.9), 
		cc.CallFunc:create(function (  )
			pLayer:removeFromParent()
		end),
		})
	pLayer:runAction(pAct)	
end

--气泡响应的图片动画

function showBubbleImgAction( _pView )
	-- body
	if not _pView then
		return
	end 
	_pView:stopAllActions()
	_pView:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	local action1 = cc.FadeTo:create(0, 255)
	local action2 = cc.FadeTo:create(0.1, 255*0.5)
	local action3 = cc.FadeTo:create(0.3, 0)
	local actions = cc.Sequence:create(action1, action2, action3)
	_pView:runAction(actions)
end

--冥界入侵出征城池暗黑特效
function showMingjieWorldEffect( _nParent )
    -- body
    if not _nParent then
        return
    end
    local tParitcles ={}
    if not tParitcles[1] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1.5)
        pParitcleB:setPosition(61,0)
        _nParent:addChild(pParitcleB,1000)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[2] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1)
        pParitcleB:setPosition(4,-28)
        -- self:addChild(pParitcleB,1001)
        _nParent:addChild(pParitcleB,1001)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[3] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_03.plist")
        pParitcleB:setScale(1.5)
        pParitcleB:setPosition(-50,-5)
        -- self:addChild(pParitcleB,1002)
        _nParent:addChild(pParitcleB,1002)
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[4] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(2.2)
        pParitcleB:setPosition(3,2)

        _nParent:addChild(pParitcleB,1003)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[5] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(1.3)
        pParitcleB:setPosition(72,2)

        _nParent:addChild(pParitcleB,1004)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[6] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_05.plist")
        pParitcleB:setScale(1.3)
        pParitcleB:setPosition(-60,0)

        _nParent:addChild(pParitcleB,1005)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[7] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_14.plist")
        pParitcleB:setScale(0.8)
        pParitcleB:setPosition(6,0)
        -- self:addChild(pParitcleB,1006)
        _nParent:addChild(pParitcleB,1006)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[8] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_14.plist")
        pParitcleB:setScale(1.2)
        pParitcleB:setPosition(7,0)
        -- self:addChild(pParitcleB,1007)
        _nParent:addChild(pParitcleB,1007)

        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[9] then
        local pParitcleB = createParitcle("tx/world/lizi_mjrq_15.plist")
        pParitcleB:setScale(1.15)
        pParitcleB:setPosition(1,1)
        -- self:addChild(pParitcleB,1008)
        _nParent:addChild(pParitcleB,1008)

        
        table.insert(tParitcles, pParitcleB)
    end
    return tParitcles
end

--城池燃烧特效
function showNormalWorldEffect( _nParent)
    -- body
    if not _nParent then
        return
    end
    local tParitcles ={}
    if not tParitcles[1] then
        local pParitcleB = createParitcle("tx/world/lizi_ccrs_a_002.plist")
        pParitcleB:setScale(1.25)
        pParitcleB:setPosition(-5,7)
        _nParent:addChild(pParitcleB,1000)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[2] then
        local pParitcleB = createParitcle("tx/world/lizi_ccrs_a_003.plist")
        pParitcleB:setScale(1)
        pParitcleB:setPosition(-3,6)
        -- self:addChild(pParitcleB,1001)
        _nParent:addChild(pParitcleB,1001)
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[3] then
        local pParitcleB = createParitcle("tx/world/lizi_ccrs_a_001.plist")
        pParitcleB:setScale(0.6)
        pParitcleB:setPosition(-3,4)
        -- self:addChild(pParitcleB,1002)
        _nParent:addChild(pParitcleB,1002)
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[4] then
        local pParitcleB = createParitcle("tx/world/lizi_ccrs_a_002.plist")
        pParitcleB:setScale(0.9)
        pParitcleB:setPosition(-68,2)

        _nParent:addChild(pParitcleB,1003)
        
        table.insert(tParitcles, pParitcleB)
    end
    if not tParitcles[5] then
        local pParitcleB = createParitcle("tx/world/lizi_ccrs_a_002.plist")
        pParitcleB:setScale(1)
        pParitcleB:setPosition(21,-17)

        _nParent:addChild(pParitcleB,1004)
        
        table.insert(tParitcles, pParitcleB)
    end
    
    return tParitcles
end