----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-26 14:45:07
-- Description: 行军路线 武将
-----------------------------------------------------

local bIsUseBillBorard = true
--8方向
--上到下1，下到上2，左到右3，左上到右下4，左下到右上5，右到左6，右上到左下7，右下到右上8
local tEnemyArmDatas = {
	[1] = {name = "redArmyUpToDown", img = "sg_hq_sdx_"},
	[2] = {name = "redArmyDownToUp", img = "sg_hq_xds_"},
	[3] = {name = "redArmyLeftToRight", img = "sg_hq_zdy_"},
	[4] = {name = "redArmyLeftUToRightD", img = "sg_hq_zsdyx_"},
	[5] = {name = "redArmyLeftDToRightU", img = "sg_hq_zxdys_"},
	[6] = {nKey = 3, flipX = true},
	[7] = {nKey = 4, flipX = true},
	[8] = {nKey = 5, flipX = true},
}
local tMyArmDatas = {
	[1] = {name = "blueArmyUpToDown", img = "sg_lh_sdx_"},
	[2] = {name = "blueArmyDownToUp", img = "sg_lh_xds_"},
	[3] = {name = "blueArmyLeftToRight", img = "sg_lq_zdy_"},
	[4] = {name = "blueArmyLeftUToRightD", img = "sg_lq_zsdyx_"},
	[5] = {name = "blueArmyLeftDToRightU", img = "sg_lq_zxdys_"},
	[6] = {nKey = 3, flipX = true},
	[7] = {nKey = 4, flipX = true},
	[8] = {nKey = 5, flipX = true},
}

local e_color_type = {
	blue = 1,
	red = 2,
}
local WarLineHero = class("WarLineHero", function( pParent )
	--创建动画
	
	local tArmData = EffectWorldDatas["blueArmyUpToDown"] --默认动画
	local pArm =  createMArmature(pParent, tArmData ,function (pArmate)
    end,cc.p(0, 0))
   	pArm:play(-1)
   	pArm.__setOpacity = pArm.setOpacity
   	pArm.tArmData = tArmData

   	local pArm2 =  createMArmature(pParent, tArmData ,function (pArmate)
    end,cc.p(0, 0))
   	pArm2:play(-1)
   	pArm2.__setOpacity = pArm.setOpacity
   	pArm2.tArmData = tArmData
   	-- pArm2:setVisible(false)
   	pArm.pSpecialEffect = pArm2

	return pArm
end)

function WarLineHero:ctor(  )
	WorldFunc.setCameraMaskForView(self)
	self:setupViews()
end

function WarLineHero:updateZorder(  )
	local nY = self:getPositionY()
	self:setLocalZOrder(math.max(WORLD_BG_HEIGHT - nY, 1))
end

function WarLineHero:resetArmature( )
end

function WarLineHero:setupViews(  )
	if bIsUseBillBorard then
		self.pBbNameBg = createCCBillBorad("#v1_img_namebg30.png",cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
		self.pBbNameBg:setPosition3D(cc.vec3(0, 2, 0))
	else
		self.pBbNameBg = MUI.MImage.new("#v1_img_namebg30.png")
	end

	self:addChild(self.pBbNameBg, 2)
	WorldFunc.setCameraMaskForView(self.pBbNameBg)

	self.pTxtName = MUI.MLabel.new({text = "", size = 16})
	setTextCCColor(self.pTxtName, _cc.lwhite)
	self:addChild(self.pTxtName,2)

	if bIsUseBillBorard then
		self.pTxtName:setVisible(false)
		--随便设置一个设置 只为了获取texture
		self.pTxtName:setString("1")
		self.pTxtName:updateContent()
		--获取所有的子节点
		local tChildrens = self.pTxtName:getChildren()
		if(tChildrens[1]) then
		    local texture = tChildrens[1]:getTexture()
		    --名字
		    self.pBbName = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
		    self.pBbName:setPosition3D(cc.vec3(0, 1, 1))
		    self:addChild(self.pBbName,3)
		    WorldFunc.setCameraMaskForView(self.pBbName)
		end
	else
		WorldFunc.setCameraMaskForView(self.pTxtName)
	end
end

function WarLineHero:updateViews(_bIsGhost )	
	if self.nPrevColorType ~= self.nColorType or self.nPrevArmIndex ~= self.nArmIndex then
		self.nPrevColorType = self.nColorType
		self.nPrevArmIndex = self.nArmIndex

		local tArmData = nil
		local bIsFilpX = false
		if self.nColorType == e_color_type.blue then
			local tData = tMyArmDatas[self.nArmIndex]
			local sName = tData.name
			if tData.nKey then
				sName = tMyArmDatas[tData.nKey].name
				bIsFilpX = tData.flipX or false
			end
			if sName then
				tArmData = EffectWorldDatas[sName]
			end		
		else
			local tData = tEnemyArmDatas[self.nArmIndex]
			local sName = tData.name
			if tData.nKey then
				sName = tEnemyArmDatas[tData.nKey].name
				bIsFilpX = tData.flipX or false
			end
			if sName then
				if _bIsGhost then
					sName = sName .. "_gh"
				end
				tArmData = EffectWorldDatas[sName]
			end
		end
		--创建动画
		if tArmData then
			self:setData(tArmData)
			self.tArmData = tArmData
			self:setFlippedX(bIsFilpX)

			local pPos = self:getNameBgPos()
			self.pBbName:setPosition(pPos)
			self.pBbNameBg:setPosition(pPos)
		end
	end
end

function WarLineHero:setGhostEffect(  )
	-- body
	-- self:setColor(getC3B("7EADFF"))
	-- print("148")
	-- if self.pSpecialEffect then
	-- print("150")

	-- 	self.pSpecialEffect:setVisible(true)
	-- 	local tArmData = copyTab(self.tArmData)
	-- 	tArmData.nBlend=1
	-- 	self.pSpecialEffect:setData(tArmData)
	-- 	-- self.pSpecialEffect:play(-1)
	-- 	self.pSpecialEffect:setColor(getC3B("63A9FF"))
	-- 	WorldFunc.setCameraMaskForView(self.pSpecialEffect)
	-- end
	-- self.tArmData.fScale = 0
	-- local tArmData1 = copyTab(self.tArmData)
	-- -- dump(self.pParent,"parent")
	-- tArmData1.nBlend=1
	-- tArmData1.pos={33,62}
	-- local pArm =  createMArmature(self, tArmData1 ,function (pArmate)
 --    end,cc.p(0, 0))
 --    if pArm then
 --    	pArm:setColor(getC3B("63A9FF"))
 --   		pArm:play(-1)
 --   		pArm:setLocalZOrder(1111)
 --   		WorldFunc.setCameraMaskForView(pArm)
 --   	end
 --   	local tArmData2 = copyTab(self.tArmData)
	-- tArmData2.nBlend=1
	-- tArmData2.pos={33,62}
	-- local pArm =  createMArmature(self.pParent, tArmData2 ,function (pArmate)
 --    end,cc.p(0, 0))
 --    if pArm then
 --    	pArm:setColor(getC3B("63A9FF"))
 --   		pArm:play(-1)
 --   		pArm:setLocalZOrder(1111)
 --   		WorldFunc.setCameraMaskForView(pArm)
 --   	end
   	-- self:setVisible(false)

   	-- self.tArmData= EffectWorldDatas["blueArmyLeftDToRightU"]
   		self:setData(self.tArmData)
   
 --   	self.tArmData.tActions={
 --   		{
 --   			nType = 5, -- 缩放 + 透明度
	-- 		sImgName = "rwww_tmtp_1_1",
	-- 		nSFrame = 16,
	-- 		nEFrame = 30,
	-- 		tValues = {-- 参数列表
	-- 			{0, 0}, -- 开始, 结束缩放值
	-- 			{0, 0}, -- 开始, 结束透明度值
	-- 		},
	-- 	}
	-- }
end

--获取动画侦偏移值
function WarLineHero:getArmOffsetPos( )
	if self.tArmData then
		return self.tArmData.pos[1], self.tArmData.pos[2]
	end
	return nil
end

--颜色，起点坐标，终点坐标
--nColorType 颜色值 蓝是1，红是2
function WarLineHero:setColorAndDir( nColorType, nStartX, nStartY, nEndX, nEndY ,_bIsGhost)
	self.nColorType = nColorType
	self.nArmIndex = self:angleToArmIndex(nStartX, nStartY, nEndX, nEndY)
	-- print("self.nArmIndex=======",self.nArmIndex)
	self:updateViews(_bIsGhost)
end

--角度转动画下标
function WarLineHero:angleToArmIndex( nStartX, nStartY, nEndX, nEndY )
	local nAngle = getAngle(nStartX, nStartY, nEndX, nEndY)
	-- print("1nAngle=======",nAngle)
	if nAngle > 360 then
		nAngle = nAngle%360
	end
	if nAngle < -360 then
		nAngle = math.ceil(math.abs(nAngle)/360) + nAngle
	end
	-- print("nAngle=======",nAngle)
	local nOffset = 360/16
	if nAngle >= 360 - nOffset or nAngle < 0 + nOffset then
		return 3
	elseif nAngle >= 45 - nOffset and nAngle < 45 + nOffset then
		return 4
	elseif nAngle >= 90 - nOffset and nAngle < 90 + nOffset then
		return 1
	elseif nAngle >= 135 - nOffset and nAngle < 135 + nOffset then
		return 7
	elseif nAngle >= 180 - nOffset and nAngle < 180 + nOffset then
		return 6
	elseif nAngle >= 225 - nOffset and nAngle < 225 + nOffset then
		return 8
	elseif nAngle >= 270 - nOffset and nAngle < 270 + nOffset then
		return 2
	else
		return 5
	end
end

--名字面板位置
function WarLineHero:getNameBgPos( )
	--8方向
	--上到下1，下到上2，左到右3，左上到右下4，左下到右上5，右到左6，右上到左下7，右下到右上8
	if self.nArmIndex == 1 or self.nArmIndex == 2 then
		return cc.p(20, 0)
	else
		return cc.p(40, 0)
	end
	return cc.p(20, 0)
end

--设置名字
function WarLineHero:setName( sName )
	self.pTxtName:setString(sName, false)

	if bIsUseBillBorard then
		--强制渲染一下
		self.pTxtName:updateContent()
		local tChildrens = self.pTxtName:getChildren()
		if(tChildrens[1]) then
		    local pTexture = tChildrens[1]:getTexture()
		    self.pBbName:setTexture(pTexture)
		    --重新设置一下大小
		    self.pBbName:setTextureRect(cc.rect(0,0,self.pTxtName:getContentSize().width,self.pTxtName:getContentSize().height))
		end

		--更新等级背景大小
		local nWidth = self.pTxtName:getWidth()
		if nWidth <= 32 then --2个字
			self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg30.png"))
		elseif nWidth <= 48 then --3个字
			self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3a.png"))
		elseif nWidth <= 64 then --4个字
			self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3b.png"))
		elseif nWidth <= 80 then --5个字
			self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3c.png"))
		else --6个字
			self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3d.png"))
		end
	end
end

function WarLineHero:setOpacity( nValue )
	self:__setOpacity(nValue)
	self.pBbName:setOpacity( nValue )
	self.pBbNameBg:setOpacity( nValue )
end

return WarLineHero


