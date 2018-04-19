-- ItemStarSoul.lua
-----------------------------------------------------
-- author: dshulan
-- Date: 2017-03-06 14:20:23
-- Description: 武将星魂单个龙图item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemStarSoul = class("ItemStarSoul", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tData 数据
function ItemStarSoul:ctor()
	-- body
	self:myInit()

	parseView("item_star_soul", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemStarSoul",handler(self, self.onDestroy))

	self:regMsgs()
	
end

-- 注册消息
function ItemStarSoul:regMsgs( )
	-- body
	-- 注册英雄界面刷新
	regMsg(self, ghd_star_soul_preview_state, handler(self, self.showPreview))

end

-- 注销消息
function ItemStarSoul:unregMsgs(  )
	-- body
	-- 注销英雄界面刷新
	unregMsg(self, ghd_star_soul_preview_state)
end

--初始化参数
function ItemStarSoul:myInit()
	-- body
	self.tData = {} --数据
	self.nPos = nil

	self.pLockEffect={}

	self.nState = 0
	self.pGrayLongTuEffect = nil
	self.nHeroId = nil

	self.pActiveLightEffect = {}
	self.bIsShowPreview = false
end

--解析布局回调事件
function ItemStarSoul:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

function ItemStarSoul:setupViews()
	--属性层
	self.pLayAttr 			= self:findViewByName("lay_attr")
	--属性文本
	self.pLbAttr 			= self:findViewByName("lb_attr")

	--锁住层
	self.pLayLock 			= self:findViewByName("lay_lock")
	self.pImgLock 			= self:findViewByName("img_lock")
	self.pImgLock:setOpacity(255*0.7)
	
	--点亮显示
	self.pImgLiang 			= self:findViewByName("img_liang")
	self.pImgLongTu 		= self:findViewByName("img_longtu")

end

--初始化控件
function ItemStarSoul:updateViews( )
	local n = table.nums(self.tData.tSoulList)
	local tStageData = self.tData.tSoulList[n]

	if self.bIsShowPreview == true then
		self.nStage = tStageData.st - 1 
		self.bIsShowPreview = false
	else
		--当前最新阶段
		self.nStage = tStageData.st
	end
	local nOrgState = self.nState
	
	self.nState = self.tData.tSoulDic[self.nStage][self.nPos]

	local nOrgId = self.nHeroId
	self.nHeroId = self.tData.nId

	local tAttr = self.tData.tSoulActAttrs[self.nStage][self.nPos]
	local nAttrId = tonumber(tAttr[1])
	local nAttrAddValue = tonumber(tAttr[2])
	local tAttrData = getBaseAttData(nAttrId)
	--属性增加值(命中，闪避，暴击，坚韧以百分比形式显示, 其他属性用数字显示)
	if nAttrId == e_id_hero_att.mingzhong or nAttrId == e_id_hero_att.shanbi or
		nAttrId == e_id_hero_att.baoji or nAttrId == e_id_hero_att.jianyi then
		local sValue = nAttrAddValue*100
		self.pLbAttr:setString(tAttrData.sName.."+"..sValue.."%")
	else
		self.pLbAttr:setString(tAttrData.sName.."+"..nAttrAddValue)
	end
	
	
	if self.nState then
		
		-- self.pImgLongTu:setVisible(true)
		
		if self.nState == e_hero_soul_state.actived then --已激活
			-- print("self.nPos,nOrgState,self.nState---",self.nPos,nOrgState,self.nState)
			if nOrgState ~= 0 and nOrgState ~= self.nState and 
				self.nHeroId == nOrgId and 
				nOrgState == e_hero_soul_state.opened then
				-- self.nPos > 1 then
				self:showActiveEffect()
			else
				-- print("self.nPos,nOrgState,self.nState222222222---",self.nPos,nOrgState,self.nState)
				setTextCCColor(self.pLbAttr, _cc.green)
				self.pImgLiang:setVisible(true)
				self.pImgLongTu:setToGray(false)
				self.pImgLongTu:setVisible(true)
				self.pLayLock:setVisible(false)
				self.pLayAttr:setVisible(true)
			end

		elseif self.nState == e_hero_soul_state.opened then --已解锁
			-- print("self.nPos,nOrgState,self.nState222222222---",self.nPos,nOrgState,self.nState)
			if nOrgState ~= 0 and nOrgState ~= self.nState and 
				self.nHeroId == nOrgId then 
				-- nOrgState ~= e_hero_soul_state.actived then
				if self.nPos == 1 then
					self:showUnlockAction()
				else 		--不是第一个的时候 需要等前一个做完激活动画之后再播放解锁动画
					local callback = cc.CallFunc:create(function (  )
						-- body
						self:showUnlockAction()
					end)
					local delayTime = cc.DelayTime:create(1.1)
					self:runAction(cc.Sequence:create(delayTime,callback))
				end
			else

				setTextCCColor(self.pLbAttr, _cc.white)
				self.pImgLiang:setVisible(false)
				self.pImgLongTu:setToGray(true)
				self.pImgLongTu:setVisible(true)
				self.pLayLock:setVisible(false)
				self.pLayAttr:setVisible(true)  
			end
		end
	else --未解锁
		self.pLayAttr:setVisible(false)
		self.pImgLiang:setVisible(false)
		self.pImgLongTu:setVisible(false)
		self.pLayLock:setVisible(true)
		self.pImgLock:setVisible(true)
		-- self:showUnlockAction()
	end
end

function ItemStarSoul:showPreview(  )
	-- body
	
	self.bIsShowPreview = true
	self:updateViews()
end

--析构方法
function ItemStarSoul:onDestroy(  )
	-- body
	self:unregMsgs()
	removeTextureFromCache("tx/other/rwww_xh_stgy_xsxg",1)
end

--设置数据 _data
function ItemStarSoul:setCurData(_tData, _index)
	if not _tData then
		return
	end

	self.tData = _tData or {}
	self.nPos = _index

	self:updateViews()

end
--显示星魂解锁动画
function ItemStarSoul:showUnlockAction(  )
	-- body
	--动画不对
	--属性出现的动画
	self.pLayLock:setVisible(true)
	self.pImgLock:setVisible(false)
	self.pImgLongTu:setVisible(false)
	self.pImgLiang:setVisible(false)
	if not self.pLockEffect[1] then
	 	self.pLockEffect[1] = MUI.MImage.new("#v2_img_lock_tjp.png")

	 	self.pLayLock:addView(self.pLockEffect[1],10)
	 	self.pLockEffect[1]:setPosition(self.pImgLock:getPositionX(),self.pImgLock:getPositionY())
	 end
	 if not self.pLockEffect[2] then
	 	self.pLockEffect[2] = MUI.MImage.new("#v2_img_lock_tjp.png")

	 	self.pLockEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLockEffect[2]:setOpacity(0)
	 	self.pLayLock:addView(self.pLockEffect[2],12)
	 	self.pLockEffect[2]:setPosition(self.pImgLock:getPositionX(),self.pImgLock:getPositionY())
	 end

	local action1 = cc.RotateTo:create(0.05, -5)
	local action2 = cc.RotateTo:create(0.1, 5)
	local action3 = cc.RotateTo:create(0.1, -5)
	local action4 = cc.RotateTo:create(0.1, 5)
	local action5 = cc.RotateTo:create(0.1, -5)
	local action6 = cc.RotateTo:create(0.1, 5)
	local action7 = cc.RotateTo:create(0.1, -17)
	local action8 = cc.RotateTo:create(0.1, 15)
	local action9 = cc.RotateTo:create(0.1, -17)
	local action10 = cc.RotateTo:create(0.1, 15)
	local action11_1 = cc.ScaleTo:create(0.1, 1.2)
	local action11_2 = cc.FadeTo:create(0.1, 255*0.33)
	local action11_3 = cc.RotateTo:create(0.1, 0)
	local action11 = cc.Spawn:create(action11_1,action11_2,action11_3)
	local action12_1 = cc.ScaleTo:create(0.1, 1.61)
	local action12_2 = cc.FadeTo:create(0.1, 0)
	local action12 = cc.Spawn:create(action12_1,action12_2)

	local callback = cc.CallFunc:create(function (  )
		-- body
		self:removeLockEffect()
		self.pImgLongTu:setVisible(true)
		setTextCCColor(self.pLbAttr, _cc.white)
		self.pImgLiang:setVisible(false)
		self.pImgLongTu:setToGray(true)
		self.pLayLock:setVisible(false)
		self.pLayAttr:setVisible(true)

		self.pLayAttr:setOpacity(0)
		local action13 = cc.FadeTo:create(0.5, 255)
		self.pLayAttr:runAction(action13)

	end)

	
	local action2_1 = cc.RotateTo:create(0.05, -5)

	local action2_2_1 = cc.RotateTo:create(0.1, 5)
	local action2_2_2 = cc.FadeTo:create(0.1, 255*0.5)
	local action2_2 = cc.Spawn:create(action2_2_1,action2_2_1)

	local action2_3_1 = cc.RotateTo:create(0.1, -5)
	local action2_3_2 = cc.FadeTo:create(0.1, 0)
	local action2_3 = cc.Spawn:create(action2_3_1,action2_3_2)

	local action2_4_1 = cc.RotateTo:create(0.1, 5)
	local action2_4_2 = cc.FadeTo:create(0.1, 255*0.5)
	local action2_4 = cc.Spawn:create(action2_4_1,action2_4_2)

	local action2_5_1 = cc.RotateTo:create(0.1, -5)
	local action2_5_2 = cc.FadeTo:create(0.1, 0)
	local action2_5 = cc.Spawn:create(action2_5_1,action2_5_2)

	local action2_6_1 = cc.RotateTo:create(0.1, 5)
	local action2_6_2 = cc.ScaleTo:create(0.1, 1.25)
	local action2_6_3 = cc.FadeTo:create(0.1, 255*0.5)
	local action2_6 = cc.Spawn:create(action2_6_1,action2_6_2,action2_6_3)

	local action2_7_1 = cc.RotateTo:create(0.1, -17)
	local action2_7_2 = cc.ScaleTo:create(0.1, 1)
	local action2_7_3 = cc.FadeTo:create(0.1, 0)
	local action2_7 = cc.Spawn:create(action2_7_1,action2_7_2,action2_7_3)

	local action2_8_1 = cc.RotateTo:create(0.1, 15)
	local action2_8_2 = cc.FadeTo:create(0.1, 255*0.5)
	local action2_8 = cc.Spawn:create(action2_8_1,action2_8_2)

	local action2_9_1 = cc.RotateTo:create(0.1, -17)
	local action2_9_2 = cc.FadeTo:create(0.1, 0)
	local action2_9 = cc.Spawn:create(action2_9_1,action2_9_1)

	local action2_10_1 = cc.RotateTo:create(0.1, 15)
	local action2_10_2 = cc.FadeTo:create(0.1, 255*0.5)
	local action2_10 = cc.Spawn:create(action2_10_1,action2_10_2)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		self:showGrayLongTuEffect()
		self:showLockArmature()
		

	end)

	local action2_11_1 = cc.ScaleTo:create(0.1, 1.2)
	local action2_11_2 = cc.FadeTo:create(0.1, 255*0.33)
	local action2_11_3 = cc.RotateTo:create(0.1, 0)
	local action2_11 = cc.Spawn:create(callback2,action2_11_1,action2_11_2,action2_11_3)

	local action2_12_1 = cc.ScaleTo:create(0.1, 1.61)
	local action2_12_2 = cc.FadeTo:create(0.1, 0)
	local action2_12 = cc.Spawn:create(action2_12_1,action2_12_2)

	self.pLockEffect[1]:runAction(cc.Sequence:create(action1,action2,action3,action4,action5,action6,action7,action8,action9,action10,action11,action12,callback))

	self.pLockEffect[2]:runAction(cc.Sequence:create(action2_1,action2_2,action2_3,action2_4,action2_5,action2_6,action2_7,action2_8,action2_9,action2_10,action2_11,action2_12))

end

function ItemStarSoul:showLockArmature(  )
	-- body
	addTextureToCache("tx/other/rwww_xh_stgy_xsxg")
	local tArmData1  = {
		nFrame = 10, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
			nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
			tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "rwww_xh_stgy_xsxg_001",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 10, -- 结束帧下标
				tValues = {-- 参数列表
					{1, 1.2}, -- 开始, 结束缩放值
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm1 = MArmatureUtils:createMArmature(
		tArmData1, 
		self.pLayLock, 
		99, 
		cc.p(self.pLayLock:getWidth()/2, self.pLayLock:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm1 then
		pArm1:play(1)
	end

	local tArmData2 = {
		nFrame = 6, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.2,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
		nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 2, --透明度
				sImgName = "rwww_xh_stgy_xsxg_002",
				nSFrame = 1,
				nEFrame = 6,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				},
			}
		},
	}
	local pArm2 = MArmatureUtils:createMArmature(
		tArmData2, 
		self.pLayLock,  
		99, 
		cc.p(self.pLayLock:getWidth()/2, self.pLayLock:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm2 then
		pArm2:play(1)
	end
end

function ItemStarSoul:removeLockEffect(  )
	-- body
	for k,v in pairs(self.pLockEffect) do
 			v:removeSelf()
 			v= nil
 		end
 		self.pLockEffect = {}
end
--解锁时灰色龙图出现的效果
function ItemStarSoul:showGrayLongTuEffect(  )
	-- body
	-- if not self.pGrayLongTuEffect[1] then
	--  	self.pGrayLongTuEffect[1] = MUI.MImage.new("#v2_img_v2_btn_longtu.png")

	--  	self:addView(self.pGrayLongTuEffect[1],10)
	--  	self.pGrayLongTuEffect[1]:setPosition(self.pImgLongTu:getPositionX(),self.pImgLongTu:getPositionY())
	--  end

	if not self.pGrayLongTuEffect then
	 	self.pGrayLongTuEffect = MUI.MImage.new("#v2_img_v2_btn_longtu.png")

	 	self.pGrayLongTuEffect:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pGrayLongTuEffect:setOpacity(0)
	 	self:addView(self.pGrayLongTuEffect,12)
	 	self.pGrayLongTuEffect:setPosition(self.pImgLongTu:getPositionX(),self.pImgLongTu:getPositionY())
	 end

	local action1 = cc.ScaleTo:create(0, 0.75)
	local action2 = cc.ScaleTo:create(0.2, 1.05)
	local action3 = cc.ScaleTo:create(0.05, 1.01)
	local action4_1 = cc.ScaleTo:create(0.05, 0.98)

	
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		-- self:showGrayLongTuEffect()
	end)


	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local action6_1 = cc.FadeTo:create(0, 255*0.5)
		local action6_2 = cc.ScaleTo:create(0, 1.1)
		local action6 = cc.Spawn:create(action6_1,action6_2)
		local action7_1 = cc.FadeTo:create(0.45, 0)
		local action7_2 = cc.ScaleTo:create(0.45, 1.2)
		local action7 = cc.Spawn:create(action7_1,action7_2)
		local callback = cc.CallFunc:create(function (  )
			-- body
			self:removeGrayLongTuEffect()
			-- self.pImgLongTu:setVisible(true)

		end)

		self.pGrayLongTuEffect:runAction(cc.Sequence:create(action6,action7,callback))

	end)
	local action4 = cc.Spawn:create(action4_1,callback1)
	
	self.pImgLongTu:runAction(cc.Sequence:create(callback2,action1,action2,action3,action4))

end

function ItemStarSoul:removeGrayLongTuEffect(  )
	-- body
 	if self.pGrayLongTuEffect then
 		
 		self.pGrayLongTuEffect:removeSelf()
 		self.pGrayLongTuEffect=nil
 	end
end

function ItemStarSoul:setLineEffectHandler( _handler )
	-- body
	self.lineEffectHandler = _handler
end
function ItemStarSoul:setAddStarEffectHandler( _handler )
	-- body
	self.addStarEffectHandler = _handler
end

function ItemStarSoul:showActiveEffect(  )
	-- body
	if self.lineEffectHandler then

		local callback1 = cc.CallFunc:create(function (  )
			-- body
			-- self:removeGrayLongTuEffect()
			-- self.pImgLongTu:setVisible(true)
			self.lineEffectHandler(self.nPos)

		end)

		local callback2 = cc.CallFunc:create(function (  )
			-- body
			self:showActiveLight()
			setTextCCColor(self.pLbAttr, _cc.green)
			self.pImgLiang:setVisible(true)
			self.pImgLongTu:setToGray(false)
			self.pLayLock:setVisible(false)
			self.pLayAttr:setVisible(true)

		end)

		local action1 = cc.DelayTime:create(0.25)
		self:runAction(cc.Sequence:create(callback1,action1,callback2))
		
	end
end

function ItemStarSoul:showActiveLight(  )
	-- body
	addTextureToCache("tx/other/rwww_xh_xsxg")
	for i=1,3 do
		if not self.pActiveLightEffect[i] then
			local pImg = MUI.MImage.new("#rwww_xh_xsxg_001.png")
		 	pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		 	self:addView(pImg,10)
		 	pImg:setPosition(self.pImgLongTu:getPositionX(),self.pImgLongTu:getPositionY())
		 	self.pActiveLightEffect[i] = pImg
		end
		 
	end
	for i=1,3 do
		if self.pActiveLightEffect[i] then
			local pImg = self.pActiveLightEffect[i]
		 	pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		 	pImg:setOpacity(0)
		 	pImg:setScale(1.5)
		end
	end

	local action2_1 = cc.ScaleTo:create(0.2, 1.04)
	local action2_2 = cc.FadeTo:create(0.2, 255)
	local action2 = cc.Spawn:create(action2_1,action2_2)

	local callback1 = cc.CallFunc:create(function (  )
			-- body
			local action5_1 = cc.ScaleTo:create(0.2, 1.04)
			local action5_2 = cc.FadeTo:create(0.2, 255)
			local action5 = cc.Spawn:create(action5_1,action5_2)

			local callback2 = cc.CallFunc:create(function (  )
				-- body

				local action8_1 = cc.ScaleTo:create(0.2, 1.04)
				local action8_2 = cc.FadeTo:create(0.2, 255)
				local action8 = cc.Spawn:create(action8_1,action8_2)

				local action9_1 = cc.ScaleTo:create(0.32, 0.22)
				local action9_2 = cc.FadeTo:create(0.32, 0)
				local action9 = cc.Spawn:create(action9_1,action9_2)

				self.pActiveLightEffect[3]:setRotation(227)
				self.pActiveLightEffect[3]:runAction(cc.Sequence:create(action8,action9))
			end)

			local action6_1 = cc.ScaleTo:create(0.32, 0.22)
			local action6_2 = cc.FadeTo:create(0.32, 0)
			local action6 = cc.Spawn:create(callback2,action6_1,action6_2)

			self.pActiveLightEffect[2]:setRotation(110)
			self.pActiveLightEffect[2]:runAction(cc.Sequence:create(action5,action6))

	end)
	local action3_1 = cc.ScaleTo:create(0.32, 0.22)
	local action3_2 = cc.FadeTo:create(0.32, 0)
	local action3 = cc.Spawn:create(callback1,action3_1,action3_2)
	local callback3 = cc.CallFunc:create(function (  )
		self:showActiveLightEnd()

		if self.nPos == 1 then    --激活第一个星魂时 要播放一个升星动画
			if self.addStarEffectHandler then
				self.addStarEffectHandler()
			end
		end
	end)
	self.pActiveLightEffect[1]:runAction(cc.Sequence:create(action2,action3,callback3))
	
end

function ItemStarSoul:showActiveLightEnd( )
	-- body

	addTextureToCache("tx/other/rwww_wjxh_xs_sg")
	local tArmData1  = {
		nFrame = 26, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
			nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
			tActions = {
			{
				nType = 1, -- 序列帧播放
				sImgName = "rwww_wjxh_xs_sg_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 26, -- 结束帧下标
				tValues = nil, 
			},
		},
	}
	local pArm1 = MArmatureUtils:createMArmature(
		tArmData1, 
		self.pImgLongTu, 
		99, 
		cc.p(self.pImgLongTu:getWidth()/2, self.pImgLongTu:getHeight()/2),
		function ( _pArm )
			_pArm:removeSelf()
			_pArm = nil
		end, Scene_arm_type.normal)
	if pArm1 then
		pArm1:play(1)
	end
end

function ItemStarSoul:stopAllEffect(  )
	-- body

	for i=1,#self.pLockEffect do
		self.pLockEffect[i]:setOpacity(0) 
		self.pLockEffect[i]:stopAllActions()
		-- self.pLockEffect:stopAllActions()
	end
	for i=1,#self.pActiveLightEffect do
		self.pActiveLightEffect:setOpacity(0) 
		self.pActiveLightEffect[i]:stopAllActions()
		-- self.pLockEffect:stopAllActions()
	end
end

return ItemStarSoul