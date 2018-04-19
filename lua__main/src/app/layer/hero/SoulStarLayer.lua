-- Author: luwenjing
-- Date: 2017-09-04 15:17:22
-- 武将星魂星级显示

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local SoulStarLayer = class("SoulStarLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 数据 _nNums 顺序
function SoulStarLayer:ctor(_nNums, _nScale,_nWidth)
	-- body
		
	self.nStarW = 35
	self.nStarH = 35
	self:setLayoutSize(_nWidth,self.nStartH)
	self.nNUms = _nNums or 0
	self.tSoulStar = {nSolidNum = 0, nHollowNum = 0}
	self.nScale = _nScale or 1

	self:myInit()	

	self:updateViews()	
	--注册析构方法
	self:setDestroyHandler("SoulStarLayer",handler(self, self.onDestroy))
	
end

--初始化参数
function SoulStarLayer:myInit()
	-- body
	self.bInit = true
	self.tData = {} --数据
	self.nNUms = 0
	self.tStarImgs = {}
	self.tStarEffImgs = {}
	self.nStatMax = 5

	self.pStarEffect ={}
	self.pStarBgEffect = {}

	local nWidth = self:getContentSize().width
	local nHeight = self:getContentSize().height
	--星魂升星动画的起始位置 写死位置
	self.tAddSoulStarPos = {
		[1]  = {x = nWidth/2 ,  y = -230},
		[2]  = {x = nWidth/2 -130,  y = -230},
		[3]  = {x = nWidth/2 -263, y = -230},
		[4]  = {x = nWidth/2 -395, y = -230},
	}
	--星魂升星动画的起始位置
	self.tSoulStarPos = {}
	self:setSoulStarPosData()
	-- if self.nLayoutType == 2 then
	-- 	self:setLayoutSize(self.nStatMax*nStarW, nStarH)
	-- end

end

-- 修改控件内容或者是刷新控件数据
function SoulStarLayer:updateViews(  )
	local nStarW = self.nStarW*self.nScale		
	local nStarH = self.nStarH*self.nScale	
	for i = 1, self.nStatMax do
		if not self.tStarImgs[i] then
			local pImg = MUI.MImage.new("#v1_img_star5a.png", {scale9=false})			
			pImg:setScale(self.nScale)
			self:addView(pImg, 10)
			self.tStarImgs[i] = pImg
		end
		
		if i <= self.nNUms then
			self.tStarImgs[i]:setVisible(true)
		else
			self.tStarImgs[i]:setVisible(false)
		end
		if self.nNUms > 0 then
			self.tStarImgs[i]:setPosition(self.tSoulStarPos[self.nNUms].x + (i-1 )* nStarW , nStarH/2)
		end


		if i <= self.tSoulStar.nSolidNum then --实心
			self.tStarImgs[i]:setCurrentImage("#v1_img_star5a.png")
		else 								--空心
			self.tStarImgs[i]:setCurrentImage("#v1_img_star5b.png")
		end
	end
	-- if self.nLayoutType == 1 then
		-- self:setLayoutSize(self.nNUms*nStarW, nStarH)
	-- end
end
--设置星星位置数据
function SoulStarLayer:setSoulStarPosData(  )
	-- body
	local nWidth = self:getContentSize().width
	local nHeight = self:getContentSize().height
	local nStarW = self.nStarW*self.nScale		
	local nStarH = self.nStarH*self.nScale
	--星魂升星动画的起始位置
	self.tSoulStarPos[1] ={x = nWidth/2 ,  y = nStarH/2}
	self.tSoulStarPos[2] ={x = nWidth/2 - nStarW / 2 ,  y = nStarH/2}
	self.tSoulStarPos[3] ={x = nWidth/2 - nStarW,  y = nStarH/2}
	self.tSoulStarPos[4] ={x = nWidth/2 - nStarW  - nStarW / 2 ,  y = nStarH/2}
	self.tSoulStarPos[5] ={x = nWidth/2 - 2*nStarW ,  y = nStarH/2}

end

--析构方法
function SoulStarLayer:onDestroy(  )
	-- body
	removeTextureFromCache("tx/other/rwww_xh_sxtx",1)
end

--设置数据 _data
function SoulStarLayer:updateStar(_nNums)
	self.nNUms = _nNums or 0
	self:updateViews()

end

function SoulStarLayer:updateSoulStar(_tSoulStar)
	self.tSoulStar = _tSoulStar or self.tSoulStar
	--实心+空心个数
	self.nNUms = self.tSoulStar.nSolidNum + self.tSoulStar.nHollowNum
	self:updateViews()

end

--每个星星所占的宽度
function SoulStarLayer:setStartWidth( nW )
	-- body
	if nW then
		self.nStarW = nW or self.nStarW	
	end
end

--
function SoulStarLayer:resetStar(  )
	-- body
	for i = 1, self.nStatMax do
		if self.tStarImgs[i] then
			self.tStarImgs[i]:setVisible(false)
		end
		if self.tStarEffImgs[i] then
			self.tStarEffImgs[i]:setVisible(false)
		end
	end

end
--
--星魂星星从空心变成实心的动画
function SoulStarLayer:showSoulStarHollowToSolid( _nIndex )
	-- body
	addTextureToCache("tx/other/rwww_xh_sxtx")
	for i=1, 3 do
		if not self.pStarEffect[i] then
		 	self.pStarEffect[i] = MUI.MImage.new("#rwww_xh_sxtx_001.png")
		 	self.pStarEffect[i]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		 	local nZorder = 13+i

		 	self:addView(self.pStarEffect[i],nZorder)
		 end
	end
	local nX= 0
	local nY= 0

	if self.tStarImgs[_nIndex] then
		self.tStarImgs[_nIndex]:setCurrentImage("#v1_img_star5b.png")
		nX= self.tStarImgs[_nIndex]:getPositionX() 
		nY= self.tStarImgs[_nIndex]:getPositionY()
	end
	for i=1,3 do
		self.pStarEffect[i]:setScale(1.5)
		self.pStarEffect[i]:setOpacity(0)
		if self.tStarImgs[_nIndex] then
			self.pStarEffect[i]:setPosition(nX,nY)
		end
	end

	local action1_1 = cc.ScaleTo:create(0.25, 0.93)
	local action1_2 = cc.FadeTo:create(0.25, 255)
	local action1 = cc.Spawn:create(action1_1,action1_1)

	local callback1 = cc.CallFunc:create(function (  )
			-- body
			local action3_1 = cc.ScaleTo:create(0.25, 0.93)
			local action3_2 = cc.FadeTo:create(0.25, 255)
			local action3 = cc.Spawn:create(action3_1,action3_2)

			local callback2 = cc.CallFunc:create(function (  )
				-- body

				local action5_1 = cc.ScaleTo:create(0.25, 0.93)
				local action5_2 = cc.FadeTo:create(0.25, 255)
				local action5 = cc.Spawn:create(action5_1,action5_2)

				local action6_1 = cc.ScaleTo:create(0.25, 0)
				local action6_2 = cc.FadeTo:create(0.25, 0)
				local action6 = cc.Spawn:create(action6_1,action6_2)

				self.pStarEffect[3]:setRotation(228)
				self.pStarEffect[3]:runAction(cc.Sequence:create(action5,action6))
			end)

			local action4_1 = cc.ScaleTo:create(0.25, 0)
			local action4_2 = cc.FadeTo:create(0.25, 0)
			local action4 = cc.Spawn:create(callback2,action4_1,action4_2)

			self.pStarEffect[2]:setRotation(92)
			self.pStarEffect[2]:runAction(cc.Sequence:create(action3,action4))

	end)
	local action2_1 = cc.ScaleTo:create(0.25, 0)
	local action2_2 = cc.FadeTo:create(0.25, 0)
	local action2 = cc.Spawn:create(callback1,action2_1,action2_2)

	--实心星星的动画
	if not self.pStarBgEffect[1] then
		self.pStarBgEffect[1] = MUI.MImage.new("#v1_img_star5a.png")
		self.pStarBgEffect[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self:addView(self.pStarBgEffect[1],11)
	end
	--空心星星
	if not self.pStarBgEffect[2] then
		self.pStarBgEffect[2] = MUI.MImage.new("#v1_img_star5b.png")

		self:addView(self.pStarBgEffect[2],12)
	end

	if self.tStarImgs[_nIndex] then
		self.pStarBgEffect[1]:setPosition(nX,nY)
		self.pStarBgEffect[2]:setPosition(nX,nY)
		self.pStarBgEffect[2]:setScale(1.2)
		self.pStarBgEffect[1]:setOpacity(0)
		self.pStarBgEffect[2]:setOpacity(0)

	end

	local callback3 = cc.CallFunc:create(function (  )
		self.tStarImgs[_nIndex]:setCurrentImage("#v1_img_star5a.png")
		self.pStarBgEffect[1]:setOpacity(255)
		self.pStarBgEffect[2]:setOpacity(255)
		local action7 = cc.FadeTo:create(0.9, 0)

		local action8_1 = cc.FadeTo:create(0.6, 0)
		local action8_2 = cc.ScaleTo:create(0.6, 2)
		local action8 = cc.Spawn:create(action8_1,action8_2)

		self.pStarBgEffect[1]:runAction(action7)
		self.pStarBgEffect[2]:runAction(cc.Sequence:create(action8))
	end)
	self.pStarEffect[1]:runAction(cc.Sequence:create(action1,action2,callback3))

end

function SoulStarLayer:showAddSoulStarAction( _tSoulStar ,_nSoulStarPos)
	local nOrgNum = self.nNUms
	--实心+空心个数
	self.nNUms = self.tSoulStar.nSolidNum + self.tSoulStar.nHollowNum
	self.tSoulStar = _tSoulStar or self.tSoulStar
	--第一次进入时不需要动画
	if self.nNUms == 0 or self.bInit then--or nOrgNum ==self.nNUms then
		-- print("SoulStarLayer 265",_nSoulStarPos,nOrgNum)
		self.bInit = false
		self:updateViews()
		return
	end

	--防止二次刷新
	if self.tStarImgs[self.nNUms]:isVisible() then
		return
	end

	--要等吸收动画播完才执行这个动画
	doDelayForSomething(self,function (  )
		-- body
		local nStarW = self.nStarW*self.nScale	
		if self.tStarImgs[self.nNUms] then
			self.tStarImgs[self.nNUms]:setVisible(true)
			if _nSoulStarPos then
				self.tStarImgs[self.nNUms]:setPosition(self.tAddSoulStarPos[_nSoulStarPos].x, self.tAddSoulStarPos[_nSoulStarPos].y) 
			end
		end

		local nNewX = self.tSoulStarPos[self.nNUms].x + (self.nNUms-1 )* nStarW  
		local action1 = cc.MoveTo:create(0.35, cc.p(nNewX - 2,self.tSoulStarPos[self.nNUms].y))
		local action2 = cc.MoveTo:create(0.1, cc.p(nNewX,self.tSoulStarPos[self.nNUms].y))

		if not self.pAddStarEffect then
			self.pAddStarEffect = MUI.MImage.new("#v1_img_star5b.png")
			self.pAddStarEffect:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			self.pAddStarEffect:setOpacity(0)

			self:addView(self.pAddStarEffect,11)
		end
		self.pAddStarEffect:setPosition(nNewX - 2,self.tSoulStarPos[self.nNUms].y)
		local action3 = cc.DelayTime:create(0.34)
		local action4 = cc.FadeTo:create(0.01, 255)
		local action5_1 = cc.MoveTo:create(0.1, cc.p(nNewX,self.tSoulStarPos[self.nNUms].y))
		local action5_2 = cc.FadeTo:create(0.1, 255 * 0.75)
		local action5 = cc.Spawn:create(action5_1,action5_2)

		local action6 = cc.FadeTo:create(0.3, 0)
		self.pAddStarEffect:runAction(cc.Sequence:create(action3,action4,action5,action6))
		
		local callback1 = cc.CallFunc:create(function (  )
			-- body
			if  self.nNUms > 1 then

				function starMove( _nIndex )
					-- body
					if _nIndex > 0 then
						local nX= self.tSoulStarPos[self.nNUms].x + (_nIndex-1 )* nStarW 
						local nY= self.tSoulStarPos[self.nNUms].y
						local action7 = cc.MoveTo:create(0.15, cc.p(nX - 2,nY))
						local action8 = cc.MoveTo:create(0.35, cc.p(nX,nY))
						local action9 = cc.DelayTime:create(0.1)
						--显示升星效果
						local callback = cc.CallFunc:create(function (  )
							-- body
							starMove(_nIndex - 1)
						end)

						self.tStarImgs[_nIndex]:runAction(cc.Sequence:create(action7,callback,action8))
					end

				end
				starMove(self.nNUms - 1)
			end
		end)
		self.tStarImgs[self.nNUms]:runAction(cc.Sequence:create(action1,callback1,action2))

	end,0.7)


end

return SoulStarLayer