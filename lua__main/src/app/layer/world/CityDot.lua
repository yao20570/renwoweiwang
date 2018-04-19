----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-07 09:42:59
-- Description: 地图上的玩家城池
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
--层次
local nProtectZorderBg = 0
local nProtectZorder = 3
local nLvBgZorder = 4
local nCallUiZorder = 5
local nPaperZorder = 1
local nPaperCdZorder = 1
local nWarZorder = 2
local nNameZorder = 109
local nPosZ = 1
local nCityZorder = 1
local nShowYAdd = 8
local nShowYAdd2 = 10
local n3dOffsetY = -24
local n3dOffsetZ = 30
local nSwordArmZorder = 10

--玩家城池类
local CityDot = class("CityDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
--pImgCity 视图点图片（减少drawcall）
function CityDot:ctor( pWorldLayer, pImgCity, pClickNode)
	self.pWorldLayer = pWorldLayer
	self.pImgCity = pImgCity
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgCity)

	self.pPrevImgCitySize = cc.p(0, 0)
	--解析文件
	self:onParseViewCallback()
end

--解析界面回调
function CityDot:onParseViewCallback(  )
	self:setContentSize(cc.size(UNIT_WIDTH, UNIT_HEIGHT))
	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("CityDot",handler(self, self.onCityDotDestroy))
end

function CityDot:onCityDotDestroy(  )
	self:onPause()
	if self.nArmSchedule then
	    MUI.scheduler.unscheduleGlobal(self.nArmSchedule)
	    self.nArmSchedule = nil
	end
end

function CityDot:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function CityDot:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function CityDot:regMsgs( )
	-- regMsg(self, ghd_city_protect_effect_test, handler(self, self.onEffectTest))
end

function CityDot:unregMsgs( )
	-- unregMsg(self, ghd_city_protect_effect_test)
end

function CityDot:onEffectTest( )
	self.bEffectTest = true
end

function CityDot:setupViews(  )
	-- --城池
	-- --BillBorad
	-- self.pImgCity = WorldFunc.getCityIconOfContainer(self, e_type_country.shuguo, 1, nil)
	-- self.pImgCity:setZOrder(nCityZorder)
	-- --位置Y轴微调
	-- self.pImgCity:setPositionY(self.pImgCity:getPositionY() + nShowYAdd)

	--创建名字
	self.pTxtName = MUI.MLabel.new({text = "1", size = 20})
	self.pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	-- setTextCCColor(self.pTxtName, _cc.lwhite)

	self:addChild(self.pTxtName, nNameZorder)

	--创建等级
	self.pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	self.pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	setTextCCColor(self.pTxtLv, _cc.lwhite)

	self:addChild(self.pTxtLv, nNameZorder)

	--创建背景
	self.pLayLvBg = MUI.MLayer.new()
	self.pLayLvBg:setLayoutSize(self:getContentSize())
	self:addChild(self.pLayLvBg, nLvBgZorder)

	--创建一个名字背景框
	self.pBbNameBg = createCCBillBorad("ui/daitu.png")
	self.pBbNameBg:setPosition3D(cc.vec3(self.pBbNameBg:getContentSize().width / 2 + 15, 14, 0))
	self.pLayLvBg:addChild(self.pBbNameBg,100)

	--创建一个等级背景框
	self.pBbLvBg = createCCBillBorad("#v1_img_dengjidi3c.png")
	self.pBbLvBg:setPosition3D(cc.vec3(self.pBbLvBg:getContentSize().width / 2, 14, 1))
	self.pLayLvBg:addChild(self.pBbLvBg,100)

	--随便设置一个设置 只为了获取texture
	self.pTxtName:setString("1")
	self.pTxtName:updateContent()
	--随便设置一个设置 只为了获取texture
	self.pTxtLv:setString("1")
	self.pTxtLv:updateContent()
	--获取所有的子节点
	local tChildrens = self.pTxtName:getChildren()
	local tChildrens2 = self.pTxtLv:getChildren()

	if(tChildrens[1]) then
	    local texture = tChildrens[1]:getTexture()
	    --名字
	    self.pBbName = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbName:setPosition3D(cc.vec3(self.pBbName:getContentSize().width / 2 + 15 + 10 , 14, 1))
	    self.pBbNameBg:addChild(self.pBbName,20)
	end
	if(tChildrens2[1]) then
	    local texture = tChildrens2[1]:getTexture()
	    --等级
	    self.pBbLv = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbLv:setPosition3D(cc.vec3(18, 18, 1))
	    self.pBbLvBg:addChild(self.pBbLv,20)
	end

	--设置层大小
	self.pClickNode:setLayoutSize(self:getContentSize())

	--召唤
	self.pImgCall = createCCBillBorad("#v1_ing_zjm_gndi.png")
	self.pImgCall:setScale(0.7)
	self:addChild(self.pImgCall, nPaperZorder)
	self.pImgCallIcon = createCCBillBorad("#v1_fonts_zh.png")
	self.pImgCallIcon:setScale(0.7)
	self:addChild(self.pImgCallIcon, nPaperZorder)
	-- --召唤文字
	-- self.pTxtName:setString("")
	-- self.pTxtName:updateContent()
	-- local tChildrens = self.pTxtName:getChildren()
 --    local texture = tChildrens[1]:getTexture()
 --    self.pBbCallTxt = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
 --    self:addChild(self.pBbCallTxt, nPaperZorder)

	--召唤点击
	local nClickW, nClickH = 70, 80
	self.pLayCallClick = MUI.MLayer.new()
	self.pLayCallClick:setContentSize(nClickW, nClickH)
	self.pLayCallClick:setAnchorPoint(0.5, 0.5)
	self:addChild(self.pLayCallClick, nPaperZorder)
	
	--显示调试
	-- local pLayCallClickColor = display.newColorLayer(cc.c4b(255, 0, 0, 255))
	-- pLayCallClickColor:setTouchEnabled(false)
	-- pLayCallClickColor:setContentSize(nClickW, nClickH)
	-- self.pLayCallClick:addView(pLayCallClickColor)


	-- --城战
	-- self.pImgWar = createCCBillBorad("#v1_ing_zjm_gndi2.png")
	-- self:addChild(self.pImgWar, nWarZorder)
	-- self.pImgWar:setScale(0.45)
	-- self.pImgWarIcon = createCCBillBorad("#v1_btn_guozhan2.png")
	-- self:addChild(self.pImgWarIcon, nWarZorder)
 --   	self.pImgWarIcon:setScale(0.75)

	-- --城战位置
	-- local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
	-- self.pImgWar:setPosition3D(cc.vec3(fX, fY - 2, nPosZ))
	-- self.pImgWarIcon:setPosition3D(cc.vec3(fX, fY - 3, nPosZ + 1))

	--召唤cd条
	local pLayBarCd = MUI.MLayer.new()
	pLayBarCd:setContentSize(132,26)
	pLayBarCd:setBackgroundImage("ui/bar/v1_bar_bscd.png")
	self:addChild(pLayBarCd, nPaperCdZorder)
	self.pLayBarCd = pLayBarCd
	-- local fX, fY = 181/2 - 10, -self.pLayBarCd:getContentSize().height
	-- self.pLayBarCd:setPosition(fX - 20, fY)
	local fX, fY = UNIT_WIDTH/2+30 - 78, -self.pLayBarCd:getContentSize().height
	self.pLayBarCd:setPosition(fX, fY)

	self.pCallCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/update_bin/v1_ball.png",
		    	barfg="ui/bar/v1_bar_blue_sc.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(124, 16)
		    :align(display.LEFT_BOTTOM)
    --设置为不可触摸
    self.pCallCdBar:setViewTouched(false)
	pLayBarCd:addView(self.pCallCdBar, 10)
	local nX, nY = self.pCallCdBar:getPosition()
	self.pCallCdBar:setPosition(nX+1, nY+5)
	
	--图标
	local pImgLevy = createCCBillBorad("#v1_img_zhaohuanxiao.png")
	pImgLevy:setPosition(-pImgLevy:getContentSize().width/2, 10)
	pLayBarCd:addChild(pImgLevy)

	--随便设置一个设置 只为了获取texture
	self.pTxtCallCd = MUI.MLabel.new({text = "1", size = 18})
	self.pTxtCallCd:setVisible(false)
	self:addChild(self.pTxtCallCd, nPaperCdZorder)
	--获取所有的子节点
	self.pTxtCallCd:updateContent()
	local tChildrens = self.pTxtCallCd:getChildren()
	if(tChildrens[1]) then
	    local texture = tChildrens[1]:getTexture()
	    self.pBbCallCd = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbCallCd:setPosition(pLayBarCd:getContentSize().width/2 - self.pBbCallCd:getContentSize().width / 2 + 15 + 5, 11)
	    self.pLayBarCd:addChild(self.pBbCallCd,20)
	end

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--更新cd
function CityDot:updateCd( )
	self:updateProtectCd()
	self:updateCallCd()
end


--设置服务器数据
--tData:服务器发过来的数据
function CityDot:setData( tData )
	self.tData = tData
	self.bEffectTest = nil
	self:updateViews( )
	--更新
	self:updateCd()
end

--获取数据
function CityDot:getData(  )
	return self.tData
end

--获取城池id
function CityDot:getId( )
	if self.tData then
		return self.tData.nCityId
	end
	return nil
end

--获取是否是自己
function CityDot:getIsMe()
	if not self.tData then
		return
	end
	return self.tData:getIsMe()
end

--更新
function CityDot:updateViews(  )
	if not self.tData then
		return
	end

	local sName = self.tData:getDotName()
	local nLv = self.tData:getDotLv()
	local nCountry = self.tData:getDotCountry()

	--名字显示
	if self.sName ~= sName then
		self.sName = sName

		local tStr = {
			{color = getColorByCountry(nCountry), text = getCountryShortName(nCountry, true)},
			{color = _cc.lwhite, text = tostring(sName)}
		}

		--设置内容
		self.pTxtName:setString(tStr, false)

		--强制渲染一下
		self.pTxtName:updateContent()
		local tChildrens = self.pTxtName:getChildren()
		if(tChildrens[1]) then
		    local pTexture = tChildrens[1]:getTexture()
		    self.pBbName:setTexture(pTexture)
		    --重新设置一下大小
		    self.pBbName:setTextureRect(cc.rect(0,0,self.pTxtName:getContentSize().width,self.pTxtName:getContentSize().height))
    	    --设置位置
        	self.pBbName:setPositionX(self.pBbName:getContentSize().width / 2 + 15 + 18)
		end

		--更新等级背景大小
		WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pBbName:getContentSize().width)
		local nSpace=10
		-- if self.pBbName:getContentSize().width >= 136 then
		-- 	nSpace = 0
		-- end
		local nBgW = self.pBbNameBg:getContentSize().width
		self.pBbNameBg:setPositionX(nBgW / 2 +nSpace)
		--动态设置名字登记位置
		local nAllW = nBgW + 10
		local nX = (UNIT_WIDTH - nAllW) / 2
		self.pLayLvBg:setPositionX(nX - 5)
		
	end
	self:setNameVisible(true)

	--防止重复刷新
	if self.nLevel ~= nLv or self.nCountry ~= nCountry then
		if self.nLevel ~= nLv then
			--设置内容
			self.pTxtLv:setString(nLv, false)
			--强制渲染一下
			self.pTxtLv:updateContent()
			local tChildrens = self.pTxtLv:getChildren()
			if(tChildrens[1]) then
			    local pTexture = tChildrens[1]:getTexture()
			    self.pBbLv:setTexture(pTexture)
			    --重新设置一下大小
			    self.pBbLv:setTextureRect(cc.rect(0,0,self.pTxtLv:getContentSize().width,self.pTxtLv:getContentSize().height))
			end
		end
		self.nLevel = nLv
		self.nCountry = nCountry
		--图标
		local sImgPath = getPlayerCityIcon(nLv, nCountry)
		if sImgPath then
			self.pImgCity:setCurrentImage(sImgPath)
		end
	end

	--防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY
		--更新坐标
		local fX, fY = self.pWorldLayer:getMapPosByDotPos(self.tData.nX,self.tData.nY)
		self:setPosition(fX, fY)

		--图片位置
		self.pImgCity:setPosition(fX, fY + nShowYAdd)

		self.pClickNode:setPosition(fX, fY)
	end

	--更新城池UI
	self:updateCityUi()

	--进击特效显示
	self:updateAtkEffect()
end

--获取DotKey
function CityDot:getDotKey(  )
	if not self.tData then
		return
	end
	return self.tData.sDotKey
end

function CityDot:onMyCityChange( )
	if not self.tData then
		return
	end
	if self.tData:getIsMe() then
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		self.tData = Player:getWorldData():getViewDotMsg(nX, nY)
		self:updateViews()
	end
end

--更新是否显示进攻特效
function CityDot:updateAtkEffect(  )
	if not self.tData then
		return
	end

	local bIsShowAtkEffect = Player:getWorldData():getViewDotIsShowAtkEffect(self.tData.nX, self.tData.nY)
	if self.bIsShowAtkEffect ~= bIsShowAtkEffect then
		self.bIsShowAtkEffect = bIsShowAtkEffect
		if self.bIsShowAtkEffect then
			-- if not self.pArmActions then
			-- 	local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
			-- 	self.pArmActions = WorldFunc.getViewDotAtkEffect(self, fX, fY, 0)
			-- 	for i=1,#self.pArmActions do
			-- 		WorldFunc.setCameraMaskForView(self.pArmActions[i])
			-- 	end
			-- end

			if not self.pArmActions then
				self.pArmActions = WorldFunc.getViewDotAtkEffect(self.pClickNode, 0, 0, 0, 0.8)
				for i=1,#self.pArmActions do
					self.pArmActions[i]:setOpacity(0)
					WorldFunc.setCameraMaskForView(self.pArmActions[i])
				end

				--5侦后执行显示
				gRefreshViewsAsync(self, 5, function ( _bEnd, _index )
					if _bEnd then
						for i=1,#self.pArmActions do
							self.pArmActions[i]:setOpacity(255)
						end
					end
				end)
			end
			--循环动画整体缩放值
			self.pClickNode:setVisible(true)
			self.pClickNode:stopAllActions()
			self.pClickNode:setOpacity(0)
			self.pClickNode:setScale(1.5)
			--动画
			if self.pArmActions then
				for i=1,#self.pArmActions do
					self.pArmActions[i]:setVisible(true)
					self.pArmActions[i]:play(-1)
				end
			end
			--动作
			local pSeqAct = cc.Sequence:create({
				cc.Spawn:create({
					cc.FadeIn:create(0.3),
					cc.ScaleTo:create(0.3, 1),
				}),
			})
			self.pClickNode:runAction(pSeqAct)
		else
			-- if self.pArmActions then
			-- 	for i=1,#self.pArmActions do
			-- 		self.pArmActions[i]:stop()
			-- 		MArmatureUtils:removeMArmature(self.pArmActions[i])
			-- 	end
			-- 	self.pArmActions = nil
			-- end
			if self.pArmActions then
				for i=1,#self.pArmActions do
					self.pArmActions[i]:stop()
					self.pArmActions[i]:setVisible(false)
				end
			end
			self.pClickNode:setVisible(false)
		end
	end
end

--更新保护cd时间
function CityDot:updateProtectCd(  )
	if self.tData then
		local nProtectCd = self.tData:getPlayerProtectCd()
		if nProtectCd > 0 or self.bEffectTest then
			if not self.pLayBack or not self.pLayFront then
				local pSize = self:getContentSize()
				self.pLayBack = MUI.MLayer.new()
				self.pLayBack:setLayoutSize(pSize)
				self:addView(self.pLayBack, nProtectZorderBg)
				
				self.pLayFront = MUI.MLayer.new()
				self.pLayFront:setLayoutSize(pSize)
				self:addView(self.pLayFront, nProtectZorder)
				
				self.pArmList, self.nArmSchedule = WorldFunc.setCityProtectArms(self.pLayBack, self.pLayFront)

				--位置Y轴微调
				self.pLayBack:setPosition(pSize.width/2, pSize.height/2 + nShowYAdd2)
				self.pLayFront:setPosition(pSize.width/2, pSize.height/2 + nShowYAdd2)

				self.pLayBack:setScale(0.42)
				self.pLayFront:setScale(0.42)

				WorldFunc.setCameraMaskForView(self.pLayBack)
				WorldFunc.setCameraMaskForView(self.pLayFront)
			else
				self.pLayBack:setVisible(true)
				self.pLayFront:setVisible(true)
				if self.pArmList then
					for i=1,#self.pArmList do
						self.pArmList[i]:setVisible(true)
					end
				end
			end
		else
			--隐藏cd
			if self.pLayBack then
				self.pLayBack:setVisible(false)
			end
			if self.pLayFront then 
				self.pLayFront:setVisible(false)
			end
			if self.pArmList then
				for i=1,#self.pArmList do
					self.pArmList[i]:setVisible(false)
				end
			end
		end
	else
		--隐藏cd
		if self.pLayBack then
			self.pLayBack:setVisible(false)
		end
		if self.pLayFront then 
			self.pLayFront:setVisible(false)
		end
		if self.pArmList then
			for i=1,#self.pArmList do
				self.pArmList[i]:setVisible(false)
			end
		end
	end
end

-------------------------------更新玩家城池Ui-----------------------------
--更新城池Ui
function CityDot:updateCityUi()
	if not self.tData then
		return
	end

	--是否强制隐藏Ui
	if self.bIsHideByClickLayer then
		return
	end

	if self.pImgCity then
		--更新大小
		local pSize = self.pImgCity:getContentSize()
		if self.pPrevImgCitySize.width ~= pSize.width or 
			self.pPrevImgCitySize.height ~= pSize.height then
			self.pPrevImgCitySize = pSize

			--召唤位置
			local fX, fY = self:getContentSize().width/2, pSize.height/2 + 100
			self.pImgCall:setPosition3D(cc.vec3(fX, fY + n3dOffsetY, nPosZ + n3dOffsetZ))
			self.pImgCallIcon:setPosition3D(cc.vec3(fX, fY - 1 + n3dOffsetY, nPosZ + n3dOffsetZ + 1))
			-- self.pBbCallTxt:setPosition3D(cc.vec3(fX, fY - 1 + n3dOffsetY - 20, nPosZ + n3dOffsetZ + 4))

			self.pLayCallClick:setPosition(fX , fY - 20)
		end
	end

	-- if self.tData:getIsMe() then
	-- 	dump(self.tData,"myCitydata")
	-- end

	--显示城战
	if self.tData then
		if self.tData.bIsHasCityWar or self.tData.bIsHasGhostWar then
			self:showCityWarEffect(true)
		else
			self:showCityWarEffect(false)
		end
	else
		self:showCityWarEffect(false)
	end

	--更新召唤信息
	self:updateCallInfo()
end

--国战特效显示
function CityDot:showCityWarEffect( bIsShow )
	--减少刷新
	if self.bWarEffectPrev == bIsShow then
		return
	end
	self.bWarEffectPrev = bIsShow
	-- self.pImgWar:setVisible(bIsShow)
	-- self.pImgWarIcon:setVisible(bIsShow)
	if bIsShow then
		-- --武器动画
		-- if not self.pSwordArmList then
		-- 	self.pSwordArmList = {}
		-- 	local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
		-- 	for i=1,3 do
		-- 		local pArm = MArmatureUtils:createMArmature(
		-- 			tNormalCusArmDatas["47_"..i],
		-- 			self,
		-- 			nWarZorder,
		-- 			cc.p(fX, fY),
		-- 			function ( _pArm )
		-- 				_pArm:removeSelf()
		-- 				_pArm = nil 
		-- 			end, Scene_arm_type.world, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
		-- 		if pArm then
		-- 			WorldFunc.setCameraMaskForView(pArm)
		-- 			pArm:play(-1)
		-- 			table.insert(self.pSwordArmList, pArm)
		-- 		end
		-- 	end
		-- else
		-- 	for i=1,#self.pSwordArmList do
		-- 		self.pSwordArmList[i]:setVisible(true)
		-- 		self.pSwordArmList[i]:play(-1)
		-- 	end
		-- end
		--新动画
		if self.pSwordArm then
			self.pSwordArm:setVisible(true)
		else
			local sName = createAnimationBackName("tx/exportjson/", "rwww_gjtx_yhyb_001")
		    self.pSwordArm = ccs.Armature:create(sName)
		    self.pSwordArm:getAnimation():play("Animation1", -1, -1)
		    local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
		    self.pSwordArm:setPosition(fX, fY)
		    self.pSwordArm:setScale(0.6)
		    self:addChild(self.pSwordArm,nSwordArmZorder)
		    WorldFunc.setCameraMaskForView(self.pSwordArm)
		end
	else
		self:hideSwordArm()
	end
end

--隐藏剑动画
function CityDot:hideSwordArm(  )
	-- if self.pSwordArmList then
	-- 	for i=1,#self.pSwordArmList do
	-- 		self.pSwordArmList[i]:setVisible(false)
	-- 		self.pSwordArmList[i]:stop()
	-- 	end
	-- end
	--新动画
	if self.pSwordArm then
		self.pSwordArm:setVisible(false)
	end
end

--显示召唤信息
function CityDot:showCallInfo( )
	self.pLayBarCd:setVisible(true)
	self.pImgCall:setVisible(true)
	self.pImgCallIcon:setVisible(true)
	-- self.pBbCallTxt:setVisible(true)
end

--隐藏召唤信息
function CityDot:hideCallInfo( )
	self.pLayBarCd:setVisible(false)
	self.pImgCall:setVisible(false)
	self.pImgCallIcon:setVisible(false)
	-- self.pBbCallTxt:setVisible(false)
end

--更新玩家召唤信息
function CityDot:updateCallInfo( )
	--容错
	if not self.tData then
		--显示名字
		self:setNameVisible(true)
		return
	end

	--同国家
	if self.tData.nDotCountry == Player:getPlayerInfo().nInfluence then
		local tCallInfo = self.tData:getCallInfo()
		if tCallInfo then
			--显示
			local nCd = tCallInfo:getReCallCd()
			if nCd > 0 then
				--显示召唤
				self:showCallInfo()
				--隐藏名字
				self:setNameVisible(false)
				--更新cd
				self:updateCallCd()
				return
			end
		end
	end

	--隐藏召唤
	self:hideCallInfo()
	--显示名字
	self:setNameVisible(true)
end

--更新召唤
function CityDot:updateCallCd( )
	--容错
	if not self.tData then
		return
	end
	local tCallInfo = self.tData:getCallInfo()
	if not tCallInfo then
		return
	end

	local nCd = tCallInfo:getReCallCd()
	if nCd > 0 then
		--显示cd
		if tCallInfo.nCallCdMax > 0 then
			self.pCallCdBar:setSliderValue(nCd/tCallInfo.nCallCdMax*100)
		end

		--设置内容
		local tStr = {
			{color = _cc.green, text = tostring(tCallInfo.nResponse)},
			{color = _cc.pwhite, text = string.format("/%s  %s", tCallInfo.nCanCallPlayer, formatTimeToMs(nCd))},
		}
		self.pTxtCallCd:setString(tStr, false)
		--强制渲染一下
		self.pTxtCallCd:updateContent()
		local tChildrens = self.pTxtCallCd:getChildren()
		if(tChildrens[1]) then
		    local pTexture = tChildrens[1]:getTexture()
		    self.pBbCallCd:setTexture(pTexture)
		    --重新设置一下大小
		    self.pBbCallCd:setTextureRect(cc.rect(0,0,self.pTxtCallCd:getContentSize().width,self.pTxtCallCd:getContentSize().height))
    	    --设置位置
        	self.pBbCallCd:setPositionX(self.pBbCallCd:getContentSize().width / 2 + 15 + 10)
		end
	else
		--隐藏召唤
		self:hideCallInfo()
	end
end

--判断是否点中召唤气泡
--屏幕坐标
function CityDot:checkIsClickedCall( fWorldX, fWorldY )
	local fX, fY = self:getPosition()
	local pAnchorPos =  self:getAnchorPoint()
	fX = fX - self:getContentSize().width * pAnchorPos.x
	fY = fY - self:getContentSize().height * pAnchorPos.y

	--是否点击中召唤
	if self.pImgCall:isVisible() then
		local pUi = self.pLayCallClick
		local fX1,fY1 = 0, 0--self.pImgCall:getPosition()
		local fX2,fY2 = pUi:getPosition()
		local pRect = pUi:getBoundingBox()
		pRect.x =  fX + fX1 + fX2 - pRect.width/2
		pRect.y =  fY + fY1 + fY2 - pRect.height/2
		local pTouchPos = cc.p(fWorldX, fWorldY)
		if cc.rectContainsPoint(pRect, pTouchPos) then
			--是自己就弹出召唤面板
			if self.tData:getIsMe() then
				local tObject = {}
				tObject.nType = e_dlg_index.callplayer --dlg类型
				sendMsg(ghd_show_dlg_by_type,tObject)
			else
				--弹出召唤
				local nNeedLv = tonumber(getCountryParam("summonMinLv"))
				local pDlg = getDlgByType(e_dlg_index.alert)
			    if(not pDlg) then
			        pDlg = DlgAlert.new(e_dlg_index.alert)
			    end
			    pDlg:setTitle(getConvertedStr(3, 10091))
			    local nCallCdMax = 0
			    local tCallInfo = self.tData:getCallInfo()
				if tCallInfo then
					nCallCdMax = tCallInfo.nCallCdMax
				end
			    local sStr = string.format(getTipsByIndex(10049), math.ceil(nCallCdMax/60), nNeedLv)
				local tStr = getTextColorByConfigure(sStr)
			    pDlg:setContent(tStr)
			    pDlg:setRightBtnText(getConvertedStr(3, 10171))
			    pDlg:setRightHandler(function (  )
			        pDlg:closeDlg(false)
			        --等级不足
			        if Player:getPlayerInfo().nLv < nNeedLv then
			        	TOAST(string.format(getConvertedStr(3, 10404), nNeedLv))
			        	return
			        end
			        --当前有武将出征中，无法进行城池迁移！
			        if not Player:getWorldData():getIsCanMove() then
			        	TOAST(getConvertedStr(3, 10405))
			        	return
			        end
			        --参与响应
			        SocketManager:sendMsg("reqWorldJoinCall", {self.tData.nCityId})
			    end)
			    pDlg:showDlg(bNew)
			end
			return true
		end
	end

	--是否点击中城战
	-- if self.pImgWar:isVisible() then
	-- 	local fX1,fY1 = self:getPosition()
	-- 	local fX2,fY2 = 0, 0 --self.pImgWar:getPosition()
	-- 	local pRect = self.pImgWar:getBoundingBox()
	-- 	pRect.x = fX1 + fX2 - pRect.width/2
	-- 	pRect.y = fY1 + fY2 - pRect.height/2
	-- 	local pTouchPos = cc.p(fWorldX, fWorldY)
	-- 	if cc.rectContainsPoint(pRect, pTouchPos) then
	-- 		--发送城战请求
	-- 		sendMsg(ghd_send_city_war_req, self.tData)
	-- 		return true
	-- 	end
	-- end
	return false
end


--更新我的保护cd时间
function CityDot:updateMyProtectCd( )
	--容错
	if not self.tData then
		return
	end
	if self.tData:getIsMe() then
		self:updateProtectCd()
	end
end

--更新我的城池信息
function CityDot:udpateMyCallInfo( )
	--容错
	if not self.tData then
		return
	end
	if self.tData:getIsMe() then
		self:updateCityUi()
	end
end

--设置UI是否隐藏
function CityDot:setDotUiVisible( bIsShow )
	if bIsShow then
		self.bIsHideByClickLayer = false
		self:updateCityUi()
	else
		self.bIsHideByClickLayer = true
		self:hideDotUis()
		self:setNameVisible(true)
	end
end

function CityDot:hideDotUis( )
	self:hideCallInfo()
	self:showCityWarEffect(false)
end

--显示或隐藏扩展
function CityDot:setVisibleEx( bIsShow )
	if bIsShow == false then
		self.bIsHideByClickLayer = false
		--清空数据
		self:delViewDotMsg()
	end
	self:setVisible(bIsShow)
	self.pImgCity:setVisible(bIsShow)
	self.pClickNode:setVisible(bIsShow)
end

--设置城名字显示
function CityDot:setNameVisible( bIsShow )
	self.pLayLvBg:setVisible(bIsShow)
	-- self.pTxtName:setVisible(bIsShow)
end

function CityDot:delViewDotMsg( )
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end


return CityDot