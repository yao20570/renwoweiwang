-- Author: maheng
-- Date: 2017-09-04 15:17:22
-- 武将星级显示

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local StarAttrLayer = class("StarAttrLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 数据 _nNums 顺序
function StarAttrLayer:ctor(_nNums, _nScale)
	-- body
		
	self.nStarW = 35
	self.nStarH = 35
	self:setLayoutSize(0,self.nStartH)
	self.nNUms = _nNums or 0
	self.tSoulStar = {nSolidNum = 0, nHollowNum = 0}
	self.nScale = _nScale or 1

	self.nLayerType = _nLayoutType or 1

	self:myInit()	

	self:updateViews()	
	--注册析构方法
	self:setDestroyHandler("StarAttrLayer",handler(self, self.onDestroy))
	
end

--初始化参数
function StarAttrLayer:myInit()
	-- body
	self.tData = {} --数据
	self.nNUms = 0
	self.tStarImgs = {}
	self.tStarEffImgs = {}
	self.nStatMax = 5

	self.pStarEffect ={}
	self.pStarBgEffect = {}

	--星魂升星动画的起始位置
	local tAddSoulStarPos = {
		[1]  = {x = -20,  y = -125},
		[2]  = {x = -70,  y = -125},
		[3]  = {x = -120, y = -125},
		[4]  = {x = -170, y = -125},
	}

	-- if self.nLayoutType == 2 then
	-- 	self:setLayoutSize(self.nStatMax*nStarW, nStarH)
	-- end

end

-- 修改控件内容或者是刷新控件数据
function StarAttrLayer:updateViews(  )
	local nStarW = self.nStarW*self.nScale		
	local nStarH = self.nStarH*self.nScale	
	for i = 1, self.nStatMax do
		if not self.tStarImgs[i] then
			local pImg = MUI.MImage.new("#v1_img_star5a.png", {scale9=false})			
			pImg:setScale(self.nScale)
			self:addView(pImg, 10)
			self.tStarImgs[i] = pImg
		end
		self.tStarImgs[i]:setPosition(nStarW*(i-0.5), nStarH/2)
		if i <= self.nNUms then
			self.tStarImgs[i]:setVisible(true)
		else
			self.tStarImgs[i]:setVisible(false)
		end

		if i <= self.tSoulStar.nSolidNum then --实心
			self.tStarImgs[i]:setCurrentImage("#v1_img_star5a.png")
		else 								--空心
			self.tStarImgs[i]:setCurrentImage("#v1_img_star5b.png")
		end
	end
	-- if self.nLayoutType == 1 then
		self:setLayoutSize(self.nNUms*nStarW, nStarH)
	-- end
end

--析构方法
function StarAttrLayer:onDestroy(  )
	-- body
end

--设置数据 _data
function StarAttrLayer:updateStar(_nNums)
	self.nNUms = _nNums or 0
	self:updateViews()

end

function StarAttrLayer:updateSoulStar(_tSoulStar)
	self.tSoulStar = _tSoulStar or self.tSoulStar
	--实心+空心个数
	self.nNUms = self.tSoulStar.nSolidNum + self.tSoulStar.nHollowNum
	self:updateViews()

end

--每个星星所占的宽度
function StarAttrLayer:setStartWidth( nW )
	-- body
	if nW then
		self.nStarW = nW or self.nStarW	
	end
end

--
function StarAttrLayer:resetStar(  )
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
function StarAttrLayer:updateStarWithAction( _tSoulStar )
	-- body
	self.tSoulStar = _tSoulStar or self.tSoulStar
	--实心+空心个数
	self.nNUms = self.tSoulStar.nSolidNum + self.tSoulStar.nHollowNum

	local fCallback = function ( i, img1, img2 )
		-- body

		img1:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*0.16),
			cc.CallFunc:create(function (  )
				img1:setScale(1.84)
				img1:setVisible(true)
			end), 
			cc.ScaleTo:create(0.16, 1), 
			cc.CallFunc:create(function (  )
				-- body
				img2:setOpacity(255*0.5)
				img2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
				img2:setVisible(true)
				img2:runAction(cc.FadeTo:create(0.5, 0))
			end)))		

	end
	local nStarW = self.nStarW*self.nScale		
	local nStarH = self.nStarH*self.nScale	
	for i = 1, self.nStatMax do
		local sImg = "#v1_img_star5b.png" --实星
		if i <= self.tSoulStar.nSolidNum then
			sImg = "#v1_img_star5a.png" --空星
		end
		if not self.tStarImgs[i] then
			local pImg = MUI.MImage.new(sImg, {scale9=false})			
			pImg:setScale(self.nScale)
			pImg:setVisible(false)
			self:addView(pImg, 10)
			self.tStarImgs[i] = pImg
		end
		if not self.tStarEffImgs[i] then
			local pImg2 = MUI.MImage.new(sImg, {scale9=false})			
			pImg2:setScale(self.nScale)
			pImg2:setVisible(false)
			self:addView(pImg2, 10)
			self.tStarEffImgs[i] = pImg2
		end
		self.tStarImgs[i]:setPosition(nStarW*(i-0.5), nStarH/2)
		self.tStarEffImgs[i]:setPosition(nStarW*(i-0.5), nStarH/2)	
		if i <= self.nNUms then
			fCallback(i, self.tStarImgs[i], self.tStarEffImgs[i])
		end
	end
	self:setLayoutSize(self.nNUms*nStarW, nStarH)	
end
--星魂星星从空心变成实心的动画
function StarAttrLayer:showSoulStarHollowToSolid( _nIndex )
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

function StarAttrLayer:showAddSoulStarAction(  )
	-- body
	local pStar = self.tStarImgs[self.nNUms]
	if pStar:isVisible() then
		pStar:setVisible(false)
		local nTargetX = pStar:getPositionX()
		local nTargetY = pStar:getPositionY()
		pStar:setPosition(x, y)

	end

	-- if not self.pAddStarEffect[1] then
	-- 	self.pAddStarEffect[1] = MUI.MImage.new("#v1_img_star5b.png")
	-- 	self.pAddStarEffect[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	-- 	self:addView(self.pStarEffect[i],11)
	-- end
	-- self.pAddStarEffect[1]:setPosition(x, y)

end

return StarAttrLayer