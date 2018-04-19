----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 城战子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
--城战类型 1:短途战 2:合围战 3:奔袭战
local e_wartype ={
	short = 1,
	merge = 2,
	run = 3,
}

local nImperialCityMapId = 1013 --皇城mapId

local CityDetailAttack = class("CityDetailAttack", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CityDetailAttack:ctor(  )
	--解析文件
	parseView("layout_city_detail_attack", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CityDetailAttack:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CityDetailAttack",handler(self, self.onCityDetailAttackDestroy))
end

-- 析构方法
function CityDetailAttack:onCityDetailAttackDestroy(  )
    self:onPause()
end

function CityDetailAttack:regMsgs(  )

	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.updateViews))
	-- 注册国家数据变化消息
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))
end

function CityDetailAttack:unregMsgs(  )
	unregMsg(self, ghd_refresh_energy_msg)		
	unregMsg(self, gud_refresh_country_msg)	
end

function CityDetailAttack:onResume(  )
	self:regMsgs()
end

function CityDetailAttack:onPause(  )
	self:unregMsgs()
end

function CityDetailAttack:setupViews(  )
	--方式1
	local pTxtAtkName1 = self:findViewByName("txt_atk_name1")
	pTxtAtkName1:setString(getConvertedStr(3, 10030))
	setTextCCColor(pTxtAtkName1, _cc.green)

	local pTxtTip1 = self:findViewByName("txt_atk_tip1")
	pTxtTip1:setString(getConvertedStr(3, 10031))
	setTextCCColor(pTxtTip1, _cc.green)

	self.pTxtCost1 = self:findViewByName("txt_cost1")
	self.pTxtStayTime1 = self:findViewByName("txt_stay_time1")
	local pLayBtn1 = self:findViewByName("lay_btn1")
	self.pBtn1 = getCommonButtonOfContainer(pLayBtn1,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10035))
	self.pBtn1:onCommonBtnClicked(handler(self, self.onBtn1Clicked))
	self.pBtn1:setBtnExText({tLabel = {{"cost:"},{"0",getC3B(_cc.green)}, {""}}})

	--方式2
	local pTxtAtkName2 = self:findViewByName("txt_atk_name2")
	pTxtAtkName2:setString(getConvertedStr(3, 10032))
	setTextCCColor(pTxtAtkName2, _cc.blue)

	local pTxtTip2 = self:findViewByName("txt_atk_tip2")
	pTxtTip2:setString(getConvertedStr(3, 10033))
	setTextCCColor(pTxtTip2, _cc.blue)

	self.pTxtCost2 = self:findViewByName("txt_cost2")
	self.pTxtStayTime2 = self:findViewByName("txt_stay_time2")
	local pLayBtn2 = self:findViewByName("lay_btn2")
	self.pBtn2 = getCommonButtonOfContainer(pLayBtn2,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10035))
	self.pBtn2:onCommonBtnClicked(handler(self, self.onBtn2Clicked))
	self.pBtn2:setBtnExText({tLabel = {{"cost:"},{"0",getC3B(_cc.green)}}})

	--方式3
	local pTxtAtkName3 = self:findViewByName("txt_atk_name3")
	pTxtAtkName3:setString(getConvertedStr(3, 10034))
	setTextCCColor(pTxtAtkName3, _cc.yellow)

	local pTxtTip3 = self:findViewByName("txt_atk_tip3")
	pTxtTip3:setString(getConvertedStr(3, 10033))
	setTextCCColor(pTxtTip3, _cc.yellow)

	self.pTxtCost3 = self:findViewByName("txt_cost3")
	self.pTxtStayTime3 = self:findViewByName("txt_stay_time3")
	local pLayBtn3 = self:findViewByName("lay_btn3")
	self.pBtn3 = getCommonButtonOfContainer(pLayBtn3,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10035))
	self.pBtn3:onCommonBtnClicked(handler(self, self.onBtn3Clicked))
	self.pBtn3:setBtnExText({tLabel = {{"cost:"},{"0",getC3B(_cc.green)}}})

	--描述
	local pTxtTip1 = self:findViewByName("txt_tip1")
	pTxtTip1:setString(getTipsByIndex(10018))
	setTextCCColor(pTxtTip1, _cc.gray)
end

function CityDetailAttack:updateViews(  )
	if self.nMoveTime then
		--方式1时间到达时间后等待时间显示
		local tData = getWorldCityFightData(1)
		if tData then
			local nStayTime = nil
			if self.bIsMarchTimes then
				local tTimes = getWorldInitData("Crossregionalcountdown")
				nStayTime = tTimes[1]
			else
				for i=1,#tData.tRule do
					if tData.tRule[i].nStartTime <= self.nMoveTime and self.nMoveTime <= tData.tRule[i].nEndTime then
						nStayTime = tData.tRule[i].nStayTime + self.nMoveTime
						break
					end
				end
			end
						
			if nStayTime then
				local sMoveTime = formatTimeToMs(nStayTime)
				self.pTxtStayTime1:setString(getConvertedStr(3, 10037) .. sMoveTime)
				setTextCCColor(self.pTxtStayTime1, _cc.white)
				self.pBtn1:setBtnEnable(true)
				local tShortFigheData = Player:getCountryData():getShortFightData()
				if tShortFigheData == nil or tShortFigheData.nFree <= 0 then --没有免费次数
					local nId, nValue = getMulitCostResOnly(tData.cost)
					if nId and nValue then
						self.pBtn1:setExTextLbCnCr(1, string.format(getConvertedStr(3, 10356),getCostResName(nId)))
						local bIsEnough = getIsResourceEnough(nId, nValue)
						local sColor = _cc.red
						if bIsEnough then
							sColor = _cc.green
						end					
						self.pBtn1:setExTextLbCnCr(2, nValue, getC3B(sColor))
						self.pBtn1:setExTextLbCnCr(3,"")
						self.pBtn1:setExTextVisiable(true)
					end
				else
					self.pBtn1:setExTextLbCnCr(1, tShortFigheData.sName..getConvertedStr(1, 10181).." ", getC3B(_cc.pwhite))	
					self.pBtn1:setExTextLbCnCr(2, tShortFigheData.nFree, getC3B(_cc.green))	
					self.pBtn1:setExTextLbCnCr(3, "/"..tShortFigheData.nCnt, getC3B(_cc.pwhite))
					self.pBtn1:setExTextVisiable(true)
				end					
			else
				self.pTxtStayTime1:setString(getConvertedStr(3, 10128))
				setTextCCColor(self.pTxtStayTime1, _cc.red)

				self.pBtn1:setExTextLbCnCr(1,getConvertedStr(3, 10036), getC3B(_cc.red))
				self.pBtn1:setExTextLbCnCr(2,"")
				self.pBtn1:setExTextLbCnCr(3,"")
				self.pBtn1:setExTextVisiable(true)
				self.pBtn1:setBtnEnable(false)
			end

		end

		--方式2时间等待显示
		local tData = getWorldCityFightData(2)
		if tData then
			local nStayTime = nil
			if self.bIsMarchTimes then
				local tTimes = getWorldInitData("Crossregionalcountdown")
				nStayTime = tTimes[2]
			else
				for i=1,#tData.tRule do
					if tData.tRule[i].nStartTime <= self.nMoveTime and self.nMoveTime <= tData.tRule[i].nEndTime then
						nStayTime = tData.tRule[i].nStayTime + self.nMoveTime
						break
					end
				end
			end
			if nStayTime then
				local sMoveTime = formatTimeToMs(nStayTime)
				self.pTxtStayTime2:setString(getConvertedStr(3, 10037) .. sMoveTime)
				self.pBtn2:setBtnEnable(true)

				local nId, nValue = getMulitCostResOnly(tData.cost)
				if nId and nValue then
					self.pBtn2:setExTextLbCnCr(1, string.format(getConvertedStr(3, 10356),getCostResName(nId)))
					local bIsEnough = getIsResourceEnough(nId, nValue)
					local sColor = _cc.red
					if bIsEnough then
						sColor = _cc.green
					end
					self.pBtn2:setExTextLbCnCr(2, nValue, getC3B(sColor))
					self.pBtn2:setExTextVisiable(true)
				end
			else
				self.pTxtStayTime2:setString(getConvertedStr(3, 10128))
				setTextCCColor(self.pTxtStayTime2, _cc.red)

				self.pBtn2:setExTextLbCnCr(1,getConvertedStr(3, 10036), getC3B(_cc.red))
				self.pBtn2:setExTextLbCnCr(2,"")
				self.pBtn2:setExTextVisiable(true)
				self.pBtn2:setBtnEnable(false)
			end
		end

		--方式3时间等待显示
		local tData = getWorldCityFightData(3)
		if tData then
			local nStayTime = nil
			if self.bIsMarchTimes then
				local tTimes = getWorldInitData("Crossregionalcountdown")
				nStayTime = tTimes[3]
			else
				for i=1,#tData.tRule do
					if tData.tRule[i].nStartTime <= self.nMoveTime and self.nMoveTime <= tData.tRule[i].nEndTime then
						nStayTime = tData.tRule[i].nStayTime + self.nMoveTime
						break
					end
				end
				if nStayTime == nil then
					nStayTime = tData.tRule[#tData.tRule].nStayTime + self.nMoveTime
				end
			end
			
			if nStayTime then
				local sMoveTime = formatTimeToMs(nStayTime)
				self.pTxtStayTime3:setString(getConvertedStr(3, 10037) .. sMoveTime)
				self.pBtn3:setBtnEnable(true)

				local nId, nValue = getMulitCostResOnly(tData.cost)
				if nId and nValue then
					self.pBtn3:setExTextLbCnCr(1, string.format(getConvertedStr(3, 10356),getCostResName(nId)))
					local bIsEnough = getIsResourceEnough(nId, nValue)
					local sColor = _cc.red
					if bIsEnough then
						sColor = _cc.green
					end
					self.pBtn3:setExTextLbCnCr(2, nValue, getC3B(sColor))
					self.pBtn3:setExTextVisiable(true)
				end
			end
		end
	end
end

--tData:tViewDotMsg
function CityDetailAttack:setData( tData )
	if not tData then
		return
	end

	self.tData = tData
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	self.nBlockId = WorldFunc.getBlockId(self.tData.nX, self.tData.nY)
	
	--阿房宫时间
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	self.bIsMarchTimes = false
	if nMyBlockId ~= self.nBlockId then
		if nMyBlockId == nImperialCityMapId then
			self.bIsMarchTimes = true
		end
	end

	self:updateViews()
end

function CityDetailAttack:onBtn1Clicked( pView )
	self:openDlgBattleHero(e_wartype.short)
end

function CityDetailAttack:onBtn2Clicked( pView )
	self:openDlgBattleHero(e_wartype.merge)
end

function CityDetailAttack:onBtn3Clicked( pView )
	self:openDlgBattleHero(e_wartype.run)
end

--打开征战面板
--nWarType:战术
function CityDetailAttack:openDlgBattleHero( nWarType)
	local nNeedLv = getWorldInitData("castkeWarOpen")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10101), nNeedLv))
		return
	end
	
	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(self.tData.nX, self.tData.nY, e_war_type.city) then
		TOAST(getTipsByIndex(20032))
		return
	end

	--条件判断
	local tData = getWorldCityFightData(nWarType)
	if not tData then
		return
	end
	local bFree = false
	local nCostType = 0
	if nWarType == e_wartype.short then
		local tShortFigheData = Player:getCountryData():getShortFightData()
		if tShortFigheData == nil or tShortFigheData.nFree <= 0 then --没有免费次数
			bFree = false
		else
			bFree = true
			nCostType = 1 --有免费次数
		end			
	end
	if bFree == false then
		local nId, nValue = getMulitCostResOnly(tData.cost)
		if not checkIsResourceEnough(nId, nValue, false) then
			local pEnergy = Player:getBagInfo():getItemDataById(e_id_item.energy) 
			if pEnergy and pEnergy.nCt > 0 and Player:getBagInfo():isItemCanUse(e_id_item.energy) then
				showUseItemDlg(e_id_item.energy)
			else
				openDlgBuyEnergy()
			end		
			return
		end
		--城战消耗道具方式 0:正常消耗 1:特殊消耗
		if getMulitCostResTypeIsSpecial(nId, tData.cost) then
			nCostType = 1
		else
			nCostType = 0
		end
	end

	--发送请求
	local function sendReq()
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.battlehero, --dlg类型
		    nIndex = 1,--城战打开
		    tViewDotMsg = self.tData,
		    nWarType = nWarType,
		    nCostType = nCostType,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end

	--还有保护cd时间
	if WorldFunc.checkIsAttackCityInProtect(sendReq) then
		return
	else
		sendReq()
	end
end

return CityDetailAttack


