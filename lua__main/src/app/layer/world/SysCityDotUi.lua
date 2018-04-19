----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-16 10:28:30
-- Description: 系统城池视图点 ui层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
-- local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgAlert = require("app.common.dialog.DlgAlert")
local SysCityDotUi = class("SysCityDotUi", function()
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	return pView
end)

function SysCityDotUi:ctor( pSysCityDot )
	self.pSysCityDot = pSysCityDot
	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
	--解析文件
	parseView("layout_world_sys_city_ui", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityDotUi:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SysCityDotUi",handler(self, self.onSysCityDotUiDestroy))
end

-- 析构方法
function SysCityDotUi:onSysCityDotUiDestroy(  )
    self:onPause()
end

function SysCityDotUi:regMsgs(  )
end

function SysCityDotUi:unregMsgs(  )
end

function SysCityDotUi:onResume(  )
	self:regMsgs()
end

function SysCityDotUi:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function SysCityDotUi:setupViews(  )
	self.pLayPaperGroup = self:findViewByName("lay_paper_group")

	--cd条
	local pLayBarCd = self:findViewByName("lay_bar_cd")
	pLayBarCd:setBackgroundImage("ui/bar/v1_bar_bscd.png")
	-- local pSize = pLayBarCd:getContentSize()
	-- self.pPaperCdBar = MCommonProgressBar.new({bar = "v1_bar_blue_1.png", barWidth = pSize.width, barHeight = pSize.height})
	-- self.pPaperCdBar:setPosition(pSize.width/2, pSize.height/2)
	-- pLayBarCd:addView(self.pPaperCdBar)
	self.pPaperCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
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
    self.pPaperCdBar:setViewTouched(false)
	pLayBarCd:addView(self.pPaperCdBar, 10)
	local nX, nY = self.pPaperCdBar:getPosition()
	self.pPaperCdBar:setPosition(nX+1, nY+5)

	--cd文字
	self.pTxtCd = self:findViewByName("txt_cd")

	--paper
	local p21 = self:findViewByName("img_paper")
	local p22 = self:findViewByName("img_paper_icon")
	p21:setVisible(false)
	p22:setVisible(false)
	self.pImgPaper = createCCBillBorad("#v1_img_qipao2.png")
	self:addView(self.pImgPaper)
	self.pImgPaperIcon = createCCBillBorad("#v1_img_zjm_hd.png")
	self:addView(self.pImgPaperIcon)
	self.pLayPaperEffect = self:findViewByName("lay_paper_effect")
	self.pLayPaperTime = self:findViewByName("lay_tt")
	self.pLayPaperTime:setPositionY(-30)
	

	--exclamation
	local p1 = self:findViewByName("img_exclamation")
	local p2 = self:findViewByName("img_exclamation_icon")
	p1:setVisible(false)
	p2:setVisible(false)


	self.pImgExclamation = createCCBillBorad("#v1_img_qipao2.png")
	self:addView(self.pImgExclamation)
	self.pImgExclamationIcon = createCCBillBorad("#v1_btn_czdl.png")
	self:addView(self.pImgExclamationIcon)

	--国战
	self.pImgWar = self:findViewByName("img_war")
	self.pImgWarIcon = self:findViewByName("img_war_icon")
	self.pLayFlagEffect = self:findViewByName("lay_flag_effect")


	--位置
	self.pMidPos = cc.p(80, 158)
	self.pLeftPos = cc.p(32, 158)
	self.pRightPos = cc.p(128, 158)

end

--nSysCityId:系统城池id
function SysCityDotUi:setData( nSysCityId )
	self.nSysCityId = nSysCityId
	self:updateViews()

	--更新
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateCd()
end

function SysCityDotUi:updateViews(  )
	--容错
	if not self.nSysCityId then
		return
	end
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if not tCityData then
		return
	end

	--更新国战列表
	self:updateCountryWar()

	--都城没有城征收
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		if tCityData.kind == e_kind_city.ducheng or tCityData.kind == e_kind_city.zhongxing then
			--隐藏图纸
			self.pLayPaperGroup:setVisible(false)
			self:setPaperVisibleState(false)
			--隐藏申请城主
			self.pImgExclamation:setVisible(false)
			self.pImgExclamationIcon:setVisible(false)
			return
		end
	end

	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	--显示图纸
	if tViewDotMsg and tViewDotMsg.nSysCountry ~= e_type_country.qunxiong then
		self.pLayPaperGroup:setVisible(true)
		self:setPaperVisibleState(true)
	else
		self.pLayPaperGroup:setVisible(false)
		self:setPaperVisibleState(false)
	end

	--没有城主时且是我方城池显示
	local bIsShow = false
	if tViewDotMsg and not tViewDotMsg:getIsSysCityHasOwner() and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		bIsShow = true
	end

	self.pImgExclamation:setVisible(bIsShow)
	self.pImgExclamationIcon:setVisible(bIsShow)

	--当叹号和图纸都显示时，改变位置
	local bIsExclamationVisible = self.pImgExclamation:isVisible()
	local bIsPaperVisible = self.pLayPaperGroup:isVisible()
	if bIsExclamationVisible and bIsPaperVisible then
		self.pImgExclamation:setPosition(self.pLeftPos)
		self.pImgExclamationIcon:setPosition(cc.p(self.pLeftPos.x,self.pLeftPos.y - 1))

		self.pImgPaper:setPosition(self.pRightPos)
		self.pImgPaperIcon:setPosition(cc.p(self.pRightPos.x,self.pRightPos.y - 1))
		self.pLayPaperEffect:setPosition(self.pRightPos.x - 25, self.pRightPos.y - 25)

	elseif bIsExclamationVisible then

		self.pImgExclamation:setPosition(self.pMidPos)
		self.pImgExclamationIcon:setPosition(cc.p(self.pMidPos.x,self.pMidPos.y - 1))

	elseif bIsPaperVisible then
		self.pImgPaper:setPosition(self.pMidPos)
		self.pImgPaperIcon:setPosition(cc.p(self.pMidPos.x,self.pMidPos.y - 1))
		self.pLayPaperEffect:setPosition(self.pMidPos.x - 25, self.pMidPos.y - 25)
	end

	--当有冒泡显示时强制隐藏城池名字
	if bIsExclamationVisible or bIsPaperVisible then
		self.pSysCityDot:setNameVisible(false)
	end

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--国战
function SysCityDotUi:updateCountryWar( )
	if not self.nSysCityId then
		self.pImgWar:setVisible(false)
		self.pImgWarIcon:setVisible(false)
		self.pLayFlagEffect:setVisible(false)
		self:showCountryWarEffect(false)
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if tViewDotMsg and tViewDotMsg.bIsHasCountryWar then
		self.pImgWar:setVisible(true)
		self.pImgWarIcon:setVisible(true)
		self.pLayFlagEffect:setVisible(true)
		self:showCountryWarEffect(true)
	else
		self.pImgWar:setVisible(false)
		self.pImgWarIcon:setVisible(false)
		self.pLayFlagEffect:setVisible(false)
		self:showCountryWarEffect(false)
	end
end

--更新图纸cd时间
function SysCityDotUi:updateCd( )
	if not self.nSysCityId then
		--关掉宝箱特效
		self:showBoxEffect(false)
		--停止倒计时
		unregUpdateControl(self)
		return
	end

	local tCityData = getWorldCityDataById(self.nSysCityId)
	if not tCityData then
		--关掉宝箱特效
		self:showBoxEffect(false)
		--停止倒计时
		unregUpdateControl(self)
		return
	end

	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	--图纸
	--显示图纸
	if tViewDotMsg and tViewDotMsg.nSysCountry ~= e_type_country.qunxiong and tCityData.dropcd > 0 then
		-- self.pLayPaperGroup:setVisible(true)
		--显示完成
		if tViewDotMsg.bHasPaper then
			--显示特宝箱特效
			self:showBoxEffect(true)

			self.pPaperCdBar:setSliderValue(100)
			self.pTxtCd:setString(getConvertedStr(3, 10192),false)
			--停止倒计时
			unregUpdateControl(self)
		else--显示时间cd
			--关掉宝箱特效
			self:showBoxEffect(false)

			local nCd = tViewDotMsg:getPaperCd()
			local fAllTime = tCityData.dropcd
			local fLeftTime = math.min(nCd, fAllTime)
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			self.pPaperCdBar:setSliderValue(nPercet)
			self.pTxtCd:setString(formatTimeToHms(fLeftTime),false)
			--设置相机类型
			WorldFunc.setCameraMaskForView(self.pTxtCd)
		end
	else
		--关掉宝箱特效
		self:showBoxEffect(false)
		-- self.pLayPaperGroup:setVisible(false)
		--停止倒计时
		unregUpdateControl(self)
	end
end

--宝箱特效显示
function SysCityDotUi:showBoxEffect( bIsShow )
	self.pLayPaperEffect:setVisible(bIsShow)

	if bIsShow then
		if not self.pBoxArm then
			local pBoxArm = MArmatureUtils:createMArmature(EffectWorldDatas["sysCityUiBox"], 
			self.pLayPaperEffect, 
			0, 
			cc.p(25, 25),
		    function (  )
			end, Scene_arm_type.world)
			pBoxArm:play(-1)
			self.pBoxArm = pBoxArm
		else
			self.pBoxArm:play(-1)
		end
		if not self.pCirclArm then
			local pCirclArm = MArmatureUtils:createMArmature(EffectWorldDatas["sysCityUiLight"], 
			self.pLayPaperEffect, 
			0, 
			cc.p(25, 25),
		    function (  )
			end, Scene_arm_type.world)
			pCirclArm:play(-1)
			self.pCirclArm = pCirclArm
		else
			self.pCirclArm:play(-1)
		end
	else
		if self.pBoxArm then
			self.pBoxArm:stop()
		end
		if self.pCirclArm then
			self.pCirclArm:stop()
		end
	end
end

--国战特效显示
function SysCityDotUi:showCountryWarEffect( bIsShow )
	if bIsShow then
		if not self.pWarArm then
			local pWarArm = MArmatureUtils:createMArmature(EffectWorldDatas["sysCityUiFlag"], 
			self.pLayFlagEffect, 
			0, 
			cc.p(25, 25),
		    function (  )
			end, Scene_arm_type.world)
			pWarArm:play(-1)
			self.pWarArm = pWarArm
		else
			self.pWarArm:play(-1)
		end
	else
		if self.pWarArm then
			self.pWarArm:stop()
		end
	end
end

--图纸点击
function SysCityDotUi:onPaperClicked(  )
	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	--同势力
	if tViewDotMsg and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		--如果有首杀资格
		if tViewDotMsg.bIsFirstKill then
			SocketManager:sendMsg("reqSysCityFKPaper", {self.nSysCityId})
		else
			local tObject = {
		    	nType = e_dlg_index.syscitycollect, --dlg类型
			    nSysCityId = self.nSysCityId,
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
function SysCityDotUi:onExclamationClicked(  )
	--服务器数据
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	--同势力
	if tViewDotMsg and tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
		local tObject = {
		    nType = e_dlg_index.cityownerapply, --dlg类型
		    nSysCityId = self.nSysCityId,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
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
function SysCityDotUi:onCountryWarClicked(  )
	if not self.nSysCityId then
		return
	end
	sendMsg(ghd_world_country_war_req_msg, self.nSysCityId)
end

--设置图纸显示或隐藏状态
function SysCityDotUi:setPaperVisibleState( bIsShow )
	self.pSysCityDot:setLvVisible(not bIsShow)
end

return SysCityDotUi


