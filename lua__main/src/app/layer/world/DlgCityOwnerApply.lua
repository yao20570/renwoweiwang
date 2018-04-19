----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-25 15:13:34
-- Description: 系统城主申请界面
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgCityOwnerApply = class("DlgCityOwnerApply", function()
	return DlgCommon.new(e_dlg_index.cityownerapply, 755 - 60 - 130, 130)
end)

function DlgCityOwnerApply:ctor(  )
	parseView("dlg_city_owner_apply", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityOwnerApply:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10089))

	self:setupViews()
	self:onResume()
	

	--注册析构方法
	self:setDestroyHandler("DlgCityOwnerApply",handler(self, self.onDlgCityOwnerApplyDestroy))
end

-- 析构方法
function DlgCityOwnerApply:onDlgCityOwnerApplyDestroy(  )
    self:onPause()
end

function DlgCityOwnerApply:regMsgs(  )
	--注册资源刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
end

function DlgCityOwnerApply:unregMsgs(  )
	unregMsg(self, gud_refresh_playerinfo)
end

function DlgCityOwnerApply:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function DlgCityOwnerApply:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgCityOwnerApply:setupViews(  )
	self.pTxtContentTip1 = self:findViewByName("txt_content_tip1")
	local pTxtContentTip2 = self:findViewByName("txt_content_tip2")
	pTxtContentTip2:setString(getTextColorByConfigure(getTipsByIndex(20013)))

	self.pLayIcon = self:findViewByName("lay_icon")

	self.pLayBottom = self:findViewByName("lay_bottom")
	local pTxtBottomTip = self:findViewByName("txt_bottom_tip")
	pTxtBottomTip:setString(getConvertedStr(3, 10140))
	self.pTxtCd = self:findViewByName("txt_bottom_cd")
	setTextCCColor(self.pTxtCd, _cc.green)
	local pTxtBottomCdTip = self:findViewByName("txt_bottom_cd_tip")
	pTxtBottomCdTip:setString(getConvertedStr(3, 10141))

	local pTxtCostTitle = self:findViewByName("txt_cost_title")
	pTxtCostTitle:setString(getConvertedStr(3, 10142))
	self.pTxtCostTitle = pTxtCostTitle

	self.pLayBottom2 = self:findViewByName("lay_bottom2")
	local pTxtBottom2Tip = self:findViewByName("txt_bottom2_tip")
	setTextCCColor(pTxtBottom2Tip, _cc.red)
	pTxtBottom2Tip:setString(getConvertedStr(3, 10195))
	local pLayBtnApply = self:findViewByName("lay_btn_apply")
	local pBtnApply = getCommonButtonOfContainer(pLayBtnApply, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10088))
	pBtnApply:onCommonBtnClicked(handler(self, self.onApplyClicked))

	self.pCostUis = {}
	for i=1,2 do
		local pImgRes = self:findViewByName("img_res"..i)
		local pTxtRes = self:findViewByName("txt_res"..i)
		table.insert(self.pCostUis, {pImgRes = pImgRes, pTxtRes = pTxtRes})
	end
end

--消耗Ui集控件居中
function DlgCityOwnerApply:costUiCenterInView( )
	local nTotalWidth = 0
	nTotalWidth = nTotalWidth + self.pTxtCostTitle:getContentSize().width
	for i=1,#self.pCostUis do
		local pImgRes = self.pCostUis[i].pImgRes
		local pTxtRes = self.pCostUis[i].pTxtRes
		nTotalWidth = nTotalWidth + pImgRes:getContentSize().width
		nTotalWidth = nTotalWidth + pTxtRes:getContentSize().width + 30
	end
	local nX = (self.pLayBottom2:getContentSize().width - nTotalWidth)/2
	self.pTxtCostTitle:setPositionX(nX)
	nX = nX + self.pTxtCostTitle:getContentSize().width
	for i=1,#self.pCostUis do
		local pImgRes = self.pCostUis[i].pImgRes
		local pTxtRes = self.pCostUis[i].pTxtRes
		pImgRes:setPositionX(nX + pImgRes:getContentSize().width/2)
		nX = nX + pImgRes:getContentSize().width
		pTxtRes:setPositionX(nX + pTxtRes:getContentSize().width/2)
		nX = nX + pTxtRes:getContentSize().width + 30
	end
end

function DlgCityOwnerApply:updateViews(  )
	if not self.tCityData then
		return
	end

	--消耗
	local tCost = luaSplitMuilt(self.tCityData.cost,";",":")
	for i=1,#tCost do
		if type(tCost[i]) == "table" then
			local nId = tonumber(tCost[i][1])
			local nValue = tonumber(tCost[i][2])
			if nId and nValue then
				local pCostUis = self.pCostUis[i]
				if pCostUis then
					pCostUis.pImgRes:setCurrentImage(getCostResImg(nId))
					pCostUis.pTxtRes:setString(getResourcesStr(nValue), false)
					local sColor = _cc.pwhite
					if not getIsResourceEnough(nId, nValue) then
						sColor = _cc.red
					end
					setTextCCColor(pCostUis.pTxtRes, sColor)
				end
			end
		end
	end
	self:costUiCenterInView()

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if tViewDotMsg then
		--图标
		WorldFunc.getSysCityIconOfContainer(self.pLayIcon, self.nSysCityId, tViewDotMsg.nDotCountry, true)

		--城池名字
		local tStr = {
			{color = _cc.white, text = getConvertedStr(3, 10143)},
			{color = _cc.blue,  text = tViewDotMsg:getDotName()},
		}
		self.pTxtContentTip1:setString(tStr)
	end

	--更新cd
	self:updateCd()
end

function DlgCityOwnerApply:updateCd(  )
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--有战功者
	if tViewDotMsg.bIsAtkMerit then
		self.pLayBottom:setVisible(false)
		self.pLayBottom2:setVisible(true)
	else
		local nCd = tViewDotMsg:getCityOwnerApplyCd()
		if nCd > 0 then
			self.pLayBottom:setVisible(true)
			self.pLayBottom2:setVisible(false)
			self.pTxtCd:setString(formatTimeToHms(nCd))
		else
			self.pLayBottom:setVisible(false)
			self.pLayBottom2:setVisible(true)
		end
	end
end

--设置数据
--nSysCityId: 系统城池id
function DlgCityOwnerApply:setData( nSysCityId )
	self.nSysCityId = nSysCityId
	self.tCityData = getWorldCityDataById(nSysCityId)
	self:updateViews()
end

--点击申请回调
function DlgCityOwnerApply:onApplyClicked( pView )
	--是否满足级数
	local nNeedLv = getWorldInitData("leaderLvLimit")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10447), nNeedLv))
		return
	end
	
	if not self.tCityData then
		myprint("数据出错")
		return
	end

	--有城的情况下直接返回
	local bIsBe = Player:getCountryData():isPlayerBeCityMaster()
	if bIsBe then
		TOAST(getTipsByIndex(568))
		return
	end

	--判断是否已经申请中
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if tViewDotMsg and tViewDotMsg.bIsApplyCityOwner then
		--申请候选人命令
		SocketManager:sendMsg("reqWorldCityCandidate", {self.nSysCityId, 0})
		--关闭自己
		self:closeCommonDlg()
	else
		--判断资源是否充够
		if not checkIsResourceStrEnough(self.tCityData.cost, true) then
			return
		end
	
		--二次确认框
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		if(not pDlg) then
		    pDlg = DlgAlert.new(e_dlg_index.alert)
		end
		pDlg:setTitle(getConvertedStr(3, 10088))

	    --判断资源是否足够 --马爷
		local temp = luaSplit(self.tCityData.cost, ";") 
		local isenough = true
		local resstr = ""
		for k, v in pairs(temp) do
			local tt = luaSplit(v, ":")
			local id = tonumber(tt[1]) 		
			local cnt = tonumber(tt[2])
			local res = getGoodsByTidFromDB(id)
			if getMyGoodsCnt(id) < cnt then
				isenough = false
			end 
			if k == 1 then
				resstr = resstr..formatCountToStr(cnt)..res.sName
			else
				resstr = resstr..","..formatCountToStr(cnt)..res.sName
			end
		end
		local tStr = {
	    	{color=_cc.pwhite,text=getConvertedStr(6, 10101)},
		    {color=_cc.blue,text=resstr},
		    {color=_cc.pwhite,text=getConvertedStr(6, 10420)},
		}
		pDlg:setContent(tStr)
		
		pDlg:setRightHandler(function (  )
			--关闭窗口
			pDlg:closeAlertDlg()
			--申请城主
			SocketManager:sendMsg("reqWorldApplyCityOwner", {self.tCityData.tCoordinate.x, 
				self.tCityData.tCoordinate.y})
			--关闭自己
			self:closeCommonDlg()
		end)
		pDlg:showDlg(bNew)
	end
end


return DlgCityOwnerApply