-- author: maheng
-- updatetime:  2017-07-20 22:10:23 星期四
-- Description: 任务宝箱

local MCommonView = require("app.common.MCommonView")
require("app.layer.task.EffectTBoxDatas")
local TaskBox = class("TaskBox", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TaskBox:ctor( _nId )
	-- body
	self:myInit(_nId)
	
	self:setLayoutSize(108, 108)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("TaskBox",handler(self, self.onTaskBoxDestroy))
end

--初始化成员变量
function TaskBox:myInit( _nId)
	-- body
	self.nStatus = e_box_status.normal	
	self.nScoreID = tonumber(_nId) or 1
	self.pParitcle = nil --粒子特效
	self.tBoxEffects = nil

	self.pSpecialEffects = {}

	self.bIsRuningAction = false
end

--解析布局回调事件
function TaskBox:onParseViewCallback( pView )
	-- body
end

--初始化控件
function TaskBox:setupViews( )
	-- body
	self:setAnchorPoint(0.5, 1)
	self.ImgBaoxiang = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
	self.ImgBaoxiang:setScale(0.8)
	self.ImgBaoxiang:setPosition(self:getWidth()/2, self:getHeight()/2)
	self:addView(self.ImgBaoxiang,10)

	self.pEffectView = MUI.MLayer.new()
	self.pEffectView:setLayoutSize(self:getWidth(), self:getHeight())
	self:addView(self.pEffectView,10)
	self.pEffectView:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function TaskBox:updateViews( )
	-- body

end

-- 析构方法
function TaskBox:onTaskBoxDestroy(  )
	-- body
end

--
function TaskBox:setStatus( _nstatus )
	-- body
	-- self.nStatus = e_box_status.prize

	self.nStatus = _nstatus or e_box_status.normal
	if self.nStatus == e_box_status.normal then		
		self.ImgBaoxiang:setCurrentImage("#v1_img_guojia_renwubaoxiang1.png")
		self.ImgBaoxiang:setVisible(true)
		self:removeEffect()
		showGrayTx(self, false)
	elseif self.nStatus == e_box_status.prize then		
		self.ImgBaoxiang:setCurrentImage("#v1_img_guojia_renwubaoxiang2.png")
		self.ImgBaoxiang:setVisible(false)
		if not self.bIsRuningAction then
			self:addEffects()
		end
		
	elseif self.nStatus == e_box_status.opened then		
		self.ImgBaoxiang:setCurrentImage("#v1_img_guojia_renwubaoxiang3.png")	
		self.ImgBaoxiang:setVisible(true)
		self:removeEffect()
		showGrayTx(self, false)
	end		
end

function TaskBox:addEffects(  )
	-- self:stopAllActions()
	-- body
	self.bIsRuningAction = true
	if not self.tBoxEffects then
		self.pEffectView:setVisible(true)
		if self.nScoreID % 2 == 0 then   --呼吸动画锚点在下面
			self.pEffectView:setAnchorPoint(0.5,1)
			self.pEffectView:setPosition(self:getWidth()/2,self:getHeight())
			
		else
			self.pEffectView:setPositionX(self:getWidth()/2)
			self.pEffectView:setAnchorPoint(0.5,0)
		end

		showBreathTx(self.pEffectView,0.75)
		self.tBoxEffects = self:getBoxEffects(self.pEffectView, self:getWidth()/2, self:getHeight()/2, 10)
	end
	if not self.pParitcle then
		local pParitcleB = createParitcle("tx/other/lizi_mlz_sf_001.plist")
		pParitcleB:setPosition(self.ImgBaoxiang:getPositionX(), self.ImgBaoxiang:getPositionY())
		self:addView(pParitcleB,30)
		self.pParitcle = pParitcleB
	end

 	addTextureToCache("tx/other/rwww_ksdh_qsaq")

	if not self.pSpecialEffects[1] then
	 	self.pSpecialEffects[1] = MUI.MImage.new("#rwww_ksdh_qsaq_003.png")
	 	self:addChild(self.pSpecialEffects[1],1)
	 	self.pSpecialEffects[1]:setScale(1.6)
	 	self.pSpecialEffects[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	centerInView(self,self.pSpecialEffects[1])
	 	-- self.pSpecialEffects[1]:setPositionY(self.pSpecialEffects[1]:getPositionY() + 18)

	 end

	 if not self.pSpecialEffects[2] then
	 	self.pSpecialEffects[2] = MUI.MImage.new("#rwww_jfxz_jxhs_01.png")
	 	self:addChild(self.pSpecialEffects[2],2)
	 	self.pSpecialEffects[2]:setScale(0.7)
	 	self.pSpecialEffects[2]:setOpacity(0)
	 	self.pSpecialEffects[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	centerInView(self,self.pSpecialEffects[2])

	end
	local action1_1 = cc.ScaleTo:create(0,0.7)
	local action1_2 = cc.FadeTo:create(0,0)
	local action1 = cc.Spawn:create(action1_1,action1_2)

	local action2_1 = cc.ScaleTo:create(0.75,1.15)
	local action2_2 = cc.FadeTo:create(0.75,255)
	local action2 = cc.Spawn:create(action2_1,action2_2)

	local action3_1 = cc.ScaleTo:create(0.75,1.55)
	local action3_2 = cc.FadeTo:create(0.75,0)
	local action3 = cc.Spawn:create(action3_1,action3_2)
	self.pSpecialEffects[2]:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2,action3)))

	if not self.pSpecialEffects[3] then
	 	self.pSpecialEffects[3] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[3]:setScale(0.37)
		-- self.pLvEffect2:setOpacity(0)
		self:addChild(self.pSpecialEffects[3],3)
		centerInView(self,self.pSpecialEffects[3])
	end
	if not self.pSpecialEffects[4] then
	 	self.pSpecialEffects[4] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[4]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self:addChild(self.pSpecialEffects[4],3)
		centerInView(self,self.pSpecialEffects[4])

	end
	if not self.pSpecialEffects[5] then
	 	self.pSpecialEffects[5] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self:addChild(self.pSpecialEffects[5],3)
		centerInView(self,self.pSpecialEffects[5])
	end


	local delay1 = cc.DelayTime:create(0.375)
	local delay2 = cc.DelayTime:create(0.375)
	local delay3 = cc.DelayTime:create(0.375)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pSpecialEffects[3]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.37)
		local scale2 = cc.ScaleTo:create(0.45,0.82)
		local scale3 = cc.ScaleTo:create(0.55,1.34)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.45,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[3]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.37)
		local scale2 = cc.ScaleTo:create(0.45,0.82)
		local scale3 = cc.ScaleTo:create(0.55,1.34)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.45,255)
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
		local scale1 = cc.ScaleTo:create(0,0.37)
		local scale2 = cc.ScaleTo:create(0.45,0.82)
		local scale3 = cc.ScaleTo:create(0.55,1.34)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.45,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[5]:setRotation(random)
		self.pSpecialEffects[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)

	self:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))
		-- local spawn3 = cc.Spawn:create(scale3,fadeTo3)
end

function TaskBox:removeEffect(  )
	self.bIsRuningAction = false
	-- body
	if self.tBoxEffects then
		for i=1,#self.tBoxEffects do
			self.tBoxEffects[i]:stop()
			MArmatureUtils:removeMArmature(self.tBoxEffects[i])
		end
		self.tBoxEffects = nil		
	end
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end

	if #self.pSpecialEffects >0 then
		for k,v in pairs(self.pSpecialEffects) do
			v:stopAllActions()
			v:removeSelf()
		end
		self.pSpecialEffects = {}		
	end
	self:stopAllActions()

	self.pEffectView:setVisible(false)

end
function TaskBox:getBoxEffects(pview, fx, fy, nZorder)
	
	-- body
	local pArmActions = {}
	for i=3,5 do
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTBoxDatas["tbox"..i], 
			pview, 
			nZorder, 
			cc.p(fx, fy),
		    function (  )
			end, Scene_arm_type.normal)
		pArmAction:play(-1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end
return TaskBox
