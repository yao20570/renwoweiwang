----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-11 17:03:49
-- Description: 区域地图背景
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local BlockWarLine = require("app.layer.world.BlockWarLine")
local BlockMapSysCityDot = require("app.layer.world.BlockMapSysCityDot")
local nImperialCityMapId = 1013 --皇城mapId
local nBgZorder = 1
local nContentZorder = 2
local nSySCityZorder = 3
local nBossZorder = 4
local nCityZorder = 5
local nLineZorder = 6
local nLocalZorder = 7

--算不出来了，设位置算了-_-(是以场景为1528, 812)
local tBlockMapBgKingPos = {
	[11162] = {312, 326},
	[11159] = {461, 565},
	[11170] = {918, 485},
	[11166] = {916, 645},
	[11164] = {612, 486},
	[11163] = {462, 406},
	[11160] = {613, 645},
	[11158] = {311, 485},
	[11165] = {765, 565},
	[11161] = {765, 724},
	[11168] = {613, 326},
	[11169] = {764, 406},
	[11175] = {1069, 406},
	[11174] = {917, 326},
	[11167] = {463, 246},
	[11172] = {615, 166},
	[11180] = {1220, 325},
	[11173] = {765, 245},
	[11171] = {1068, 565},
	[11176] = {1221, 485},
	[11179] = {1067, 245},
	[11181] = {1371, 404},
	[11178] = {917, 166},
	[11177] = {767, 87},
	[11157] = {160, 406}
}

local e_view_type = {
	world = 1,
	normal = 2,
}

local BlockMapLayer = class("BlockMapLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nViewType  1，是世界小地图，2，是普通界面
function BlockMapLayer:ctor( nViewType )
	self.nViewType = nViewType
	
	--透明度
	self.nOpacity = 255
	self.nSceneArmType = Scene_arm_type.normal
	if self.nViewType == e_view_type.world then
		self.nOpacity = 80
		self.nSceneArmType = Scene_arm_type.world
	end

	
	self.pImgCitys = {} --当前玩家城池图片列表，以sDotKey方式存放
	self.pUnImgCitys = {} --闲置玩家城池图片列表，以列表方式存放

	self.pImgSysCitys = {} --当前系统城池图片列表，以id方式存放
	self.pUnImgSysCitys = {} --闲置系统城池图片列表，以列表方式存放

	self.pImgBosses = {} --当前Boss图片列表，以sDotKey方式存放
	self.pUnImgBosses = {} --闲置Boss图片列表，以列表方式存放

	self.pImgTLBoss = nil --当前TLBoss图片

	self.pBossEffectes = {} --当前Boss特效列表，以sDotkey方式存放
	self.pUnBossEffectes = {} --闲置Boss特效列表，以列表方式存放

	self.pImgKingZhous = {} --纣王试炼
	self.pUnImgKingZhous = {}	--闲置的纣王试炼

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BlockMapLayer", handler(self, self.onBlockMapLayerDestroy))
end

-- 析构方法
function BlockMapLayer:onBlockMapLayerDestroy(  )
    self:onPause()
end

function BlockMapLayer:regMsgs(  )
	regMsg(self, gud_tlboss_world_pos_refersh, handler(self, self.updateImgTLBoss))
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.updateImgTLBoss))
end

function BlockMapLayer:unregMsgs(  )
	unregMsg(self, gud_tlboss_world_pos_refersh)
	unregMsg(self, gud_tlboss_data_refresh)
end

function BlockMapLayer:onResume(  )
	self:regMsgs()
end

function BlockMapLayer:onPause(  )
	self:unregMsgs()
end

function BlockMapLayer:setupViews(  )
	--设置大小，图片改变，就要改
	self:setContentSize(1528, 812)
	--地图层
	self.pMapSize = cc.size(1504, 794) --地图尺寸(去掉边阴影）,注意地图背景要换也要跟着换
	--内容层
	local pLayContent =  MUI.MLayer.new()
	pLayContent:setLayoutSize(self.pMapSize.width, self.pMapSize.height)
  	self:addView(pLayContent, nContentZorder)
  	centerInView(self, pLayContent)
  	self.pLayContent = pLayContent

  	--玩家城池层
  	local pLayCityContent =  MUI.MLayer.new()
	pLayCityContent:setLayoutSize(self.pMapSize.width, self.pMapSize.height)
  	self.pLayContent:addView(pLayCityContent, nCityZorder)
  	centerInView(self.pLayContent, pLayCityContent)
  	self.pLayCityContent = pLayCityContent

  	--系统城池层
  	local pLaySysCityContent =  MUI.MLayer.new()
	pLaySysCityContent:setLayoutSize(self.pMapSize.width, self.pMapSize.height)
  	self.pLayContent:addView(pLaySysCityContent, nSySCityZorder)
  	centerInView(self.pLayContent, pLaySysCityContent)
  	self.pLaySysCityContent = pLaySysCityContent

  	--Boss层
  	local pLayBossContent =  MUI.MLayer.new()
	pLayBossContent:setLayoutSize(self.pMapSize.width, self.pMapSize.height)
  	self.pLayContent:addView(pLayBossContent, nBossZorder)
  	centerInView(self.pLayContent, pLayBossContent)
  	self.pLayBossContent = pLayBossContent

  	--TLBoss层
  	local pLayTLBossContent =  MUI.MLayer.new()
	pLayTLBossContent:setLayoutSize(self.pMapSize.width, self.pMapSize.height)
  	self.pLayContent:addView(pLayTLBossContent, nBossZorder)
  	centerInView(self.pLayContent, pLayTLBossContent)
  	self.pLayTLBossContent = pLayTLBossContent

	--创建线路层
	self.pBlockWarLine = BlockWarLine.new(self.pMapSize)
	pLayContent:addView(self.pBlockWarLine, nLineZorder)

	--当前点
	local pImgBlockLocal = MUI.MImage.new("#v1_img_weizhi.png")
	pImgBlockLocal:setAnchorPoint(0.5,0)
	pLayContent:addView(pImgBlockLocal, nLocalZorder)
	self.pImgBlockLocal = pImgBlockLocal

	--当前选中框位置
	local pImgViewLocal = MUI.MImage.new("#v1_img_quyukuang.png")
	pImgViewLocal:setAnchorPoint(0.5,0.5)
	pLayContent:addView(pImgViewLocal, nLocalZorder)
	self.pImgViewLocal = pImgViewLocal
end

--世界视图坐标转化为区域视图坐标
function BlockMapLayer:parseWorldToBlock( fX, fY)
	fX, fY = WorldFunc.parseWorldToBlock(self.pMapSize, fX, fY, true)
	if not fX then
		return 0,0
	end
	return fX, fY
end

function BlockMapLayer:updateViews(  )
	self:updateBg()
	self:updateMyPos()
	self:updateSysCityUiByBlockId()
	self:updateCityUiByBlockId()
	self:updateBossUiByBlockId()
end

--更新背景
function BlockMapLayer:updateBg( )
	--皇宫
	if self.nBlockId == nImperialCityMapId then
		--设置背景
		local sImg = "ui/bg_world/v1_img_quyutu2.png"
		if self.pImgBg then
			self.pImgBg:setCurrentImage(sImg)
		else
			self.pImgBg = MUI.MImage.new(sImg)
			local pSize = self.pImgBg:getContentSize()
			self.pImgBg:setPosition(pSize.width/2, pSize.height/2)
			self.pImgBg:setOpacity(self.nOpacity)
			self:addView(self.pImgBg)
		end
		
		--设置地图块
		if not self.pImgImperialBgs then
			self.pImgImperialBgs = {}
		else
			--隐藏所有
			if self.pImgImperialBgs then
				for k,v in pairs(self.pImgImperialBgs) do
                    local pImgBgs = v
					for k, v in pairs(pImgBgs) do
				        v:setVisible(true)
                    end
				end
			end
		end

		--创建精灵
		local tWorldCitys = getWorldCityDataByMapId(self.nBlockId)
		for i=1,#tWorldCitys do
			local tWorldCity = tWorldCitys[i]
			local nCountry = e_type_country.qunxiong
			--服务器数据
			local tBlockSCOI = Player:getWorldData():getBlockSCOI(self.nBlockId)
			if tBlockSCOI[tWorldCity.id] then
				nCountry = tBlockSCOI[tWorldCity.id].nCountry
			end
			--创建精灵
			local sImgPath = WorldFunc.getCountryBgImg(nCountry)
			local pImgBgs = self.pImgImperialBgs[tWorldCity.id]
			if not pImgBgs then                
                                             
				local pImgBgLT = MUI.MImage.new(sImgPath)
                pImgBgLT:getTexture():setAliasTexParameters() --抗锯齿
				self:addView(pImgBgLT)
                pImgBgLT:setScaleX(-1)
                pImgBgLT:setScaleY(-1)

                local pImgBgRT = MUI.MImage.new(sImgPath)
				self:addView(pImgBgRT)
                pImgBgRT:setScaleY(-1)

                local pImgBgLB = MUI.MImage.new(sImgPath)
				self:addView(pImgBgLB)
                pImgBgLB:setScaleX(-1)

                local pImgBgRB = MUI.MImage.new(sImgPath)
				self:addView(pImgBgRB)

                --位置
				local tPos = tBlockMapBgKingPos[tWorldCity.id]

                pImgBgs = {pImgBgLT, pImgBgRT, pImgBgLB, pImgBgRB}
                self.pImgImperialBgs[tWorldCity.id] = pImgBgs                                				
                for k, v in pairs(pImgBgs) do
				    if tPos then
				    	v:setPosition(tPos[1], tPos[2])
				    end
				    v:setOpacity(self.nOpacity)
                    v:setAnchorPoint(0, 1)
                end
			else
                for k, v in pairs(pImgBgs) do
				    v:setCurrentImage(sImgPath)
				    v:setVisible(true)
                end
			end
		end
	else
		--隐藏所有
		if self.pImgImperialBgs then
			for k, v in pairs(self.pImgImperialBgs) do
                local pImgBgs = v
                for k, v in pairs(pImgBgs) do
				    v:setVisible(false)
                end
			end
		end

		--普通区域
		--设置背景
		local sImg = "ui/bg_world/v1_img_quyutu1.png"
		if self.pImgBg then
			self.pImgBg:setCurrentImage(sImg)
		else
			self.pImgBg = MUI.MImage.new(sImg)
			local pSize = self.pImgBg:getContentSize()
			self.pImgBg:setPosition(pSize.width/2, pSize.height/2)
			self:addView(self.pImgBg)
			self.pImgBg:setOpacity(self.nOpacity)
		end
	end

	--更新行军线路
	self.pBlockWarLine:setBlockId(self.nBlockId)
end

-----------------------------------------------玩家城池
--玩家城池图片显示
function BlockMapLayer:showCity( tBlockDot )
	if not tBlockDot then
		return
	end

	local pImg = self.pImgCitys[tBlockDot.sDotKey]
	if not pImg then
		pImg = self:getImgCity()
		self.pImgCitys[tBlockDot.sDotKey] = pImg
	end

	local sMapIcon = getPlayerDotIcon(tBlockDot.nCityLv, tBlockDot.nCountry)
	-- 修改方法为sprite适用的方式
	pImg:setSpriteFrame(getSpriteFrameByName(sMapIcon, false))

	--设置大小
	WorldFunc.setPlayerDotImgScale(pImg, tBlockDot.nCityLv)
	local fX,fY = self:parseWorldToBlock(tBlockDot.tMapPos.x, tBlockDot.tMapPos.y)
	pImg:setPosition(fX, fY)

	return pImg
end

--获取玩家城池图片
--返回图片，是否新创建
function BlockMapLayer:getImgCity( )
	local pImg = nil
	local nCount = #self.pUnImgCitys
	if nCount > 0 then
		pImg = self.pUnImgCitys[nCount]
		table.remove(self.pUnImgCitys, nCount)
		pImg:setVisible(true)
	else
		-- 取消使用MImage的方法，直接使用sprite来代替
		pImg = display.newSprite("ui/daitu.png")
		self.pLayCityContent:addView(pImg)
	end
	return pImg
end

--隐藏所有城池图片
function BlockMapLayer:hideImgCitys( )
	for sDotKey, pImg in pairs(self.pImgCitys) do
		pImg:setVisible(false)
		self.pImgCitys[sDotKey] = nil
		table.insert(self.pUnImgCitys, pImg)
	end
	self.pImgCitys = {}
end

--隐藏玩家城池点
function BlockMapLayer:hideImgCity( sDotKey )
	local pImg = self.pImgCitys[sDotKey]
	if pImg then
		pImg:setVisible(false)
		self.pImgCitys[sDotKey] = nil
		table.insert(self.pUnImgCitys, pImg)
	end
end
-----------------------------------------------玩家城池

-----------------------------------------------系统城池
--系统城池图片显示
function BlockMapLayer:showSysCity( tWorldCity )
	if not tWorldCity then
		return
	end

	local nSysCityId = tWorldCity.id
	--获取
	local pSysCityDot = self.pImgSysCitys[nSysCityId]
	if not pSysCityDot then
		pSysCityDot = self:getImgSysCity()
		pSysCityDot:setSysCityId(nSysCityId)
		self.pImgSysCitys[nSysCityId] = pSysCityDot

		local fX,fY = self:parseWorldToBlock(tWorldCity.tMapPos.x, tWorldCity.tMapPos.y)
		
		local tfireTown = {
			[11182] = 15,
			[11183] = 15,
			[11184] = 15,
			[11185] = 15,
			[e_syscity_ids.EpangPalace] = 8,
		}
		local nOffsetX = tfireTown[nSysCityId] or 0
		pSysCityDot:setPosition(fX + nOffsetX, fY)
	end
	
	--服务器系统城池占领数据
	local tBlockSCOI = Player:getWorldData():getBlockSCOI(self.nBlockId)
	if tBlockSCOI[nSysCityId] then
		pSysCityDot:setData(tBlockSCOI[nSysCityId])
	end
	--服务器攻击系统城市数据
	if self.nViewType == e_view_type.normal then
		local tBlockCWOV = Player:getWorldData():getBlockCWOV(self.nBlockId)
		if tBlockCWOV[nSysCityId] then
			local tCountry = tBlockCWOV[nSysCityId].tCountry
			pSysCityDot:setBeAtkCountry(tCountry)
		end
	end
end

--获取系统城池图片
function BlockMapLayer:getImgSysCity(  )
	local nCount = #self.pUnImgSysCitys
	local pSysCityDot = nil
	if nCount > 0 then
		pSysCityDot = self.pUnImgSysCitys[nCount]
		pSysCityDot:setVisible(true)
		table.remove(self.pUnImgSysCitys, nCount)
	else
		pSysCityDot = BlockMapSysCityDot.new(self.nSceneArmType)
		if self.nViewType == e_view_type.world then
			pSysCityDot:getTxtName():setVisible(false)
		end
		self.pLaySysCityContent:addView(pSysCityDot)
	end
	return pSysCityDot
end

--隐藏所有系统城池图片
function BlockMapLayer:hideImgSysCitys( )
	for k, pImg in pairs(self.pImgSysCitys) do
		pImg:setVisible(false)
		self.pImgSysCitys[k] = nil
		table.insert(self.pUnImgSysCitys, pImg)
	end
	self.pImgSysCitys = {}
end

-----------------------------------------------系统城池

-----------------------------------------------Boss
--显示Boss
function BlockMapLayer:showBoss( tBossLocation )
	if not tBossLocation then
		return
	end

	local pImg = self.pImgBosses[tBossLocation.sDotKey]
	if not pImg then
		local sImg = WorldFunc.getWorldBossFlagFile(tBossLocation.nLv)
		pImg = self:getImgBoss(sImg)
		self.pImgBosses[tBossLocation.sDotKey] = pImg
	end

	local fWorldX,fWorldY = WorldFunc.getMapPosByDotPos(tBossLocation.nX, tBossLocation.nY)
	if fWorldX then
		local fX,fY = self:parseWorldToBlock(fWorldX, fWorldY)
		if fX then
			pImg:setPosition(fX, fY)

			--显示特效
			if self.nSceneArmType == Scene_arm_type.normal then
				if tBossLocation.bIsAtk then
					local pEffectList = self.pBossEffectes[tBossLocation.sDotKey]
					if pEffectList then
						for i=1,#pEffectList do
							pEffectList[i]:play(-1)
							pEffectList[i]:setVisible(true)
						end
					else
						pEffectList = self:getBossBeAttackEffect(cc.p(fX, fY), tBossLocation.nLv)
						self.pBossEffectes[tBossLocation.sDotKey] = pEffectList
					end
				else
					local pEffectList = self.pBossEffectes[tBossLocation.sDotKey]
					if pEffectList then
						for i=1,#pEffectList do
							pEffectList[i]:stop()
							pEffectList[i]:setVisible(false)
						end
					end
				end
				 	--todo 
			end
		end
	end
end

--获取Boss图片
function BlockMapLayer:getImgBoss( sImg )
	local pImg = nil
	local nCount = #self.pUnImgBosses
	if nCount > 0 then
		pImg = self.pUnImgBosses[nCount]
		table.remove(self.pUnImgBosses, nCount)
		pImg:setVisible(true)
		-- 修改方法为sprite适用的方式
		pImg:setSpriteFrame(getSpriteFrameByName(sImg, false))
	else
		-- 取消使用MImage的方法，直接使用sprite来代替
		pImg = display.newSprite(sImg)
		pImg:setScale(0.25)
		self.pLayBossContent:addView(pImg)
	end
	return pImg
end

--隐藏所有Boss图片
function BlockMapLayer:hideImgBosses( )
	for sDotKey, pImg in pairs(self.pImgBosses) do
		pImg:setVisible(false)
		self.pImgBosses[sDotKey] = nil
		table.insert(self.pUnImgBosses, pImg)
	end
	self.pImgBosses = {}
end

--隐藏Boss
function BlockMapLayer:hideImgBoss( sDotKey )
	local pImg = self.pImgBosses[sDotKey]
	if pImg then
		pImg:setVisible(false)
		self.pImgBosses[sDotKey] = nil
		table.insert(self.pUnImgBosses, pImg)
	end
end

--获取Boss发起攻击特效
function BlockMapLayer:getBossBeAttackEffect( pPos, nLv )
	local tArmData1 = nil
	local tArmData2 = nil
	if nLv == 2 then
		tArmData1 = EffectWorldDatas["bigSkull1"]
		tArmData2 = EffectWorldDatas["bigSkull2"]
	else
		tArmData1 = EffectWorldDatas["littleSkull1"]
		tArmData2 = EffectWorldDatas["littleSkull2"]
	end
	local pProtectArm1 = MArmatureUtils:createMArmature(tArmData1, 
		self.pLayBossContent, 
		2, 
		pPos,
	    function (  )
		end, Scene_arm_type.normal)
	pProtectArm1:play(-1)
	local pProtectArm2 = MArmatureUtils:createMArmature(tArmData2, 
		self.pLayBossContent, 
		2, 
		pPos,
	    function (  )
		end, Scene_arm_type.normal)
	pProtectArm2:play(-1)

	return {pProtectArm1, pProtectArm2}
end

-----------------------------------------------Boss


-----------------------------------------------TLBoss
--显示TLBoss
function BlockMapLayer:showTLBoss(  )
	local tPos = Player:getTLBossData():getBLocatVo(self.nBlockId)
	if not tPos then
		return
	end

	local pImg = self.pImgTLBoss
	if not pImg then
		-- 取消使用MImage的方法，直接使用sprite来代替
		pImg = display.newSprite("#v2_img_emobiaozhi2.png")
		pImg:setScale(0.25)
		self.pLayTLBossContent:addView(pImg)
		self.pImgTLBoss = pImg
	else
		self.pImgTLBoss:setVisible(true)
	end
	local fWorldX,fWorldY = WorldFunc.getMapPosByDotPos(tPos.nX, tPos.nY)
	if fWorldX then
		local fX,fY = self:parseWorldToBlock(fWorldX, fWorldY)
		if fX then
			pImg:setPosition(fX, fY)

			--显示特效
			if self.nSceneArmType == Scene_arm_type.normal then
				local nCdState = Player:getTLBossData():getCdState()
				if nCdState == e_tlboss_time.begin then
					local pEffectList = self.pBossEffectes[self.nBlockId]
					if pEffectList then
						for i=1,#pEffectList do
							pEffectList[i]:play(-1)
							pEffectList[i]:setVisible(true)
						end
					else
						pEffectList = self:getBossBeAttackEffect(cc.p(fX, fY), 2)
						self.pBossEffectes[self.nBlockId] = pEffectList
					end
				else
					local pEffectList = self.pBossEffectes[self.nBlockId]
					if pEffectList then
						for i=1,#pEffectList do
							pEffectList[i]:stop()
							pEffectList[i]:setVisible(false)
						end
					end
				end
			end
		end
	end
end

--隐藏所有TLBoss图片
function BlockMapLayer:hideImgTLBoss( )
	if self.pImgTLBoss then
		self.pImgTLBoss:setVisible(false)
	end
end

-----------------------------------------------TLBoss

-------------------------------------------------kingzhou
function BlockMapLayer:showKingZhou( tKingZhouLoction )
	-- body
	if not tKingZhouLoction then
		return
	end

	local pImg = self.pImgKingZhous[tKingZhouLoction.sDotKey]
	if not pImg then
		local sImg = WorldFunc.getWorldBossFlagFile(3)
		pImg = self:getImgKingZhou(sImg)
		self.pImgKingZhous[tKingZhouLoction.sDotKey] = pImg
	end

	local fWorldX,fWorldY = WorldFunc.getMapPosByDotPos(tKingZhouLoction.nX, tKingZhouLoction.nY)
	if fWorldX then
		local fX,fY = self:parseWorldToBlock(fWorldX, fWorldY)
		if fX then
			pImg:setPosition(fX, fY)

			--显示特效
			if self.nSceneArmType == Scene_arm_type.normal then
				local pEffectList = self.pBossEffectes[tKingZhouLoction.sDotKey]
				if pEffectList then
					for i=1,#pEffectList do
						pEffectList[i]:play(-1)
						pEffectList[i]:setVisible(true)
					end
				else
					pEffectList = self:getBossBeAttackEffect(cc.p(fX, fY), tKingZhouLoction.nLv)
					self.pBossEffectes[tKingZhouLoction.sDotKey] = pEffectList
				end
			end
		end
	end
end

--获取纣王图片
function BlockMapLayer:getImgKingZhou( sImg )
	local pImg = nil
	local nCount = #self.pUnImgKingZhous
	if nCount > 0 then
		pImg = self.pUnImgKingZhous[nCount]
		table.remove(self.pUnImgKingZhous, nCount)
		pImg:setVisible(true)
		-- 修改方法为sprite适用的方式
		pImg:setSpriteFrame(getSpriteFrameByName(sImg, false))
	else
		-- 取消使用MImage的方法，直接使用sprite来代替
		pImg = display.newSprite(sImg)
		pImg:setScale(0.25)
		self.pLayBossContent:addView(pImg)
	end
	return pImg
end

--隐藏所有纣王图片
function BlockMapLayer:hideImgKingZhous( )
	for sDotKey, pImg in pairs(self.pImgKingZhous) do
		pImg:setVisible(false)
		self.pImgKingZhous[sDotKey] = nil
		table.insert(self.pUnImgKingZhous, pImg)
		local pEffectList = self.pBossEffectes[sDotKey]
		if pEffectList then
			for i=1,#pEffectList do
				pEffectList[i]:stop()
				pEffectList[i]:setVisible(false)
			end
		end
	end
	self.pImgKingZhous = {}
end

--隐藏纣王
function BlockMapLayer:hideImgKingZhou( sDotKey )
	local pImg = self.pImgKingZhous[sDotKey]
	if pImg then
		pImg:setVisible(false)
		self.pImgKingZhous[sDotKey] = nil
		table.insert(self.pUnImgBosses, pImg)
	end
	local pEffectList = self.pBossEffectes[sDotKey]
	if pEffectList then
		for i=1,#pEffectList do
			pEffectList[i]:stop()
			pEffectList[i]:setVisible(false)
		end
	end	
end

-------------------------------------------------kingzhou

--隐藏格子点(搜索周围视图点3008,消失的视图点）
function BlockMapLayer:hideGridBySearchAround( tNullGrid )
	for k,sDotKey in pairs(tNullGrid) do
		--隐藏玩家
		self:hideImgCity(sDotKey)
		--隐藏Boss
		self:hideImgBoss(sDotKey)
		--隐藏纣王
		self:hideImgKingZhou(sDotKey)
	end
end

--更新玩家城池信息(搜索周围视图点3008,发生变化或新增的视图点)
function BlockMapLayer:updateImgCityBySearchAround( tBlockDots )
	for k,tBlockDot in pairs(tBlockDots) do
		self:showCity(tBlockDot)
	end
end

--更新Boss信息(搜索周围视图点3008,发生变化或新增的视图点)
function BlockMapLayer:updateImgBossBySearchAround( tBlockDots )
	for k,tBossLocation in pairs(tBlockDots) do
		self:showBoss(tBossLocation)
	end
end

--更新纣王信息(搜索周围视图点3008,发生变化或新增的视图点)
function BlockMapLayer:updateImgZhouBySearchAround( tBlockDots )
	for k,tKingZhouLoction in pairs(tBlockDots) do
		self:showKingZhou(tKingZhouLoction)
	end
end

--更新TLBoss信息
function BlockMapLayer:updateImgTLBoss(  )
	local nState = Player:getTLBossData():getCdState()
	if nState == e_tlboss_time.no then
		self:hideImgTLBoss()
	else
		local tPos = Player:getTLBossData():getBLocatVo(self.nBlockId)
		if tPos then
			self:showTLBoss()
		else
			self:hideImgTLBoss()
		end
	end
end

--更新系统城池
function BlockMapLayer:updateSysCityUiByBlockId( bIsRefresh )
	--未开放区域显示
	if not self.nBlockId then
		self.pLaySysCityContent:setVisible(false)
		return
	end

	--存在数据才进行刷新
	if not Player:getWorldData():isBlockDataExist(self.nBlockId) then
		self.pLaySysCityContent:setVisible(false)
		return
	end

	self.pLaySysCityContent:setVisible(true)

	--如果不同的区域id(切换区域时会触发)
	if self.nUpdateSysCityBlockId ~= self.nBlockId or bIsRefresh then
		self.nUpdateSysCityBlockId = self.nBlockId
		--先隐藏全部
		self:hideImgSysCitys()
		--创建系统城池精灵
		local tWorldCitys = getWorldCityDataByMapId(self.nBlockId)
		for k,tWorldCity in pairs(tWorldCitys) do
			self:showSysCity(tWorldCity)
		end
	end
end

--更新玩家城池视图点
function BlockMapLayer:updateCityUiByBlockId( bIsRefresh )
	if not self.nBlockId then
		self.pLayCityContent:setVisible(false)
		return
	end

	--存在数据才进行刷新
	if not Player:getWorldData():isBlockDataExist(self.nBlockId) then
		self.pLayCityContent:setVisible(false)
		return
	end

	local bIsShow = true
	if self.bIsHidePlayer then
		bIsShow = false
	end
	self.pLayCityContent:setVisible(bIsShow)

	--如果不同的区域id(切换区域时会触发)
	if self.nUpdateCityUiBlockId ~= self.nBlockId or bIsRefresh then
		self.nUpdateCityUiBlockId = self.nBlockId
	
		--先隐藏全部
		self:hideImgCitys()
		
		--直接显示
		local tDots = Player:getWorldData():getBlockDots(self.nBlockId)
		for k,tDot in pairs(tDots) do
			self:showCity(tDot)
		end
	end
end

--更新玩家城池视图点
function BlockMapLayer:updateBossUiByBlockId( bIsRefresh )
	if not self.nBlockId then
		self.pLayBossContent:setVisible(false)
		return
	end

	--存在数据才进行刷新
	if not Player:getWorldData():isBlockDataExist(self.nBlockId) then
		self.pLayBossContent:setVisible(false)
		return
	end

	--如果不同的区域id(切换区域时会触发)
	if self.nUpdateBossUiBlockId ~= self.nBlockId or bIsRefresh then
		self.nUpdateBossUiBlockId = self.nBlockId
		
		self.pLayBossContent:setVisible(true)

		--先隐藏全部
		self:hideImgBosses()
		self:hideImgKingZhous()
		--直接显示
		local tDots = Player:getWorldData():getBlockBoss(self.nBlockId)
		for k,tBossLocation in pairs(tDots) do
			self:showBoss(tBossLocation)
		end		
		--直接显示
		local tDots = Player:getWorldData():getBlockKingZhou(self.nBlockId)
		for k,tKingZhouLoction in pairs(tDots) do
			self:showKingZhou(tKingZhouLoction)
		end		
		--更新TLBoss
		self:updateImgTLBoss()
	end
end

--更新我的定位数据
function BlockMapLayer:updateMyPos( )
	if not self.nBlockId then
		self.pImgBlockLocal:setVisible(false)
		self.pImgViewLocal:setVisible(false)
		return
	end
	
	--显示我的坐标
	local fX, fY = self:getMyBlockPos()
	if fX then
		self.pImgBlockLocal:setPosition(fX, fY-7)
		self.pImgBlockLocal:setVisible(true)
	else
		self.pImgBlockLocal:setVisible(false)
	end

	--显示我的视图中心点
	if self.fViewCX and self.fViewCY then
		local fX, fY = self:parseWorldToBlock( self.fViewCX, self.fViewCY)
		if fX then
			self.pImgViewLocal:setPosition(fX, fY)
			self.pImgViewLocal:setVisible(true)
		else
			self.pImgViewLocal:setVisible(false)
		end
	else
		self.pImgViewLocal:setVisible(false)
	end
end

--获取自己在区域中的位置
function BlockMapLayer:getMyBlockPos(  )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	if nBlockId then
		if self.nBlockId == nBlockId then
			local fWorldX,fWorldY = WorldFunc.getMapPosByDotPos(nX, nY)
			if fWorldX then
				return self:parseWorldToBlock( fWorldX, fWorldY)
			end
		end
	end
end

--更新区域点信息
function BlockMapLayer:updateBlockDots()
	if not self.nBlockId then
		return
	end
	--更新系统城池背景
	self:updateBg()
	--更新系统城池
	self:updateSysCityUiByBlockId(true)
	--更新玩家城池
	self:updateCityUiByBlockId(true)
	--更新Boss
	self:updateBossUiByBlockId(true)
end

--更新系统城池视图点(系统城池发生改变)
function BlockMapLayer:updateBlockSysCityDots( tBlockSysCityDots )
	if not self.nBlockId then
		return
	end

	--服务器攻击系统城市数据
	local tBlockCWOV = Player:getWorldData():getBlockCWOV(self.nBlockId)

	--更新背景(阿房宫)
	self:updateBg()

	for i=1,#tBlockSysCityDots do
		--服务器系统城池占领数据
		local tBlockSCOI = tBlockSysCityDots[i]
		local nSysCityId = tBlockSCOI.nId
		--更新系统城池
		local pSysCityDot = self.pImgSysCitys[nSysCityId]
		if pSysCityDot then
			--服务器系统城池占领数据
			local tData = tBlockSCOI
			if tData then
				pSysCityDot:setData(tData)
			end

			if self.nViewType == e_view_type.normal then
				--服务器攻击系统城市数据
				local tData2 = tBlockCWOV[nSysCityId]
				if tData2 then
					pSysCityDot:setBeAtkCountry(tData2.tCountry)
				end
			end
		end
	end
end

--更新城池占领数据
function BlockMapLayer:updateBlockSysCitySCOI( nSysCityId )
	if not self.nBlockId then
		return
	end
	--更新系统城池
	local pSysCityDot = self.pImgSysCitys[nSysCityId]
	if pSysCityDot then
		--更新背景(阿房宫)
		self:updateBg()
		--服务器系统城池占领数据
		local tBlockSCOI = Player:getWorldData():getBlockSCOI(self.nBlockId)
		local tData = tBlockSCOI[nSysCityId]
		if tData then
			--更新数据
			pSysCityDot:setData(tData)
		end
	end
end


--更新系统城池视图点
function BlockMapLayer:updateBlockSysCityCWOV( )
	if not self.nBlockId then
		return
	end
	--服务器攻击系统城市数据
	if self.nViewType == e_view_type.normal then
		local tBlockCWOV = Player:getWorldData():getBlockCWOV(self.nBlockId)
		for nSysCityId, tData in pairs(tBlockCWOV) do
			local pSysCityDot = self.pImgSysCitys[nSysCityId]
			if pSysCityDot then
				pSysCityDot:setBeAtkCountry(tData.tCountry)
			end
		end
	end
end

--设置数据
function BlockMapLayer:setData( nBlockId, fViewCX, fViewCY)
	self.nBlockId = nBlockId
	self.fViewCX = fViewCX 
	self.fViewCY = fViewCY
	self:updateViews()
end

--设置不显示
function BlockMapLayer:setHidePlayer( bIsHide )
	self.bIsHidePlayer = bIsHide
	local bIsShow = true
	if self.bIsHidePlayer then
		bIsShow = false
	end
	self.pLayCityContent:setVisible(bIsShow)
end

function BlockMapLayer:parseBlockToWorld( fX, fY)
	if not self.nBlockId then
		return nil
	end

	return WorldFunc.parseBlockToWorld(self.nBlockId, self.pMapSize, fX, fY)
end

--获取是否有点击到点
function BlockMapLayer:getClickedCityDot( _nClickedX, _nClikedY )
	--容错
	if not self.nBlockId then
		return nil
	end


	--转成世界坐标
	local fWorldX, fWorldY = self:parseBlockToWorld(_nClickedX, _nClikedY)
	if not fWorldX then
		return
	end
	--获取世界位置在区域中的位置
	nClickedX, nClikedY = self:parseWorldToBlock(fWorldX, fWorldY)
	if not nClickedX then
		return
	end
	local pClickPos = cc.p(nClickedX, nClikedY)

	local tPosList = {}
	--更新的位置
	local tPos = nil
	--遍历系统城池
	for k,pSysCityDot in pairs(self.pImgSysCitys) do
		local fX1, fY1 = pSysCityDot:getPosition()
		local pSize = pSysCityDot:getContentSize()
		local pAnchorPos =  pSysCityDot:getAnchorPoint()
		fX1 = fX1 - pSize.width * pAnchorPos.x
		fY1 = fY1 - pSize.height * pAnchorPos.y
		local fX2, fY2 = pSysCityDot:getLayImgCity():getPosition()
		local fX3, fY3 = pSysCityDot:getImgCity():getPosition()
		local pRect = pSysCityDot:getImgCity():getBoundingBox()
		local fX = fX1 + fX2 + fX3
		local fY = fY1 + fY2 + fY3
		pRect.x = fX - pRect.width/2
		pRect.y = fY - pRect.height/2

		if cc.rectContainsPoint(pRect, pClickPos) then
			tPos = {x = fX, y = fY, nSysCityId = pSysCityDot.nSysCityId}
			table.insert(tPosList, tPos)
			break
		end
	end

	--遍历玩家城池
	local nOffset = 30 --容错值
	local nMinDes2 = nil
	local key = nil
	for k,v in pairs(self.pImgCitys) do
		local nX, nY = v:getPosition()
		local nCurrDes = cc.pGetDistance(cc.p(nX, nY), pClickPos)
		if nMinDes2 then
			if nMinDes2 > nCurrDes then
				nMinDes2 = nCurrDes
				key = k
			end
		else
			nMinDes2 = nCurrDes
			key = k
		end
	end
	local tPos2 = nil
	if nMinDes2 and nMinDes2 <= nOffset and key then
		local fX, fY = self.pImgCitys[key]:getPosition()
		tPos2 = {x = fX, y = fY}
		table.insert(tPosList, tPos2)
	end

	--遍历Boss的点
	local nOffset = 20 --容错值
	local nMinDes3 = nil
	local key = nil
	for k,v in pairs(self.pImgBosses) do
		local nX, nY = v:getPosition()
		local nCurrDes = cc.pGetDistance(cc.p(nX, nY), pClickPos)
		if nMinDes3 then
			if nMinDes3 > nCurrDes then
				nMinDes3 = nCurrDes
				key = k
			end
		else
			nMinDes3 = nCurrDes
			key = k
		end
	end
	local tPos3 = nil
	if nMinDes3 and nMinDes3 <= nOffset and key then
		local fX, fY = self.pImgBosses[key]:getPosition()
		tPos3 = {x = fX, y = fY}
		table.insert(tPosList, tPos3)
	end

	--遍历限时Boss的点
	local nOffset = 20 --容错值
	if self.pImgTLBoss and self.pImgTLBoss:isVisible() then
		local fX, fY = self.pImgTLBoss:getPosition()
		local nCurrDes = cc.pGetDistance(cc.p(fX, fY), pClickPos)
		if nOffset > nCurrDes then
			table.insert(tPosList, {x = fX, y = fY})
		end
		-- print("DDDDDDDDDDDDDDDDDDDDDDDDDDDD")
		-- return fWorldX2,fWorldY2
	end
	--遍历纣王的点
	local nOffset = 20 --容错值
	local nMinDes3 = nil
	local key = nil
	for k,v in pairs(self.pImgKingZhous) do
		local nX, nY = v:getPosition()
		local nCurrDes = cc.pGetDistance(cc.p(nX, nY), pClickPos)
		if nMinDes3 then
			if nMinDes3 > nCurrDes then
				nMinDes3 = nCurrDes
				key = k
			end
		else
			nMinDes3 = nCurrDes
			key = k
		end
	end
	local tPos3 = nil
	if nMinDes3 and nMinDes3 <= nOffset and key then
		local fX, fY = self.pImgKingZhous[key]:getPosition()
		tPos3 = {x = fX, y = fY}
		table.insert(tPosList, tPos3)
	end	

	--比较得最优点
	local tBestPos = nil
	for i=1,#tPosList do
		if tBestPos then
			local nCurrDes1 = cc.pGetDistance(cc.p(tPosList[i].x, tPosList[i].y), pClickPos)
			local nCurrDes2 = cc.pGetDistance(cc.p(tBestPos.x, tBestPos.y), pClickPos)
			if nCurrDes1 < nCurrDes2 then
				tBestPos = tPosList[i]
			end
		else
			tBestPos = tPosList[i]
		end
	end
	--
	if tBestPos then
		local nSysCityId = tBestPos.nSysCityId
		if nSysCityId then
			local tCityData = getWorldCityDataById(nSysCityId)
			if tCityData then
				return tCityData.tMapPos.x, tCityData.tMapPos.y
			end
		end
		return WorldFunc.parseBlockToWorld(self.nBlockId, self.pMapSize, tBestPos.x, tBestPos.y)
	end
	
	return nil
end

return BlockMapLayer


