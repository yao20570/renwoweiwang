-- DlgLevelUpAwards.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-07-04 11:23:14 星期二
-- Description: 升级奖励弹窗
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgLevelUpAwards = class("DlgLevelUpAwards", function()
	-- body
	--addTextureToCache("tx/other/sg_jssj_zjm_2s3")
	--addTextureToCache("tx/other/sg_jssj_zjm_2x3")
	return MDialog.new(e_dlg_index.dlglevelupawards)
end)

function DlgLevelUpAwards:ctor(_tData, _nType)
	-- body
	self:myInit(_tData, _nType)
	parseView("dlglevelup", handler(self, self.onParseViewCallback))

    --设置背景颜色
	self:setDialogBgColor(cc.c4b(0, 0, 0, 127))
	self:setIsNeedOutside(false)
end

--初始化成员变量
function DlgLevelUpAwards:myInit(_tData, _nType)
	self.nType = _nType or 0 --0 等级奖励提示 1 Vip等级提示
	if self.nType == 0 then
		self.tLvAwards = getDropItemsShow( _tData )
		-- if self.tLvAwards then
		-- 	local tTemp={}
		-- 	for k,v in pairs(self.tLvAwards) do
		-- 		local tData = v.item
		-- 		local tItem={k=tData.sTid,v=tData.nCt}
		-- 		table.insert(tTemp,tItem)
				
		-- 	end
		-- 	showGetItemsAction(tTemp)
		-- end
	elseif self.nType == 1 then
		local tPrivileges = luaSplitMuilt(_tData, "|", ":")
		--dump(tPrivileges, "tPrivileges", 100)
		self.tLvAwards = {}
		for k, v in pairs(tPrivileges) do
			local nItemID 	= 	tonumber(v[1] or 0) --物品iD
			local sDes 		= 	v[2]
			local pItem 	= 	getBaseItemDataByID(nItemID)
			if pItem then
				pItem.sName = pItem.sName..sDes				
				table.insert(self.tLvAwards, pItem)
			end
		end
		--dump(self.tLvAwards, "self.tLvAwards", 100)		
	end
end

--解析布局回调事件
function DlgLevelUpAwards:onParseViewCallback( pView )
	--img
	self.pImgBg  = pView:findViewByName("img_bg") --背景图片

    -- 如果是低分辨率设备的情况下
    local isLow  = getIsTargetLow()
    if isLow then
        --计算缩放比例
        local fScale = self:getHeight() / pView:getHeight()
        local pVg = MUI.MLayer.new()
        pVg:setContentSize(self:getContentSize())
        pView:setScale(fScale)
        pVg:addView(pView)

		
		self.pImgBg:setContentSize(cc.size(display.width/fScale, display.height/fScale))
        centerInView(pVg,pView)
        self:setContentView(pVg)
    else
		self:setContentView(pView) --加入内容层
        self.pImgBg:setContentSize(display.width, display.height)
        centerInView(pVg,pView)
        -- self:addView(pView)
    end
	--self:setContentView(pView)	
	self:setupViews()	
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgLevelUpAwards",handler(self, self.onDlgLevelUpAwardsDestroy))
end

--初始化控件
function DlgLevelUpAwards:setupViews()
	-- body
	self.pLayRoot             = self:findViewByName("default")
	self.pLayMain 			  = self:findViewByName("ly_main")

	self.pLayCont = self:findViewByName("lay_content")
	self.pLayRoot:setViewTouched(false)
	-- self.pLayRoot:onMViewClicked(handler(self, self.onBtnClicked))

	--确定按钮
	self.pLayBtn              = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(7,10108))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	self.pBtn:setVisible(false)

	--lb
	self.pLbAwd               = self:findViewByName("lb_awd")
	if self.nType == 0 then
		self.pLbAwd:setString(getConvertedStr(7,10109))
	else
		self.pLbAwd:setString(getConvertedStr(6,10536))		
	end
	self.pLbAwd:setVisible(false)

	--奖励层
	self.pLayAwards1 = self:findViewByName("lay_awards_1")
	self.pLayAwards2 = self:findViewByName("lay_awards_2")
	local pLayIcon1 = self:findViewByName("lay_icon1")
	local pLayIcon2 = self:findViewByName("lay_icon2")
	local pLayIcon3 = self:findViewByName("lay_icon3")
	local pLayIcon4 = self:findViewByName("lay_icon4")
	local pLayIcon5 = self:findViewByName("lay_icon5")
	local pLayIcon6 = self:findViewByName("lay_icon6")
	self.pLayIcons = {
		pLayIcon1,
		pLayIcon2,
		pLayIcon3,
		pLayIcon4,
		pLayIcon5,
		pLayIcon6,
	}
	for i=1, #self.pLayIcons do
		self.pLayIcons[i]:setPositionY(self.pLayIcons[i]:getPositionY() - 20)
		self.pLayIcons[i]:setVisible(false)
	end
	self.nIconWidth = pLayIcon1:getContentSize().width

	
end

function DlgLevelUpAwards:updateViews()
	-- body
	self:showTx()
end

--刷新物品显示
function DlgLevelUpAwards:updateItemVisible(  )
	-- body
	local nCt =  table.nums(self.tLvAwards)
	if nCt <= 3 then
		for i = 1, nCt do
			self.pLayIcons[i]:setPositionY(0 - self.nIconWidth/2 - 20)
		end

		local nNum = math.min(6, nCt)
		local nW = 430 / nNum
		local nH = 340 / nNum
		for i=1,nNum do
			local nX = (i - 1) * nW + nW / 2 - self.nIconWidth / 2
			if self.pLayIcons[i] then
				self.pLayIcons[i]:setPositionX(nX)
			end
		end
	end

	for i = 1, 6 do
		local tIconData = self.tLvAwards[i]
		if tIconData then
			local pItem = nil
			if self.nType == 0 then
				pItem = getIconGoodsByType(self.pLayIcons[i], TypeIconGoods.HADMORE, type_icongoods_show.itemnum, tIconData.item, TypeIconEquipSize.L)
			else
				pItem = getIconGoodsByType(self.pLayIcons[i], TypeIconGoods.HADMORE, type_icongoods_show.item, tIconData, TypeIconEquipSize.L)
			end
			centerInView(self.pLayIcons[i], pItem)
			self.pLayIcons[i]:setVisible(true)
		else
			self.pLayIcons[i]:setVisible(false)
		end
	end	
end

function DlgLevelUpAwards:showTx()
	doDelayForSomething(self, function ( ... )
		-- body
		local nArmTag = 89754
		local sName = createAnimationBackName("tx/exportjson/", "sg_jssj_jm_tx_001")
	    local pArm = ccs.Armature:create(sName)
	    --替换骨骼
	    if self.nType == 0 then
	    	changeBoneWithPngAndScale(pArm,"djtsth001","#sg_jssj_zjm_s_x_005.png",false) 
		else
			changeBoneWithPngAndScale(pArm,"djtsth001","#v1_fonts_VIPtfce.png",false) 
		end

		if self.nType == 0 then
	    	changeBoneWithPngAndScale(pArm,"djtsth002","#sg_jssj_zjm_s_x_005.png",true) 
		else
			changeBoneWithPngAndScale(pArm,"djtsth002","#v1_fonts_VIPtfce.png",true) 
		end
		--等级
	    local nLv = Player:getPlayerInfo().nLv	
	    if self.nType == 1 then
	    	nLv =  Player:getPlayerInfo().nVip
	    end
		local pLbLevel = MUI.MLabelAtlas.new({text=tostring(nLv), 		
	    png="ui/atlas/v1_fonts_tffuxeovpb.png", pngw=26, pngh=42, scm=48})	
	    changeBoneWithNodeAndScale(pArm,"djth001",pLbLevel)  

	    local pLbLevel = MUI.MLabelAtlas.new({text=tostring(nLv), 		
	    png="ui/atlas/sg_jssj_zjm_zt_dj.png", pngw=26, pngh=43, scm=48})	
	    changeBoneWithNodeAndScale(pArm,"djth002",pLbLevel)    

	    changeBoneWithPngAndScale(pArm,"lgth001","ui/big_img/sg_dzjs_zzsk_xk_0x01.png")

	    changeBoneWithPngAndScale(pArm,"qbth001","ui/sg_dzjs_zzsk_xk_008.png", false, cc.p(0.5, 1))

        local posY = 618

	    pArm:setPosition(320,posY)
	    self.pLayMain:addChild(pArm,10,nArmTag)
	    pArm:getAnimation():play("Animation1", 1)

		pArm:getAnimation():setFrameEventCallFunc(function ( pBone, frameEventName, originFrameIndex, currentFrameIndex ) 
			if frameEventName == "gxcx01" then		
				--dump("gxcx01")		
				local pParitcle = createParitcle("tx/other/lizi_jiesjm_002.plist")
				pParitcle:setPosition(320,800)
				self.pLayMain:addView(pParitcle,0)	

				self:creatLightImg()
				local pDelay = cc.DelayTime:create(0.45)
				local fCallback = cc.CallFunc:create(function (  )
					self:creatLightImg()
				end)		
				self.pLayMain:runAction(cc.RepeatForever:create(cc.Sequence:create(pDelay,fCallback)))	
			elseif frameEventName == "wpcx01" then
				--dump("wpcx01")
				self.pLbAwd:setVisible(true)
				self:updateItemVisible()
				local nCt =  table.nums(self.tLvAwards)
				if nCt >= 1 and nCt <= 3 then
					local pOriY = self.pLayAwards1:getPositionY() 
					self.pLayAwards1:setPositionY(pOriY-100)
					self.pLayAwards1:setOpacity(0)

					local pMoveTo =  cc.MoveTo:create(0.15, cc.p(self.pLayAwards1:getPositionX(),pOriY))
					local pFadeTo1  = cc.FadeTo:create(0.15, 255)
					local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

					self.pLayAwards1:runAction(cc.Sequence:create(action1))
				elseif nCt >= 4  then
					local pOriY = self.pLayAwards1:getPositionY() 
					self.pLayAwards1:setPositionY(pOriY-100)
					self.pLayAwards1:setOpacity(0)

					local pOriY2 = self.pLayAwards2:getPositionY() 
					self.pLayAwards2:setPositionY(pOriY2-100)
					self.pLayAwards2:setOpacity(0)

					local pMoveTo =   cc.MoveTo:create(0.15, cc.p(self.pLayAwards1:getPositionX(),pOriY))
					local pFadeTo1  = cc.FadeTo:create(0.15, 255)
					local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

					local fCallback = cc.CallFunc:create(function (  )

						local pMoveTo2 =   cc.MoveTo:create(0.15, cc.p(self.pLayAwards2:getPositionX(),pOriY2))
						local pFadeTo2  = cc.FadeTo:create(0.15, 255)
						local action2 = cc.Spawn:create(pMoveTo2,pFadeTo2)
						self.pLayAwards2:runAction(cc.Sequence:create(action2,fCallback2))

					end)
					self.pLayAwards1:runAction(cc.Sequence:create(action1,fCallback))
				end
				self.pBtn:setVisible(true)
			elseif frameEventName == "slzd01" then					
				--dump("slzd01")
				--self.pLayMain:stopAllActions()

				local pMoveTo1 = cc.MoveTo:create(0, cc.p(0,-3))
				local pMoveTo2 = cc.MoveTo:create(0.1, cc.p(0,1))
				local pMoveTo3 = cc.MoveTo:create(0.05, cc.p(0,0))

				self.pLayMain:runAction(cc.Sequence:create(pMoveTo1,pMoveTo2,pMoveTo3)) 			
			elseif frameEventName == "sgcxsj01" then	--龙骨等光效				
				-- body
				local tArm1 = createMArmature(self.pLayMain, {
                    sPlist = "tx/other/sg_jssj_zjm_2s3",
                    nImgType = 1,
					nFrame = 15, -- 总帧数
					pos = {-26, 271}, -- 特效的x,y轴位置（相对中心锚点的偏移）
					fScale = 1,-- 初始的缩放值
					nBlend = 1, -- 需要加亮
				   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
					tActions = {
						 {
							nType = 1, -- 序列帧播放
							sImgName = "sg_jssj_zjm_2s3_",
							nSFrame = 1, -- 开始帧下标
							nEFrame = 15, -- 结束帧下标
							tValues = nil, -- 参数列表
						},
					},
				} ,function ( )
					-- body

				end,cc.p(320,posY), 20)
				local tArm2 = createMArmature(self.pLayMain, {
                    sPlist = "tx/other/sg_jssj_zjm_2s3",
                    nImgType = 1,
					nFrame = 15, -- 总帧数
					pos = {29, 271}, -- 特效的x,y轴位置（相对中心锚点的偏移）
					fScale = 1,-- 初始的缩放值
					fScaleX = -1,
					fScaleY = 1,
					nBlend = 1, -- 需要加亮
				   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
					tActions = {
						 {
							nType = 1, -- 序列帧播放
							sImgName = "sg_jssj_zjm_2s3_",
							nSFrame = 1, -- 开始帧下标
							nEFrame = 15, -- 结束帧下标
							tValues = nil, -- 参数列表
						},
					},
				} ,function ( )
				-- body

				end,cc.p(320,posY), 20)
				if tArm1 and tArm2 then

				end

				local tArmRightData  = {
                    sPlist = "tx/other/sg_jssj_zjm_2x3",
                    nImgType = 1,
					nFrame = 13, -- 总帧数
					pos = {250, 290}, -- 特效的x,y轴位置（相对中心锚点的偏移）
					fScale = 1,-- 初始的缩放值
					nBlend = 1, -- 需要加亮
				   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
					tActions = {
						 {
							nType = 1, -- 序列帧播放
							sImgName = "sg_jssj_zjm_2x3_",
							nSFrame = 1, -- 开始帧下标
							nEFrame = 13, -- 结束帧下标
							tValues = nil, -- 参数列表
						},
					},
				}
				local pArmRight = createMArmature(self.pLayMain, tArmRightData ,function ( )
					-- body
					if tArm2 then
						tArm2:play(1)
					end
				end,cc.p(320,posY), 20)

				local tArmLeftData  = {
                    sPlist = "tx/other/sg_jssj_zjm_2x3",
                    nImgType = 1,
					nFrame = 13, -- 总帧数
					pos = {-244, 290}, -- 特效的x,y轴位置（相对中心锚点的偏移）
					fScale = 1,-- 初始的缩放值
					fScaleX = -1,
					fScaleY = 1,
					nBlend = 1, -- 需要加亮
				   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
					tActions = {
						 {
							nType = 1, -- 序列帧播放
							sImgName = "sg_jssj_zjm_2x3_",
							nSFrame = 1, -- 开始帧下标
							nEFrame = 13, -- 结束帧下标
							tValues = nil, -- 参数列表
						},
					},
				}
				local pArmLeft = createMArmature(self.pLayMain, tArmLeftData ,function ( )
					-- body
					if tArm1 then
						tArm1:play(1)
					end
				end,cc.p(320,posY), 20)


				self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function (  )
					-- body
					if pArmLeft and pArmRight then
						pArmLeft:play(1)
						pArmRight:play(1)
					end			
				end), cc.DelayTime:create(5)))) 
			end
		end) 

	end, 0.08)


end

--创建光芒图片
function DlgLevelUpAwards:creatLightImg()
	-- body
	local nRold =  math.random(0,360)
	local pImg =  MUI.MImage.new("#sg_slhmdg_zdg_01.png")
	pImg:setRotation(nRold)
	pImg:setAnchorPoint(0.5,0.5)
	pImg:setScale(0.96*0.95)
	pImg:setOpacity(0)
	pImg:setPosition(320,783)
	self.pLayMain:addView(pImg,1)

	local pImg1 =  MUI.MImage.new("#sg_slhmdg_zdg_01.png")
	pImg1:setRotation(nRold)
	pImg1:setAnchorPoint(0.5,0.5)
	pImg1:setScale(0.96)
	pImg1:setOpacity(0)
	pImg1:setPosition(320,783)
    pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	self.pLayMain:addView(pImg1,1)

	for i=1,2 do
		local pOj = nil
		if i== 1 then
			pOj = pImg
		elseif i ==2 then
			pOj = pImg1
		end

		if pOj then
			local pScaleTo1 =  cc.ScaleTo:create(0.5, 1.19*0.95)
			local pFadeTo1  = cc.FadeTo:create(0.5, 255)
			local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

			local pScaleTo2 =  cc.ScaleTo:create(0.65, 1.48*0.95)
			local pFadeTo2  = cc.FadeTo:create(0.65, 0)
			local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)

			local fCallback = cc.CallFunc:create(function (  )
				pOj:removeFromParent(true)
			end)

			pOj:runAction(cc.Sequence:create(action1,action2,fCallback))
		end
	end

end
--按钮点击事件
function DlgLevelUpAwards:onBtnClicked()
	-- body

	if self.nType == 0 then
		if self.tLvAwards then
			local tTemp={}
			for k,v in pairs(self.tLvAwards) do
				local tData = v.item
				local tItem={k=tData.sTid,v=tData.nCt}
				table.insert(tTemp,tItem)
								
			end
			showGetItemsAction(tTemp)
		end
	elseif self.nType == 1 then
	end	
	self:closeDlg(false)
end


-- 析构方法
function DlgLevelUpAwards:onDlgLevelUpAwardsDestroy(  )
	-- body
	self:onPause()
	--显示
	showNextSequenceFunc(e_show_seq.kindreward)
	--removeTextureFromCache("tx/other/sg_jssj_zjm_2s3")
	--removeTextureFromCache("tx/other/sg_jssj_zjm_2x3")
end

--注册消息
function DlgLevelUpAwards:regMsgs(  )
	-- bod
end
--注销消息
function DlgLevelUpAwards:unregMsgs(  )
	-- body
end

-- 暂停方法
function DlgLevelUpAwards:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgLevelUpAwards:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgLevelUpAwards