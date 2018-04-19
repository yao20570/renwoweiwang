----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-19 17:51:52
-- Description: 新手引导层 手指
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local NewGuideFinger = class("NewGuideFinger", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NewGuideFinger:ctor( )
	self.pPrevFingerPos = nil --上一个手指位置
	self.bIsShow = true
	--解析文件
	parseView("lay_newguide", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NewGuideFinger:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NewGuideFinger", handler(self, self.onNewGuideFingerDestroy))
end

-- 析构方法
function NewGuideFinger:onNewGuideFingerDestroy(  )
    self:onPause()
end

function NewGuideFinger:regMsgs(  )
	--监听点击手指
	regMsg(self, ghd_guide_clicked_finger, handler(self, self.onFingerClicked))
	--监听手指暂停
	regMsg(self, ghd_guide_finger_show_or_hide, handler(self, self.onFingerShow))
end

function NewGuideFinger:unregMsgs(  )
	unregMsg(self, ghd_guide_clicked_finger)
	unregMsg(self, ghd_guide_finger_show_or_hide)
end

function NewGuideFinger:onResume(  )
	self:regMsgs()
end

function NewGuideFinger:onPause(  )
	self:unregMsgs()
end

function NewGuideFinger:setupViews(  )
	--设置穿透事件
	self:setIsTouchBeforeClick(true)
	self:onTouchBeforeClicked(handler(self, self.onOutsideClicked))
end

--设置隐藏
function NewGuideFinger:setHide( )
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideFinger:setHide  隐藏手指并清空当前步骤数据 ************************")
	end
	self:setVisible(false)
	if self.pImgFinger then
		self.pImgFinger:stopAllActions()
	end
	self:hideFingerArm()
	self.nStepId = nil
	self.tGuideData = nil
	self.bIsShow = true

	-- if self.pSpeakTip ~= nil then
	-- 	self.pSpeakTip:removeFromParent(true)
	-- 	self.pSpeakTip = nil
	-- end
end

--点击任意地方
function NewGuideFinger:onOutsideClicked(  )
	self:setHide()
end

--监听其他点击
function NewGuideFinger:onFingerClicked( )
	self:setHide()
end

--设置数据
--nGuideType: 1:美女引导教你玩
function NewGuideFinger:setData( nStepId, pFingerUi, nGuideType, pSpeakTip )
	self.nStepId = nStepId
	self.pFingerUi = pFingerUi
	self.tGuideData = nil
	if nGuideType then
		self.tGuideData = getTeachPlayStep(self.nStepId)
	else
		if self.nStepId then
			self.tGuideData = getGuideData(self.nStepId) 
		end
	end
	if B_GUIDE_LOG then
		myprint("self.bIsShow=======================",self.bIsShow)
	end
	--提示语
	-- self.pSpeakTip = pSpeakTip
	self:updateViews( )
end

--更新视图
function NewGuideFinger:updateViews(  )
	--隐藏手指期间不操作
	if not self.bIsShow then
		return
	end

	local tGuideData = self.tGuideData
	if not tGuideData then
		return
	end

	--手指id
	self.nFingerId = self.tGuideData.fingerid

	-- --保证唯一显示
	-- if self.nPrevStepId == self.nStepId then
	-- 	self:setVisible(true)
	-- 	return
	-- end
	-- self.nPrevStepId = self.nStepId

	--延迟出现
	self:setVisible(false)
	local nDelayTime = self.tGuideData.fingerdelayed
	local function func()
		self:showFinger()
	end
	if nDelayTime and nDelayTime > 0 then
		--一段时间显示
		self:stopAllActions()
		doDelayForSomething(self, func, nDelayTime/1000)
	else
		if self.tGuideData.step == 151 or self.tGuideData.step == 207 then
			doDelayForSomething(self, func, 0.2)
			return
		end
		func()
	end
end

--显示手指
function NewGuideFinger:showFinger( )
	if getIsNoFingerSeq() then
		return
	end
	self:setVisible(true)

	--手指头
	if self.pFingerUi then
		if not self.pImgFinger then
			self.pImgFinger = MUI.MImage.new("#v1_img_shouzhi.png")
     		self.pView:addView(self.pImgFinger)
		end

		--图本身
 		-- 1-左上(不翻转, -90) 
		-- 2-右上(翻转, -180)
		-- 3-左下(不翻转,不旋转)
		-- 4-右下(翻转,不旋转)
		local bIsFliped = false
		local fAngle = 0
		local nDirection = 3
		if nDirection == 1 then
			fAngle = 90
		elseif nDirection == 2 then
			bIsFliped = true
			fAngle = 180
		elseif nDirection == 3 then
		elseif nDirection == 4 then
			bIsFliped = true
		end
		self.pImgFinger:setFlippedX(bIsFliped)
		self.pImgFinger:setRotation(fAngle)
		if self.pPrevFingerPos ~= nil then
			self:playFingerMove()
		else
			local pCurrFingerPos = self:getFingerTargetPos()
			if pCurrFingerPos then
				self.pImgFinger:setVisible(true)
				self.pImgFinger:setPosition(pCurrFingerPos)
				self.pPrevFingerPos = pCurrFingerPos
				self:showFingerArm()
			end
		end
	else
		if self.pImgFinger then
			self.pImgFinger:setVisible(false)
		end
		self:hideFingerArm()
	end
end

--播放手指移动
function NewGuideFinger:playFingerMove( )
	--隐藏所有
	if self.pImgFinger then
		self.pImgFinger:stopAllActions()
		self.pImgFinger:setVisible(false)
	end
	self:hideFingerArm()

	--移动时间
	local nMoveT = 0
	if self.tGuideData then
		if self.tGuideData.movingtime and self.tGuideData.movingtime > 0 then
			self.pImgFinger:setVisible(true)
			nMoveT = self.tGuideData.movingtime/1000
		end
	end

	--移动
	local pCurrFingerPos = self:getFingerTargetPos()
	if pCurrFingerPos then
		self.pPrevFingerPos = pCurrFingerPos
		local pSeqAct = cc.Sequence:create({
			cc.MoveTo:create(nMoveT, pCurrFingerPos),
			cc.CallFunc:create(handler(self, self.showFingerArm))
		})
		self.pImgFinger:runAction(pSeqAct)
	end
end

--显示手指特效
function NewGuideFinger:showFingerArm(  )
	-- local globalX = GLOBAL_OFFSETX or 0
	-- local globalY = GLOBAL_OFFSETY or 0
	--隐藏手指
	self.pImgFinger:setVisible(false)

	local bIsAddFingerUi = false
	if tolua.isnull(self.pFingerUi) then
		return
	end
	local pUi = self.pFingerUi
	local pAchorPos = pUi:getAnchorPoint()
	local pSize = pUi:getContentSize()

	--领奖任务
	local nX,nY = 0, 0
	local nOffsetX, nOffsetY = 0, 0
	local nCircleX, nCircleY = nil, nil
	local nCircleOffsetX, nCircleOffsetY = nil, nil
	local pSize = pUi:getContentSize()
	local nScale = 0.8
	if self.nFingerId == e_guide_finer.home_task_layer then
		nX = pSize.width*0.6
		nY = pSize.height
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.first_arena_btn then
		nX = 100
		nY = 60
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.atelier_produce_btn then
		nScale = 0.75
		nX = 100
		nY = 60
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.pkhero_enter or
		   self.nFingerId == e_guide_finer.arena_enter then
		nX = 110
		nY = 90
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.gequip_sword then
		nX = pSize.width/2 + 38
		nY = pSize.height/2 + 48
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.buyhero_build then
		nOffsetX = -40
		nOffsetY = -50
	elseif self.nFingerId == e_guide_finer.warhall_build then
		nOffsetX = -40
		nOffsetY = -50
	elseif self.nFingerId == e_guide_finer.task_reward_btn then
		local pFingerUiPoint = self.pFingerUi:getAnchorPointInPoints()
		local pWorldPoint = self.pFingerUi:convertToWorldSpace(pFingerUiPoint);
		if tolua.isnull(pUi.__fingerUi) then
			return
		end
		local pCurrPoint = pUi.__fingerUi:convertToNodeSpace(pWorldPoint)
		pUi = pUi.__fingerUi
		nX, nY = pCurrPoint.x + pSize.width/2 - 20, pCurrPoint.y + pSize.height/2 - 20
		nCircleX = nX+13
		nCircleY = nY+8
		bIsAddFingerUi = true
		-- nX = pSize.width*0.77
		-- nY = pSize.height*1.3
		-- bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.house1_lvup_btn or
		self.nFingerId == e_guide_finer.house2_lvup_btn or
		self.nFingerId == e_guide_finer.wood1_lvup_btn or
		self.nFingerId == e_guide_finer.wood2_lvup_btn or 
		self.nFingerId == e_guide_finer.wood3_lvup_btn or 
		self.nFingerId == e_guide_finer.wood4_lvup_btn or
		self.nFingerId == e_guide_finer.palace_lvup_btn or
		self.nFingerId == e_guide_finer.house3_lvup_btn or
		self.nFingerId == e_guide_finer.food1_lvup_btn or 
		self.nFingerId == e_guide_finer.store_lvup_btn or
		self.nFingerId == e_guide_finer.tnoly_enter_btn or
		self.nFingerId == e_guide_finer.atelier_enter_btn or
		self.nFingerId == e_guide_finer.tcf_enter_btn or
		self.nFingerId == e_guide_finer.camp_enter_btn or 
		self.nFingerId == e_guide_finer.house5_lvup_btn or 
		self.nFingerId == e_guide_finer.wood5_lvup_btn or
		self.nFingerId == e_guide_finer.tnoly_lvup_btn or
		self.nFingerId == e_guide_finer.sowar_lvup_btn or
		self.nFingerId == e_guide_finer.food5_lvup_btn then
		nX = pSize.width*0.9
		nY = pSize.height*0.9
		nCircleX = nX-12
		nCircleY = nY-12
		nScale = 1.4
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.house1_speed_btn or
		self.nFingerId == e_guide_finer.house2_speed_btn or
		self.nFingerId == e_guide_finer.wood1_speed_btn or 
		self.nFingerId == e_guide_finer.wood2_speed_btn or 
		self.nFingerId == e_guide_finer.wood3_speed_btn or 
		self.nFingerId == e_guide_finer.wood4_speed_btn or
		self.nFingerId == e_guide_finer.palace_speed_btn or 
		self.nFingerId == e_guide_finer.house3_speed_btn or
		self.nFingerId == e_guide_finer.food1_speed_btn or 
		self.nFingerId == e_guide_finer.store_speed_btn or 
		self.nFingerId == e_guide_finer.house5_speed_btn or 
		self.nFingerId == e_guide_finer.wood5_speed_btn or 
		self.nFingerId == e_guide_finer.store_speed_btn or
		self.nFingerId == e_guide_finer.tnoly_speed_btn or
		self.nFingerId == e_guide_finer.food5_speed_btn or
		self.nFingerId == e_guide_finer.sowar_speed_btn or 
		self.nFingerId == e_guide_finer.smithshop_bubble then
		

		nX = pSize.width*1
		nY = pSize.height*0.9
		nCircleX = nX-20
		nCircleY = nY-16
		nScale = 1.4
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.food1_res_bubble or 
		self.nFingerId == e_guide_finer.house5_res_bubble or 
		self.nFingerId == e_guide_finer.wood5_res_bubble or
		self.nFingerId == e_guide_finer.food5_res_bubble then
		nX = pSize.width*1
		nY = pSize.height*0.9
		nCircleX = nX-20
		nCircleY = nY-17
		nScale = 1.4
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.house3_army_btn then
		nX = pSize.width
		nY = pSize.height*1.2
		nScale = 1.2
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.hero_enter_btn or
		self.nFingerId == e_guide_finer.fuben_enter_btn or
		self.nFingerId == e_guide_finer.country_enter_btn or
		self.nFingerId == e_guide_finer.gequip_enter_btn then
		local pFingerUiPoint = self.pFingerUi:getAnchorPointInPoints()
		local pWorldPoint = self.pFingerUi:convertToWorldSpace(pFingerUiPoint);
		if tolua.isnull(pUi.__fingerUi) then
			return
		end
		local pCurrPoint = pUi.__fingerUi:convertToNodeSpace(pWorldPoint)
		pUi = pUi.__fingerUi
		nX, nY = pCurrPoint.x + pSize.width/2 - 20, pCurrPoint.y + pSize.height/2 - 20
		nCircleX = nX+13
		nCircleY = nY+8
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.world_enter_btn or 
		self.nFingerId == e_guide_finer.tnoly_build or
		self.nFingerId == e_guide_finer.treasure_build then
		nX = pSize.width*0.8
		nY = pSize.height*0.8
		if self.nFingerId == e_guide_finer.world_enter_btn then
			nScale = 1
		else
			nScale = 1.5
		end
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.arena_build or
		self.nFingerId == e_guide_finer.gate_build or
		self.nFingerId == e_guide_finer.store_build or
		self.nFingerId == e_guide_finer.infantry_build then
		nX = pSize.width*0.7
		nY = pSize.height*0.7
		nScale = 1.5
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.palace_build then
		nX = pSize.width*0.5
		nY = pSize.height*0.55
		nScale = 1.8
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.house1_build then
		nX = pSize.width*0.7
		nY = pSize.height
		nScale = 1.5
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.smithshop_build then
		nX = pSize.width*0.78
		nY = pSize.height*0.7
		nCircleX = nX-20
		nCircleY = nY-10
		nScale = 1.5
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.hero_first_equip or
		self.nFingerId == e_guide_finer.hero_second_equip or
		self.nFingerId == e_guide_finer.hero_third_equip or
		self.nFingerId == e_guide_finer.hero_forth_equip or
		self.nFingerId == e_guide_finer.hero_fifth_equip or
		self.nFingerId == e_guide_finer.hero_sixth_equip then
		nX = pSize.width*0.83
		nY = pSize.height*0.78
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.wear_gun_btn or 
		self.nFingerId == e_guide_finer.wear_sword_btn or
		self.nFingerId == e_guide_finer.wear_corselet_btn or
		self.nFingerId == e_guide_finer.wear_helmet_btn or
		self.nFingerId == e_guide_finer.wear_yin_btn or
		self.nFingerId == e_guide_finer.wear_fu_btn then
		nX = pSize.width*0.75
		nY = pSize.height*1.1
		nCircleX = nX+3
		nCircleY = nY+5
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.first_hero_head or
		self.nFingerId == e_guide_finer.second_hero_head then
		nX = pSize.width*0.7
		nY = pSize.height*0.7
		nCircleX = nX+13
		nCircleY = nY+14
		nScale = 0.8
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.fuben_first_post_cruit then
		nX = pSize.width*0.7
		nY = pSize.height*0.65
		nCircleX = nX+10
		nCircleY = nY+10
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.recruit_hero_btn1 then
		nX = pSize.width*0.66
		nY = pSize.height*0.8
		nCircleX = nX+10
		nCircleY = nY+17
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.online_btn or self.nFingerId == e_guide_finer.sowar_hero_online_btn then
		nCircleOffsetX = -5
		-- nCircleOffsetY = 11
		bIsAddFingerUi = false
	elseif self.nFingerId == e_guide_finer.recruit_smith_btn then
		nX = pSize.width*0.75
		nY = pSize.height*0.75
		nCircleX = nX+8
		nCircleY = nY+9
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.change_name_btn then
		nX = pSize.width*1.3
		nY = pSize.height*1.25
		nCircleX = nX+8
		nCircleY = nY+9
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.build_equip_btn or self.nFingerId == e_guide_finer.tjp_equip_speed then
		nX = pSize.width*0.72
		nY = pSize.height*1.1
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.change_hero_btn then
		nX = pSize.width*0.73
		nY = pSize.height*1.1
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.battle_selected_btn then
		nX = pSize.width*1.1
		nY = pSize.height
		nCircleX = nX+8
		nCircleY = nY+8
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.hero_wear_all_btn then
		nX = pSize.width*0.72
		nY = pSize.height*1.1
		bIsAddFingerUi = true
	elseif self.nFingerId == e_guide_finer.tnoly_build_bubble then
		nX = pSize.width*1.1
		nY = pSize.height*1.1
		nCircleX = nX-20
		nCircleY = nY-16
		nScale = 1.4
		bIsAddFingerUi = true
	end

	--是加入父面板
	if bIsAddFingerUi then
		--创建控件
		--光圈
		if tolua.isnull(self.pLightArm) then
			local sName = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
		    self.pLightArm = ccs.Armature:create(sName)
		    if pUi.addView then
		    	pUi:addView(self.pLightArm,999)
		    else
		    	pUi:addChild(self.pLightArm,999)
		    end
		    self.pLightArm:getAnimation():play("gqks_01", 1)
		    self.pLightArm:setScale(0.8)
		else
			self.pLightArm:setVisible(true)
		end

		--手指
		if tolua.isnull(self.pClieckArm) then
		    local sName = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
		    self.pClieckArm = ccs.Armature:create(sName)
		    local sSkillName = "#v1_img_shouzhi.png"
		    local sBoneName = "szth_01"
			local pImg = changeBoneWithPngName(self.pClieckArm,sBoneName,sSkillName,false) 
			if pUi.addView then
		    	pUi:addView(self.pClieckArm,999)
		    else
		    	pUi:addChild(self.pClieckArm,999)
		    end
		    self.pClieckArm:getAnimation():play("szdj_02", 1)
		else
			self.pClieckArm:setVisible(true)
		end

		nCircleX = nCircleX or nX
		nCircleY = nCircleY or nY
		self.pClieckArm:setPosition(nX + 10 , nY + 10)
		self.pLightArm:setPosition(nCircleX -25 - 10 , nCircleY -25 - 10)
		self.pLightArm:setScale(nScale)
		self.pClieckArm:setScale(nScale)

		--更新手指位置
		-- local pFingerUiPoint = self.pClieckArm:getAnchorPointInPoints()
		-- local nX, nY = self.pClieckArm:getPosition()
		-- local pWorldPoint = self.pClieckArm:getParent():convertToWorldSpace(cc.p(nX, nY));
		-- print("pWorldPoint========================================",pWorldPoint.x, pWorldPoint.y)
		-- local pCurrPoint = self.pView:convertToNodeSpace(pWorldPoint)
		-- local nX, nY = pCurrPoint.x, pCurrPoint.y
		-- -- local pFingerUiPoint = self.pLightArm:getAnchorPointInPoints()
		-- -- local pWorldPoint = self.pLightArm:convertToWorldSpace(pFingerUiPoint);
		-- if self.pSpeakTip then
		-- 	if pUi.addView then
		--     	pUi:addView(self.pSpeakTip, 9999)
		--     else
		--     	pUi:addChild(self.pSpeakTip, 9999)
		--     end
		--     -- self.pSpeakTip:setGlobalZOrder(999)
		-- 	-- self.pSpeakTip:setPosition(nX + 10 , nY - 100)
		-- 	self.pSpeakTip:setPosition3D(cc.vec3(nX + 10 , nY - 100, 10))
		-- end
	else
		--光圈
		if tolua.isnull(self.pLightArm) then
			local sName = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
		    self.pLightArm = ccs.Armature:create(sName)
		    self.pView:addView(self.pLightArm,999)
		    self.pLightArm:getAnimation():play("gqks_01", 1)
		    self.pLightArm:setScale(0.8)
		else
			self.pLightArm:setVisible(true)
		end

		--手指
		if tolua.isnull(self.pClieckArm) then
		    local sName = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
		    self.pClieckArm = ccs.Armature:create(sName)
		    local sSkillName = "#v1_img_shouzhi.png"
		    local sBoneName = "szth_01"
			local pImg = changeBoneWithPngName(self.pClieckArm,sBoneName,sSkillName,false) 
		    self.pView:addView(self.pClieckArm,999)
		    self.pClieckArm:getAnimation():play("szdj_02", 1)
		else
			self.pClieckArm:setVisible(true)
		end
		nCircleOffsetX = nCircleOffsetX or 0
		nCircleOffsetY = nCircleOffsetY or 0
		local nX, nY = self.pImgFinger:getPosition()
		nX = nX + nOffsetX
		nY = nY + nOffsetY
		self.pClieckArm:setPosition(nX + 10 , nY + 10)
		self.pLightArm:setPosition(nX -25 - 10 + nCircleOffsetX , nY -25 - 10 + nCircleOffsetY)
	end
end

--隐藏手指移动
function NewGuideFinger:hideFingerArm( )
	-- if self.pLightArm then
	-- 	self.pLightArm:setVisible(false)
	-- end
	-- if self.pClieckArm then
	-- 	self.pClieckArm:setVisible(false)
	-- end
	if not tolua.isnull(self.pLightArm) then
		self.pLightArm:removeFromParent(true)
		self.pLightArm = nil
	end
	if not tolua.isnull(self.pClieckArm) then
		self.pClieckArm:removeFromParent(true)
		self.pClieckArm = nil
	end

end

function NewGuideFinger:getClickFingerArm()
	-- body
	return self.pClieckArm
end

--获取手指目标位置
function NewGuideFinger:getFingerTargetPos( )
	--容错
	if not self.tGuideData then
		return
	end
	if self.tGuideData.fingerid == 0 then
		return
	end

	if tolua.isnull(self.pFingerUi) then
		return
	end

	local tGuideData = self.tGuideData
	--更新手指位置
	local pFingerUiPoint = self.pFingerUi:getAnchorPointInPoints()
	local pWorldPoint = self.pFingerUi:convertToWorldSpace(pFingerUiPoint);
	local pCurrPoint = self.pView:convertToNodeSpace(pWorldPoint)
	local pAnchorPoint = self.pFingerUi:getAnchorPoint()
	if pAnchorPoint.x == 0 then
		pCurrPoint.x = pCurrPoint.x + self.pFingerUi:getContentSize().width/2
	end
	if pAnchorPoint.y == 0 then
		pCurrPoint.y = pCurrPoint.y + self.pFingerUi:getContentSize().height/2
	end
	local nX, nY = pCurrPoint.x, pCurrPoint.y
	--图本身
	-- 1-左上(不翻转, -90) 
	-- 2-右上(翻转, -180)
	-- 3-左下(不翻转,不旋转)
	-- 4-右下(翻转,不旋转)
	local nDirection = 3
	if nDirection == 1 then
		nX = nX + 30
		nY = nY - 30
	elseif nDirection == 2 then
		nX = nX + 30
		nY = nY - 30
	elseif nDirection == 3 then
		nX = nX + 30 + 10
		nY = nY + 30 + 10
	elseif nDirection == 4 then
		nX = nX - 30
		nY = nY + 30
	end
	return cc.p(nX, nY)
end

--获取在哪个方向状态
function NewGuideFinger:getInUpHalfState( )
	if self:isVisible() then
		--如果提示界面和手指同时存在
		--若存在点击手势与提示框同时存在的情况，则视点击手势在上半屏或下半屏
		--a.手势在上半屏，则提示框显示在手势下方，左右居中
		--b.手势在下半屏，则提示框显示在手势上方，左右居中
		if self.pImgFinger then
			local fFingerX, fFingerY = self.pImgFinger:getPosition()
			local fHalfHeight = self.pView:getContentSize().height/2
			--a情况
			if fFingerY >= fHalfHeight then
				return 1
			--b情况
			else
				return 2
			end
		end
	end
	return 0
end

--位置刷新
function NewGuideFinger:onFingerPosRefresh(  )
	if self:isVisible() then
		self:playFingerMove()
	end
end

--手指是否显示
function NewGuideFinger:onFingerShow( sMsgName, pMsgObj )
	if self.bIsShow == pMsgObj then
		return
	end
	if pMsgObj then
		self.bIsShow = true
		self:updateViews() --再显示一次
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG onFingerShow  再显示一次,当存在当前步骤数据 ************************")
		end
	else
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG onFingerShow  隐藏手指不清空当前步骤数据 ************************")
		end
		--隐藏所有
		if self.pImgFinger then
			self.pImgFinger:stopAllActions()
			self.pImgFinger:setVisible(false)
		end
		self:hideFingerArm()
		self:setVisible(false)
		--设置为不显示
		self.bIsShow = false
	end
end


return NewGuideFinger


