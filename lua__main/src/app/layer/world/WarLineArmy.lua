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
local MCommonView = require("app.common.MCommonView")
local WarLineArmy = class("WarLineArmy", function()
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	return pView
end)

function WarLineArmy:ctor(  )
	WorldFunc.setHighCameraMaskForView(self)
	self:onParseViewCallback()
end

--解析界面回调
function WarLineArmy:onParseViewCallback( )
	self:setContentSize(100, 100)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WarLineArmy", handler(self, self.onWarLineArmyDestroy))
end

-- 析构方法
function WarLineArmy:onWarLineArmyDestroy(  )
    self:onPause()
end

function WarLineArmy:regMsgs(  )
end

function WarLineArmy:unregMsgs(  )
end

function WarLineArmy:onResume(  )
	self:regMsgs()
	self:updateViews()
	-- regUpdateControl(self, handler(self, self.updateZorder))
end

function WarLineArmy:onPause(  )
	self:unregMsgs()
	-- unregUpdateControl(self)
end

function WarLineArmy:updateZorder(  )
	local nY = self:getPositionY()
	self:setLocalZOrder(math.max(WORLD_BG_HEIGHT - nY, 1))
end

function WarLineArmy:setupViews(  )
	if bIsUseBillBorard then
		self.pBbNameBg = createCCBillBorad("#v1_img_namebg30.png",cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
		self.pBbNameBg:setPosition3D(cc.vec3(0, 2, 0))
	else
		self.pBbNameBg = MUI.MImage.new("#v1_img_namebg30.png")
	end

	self:addView(self.pBbNameBg, 2)
	WorldFunc.setCameraMaskForView(self.pBbNameBg)

	self.pTxtName = MUI.MLabel.new({text = "", size = 16})
	setTextCCColor(self.pTxtName, _cc.lwhite)
	self:addView(self.pTxtName,2)

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
		    self:addView(self.pBbName,3)
		    WorldFunc.setCameraMaskForView(self.pBbName)
		end
	else
		WorldFunc.setCameraMaskForView(self.pTxtName)
	end
end

function WarLineArmy:updateViews(  )	
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
				tArmData = EffectWorldDatas[sName]
			end
		end
		--创建动画
		if tArmData then
			if self.pArm then
				self.pArm:setData(tArmData)
			else
				local pArm =  createMArmature(self, tArmData ,function (pArmate)
			    end,cc.p(0, 0),nil, Scene_arm_type.world)
			   	pArm:play(-1)
			   	self.pArm = pArm
			   	WorldFunc.setCameraMaskForView(pArm)
			end
			self.pArm:setFlippedX(bIsFilpX)
		end
	end
end

--颜色，起点坐标，终点坐标
--nColorType 颜色值 蓝是1，红是2
function WarLineArmy:setData( nColorType, nStartX, nStartY, nEndX, nEndY )
	self.nColorType = nColorType
	self.nArmIndex = self:angleToArmIndex(nStartX, nStartY, nEndX, nEndY)
	-- print("self.nArmIndex=======",self.nArmIndex)
	self:updateViews()
end

--角度转动画下标
function WarLineArmy:angleToArmIndex( nStartX, nStartY, nEndX, nEndY )
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

--设置名字
function WarLineArmy:setName( sName )
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

return WarLineArmy


