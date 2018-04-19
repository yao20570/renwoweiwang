----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-24 21:03:00
-- Description: 年兽来袭详情礼包
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local NianAttackDetailGift = class("NianAttackDetailGift", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NianAttackDetailGift:ctor(  pNianAttackDetail )
	self.pNianAttackDetail = pNianAttackDetail
	self.pActData = Player:getActById(e_id_activity.nianattack)
	self.pSpecialEffects = {}
	--解析文件
	parseView("item_nian_detail_gift", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NianAttackDetailGift:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NianAttackDetailGift", handler(self, self.onNianAttackDetailGiftDestroy))

	--层点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onSelectClicked))
end

-- 析构方法
function NianAttackDetailGift:onNianAttackDetailGiftDestroy(  )
    self:onPause()
end

function NianAttackDetailGift:regMsgs(  )
end

function NianAttackDetailGift:unregMsgs(  )
end

function NianAttackDetailGift:onResume(  )
	
	self:regMsgs()
	self:updateViews()
end

function NianAttackDetailGift:onPause(  )
	self:unregMsgs()
end

function NianAttackDetailGift:setupViews(  )
	local pSize = self:getContentSize()
	--按钮选择图片
	self.pImgGiftSel = MUI.MImage.new("#v2_img_texiao_ns.png")
	self.pView:addView(self.pImgGiftSel)
	self.pImgGiftSel:setPosition(pSize.width/2, pSize.height/2)
	self.pImgGiftSel:setVisible(false)

	--箱子特效。
	self.pImgBoxEffect = MUI.MImage.new("#rwww_ns2lx_gjgx_001.png")
	self.pView:addView(self.pImgBoxEffect, 1)
	self.pImgBoxEffect:setPosition(pSize.width/2, pSize.height/2)	

	--特效
	self.pLayReward = MUI.MLayer.new()
	self.pLayReward:setLayoutSize(96, 96)
	centerInView(self.pView, self.pLayReward)
	self.pLayReward:setPositionY(-20)
	self.pView:addView(self.pLayReward,2)
	-- self.pImgBx = MUI.MImage.new("ui/daitu.png")
	-- self.pImgBx:setPosition(pSize.width/2, pSize.height/2 - 80)
	-- self.pView:addView(self.pImgBx,3)

	--礼包(第三层：箱子图标浮动)
	self.pImgGift = self:findViewByName("img_gift")
	self.pImgGift:setVisible(true)
	local nX, nY = self.pImgGift:getPosition()
	self.pImgGiftPos = cc.p(nX, nY)

	--第四层：箱子图标浮动呼吸
	self.pImgEffect = MUI.MImage.new("#v1_img_wangquanzhengshou.png")
	self.pImgEffect:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	local pParent = self.pImgGift:getParent()
	local nZoder = self.pImgGift:getLocalZOrder()
	local nScale = self.pImgGift:getScale()
	self.pImgEffect:setScale(nScale)
	pParent:addView(self.pImgEffect, nZoder + 1)
	self.pImgEffect:setPosition(self.pImgGiftPos)
	self.pImgEffect:setVisible(false)
	self.pImgEffectPos = self.pImgGiftPos
	
	--已领取
	self.pImgGot = self:findViewByName("img_got")	
	self.pImgGot:setCurrentImage("#v2_fonts_yilingqu.png")
end

function NianAttackDetailGift:updateViews(  )
	if not self.tHARes then
		return
	end
	local pActData = self.pActData
	if pActData then
		local nState = pActData:getHarmGiftState(self.tHARes:getHarm())
		if nState == e_ngift_state.got then
			self.pImgGot:setVisible(true)
			self.pImgGift:setToGray(true)
			self:removeEffect()
		else
			if nState == e_ngift_state.get then
				self:showGetEffect()
			else
				self:removeEffect()
			end
			self.pImgGot:setVisible(false)
			self.pImgGift:setToGray(false)
		end
	end
end

function NianAttackDetailGift:setData( tHARes )
	self.tHARes = tHARes
	self:updateViews()
end

function NianAttackDetailGift:onSelectClicked( )
	if not self.tHARes then
		return
	end
	self.pNianAttackDetail:selectGiftByHarm(self.tHARes:getHarm())
end

--光晕扩散动画：“rwww_gcld_txtx_02”
-- function NianAttackDetailGift:addSpecialEffect()
-- 	local delay1 = cc.DelayTime:create(0.33)
-- 	local delay2 = cc.DelayTime:create(0.33)
-- 	local delay3 = cc.DelayTime:create(0.33)

-- 	local function getEffectAct( nIndex )
-- 		if not self.pSpecialEffects[nIndex] then
-- 			self.pSpecialEffects[nIndex] = MUI.MImage.new("#rwww_gcld_txtx_01.png")
-- 			self.pSpecialEffects[nIndex]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
-- 			centerInView(self.pView, self.pSpecialEffects[nIndex])
-- 			self.pSpecialEffects[nIndex]:setOpacity(0)
-- 			self.pView:addView(self.pSpecialEffects[nIndex], 2)
-- 		end
-- 		return cc.CallFunc:create(function (  )
-- 			local random = math.random(0,360)
-- 			local scale1 = cc.ScaleTo:create(0,0.51* 1.35)
-- 			local scale2 = cc.ScaleTo:create(0.46,0.8* 1.35)
-- 			local scale3 = cc.ScaleTo:create(0.54,1.13* 1.35)

-- 			local fadeTo1 = cc.FadeTo:create(0,0)
-- 			local fadeTo2 = cc.FadeTo:create(0.46,255)
-- 			local fadeTo3 = cc.FadeTo:create(0.54,0)

-- 			local spawn1 = cc.Spawn:create(scale1,fadeTo1)
-- 			local spawn2 = cc.Spawn:create(scale2,fadeTo2)
-- 			local spawn3 = cc.Spawn:create(scale3,fadeTo3)
-- 			self.pSpecialEffects[nIndex]:setRotation(random)
-- 			self.pSpecialEffects[nIndex]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))
-- 		end)
-- 	end
-- 	local callback1 = getEffectAct(1)
-- 	local callback2 = getEffectAct(2)
-- 	local callback3 = getEffectAct(3)
-- 	self:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))
--  end 
 function NianAttackDetailGift:addSpecialEffect()
	if not self.pSpecialEffects[1] then
	 	self.pSpecialEffects[1] = MUI.MImage.new("#rwww_ksdh_qsaq_003.png")
	 	self.pLayReward:addChild(self.pSpecialEffects[1],6)
	 	self.pSpecialEffects[1]:setScale(1.7)
	 	self.pSpecialEffects[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	centerInView(self.pLayReward,self.pSpecialEffects[1])
	 	self.pSpecialEffects[1]:setPositionY(self.pSpecialEffects[1]:getPositionY() + 18)

	 end
	 if not self.pSpecialEffects[2] then
	 	self.pSpecialEffects[2] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[2],3)
		centerInView(self.pLayReward,self.pSpecialEffects[2])
		self.pSpecialEffects[2]:setPositionY(self.pSpecialEffects[2]:getPositionY() + 18)
	end
	-- if not self.pSpecialEffects[3] then
	--  	self.pSpecialEffects[3] = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
	-- 	self.pSpecialEffects[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	-- 	-- self.pSpecialEffects[3]:setScale(0.8)
	-- 	self.pSpecialEffects[3]:setOpacity(0)
	-- 	self.pImgBx:addChild(self.pSpecialEffects[3],110)
	-- 	centerInView(self.pImgBx,self.pSpecialEffects[3])
	-- end
	-- showFloatTx(self.pImgBx,0.5)
	-- showFloatTx(self.pSpecialEffects[3],0.5,0.5 * 255,0)

	if not self.pSpecialEffects[4] then
	 	self.pSpecialEffects[4] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[4]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[4],3)
		centerInView(self.pLayReward,self.pSpecialEffects[4])
		self.pSpecialEffects[4]:setPositionY(self.pSpecialEffects[4]:getPositionY() + 18)
	end
	if not self.pSpecialEffects[5] then
	 	self.pSpecialEffects[5] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[5],3)
		centerInView(self.pLayReward,self.pSpecialEffects[5])
		self.pSpecialEffects[5]:setPositionY(self.pSpecialEffects[5]:getPositionY() + 18)
	end

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pSpecialEffects[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55*0.85)
		local scale2 = cc.ScaleTo:create(0.38,0.92*0.85)
		local scale3 = cc.ScaleTo:create(0.55,1.5*0.85)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55*0.85)
		local scale2 = cc.ScaleTo:create(0.38,0.92*0.85)
		local scale3 = cc.ScaleTo:create(0.55,1.5*0.85)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[4]:setRotation(random)
		self.pSpecialEffects[4]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback3 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55*0.85)
		local scale2 = cc.ScaleTo:create(0.38,0.92*0.85)
		local scale3 = cc.ScaleTo:create(0.55,1.5*0.85)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[5]:setRotation(random)
		self.pSpecialEffects[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	self.pLayReward:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))
 end 

function NianAttackDetailGift:boxFlotEffect( ... )
	-- 第四层：箱子图标浮动呼吸三层：箱子图标浮动
	-- 时间    位置（Y） 
	-- 0秒       0
	-- 0.75秒    2
	-- 1.5秒     0
	self.pImgGift:setPosition(self.pImgGiftPos)
	local pSeqAct = cc.Sequence:create({
		cc.MoveTo:create(0.75, cc.p(self.pImgGiftPos.x, self.pImgGiftPos.y + 2)),
		cc.MoveTo:create(1.5 - 0.75, self.pImgGiftPos),
		}
	)
	self.pImgGift:stopAllActions()
	self.pImgGift:runAction(cc.RepeatForever:create(pSeqAct))
end

function NianAttackDetailGift:boxBreathEffect( ... )
	-- 第四层：箱子图标浮动呼吸
	-- 时间    位置（Y）   透明度      是否加亮
	-- 0秒       0           20%         加亮
	-- 0.75秒    2           70%         加亮
	-- 1.5秒     0           20%         加亮
	self.pImgEffect:setVisible(true)
	self.pImgEffect:setPosition(self.pImgEffectPos)
	self.pImgEffect:setOpacity(255 * 0.2)
	local pSeqAct = cc.Sequence:create({
		cc.Spawn:create({
						cc.FadeTo:create(0.75, 255 * 0.7),
		    			cc.MoveTo:create(0.75, cc.p(self.pImgEffectPos.x, self.pImgEffectPos.y + 2)),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(1.5 - 0.75, 255 * 0.2),
		    			cc.MoveTo:create(1.5 - 0.75, self.pImgEffectPos),
		    		}),
		}
	)
	self.pImgEffect:stopAllActions()
	self.pImgEffect:runAction(cc.RepeatForever:create(pSeqAct))
end

function NianAttackDetailGift:showGetEffect( ... )
	if self.bIsGiftEffect then
		return
	end
	self.bIsGiftEffect = true
	self:addSpecialEffect()
	self:boxFlotEffect()
	self:boxBreathEffect()
end

function NianAttackDetailGift:removeEffect(  )
	if not self.bIsGiftEffect then
		return
	end
	self.bIsGiftEffect = false
	self.pImgGift:stopAllActions()
	self.pImgGift:setPosition(self.pImgGiftPos)
	self.pImgEffect:stopAllActions()
	self.pImgEffect:setVisible(false)
	-- self.pImgBx:stopAllActions()
	self.pLayReward:stopAllActions()
	self:stopAllActions()
	for k,v in pairs(self.pSpecialEffects) do
 		v:removeSelf()
 		v= nil
 	end
 	self.pSpecialEffects = {}
end

function NianAttackDetailGift:setSelected( bIsSel )
	self.pImgGiftSel:setVisible(bIsSel)
end


return NianAttackDetailGift


