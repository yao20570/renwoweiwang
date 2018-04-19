if TaskFunc then return end
TaskFunc = {}

require("app.layer.task.EffectTaskDatas")

--获取奖励layer特效
function TaskFunc.getTaskLayerEffects(pView1, pView2, fX, fY, nZorder ,handler)
	-- body
	if not pView1 or not pView2 then
		return
	end

    local pArm =  createMArmature(pView1, EffectTaskDatas["taskLayer"] ,handler,cc.p(fX, fY), nZorder)
	if pArm then
		pArm:setFrameEventCallFunc(function ( _nCur )
			-- body
			if _nCur == 4 then
				TaskFunc.showTaskLayerDisappear(pView2)
			elseif _nCur == 8 then			
				-- TaskFunc.showTaskLayerAppear(pView2)
			end
		end)
        pArm:play(1)
        return pArm
	end
	return nil		
end
--获取领取奖励的光环特效
function TaskFunc.getTaskRingEffects(pView, fX, fY, nZorder,handler, nTaskType )
	-- body
	local pArmActions = {}

	local tEffectData = EffectTaskDatas["ringAf3"]
	for k, v in pairs (tEffectData.tActions) do
		v.sImgName = TaskFunc.getTaskEffectIcon(nTaskType)
	end
	--创建特效
	for i=1,3 do
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTaskDatas["ringAf"..i], 
			pView, 
			nZorder, 
			cc.p(fX, fY),
		    handler, Scene_arm_type.normal)
		pArmAction:play(1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end

function TaskFunc:resetTaskImgEffectData( pArm,  nTaskType)
	-- body
	local tEffectData = EffectTaskDatas["ringAf3"]
	for k, v in pairs (tEffectData.tActions) do
		v.sImgName = TaskFunc.getTaskEffectIcon(nTaskType)
	end
	pArm:setData(tEffectData)
end

--替换图片
function TaskFunc.getTaskEffectIcon( _nType )
	-- body
	_nType = _nType or 1
	local nType = tonumber(_nType)
	local sIcon = "v1_btn_zxrw"
	if nType == 1 then --主线
		sIcon = "v1_btn_zxrw"
	elseif nType == 2 then --装备
		sIcon = "v1_btn_zbrw"
	elseif nType == 3 then --科技
		sIcon = "v1_btn_kjrw"
	elseif nType == 4 then --建筑
		sIcon = "v1_img_zjm_ptdl"
	elseif nType == 5 then --军事
		sIcon = "v1_btn_jsrw"
	elseif nType == 6 then --乱军
		sIcon = "v1_btn_ljrw"
	elseif nType == 7 then --副本
		sIcon = "v1_img_zjm_fuben"
	elseif nType == 8 then --神兵
		sIcon = "v1_img_zjm_shenbing"
	end
	return sIcon
end

--获取领取国家任务奖励的光环特效
function TaskFunc.getCountryTaskRingEffects(pView, fX, fY, nZorder,handler, sImgName )
	-- body
	local pArmActions = {}
	--替换图片	
	local tEffectData = EffectTaskDatas["ringAf3"]
	for k, v in pairs (tEffectData.tActions) do
		v.sImgName = sImgName
	end
	--创建特效
	for i=1,3 do
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTaskDatas["ringAf"..i], 
			pView, 
			nZorder, 
			cc.p(fX, fY),
		    handler, Scene_arm_type.normal)
		pArmAction:play(1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end

--可领奖的特效
function TaskFunc.getNorRingEffects(pView, fX, fY, nZorder )
	-- body
	if not pView then
		return
	end
    local pArm =  createMArmature(pView, EffectTaskDatas["ringNormalAf"] ,function (pArm)
    end,cc.p(fX, fY), nZorder)
	if pArm then	
        pArm:play(-1)
        return pArm
	end
	return nil	
end

--底框呼吸
function TaskFunc.getBgFrameEffects(pView, fX, fY, nZorder )
	-- body
	local pArmActions = {}
	for i=1,2 do
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTaskDatas["bgbreath"..i], 
			pView, 
			nZorder, 
			cc.p(fX, fY),
		    function (  )
			end, Scene_arm_type.normal)
		pArmAction:play(-1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end

function TaskFunc:getLiziEffect( pView )
	-- body
	local pParitcleA = createParitcle("tx/other/lizi_zjm_rwlz_sa_04.plist")	
	pView:addView(pParitcleA,30)
	pParitcleA:setPosition(pView:getWidth()/2, pView:getHeight()/2 - 27)
	local pParitcleB = createParitcle("tx/other/lizi_zjm_rwlz_sa_04.plist")	
	pView:addView(pParitcleB,30)
	pParitcleB:setPosition(pView:getWidth()/2, pView:getHeight()/2 + 27)
	return pParitcleA, pParitcleB
end

--任务图标动画
function TaskFunc.showTaskImgBreathTx( pImg )
	-- body	
	if not pImg then
		return
	end
	-- 图标呼吸光效。(循环播放加亮)

	-- “v1_btn_zbrw”

	-- 时间           透明度
	-- 0秒              0
	-- 0.5秒            30%
	-- 1秒              0%
	pImg:stopAllActions()
	pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)	
	local action1_1 = cc.FadeTo:create(0.5, 255*0.3)
	local action1_2 = cc.FadeTo:create(1, 0)
	local actions1 = cc.RepeatForever:create(cc.Sequence:create(action1_1, action1_2))
	pImg:runAction(actions1)
end
--任务框动画
function TaskFunc.showTaskKuangTx( pView )
	-- body
	if not pView then
		return
	end
	local pActionLayer = pView:findViewByName("TaskFrameAcrion")
	if pActionLayer then
		return
	end 
	local pActionLayer = MUI.MLayer.new(true)
	pActionLayer:setName("TaskFrameAcrion")
	pActionLayer:setLayoutSize(pView:getWidth(), pView:getHeight())
	pView:addView(pActionLayer, 5)
	centerInView(pView, pActionLayer)

	function runActions( pView)
		-- body
		if not pView then
			return
		end
		local Img1 = MUI.MImage.new("#v1_img_zjm_rwdk_s_1.png", {scale9=false})
		Img1:setOpacity(0)
    	Img1:setScale(1)
    	Img1:setRotation(math.random(0,360))
    	Img1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)	
		pView:addView(Img1, 100)
		centerInView(pView, Img1)			

		local action1_1 = cc.ScaleTo:create(0.46, 1.12)
		local action1_2 = cc.FadeTo:create(0.46, 255*0.83)
		local actions1 = cc.Spawn:create(action1_1,action1_2)

		local action2_1 = cc.ScaleTo:create(1.1, 1.3)
		local action2_2 = cc.FadeTo:create(1.1, 0)
		local actions2 = cc.Spawn:create(action2_1,action2_2)		
		Img1:runAction(cc.Sequence:create(actions1,actions2))
		pView:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function (  )
			-- body
			Img1:removeSelf()		
		end)))				
	end	

	pActionLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.CallFunc:create(function (  )
			-- body
			runActions(pActionLayer)
		end),
		cc.DelayTime:create(0.5)				
	)))
	return pActionLayer
end

--任务栏消失
function TaskFunc.showTaskLayerDisappear(pView )
	-- body
	if not pView then
		return
	end

	-- 当序列帧播放至 ： “sg_zjm_rw_s0_04”的图片时，需要将 横栏“v1_img_zjm_rwxqsrk”图片+任务描述字体，一起做一个缩放动画：
	-- 动画描述

	-- 时间               缩放值               透明度
	-- 0秒            （100%，100%）            100%
	-- 0.21秒         （131%，3.4%）              0%	
	local action1_1 = cc.ScaleTo:create(0, 1, 1)
	local action1_2 = cc.FadeTo:create(0, 255)
	local actions1 = cc.Spawn:create(action1_1,action1_2)
	local action2_1 = cc.ScaleTo:create(0.21, 1.31, 0.034)
	local action2_2 = cc.FadeTo:create(0.21, 0)
	local actions2 = cc.Spawn:create(action2_1,action2_2)
	local actionEnd = cc.CallFunc:create(function (  )
			-- body
			TaskFunc.showTaskLayerAppear(pView)
		end)
	pView:runAction(cc.Sequence:create(actions1,actions2,actionEnd))
end

--任务栏出现
function TaskFunc.showTaskLayerAppear(pView )
	-- body
	if not pView then
		return
	end

	-- 当序列帧播放至 ： “sg_zjm_rw_s0_04”的图片时，需要将 横栏“v1_img_zjm_rwxqsrk”图片+任务描述字体，一起做一个缩放动画：
	-- 动画描述

	-- 时间               缩放值               透明度
	-- 0秒            （121%，43.5%）            20%
	-- 0.13秒         （106%，114.7%）           100%
	-- 0.33秒         （100%，100%）             100%	
	local action1_1 = cc.ScaleTo:create(0, 1.2, 0.435)
	local action1_2 = cc.FadeTo:create(0, 255*0.2)
	local actions1 = cc.Spawn:create(action1_1,action1_2)
	local action2_1 = cc.ScaleTo:create(0.13, 1.06, 1.147)
	local action2_2 = cc.FadeTo:create(0.13, 255)
	local actions2 = cc.Spawn:create(action2_1,action2_2)
	local action3_1 = cc.ScaleTo:create(0.33, 1, 1)
	local action3_2 = cc.FadeTo:create(0.33, 255)
	local actions3 = cc.Spawn:create(action3_1,action3_2)	
	pView:runAction(cc.Sequence:create(actions1,actions2, actions3))
end

function TaskFunc.showRightLayerTx( pView )
	-- body
	local Img = MUI.MImage.new("#sg_txkk_akl_gx_001.png", {scale9=false})	
	local nX = pView:getWidth()/2
	local nY = pView:getHeight()/2

	Img:setOpacity(255*0.11)
	Img:setScale(1)
	Img:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	Img:setPosition(nX-138, nY)	
	pView:addView(Img, 10)
	
	local actions1 = cc.CallFunc:create(function ( ... )
		-- body
		Img:setOpacity(255*0.11)
		Img:setScale(1)
		Img:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		Img:setPosition(nX-138, nY)	
	end)

	local action2_1 = cc.ScaleTo:create(0.125, 1, 1)
	local action2_2 = cc.FadeTo:create(0.125, 255*0.56)
	local action2_3 = cc.MoveTo:create(0.125, cc.p(nX-123,nY))
	local actions2 = cc.Spawn:create(action2_1,action2_2,action2_3)

	local action3_1 = cc.ScaleTo:create(0.25, 1.054, 1)
	local action3_2 = cc.FadeTo:create(0.25, 255)
	local action3_3 = cc.MoveTo:create(0.25, cc.p(nX-108,nY))
	local actions3 = cc.Spawn:create(action3_1,action3_2,action3_3)

	local action4_1 = cc.ScaleTo:create(0.58, 1.2, 1)
	local action4_2 = cc.FadeTo:create(0.58, 255)
	local action4_3 = cc.MoveTo:create(0.58, cc.p(nX-68,nY))
	local actions4 = cc.Spawn:create(action4_1,action4_2,action4_3)

	local action5_1 = cc.ScaleTo:create(0.95, 0.955, 1)
	local action5_2 = cc.FadeTo:create(0.95, 255)
	local action5_3 = cc.MoveTo:create(0.95, cc.p(nX-23,nY))
	local actions5 = cc.Spawn:create(action5_1,action5_2,action5_3)

	local action6_1 = cc.ScaleTo:create(1.58, 0.55, 1)
	local action6_2 = cc.FadeTo:create(1.58, 0)
	local action6_3 = cc.MoveTo:create(1.58, cc.p(nX+52, nY))
	local actions6 = cc.Spawn:create(action6_1,action6_2,action6_3)	
	local action = cc.Sequence:create(actions1,actions2,actions3,actions4,actions5,actions6, cc.DelayTime:create(0.42))
	Img:runAction(cc.RepeatForever:create(action))
	return Img
end

function TaskFunc:showCanGetPrizeTX( _pLayRoot, _pContainer, _img1, _img2, pImgType, pImgTypeTX)
	-- body
	if not _pLayRoot or not _pContainer or not _img1 
		or not _img2 or not pImgType 
		or not pImgTypeTX then
		return
	end
	--例子效果
	local pParitcle = _pContainer:findViewByTag(10231403)		
	if not pParitcle then
		--一层 0
		local pLayer = MUI.MLayer.new()
		_pContainer:addView(pLayer)
		pLayer:setTag(10231403)
		pParitcle = createParitcle("tx/other/lizi_remw_002.plist")	
		local nX = _img1:getPositionX() + _img1:getWidth()/2 - 25
		local nY = _img1:getPositionY() - 4
		pParitcle:setPosition(nX, nY)
		pLayer:addView(pParitcle)
		--二层 1
		_img1:setScale(1, 0.98)
		local action_1 = cc.ScaleTo:create(0.5, 1, 1)
		local action_2 = cc.ScaleTo:create(1, 1, 0.98)
		local action = cc.Sequence:create(action_1,action_2)
		_img1:runAction(cc.RepeatForever:create(action))	
		--三层 2
		_img2:setVisible(true)			
		_img2:setOpacity(255*0.8)
		_img2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)	
		_img2:setScale(1, 0.98)
		local action1_1 = cc.ScaleTo:create(0.5, 1, 1)
		local action1_2 = cc.FadeTo:create(0.5, 255*0.35)
		local action_1 = cc.Spawn:create(action1_1, action1_2)

		local action2_1 = cc.ScaleTo:create(0.5, 1, 0.98)
		local action2_2 = cc.FadeTo:create(0.5, 255*0.8)
		local action_2 = cc.Spawn:create(action2_1, action2_2)
		local action = cc.Sequence:create(action_1,action_2)
		_img2:runAction(cc.RepeatForever:create(action))
		--四层 5
		local pLayer = MUI.MLayer.new()
		pLayer:setTag(10231429)
		_pContainer:addView(pLayer, 5)
		for i=1,2 do
			local pArmAction = MArmatureUtils:createMArmature(
				EffectTaskDatas["onprize_"..i], 
				pLayer, 
				5, 
				cc.p(_img1:getPositionX() + _img1:getWidth()/2, _img1:getPositionY()),
			    function (  )
				end, Scene_arm_type.normal)
			pArmAction:play(-1)
			--table.insert(pArmActions, pArmAction)
		end
		--五层 6		
		local pImgLight = MUI.MImage.new("#sg_zjm_rwtih_sdx_001.png", {scale9=false})	
		pImgLight:setName("ImgLight")
		pImgLight:setOpacity(255)
		local pCenter = cc.p(_img1:getPositionX() + _img1:getWidth()/2, _img1:getPositionY())
		_pContainer:addView(pImgLight, 6)
		local actions1 = cc.CallFunc:create(function ( ... )
			-- body
			pImgLight:setOpacity(0)
			pImgLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pImgLight:setPosition(pCenter.x-189, pCenter.y)	
		end)
		local action1_1 = cc.FadeTo:create(0.79, 255)
		local action1_2 = cc.MoveTo:create(0.79, cc.p(pCenter.x-76, pCenter.y))
		local action1 = cc.Spawn:create(action1_1, action1_2)
		local action2_1 = cc.FadeTo:create(0.67, 255)
		local action2_2 = cc.MoveTo:create(0.67, cc.p(pCenter.x+23, pCenter.y))	
		local action2 = cc.Spawn:create(action2_1, action2_2)	
		local action3_1 = cc.FadeTo:create(0.84, 0)
		local action3_2 = cc.MoveTo:create(0.84, cc.p(pCenter.x+155, pCenter.y))
		local action3 = cc.Spawn:create(action3_1, action3_2)
		pImgLight:runAction(cc.RepeatForever:create(cc.Sequence:create(actions1, action1, action2, action3)))	

		--左边
		--一层 10
		pImgType:setScale(1, 1)
		pImgType:setRotation(0)
		pImgType:setOpacity(255)		
		pImgType:setScale(0.98, 0.98)
		local action_1 = cc.ScaleTo:create(0.5, 1.03, 1.03)
		local action_2 = cc.ScaleTo:create(0.5, 0.98, 0.98)
		local action = cc.Sequence:create(action_1,action_2)
		pImgType:runAction(cc.RepeatForever:create(action))	
		--二层 11	
		pImgTypeTX:setVisible(true)
		pImgTypeTX:setRotation(0)		
		pImgTypeTX:setOpacity(255*0.25)
		pImgTypeTX:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)	
		pImgTypeTX:setScale(0.98, 0.98)
		local action1_1 = cc.ScaleTo:create(0.5, 1.03, 1.03)
		local action1_2 = cc.FadeTo:create(0.5, 0)
		local action_1 = cc.Spawn:create(action1_1, action1_2)

		local action2_1 = cc.ScaleTo:create(0.5, 0.98, 0.98)
		local action2_2 = cc.FadeTo:create(0.5, 255*0.25)
		local action_2 = cc.Spawn:create(action2_1, action2_2)
		local action = cc.Sequence:create(action_1,action_2)
		pImgTypeTX:runAction(cc.RepeatForever:create(action))	

		--三层 12
		local pLayer = MUI.MLayer.new()
		_pLayRoot:addView(pLayer, 12)
		pLayer:setTag(10231612)
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTaskDatas["onprize_3"], 
			pLayer, 
			12, 
			cc.p(pImgType:getPositionX(), pImgType:getPositionY()),
		    function (  )
			end, Scene_arm_type.normal)
		pArmAction:play(-1)
		--四层 13
		local pImgRing = MUI.MImage.new("#sg_zjm_rwtih_fk_sdx_xx1.png", {scale9=false})
		pImgRing:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImgRing:setName("ImgRing")
		pImgRing:setPosition(pImgType:getPositionX(), pImgType:getPositionY())
		pImgRing:setRotation(0)
		_pLayRoot:addView(pImgRing, 13)	
		local action1 = cc.RotateTo:create(0.8, 180)
		local action2 = cc.RotateTo:create(0.8, 360)
		pImgRing:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))			
	end	
end

function TaskFunc:removeCanGetPrizeTX(_pLayRoot, _pContainer, _img1, _img2, pImgType, pImgTypeTX )
	-- body
	if not _pLayRoot or not _pContainer or not _img1 
		or not _img2 or not pImgType 
		or not pImgTypeTX then
		return
	end
	--例子效果
	local pParitcleLayer = _pContainer:findViewByTag(10231403)	
	if pParitcleLayer then
		pParitcleLayer:removeSelf()
	end
	_img1:stopAllActions()
	_img2:stopAllActions()
	_img2:setVisible(false)
	local pLayer1 = _pContainer:findViewByTag(10231429)
	if pLayer1 then
		--print("--11111111111111")
		pLayer1:removeSelf()
	end
	local pImgLight = _pContainer:findViewByName("ImgLight")
	if pImgLight then
		pImgLight:stopAllActions()
		pImgLight:removeSelf()
	end	
	pImgType:stopAllActions()
	pImgType:setScale(1, 1)
	pImgType:setRotation(0)
	pImgType:setRotation(255)
	pImgTypeTX:stopAllActions()
	pImgTypeTX:setVisible(false)	
	local pLayer2 = _pLayRoot:findViewByTag(10231612)
	if pLayer2 then
		--print("--22222222222222")
		pLayer2:removeSelf()
	end
	local pImgLight = _pLayRoot:findViewByName("ImgRing")
	if pImgLight then
		pImgLight:removeSelf()
	end
	--print("--33333333333333333")
end
--点击特效
function TaskFunc:showClickTX( _pLayRoot, _pContainer, _img1, _img2, pImgType, pImgTypeTX )
	-- body
	if not _pLayRoot or not _pContainer or not _img1 
		or not _img2 or not pImgType 
		or not pImgTypeTX then
		return
	end
	--第一层
	_pContainer:setScale(0.4, 1)
	_pContainer:setOpacity(0)

	local action1_1 = cc.ScaleTo:create(0.12, 0.48, 1)
	local action1_2 = cc.FadeTo:create(0.12, 0)
	local action1 = cc.Spawn:create(action1_1, action1_2)

	local action2_1 = cc.ScaleTo:create(0.01, 0.489, 1)
	local action2_2 = cc.FadeTo:create(0.01, 255*0.47)
	local action2 = cc.Spawn:create(action2_1, action2_2)

	local action3_1 = cc.ScaleTo:create(0.2, 1.02, 1)
	local action3_2 = cc.FadeTo:create(0.2, 255)
	local action3 = cc.Spawn:create(action3_1, action3_2)

	local action4_1 = cc.ScaleTo:create(0.09, 1, 1)
	local action4_2 = cc.FadeTo:create(0.09, 255)
	local action4 = cc.Spawn:create(action4_1, action4_2)
	_pContainer:runAction(cc.Sequence:create(action1, action2, action3, action4))

	--第二层
	pImgType:setScale(1.57)
	pImgType:setRotation(-137)
	pImgType:setOpacity(255*0.51)
	local action1_1 = cc.ScaleTo:create(0.21, 1, 1)
	local action1_2 = cc.FadeTo:create(0.21, 255)
	local action1_3 = cc.RotateTo:create(0.21, 0)
	local action1 = cc.Spawn:create(action1_1, action1_2, action1_3)
	pImgType:runAction(action1)

	--第三层
	pImgTypeTX:setVisible(true)
	pImgTypeTX:setScale(1.57)
	pImgTypeTX:setRotation(-137)
	pImgTypeTX:setOpacity(0)
	local action1_1 = cc.ScaleTo:create(0.21, 1, 1)
	local action1_2 = cc.FadeTo:create(0.21, 255)
	local action1_3 = cc.RotateTo:create(0.21, 0)
	local action1 = cc.Spawn:create(action1_1, action1_2, action1_3)

	local action2_1 = cc.ScaleTo:create(0.17, 1, 1)
	local action2_2 = cc.FadeTo:create(0.17, 255*0.5)
	local action2_3 = cc.RotateTo:create(0.17, 0)
	local action2 = cc.Spawn:create(action2_1, action2_2, action2_3)

	local action3_1 = cc.ScaleTo:create(0.52, 1, 1)
	local action3_2 = cc.FadeTo:create(0.52, 0)
	local action3_3 = cc.RotateTo:create(0.52, 0)
	local action3 = cc.Spawn:create(action3_1, action3_2, action3_3)
	pImgTypeTX:runAction(cc.Sequence:create(action1, action2, action3))
	--第四层
	local pImgTihFk = _pLayRoot:findViewByName("ImgTihFk")
	if not pImgTihFk then
		pImgTihFk = MUI.MImage.new("#sg_zjm_rw_tih_fk_sdx_xx1.png", {scale9=false})
		pImgTihFk:setName("ImgTihFk")
		pImgTihFk:setOpacity(0)
		_pLayRoot:addView(pImgTihFk, 14)
	end
	local nStPos = cc.p(_pContainer:getPositionX(), _pContainer:getPositionY() + _pContainer:getHeight()/2)
	local action = cc.CallFunc:create(function ()
		-- body
		pImgTihFk:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImgTihFk:setScale(1, 1)
		pImgTihFk:setOpacity(255)
		pImgTihFk:setPosition(nStPos)	
	end)

	local action1_1 = cc.ScaleTo:create(0.25, 1, 0.4)
	local action1_2 = cc.FadeTo:create(0.25, 255)
	local action1_3 = cc.MoveTo:create(0.25, cc.p(nStPos.x + 238, nStPos.y))
	local action1 = cc.Spawn:create(action1_1, action1_2, action1_3)	

	local action2_1 = cc.ScaleTo:create(0.17, 1, 0.02)
	local action2_2 = cc.FadeTo:create(0.17, 0)
	local action2_3 = cc.MoveTo:create(0.17, cc.p(nStPos.x + 390, nStPos.y))
	local action2 = cc.Spawn:create(action2_1, action2_2, action2_3)	

	pImgTihFk:runAction(cc.Sequence:create(cc.DelayTime:create(0.08), action, action1, action2))	
end