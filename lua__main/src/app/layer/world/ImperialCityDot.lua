----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-14 20:14:00
-- Description: 地图上的皇城
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
--层次
local nProtectZorderBg = 0
local nProtectZorder = 3
local nLvBgZorder = 4
local nPaperZorder = 1
local nPaperCdZorder = 1
local nNameZorder = 109
local nPosZ = 1
local nShowYAdd = 15
local nShowYAdd2 = 10
local n3dOffsetY = -24
local n3dOffsetZ = 30
local nEpwFightZorder = 10

local nNameOffsetX = 15 -- 名称偏移
local nCaremaMask = 10 --1010 摄像机掩码（在最后才渲染最高层。照道理用1000就可以了，不过存在问题，不能随着屏幕移动，所以用10） 

local const_img_qi_name = {
    "#v2_img_han2b.png",
    "#v2_img_qing3c.png",
    "#v2_img_chu1a.png",
    "#v2_img_qun4d.png"
}

local ImperialCityDot = class("ImperialCityDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)


--pWorldLayer：世界层
--pImgCity 视图点图片（减少drawcall）
function ImperialCityDot:ctor( pWorldLayer, pImgCity, pClickNode)
	self.pWorldLayer = pWorldLayer
	self.pImgCity = pImgCity
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgCity)
	self.nCaptureSMax = tonumber(getEpangWarInitData("ocSecond"))

	self.tParitcles = {}

	--解析文件
	self:onParseViewCallback()
end

--解析界面回调
function ImperialCityDot:onParseViewCallback( )
	self:setContentSize(cc.size(UNIT_WIDTH, UNIT_HEIGHT))
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("ImperialCityDot",handler(self, self.onImperialCityDotDestroy))
end

function ImperialCityDot:onImperialCityDotDestroy(  )
	self:onPause()
	if self.nArmSchedule then
	    MUI.scheduler.unscheduleGlobal(self.nArmSchedule)
	    self.nArmSchedule = nil
	end
end

function ImperialCityDot:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function ImperialCityDot:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function ImperialCityDot:regMsgs( )
	-- regMsg(self, ghd_city_protect_effect_test, handler(self, self.onEffectTest))
	regMsg(self, ghd_sys_city_mingjie_action, handler(self, self.updateViews))
end

function ImperialCityDot:unregMsgs( )
	-- unregMsg(self, ghd_city_protect_effect_test)
	unregMsg(self, ghd_sys_city_mingjie_action)

end

function ImperialCityDot:onEffectTest( )
	self.bEffectTest = true
	self:updateSysCityUi()
end

function ImperialCityDot:setupViews(  )
	--创建名字
	local nNameFontSize = 22
	self.pTxtName = MUI.MLabel.new({text = "1", size = nNameFontSize})
	self.pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	self:addChild(self.pTxtName, nNameZorder)
    setTextCCColor(self.pTxtName, _cc.lwhite)

	--创建等级
	self.pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	self.pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	self:addChild(self.pTxtLv, nNameZorder)
	setTextCCColor(self.pTxtLv, _cc.lwhite)

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
	    self.pBbName:setPosition3D(cc.vec3(self.pBbName:getContentSize().width / 2 + nNameOffsetX + 5, 14, 1))
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

	--集结
	self.pBbTogether = createCCBillBorad("ui/big_img/v2_img_qizi.png")
	self:addChild(self.pBbTogether, nPaperZorder)
	centerInView(self, self.pBbTogether)
	local posX, posY = self.pBbTogether:getPosition()
	posY = posY + 40	
	self.pBbTogether:setPositionY(posY) 
	local nMoveHeight = 10
	local action1 = cc.MoveTo:create(1, cc.p(posX, posY + nMoveHeight))
	local action2 = cc.MoveTo:create(1, cc.p(posX, posY - nMoveHeight))
	local seq = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	self.pBbTogether:runAction(seq)

	--图纸和申请城主文字特殊处理结束
	self.pTxtName:setSystemFontSize(nNameFontSize)
	setTextCCColor(self.pTxtName, _cc.lwhite)

	--旗子
	self.pImgQi = MUI.MImage.new(const_img_qi_name[e_type_country.qunxiong])
    self:addChild(self.pImgQi)

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)

	self:initCaptureBar()
end

--更新cd
function ImperialCityDot:updateCd( )
	if not self.tData then
		return
	end
	if Player:getImperWarData():getImperWarIsOpen() then
		self.pLayBarCd:setVisible(true)
		local nCd = self.tData:getEWCaputerCd()
		if nCd > self.nCaptureSMax then
			nCd = self.nCaptureSMax
		end
		local nPer = nCd/self.nCaptureSMax * 100
		self.pCallCdBar:setSliderValue(nPer)

		self.pTxtCallCd:setString(getTimeLongStr(nCd, false, false))
	else
		self.pLayBarCd:setVisible(false)
	end
	--更新集结
	self:udpateTogether()
end

--获取id
function ImperialCityDot:getId(  )
	return self.nSystemCityId
end

--设置服务端数据
--tData:viewDotMsg
function ImperialCityDot:setData( tData )
	self.tData = tData
	self.bEffectTest = nil
	self:updateViews()
	self:updateCd()

	--设置位置
	if self.tData then
		local fX, fY = self.tData:getWorldMapPos()
		if fX then
			self:setPosition(fX, fY)
			self.pImgCity:setPosition(fX, fY + nShowYAdd)
			self.pClickNode:setPosition(fX, fY)
		end
	end
end

--获取服务端数据
function ImperialCityDot:getData(  )
	return self.tData
end

--设置表格数据
function ImperialCityDot:setDataByCityId( nCityId )
	self.nCityId = nCityId
	local tData =  Player:getWorldData():getSysCityDot(nCityId)
	if tData then
		self:setData(tData)
	else
		myprint("服务器没有数据")
	end
end

--获取dotkey集
function ImperialCityDot:getDotKeys(  )
	return self.tDotKey or {}
end

--生成dotKey集
function ImperialCityDot:setDotKeys( tDotKey )
	self.tDotKey = tDotKey
end

--设置显示视图
function ImperialCityDot:setViewRect( pRect )
	self.pViewRect = pRect
end

--获取显示视图
function ImperialCityDot:getViewRect(  )
	return self.pViewRect
end

--更新视图
function ImperialCityDot:updateViews()
	if not self.tData then
		return
	end

	--防止重复刷新
	if self.nSystemCityId ~= self.tData.nSystemCityId or self.nCountry ~= self.tData.nDotCountry then

		self.nSystemCityId = self.tData.nSystemCityId

		self.nCountry = self.tData.nDotCountry

		--占领旗子图片
		if self.pImgCaptureFlag then
			self.pImgCaptureFlag:setCurrentImage(WorldFunc.getCountryFlagImg(self.nCountry))
		end
		--城池图片
		local tCityData = getWorldCityDataById(self.nSystemCityId)
		if tCityData then            
			self.pImgCity:setScale(1)
			-- self.pImgCity = WorldFunc.getSysCityIconOfContainer(self, self.nSystemCityId, self.nCountry, nil)
            local nCountryType = self.nCountry or e_type_country.qunxiong
			local sImgPath = tCityData.tCityicon[nCountryType]
			if sImgPath then
				self.pImgCity:setCurrentImage(sImgPath)
			end
			if tCityData.kind==e_kind_city.juncheng or tCityData.kind==e_kind_city.zhoucheng 
				or tCityData.kind==e_kind_city.mingcheng or tCityData.kind==e_kind_city.ducheng then
				self.pImgCity:setScale(0.5)
			end
			-- 图片大小
            local tImgCitySize = self.pImgCity:getContentSize()
			--图片大小设置变化
			--等级和名字位置随图片的变化而化
			local nScale=self.pImgCity:getScale()
			local fX, fY = UNIT_WIDTH/2, UNIT_HEIGHT/2 + nShowYAdd
			fY = fY - tImgCitySize.height/2 * nScale
			self.pLayLvBg:setPositionY(fY)

            --旗子
            self.pImgQi:setCurrentImage(const_img_qi_name[nCountryType])
            self.pImgQi:setPosition(fX + tImgCitySize.width /2 * nScale - 40, fY + tImgCitySize.height/2 * nScale + 20)
		end

		-- --系统城池要显示底框
		-- local sImg = WorldFunc.getWorldCityDotBgImg(self.nCountry)
		-- if not self.pImgBorder then
		-- 	self.pImgBorder = MUI.MImage.new(sImg)
		-- 	self:addView(self.pImgBorder)
		-- 	centerInView(self, self.pImgBorder)
		-- else
		-- 	self.pImgBorder:setCurrentImage(sImg)
		-- end
	end

	--防止重复刷新
    local nDotLv = self.tData.nDotLv
	if self.nLv ~= nDotLv then
		self.nLv = nDotLv
		-- self.pTxtLv:setString(getLvString(self.nLv),false)
		-- self.pTxtLv:setString(tostring(self.nLv),false)
		--设置内容
		self.pTxtLv:setString(self.nLv, false)
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

	--防止重复刷新名字
    local sName = self.tData:getSysCityOwnerName() 
    if sName ~= nil then
        sName = string.format(getConvertedStr(10, 90001), sName)
    else
        sName = self.tData:getDotName()
    end
	if self.sName ~= sName then
		self.sName = sName
		--设置内容
		self.pTxtName:setString(self.sName, false)
		--强制渲染一下
		self.pTxtName:updateContent()
		local tChildrens = self.pTxtName:getChildren()
		if(tChildrens[1]) then
		    local pTexture = tChildrens[1]:getTexture()
		    self.pBbName:setTexture(pTexture)
		    --重新设置一下大小
		    self.pBbName:setTextureRect(cc.rect(0,0,self.pTxtName:getContentSize().width,self.pTxtName:getContentSize().height))
    	    --设置位置
        	self.pBbName:setPositionX(self.pBbName:getContentSize().width / 2 + 15 + 20)
		end

		WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pBbName:getContentSize().width)
		local nBgW = self.pBbNameBg:getContentSize().width
		self.pBbNameBg:setPositionX(nBgW / 2 + nNameOffsetX)
		--动态设置名字登记位置
		local nAllW = nBgW + 15
		local nX = (UNIT_WIDTH - nAllW) / 2
		self.pLayLvBg:setPositionX(nX - 5)
	end
	--强制显示
	self:setNameVisible(true)

	--进击特效显示
	self:updateAtkEffect()

	--更新保护罩显示
	self:updateProtect()

	--更新系统城池UI
	self:updateSysCityUi()

	--更新集结
	self:udpateTogether()

	--更新冥界特效
	self:onShowMingjieEffect()

	--更新皇城战特效
	self:updateEpwFightEffect()
end

--更新是否显示进攻特效
function ImperialCityDot:updateAtkEffect(  )
	if not self.nSystemCityId then
		return
	end

	local nX, nY = nil, nil
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if tCityData then
		local tCoordinate = tCityData.tCoordinate
		if tCoordinate then
			nX, nY = tCoordinate.x, tCoordinate.y
		end
	end

	local bIsShowAtkEffect = Player:getWorldData():getViewDotIsShowAtkEffect(nX, nY)
	if self.bIsShowAtkEffect ~= bIsShowAtkEffect then
		self.bIsShowAtkEffect = bIsShowAtkEffect

		if self.bIsShowAtkEffect then
			if not self.pArmActions then
				self.pArmActions = WorldFunc.getViewDotAtkEffect(self.pClickNode, 0, 0, 0)
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
			local nScale = 3
			self.pClickNode:setVisible(true)
			self.pClickNode:stopAllActions()
			self.pClickNode:setOpacity(0)
			self.pClickNode:setScale(nScale)
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
					cc.ScaleTo:create(0.3, nScale - 0.5),
				}),
			})
			self.pClickNode:runAction(pSeqAct)
		else
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


--更新cd时间
function ImperialCityDot:updateProtect()
	if self.tData then
		local bIsOpen = Player:getImperWarData():getImperWarIsOpen()
		if not bIsOpen then
			if not self.pLayBack or not self.pLayFront then
				local pSize = self:getContentSize()
				self.pLayBack = MUI.MLayer.new()
				self.pLayBack:setContentSize(pSize)
				self:addView(self.pLayBack, nProtectZorderBg)
				
				self.pLayFront = MUI.MLayer.new()
				self.pLayFront:setContentSize(pSize)
				self:addView(self.pLayFront, nProtectZorder)

				self.pArmList, self.nArmSchedule = WorldFunc.setCityProtectArms(self.pLayBack, self.pLayFront)

				--位置Y轴微调
				self.pLayBack:setPosition(pSize.width/2, pSize.height/2 + nShowYAdd2)
				self.pLayFront:setPosition(pSize.width/2, pSize.height/2 + nShowYAdd2)

				WorldFunc.setCameraMaskForView(self.pLayFront)
				WorldFunc.setCameraMaskForView(self.pLayBack)
			else
				self.pLayBack:setVisible(true)
				self.pLayFront:setVisible(true)
				if self.pArmList then
					for i=1,#self.pArmList do
						self.pArmList[i]:setVisible(true)
					end
				end
			end
			--设置大小
			local nScale = 1.9
			self.pLayBack:setScale(nScale)
			self.pLayFront:setScale(nScale)
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
-------------------------------更新系统城池Ui-----------------------------
function ImperialCityDot:updateSysCityUi( )
end

--更新集结
function ImperialCityDot:udpateTogether( )
	if self.tData and self.tData:getIsTogether() then
		self:showTogetherUi()
	else
		self:hideTogetherUi()
	end
end

--显示集结Ui
function ImperialCityDot:showTogetherUi(  )
	self.pBbTogether:setVisible(true)
end
--隐藏集结Ui
function ImperialCityDot:hideTogetherUi()
	self.pBbTogether:setVisible(false)
end

--------------------------------------------
--世界坐标
--fX,fY 世界坐标
function ImperialCityDot:checkIsClickedUis( fWorldX, fWorldY )
	return false
end

--图纸点击
function ImperialCityDot:onPaperClicked(  )
end

--设置UI是否隐藏
function ImperialCityDot:setDotUiVisible( bIsShow )
	if bIsShow then
		self.bIsHideByClickLayer = false
		self:updateSysCityUi()
	else
		self.bIsHideByClickLayer = true
		self:hideDotUis()
		self:setNameVisible(true)
	end
end

function ImperialCityDot:hideDotUis( )
end

--显示或隐藏扩展
function ImperialCityDot:setVisibleEx( bIsShow )
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
function ImperialCityDot:setNameVisible( bIsShow )
	self.pLayLvBg:setVisible(bIsShow)
	self.pTxtName:setVisible(false)

    self:setLvVisible(bIsShow)
end

--设置等级是否显示
function ImperialCityDot:setLvVisible( bIsShow )
	-- body
    --print("=========>function ImperialCityDot:setLvVisible( bIsShow )", bIsShow, self.tData:getSysCityOwnerName() == nil)
    local isShowLvBg = false 
    if self.tData then
    	isShowLvBg = self.tData:getSysCityOwnerName() == nil
    end

    bIsShow = (bIsShow and isShowLvBg)
	self.pBbLvBg:setVisible(bIsShow)

    local nBgW = self.pBbNameBg:getContentSize().width
    local nOffsetX = bIsShow == true and nNameOffsetX or 0
    --TOAST(string.format("======================>%s", nOffsetX))
    self.pBbName:setPositionX(nBgW / 2 + 3)
end

--删除视图数据
function ImperialCityDot:delViewDotMsg( )
	self:removeMingjieEffect()
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
	--移除特效
	self:updateEpwFightEffect()
end

--需要双摄机处理
function ImperialCityDot:initCaptureBar(  )
	if self.pLayBarCd then
		return
	end
	if not self.pWorldLayer:getIsCamera2Inited() then
		return
	end

	--皇城占领时间条
	local nLayWidth = 264
	local nLayHeight = 30
	local pLayBarCd = MUI.MLayer.new()
	pLayBarCd:setContentSize(nLayWidth,nLayHeight)

	local pImgBg = MUI.MImage.new("ui/bar/v1_bar_b1.png")
	local pSize = pImgBg:getContentSize()
	pImgBg:setScale((nLayWidth-4)/pSize.width, nLayHeight/pSize.height)
	pImgBg:setAnchorPoint(0, 0)
	pLayBarCd:addView(pImgBg)
	
	self:addChild(pLayBarCd, nPaperCdZorder)
	self.pLayBarCd = pLayBarCd
	local fX, fY = UNIT_WIDTH/2 - nLayWidth/2, 250
	self.pLayBarCd:setPosition(fX, fY)
	self.pCallCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/daitu.png",
		    	barfg="ui/bar/v1_bar_blue_3afg.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(264, 26)
		    :align(display.LEFT_BOTTOM)
    --设置为不可触摸
    self.pCallCdBar:setViewTouched(false)
    self.pCallCdBar:setSliderValue(100)
	pLayBarCd:addView(self.pCallCdBar, 1)
	self.pCallCdBar:setPosition(3, 2)
	-- local nX, nY = self.pCallCdBar:getPosition()
	-- centerInView(pLayBarCd, self.pCallCdBar)
	self.pImgCaptureFlag = MUI.MImage.new(WorldFunc.getCountryFlagImg(self.nCountry))
	self.pImgCaptureFlag:setAnchorPoint(1,1)
	self.pImgCaptureFlag:setPositionY(38)
	self.pLayBarCd:addView(self.pImgCaptureFlag)

	-- local pImgBg2 = MUI.MImage.new("#v1_img_blackjianbian.png")
	-- pImgBg2:setOpacity(255*0.5)
	-- self.pLayBarCd:addView(pImgBg2, 2)
	-- pImgBg2:setPosition(nLayWidth/2, -25)

	self.pTxtCallCd = MUI.MLabel.new({
            text = "999999",
            size = 23,
        })
	self.pLayBarCd:addView(self.pTxtCallCd, 2)
	self.pTxtCallCd:enableOutline(cc.c4b(0, 0, 0, 255), 2)
	self.pTxtCallCd:setPosition(nLayWidth/2, 15)

	self.pLayBarCd:setCameraMask(10,true)
end


-------------------------------------------------------冥界入侵燃烧
function ImperialCityDot:onShowMingjieEffect(  )
	-- body
	--创建新的任务线路
	--创建新的任务推送线路
	local bShowEffect = false
	local tData = Player:getActById(e_id_activity.mingjie)
	if tData and tData.nS == 2 then
		bShowEffect = true
	end
	
	if bShowEffect then
		self:showMingjieEffect()
	else
		self:removeMingjieEffect()
	end
end

function ImperialCityDot:showMingjieEffect(  )
	-- body
	-- 图片大小

    local  nScale = self.pImgCity:getScale()
    local  nRealWidth = self.pImgCity:getWidth() * nScale
    local  nRealHeight = self.pImgCity:getHeight() * nScale
	self.pImgCity:setCurrentImage("#v1_img_mj_huang03.png")
	local  nRealScale = nRealWidth/self.pImgCity:getWidth()
	if not self.pLayParitcle then
		self.pLayParitcle = MUI.MLayer.new()
		self.pLayParitcle:setAnchorPoint(0,0)
		self.pLayParitcle:setLayoutSize(nRealWidth, nRealHeight)
		self.pLayParitcle:setPosition(UNIT_WIDTH/2,UNIT_HEIGHT/2 + 30)
		self:addChild(self.pLayParitcle,1000)
	end
	self.pImgCity:setScale(nRealScale)
	if #self.tParitcles <= 0 then
		self.tParitcles = showMingjieWorldEffect(self.pLayParitcle)
	end
	WorldFunc.setCameraMaskForView(self.pLayParitcle)
end

function ImperialCityDot:removeMingjieEffect(  )
	-- body
	if self.pLayParitcle  then
		for i=1,#self.tParitcles do
			local v= self.tParitcles[i]
			v:removeSelf()
			v = nil
		end
		self.tParitcles={}

		self.pLayParitcle:removeSelf()
		self.pLayParitcle = nil
	end
end
-------------------------------------------------------冥界入侵燃烧

-------------------------------------------------------皇城作战特效
function ImperialCityDot:updateEpwFightEffect(  )
	if self.tData and Player:getImperWarData():getImperWarIsOpen() then
		if self.tData:getIsEpwBattle() then --是否播放特效
			if not self.pEpwFightEffect then
				local EpwFightEffect = require("app.layer.world.EpwFightEffect")
			 	self.pEpwFightEffect = EpwFightEffect.new()
			 	self:addView(self.pEpwFightEffect, nEpwFightZorder)
			 	self.pEpwFightEffect:setPosition(UNIT_WIDTH/2, UNIT_HEIGHT/2 + nShowYAdd)
				WorldFunc.setCameraMaskForView(self.pEpwFightEffect)
			end
			self.pEpwFightEffect:setData(self.tData.nSystemCityId)
		else
			if self.pEpwFightEffect then
				self.pEpwFightEffect:removeFromParent()
				self.pEpwFightEffect = nil
			end
		end
	else
		if self.pEpwFightEffect then
			self.pEpwFightEffect:removeFromParent()
			self.pEpwFightEffect = nil
		end
	end
end
-------------------------------------------------------皇城作战特效

return ImperialCityDot