----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-24 11:37:27
-- Description: 出征武将面板 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgAlert = require("app.common.dialog.DlgAlert")
local nEffectZorder = 99

local ItemBattleHero = class("ItemBattleHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBattleHero:ctor( nNum )
	self.nNUms = nNum
	self.bIsFirstSelected = true
	--解析文件
	parseView("item_battle_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemBattleHero:onParseViewCallback( pView )
	self.pCSView = pView
	pView:setViewTouched(true)
	pView:setIsPressedNeedScale(false)
	pView:onMViewClicked(handler(self, self.onSelectedHero))

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemBattleHero",handler(self, self.onItemBattleHeroDestroy))
end

-- 析构方法
function ItemBattleHero:onItemBattleHeroDestroy(  )
    self:onPause()
end

function ItemBattleHero:regMsgs(  )
end

function ItemBattleHero:unregMsgs(  )
end

function ItemBattleHero:onResume(  )
	self:regMsgs()
end

function ItemBattleHero:onPause(  )
	self:unregMsgs()
end

function ItemBattleHero:setupViews(  )
	local pLayDefault = self.pCSView:findViewByName("default")
	setGradientBackground(pLayDefault)
	self.pLayIcon = self.pCSView:findViewByName("lay_icon")
	self.pTxtName = self.pCSView:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtState = self.pCSView:findViewByName("txt_state")
	local pTxtTroopsTitle = self.pCSView:findViewByName("txt_troops_title")
	pTxtTroopsTitle:setString(getConvertedStr(3, 10183))
	-- self.pImgSelectedBg = self.pCSView:findViewByName("img_selected_bg")
	self.pImgSelected = self.pCSView:findViewByName("img_selected")
	self.pTxtSelected = self.pCSView:findViewByName("txt_selected")

	local pLayBarTroops = self.pCSView:findViewByName("lay_bar_troops")
	local pSize = pLayBarTroops:getContentSize()
	local nBarWidth, nBarHeight = 212, 20
	self.pBarTroops = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/bar/v1_bar_b1.png",
		   	 	button="ui/update_bin/v1_ball.png",
		    	barfg="ui/bar/v1_bar_blue_3a.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(nBarWidth, nBarHeight)
		    :align(display.LEFT_BOTTOM)
    --设置为不可触摸
    self.pBarTroops:setViewTouched(false)
    pLayBarTroops:addView(self.pBarTroops)
    local pSize1 = pLayBarTroops:getContentSize()
    self.pBarTroops:setPosition((pSize1.width - nBarWidth)/2, (pSize1.height - nBarHeight)/2)
	

	self.pTxtTroops = self.pCSView:findViewByName("txt_troops")
	self.pTxtTroops:enableOutline(getC4B("000000ff"), 1)
	setTextCCColor(self.pTxtTroops, _cc.yellow)

	self.pTxtTroopsMax = self.pCSView:findViewByName("txt_troops_max")
	self.pTxtTroopsMax:enableOutline(getC4B("000000ff"), 1)
	setTextCCColor(self.pTxtTroopsMax, _cc.white)

	local pLayBtnFill = self.pCSView:findViewByName("lay_btn_fill")
	self.pLayBtnFill = pLayBtnFill
	self.pBtnFill = getSepButtonOfContainer(pLayBtnFill, TypeSepBtn.PLUS, TypeSepBtnDir.center)
	self.pBtnFill:onMViewClicked(handler(self, self.onFillClicked))

	self.pLayHeroInfo = self.pCSView:findViewByName("lay_hero_info")
	self.pLayHeroNull = self.pCSView:findViewByName("lay_hero_null")
	self.pTxtNullTip = self.pCSView:findViewByName("txt_null_tip")
	self.pLayNullIcon = self.pCSView:findViewByName("lay_null_icon")
end

function ItemBattleHero:updateViews(  )
	--空的类型
	if self.nNullType then
		if self.pNullIcon then
			self.pNullIcon:removeHeroType()
			self.pNullIcon:removeHeroAdd()
		end

		if self.nNullType == TypeIconHero.ADD then --可以增加
			--图标
			self.pNullIcon  =  getIconHeroByType(self.pLayNullIcon, self.nNullType, nil, TypeIconHeroSize.L)
			self.pNullIcon:setIconHeroType(self.nNullType)

			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUp() then 
				self.pNullIcon:stopAddImgAction()
			end

			--文本
			self.pTxtNullTip:setString(getConvertedStr(5, 10101))

		else --可以上锁
			--图标
			self.pNullIcon  =  getIconHeroByType(self.pLayNullIcon, self.nNullType, nil, TypeIconHeroSize.L)
			self.pNullIcon:setIconHeroType(self.nNullType)

			--文本
			local nTnStr = "" 
			local nTnId = 1
			if self.nNUms == 3 then
				nTnId   =  3010 --中级科技id
			elseif self.nNUms == 4 then
				nTnId   =  3020 --高级科技id
			end
			self.tTechnology = getGoodsByTidFromDB(nTnId)
			if self.tTechnology then
				nTnStr = self.tTechnology.sName
			end 
			if nTnStr and (nTnStr~= "") then
				nTnStr = string.format(getConvertedStr(5, 10102),nTnStr)
				self.pTxtNullTip:setString(nTnStr)
			end
		end

		self.pLayHeroInfo:setVisible(false)
		self.pLayHeroNull:setVisible(true)
		return
	end

	--有值
	if not self.tData then
		return
	end

	self.pLayHeroInfo:setVisible(true)
	self.pLayHeroNull:setVisible(false)

	--武将名字
	self.pTxtName:setString(self.tData.sName .. getLvString(self.tData.nLv))
	setTextCCColor(self.pTxtName, getColorByQuality(self.tData.nQuality))

	--武将头像
	if not self.pIcon then
		self.pIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.L)
		self.pIcon:setIconIsCanTouched(false)
	else
		self.pIcon:setCurData(self.tData)
	end
	self.pIcon:setHeroType()

	--更新兵力
	self:updateTroops()

	--新手引导勾选图片
	Player:getNewGuideMgr():setNewGuideFinger(self.pImgSelected, e_guide_finer.battle_selected_btn)
end

function ItemBattleHero:updateTroops( bIsAnim )
	if not self.tData then
		return
	end

	local nCurrTroops = self.tData.nLt
	local nMaxTroops = self.tData:getProperty(e_id_hero_att.bingli)
	
	-- self.pTxtTroops:setString(tostring(nCurrTroops).. "/"..tostring(nMaxTroops))
	--当前兵力颜色
	local sCurrTroopColor = _cc.yellow
	--兵力不足
	local fTroopsRate = nCurrTroops/nMaxTroops
	if fTroopsRate <= 0.1 then
		-- self.pBarTroops:setSliderImage("ui/bar/v1_bar_red1.png")
		sCurrTroopColor = _cc.red
	else
		-- if fTroopsRate >= 1 then
		-- 	self.pBarTroops:setSliderImage("ui/bar/v1_bar_blue_3.png")
		-- else
		-- 	self.pBarTroops:setSliderImage("ui/bar/v1_bar_yellow_8.png")
		-- end
	end

	-- --兵力数字
	-- local tStr = {
 --    	{color=_cc.yellow, text= tostring(nCurrTroops)},
 --    	{color=_cc.pwhite, text= "/"..tostring(nMaxTroops)},
 --    }
	-- self.pTxtTroops:setString(tStr)
	self.pTxtTroops:setString(tostring(nCurrTroops))
	setTextCCColor(self.pTxtTroops, sCurrTroopColor)
	self.pTxtTroopsMax:setString("/"..tostring(nMaxTroops))

	--兵力增加动画
	local nCurrRate = math.min(fTroopsRate*100, 100)
	if bIsAnim then
		self.pBarTroops:setPercentToByTime(0.1, nCurrRate, function()
			--保证最终值
			if self.pBarTroops then
				self.pBarTroops:setSliderValue(nCurrRate)
			end
		end)
	else
		self.pBarTroops:setSliderValue(nCurrRate)
	end

	--更新部分
	self:updatePart()
end

--是否兵力不足
function ItemBattleHero:getIsNoTroops( )
	if not self.tData then
		return true
	end
	local nMaxTroops = self.tData:getProperty(e_id_hero_att.bingli)
	local nCurrTroops = self.tData.nLt
	local fTroopsRate = nCurrTroops/nMaxTroops
	return fTroopsRate <= 0.1
end

--兵力是否已满
function ItemBattleHero:getIsFullTroops( )
	if not self.tData then
		return false
	end
	local nMaxTroops = self.tData:getProperty(e_id_hero_att.bingli)
	local nCurrTroops = self.tData.nLt
	local fTroopsRate = nCurrTroops/nMaxTroops
	return fTroopsRate >= 1
end

--更新部分显示（状态字， 选择框，背景, 加号特效）
function ItemBattleHero:updatePart( )
	if self.pTxtBackCd then
		self.pTxtBackCd:setVisible(false)
	end
	--武将状态
	if self.nState == e_type_task_state.idle then --空闲状态
		--兵力不足
		if self:getIsNoTroops() then
			--显示状态字
			self.pTxtState:setVisible(true)
			self.pTxtState:setString(getConvertedStr(3, 10553))
			setTextCCColor(self.pTxtState, _cc.red)
			--隐藏单选框
			-- self.pImgSelectedBg:setVisible(false)
			self.pImgSelected:setVisible(false)
			self.pTxtSelected:setVisible(false)

			self:showFillBtnTx()
			--更改背景图片
			self.pCSView:setBackgroundImage("#v1_img_kelashen6hui.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})
		else --有兵力
			if self.bIsSelected then --已选择
				--隐藏状态字
				self.pTxtState:setVisible(false)
				--显示单选框
				-- self.pImgSelectedBg:setVisible(true)
				self.pImgSelected:setVisible(true)
				self.pImgSelected:setCurrentImage("#v2_img_gouxuan.png")
				self.pTxtSelected:setVisible(true)
				self.pTxtSelected:setString(getConvertedStr(3, 10554))
				setTextCCColor(self.pTxtSelected, _cc.green)
			else--非选中状态
				--隐藏状态字
				self.pTxtState:setVisible(false)
				--显示单选框
				-- self.pImgSelectedBg:setVisible(true)
				self.pImgSelected:setVisible(true)
				self.pImgSelected:setCurrentImage("#v2_img_gouxuankuang.png")
				self.pTxtSelected:setVisible(true)
				self.pTxtSelected:setString(getConvertedStr(3, 10555))
				setTextCCColor(self.pTxtSelected, _cc.white)
			end
			--是否满兵
			if self:getIsFullTroops() then
				self:hideFillBtnTx()
			else
				self:showFillBtnTx()
			end

			--更改背景图片
			self.pCSView:removeBackground()
		end
	else --出征状态
		if self.nState == e_type_task_state.back then
			--显示状态字
			self.pTxtState:setVisible(true)
			self.pTxtState:setString(getConvertedStr(9, 10224))
			setTextCCColor(self.pTxtState, _cc.green)
			if not self.pTxtBackCd then
				self.pTxtBackCd =  MUI.MLabel.new({text="", size=20})
				self.pTxtState:getParent():addView(self.pTxtBackCd)
				self.pTxtBackCd:setPosition(self.pTxtState:getPositionX(), self.pTxtState:getPositionY()-20)
			end
			self.pTxtBackCd:setVisible(true)
			regUpdateControl(self, handler(self, self.onUpdateBackCd))		--注册更新倒计时

		else

			--显示状态字
			self.pTxtState:setVisible(true)
			self.pTxtState:setString(getConvertedStr(3, 10062))
			setTextCCColor(self.pTxtState, _cc.yellow)
		end
		--隐藏单选框
		-- self.pImgSelectedBg:setVisible(false)
		self.pImgSelected:setVisible(false)
		self.pTxtSelected:setVisible(false)
		self:hideFillBtnTx()
		--更改背景图片
		self.pCSView:setBackgroundImage("#v1_img_kelashen6hui.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})
	end
end

--设置是否选中
function ItemBattleHero:setIsSelected( bIsSelected )
	if self.nNullType then
		return
	end
	--记录是否选中
	self.bIsSelected = bIsSelected
	--武将状态
	if self.nState == e_type_task_state.idle then --空闲状态
		--兵力不足
		if self:getIsNoTroops() then
			--记录没有选中
			self.bIsSelected = false
		end
	else --出征状态
		self.bIsSelected = false
	end

	--更新部分显示
	self:updatePart()

	--休闲变出征特效(之前没有选中且现在是选中)
	if not self.nPrevSelected and self.bIsSelected then
		local function showSelecteTx()
			--特效
			if not self.pArmAction then
				--特效层1
				self.pArmAction = MArmatureUtils:createMArmature(
					EffectWorldDatas["heroBattleSel"], 
					self, 
					nEffectZorder, 
					cc.p(self:getContentSize().width/2, self:getContentSize().height/2),
				    function (  )
					end, Scene_arm_type.normal)
			end
			self.pArmAction:play()

			--特效层2
			if not self.pImgLight then
				self.pImgLight = MUI.MImage.new("#sg_jxfk_sa1_001.png")
				self:addView(self.pImgLight, nEffectZorder)
				centerInView(self, self.pImgLight)
			end

			-- 时间                  缩放（X,Y）                    透明度
			-- 0秒                 （100%，100%）                    29%
			-- 0.17                 (101.5%，105.8%)                 80%
			-- 0.45                 (103.8%，115.2%)                 0%
			self.pImgLight:stopAllActions()
			self.pImgLight:setScale(1,1)
			self.pImgLight:setOpacity(255)
			local pSeqAct = cc.Sequence:create({
				cc.FadeTo:create(0, 0.29*255),
				cc.Spawn:create({
					cc.ScaleTo:create(0.17 - 0, 1.015, 1.058),
					cc.FadeTo:create(0.17 - 0, 0.8*255),
				}),
				cc.Spawn:create({
					cc.ScaleTo:create(0.45 - 0.17, 1.038, 1.152),
					cc.FadeTo:create(0.45 - 0.17, 0),
				}),
				})
			self.pImgLight:runAction(pSeqAct)
		end
		--进入界面首次播放要延迟0.2秒
		if self.bIsFirstSelected then
			self:performWithDelay(function (  )
		         showSelecteTx()
		    end, 0.2)
		else
			showSelecteTx()
		end
	end
	self.nPrevSelected = self.bIsSelected
	self.bIsFirstSelected = false
end
function ItemBattleHero:onUpdateBackCd(  )
	-- body
	if self.nState == e_type_task_state.back then
		local tTask = Player:getWorldData():getHeroInTask(self.tData.nId)
		if tTask then
			local nCd = tTask:getCd()
			if nCd > 0 then
				self.pTxtBackCd:setString(formatTimeToStr(nCd),false)
			else
				unregUpdateControl(self)--停止计时刷新
			end

		end
	end
end

--切换出征
function ItemBattleHero:onToBattleClicked( pView )
	self:setIsSelected(true)
	sendMsg(gud_dlg_battle_hero_selected_msg)
end

--切换待命
function ItemBattleHero:onToIdleClicked(  )
	--新手引导点击勾选
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.battle_selected_btn)
	self:setIsSelected(false)
	sendMsg(gud_dlg_battle_hero_selected_msg)
end

--点击背景
function ItemBattleHero:onSelectedHero( pView )
	if self.nNullType then
		--存在添加回调就添加英雄回调
		if self.nNullType == TypeIconHero.ADD then
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			local nTipIndex = 1
			if self.nNUms == 3 then
				nTipIndex = 10060
			elseif self.nNUms == 4 then
				nTipIndex = 10061
			end
			local tObject = {
			    nType = e_dlg_index.lockherotip, --dlg类型
			    tData = self.tTechnology,
			    sStr = getTextColorByConfigure(getTipsByIndex(nTipIndex))
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
		return
	end

	if self.bIsTroopsNoEnough then
		return
	else
		--选中状态
		if self.bIsSelected then
			self:onToIdleClicked()
		else
			self:onToBattleClicked()
		end
	end
end

--显示加号特效
function ItemBattleHero:showFillBtnTx( )
	if self.pImgRing then
		self.pImgRing:setVisible(true)
	else
		local pImgRing = MUI.MImage.new("#sg_zjm_rwtih_fk_sdx_xx1.png", {scale9=false})
		pImgRing:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImgRing:setScale(0.5)
		self.pLayBtnFill:addView(pImgRing, 99)
		centerInView(self.pLayBtnFill, pImgRing)
		local action1 = cc.RotateTo:create(0.8, 180)
		local action2 = cc.RotateTo:create(0.8, 360)
		pImgRing:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))		
		self.pImgRing = pImgRing
	end
end

--隐藏加号特效
function ItemBattleHero:hideFillBtnTx( )
	if self.pImgRing then
		self.pImgRing:setVisible(false)
	end
end

--补兵按钮
function ItemBattleHero:onFillClicked(  )
	--容错
	if not self.tData then
		return
	end

	--出征状态不能补
	if self.nState ~= e_type_task_state.idle then
		TOAST(getConvertedStr(3, 10559))
		return
	end

	--补兵已满
	if self:getIsFullTroops() then
		TOAST(getConvertedStr(3, 10558))
		return
	end

	--最大兵力
	local nLeftNums = 0
	local strTips = ""
	if self.tData.nKind == en_soldier_type.infantry then --步
		nLeftNums = Player:getPlayerInfo().nInfantry-- - nWillAddSoldier 
		strTips = getConvertedStr(5, 10033)
	elseif self.tData.nKind == en_soldier_type.sowar then --骑
		nLeftNums = Player:getPlayerInfo().nSowar--  - nWillAddSoldier
		strTips = getConvertedStr(5, 10032)
	elseif self.tData.nKind == en_soldier_type.archer then --弓
		nLeftNums = Player:getPlayerInfo().nArcher-- - nWillAddSoldier
		strTips = getConvertedStr(5, 10034)
	end
	--剩余兵力
	if nLeftNums > 0 then
		--请求甲兵
		if self.tData.nId then
			SocketManager:sendMsg("heroAddSoldier", {self.tData.nId}, handler(self, self.onGetDataFunc))
		end
	else
		--是否上锁
		local bIsLock = true
		--如果步兵营
		local strTips = ""
		if self.tData.nKind == en_soldier_type.infantry then
			local pBuildData = Player:getBuildData():getBuildById(e_build_ids.infantry)
			if pBuildData and pBuildData.nLv > 0 then
				bIsLock = false
			end
			strTips = getConvertedStr(5, 10033)		
		elseif self.tData.nKind == en_soldier_type.sowar then
			local pBuildData = Player:getBuildData():getBuildById(e_build_ids.sowar)
			if pBuildData and pBuildData.nLv > 0 then
				bIsLock = false
			end
			strTips = getConvertedStr(5, 10032)
		elseif self.tData.nKind == en_soldier_type.archer then
			local pBuildData = Player:getBuildData():getBuildById(e_build_ids.archer)
			if pBuildData and pBuildData.nLv > 0 then
				bIsLock = false
			end
			strTips = getConvertedStr(5, 10034)	
		end
		if bIsLock then
			TOAST(string.format(getConvertedStr(6, 10525), strTips))
			--TOAST(getConvertedStr(3, 10362))
			return
		end

		--补兵
        local DlgAlert = require("app.common.dialog.DlgAlert")
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		if(not pDlg) then
		    pDlg = DlgAlert.new(e_dlg_index.alert)
		end
		pDlg:setTitle(getConvertedStr(5, 10104))
		pDlg:setContent(strTips..getConvertedStr(5, 10103))
		pDlg:setRightHandler(function (  )
			closeDlgByType(e_dlg_index.alert, false)
			
			local nBuildId = 0
			if self.tData.nKind == en_soldier_type.infantry then --步
				nBuildId = e_build_ids.infantry--步兵
			elseif self.tData.nKind == en_soldier_type.sowar then --骑
				nBuildId = e_build_ids.sowar--骑兵
			elseif self.tData.nKind == en_soldier_type.archer then --弓
				nBuildId =  e_build_ids.archer--弓
			end
			local tObject = {}
			tObject.nType = e_dlg_index.camp --dlg类型
			tObject.nBuildId = nBuildId
			sendMsg(ghd_show_dlg_by_type,tObject)

		end)
		pDlg:showDlg(bNew)
	end
end

--接收服务端发回的登录回调
function ItemBattleHero:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.heroAddSoldier.id then
        	--更新选中装状态
        	local bIsAuto = Player:getWorldData():getIsAllBattleAuto()
        	if bIsAuto then
        		self:setIsSelected(true)
        	else
        		self:setIsSelected(self.bIsSelected)
        	end
        	sendMsg(gud_dlg_battle_hero_selected_msg)
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--设置数据
--tData：武将数据
--nNullType: 空的类型 TypeIconHero.LOCK, TypeIconHero.ADD
function ItemBattleHero:setData( tData, nNullType)
	self.tData = tData
	self.nNullType = nNullType
	if self.tData then
		self.nState =  Player:getWorldData():getHeroState(self.tData.nId)
		self.nNullType = nil
	else
		self.nState = nil
	end
	self:updateViews()
end

--更新武将状态(任务回来刷新)
function ItemBattleHero:updateHeroState(  )
	if not self.tData then
		return
	end
	if self.nNullType then
		return
	end
	local nState =  Player:getWorldData():getHeroState(self.tData.nId)
	if self.nState ~= nState then
		self.nState = nState
		local bIsAuto = Player:getWorldData():getIsAllBattleAuto()
        if bIsAuto then
			self:setIsSelected(true)
		else
			self:setIsSelected(self.bIsSelected)
		end
	end
end

--获取是否选中
function ItemBattleHero:getIsSelected(  )
	return self.bIsSelected
end

--获取带兵数
function ItemBattleHero:getTroops()
	if self.nNullType then
		return 0
	end
	if not self.bIsSelected then
		return 0
	end
	if self.tData and self.tData.nLt then
		return self.tData.nLt
	end
	return 0
end

--获取武将
function ItemBattleHero:getHeroId()
	if self.tData then
		return self.tData.nId
	end
	return nil
end

--获取武将内部属性是否出征
function ItemBattleHero:getIsBusy( )
	--最终判断出征中，看是否有问题
	if self.tData then
		return self.tData.nW == 1
	end
	return false
end

--补兵刷新
function ItemBattleHero:updateHeroRecruit(  )
	if not self.tData then
		return
	end
	self.tData = Player:getHeroInfo():getHero(self.tData.nId)
	self:updateTroops( true )
end

--获取空类型
function ItemBattleHero:getNullType( )
	return self.nNullType
end


return ItemBattleHero