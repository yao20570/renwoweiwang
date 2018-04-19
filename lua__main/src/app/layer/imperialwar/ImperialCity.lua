----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-14 20:42:00
-- Description: 皇城详情
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local TacticsGoods = require("app.layer.imperialwar.TacticsGoods")
local nFlagYAdd = 45
local nFlagTxtY = 25
local nTaiwei = 3 --太尉
local ImperialCity = class("ImperialCity", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ImperialCity:ctor(  )
	self.nHoldFire = tonumber(getEpangWarInitData("holdFire"))
	--解析文件
	parseView("layout_imperial_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ImperialCity:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ImperialCity", handler(self, self.onImperialCityDestroy))
end

-- 析构方法
function ImperialCity:onImperialCityDestroy(  )
    self:onPause()
end

function ImperialCity:regMsgs(  )
	regMsg(self, gud_imperialwar_vo_refresh, handler(self, self.updateViews))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
end

function ImperialCity:unregMsgs(  )
	unregMsg(self, gud_imperialwar_vo_refresh)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, gud_world_dot_change_msg)
end

function ImperialCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ImperialCity:onPause(  )
	self:unregMsgs()
end

function ImperialCity:setupViews(  )
	local pLayBg = self:findViewByName("lay_bg")
	setGradientBackground(pLayBg)
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayCityIcon = self:findViewByName("lay_city_icon")
	self.pLayGoods = self:findViewByName("lay_goods")
	local tData = getTechDataById(e_tech_type.together)
	if tData then
		local pGoods = getIconGoodsByType(self.pLayGoods, TypeIconGoods.NORMAL, type_icongoods_show.tech, tData, TypeIconGoodsSize.M)
		pGoods:setMoreTextSize(22)
		pGoods:setIconIsCanTouched(false)
	end
	self.pLayGoods:setViewTouched(true)
	self.pLayGoods:setIsPressedNeedScale(false)
	self.pLayGoods:setIsPressedNeedColor(false)
	self.pLayGoods:onMViewClicked(handler(self, self.onTogetherClicked))

	self.pTxtGoods = self:findViewByName("txt_goods")
	self.pTxtFireLay = self:findViewByName("txt_fire_lay")
	self.pTxtReadyCd = self:findViewByName("txt_ready_cd")
	self.pTxtOccupyCd = self:findViewByName("txt_occupy_cd")
	self.pTxtOwn = self:findViewByName("txt_own")
	self.pLayArmy = self:findViewByName("lay_army")
	self.pLayMiddle = self:findViewByName("lay_middle")
	self.pTxtNone = self:findViewByName("txt_none")
	self.pTxtNone:setString(getConvertedStr(3, 10139))

	--集结道具文本

	--兵力集
	--3个兵力
	self.tTroopsUi = {}
	for i=1,3 do
		local pTxtTroops, pImgTroops = self:getTroopsUi()
		pTxtTroops:setVisible(false)
		pImgTroops:setVisible(false)
		table.insert(self.tTroopsUi, {pTxtTroops = pTxtTroops, pImgTroops = pImgTroops})
	end

	--右边防守位置
	local tRightPos = {424, nFlagTxtY}
	local pTxtTroops, pImgTroops = self:getTroopsUi()
	pTxtTroops:setPosition(tRightPos[1], tRightPos[2])
	pImgTroops:setPosition(tRightPos[1], tRightPos[2] + nFlagYAdd)
	self.tDefTroops = {pTxtTroops = pTxtTroops, pImgTroops = pImgTroops}

	--初始化科技Ui
	local nX, nY, nOffsetX = 15, 5, 106
	self.tTechUis = {}
	--排序
	local tTechDataList = {}
	local tTechDatas = getAllTechData()
	for k,v in pairs(tTechDatas) do
		table.insert(tTechDataList, v)
	end
	table.sort(tTechDataList, function(a, b)
		return a.sTid < b.sTid
	end)
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	for i=1,#tTechDataList do
		local tTechData = tTechDataList[i]
		local sTid = tTechData.sTid
		if sTid ~= e_tech_type.together then
			self.tTechUis[sTid]  = TacticsGoods.new()
			self.tTechUis[sTid]:setData(tTechData, tImperialWarVo)
			self.tTechUis[sTid]:setPosition(nX, nY)
			self.pLayMiddle:addView(self.tTechUis[sTid])
			nX = nX + nOffsetX
		end
	end

	--初始化按钮集
	--突围
	self.pLayBtnBreakout = self:findViewByName("lay_btn_breakout")
	self.pBtnBreakout = getCommonButtonOfContainer(self.pLayBtnBreakout,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10903))
	local tBtnTable = {}
	tBtnTable.tLabel = {
		{getConvertedStr(3, 10904),getC3B(_cc.white)},
		{"",getC3B(_cc.red)},
	}
	tBtnTable.awayH = -14
	self.pBtnBreakout:setBtnExText(tBtnTable, false)
	self.pBtnBreakout:onCommonBtnClicked(handler(self, self.onBreakoutClicked))

	--查看武将
	self.pLayBtnHero = self:findViewByName("lay_btn_hero")
	self.pBtnHero = getCommonButtonOfContainer(self.pLayBtnHero,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10923))
	local tBtnTable = {}
	tBtnTable.tLabel = {
		{getConvertedStr(3, 10124),getC3B(_cc.white)},
		{"",getC3B(_cc.green)},
	}
	tBtnTable.awayH = -14 
	self.pBtnHero:setBtnExText(tBtnTable, false)
	self.pBtnHero:onCommonBtnClicked(handler(self, self.onHeroClicked))

	--城内部队
	self.pLayBtnArmy = self:findViewByName("lay_btn_army")
	self.pBtnArmy = getCommonButtonOfContainer(self.pLayBtnArmy,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10905))
	self.pBtnArmy:onCommonBtnClicked(handler(self, self.onArmyClicked))	

	--撤退
	self.pLayBtnRetreat = self:findViewByName("lay_btn_retreat")
	self.pBtnRetreat = getCommonButtonOfContainer(self.pLayBtnRetreat,TypeCommonBtn.L_RED, getConvertedStr(3, 10906))
	self.pBtnRetreat:onCommonBtnClicked(handler(self, self.onRetreatClicked))		

	--出征或加速（默认出征)
	self.pTxtBtnMove = self:findViewByName("txt_btn_move")
	self.pLayBtnMove = self:findViewByName("lay_btn_move")
	self.pBtnMove = getCommonButtonOfContainer(self.pLayBtnMove,TypeCommonBtn.L_BLUE, "")
end

function ImperialCity:updateViews(  )
	--基本信息
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if tViewDotMsg then
		local nCountry = tViewDotMsg:getDotCountry()
		local sImg = WorldFunc.getCountryFlagImg(nCountry)
		self.pImgFlag:setCurrentImage(sImg)
		self.tDefTroops.pImgTroops:setCurrentImage(sImg)

		WorldFunc.getSysCityIconOfContainer(self.pLayCityIcon, nSysCityId, nCountry, true)

		local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10907)},
		    {color=getColorByCountry(nCountry),text=getCountryName(nCountry)},
		}
		self.pTxtOwn:setString(tStr)

		--设置防守方国家
		for nId,pTechUi in pairs(self.tTechUis) do
			pTechUi:setDefCountry(nCountry)
		end
	end

	--更新
	self:updateTroopsFlag()
	self:updateTechUis()
	self:updateFireLay()
	self:updateBottom()
	self:updateTroopPer()
	self:updateCd()
end


--更新国家兵力和旗帜
function ImperialCity:updateTroopsFlag(  )
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end

	--五个文字点位置
	local tPosList = {
		{52,  nFlagTxtY},
		{93,  nFlagTxtY},
		{134, nFlagTxtY},
		{175, nFlagTxtY},
		{216, nFlagTxtY},
	}

	local tAckTrps = tImperialWarVo:getAckTrps()
	local tPosList2 = {}
	local nCount = #tAckTrps
	if nCount == 1 then
		tPosList2 = {tPosList[3]}
	elseif nCount == 2 then
		tPosList2 = {tPosList[2],tPosList[4]}
	elseif nCount == 3 then
		tPosList2 = {tPosList[1],tPosList[3],tPosList[5]}
	end
	self.pTxtNone:setVisible(nCount == 0)

	for i=1,#self.tTroopsUi do
		local pUis = self.tTroopsUi[i]
		local pTxtTroops = pUis.pTxtTroops
		local pImgTroops = pUis.pImgTroops
		local tAckTrp = tAckTrps[i]
		local tPos = tPosList2[i]
		if tAckTrp and tPos then
			pImgTroops:setVisible(true)
			pTxtTroops:setVisible(true)

			local nCountry = tAckTrp.k
			local nTroops = tAckTrp.v
			pTxtTroops:setString(nTroops)
			pImgTroops:setCurrentImage(WorldFunc.getCountryFlagImg(nCountry))

			pTxtTroops:setPosition(tPos[1], tPos[2])
			pImgTroops:setPosition(tPos[1], tPos[2] + nFlagYAdd)
		else
			pImgTroops:setVisible(false)
			pTxtTroops:setVisible(false)
		end
	end
	--防守者兵力
	self.tDefTroops.pTxtTroops:setString(tImperialWarVo:getDefTrps())
end

--获取兵力Ui
function ImperialCity:getTroopsUi( )
	local pTxtTroops = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(0.5, 0.5),})
	self.pLayArmy:addView(self.pTextMyInfo)
	self.pLayArmy:addView(pTxtTroops)

	local pImgTroops = MUI.MImage.new("#v1_img_qun.png")
	self.pLayArmy:addView(pImgTroops)

	return pTxtTroops, pImgTroops
end

--更新科技Ui
function ImperialCity:updateTechUis(  )
	local bIsHide = true
	local nHeroInCityId = Player:getWorldData():getWaitBattleInEWCityId() --部队驻战的城池id是否是现在打开的城池id
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	if nHeroInCityId == nSysCityId then
		bIsHide = false
	end

	--不在据点就隐藏
	if bIsHide then
		for k,pTechUi in pairs(self.tTechUis) do
			pTechUi:setVisible(false)
		end
		return
	end

	--进行显示更新
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end

	--正常显示
	for nId,pTechUi in pairs(self.tTechUis) do
		pTechUi:setVisible(true)
		pTechUi:updateViews()
	end
end

--更新火攻层数
function ImperialCity:updateFireLay( )
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	local nLay = tImperialWarVo:getFireLay()
	local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10913)},
		    {color=_cc.green,text=nLay},
		}
	self.pTxtFireLay:setString(tStr)
end

--更新时间
function ImperialCity:updateCd( )
	--更新cd时间
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	local nCd = tImperialWarVo:getOccupyTime()
	local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10911)},
		    {color=_cc.green,text=getTimeLongStr(nCd,false,false) },
		}
	self.pTxtOccupyCd:setString(tStr)

	local bIsWait = tImperialWarVo:getIsWaitAtk()
	if bIsWait then
		local tStr = {
			    {color=_cc.white,text=getConvertedStr(3, 10934)},
			    {color=_cc.green,text=getConvertedStr(3, 10935)},
			}
		self.pTxtReadyCd:setString(tStr)
	else
		local nCd = tImperialWarVo:getPrepareCd()
		if nCd > self.nHoldFire then
			local tStr = {
				    {color=_cc.white,text=getConvertedStr(3, 10912)},
				    {color=_cc.green,text=getTimeLongStr(nCd - self.nHoldFire,false,false) },
				}
			self.pTxtReadyCd:setString(tStr)
		else
			local tStr = {
				    {color=_cc.white,text=getConvertedStr(3, 10949)},
				    {color=_cc.green,text=getTimeLongStr(nCd,false,false) },
				}
			self.pTxtReadyCd:setString(tStr)
		end
	end

	local nCd = tImperialWarVo:getToCd()
	local tStr = nil
	if nCd > 0 then
		tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10914)},
		    {color=_cc.green,text=getTimeLongStr(nCd,false,false) },
		}
	else
		tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10914)},
		    {color=_cc.green,text=getConvertedStr(3, 10915)},
		}
	end
	self.pTxtGoods:setString(tStr)
	--更新红点
	self:updateTogetherRed()

	--更新战术倒计时
	local pTechUiFire = self.tTechUis[e_tech_type.fire]
	if pTechUiFire then
		pTechUiFire:updateCd()
	end
	local pTechUiRain = self.tTechUis[e_tech_type.rain]
	if pTechUiRain then
		pTechUiRain:updateCd()
	end

	--下方按钮时间
	local nCd = tImperialWarVo:getSrCd()
	if nCd > 0 then
		self.pBtnBreakout:setExTextLbCnCr(1,getConvertedStr(3, 10904))
		self.pBtnBreakout:setExTextLbCnCr(2,getTimeLongStr(nCd,false,false))
		self.pBtnBreakout:setBtnEnable(false)
	else
		if tImperialWarVo:getIsCanOutCtrl() then --可以突码
			if tImperialWarVo:getIsCanBroke() then --人数充足
				self.pBtnBreakout:setExTextLbCnCr(1,"")
				self.pBtnBreakout:setExTextLbCnCr(2,"")
				self.pBtnBreakout:setBtnEnable(true)
			else
				self.pBtnBreakout:setExTextLbCnCr(1, getConvertedStr(3, 10845), getC3B(_cc.red))
				self.pBtnBreakout:setExTextLbCnCr(2,"")
				self.pBtnBreakout:setBtnEnable(false)
			end
		else --开战期间
			self.pBtnBreakout:setExTextLbCnCr(1, getConvertedStr(3, 10844), getC3B(_cc.red))
			self.pBtnBreakout:setExTextLbCnCr(2,"")
			self.pBtnBreakout:setBtnEnable(false)
		end
	end

	--行军Cd
	if self.bIsMoveCd then
		local nCd = Player:getWorldData():getGOEWMoveCd()
		self.pTxtBtnMove:setString(string.format(getConvertedStr(3, 10918), _cc.green, getTimeLongStr(nCd,false,false)))
	end
end

--兵力百分比
function ImperialCity:updateTroopPer( )
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	self.pBtnHero:setExTextLbCnCr(2,string.format("%s%%",tImperialWarVo:getTrp()))
end

--更新下按钮
function ImperialCity:updateBottom( )
	self.bIsMoveCd = false
	local bIsBreakouting = Player:getWorldData():getIsBreakouting() --是否突围中
	if bIsBreakouting then
		--更新按钮
		self.pBtnBreakout:setExTextVisiable(false)
		self.pBtnHero:setExTextVisiable(false)
		self.pLayBtnBreakout:setVisible(false)
		self.pLayBtnHero:setVisible(false)
		self.pLayBtnArmy:setVisible(false)
		self.pLayBtnRetreat:setVisible(false)
		self.pTxtBtnMove:setVisible(true)
		self.pLayBtnMove:setVisible(true)

		--设置部队正在前往指定的建筑
		local sCityName = Player:getWorldData():getBreakoutCityName()
		self.pTxtBtnMove:setString(string.format(getConvertedStr(3, 10919), _cc.green, sCityName))
		self.pBtnMove:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10381))
		self.pBtnMove:onCommonBtnClicked(handler(self, self.onSubmitClicked))
	else
		local bIsInWarCity = Player:getWorldData():getIsWaitBattleInEW() --是否有武将到达城池（兵种驻战城池
		if bIsInWarCity then
			local nHeroInCityId = Player:getWorldData():getWaitBattleInEWCityId() --部队驻战的城池id是否是现在打开的城池id
			local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
			if nHeroInCityId == nSysCityId then
				self.pBtnBreakout:setExTextVisiable(true)
				self.pBtnHero:setExTextVisiable(true)
				self.pLayBtnBreakout:setVisible(true)
				self.pLayBtnHero:setVisible(true)
				self.pLayBtnArmy:setVisible(true)
				self.pLayBtnRetreat:setVisible(true)
				self.pTxtBtnMove:setVisible(false)
				self.pLayBtnMove:setVisible(false)
			else
				--更新按钮
				self.pBtnBreakout:setExTextVisiable(false)
				self.pBtnHero:setExTextVisiable(false)
				self.pLayBtnBreakout:setVisible(false)
				self.pLayBtnHero:setVisible(false)
				self.pLayBtnArmy:setVisible(false)
				self.pLayBtnRetreat:setVisible(false)
				self.pTxtBtnMove:setVisible(true)
				self.pLayBtnMove:setVisible(true)

				--设置部队正在指定的建筑战斗
				local tCityData = getWorldCityDataById(nHeroInCityId)
				if tCityData then
					local sCityName = tCityData.name
					self.pTxtBtnMove:setString(string.format(getConvertedStr(3, 10924), _cc.green, sCityName))
				end
				self.pBtnMove:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
				self.pBtnMove:onCommonBtnClicked(handler(self, self.onJumpClicked))
			end
		else
			--更新按钮
			self.pBtnBreakout:setExTextVisiable(false)
			self.pBtnHero:setExTextVisiable(false)
			self.pLayBtnBreakout:setVisible(false)
			self.pLayBtnHero:setVisible(false)
			self.pLayBtnArmy:setVisible(false)
			self.pLayBtnRetreat:setVisible(false)
			self.pTxtBtnMove:setVisible(true)
			self.pLayBtnMove:setVisible(true)

			local bIsSendedHero = Player:getWorldData():getHasGoEW() --是否有派兵
			if bIsSendedHero then
				local nCd = Player:getWorldData():getGOEWMoveCd()--设置行军cd 记得放进updateCd里
				self.pTxtBtnMove:setString(string.format(getConvertedStr(3, 10918), _cc.green, nCd))
				self.pBtnMove:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10084))
				self.pBtnMove:onCommonBtnClicked(handler(self, self.onAddSpeedClicked))	
				self.bIsMoveCd = true
			else
				self.pTxtBtnMove:setString(string.format(getConvertedStr(3, 10917), _cc.green))
				self.pBtnMove:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10064))
				self.pBtnMove:onCommonBtnClicked(handler(self, self.onSendHeroClicked))
			end
		end
	end
end

--突围
function ImperialCity:onBreakoutClicked(  )
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	if nSysCityId == e_syscity_ids.EpangPalace then --当前是在皇城
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10921))
	    local FireTownSelectLayer = require("app.layer.imperialwar.FireTownSelectLayer")
	    local pSelectLayer = FireTownSelectLayer.new()
	    pDlg:addContentView(pSelectLayer)
	    pDlg:setRightHandler(function (  )
	        local nCityId = pSelectLayer:getCurrSelectCityId()
	        SocketManager:sendMsg("reqImperWarBreakout", {nCityId}, nil)
	        pDlg:closeDlg(false)
	        closeDlgByType(e_dlg_index.syscitydetail, false)
	    end)
	    pDlg:showDlg(bNew)
	else
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10922))
	    pDlg:setRightHandler(function (  )
	    	SocketManager:sendMsg("reqImperWarBreakout", {e_syscity_ids.EpangPalace}, nil)
	        pDlg:closeDlg(false)
	        closeDlgByType(e_dlg_index.syscitydetail, false)
	    end)
	    pDlg:showDlg(bNew)
	end
end

--查看英雄
function ImperialCity:onHeroClicked( )
	local tObject = {
	    nType = e_dlg_index.imperialwarhero, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--城内部队
function ImperialCity:onArmyClicked(  )
	local tObject = {
	    nType = e_dlg_index.imperialwararmy, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--撤退
function ImperialCity:onRetreatClicked( )
	--等待进攻或备战时间期
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if tImperialWarVo:getIsCanOutCtrl() then
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10936))
	    pDlg:setContent(getConvertedStr(3, 10937))
	    pDlg:setRightHandler(function (  )
	    	pDlg:closeDlg(false)
	        local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	        if tImperialWarVo then
	        	--等待进攻或备战时间期
	        	local bIsToast = true
	        	if tImperialWarVo:getIsCanOutCtrl() then
	        		local tTask = Player:getWorldData():getImperWarTask()
					if tTask then
						bIsToast = false
						SocketManager:sendMsg("reqWorldTaskInput", {tTask.sUuid, e_type_task_input.call, nil}, function(__msg, __oldMsg)
				            if __msg.head.state == SocketErrorType.success then 
				                if __msg.head.type == MsgType.reqWorldTaskInput.id then
				               		TOAST(getConvertedStr(3, 10939))     
				                end
				            end
						end)
					end
	        	end
	        	if bIsToast then
	        		TOAST(getConvertedStr(3, 10846))
	        	end
	        end
	    end)
	    pDlg:showDlg(bNew)
	else
		TOAST(getConvertedStr(3, 10846))
	end
end

--出征
function ImperialCity:onSendHeroClicked( )
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if tViewDotMsg then
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.battlehero, --dlg类型
		    nIndex = 10,--出征皇城战
		    tViewDotMsg = tViewDotMsg,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	else
		TOAST(getConvertedStr(3, 10948))
	end
end

--出征加速
function ImperialCity:onAddSpeedClicked( )
	local tTask = Player:getWorldData():getImperWarTask()
	if tTask then
		local tObject = {}
	    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
	    tObject.tItemList = {100030,100031}
	    tObject.tTaskCommend = { nOrder = e_type_task_input.quick, sTaskUuid = tTask.sUuid}
	    sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--确定
function ImperialCity:onSubmitClicked(  )
	closeDlgByType(e_dlg_index.syscitydetail, false)
end

--跳转
function ImperialCity:onJumpClicked( )
	closeDlgByType(e_dlg_index.syscitydetail, false)

	local nHeroInCityId = Player:getWorldData():getWaitBattleInEWCityId() --武将当前到达的id是否是现在打开的城池id
	local tCityData = getWorldCityDataById(nHeroInCityId)
	if tCityData then
		sendMsg(ghd_world_location_mappos_msg, {fX = tCityData.tMapPos.x, fY = tCityData.tMapPos.y, isClick = true})
	end
end

--集结红点
function ImperialCity:updateTogetherRed(  )
	if self:getIsCanUseTogether() then
		showRedTips(self.pLayGoods, 0, 1, 2)
	else
		showRedTips(self.pLayGoods, 0, 0, 2)
	end
end

--是否可以使用集合技能
function ImperialCity:getIsCanUseTogether( bIsShowLog )
	local bIsIdel = false --是否空闲
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if tImperialWarVo then
		bIsIdel = tImperialWarVo:getToCd() <= 0
	end
	local bIsCanUsed = false
	local tCountryDataVo = Player:getCountryData():getCountryDataVo()
	if tCountryDataVo then
		bIsCanUsed = tCountryDataVo:getIsOfficialEnough(nTaiwei)
	end
	if not bIsIdel then
		if bIsShowLog then
			TOAST(getConvertedStr(3, 10950))
		end
		return false
	end
	if not bIsCanUsed then
		if bIsShowLog then
			TOAST(getConvertedStr(3, 10951))
		end
		return false
	end
	return true
end

--集结点击
function ImperialCity:onTogetherClicked(  )
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(3, 10944))
    pDlg:setRightHandler(function (  )
    	if self:getIsCanUseTogether(true) then
    		SocketManager:sendMsg("reqImperWarTech", {e_tech_type.together}, nil)
    	end
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)
end

--监听数据发生改变
function ImperialCity:onDotChange( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
		if tViewDotMsg.nSystemCityId == nSysCityId then
			self:updateViews()
		end
	end
end


return ImperialCity
