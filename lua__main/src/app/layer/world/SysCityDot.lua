----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-07 09:42:59
-- Description: 地图上的系统城池
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
--层次
local nProtectZorderBg = 0
local nProtectZorder = 3
local nLvBgZorder = 4
local nPaperZorder = 1
local nPaperCdZorder = 1
local nExclamationZorder = 1
local nWarZorder = 2
local nNameZorder = 109
local nPosZ = 1
local nCityZorder = 1
local nShowYAdd = 15
local nShowYAdd2 = 10
local n3dOffsetY = -24
local n3dOffsetZ = 30
local nSwordArmZorder = 10

local nNameOffsetX = 15 -- 名称偏移

local const_img_qi_name = {
    "#v2_img_han2b.png",
    "#v2_img_qing3c.png",
    "#v2_img_chu1a.png",
    "#v2_img_qun4d.png"
}

local SysCityDot = class("SysCityDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)


--pWorldLayer：世界层
--pImgCity 视图点图片（减少drawcall）
function SysCityDot:ctor( pWorldLayer, pImgCity, pClickNode)
	self.pWorldLayer = pWorldLayer
	self.pImgCity = pImgCity
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgCity)

	-- self.pPrevImgCitySize = cc.p(0, 0)
	self.pMidPos = cc.p(0, 0)
	self.pLeftPos = cc.p(0, 0)
	self.pRightPos = cc.p(0, 0)

	self.nEffectType = e_sys_city_effect.none

	self.tMingjieParitcles = {}
	self.tNormalParitcles = {}

	self.nCityKind = nil

	--解析文件
	self:onParseViewCallback()
end

--解析界面回调
function SysCityDot:onParseViewCallback( )
	self:setContentSize(cc.size(UNIT_WIDTH, UNIT_HEIGHT))
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("SysCityDot",handler(self, self.onSysCityDotDestroy))
end

function SysCityDot:onSysCityDotDestroy(  )
	self:onPause()
	if self.nArmSchedule then
	    MUI.scheduler.unscheduleGlobal(self.nArmSchedule)
	    self.nArmSchedule = nil
	end
end

function SysCityDot:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function SysCityDot:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function SysCityDot:regMsgs( )
	regMsg(self, ghd_sys_city_mingjie_action, handler(self, self.updateViews))
end

function SysCityDot:unregMsgs( )
	unregMsg(self, ghd_sys_city_mingjie_action)
end

function SysCityDot:onEffectTest( )
	self.bEffectTest = true
	self:updateSysCityUi()
end

function SysCityDot:setupViews(  )
	-- --城池
	-- --BillBorad
	-- self.pImgCity = WorldFunc.getSysCityIconOfContainer(self, 11001, e_type_country.qunxiong, nil)
	-- self.pImgCity:setZOrder(nCityZorder)
	-- --位置Y轴微调
	-- self.pImgCity:setPositionY(self.pImgCity:getPositionY() + nShowYAdd)

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

	--图纸和申请城主文字特殊处理
	self.pTxtName:enableOutline(cc.c4b(0, 0, 0, 255),2)
	setTextCCColor(self.pTxtName, _cc.lyellow)

	--图纸
	self.pImgPaper = createCCBillBorad("#v1_ing_zjm_gndi.png")
	self.pImgPaper:setScale(1)
	self:addChild(self.pImgPaper, nPaperZorder)
	self.pImgPaperIcon = createCCBillBorad("#v1_img_zjm_hd.png")
	self.pImgPaperIcon:setScale(1)
	self:addChild(self.pImgPaperIcon, nPaperZorder)
	--图纸文字
	self.pTxtName:setString(getConvertedStr(3, 10157))
	self.pTxtName:updateContent()
	local tChildrens = self.pTxtName:getChildren()
    local texture = tChildrens[1]:getTexture()
    self.pBbPaperTxt = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
    self.pBbPaperTxt:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.pBbPaperTxt, nPaperZorder)
    --图纸特效层
    self.pLayPaperArm = MUI.MLayer.new()
    self.pLayPaperArm:setLayoutSize(self.pImgPaper:getContentSize())
    self:addChild(self.pLayPaperArm, nPaperZorder)
    self.pLayPaperArm:setScale(1)
	--图纸点击
	local nClickW, nClickH = 88, 88
	self.pLayPaperClick = MUI.MLayer.new()
	self.pLayPaperClick:setContentSize(nClickW, nClickH)
	self.pLayPaperClick:setAnchorPoint(0.5, 0.5)
	self:addChild(self.pLayPaperClick, nPaperZorder)

	--显示调试
	-- local pLayPaperClickColor = display.newColorLayer(cc.c4b(255, 0, 0, 255))
	-- pLayPaperClickColor:setTouchEnabled(false)
	-- pLayPaperClickColor:setContentSize(nClickW, nClickH)
	-- self.pLayPaperClick:addView(pLayPaperClickColor)

	--申请城主
	self.pImgExclamation = createCCBillBorad("#v1_ing_zjm_gndi.png")
	self.pImgExclamation:setScale(1)
	self:addChild(self.pImgExclamation, nPaperZorder)
	self.pImgExclamationIcon = createCCBillBorad("#v1_btn_czdl.png")
	self.pImgExclamationIcon:setScale(1)
	self:addChild(self.pImgExclamationIcon, nExclamationZorder)
	--申请文字
	self.pTxtName:setString(getConvertedStr(3, 10700))
	self.pTxtName:updateContent()
	local tChildrens = self.pTxtName:getChildren()
    local texture = tChildrens[1]:getTexture()
    self.pBbExclamationTxt = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
    self:addChild(self.pBbExclamationTxt, nExclamationZorder)


	--申请城主点击
	local nClickW, nClickH = 88, 88
	self.pLayExclamationClick = MUI.MLayer.new()
	self.pLayExclamationClick:setContentSize(nClickW, nClickH)
	self.pLayExclamationClick:setAnchorPoint(0.5, 0.5)
	self:addChild(self.pLayExclamationClick, nExclamationZorder)

	--显示调试
	-- local pLayExclamationClickColor = display.newColorLayer(cc.c4b(255, 0, 0, 255))
	-- pLayExclamationClickColor:setTouchEnabled(false)
	-- pLayExclamationClickColor:setContentSize(nClickW, nClickH)
	-- self.pLayExclamationClick:addView(pLayExclamationClickColor)

	--国战按钮
	-- self.pImgWar = createCCBillBorad("#v1_ing_zjm_gndi2.png")

	-- self:addChild(self.pImgWar, nWarZorder)
	-- self.pImgWar:setScale(0.45)
	-- self.pImgWarIcon = createCCBillBorad("#v1_btn_guozhan2.png")
	-- self.pImgWarIcon:setScale(0.75)
	-- self:addChild(self.pImgWarIcon, nWarZorder)
	-- --城战位置
	-- local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
	-- self.pImgWar:setPosition3D(cc.vec3(fX, fY - 2, nPosZ))
	-- self.pImgWarIcon:setPosition3D(cc.vec3(fX, fY - 2, nPosZ + 1))

	--图纸和申请城主文字特殊处理结束
	self.pTxtName:disableEffect()
	self.pTxtName:setSystemFontSize(nNameFontSize)
	setTextCCColor(self.pTxtName, _cc.lwhite)

	--图纸征收cd条
	local pLayBarCd = MUI.MLayer.new()
	pLayBarCd:setContentSize(100,26)
	-- pLayBarCd:setBackgroundImage("ui/bar/v1_bar_bscd.png")
	self:addChild(pLayBarCd, nPaperCdZorder)
	self.pLayBarCd = pLayBarCd

	-- self.pPaperCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
	-- 	    {
	-- 	    	bar="ui/daitu.png",
	-- 	   	 	button="ui/update_bin/v1_ball.png",
	-- 	    	barfg="ui/bar/v1_bar_blue_sc.png"
	-- 	    }, 
	-- 	    {
	-- 	    	scale9 = false, 
	-- 	    	touchInButton=false
	-- 	    })
	-- 	    :setSliderSize(124, 16)
	-- 	    :align(display.LEFT_BOTTOM)
 --    --设置为不可触摸
 --    self.pPaperCdBar:setViewTouched(false)
	-- pLayBarCd:addView(self.pPaperCdBar, 10)
	-- local nX, nY = self.pPaperCdBar:getPosition()
	-- self.pPaperCdBar:setPosition(nX+1, nY+5)
	
	--征收图标
	-- local pImgLevy = createCCBillBorad("#v1_img_shengchanzhong.png")
	-- pImgLevy:setPosition(-pImgLevy:getContentSize().width/2, 10)
	-- pLayBarCd:addChild(pImgLevy)

	--随便设置一个设置 只为了获取texture   征收倒计时
	self.pTxtPaperCd = MUI.MLabel.new({text = "1", size = 20})
	self.pTxtPaperCd:enableOutline(cc.c4b(0, 0, 0, 255),1)
	setTextCCColor(self.pTxtPaperCd, _cc.yellow)	
	self.pTxtPaperCd:setVisible(false)
	self:addChild(self.pTxtPaperCd, nPaperCdZorder)
	--获取所有的子节点
	self.pTxtPaperCd:updateContent()
	local tChildrens = self.pTxtPaperCd:getChildren()
	if(tChildrens[1]) then
	    local texture = tChildrens[1]:getTexture()
	    self.pBbPaperCd = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbPaperCd:setPosition(pLayBarCd:getContentSize().width/2 - self.pBbPaperCd:getContentSize().width / 2 + 15 + 5, 11)
	    self.pImgPaperIcon:addChild(self.pBbPaperCd,20)
	    self.pBbPaperCd:setPosition3D(cc.vec3(self.pImgPaperIcon:getContentSize().width/2, self.pImgPaperIcon:getContentSize().height +10 ,10))
	end

	--随便设置一个设置 只为了获取texture  竞选倒计时
	self.pTxtPaperJxCd = MUI.MLabel.new({text = "1", size = 20})
	self.pTxtPaperJxCd:enableOutline(cc.c4b(0, 0, 0, 255),1)
	setTextCCColor(self.pTxtPaperJxCd, _cc.yellow)	
	self.pTxtPaperJxCd:setVisible(false)
	self:addChild(self.pTxtPaperJxCd, nPaperCdZorder)
	--获取所有的子节点
	self.pTxtPaperJxCd:updateContent()
	local tChildrens = self.pTxtPaperJxCd:getChildren()
	if(tChildrens[1]) then
	    local texture = tChildrens[1]:getTexture()
	    self.pBbPaperJxCd = cc.BillBoard:createWithTexture(texture,cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	    self.pBbPaperJxCd:setPosition(pLayBarCd:getContentSize().width/2 - self.pBbPaperCd:getContentSize().width / 2 + 15 + 5, 11)
	    self.pImgExclamationIcon:addChild(self.pBbPaperJxCd,20)
	    self.pBbPaperJxCd:setPosition3D(cc.vec3(self.pImgExclamationIcon:getContentSize().width/2, self.pImgExclamationIcon:getContentSize().height +10 ,10))
	end


    --self.pImgQi = MUI.MImage.new("ui/daitu.png")    
    self.pImgQi = MUI.MImage.new(const_img_qi_name[e_type_country.qunxiong])
    self:addChild(self.pImgQi)

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--更新cd
function SysCityDot:updateCd( )
	self:updateProtectCd()
	self:updatePaperCd()
	self:updatePaperJxCd()
end

--获取id
function SysCityDot:getId(  )
	return self.nSystemCityId
end

--设置服务端数据
--tData:viewDotMsg
function SysCityDot:setData( tData )
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
function SysCityDot:getData(  )
	return self.tData
end

--设置表格数据
function SysCityDot:setDataByCityId( nCityId )
	self.nCityId = nCityId
	local tData =  Player:getWorldData():getSysCityDot(nCityId)
	if tData then
		self:setData(tData)
	else
		myprint("服务器没有数据")
	end
end

--获取dotkey集
function SysCityDot:getDotKeys(  )
	return self.tDotKey or {}
end

--生成dotKey集
function SysCityDot:setDotKeys( tDotKey )
	self.tDotKey = tDotKey
end

--设置显示视图
function SysCityDot:setViewRect( pRect )
	self.pViewRect = pRect
end

--获取显示视图
function SysCityDot:getViewRect(  )
	return self.pViewRect
end

--更新视图
function SysCityDot:updateViews()
	if not self.tData then
		return
	end

	--防止重复刷新
	if self.nSystemCityId ~= self.tData.nSystemCityId or self.nCountry ~= self.tData.nDotCountry then

		self.nSystemCityId = self.tData.nSystemCityId

		self.nCountry = self.tData.nDotCountry

		--城池图片
		local tCityData = getWorldCityDataById(self.nSystemCityId)
		if tCityData then 
			self.nCityKind = tCityData.kind        
			-- self.pImgCity = WorldFunc.getSysCityIconOfContainer(self, self.nSystemCityId, self.nCountry, nil)
            local nCountryType = self.nCountry or e_type_country.qunxiong
			local sImgPath = tCityData.tCityicon[nCountryType]
			if sImgPath then
				self.pImgCity:setCurrentImage(sImgPath)
			end
			if tCityData.kind==e_kind_city.juncheng or tCityData.kind==e_kind_city.zhoucheng 
				or tCityData.kind==e_kind_city.mingcheng or tCityData.kind==e_kind_city.ducheng then
				self.pImgCity:setScale(0.5)
			else
				self.pImgCity:setScale(1)
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
        	self.pBbName:setPositionX(self.pBbName:getContentSize().width / 2)
		end

		--更新等级背景大小
		-- local nWidth = self.pTxtName:getWidth() + 20
		-- if nWidth <= 85 then
		-- 	self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg1.png"))
		-- elseif nWidth <= 100 then
		-- 	self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg2.png"))
		-- elseif nWidth <= 115 then
		-- 	self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg3.png"))
		-- elseif nWidth <= 130 then
		-- 	self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg4.png"))
		-- elseif nWidth <= 145 then
		-- 	self.pBbNameBg:setSpriteFrame(getSpriteFrameByName("#v1_img_namebg5.png"))
		-- end
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

	--更新系统城池UI
	self:updateSysCityUi()

	--更新冥界特效
	self:onShowMingjieEffect()

	self:showFireEffect()
end

--更新是否显示进攻特效
function SysCityDot:updateAtkEffect(  )
	if not self.nSystemCityId then
		return
	end

	local nX, nY = nil, nil
	local nScale = 1.5
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if tCityData then
		local tCoordinate = tCityData.tCoordinate
		if tCoordinate then
			nX, nY = tCoordinate.x, tCoordinate.y
		end
		if tCityData.grid == 9 then
			nScale = 2.5
		elseif tCityData.grid == 4 then
			nScale = 2
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

--更新cd时间
function SysCityDot:updateProtectCd()
	if self.tData then
		if self.tData:getProtectCd() > 0  or self.bEffectTest then
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
			local tCityData = getWorldCityDataById(self.tData.nSystemCityId)
			if tCityData then
				local sCityicon = tCityData.cityicon
				if sCityicon then
					local tCityicon = luaSplit(sCityicon,";")
					local pStr
					if tCityicon[1] then
						pStr = string.sub(tCityicon[1], -2)
					end
					local nScale = 1
					--根据图片名字最后两个字判断
					if pStr and pStr == "01" or pStr == "02" then
						nScale = 0.73
					end
					self.pLayBack:setScale(nScale)
					self.pLayFront:setScale(nScale)
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


-------------------------------更新系统城池Ui-----------------------------
function SysCityDot:updateSysCityUi()
	if not self.nSystemCityId then
		return
	end

	--是否强制隐藏Ui
	if self.bIsHideByClickLayer then
		return
	end

	-- if self.pImgCity then
		--更新大小
		local nScale=self.pImgCity:getScale()
		local pSize = self.pImgCity:getContentSize() 
		-- if self.pPrevImgCitySize.width ~= pSize.width  or 
		-- 	self.pPrevImgCitySize.height ~= pSize.height then
		-- 	self.pPrevImgCitySize = pSize
			--中间置顶位置
			self.pMidPos = cc.p(self:getContentSize().width/2, pSize.height * nScale/2 + 80 )

			--申请城主,左上
			local fX, fY = self.pMidPos.x - pSize.width*0.25 *nScale, self.pMidPos.y - 20
			self.pLeftPos = cc.p(fX, fY)

			--图纸生成，右上
			local fX, fY = self.pMidPos.x + pSize.width*0.25 * nScale, self.pMidPos.y - 20
			self.pRightPos = cc.p(fX, fY)

			--城中心置底
			local fX, fY = UNIT_WIDTH/2+30 - 72, -pSize.height/4 * nScale
			self.pLayBarCd:setPosition(fX, fY)
		-- end
	-- end

	--更新国战按钮
	self:updateCountryWar()

	--是否显示图纸和是否显示申请城主
	local bIsShowPaper = false
	local bIsShowExclamation = false
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)

	if tCityData then
		--都城没有城征收
		if tCityData.kind == e_kind_city.ducheng or tCityData.kind == e_kind_city.zhongxing then
			--
		else
			
			if tViewDotMsg then
				--显示图纸
				if tViewDotMsg.nSysCountry ~= e_type_country.qunxiong then
					bIsShowPaper = true
				end
				--显示申请城主
				if not tViewDotMsg:getIsSysCityHasOwner() and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
					bIsShowExclamation = true
				end
			end
		end
	end
	
	if self.bEffectTest then
		bIsShowPaper = true
		bIsShowExclamation = true
	end
	if bIsShowPaper and bIsShowExclamation then
		self:showPaperUi(self.pLeftPos)
		self:showExclamationUi(self.pRightPos)
	elseif bIsShowPaper then
		self:showPaperUi(self.pMidPos)
		self:hideExclamationUi()
	elseif bIsShowExclamation then
		self:showExclamationUi(self.pMidPos)
		self:hidePaperUi()
	else
		self:hideExclamationUi()
		self:hidePaperUi()
	end
	--当有冒泡显示时强制隐藏城池名字
	if bIsShowExclamation or bIsShowPaper then
		--self:setNameVisible(false)
	end
	--这里马上刷新一遍得到征收显示的正确状态
	self:updatePaperCd()

	self:updatePaperJxCd()
	if tCityData and tViewDotMsg then
		if tCityData.kind <= e_kind_city.mingcheng and 
			tViewDotMsg.nSysCountry ~= e_type_country.qunxiong  and
			tViewDotMsg.nCurrGarrisonTroops < tViewDotMsg.nGarrisonTroopsMax then
			self.nEffectType = e_sys_city_effect.normal
		else
			self.nEffectType = e_sys_city_effect.none
		end 
	end
end

function SysCityDot:showPaperUi( pPos )
	local nAddY = 60
	local fX, fY = pPos.x, pPos.y + nAddY
	self.pImgPaper:setVisible(true)
	self.pImgPaperIcon:setVisible(true)
	self.pBbPaperTxt:setVisible(true)
	self.pImgPaper:setPosition3D(cc.vec3(fX , fY + n3dOffsetY, nPosZ + n3dOffsetZ))
	self.pImgPaperIcon:setPosition3D(cc.vec3(fX , fY - 1 + n3dOffsetY, nPosZ + n3dOffsetZ + 1))
	self.pBbPaperTxt:setPosition3D(cc.vec3(fX , fY - 20 + n3dOffsetY , nPosZ + n3dOffsetZ + 4))
	self.pLayPaperArm:setPosition3D(cc.vec3(fX ,  fY - 2 + n3dOffsetY, nPosZ + n3dOffsetZ + 2))
	self.pLayBarCd:setVisible(true)
	self.pLayPaperArm:setVisible(true)

	self.pLayPaperClick:setPosition(fX , fY - 20)
end
function SysCityDot:hidePaperUi()
	self.pImgPaper:setVisible(false)
	self.pImgPaperIcon:setVisible(false)
	self.pBbPaperTxt:setVisible(false)
	self.pLayBarCd:setVisible(false)
	self.pLayPaperArm:setVisible(false)
end
function SysCityDot:showExclamationUi( pPos )
	local nAddY = 60
	local fX, fY = pPos.x, pPos.y + nAddY
	self.pImgExclamation:setVisible(true)
	self.pImgExclamationIcon:setVisible(true)
	self.pBbExclamationTxt:setVisible(true)
	self.pImgExclamation:setPosition3D(cc.vec3(fX, fY + n3dOffsetY, nPosZ + n3dOffsetZ))
	self.pImgExclamationIcon:setPosition3D(cc.vec3(fX, fY-1 + n3dOffsetY, nPosZ + n3dOffsetZ + 1))
	self.pBbExclamationTxt:setPosition3D(cc.vec3(fX, fY - 1 + n3dOffsetY - 20, nPosZ + n3dOffsetZ + 4))

	self.pLayExclamationClick:setPosition(fX , fY - 20)
end
function SysCityDot:hideExclamationUi(  )
	self.pImgExclamation:setVisible(false)
	self.pImgExclamationIcon:setVisible(false)
	self.pBbExclamationTxt:setVisible(false)
end

--国战
function SysCityDot:updateCountryWar( )
	local bIsShow = false
	if self.nSystemCityId then
		local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)
		if tViewDotMsg and tViewDotMsg.bIsHasCountryWar then
			bIsShow = true
		end
	end

	-- self.pImgWar:setVisible(bIsShow)
	-- self.pImgWarIcon:setVisible(bIsShow)
	--隐藏或显示名字
	self:setNameVisible(not bIsShow)
	if bIsShow then
		--武器动画
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
		    self:addChild(self.pSwordArm,nSwordArmZorder)
		    WorldFunc.setCameraMaskForView(self.pSwordArm)
		end
	else
		self:hideSwordArm()
	end
end

--隐藏剑动画
function SysCityDot:hideSwordArm(  )
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

--更新图纸征收cd
function SysCityDot:updatePaperCd( )
	--容错
	if not self.nSystemCityId then
		--关掉宝箱特效
		self:showBoxEffect(false)
		return
	end
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if not tCityData then
		--关掉宝箱特效
		self:showBoxEffect(false)
		return
	end

	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)
	--图纸
	--显示图纸
	if tViewDotMsg and tViewDotMsg.nSysCountry ~= e_type_country.qunxiong and tCityData.dropcd > 0 then
		--显示完成
		local sPaperStr = ""
		if tViewDotMsg.bHasPaper or tViewDotMsg.bIsFirstKill then
			--显示特宝箱特效
			self:showBoxEffect(true)
			if self.pImgPaperIcon and self.pImgPaperIcon:isVisible() then
				self.pBbPaperTxt:setVisible(true)
			end
			--进度条
			-- self.pPaperCdBar:setSliderValue(100)
			-- sPaperStr = getConvertedStr(3, 10192)
		else--显示时间cd
			--关掉宝箱特效
			self:showBoxEffect(false)
			-- self.pBbPaperTxt:setVisible(false)
			--进度条
			local nCd = tViewDotMsg:getPaperCd()
			local fAllTime = tCityData.dropcd
			local fLeftTime = math.min(nCd, fAllTime)
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			-- self.pPaperCdBar:setSliderValue(nPercet)
			sPaperStr = formatTimeToHms(fLeftTime)

			-- print("SysCityDot 905",nCd,fAllTime)
		end

		--更新cd文字
		if self.sPaperStr ~= sPaperStr then
			self.sPaperStr = sPaperStr

			--设置内容
			self.pTxtPaperCd:setString(self.sPaperStr, false)
			--强制渲染一下
			self.pTxtPaperCd:updateContent()
			local tChildrens = self.pTxtPaperCd:getChildren()
			if(tChildrens[1]) then
			    local pTexture = tChildrens[1]:getTexture()
			    self.pBbPaperCd:setTexture(pTexture)
			    --重新设置一下大小
			    self.pBbPaperCd:setTextureRect(cc.rect(0,0,self.pTxtPaperCd:getContentSize().width,self.pTxtPaperCd:getContentSize().height))
	    	    --设置位置
			end
		end
	else
		--关掉宝箱特效
		self:showBoxEffect(false)
	end
end

--更新图纸征收cd
function SysCityDot:updatePaperJxCd( )
	--容错
	if not self.nSystemCityId then
		--关掉宝箱特效
		-- self:showBoxEffect(false)
		return
	end
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if not tCityData then
		--关掉宝箱特效
		-- self:showBoxEffect(false)
		return
	end

	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)
	
	if tViewDotMsg and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		--显示完成
		local sPaperStr = ""
		local nCd = tViewDotMsg:getCityOwnerApplyCd()
		if nCd > 0 then
			sPaperStr = formatTimeToHms(nCd)
		end

		--更新cd文字
		if self.sPaperJxStr ~= sPaperStr then
			self.sPaperJxStr = sPaperStr

			--设置内容
			self.pTxtPaperJxCd:setString(self.sPaperJxStr, false)
			--强制渲染一下
			self.pTxtPaperJxCd:updateContent()
			local tChildrens = self.pTxtPaperJxCd:getChildren()
			if(tChildrens[1]) then
			    local pTexture = tChildrens[1]:getTexture()
			    self.pBbPaperJxCd:setTexture(pTexture)
			    --重新设置一下大小
			    self.pBbPaperJxCd:setTextureRect(cc.rect(0,0,self.pTxtPaperJxCd:getContentSize().width,self.pTxtPaperJxCd:getContentSize().height))
	    	    --设置位置
			end
		end
	end
end

--宝箱特效显示
function SysCityDot:showBoxEffect( bIsShow )
	--减少刷新
	if self.bBoxEffectPrev == bIsShow then
		return
	end
	self.bBoxEffectPrev = bIsShow

	--显示
	if bIsShow then
		if not self.pCirclArmList then
			self.pCirclArmList = {}
			local tAllYellowTx = showYellowRing2(self.pLayPaperArm,2,nil,1,nil,Scene_arm_type.world, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
			for i=1,#tAllYellowTx do
				table.insert(self.pCirclArmList, tAllYellowTx[i])
				WorldFunc.setCameraMaskForView(tAllYellowTx[i])
			end
		else
			for i=1,#self.pCirclArmList do
				self.pCirclArmList[i]:setVisible(true)
				self.pCirclArmList[i]:play(-1)
			end
		end
	else
		if self.pCirclArmList then
			for i=1,#self.pCirclArmList do
				self.pCirclArmList[i]:setVisible(false)
				self.pCirclArmList[i]:stop()
			end
		end
	end
end

--------------------------------------------
--世界坐标
--fX,fY 世界坐标
function SysCityDot:checkIsClickedUis( fWorldX, fWorldY )
	local fX, fY = self:getPosition()
	local pAnchorPos =  self:getAnchorPoint()
	fX = fX - self:getContentSize().width * pAnchorPos.x
	fY = fY - self:getContentSize().height * pAnchorPos.y
	--点击纸
	if self.pImgPaper:isVisible() then
		local pUi = self.pLayPaperClick
		local fX1,fY1 = 0, 0
		local fX2,fY2 = pUi:getPosition()
		local pRect = pUi:getBoundingBox()
		pRect.x =  fX + fX1 + fX2 - pRect.width/2
		pRect.y =  fY + fY1 + fY2 - pRect.height/2
		local pTouchPos = cc.p(fWorldX, fWorldY)
		if cc.rectContainsPoint(pRect, pTouchPos) then
			self:onPaperClicked()
			return true
		end
	end

	-- --点击国战旗积
	-- if self.pImgWar:isVisible() then
	-- 	local fX1,fY1 = self:getPosition()
	-- 	local fX2,fY2 = 0, 0
	-- 	local pRect = self.pImgWar:getBoundingBox()
	-- 	pRect.x = fX1 + fX2 - pRect.width/2
	-- 	pRect.y = fY1 + fY2 - pRect.height/2
	-- 	local pTouchPos = cc.p(fWorldX, fWorldY)
	-- 	if cc.rectContainsPoint(pRect, pTouchPos) then
	-- 		self:onCountryWarClicked()
	-- 		return true
	-- 	end
	-- end

	--点击申请城主
	if self.pImgExclamation:isVisible() then
		local pUi = self.pLayExclamationClick
		local fX1,fY1 = 0, 0--self:getPosition()
		local fX2,fY2 = pUi:getPosition()
		local pRect = pUi:getBoundingBox()
		pRect.x = fX + fX1 + fX2 - pRect.width/2
		pRect.y = fY + fY1 + fY2 - pRect.height/2
		local pTouchPos = cc.p(fWorldX, fWorldY)
		if cc.rectContainsPoint(pRect, pTouchPos) then
			self:onExclamationClicked()
			return true
		end
	end

	return false
end

--图纸点击
function SysCityDot:onPaperClicked(  )
	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)
	--同势力
	if tViewDotMsg and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		--如果有首杀资格
		if tViewDotMsg.bIsFirstKill then
			SocketManager:sendMsg("reqSysCityFKPaper", {self.nSystemCityId})
		else
			local tObject = {
		    	nType = e_dlg_index.syscitydetail, --dlg类型
			    nSystemCityId = self.nSystemCityId,
			    nTab = 2,
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
		
	else --不同势力
		--单次确认框
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10366))
	    pDlg:setOnlyConfirm()
	    pDlg:showDlg(bNew)
	end
end

--叹号点击
function SysCityDot:onExclamationClicked(  )
	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSystemCityId)
	--同势力
	if tViewDotMsg and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		--判断是否已经申请中
		-- if tViewDotMsg.bIsApplyCityOwner then
			--申请候选人命令
			SocketManager:sendMsg("reqWorldCityCandidate", {self.nSystemCityId, 0})
 	-- 	else
 	-- 		--打开界面
		-- 	local tObject = {
		-- 	    nType = e_dlg_index.cityownerapply, --dlg类型
		-- 	    nSysCityId = self.nSystemCityId,
		-- 	}
		-- 	sendMsg(ghd_show_dlg_by_type, tObject)
		-- end
	else --不同势力
		--单次确认框
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10090))
	    pDlg:setOnlyConfirm()
	    pDlg:showDlg(bNew)
	end
end

--叹号点击
function SysCityDot:onCountryWarClicked(  )
	if not self.nSystemCityId then
		return
	end
	sendMsg(ghd_world_country_war_req_msg, self.nSystemCityId)
end


--设置UI是否隐藏
function SysCityDot:setDotUiVisible( bIsShow )
	if bIsShow then
		self.bIsHideByClickLayer = false
		self:updateSysCityUi()
	else
		self.bIsHideByClickLayer = true
		self:hideDotUis()
		self:setNameVisible(true)
	end
end

function SysCityDot:hideDotUis( )
	self:hidePaperUi()
	self:hideExclamationUi()
	-- self.pImgWar:setVisible(false)
	-- self.pImgWarIcon:setVisible(false)
	self:hideSwordArm()
end

--显示或隐藏扩展
function SysCityDot:setVisibleEx( bIsShow )
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
function SysCityDot:setNameVisible( bIsShow )
	self.pLayLvBg:setVisible(bIsShow)
	self.pTxtName:setVisible(false)

    self:setLvVisible(bIsShow)
end

--设置等级是否显示
function SysCityDot:setLvVisible( bIsShow )
	-- body
    --print("=========>function SysCityDot:setLvVisible( bIsShow )", bIsShow, self.tData:getSysCityOwnerName() == nil)
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
function SysCityDot:delViewDotMsg( )
	self:removeMingjieEffect()
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end

function SysCityDot:onShowMingjieEffect(  )
	if not self.tData then
		return
	end
	-- body
	--创建新的任务线路
	--创建新的任务推送线路
	local bShowEffect = false
	local tData = Player:getActById(e_id_activity.mingjie)
	--中心城
	local bIsCenter = getWorldCityIsCenter(self.tData.nSystemCityId)
	if tData and tData.nS == 2 and bIsCenter then
		bShowEffect = true
	end

	if bShowEffect then
		self.nEffectType = e_sys_city_effect.ghost
		-- self:showMingjieEffect()
	-- else
	-- 	if self.nEffectType ~= e_sys_city_effect.none then

	-- 	end
		-- self:removeMingjieEffect()
	end
end

function SysCityDot:showMingjieEffect(  )
	-- body
	-- 图片大小
	if #self.tNormalParitcles > 0 then
		self:removeNormalEffect()
	end

    local  nScale = self.pImgCity:getScale()
    local  nRealWidth = self.pImgCity:getWidth() * nScale
    local  nRealHeight = self.pImgCity:getHeight() * nScale
	self.pImgCity:setCurrentImage("#v1_img_mj_huang03.png")
	local  nRealScale = nRealWidth/self.pImgCity:getWidth()
	if not self.pLayParitcle then
		self.pLayParitcle = MUI.MLayer.new()
		self.pLayParitcle:setAnchorPoint(0,0)
		self.pLayParitcle:setLayoutSize(1, 1)
		self.pLayParitcle:setPosition(UNIT_WIDTH/2,UNIT_HEIGHT/2 + 30)
		self:addChild(self.pLayParitcle,1000)
	end
	self.pLayParitcle:setVisible(true)
	self.pLayParitcle:setScale(1)
	
	self.pImgCity:setScale(nRealScale)
	if #self.tMingjieParitcles <= 0  then
		self.tMingjieParitcles = showMingjieWorldEffect(self.pLayParitcle)
		WorldFunc.setCameraMaskForView(self.pLayParitcle)
	end
end

function SysCityDot:showNormalEffect(  )
	-- body
	-- 图片大小
	if #self.tMingjieParitcles > 0 then
		self:removeMingjieEffect()
	end
	if not self.pNorEffectImg then
		self.pNorEffectImg = MUI.MImage.new("#v1_img_hong01_sh.png")
		self.pNorEffectImg:setAnchorPoint(cc.p(0,0))
		self.pImgCity:addChild(self.pNorEffectImg,1000)
		WorldFunc.setCameraMaskForView(self.pNorEffectImg)
	end
	local sImg = "#v1_img_hong01_sh.png"
	local nImgScale = 1
	local nEffectScale = 1
	if self.nCityKind == e_kind_city.junyin or 
		self.nCityKind == e_kind_city.zhouxian then
		sImg = "#v1_img_hong01_sh.png"
	elseif self.nCityKind == e_kind_city.junxian or
		self.nCityKind == e_kind_city.zhoufu then 
		sImg = "#v1_img_hong02_sh.png"
	elseif self.nCityKind == e_kind_city.juncheng or
		self.nCityKind == e_kind_city.mingcheng or
		self.nCityKind == e_kind_city.zhoucheng then 
		sImg = "#v1_img_hong03_sh.png"
		nImgScale = 2
		nEffectScale = 1.2
	end
	self.pNorEffectImg:setCurrentImage(sImg)
	self.pNorEffectImg:setScale(nImgScale)


    local  nScale = self.pImgCity:getScale()
    local  nRealWidth = self.pImgCity:getWidth() * nScale
    local  nRealHeight = self.pImgCity:getHeight() * nScale
	local  nRealScale = nRealWidth/self.pImgCity:getWidth()
	if not self.pLayParitcle then
		self.pLayParitcle = MUI.MLayer.new()
		self.pLayParitcle:setAnchorPoint(0,0)
		self.pLayParitcle:setLayoutSize(1, 1)
		self.pLayParitcle:setPosition(UNIT_WIDTH/2,UNIT_HEIGHT/2 + 10)
		self:addChild(self.pLayParitcle,1000)
	end
	self.pLayParitcle:setVisible(true)
	self.pLayParitcle:setScale(nEffectScale)
	if #self.tNormalParitcles <= 0  then
		self.tNormalParitcles = showNormalWorldEffect(self.pLayParitcle)
		WorldFunc.setCameraMaskForView(self.pLayParitcle)
	end
end

function SysCityDot:removeMingjieEffect(  )
	-- body
	if self.pLayParitcle  then
		for i=1,#self.tMingjieParitcles do
			local v= self.tMingjieParitcles[i]
			v:removeSelf()
			v = nil
		end
		self.tMingjieParitcles={}
		self.pLayParitcle:setVisible(false)
		
		-- self.pLayParitcle = nil
	end
end

function SysCityDot:removeNormalEffect(  )
	-- body
	if self.pLayParitcle  then
		for i=1,#self.tNormalParitcles do
			local v= self.tNormalParitcles[i]
			v:removeSelf()
			v = nil
		end
		self.tNormalParitcles={}
		self.pLayParitcle:setVisible(false)
	end
	if self.pNorEffectImg then
		self.pNorEffectImg:removeSelf()
		self.pNorEffectImg=nil
	end
end

function SysCityDot:showFireEffect( )
	-- body

	if self.nEffectType == e_sys_city_effect.ghost then
		self:showMingjieEffect()
	elseif self.nEffectType == e_sys_city_effect.normal then
		self:showNormalEffect()
	else
		if #self.tMingjieParitcles > 0 then
			self:removeMingjieEffect()
		end
		if #self.tNormalParitcles then
			self:removeNormalEffect()
		end
	end

end

return SysCityDot