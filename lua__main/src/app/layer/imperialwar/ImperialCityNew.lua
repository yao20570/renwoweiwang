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
local nFRopeY = 5
local ImperialCityNew = class("ImperialCityNew", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ImperialCityNew:ctor(  )
	self.nHoldFire = tonumber(getEpangWarInitData("holdFire"))
	self.nHoldReady = tonumber(getEpangWarInitData("holdReady"))
	self.nMaxTime = self.nHoldReady --+ self.nHoldFire --后端是加起来的，所以。。。
	self.nTogetherSec = tonumber(getEpangWarInitData("massSec"))
	--解析文件
	parseView("layout_imperial_city_new", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ImperialCityNew:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ImperialCityNew", handler(self, self.onImperialCityNewDestroy))
end

-- 析构方法
function ImperialCityNew:onImperialCityNewDestroy(  )
    self:onPause()
    self:stopPlayTroopsNum()
end

function ImperialCityNew:regMsgs(  )
	regMsg(self, gud_imperialwar_vo_refresh, handler(self, self.updateViews))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
	regMsg(self, ghd_imperialwar_show_fight, handler(self, self.onShowFight))

end

function ImperialCityNew:unregMsgs(  )
	unregMsg(self, gud_imperialwar_vo_refresh)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, gud_world_dot_change_msg)
	unregMsg(self, ghd_imperialwar_show_fight)
end

function ImperialCityNew:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ImperialCityNew:onPause(  )
	self:unregMsgs()
end

function ImperialCityNew:setupViews(  )
	local pLayBg = self:findViewByName("lay_bg")
	setGradientBackground(pLayBg)
	self.pLayRope = self:findViewByName("lay_rope")
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayCityIcon = self:findViewByName("lay_city_icon")
	self.pLayGoods = self:findViewByName("lay_goods")
	self.pLayTop = self:findViewByName("lay_top")
	self.pImgZhanFont = self:findViewByName("img_zhan_font")
	local tData = getTechDataById(e_tech_type.together)
	if tData then
		local pGoods = getIconGoodsByType(self.pLayGoods, TypeIconGoods.NORMAL, type_icongoods_show.tech, tData, TypeIconGoodsSize.M)
		pGoods:setMoreTextSize(24)
		pGoods:setIconIsCanTouched(true)
		pGoods.pLayBase:setIsPressedNeedColor(false)
	end
	-- self.pLayGoods:setViewTouched(true)
	-- self.pLayGoods:setIsPressedNeedScale(false)
	-- self.pLayGoods:setIsPressedNeedColor(false)
	-- self.pLayGoods:onMViewClicked(handler(self, self.onTogetherClicked))

	self.pTxtGoods = self:findViewByName("txt_goods")
	self.pTxtFireLay = self:findViewByName("txt_fire_lay")
	-- self.pTxtReadyCd = self:findViewByName("txt_ready_cd")
	self.pTxtOccupyCd = self:findViewByName("txt_occupy_cd")
	self.pTxtOwn = self:findViewByName("txt_own")
	self.pLayArmy = self:findViewByName("lay_army")
	self.pLayMiddle = self:findViewByName("lay_middle")
	self.pTxtNone = self:findViewByName("txt_none")
	self.pTxtNone:setString(getConvertedStr(3, 10139))

	self.pLayFlagsLeft = self:findViewByName("lay_flags_left")
	self.pLayFlagsRight = self:findViewByName("lay_flags_right")	

	self.pLbCityName = self:findViewByName("txt_city_name")
	--集结道具文本

	--兵力集
	--3个兵力
	self.tTroopsUi = {}
	for i=1,3 do
		local pTxtTroops, pImgTroops = self:getTroopsUi()
		pTxtTroops:setVisible(false)
		pImgTroops:setVisible(false)
		table.insert(self.tTroopsUi, {pTxtTroops = pTxtTroops, pImgTroops = pImgTroops})

		self.pLayFlagsLeft:addView(pTxtTroops)
		self.pLayFlagsLeft:addView(pImgTroops)
	end

	--右边防守位置
	local tRightPos = {278/2, nFlagTxtY}
	local pTxtTroops, pImgTroops = self:getTroopsUi()
	pTxtTroops:setPosition(tRightPos[1], tRightPos[2])
	pImgTroops:setPosition(tRightPos[1], tRightPos[2] + nFlagYAdd)
	self.tDefTroops = {pTxtTroops = pTxtTroops, pImgTroops = pImgTroops}
	self.pLayFlagsRight:addView(pTxtTroops)
	self.pLayFlagsRight:addView(pImgTroops)

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

	self:createFireRope()
	self:createTogetherGray()
end

function ImperialCityNew:updateViews(  )
	--基本信息
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	self.pLbCityName:setString(tViewDotMsg.sDotName .. " Lv." .. tViewDotMsg.nDotLv)
	setTextCCColor(self.pLbCityName, _cc.blue)

	if tViewDotMsg then
		local nCountry = tViewDotMsg:getDotCountry()
		local sImg = WorldFunc.getCountryFlagImg(nCountry)
		self.pImgFlag:setCurrentImage(sImg)

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
	self:updateFireRope()
	self:updateTechUis()
	self:updateFireLay()
	self:updateBottom()
	self:updateTroopPer()
	self:udpateTogether()
	self:updateCd()
end


--更新国家兵力和旗帜
function ImperialCityNew:updateTroopsFlag( bIsShowFight )
	--如果是在播放动画中就返回
	if self.bIsPlayAniming then
		return
	end
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	local tAckTrps = tImperialWarVo:getAckTrps()

	--是战斗就发生
	if bIsShowFight then
		--播放火力动画
		if self.tAckTrpsPrev and self.nDefTroops and tAckTrps then
			--播放战动画
			self.bIsPlayAniming = true
			self.pLayRope:setVisible(false)
			self:playZhanAmin()
	    	self.tTroopsData = {
	    		tAckTrpsPrev = self.tAckTrpsPrev,
	    		nPrevDef = self.nDefTroops,
	    		tAckTrps = tAckTrps,
	    		nDef = tImperialWarVo:getDefTrps(),
	    	}
	    	self:playCollideAmin()
	    	self.tAckTrpsPrev = nil
	    	self.nDefTroops = nil
	    	return
		end
	end
	--记录最新数据
	self.tAckTrpsPrev = clone(tAckTrps)
	self.nDefTroops = tImperialWarVo:getDefTrps()

	

	--五个文字点位置
	local tPosList = {
		{52,  nFlagTxtY},
		{93,  nFlagTxtY},
		{134, nFlagTxtY},
		{175, nFlagTxtY},
		{216, nFlagTxtY},
	}
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
			pImgTroops.pImgFlagRed:setCurrentImage(WorldFunc.getCountryFlagImg(nCountry))

			pTxtTroops:setPosition(tPos[1], tPos[2])
			pImgTroops:setPosition(tPos[1], tPos[2] + nFlagYAdd)
		else
			pImgTroops:setVisible(false)
			pTxtTroops:setVisible(false)
		end
	end
	--防守者兵力
	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if tViewDotMsg then
		local nCountry = tViewDotMsg:getDotCountry()
		local sImg = WorldFunc.getCountryFlagImg(nCountry)
		self.tDefTroops.pImgTroops:setCurrentImage(sImg)
		self.tDefTroops.pImgTroops.pImgFlagRed:setCurrentImage(sImg)
	end
	self.tDefTroops.pTxtTroops:setString(tImperialWarVo:getDefTrps())
end

--获取兵力Ui
function ImperialCityNew:getTroopsUi( )
	local pTxtTroops = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(0.5, 0.5),})

	local pImgTroops = MUI.MImage.new("#v1_img_qun.png")

	local pImgFlagRed = MUI.MImage.new("#v1_img_qun.png")
	pImgTroops.pImgFlagRed = pImgFlagRed
	pImgTroops:addChild(pImgFlagRed)
	pImgFlagRed:setOpacity(0)
	pImgFlagRed:setColor(cc.c3b(255, 0, 0))
	local tSize = pImgTroops:getContentSize()
	pImgFlagRed:setPosition(tSize.width/2, tSize.height/2)

	return pTxtTroops, pImgTroops
end

--更新科技Ui
function ImperialCityNew:updateTechUis(  )
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
function ImperialCityNew:updateFireLay( )
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
	if nLay > 0 then
		self:playCityFire()
	else
		self:stopCityFire()
	end
end

--更新时间
function ImperialCityNew:updateCd( )
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

	-- local nCd = tImperialWarVo:getToCd()
	-- local tStr = nil
	-- if nCd > 0 then
	-- 	tStr = {
	-- 	    {color=_cc.white,text=getConvertedStr(3, 10914)},
	-- 	    {color=_cc.green,text=getTimeLongStr(nCd,false,false) },
	-- 	}
	-- else
	-- 	tStr = {
	-- 	    {color=_cc.white,text=getConvertedStr(3, 10914)},
	-- 	    {color=_cc.green,text=getConvertedStr(3, 10915)},
	-- 	}
	-- end
	-- self.pTxtGoods:setString(tStr)
	--更新红点
	-- self:updateTogetherRed()

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
function ImperialCityNew:updateTroopPer( )
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	self.pBtnHero:setExTextLbCnCr(2,string.format("%s%%",tImperialWarVo:getTrp()))
end

--更新下按钮
function ImperialCityNew:updateBottom( )
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
function ImperialCityNew:onBreakoutClicked(  )
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
function ImperialCityNew:onHeroClicked( )
	local tObject = {
	    nType = e_dlg_index.imperialwarhero, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--城内部队
function ImperialCityNew:onArmyClicked(  )
	local tObject = {
	    nType = e_dlg_index.imperialwararmy, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--撤退
function ImperialCityNew:onRetreatClicked( )
	--等待进攻或备战时间期
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
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
				               		if self.stopFightAnimNow then
				               			self:stopFightAnimNow()
				               		end
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
function ImperialCityNew:onSendHeroClicked( )
    --还有保护cd时间
    local function sendBattleReq(  )
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
	local bProtect = WorldFunc.checkIsAttackCityInProtect(sendBattleReq)
	if not bProtect then
		--发生请求
		sendBattleReq()
	end
end

--出征加速
function ImperialCityNew:onAddSpeedClicked( )
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
function ImperialCityNew:onSubmitClicked(  )
	closeDlgByType(e_dlg_index.syscitydetail, false)
end

--跳转
function ImperialCityNew:onJumpClicked( )
	closeDlgByType(e_dlg_index.syscitydetail, false)

	local nHeroInCityId = Player:getWorldData():getWaitBattleInEWCityId() --武将当前到达的id是否是现在打开的城池id
	local tCityData = getWorldCityDataById(nHeroInCityId)
	if tCityData then
		sendMsg(ghd_world_location_mappos_msg, {fX = tCityData.tMapPos.x, fY = tCityData.tMapPos.y, isClick = true})
	end
end

--集结红点
function ImperialCityNew:updateTogetherRed(  )
	if self:getIsCanUseTogether() then
		showRedTips(self.pLayGoods, 0, 1, 2)
	else
		showRedTips(self.pLayGoods, 0, 0, 2)
	end
end

--是否可以使用集合技能
function ImperialCityNew:getIsCanUseTogether( bIsShowLog )
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
function ImperialCityNew:onTogetherClicked(  )
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(3, 10944))
    pDlg:setRightHandler(function (  )
    	if self:getIsCanUseTogether(true) then
    		local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
    		SocketManager:sendMsg("reqImperWarTech", {e_tech_type.together, nSysCityId}, nil)
    	end
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)
end

--监听数据发生改变
function ImperialCityNew:onDotChange( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
		if tViewDotMsg.nSystemCityId == nSysCityId then
			self:updateViews()
		end
	end
end

--------------------------------------------------------------特效
--城池火焰特效
function ImperialCityNew:playCityFire(  )
	if self.pLayCityFire then
		self.pLayCityFire:setVisible(true)
	else
		self.pLayCityFire = MUI.MLayer.new()
		self.pLayCityFire:setLayoutSize(1, 1)
		self.pLayCityIcon:addView(self.pLayCityFire, 1)
		centerInView(self.pLayCityIcon, self.pLayCityFire)

		--粒子
		local pParitcle1 =  createParitcle("tx/other/lizi_jzefg_dh_01.plist")
		pParitcle1:setPosition(11, -6)
		self.pLayCityFire:addView(pParitcle1)

		local pParitcle2 =  createParitcle("tx/other/lizi_jzefg_dh_02.plist")
		pParitcle2:setPosition(12, -6)
		pParitcle2:setScale(0.5)
		self.pLayCityFire:addView(pParitcle2, 1)

		local pParitcle3 =  createParitcle("tx/other/lizi_jzefg_dh_03.plist")
		pParitcle3:setPosition(25, -7)
		pParitcle3:setScale(0.7)
		self.pLayCityFire:addView(pParitcle3, 2)

		local pParitcle4 =  createParitcle("tx/other/lizi_jzefg_dh_04.plist")
		pParitcle4:setPosition(17, -3)
		self.pLayCityFire:addView(pParitcle4, 3)
	end
end

--停止火焰特效
function ImperialCityNew:stopCityFire(  )
	if self.pLayCityFire then
		self.pLayCityFire:setVisible(false)
	end
end

--创建火烧线火种
function ImperialCityNew:createFRopeFire(  )
	local pLayFire = MUI.MLayer.new()
	pLayFire:setLayoutSize(1, 1)
	
	--粒子
	local pParitcle1 =  createParitcle("tx/other/lizi_jzefg_dh_22.plist")
	pParitcle1:setScale(0.5)
	pLayFire:addView(pParitcle1)

	local pParitcle2 =  createParitcle("tx/other/lizi_jzefg_dh_17.plist")
	pParitcle2:setScale(0.9)
	pLayFire:addView(pParitcle2, 1)

	local pParitcle3 =  createParitcle("tx/other/lizi_jzefg_dh_20.plist")
	pParitcle3:setScale(0.5)
	pLayFire:addView(pParitcle3, 2)

	return pLayFire
end

--创建火烧线
function ImperialCityNew:createFireRope(  )
	local pSize = self.pLayRope:getContentSize()
	--左边线
	local pImgRopeLeft = display.newSprite("ui/big_img_sep/v2_img_huoyaoyin1.png")
	local pImgSize = pImgRopeLeft:getContentSize()
	local pProRopeLeft = cc.ProgressTimer:create(pImgRopeLeft)  
	self.pProRopeLeft = pProRopeLeft
	pProRopeLeft:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	pProRopeLeft:setMidpoint(cc.p(1,0)) --设置起点为条形坐下方  
	pProRopeLeft:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    pProRopeLeft:setPosition(pImgSize.width/2, pSize.height/2)
    self.pLayRope:addChild(pProRopeLeft)
    --左边火点
    self.pFRopeFireLeft = self:createFRopeFire()
    self.pFRopeFireLeft:setPosition(0, nFRopeY)
    self.pLayRope:addChild(self.pFRopeFireLeft,1)


	--右边线
   	local pImgRopeRight = display.newSprite("ui/big_img_sep/v2_img_huoyaoyin2.png")
	local pImgSize = pImgRopeRight:getContentSize()
	local pProRopeRight = cc.ProgressTimer:create(pImgRopeRight)  
	self.pProRopeRight = pProRopeRight
	pProRopeRight:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	pProRopeRight:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
	pProRopeRight:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    pProRopeRight:setPosition(pSize.width/2 + pImgSize.width/2, pSize.height/2)
    self.pLayRope:addChild(pProRopeRight)  
    --左边右点
	self.pFRopeFireRight = self:createFRopeFire()
	self.pFRopeFireRight:setPosition(461, nFRopeY)
    self.pLayRope:addChild(self.pFRopeFireRight,1)
end

--更新火烧线
function ImperialCityNew:updateFireRope(  )
	--如果是在播放动画中就返回
	if self.bIsPlayAniming then
		return
	end
		
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if not tImperialWarVo then
		return
	end
	local bIsWait = tImperialWarVo:getIsWaitAtk()
	local bIsNoAtk = tImperialWarVo:getIsNoAtk()
	if bIsWait or bIsNoAtk then
		self.pProRopeLeft:stopAllActions()
		self.pProRopeLeft:setPercentage(100)
		self.pFRopeFireLeft:setVisible(false)

		self.pProRopeRight:stopAllActions()
		self.pProRopeRight:setPercentage(100)
		self.pFRopeFireRight:setVisible(false)
		self.bIsPlayAniming = false
	else
		local nMaxTime = self.nMaxTime 
		if nMaxTime < 0 then
			nMaxTime = 0
		end
		local nCd = tImperialWarVo:getPrepareCd() - self.nHoldFire
		if nCd < 0 then
			nCd = 0
		end
		--左边进度条
		self.pProRopeLeft:setPercentage(nCd/nMaxTime * 100) --剩余长度
		local progressTo = cc.ProgressTo:create(nCd,0)  
	    local clear = cc.CallFunc:create(function (  ) 
	    	self.pFRopeFireLeft:setVisible(false) 
	    	self.pFRopeFireRight:setVisible(false)
	    	self:playZhanAmin()
	    end) 
	    local pAct = cc.Sequence:create(progressTo,clear)
	    self.pProRopeLeft:stopAllActions()
	    self.pProRopeLeft:runAction(pAct)
	    --左边进度条火花
	    self.pFRopeFireLeft:setVisible(true) 
	    self.pFRopeFireLeft:stopAllActions()  

	    local nCurrX = ((nMaxTime - nCd)/nMaxTime) * 230
	    self.pFRopeFireLeft:setPosition(nCurrX, nFRopeY)
	    self.pFRopeFireLeft:runAction(cc.MoveTo:create(nCd, cc.p(230, nFRopeY)))

	    --右边进度条
	    self.pProRopeRight:setPercentage(nCd/nMaxTime * 100)
		local progressTo = cc.ProgressTo:create(nCd,0)  
	    self.pProRopeRight:stopAllActions()
	    self.pProRopeRight:runAction(progressTo)
	    --左边进度条火花
	    self.pFRopeFireRight:setVisible(true) 
	    self.pFRopeFireRight:stopAllActions()

	    local nCurrX = 461 - ((nMaxTime - nCd)/nMaxTime) * 230
	    self.pFRopeFireRight:setPosition(nCurrX, nFRopeY)
	    self.pFRopeFireRight:runAction(cc.MoveTo:create(nCd, cc.p(230, nFRopeY)))
	end


end

--当火药引动画燃烧殆尽，播放战字动画。
function ImperialCityNew:playZhanAmin(  )
	if self.pZhanAmin then
		return
	end
	local tArmData1  = 
	{
		nFrame = 24, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_efg_zztx_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 24, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local nX, nY = self.pImgZhanFont:getPosition()
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayArmy, 
        12, 
        cc.p(nX, nY),
        function ( _pArm )
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:play(-1)
    	self.pZhanAmin = pArm
    end
end

function ImperialCityNew:stopZhanAmin(  )
	if self.pZhanAmin then
		self.pZhanAmin:removeSelf()
		self.pZhanAmin = nil
	end
end

--当火药引动画燃烧殆尽，出现碰撞动画。
function ImperialCityNew:playCollideAmin( )
	-- a、国家旗子 碰撞动画。
	self:playFlagAnim( )
	-- b、剑碰撞。
	self:playSwordAnim()
end

--撤退，强制停止活动
function ImperialCityNew:stopFightAnimNow(  )
	self.pLayFlagsLeft:stopAllActions()
	self.pLayFlagsLeft:setPositionX(0)
	self.pLayFlagsRight:stopAllActions()
	self.pLayFlagsRight:setPositionX(278)
	--播放动画结束，刷新最新数据
	self:stopZhanAmin()
	self.bIsPlayAniming = false
	self.pLayRope:setVisible(true)
	self:stopPlayTroopsNum()
	self:updateTroopsFlag()
	self:updateFireRope()
end

--播放旗子动画
function ImperialCityNew:playFlagAnim(  )
	--左边旗子
	-- 时间      位置（仅移动X）    
	-- 0秒           0
	-- 0.30秒        -10
	-- 0.42秒        12
	-- 0.71秒         0
	-- 1秒           -10
	-- 1.13秒        12
	-- 1.42秒         0
	local nX, nY = 0, 0
	self.pLayFlagsLeft:setPositionX(nX)
	local pAct = cc.Sequence:create({
		cc.MoveTo:create(0.3, cc.p(nX - 10, nY)),
		cc.CallFunc:create(function ( )
	 		self:playTroopsAnim(1)
	 		self:playTroopsFlagRed()
	 	end),
		cc.MoveTo:create(0.42 - 0.3, cc.p(nX + 12, nY)),
		cc.MoveTo:create(0.71 - 0.42, cc.p(nX, nY)),
		cc.MoveTo:create(1 - 0.71, cc.p(nX - 10, nY)),
		cc.CallFunc:create(function ( )
	 		self:playTroopsAnim(2)
	 		self:playTroopsFlagRed()
	 	end),
		cc.MoveTo:create(1.13 - 1, cc.p(nX + 12, nY)),
		cc.MoveTo:create(1.42 - 1.13, cc.p(nX, nY)),
		cc.CallFunc:create(function ( )
			--播放动画结束，刷新最新数据
			self:stopZhanAmin()
	 		self.bIsPlayAniming = false
	 		self.pLayRope:setVisible(true)
	 		self:stopPlayTroopsNum()
	 		self:updateTroopsFlag()
	 		self:updateFireRope()
	 	end),
	})
	self.pLayFlagsLeft:runAction(pAct)

	--右边旗子
	-- 时间      位置（仅移动X）    
	-- 0秒           0
	-- 0.30秒        10
	-- 0.42秒        -12
	-- 0.71秒         0
	-- 1秒           10
	-- 1.13秒        -12
	-- 1.42秒         0
	local nX, nY = 278, 0
	self.pLayFlagsRight:setPositionX(nX)
	local pAct = cc.Sequence:create({
		cc.MoveTo:create(0.3, cc.p(nX + 10, nY)),
		cc.MoveTo:create(0.42 - 0.3, cc.p(nX - 12, nY)),
		cc.MoveTo:create(0.71 - 0.42, cc.p(nX, nY)),
		cc.MoveTo:create(1 - 0.71, cc.p(nX + 10, nY)),
		cc.MoveTo:create(1.13 - 1, cc.p(nX - 12, nY)),
		cc.MoveTo:create(1.42 - 1.13, cc.p(nX, nY)),
	})
	self.pLayFlagsRight:runAction(pAct)
end

--播放数字
function ImperialCityNew:playTroopsAnim( nStep)
	-- if true and not self.tTroopsData then
	-- 	self.tTroopsData = {
	-- 		tAckTrpsPrev = {
	-- 			{k = 1, v = 3000},
	-- 			{k = 2, v = 3000},
	-- 			{k = 3, v = 3000},
	-- 		},
	-- 		nPrevDef = 1000,
	-- 		tAckTrps = {
	-- 			{k = 1, v = 2000},
	-- 			{k = 2, v = 2000},
	-- 			{k = 3, v = 2000},
	-- 		},
	-- 		nDef = 200,

	-- 	}
	-- end

	--最新配表
	local tAckTrpsDict = {}
	for i=1,#self.tTroopsData.tAckTrps do
		local k = self.tTroopsData.tAckTrps[i].k
		local v = self.tTroopsData.tAckTrps[i].v
		tAckTrpsDict[k] = v
	end
	local tChangeData = {}
	local nPrevDef = 0
	local nNextDef = 0
	if nStep == 1 then
		for i=1,#self.tTroopsData.tAckTrpsPrev do
			local k = self.tTroopsData.tAckTrpsPrev[i].k
			local v = self.tTroopsData.tAckTrpsPrev[i].v
			local nNewV = tAckTrpsDict[k] or 0
			table.insert(tChangeData, {nCountry = k, nPrevNum = v, nNextNum = v - math.floor((v - nNewV)/2)})
		end
		nPrevDef = self.tTroopsData.nPrevDef
		nNextDef = self.tTroopsData.nPrevDef - math.floor((self.tTroopsData.nPrevDef - self.tTroopsData.nDef)/2)
	else
		for i=1,#self.tTroopsData.tAckTrpsPrev do
			local k = self.tTroopsData.tAckTrpsPrev[i].k
			local v = self.tTroopsData.tAckTrpsPrev[i].v
			local nNewV = tAckTrpsDict[k] or 0
			local nPrevNum = v - math.floor((v - nNewV)/2)
			table.insert(tChangeData, {nCountry = k, nPrevNum = nPrevNum, nNextNum = nNewV})
		end
		nPrevDef = self.tTroopsData.nPrevDef - math.floor((self.tTroopsData.nPrevDef - self.tTroopsData.nDef)/2)
		nNextDef = self.tTroopsData.nDef
	end
	
	self.pUiList = {}
	--五个文字点位置
	local tPosList = {
		{52,  nFlagTxtY},
		{93,  nFlagTxtY},
		{134, nFlagTxtY},
		{175, nFlagTxtY},
		{216, nFlagTxtY},
	}
	local tPosList2 = {}
	local nCount = #tChangeData
	if nCount == 1 then
		tPosList2 = {tPosList[3]}
	elseif nCount == 2 then
		tPosList2 = {tPosList[2],tPosList[4]}
	elseif nCount == 3 then
		tPosList2 = {tPosList[1],tPosList[3],tPosList[5]}
	end
	for i=1,#self.tTroopsUi do
		local pUis = self.tTroopsUi[i]
		local pTxtTroops = pUis.pTxtTroops
		local pImgTroops = pUis.pImgTroops
		local tData = tChangeData[i]
		local tPos = tPosList2[i]
		if tData and tPos then
			pImgTroops:setVisible(true)
			pTxtTroops:setVisible(true)
			pImgTroops:setCurrentImage(WorldFunc.getCountryFlagImg(tData.nCountry))
			pImgTroops.pImgFlagRed:setCurrentImage(WorldFunc.getCountryFlagImg(tData.nCountry))
			pTxtTroops:setString(tData.nPrevNum)
			
			table.insert(self.pUiList, {pTxtUi = pTxtTroops, nPrevNum = tData.nPrevNum, nNextNum = tData.nNextNum})

			pTxtTroops:setPosition(tPos[1], tPos[2])
			pImgTroops:setPosition(tPos[1], tPos[2] + nFlagYAdd)
		else
			pImgTroops:setVisible(false)
			pTxtTroops:setVisible(false)
		end
	end
	--防守者兵力
	table.insert(self.pUiList, {pTxtUi = self.tDefTroops.pTxtTroops, nPrevNum = nPrevDef, nNextNum = nNextDef})
	self:playTroopsNum()
end

--播放数字(每0.05切换一次数字，共10次)
function ImperialCityNew:playTroopsNum(  )
	if not self.pUiList then
		return
	end
	self:stopPlayTroopsNum()
	self.nTroopsSchedulerI = 1
    self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
    	local nTroopsSchedulerMax = 10
    	self.nTroopsSchedulerI = self.nTroopsSchedulerI + 1
		for i=1,#self.pUiList do
			local pTroops = self.pUiList[i]
			local pTxtUi = pTroops.pTxtUi
			local nNextNum = pTroops.nNextNum
			local nPrevNum = pTroops.nPrevNum
			if self.nTroopsSchedulerI >= nTroopsSchedulerMax then
				pTxtUi:setString(nNextNum)
			else
				pTxtUi:setString(nPrevNum - math.floor((nPrevNum - nNextNum) * self.nTroopsSchedulerI/nTroopsSchedulerMax))
			end
		end
		if self.nTroopsSchedulerI >= nTroopsSchedulerMax then
			self:stopPlayTroopsNum()
		end
	end,0.05)
end

function ImperialCityNew:stopPlayTroopsNum(  )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

function ImperialCityNew:playTroopsFlagRed(  )
	for i=1,#self.tTroopsUi do
		local pUis = self.tTroopsUi[i]
		local pImgTroops = pUis.pImgTroops
		if pImgTroops:isVisible() then
			pImgTroops.pImgFlagRed:setOpacity(255)
			pImgTroops.pImgFlagRed:runAction(cc.FadeOut:create(0.25))
		end
	end
	self.tDefTroops.pImgTroops.pImgFlagRed:setOpacity(255)
	self.tDefTroops.pImgTroops.pImgFlagRed:runAction(cc.FadeOut:create(0.25))
end


--剑动画
function ImperialCityNew:playSwordAnim(  )
	-- 时间       旋转°      位置（仅移动X）     透明度
	-- 0秒         0               0               0
	-- 0.30秒      -73             -10             100
	-- 0.42秒      20              12              100
	-- 0.71秒      -41             0               100
	-- 1秒        -102             -10             100
	-- 1.13秒      20              12              100
	-- 1.42秒     -83              0               0
	local nX, nY = 278 - 25, 68 - 40
	if not self.pImgLeftSword then
		local pImgLeftSword =  display.newSprite("ui/big_img/rwww_efg_pzgx_x_001.png")
		pImgLeftSword:setPosition(nX, nY)
		self.pLayArmy:addView(pImgLeftSword, 13)
		self.pImgLeftSword = pImgLeftSword
	end
	self.pImgLeftSword:setOpacity(0)
	self.pImgLeftSword:setRotation(0)
	self.pImgLeftSword:setPositionX(nX)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.RotateTo:create(0.3, -73),
			cc.MoveTo:create(0.3, cc.p(nX-10, nY)),
			cc.FadeIn:create(0.3),
		}),
		cc.CallFunc:create(function ( )
	 		self:playSwordEffect()
	 	end),
		cc.Spawn:create({
			cc.RotateTo:create(0.42 - 0.3, 20),
			cc.MoveTo:create(0.42 - 0.3, cc.p(nX + 12, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(0.71 - 0.42, -41),
			cc.MoveTo:create(0.71 - 0.42, cc.p(nX, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(1 - 0.71, -102),
			cc.MoveTo:create(1 - 0.71, cc.p(nX - 10, nY)),
		}),
		cc.CallFunc:create(function ( )
	 		self:playSwordEffect()
	 	end),
		cc.Spawn:create({
			cc.RotateTo:create(1.13 - 1, 20),
			cc.MoveTo:create(1.13 - 1, cc.p(nX + 12, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(1.42 - 1.13, -83),
			cc.MoveTo:create(1.42 - 1.13, cc.p(nX, nY)),
			cc.FadeOut:create(1.42 - 1.13),
		}),
	})
	self.pImgLeftSword:runAction(pAct)

	--右边剑
	-- 时间       旋转°      位置（仅移动X）     透明度
	-- 0秒         0               0               0
	-- 0.30秒      71             -10             100
	-- 0.42秒      -12             12             100
	-- 0.71秒      36              0              100
	-- 1秒         85             -10             100
	-- 1.13秒      -12             12             100
	-- 1.42秒      113             0               0
	local nX, nY = 278 + 25, 68 - 40
	if not self.pImgRightSword then
		local pImgRightSword =  display.newSprite("ui/big_img/rwww_efg_pzgx_x_001.png")
		pImgRightSword:setPosition(nX, nY)
		pImgRightSword:setFlippedX(true)
		self.pLayArmy:addView(pImgRightSword, 13)
		self.pImgRightSword = pImgRightSword
	end
	self.pImgRightSword:setOpacity(0)
	self.pImgRightSword:setRotation(0)
	self.pImgRightSword:setPositionX(nX)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.RotateTo:create(0.3, 71),
			cc.MoveTo:create(0.3, cc.p(nX+10, nY)),
			cc.FadeIn:create(0.3),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(0.42 - 0.3, -12),
			cc.MoveTo:create(0.42 - 0.3, cc.p(nX - 12, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(0.71 - 0.42, 36),
			cc.MoveTo:create(0.71 - 0.42, cc.p(nX, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(1 - 0.71, 85),
			cc.MoveTo:create(1 - 0.71, cc.p(nX + 10, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(1.13 - 1, -12),
			cc.MoveTo:create(1.13 - 1, cc.p(nX - 12, nY)),
		}),
		cc.Spawn:create({
			cc.RotateTo:create(1.41 - 1.13, 113),
			cc.MoveTo:create(1.41 - 1.13, cc.p(nX, nY)),
			cc.FadeOut:create(1.41 - 1.13),
		}),
	})
	self.pImgRightSword:runAction(pAct)
end

function ImperialCityNew:playSwordEffect(  )
	local nX, nY = 278 + 10, 60 - 10
	local tArmData1  = 
	{
		nFrame = 13, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.25,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_efg_pzgx_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 13, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayArmy, 
        14, 
        cc.p(nX, nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:play(1)
    end
end

-----------------------------------集结特效
function ImperialCityNew:createTogetherGray(  )
	local pLayGray = MUI.MLayer.new()
	self.pLayGray = pLayGray
	pLayGray:setContentSize(87, 87)

	local pImgIcon = display.newSprite("ui/big_img/gray_together.png")
	local pProGrayIcon = cc.ProgressTimer:create(pImgIcon)  
	self.pProGrayIcon = pProGrayIcon
	pProGrayIcon:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	pProGrayIcon:setMidpoint(cc.p(0,1)) --设置起点为条形坐下方  
	pProGrayIcon:setBarChangeRate(cc.p(0,1))  --设置为竖直方向  
	pLayGray:addView(pProGrayIcon)
	centerInView(pLayGray, pProGrayIcon)
	pProGrayIcon:setScale(0.8)

	self.pLayGray:setPosition(416, 26)
	self.pLayTop:addView(self.pLayGray, 3)
end

--更新集结
function ImperialCityNew:udpateTogether(  )
	local nEffectCd = 0 --有效时间
	local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
	if tImperialWarVo then
		nEffectCd = tImperialWarVo:getToCd()
	end
	if nEffectCd > 0 then
		self.pProGrayIcon:stopAllActions()
		self.pProGrayIcon:setPercentage((1 - nEffectCd/self.nTogetherSec) * 100)
		local pAct = cc.Sequence:create({
			cc.ProgressTo:create(nEffectCd,100),
			cc.CallFunc:create(function ( )
				--文字置灰
		 		self.pTxtGoods:setString(getConvertedStr(3, 10849))
				setTextCCColor(self.pTxtGoods, _cc.gray)
		 	end),
			})
	    self.pProGrayIcon:runAction(pAct)

		self.pTxtGoods:setString(getConvertedStr(3, 10850))
		setTextCCColor(self.pTxtGoods, _cc.red)
	else
		self.pProGrayIcon:stopAllActions()
		self.pProGrayIcon:setPercentage(100)

		self.pTxtGoods:setString(getConvertedStr(3, 10849))
		setTextCCColor(self.pTxtGoods, _cc.gray)
	end
end

function ImperialCityNew:onShowFight(  )
	self:updateTroopsFlag(true)
end

return ImperialCityNew
