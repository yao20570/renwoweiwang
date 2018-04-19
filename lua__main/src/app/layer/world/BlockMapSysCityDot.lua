----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-04 16:42:56
-- Description: 区域地图弹出框  系统城池视示
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

--层次
local nTopZorder = 10

local BlockMapSysCityDot = class("BlockMapSysCityDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

function BlockMapSysCityDot:ctor( nSceneArmType)
	self.nSysCityId = nil
	self.nCountry = e_type_country.qunxiong
	self.nSceneArmType = nSceneArmType

	-- --添加纹理
	-- addTextureToCache("tx/other/sg_sjdt_xbhz_x",1, true)
	--解析文件
	parseView("layout_world_block_map_sys_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function BlockMapSysCityDot:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("BlockMapSysCityDot",handler(self, self.onBlockMapSysCityDotDestroy))
end

function BlockMapSysCityDot:onBlockMapSysCityDotDestroy(  )
	self:onPause()
	unregUpdateControl(self)
end

function BlockMapSysCityDot:onResume(  )
	regUpdateControl(self, handler(self, self.updateProtectCd))
	self:updateViews()
end

function BlockMapSysCityDot:onPause(  )
end

function BlockMapSysCityDot:setupViews(  )
	self.pLayImg = self:findViewByName("lay_img")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtName:enableOutline(cc.c4b(0, 0, 0, 255),2)
end

function BlockMapSysCityDot:updateViews(  )
	self:updateName()
	self:updateImg()	
	self:updateProtectCd()
	self:updateCollectTx()
end

--更新保护cd时间
function BlockMapSysCityDot:updateProtectCd()
	if self.tSystemcityOcpyInfo then
		--开启定时器
		local nCd = self.tSystemcityOcpyInfo:getProtectCd()
		if nCd > 0 then
			self:setProtectVisible(true)
		else
			self:setProtectVisible(false)
			unregUpdateControl(self)
		end
	else
		self:setProtectVisible(false)
		unregUpdateControl(self)
	end
end

--设置占领数据
--tSystemcityOcpyInfo: SystemcityOcpyInfo
function BlockMapSysCityDot:setData( tSystemcityOcpyInfo )
	self.tSystemcityOcpyInfo = tSystemcityOcpyInfo
	self.nCountry = self.tSystemcityOcpyInfo.nCountry
	regUpdateControl(self, handler(self, self.updateProtectCd))
	self:updateViews()
end

--设置城池id(注意会重置占领数据)
function BlockMapSysCityDot:setSysCityId( nSysCityId )
	self.nSysCityId = nSysCityId
	self.nCountry = e_type_country.qunxiong
	self.tSystemcityOcpyInfo = nil
	self:updateViews()
end

--获取id
function BlockMapSysCityDot:getId(  )
	return self.nSysCityId
end

--更新名字
function BlockMapSysCityDot:updateName(  )
	if self.tSystemcityOcpyInfo then
		self.pTxtName:setString(self.tSystemcityOcpyInfo:getName())
		setTextCCColor(self.pTxtName, getColorByCountry(self.tSystemcityOcpyInfo.nCountry))
	else
		if self.nSysCityId then
			--设置名字
			local tCityData = getWorldCityDataById(self.nSysCityId)
			if tCityData then
				self.pTxtName:setString(tCityData.name)
			end
		end
	end
end

--获取名字
function BlockMapSysCityDot:getTxtName( )
	return self.pTxtName
end

--更新图片
function BlockMapSysCityDot:updateImg(  )
	if not self.nSysCityId then
		return
	end
	--去掉重复刷新
	if self.nUpdateImgId == self.nSysCityId and self.nUpdateImgCountry == self.nCountry then
		return
	end	
	self.nUpdateImgId = self.nSysCityId
	self.nUpdateImgCountry = self.nCountry
	--设置图片
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		local sMapIcon = tCityData.tMapicon[self.nCountry]
		if sMapIcon then
			--箭影图片
			local pImg = self.pImg
			if not pImg then --创建
				pImg = MUI.MImage.new(sMapIcon)
				self.pLayImg:addView(pImg)
				self.pImg = pImg
			else
				pImg:setCurrentImage(sMapIcon)
			end
			centerInView(self.pLayImg, pImg)
			WorldFunc.setSysCityShadowImgScale(pImg, tCityData.kind)

			--保护特效层
			if not self.pLayProtectArm then
				self.pLayProtectArm = MUI.MLayer.new()
				self.pLayProtectArm:setLayoutSize(100, 100)
				self.pLayProtectArm:setAnchorPoint(0.5, 0.5)
				self.pLayImg:addView(self.pLayProtectArm)
				local nX, nY = self.pImg:getPosition()
				self.pLayProtectArm:setPosition(nX, nY)
			end
			local fScale = self.pImg:getScale()
			self.pLayProtectArm:setScale(fScale + 0.4)
		end
	end
end

--获取城池图片
function BlockMapSysCityDot:getImgCity( )
	return self.pImg
end

--获取城池层
function BlockMapSysCityDot:getLayImgCity( )
	return self.pLayImg
end


--视置被攻击事件
function BlockMapSysCityDot:setBeAtkCountry( tCountry )
	if self.pImgAtkRed then
		self.pImgAtkRed:setVisible(false)
	end
	if self.pImgAtkGray then
		self.pImgAtkGray:setVisible(false)
	end
	if self.pImgAtkGreen then
		self.pImgAtkGreen:setVisible(false)
	end
	if self.pImgAtkBlue then
		self.pImgAtkBlue:setVisible(false)
	end
	-- tCountry = {e_type_country.qunxiong ,
	-- e_type_country.weiguo,
	-- e_type_country.shuguo,
	-- e_type_country.wuguo,
	-- }
	local nOffsetX, nOffsetY = 0, -5
	if tCountry then
		for i=1,#tCountry do
			if 	tCountry[i] == e_type_country.qunxiong then
				if not self.pImgAtkGray then
					self.pImgAtkGray = MUI.MImage.new("#v1_img_huijiantou.png")
					self.pImgAtkGray:setPosition(84, 52 + nOffsetY)
					self.pImgAtkGray:setFlippedY(true)
					self:addView(self.pImgAtkGray, nTopZorder)
				end
				self.pImgAtkGray:setVisible(true)
			elseif tCountry[i] == e_type_country.weiguo then
				if not self.pImgAtkBlue then
					self.pImgAtkBlue = MUI.MImage.new("#v1_img_lanjiantou2.png")
					self.pImgAtkBlue:setPosition(0, 52 + nOffsetY)
					self.pImgAtkBlue:setFlippedX(true)
					self.pImgAtkBlue:setFlippedY(true)
					self:addView(self.pImgAtkBlue, nTopZorder)
				end
				self.pImgAtkBlue:setVisible(true)
			elseif tCountry[i] == e_type_country.shuguo then
				if not self.pImgAtkRed then
					self.pImgAtkRed = MUI.MImage.new("#v1_img_hongjiantou2.png")
					self.pImgAtkRed:setPosition(84, 13 + nOffsetY)
					self:addView(self.pImgAtkRed, nTopZorder)
				end
				self.pImgAtkRed:setVisible(true)
			elseif tCountry[i] == e_type_country.wuguo then
				if not self.pImgAtkGreen then
					self.pImgAtkGreen = MUI.MImage.new("#v1_img_lvjiantou.png")
					self.pImgAtkGreen:setPosition(0, 13 + nOffsetY)
					self.pImgAtkGreen:setFlippedX(true)
					self:addView(self.pImgAtkGreen, nTopZorder)
				end
				self.pImgAtkGreen:setVisible(true)
			end
		end
	end
end

--显示小保护罩特效
function BlockMapSysCityDot:setProtectVisible( bIsShow )
	if not self.pLayProtectArm then
		return
	end
	if not self.nSysCityId then
		return
	end
	--都城和中心城不显示
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		if tCityData.kind == e_kind_city.ducheng or
			tCityData.kind == e_kind_city.zhongxing then
			bIsShow = false
		end
	end
	if bIsShow then
		--显示精灵
		if not self.pProtectArm then
			--创建精灵
			local pProtectArm = MArmatureUtils:createMArmature(EffectWorldDatas["smallProtectCover"], 
			self.pLayProtectArm, 
			0, 
			cc.p(50, 50),
		    function (  )
			end, self.nSceneArmType)
			pProtectArm:play(-1)
			self.pProtectArm = pProtectArm
		else
			self.pProtectArm:play(-1)
			self.pProtectArm:setVisible(true)
		end
	else
		--隐藏精灵
		if self.pProtectArm then
			self.pProtectArm:stop()
			self.pProtectArm:setVisible(false)
		end
	end
end

--刷新征收特效 
function BlockMapSysCityDot:updateCollectTx(  )
	-- body
	local bCollect = false
	if self.tSystemcityOcpyInfo then
		bCollect = self.tSystemcityOcpyInfo.bCanCollect
	end	
	self:showCollectTx(bCollect)
end

--显示征收特效
function BlockMapSysCityDot:showCollectTx( _bShow )
	-- body
	-- self.pLayCollectArm
	--显示特效
	if not self.pImg then
		return
	end
	if _bShow then
		if not self.pLayCollectArm then
			self.pLayCollectArm = MUI.MLayer.new()
			self.pLayCollectArm:setLayoutSize(100, 100)
			self.pLayCollectArm:setAnchorPoint(0.5, 0.5)
			self.pLayImg:addView(self.pLayCollectArm)
			local nX, nY = self.pImg:getPosition()
			self.pLayCollectArm:setPosition(nX, nY + self.pImg:getHeight()/2 - 5)
		end
		if not self.pCollectArm then
			--创建精灵			
			local pCollectArm = MArmatureUtils:createMArmature(EffectWorldDatas["smallCollectCover"], 
			self.pLayCollectArm, 
			1, 
			cc.p(50, 50),
		    function (  )
			end, self.nSceneArmType)
			pCollectArm:play(-1)
			self.pCollectArm = pCollectArm
		else
			self.pCollectArm:play(-1)
			self.pCollectArm:setVisible(true)				
		end
		--粒子特效		
		if not self.pCollectLZ then
			self.pCollectLZ = createParitcle("tx/other/lizi_rwww_zslz_001.plist")
			self.pCollectLZ:setPosition(self.pLayCollectArm:getWidth() / 2 ,self.pLayCollectArm:getHeight() / 2)
			self.pLayCollectArm:addView(self.pCollectLZ)
			self.pCollectLZ:setScale(1.05)
			centerInView(self.pLayCollectArm,self.pCollectLZ)
		end
		self.pCollectLZ:setVisible(true)
	else--隐藏特效
		if self.pCollectArm then		
			self.pCollectArm:stop()
			self.pCollectArm:setVisible(false)		
		end
		if self.pCollectLZ then
			self.pCollectLZ:setVisible(false)
		end
	end
end

return BlockMapSysCityDot