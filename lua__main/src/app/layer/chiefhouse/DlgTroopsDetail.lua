-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-25 11:11:23 星期一
-- Description: 高级御兵术 对话框
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemChiefLayer = require("app.layer.chiefhouse.ItemChiefLayer")
local DlgTroopsDetail = class("DlgTroopsDetail", function()
	-- body
	return DlgBase.new(e_dlg_index.troopsdetail)
end)

function DlgTroopsDetail:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_troops_detail", handler(self, self.onParseViewCallback))
end

function DlgTroopsDetail:myInit(  )
	-- body
	self.nCurSelectType = 0
	self.progressArm = nil
end

--解析布局回调事件
function DlgTroopsDetail:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	--设置标题
	self:setTitle(getConvertedStr(6,10656))
	self:setupView()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTroopsDetail",handler(self, self.onDestroy))
end
function DlgTroopsDetail:setupView(  )
	-- body
	self.pLayRoot 			= 		self:findViewByName("dlg_troops_detail")
	self.pLayMain 			= 		self:findViewByName("lay_mian")

	self.pArrowRight 		= 		self:findViewByName("img_right")	
	
	--进度层
	self.pLayProgress 		= 		self:findViewByName("lay_progresss")
	self.pLbSec 			= 		self:findViewByName("lb_sec")
	--进度条
	self.pLayBarBg 			= 		self:findViewByName("lay_bar")
	self.pImgRes1 = self:findViewByName("img_res_1")
	self.pImgRes2 = self:findViewByName("img_res_2")
	self.pLbCost1 = self:findViewByName("lb_cost_1") 
	self.pLbCost2 = self:findViewByName("lb_cost_2") 

	self.pTroopIcon 		= 		self:findViewByName("img_troop_icon")	
			
	--等级信息
	self.pLayNormalLv = self:findViewByName("lay_level_unfull") 
	self.pLbPar1 = self:findViewByName("lb_pa_1")
	self.pLbPar2 = self:findViewByName("lb_pa_2")
	self.pLbPar3 = self:findViewByName("lb_pa_3")
	self.pLbPar4 = self:findViewByName("lb_pa_4")	
	self.pLayTopLv = self:findViewByName("lay_level_full") 
	self.pLbPar5 = self:findViewByName("lb_pa_5")
	self.pLbPar6 = self:findViewByName("lb_pa_6")	


	self.pLayBot  			= 		self:findViewByName("lay_bot") 
	--升级Cd 				
	self.pLbCd 				=		self:findViewByName("lb_cd") 

	--按钮
	self.pLayBtn 			= 		self:findViewByName("lay_btn")
	
 	self.pLbBotTip 			= 		self:findViewByName("lb_bot_tip")
	--解锁提示语
	self.pLbLockTip 		= 		self:findViewByName("lb_lock_tip")	
	--等级限制提示
	self.pLbLimitTip 		= 		self:findViewByName("lb_limit_tip")
	self.pArrowRight:setFlippedX(true)		

	self.pBtn 				= 		getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10089))
	--
 	self.pProgressBar 		= 		MCommonProgressBar.new({bar = "v1_bar_blue_6.png",barWidth = 566, barHeight = 16})
	self.pTx = createSliderTx(self.pProgressBar)
	self.pProgressBar:setPosition(2, 1)
	self.pLayBarBg:addView(self.pProgressBar, 10)
	centerInView(self.pLayBarBg, self.pProgressBar)	
	self.pProgressBar:setPercent(0)	


	setTextCCColor(self.pLbLockTip, _cc.red)
	setTextCCColor(self.pLbLimitTip, _cc.red)

	self.tItemTroops = {}
	local nHeightY = 710
	local nDisW 	= 200
	for i = 1, 3 do
		if not self.tItemTroops[i] then
			local pItemTroop = ItemChiefLayer.new()
			pItemTroop:setClickHandler(handler(self, self.onItemChiefClick))
			pItemTroop:setPosition(self.pLayMain:getWidth()/2 + (i - 2)*nDisW - pItemTroop:getWidth()/2, nHeightY)
			self.pLayMain:addView(pItemTroop)
			self.tItemTroops[i] = pItemTroop
		end
	end

 	self.pLbBotTip:setString(getTipsByIndex(20094))
	--文本
	local tBtnLUpTable = {}
	local tUpLLabel = {
		{"",getC3B(_cc.pwhite)},
		{"",getC3B(_cc.white)},
		{"",getC3B(_cc.pwhite)},
	}
	tBtnLUpTable.tLabel = tUpLLabel
	tBtnLUpTable.img = "#v1_img_qianbi.png"
	self.pBtnExText =  self.pBtn:setBtnExText(tBtnLUpTable)			

	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local nStage = pBChiefData.nStage
	if nStage%3 == 0 then
		self.nCurSelectType = 3
	else
		self.nCurSelectType = nStage%3 
	end
	for k, v in pairs(self.tItemTroops) do
		v:setItemSelected(k == self.nCurSelectType)	
	end	
end

--控件刷新
function DlgTroopsDetail:updateViews(  )
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	-- dump(pBChiefData, "pBChiefData", 100)
	if not pBChiefData then
		return
	end

	local nLeftTime  		=		pBChiefData:getTroopCdTime()	
	if nLeftTime > 0 then
		self.pLbCd:setVisible(true)
		regUpdateControl(self, handler(self, self.onUpdateTime))		
	else
		self.pLbCd:setVisible(false)
		unregUpdateControl(self)--停止计时刷新
	end	

	self:refreshTroopItems()
	self:refreshTroopDetail()


end

function DlgTroopsDetail:refreshTroopItems(  )
	-- body
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local tDataList 		= 		pBChiefData:getTroopItemsData()
	for k, v in pairs(tDataList) do
		local nType = v.type
		self.tItemTroops[nType]:setCurData(v)		
	end
end

function DlgTroopsDetail:refreshTroopDetail( )
	-- body
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local pItem 			= 		self.tItemTroops[self.nCurSelectType]
	local pCurTroop         = 		pItem:getData()	
	local pTroopVo 			= 		pBChiefData:getCurTroopVo(pCurTroop.type)	
	if not pCurTroop or not pTroopVo then
		return	
	end
	local nTroopMaxLv = tonumber(getWallInitParam("queueMaxLv") or 0)
	self.pTroopIcon:setCurrentImage("#"..pCurTroop.icon..".png")

	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local nStage = pBChiefData.nStage
 	local nLimitLv = tonumber(pCurTroop.lvlimit or 0)
	local pNextTroop = getTroopsVoById(pCurTroop.id + 3)	
	self.pLbLimitTip:setString(string.format(getConvertedStr(6, 10840), nLimitLv), false)
	local bLimit = false
	if (pTroopVo.nStage <= 0 and pTroopVo.nSec <= 0 and Player:getPlayerInfo().nLv < nLimitLv ) then--等级限制		
		bLimit = true
	end	
	local bLocked = false
	if pCurTroop.id > nStage then
		bLocked = true
	end
	if bLocked or bLimit then--未解锁
		self.pLayNormalLv:setVisible(true)
		self.pLayTopLv:setVisible(false)
		self.pLayProgress:setVisible(false)
		self.pLayBot:setVisible(true)
		self.pLbLockTip:setVisible(bLocked)
		self.pLbLimitTip:setVisible(bLimit)		
		self:updateTroopDetail(pCurTroop, 1)
		self.pBtn:setBtnVisible(false)
		self.pBtn:removeLingTx()
		
		local pPrevTroop = getTroopsVoById(pCurTroop.id - 1)
		local sStr = {
			{color=_cc.red, text =getConvertedStr(6, 10660)},
			{color=_cc.red, text =pPrevTroop.name},
			{color=_cc.red, text =getLvString(pPrevTroop.lv, false)},
			{color=_cc.red, text =getConvertedStr(6, 10152)},
		}
		self.pLbLockTip:setString(sStr, false)
		-- self.pBtn:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(6, 10663))
		-- self.pBtn:onCommonBtnClicked(handler(self, self.onGuideLvUpBtnClicked))
		-- self.pBtn:setExTextVisiable(false)		
		return
	else
		self.pLbLimitTip:setVisible(false)
		self.pBtn:setBtnVisible(true)
		if pTroopVo.nLv == nTroopMaxLv then--满级
			self.pLayNormalLv:setVisible(false)
			self.pLayTopLv:setVisible(true)		
			self.pLayProgress:setVisible(false)
			self.pLayBot:setVisible(false)
			self.pLbLockTip:setVisible(true)
			setTextCCColor(self.pLbLockTip, _cc.red)
			self.pLbLockTip:setString(getConvertedStr(6, 10659), false)
			self:updateTroopDetail(pCurTroop, 2)
			return
		else--未满级
			self.pLayNormalLv:setVisible(true)
			self.pLayTopLv:setVisible(false)
			self.pLayProgress:setVisible(true)
			self.pLayBot:setVisible(true)
			self.pLbLockTip:setVisible(false)
			local sStr = nil
			if pCurTroop.section > pTroopVo.nSec then
				sStr = {
					{color=_cc.pwhite, text=getConvertedStr(6, 10669)},
					{color=_cc.pwhite, text=pTroopVo.nSec.."/"..pCurTroop.section}
				}
			else
				sStr = {
					{color=_cc.pwhite, text=getConvertedStr(6, 10669)},
					{color=_cc.blue, text=getConvertedStr(6, 10670)}
				}
			end
			self.pLbSec:setString(sStr, false)
			local nPercent = pTroopVo.nStage
			self:setProgressTx(nPercent)
			if nPercent >= 20 then
				setSliderTxVisible(self.pTx , true)
				for k, v in pairs(self.pTx.pArm) do
					v:setPosition(cc.p(nPercent*self.pProgressBar:getWidth()/100, self.pProgressBar:getContentSize().height/2))
				end
				self.pTx.pLizi:setPosition(nPercent*self.pProgressBar:getWidth()/100, self.pProgressBar:getContentSize().height/2)
			else
				setSliderTxVisible(self.pTx , false)
			end
			self.pProgressBar:setPercent(nPercent)
			self.pProgressBar:setProgressBarText(pTroopVo.nStage.."%")
			self:updateTroopDetail(pCurTroop, 1)

			self:refreshLvUpCost(luaSplitMuilt(pCurTroop.cost, ";", ":"))
			self.pBtn:setExTextVisiable(true)
			self:updateLvUpBtn()
			if pBChiefData:isShowActivate() == true then
				self.pBtn:showLingTx()				
				self.pBtn:onCommonBtnClicked(handler(self, self.onActiviteBtnClicked))	
			else
				self.pBtn:removeLingTx()
				self.pBtn:onCommonBtnClicked(handler(self, self.onLvUpBtnClicked))	
			end			
			
		end
	end
end
function DlgTroopsDetail:updateLvUpBtn( )
	-- body
	local nLimitMaxTime = tonumber(getWallInitParam("queueMaxLimit") or 0)
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local nRate = pBChiefData.nRate
	if pBChiefData:isShowActivate() == true then--激活状态
		self.pBtn:setExTextImg(nil)
		self.pBtn:setExTextLbCnCr(1, getConvertedStr(6, 10668), getC3B(_cc.pwhite))
		self.pBtn:setExTextLbCnCr(2, "")
		self.pBtn:setExTextLbCnCr(3, "")
		self.pBtn:updateBtnType(TypeCommonBtn.L_YELLOW)	
		self.pBtn:updateBtnText(getConvertedStr(6, 10530))	
		return	
	else
		local nLeftTime = pBChiefData:getTroopCdTime()
		local nShowCost = false
		local nCost = tonumber(pBChiefData:getGoldCost() or 0)
		--todo	
		if (nLeftTime > nLimitMaxTime and nCost > 0) then--显示花费
			self.pBtn:setExTextImg("#v1_img_qianbi.png")			
			self.pBtn:setExTextLbCnCr(1, nCost, getC3B(_cc.pwhite))
			self.pBtn:setExTextLbCnCr(2, "")
			self.pBtn:setExTextLbCnCr(3, "")	
			self.pBtn:updateBtnType(TypeCommonBtn.L_YELLOW)		
			self.pBtn:updateBtnText(getConvertedStr(6, 10664))					
		else
			if nRate > 1 then
				self.pBtn:setExTextImg(nil)
				self.pBtn:setExTextLbCnCr(1, getConvertedStr(7, 10024), getC3B(_cc.pwhite))
				self.pBtn:setExTextLbCnCr(2, nRate.."%", getC3B(_cc.white))
				self.pBtn:setExTextLbCnCr(3, getConvertedStr(5, 10111), getC3B(_cc.pwhite))
				self.pBtn:updateBtnText(nRate..getConvertedStr(6, 10665))
				self.pBtn:updateBtnType(TypeCommonBtn.L_YELLOW)				
				return	
			else
				self.pBtn:updateBtnType(TypeCommonBtn.L_BLUE)	
				self.pBtn:setExTextImg(nil)
				self.pBtn:setExTextLbCnCr(1, getConvertedStr(7, 10024), getC3B(_cc.pwhite))
				self.pBtn:setExTextLbCnCr(2, nRate.."%", getC3B(_cc.white))
				self.pBtn:setExTextLbCnCr(3, getConvertedStr(5, 10111), getC3B(_cc.pwhite))
				self.pBtn:updateBtnText(getConvertedStr(6, 10388))				
			end			
		end			
	end
end


function DlgTroopsDetail:refreshLvUpCost( tCost )
	-- body
	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0

	local tCost1 = tCost[1]
	--dump(tCost, "tCost", 100)
	local nNum1 = tonumber(tCost1[2] or 0)
	self.tResList[tonumber(tCost1[1] or 0)] =  nNum1
	local nMyNum1 = Player:getPlayerInfo():getBaseResNum(tonumber(tCost1[1] or 0))
	local sColor1 = _cc.blue
	if nNum1 > nMyNum1 then
		sColor1 = _cc.red
	end
	self.pImgRes1:setCurrentImage(getCostResImg(tonumber(tCost1[1] or 0)))
	local sStr1 = {
		{color=sColor1, text=getResourcesStr(nMyNum1)},
		{color=_cc.pwhite, text="/"..getResourcesStr(nNum1)}
	}
	self.pLbCost1:setString(sStr1)
	
	local tCost2 = tCost[2]	
	local nNum2 = tonumber(tCost2[2] or 0)
	self.tResList[tonumber(tCost2[1] or 0)] =  nNum2
	local nMyNum2 = Player:getPlayerInfo():getBaseResNum(tonumber(tCost2[1] or 0))
	local sColor2 = _cc.blue
	if nNum2 > nMyNum2 then
		sColor2 = _cc.red
	end	
	self.pImgRes2:setCurrentImage(getCostResImg(tonumber(tCost2[1] or 0)))	 
	local sStr2 = {
		{color=sColor2, text=getResourcesStr(nMyNum2).."/"},
		{color= _cc.pwhite, text=getResourcesStr(nNum2)},
	}
	self.pLbCost2:setString(sStr2)
end

--析构方法
function DlgTroopsDetail:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgTroopsDetail:regMsgs(  )
	-- body
	-- 注册统帅府数据刷新
	regMsg(self, ghd_refresh_chiefhouse_msg, handler(self, self.updateViews))
	-- 资源刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	

	--升级暴击
	regMsg(self, ghd_refresh_troop_trap_msg, handler(self, self.onTroopTrap))
end
--注销消息
function DlgTroopsDetail:unregMsgs(  )
	-- bodypProgressBar
	-- 注销统帅府数据刷新
	unregMsg(self, ghd_refresh_chiefhouse_msg)
	-- 注销玩家信息刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
    --升级暴击
	unregMsg(self, ghd_refresh_troop_trap_msg)	
end

--暂停方法
function DlgTroopsDetail:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgTroopsDetail:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end

function DlgTroopsDetail:onItemChiefClick( _data )
	-- body
	-- dump(_data, "_data", 100)
	if not _data then
		print("error data !")
		return
	end	
	local nType = _data.type
	if self.nCurSelectType ~= nType then
		self.nCurSelectType = nType 
		self:refreshTroopDetail()		
	end	
	self:updateItemSelectedStatus()
end

function DlgTroopsDetail:onGuideLvUpBtnClicked( _pView )
	-- body
	-- print("升级按钮引导")
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	if not pBChiefData then
		return
	end
	local pBaseTroop = getTroopsVoById(pBChiefData.nStage)	
	local nType = pBaseTroop.type
	if self.nCurSelectType ~= nType then
		self.nCurSelectType = nType 
		self:refreshTroopDetail()	
	end	
	self:updateItemSelectedStatus()	
end

function DlgTroopsDetail:updateItemSelectedStatus(  )
	-- body
	for k, v in pairs(self.tItemTroops) do
		v:setItemSelected(k == self.nCurSelectType)	
	end
end
--升级
function DlgTroopsDetail:onLvUpBtnClicked( )
	-- body
	--print("升级按钮")
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	if not pBChiefData then
		return 
	end	
	local nLimitMaxTime = tonumber(getWallInitParam("queueMaxLimit") or 0)	
	local nLeftTime = pBChiefData:getTroopCdTime()
	local nCost = pBChiefData:getGoldCost()
	local nHasMoney = Player:getPlayerInfo().nMoney

	local bTotalNum, nNum = pBChiefData:getLeftLvUpTimes()
	local nLeftNum = bTotalNum - nNum
	local sColor = _cc.green
	if nLeftNum == 0 then
		sColor = _cc.red
	end
	if nLeftTime > nLimitMaxTime then--显示花费
		if nLeftNum > 0 then
			local strTips = {
    	    	{color=_cc.pwhite,text=getConvertedStr(6, 10667)},--扩充招募队列
    	    	{color=_cc.pwhite,text=getVipLvString(Player:getPlayerInfo().nVip)},
    	    	{color=_cc.pwhite,text=getConvertedStr(6, 10672)},
    	    	{color=sColor, text=nLeftNum},
    	    	{color=_cc.pwhite, text="/"..bTotalNum},
    	    }
			showBuyDlg(strTips, nCost, function (  )
				-- body
				SocketManager:sendMsg("reqUnLockTcfPos", {3}, handler(self, self.onGetCallBack))
			end, 0, false)
		else
			TOAST(getTipsByIndex(680))
		end
	else
		SocketManager:sendMsg("reqUnLockTcfPos", {3}, handler(self, self.onGetCallBack))				
	end
	
end
--激活
function DlgTroopsDetail:onActiviteBtnClicked(  )	
	-- body
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	local pBaseTroop = getTroopsVoById(pBChiefData.nStage)
	if pBaseTroop then
		SocketManager:sendMsg("reqTroopActivite", {pBaseTroop.type}, handler(self, self.onReqTroopActivieBack))			
	end
end

function DlgTroopsDetail:onReqTroopActivieBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			--dump(__msg.body, "__msg.body", 100)
			self:playFontAction("#v2_fonts_shengjichenggong_yb.png")
		end
	end
end

function DlgTroopsDetail:onTroopTrap( sMsgName, pMsgObj )
	-- body
	local nTrapRate = pMsgObj
	if nTrapRate and nTrapRate > 1 then
		self:playFontAction(nil, nTrapRate)		
	end
	self:showNumJump(nTrapRate)
end
function DlgTroopsDetail:onGetCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		if __msg.head.type == MsgType.reqUnLockTcfPos.id then
			--TOAST(getConvertedStr(6, 10666))
		end
	else
    	local nResID = nil
		if __msg.head.state == 233 then --银币不足
			nResID = e_resdata_ids.yb
		elseif __msg.head.state == 231 then--木材不足
			nResID = e_resdata_ids.mc
		elseif __msg.head.state == 232 then--粮草不足
			nResID = e_resdata_ids.lc
		elseif __msg.head.state == 230 then--铁矿不足			
			nResID = e_resdata_ids.bt		
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
			return	
		end
		if nResID then
			if self and self.tResList then
				goToBuyRes(nResID,self.tResList)
			else
				goToBuyRes(nResID)
			end
		end		
	end	
end

function DlgTroopsDetail:onUpdateTime(  )
	-- body
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	if not pBChiefData then
		return
	end
	local nLimitMaxTime = tonumber(getWallInitParam("queueMaxLimit") or 0)
	local nLeftTime  		=		pBChiefData:getTroopCdTime()	
	local sColor = ""
	if nLeftTime < nLimitMaxTime then  
		sColor = _cc.green
	else
		sColor = _cc.red
	end
	local sTimeStr 			= 		{
		{color=_cc.pwhite,text=getConvertedStr(6, 10658)},
		{color=sColor,text=formatTimeToHms(nLeftTime)},		
	}	
	
	if nLeftTime > 0 then		
		self.pLbCd:setString(sTimeStr)	
		if nLeftTime == nLimitMaxTime then
			self:updateViews()
		end	
	else
		unregUpdateControl(self)--停止计时刷新
		self:updateViews()
	end

end

function DlgTroopsDetail:updateTroopDetail( pCurTroop, nType )
	-- body	
	local tPar = luaSplit(pCurTroop.row, ",")
	-- dump(tPar, "tPar", 100)
	if nType == 1 then
		local sStr1 = {
			{color=_cc.pwhite, text =pCurTroop.name..getSpaceStr(1)},
			{color=_cc.white, text =getLvString(pCurTroop.lv - 1, false)},
		}
		self.pLbPar1:setString(sStr1)
		
		local sStr2 = {
			{color=_cc.pwhite, text=getConvertedStr(6,10661)},
			{color=_cc.green, text=tostring(tPar[1] or 0)},
			{color=_cc.white, text=getConvertedStr(6,10662)},
		}
		self.pLbPar2:setString(sStr2)

		local sStr3 = {
			{color=_cc.pwhite, text =pCurTroop.name..getSpaceStr(1)},
			{color=_cc.green, text =getLvString(pCurTroop.lv, false)},
		}
		self.pLbPar3:setString(sStr3)
		
		local sStr4 = {
			{color=_cc.pwhite, text=getConvertedStr(6,10661)},
			{color=_cc.green, text=tostring(tPar[2] or 0)},
			{color=_cc.pwhite, text=getConvertedStr(6,10662)},
		}
		self.pLbPar4:setString(sStr4)
	else				
		local sStr5 = {
			{color=_cc.pwhite, text =pCurTroop.name..getSpaceStr(1)},
			{color=_cc.green, text =getLvString(pCurTroop.lv, false)},
		}
		self.pLbPar5:setString(sStr5)
		
		local sStr6 = {
			{color=_cc.pwhite, text=getConvertedStr(6,10661)},
			{color=_cc.green, text=tostring(tPar[2] or 0)},
			{color=_cc.pwhite, text=getConvertedStr(6,10662)},
		}
		self.pLbPar6:setString(sStr6)
	end
end
--播放文字特效
function DlgTroopsDetail:playFontAction(_sImgPath, _nTrapRate, _nhandler)
	-- body
	--字体动画
--[[	dump(_sImgPath, "_sImgPath",100)
	dump(_nTrapRate, "_sImgPath",100)
	dump(_nhandler, "_sImgPath",100)--]]
    local pFontPos = cc.p(self:getWidth()/2, 537) --大概神兵的中间
    --第一层
    local pImgFont1 = self:createFontLay(_sImgPath, _nTrapRate)--MUI.MImage.new(_sImgPath)
    if not pImgFont1 then return end
    pImgFont1:setPosition(pFontPos)
    self.pLayMain:addView(pImgFont1, 1000)    
    pImgFont1:setScale(0.25)
    local pSequence = cc.Sequence:create({
        cc.ScaleTo:create(0.13, 1.1),
        cc.ScaleTo:create(0.08, 0.98),
        cc.ScaleTo:create(0.09, 1),
        cc.ScaleTo:create(0.8, 1),
        cc.Spawn:create({
            cc.ScaleTo:create(0.54, 1),
            cc.MoveTo:create(0.54, cc.p(pFontPos.x, pFontPos.y + 43)),
            cc.FadeOut:create(0.54),
            }),
        cc.CallFunc:create(function()
            pImgFont1:removeSelf()
            if _nhandler then
            	_nhandler()
            end
        end)
        })
    pImgFont1:runAction(pSequence)

    --第二层, 加亮
    local pImgFont2 = self:createFontLay(_sImgPath, _nTrapRate, true)           --MUI.MImage.new(_sImgPath)    
    if not pImgFont2 then return end
    pImgFont2:setPosition(pFontPos)
    self.pLayMain:addView(pImgFont2, 1000)
    pImgFont2:setScale(0.25)
    local pSequence = cc.Sequence:create({
        cc.ScaleTo:create(0.13, 1.1),
        cc.ScaleTo:create(0.08, 0.98),
        
        cc.Spawn:create({
            cc.ScaleTo:create(0.09, 1),
            cc.FadeTo:create(0.09, 255*0.75),
            }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.25, 1),
            cc.FadeOut:create(0.25),
            }),
        cc.CallFunc:create(function()
            pImgFont2:removeSelf()
        end)
        })
    pImgFont2:runAction(pSequence)

    --第三层, 加亮
    local pImgFont3 = self:createFontLay(_sImgPath, _nTrapRate, true)            --MUI.MImage.new(_sImgPath)
    if not pImgFont3 then return end   
    pImgFont3:setPosition(pFontPos)
    self.pLayMain:addView(pImgFont3, 1000)
    local pSequence = cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.13, 1.25),
            cc.FadeTo:create(0.13, 255),
            }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.72, 1.37),
            cc.FadeOut:create(0.72),
            }),
        cc.CallFunc:create(function()
            pImgFont3:removeSelf()
        end)
        })
    pImgFont3:runAction(pSequence)
end

--创建字体层
function DlgTroopsDetail:createFontLay(_sImgPath, _nTrapRate, _bBlend)
	-- body
    local fontLay
    if _sImgPath then
    	fontLay = MUI.MImage.new(_sImgPath)
    	if _bBlend then
			fontLay:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		end
	end
   	if _nTrapRate and _nTrapRate > 1 then
    	fontLay = self:createImgLay(_nTrapRate, _bBlend)
    elseif _sImgPath then
    	fontLay = MUI.MImage.new(_sImgPath)
    	if _bBlend then
			fontLay:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		end
    end
    if fontLay then
		fontLay:setAnchorPoint(cc.p(0.5, 0.5))
    end
    return fontLay
end

--暴击字体图片
function DlgTroopsDetail:createImgLay(_nTrapRate, _bBlend)
	-- body
	--获取暴击倍数	
	if not _nTrapRate then
		return
	end
	local pLay = MUI.MLayer.new()
	local pLbBaoji = MUI.MLabelAtlas.new({text = _nTrapRate, 
	    png = "ui/atlas/v2_img_baojishuzi.png", pngw=25, pngh=46, scm=48})
	pLay:addView(pLbBaoji, 1)
	pLbBaoji:setPosition(0, 26)
	pLbBaoji:setAnchorPoint(cc.p(0, 0.5))
	local pImg = MUI.MImage.new("#v2_fonts_beibaoji_yb.png")
	if _bBlend then
		pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	pLay:addView(pImg, 1)
	pImg:setAnchorPoint(cc.p(0, 0.5))
	if _nTrapRate >= 10 then
		pImg:setPosition(60, 26)
	else
		pImg:setPosition(35, 26)
	end
	pLay:setLayoutSize(pLbBaoji:getContentSize().width + pImg:getContentSize().width, pImg:getContentSize().height)
	return pLay
end

function DlgTroopsDetail:setProgressTx(_nPrecent)
	_nPrecent = _nPrecent or 0
	if not self.progressArm then
		--addTextureToCache("tx/other/sg_wjjj_jdt")
		self.progressArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["50"],
			self.pProgressBar,
			15,
			cc.p(0,0),
			function ( _pArm )
			end, Scene_arm_type.normal)
		if self.progressArm then
			self.progressArm:play(1)
		end
	else
		self.progressArm:play(1)
	end
	self.progressArm:setPosition(cc.p((_nPrecent*self.pProgressBar:getWidth()-3)/100, 7))
	
end

function DlgTroopsDetail:hideProgressTx()
	if self.progressArm then
		self.progressArm:setVisible(false)
	end
end

function DlgTroopsDetail:showNumJump(_num)
	local pLayArm = showNumJump(_num, true)
	if pLayArm then
		self.pLayBarBg:addView(pLayArm, 99)
		pLayArm:setPosition(self.pLayBarBg:getWidth()/2, -40)
	end	

end
return DlgTroopsDetail
