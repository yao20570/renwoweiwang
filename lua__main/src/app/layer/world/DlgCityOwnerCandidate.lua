----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-03 16:28:09
-- Description: 系统城主候选人界面
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemCityOwnerCandidate = require("app.layer.world.ItemCityOwnerCandidate")
local ListViewFooter = require("app.layer.world.ListViewFooter")

local DlgCityOwnerCandidate = class("DlgCityOwnerCandidate", function()
	return DlgCommon.new(e_dlg_index.cityownercandidate,565,130)
end)

function DlgCityOwnerCandidate:ctor(  )
	parseView("dlg_city_owner_candidate", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityOwnerCandidate:onParseViewCallback( pView )


	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(9, 10189))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityOwnerCandidate",handler(self, self.onDlgCityOwnerCandidateDestroy))
end

-- 析构方法
function DlgCityOwnerCandidate:onDlgCityOwnerCandidateDestroy(  )
    self:onPause()
end

function DlgCityOwnerCandidate:regMsgs(  )
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
end

function DlgCityOwnerCandidate:unregMsgs(  )
	unregMsg(self, gud_world_dot_change_msg)
end

function DlgCityOwnerCandidate:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function DlgCityOwnerCandidate:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgCityOwnerCandidate:setupViews(  )
	self.pTxtNoTip = self:findViewByName("txt_no_tip")
	self.pTxtNoTip:setString(getConvertedStr(9,10188))
	setTextCCColor(self.pTxtNoTip, _cc.pwhite)
	self.pTxtNoTip:setVisible(false)

	self.pTxtContentTip1 = self:findViewByName("txt_content_tip1")
	local pTxtBannerTip = self:findViewByName("txt_banner_tip")
	pTxtBannerTip:setString(getConvertedStr(3, 10145))
	-- local pTxtContentTip2 = self:findViewByName("txt_content_tip2")
	self.pTxtContentTip1:setString(getTextColorByConfigure(getTipsByIndex(20013)))

	self.pTxtCd = self:findViewByName("txt_cd")
	local pTxtCostTitle = self:findViewByName("txt_cost_title")
	pTxtCostTitle:setString(getConvertedStr(3, 10142))
	self.pTxtCostTitle = pTxtCostTitle
	self.pCostUis = {}
	for i=1,2 do
		local pImgRes = self:findViewByName("img_res"..i)
		local pTxtRes = self:findViewByName("txt_res"..i)
		table.insert(self.pCostUis, {pImgRes = pImgRes, pTxtRes = pTxtRes})
	end

	local pTxtTip2 = self:findViewByName("txt_tip2")
	setTextCCColor(pTxtTip2, _cc.red)
	pTxtTip2:setString(getConvertedStr(3, 10195))

	self.pTxtTip3 = self:findViewByName("txt_tip3")
	setTextCCColor(self.pTxtTip3, _cc.red)
	self.pTxtTip3:setString(getConvertedStr(9, 10187))
	self.pTxtTip3:setVisible(false)

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn ,TypeCommonBtn.L_BLUE,getConvertedStr(9,10189))
	self.pBtn:onCommonBtnClicked(handler(self, self.onClickCandidate))

	--列表
	local pLayContent = self:findViewByName("lay_candidate")
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayContent:getContentSize().width, pLayContent:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    self.pListView:setItemCallback(function ( _index, _pView ) 
		local pItemData = self.tElectorList[_index]
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemCityOwnerCandidate.new()
		end
		pTempView:setData(pItemData)
	    return pTempView
	end)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
    pLayContent:addView(self.pListView)
    centerInView(pLayContent, self.pListView )
end

--消耗Ui集控件居中
function DlgCityOwnerCandidate:costUiCenterInView( )
	local nTotalWidth = 0
	nTotalWidth = nTotalWidth + self.pTxtCostTitle:getContentSize().width
	for i=1,#self.pCostUis do
		local pImgRes = self.pCostUis[i].pImgRes
		local pTxtRes = self.pCostUis[i].pTxtRes
		nTotalWidth = nTotalWidth + pImgRes:getContentSize().width
		nTotalWidth = nTotalWidth + pTxtRes:getContentSize().width + 30
	end
	local nX = (550 - nTotalWidth)/2
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

function DlgCityOwnerCandidate:updateViews(  )
	if not self.tCityData then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local nCd = tViewDotMsg:getCityOwnerApplyCd()
	--有战功者
	if tViewDotMsg.bIsAtkMerit then
		--判断是否已经申请中
		if tViewDotMsg.bIsApplyCityOwner then
			self.pBtn:updateBtnText(getConvertedStr(9,10190))
			self.pBtn:setBtnEnable(false)
		else
			self.pBtn:updateBtnText(getConvertedStr(9,10189))
			self.pBtn:setBtnEnable(true)
		end
		self.pTxtTip3:setVisible(false)

		if nCd > 0 then
			self.pTxtCd:setVisible(true)
		else
			self.pTxtCd:setVisible(false)

		end

	else
		if nCd > 0 then
			self.pBtn:updateBtnText(getConvertedStr(9,10191))
			self.pBtn:setBtnEnable(false)
			self.pTxtTip3:setVisible(true)
			self.pTxtCd:setVisible(true)
		else
			self.pBtn:updateBtnText(getConvertedStr(9,10189))
			self.pBtn:setBtnEnable(true)

			self.pTxtTip3:setVisible(false)
			self.pTxtCd:setVisible(false)

		end
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
				end
			end
		end
	end
	self:costUiCenterInView()

	-- --城池名字
	-- local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	-- if tViewDotMsg then
	-- 	local tStr = {
	-- 		{color = _cc.white, text = getConvertedStr(3, 10143)},
	-- 		{color = _cc.blue,  text = tViewDotMsg:getDotName()},
	-- 	}
	-- 	self.pTxtContentTip1:setString(tStr)
	-- end

	--cd时间
	self:updateCd()
end

--cd倒计时
function DlgCityOwnerCandidate:updateCd( )
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	local nCd = tViewDotMsg:getCityOwnerApplyCd()
	local tStr = {
		{color = _cc.green, text = formatTimeToHms(nCd)},
		{color = _cc.pwhite,  text = getConvertedStr(3, 10382)},
	}
	--无战功者
	if not tViewDotMsg.bIsAtkMerit then
		tStr[2].text=getConvertedStr(9,10192)
	end
	
	self.pTxtCd:setString(tStr)
	if nCd <= 0 then
		unregUpdateControl(self)
	end
end

--设置数据
--nSysCityId: 系统城池id
--__msg: 3024协议第一次返回的数据
function DlgCityOwnerCandidate:setData( nSysCityId, __msg)
	self.nSysCityId = nSysCityId
	self.tCityData = getWorldCityDataById(nSysCityId)
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg and self.tCityData then
		SocketManager:sendMsg("reqSingalSysCityDot", {self.tCityData.tCoordinate.x,self.tCityData.tCoordinate.y},function ( )
			-- body
			self:updateViews()

		end)
	else
		self:updateViews()
	end
	
	self:onResume()

	--请求候选人列表
	self.nCurrPage 		= 0
	self.nPageCount 	= 0
	self.nPageCountMax 	= 0
	self.nItemCountMax 	= 0
	self.tElectorList = {}
	self:onReqWorldCityCandidate(__msg)
end

--请求数据
function DlgCityOwnerCandidate:reqWorldCityCandidate( )
	if #self.tElectorList < self.nItemCountMax then
		SocketManager:sendMsg("reqWorldCityCandidate", {self.nSysCityId,#self.tElectorList}, handler(self, self.onReqWorldCityCandidate))
	end
end

function DlgCityOwnerCandidate:onReqWorldCityCandidate( __msg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqWorldCityCandidate.id then
			--转城自己的数据
			local pMsgObj = {
				nCurrPage 		= __msg.body.c ,--Integer	当前页码
				nPageCount 		= __msg.body.ps, --Integer	每页大小
				nPageCountMax 	= __msg.body.a ,--Integer	总页数
				nItemCountMax 	= __msg.body.t ,--	Integer	总条数
				tElectorList 	= Player:getWorldData():createElectorList(__msg.body.r), --List<Elector>	结果
			}
			--容错
			if not pMsgObj.tElectorList then
				return
			end
			--之前的数量
			local nPrevCount = #self.tElectorList
			--新的数量
			self.nCurrPage 		= pMsgObj.nCurrPage
			self.nPageCount 	= pMsgObj.nPageCount
			self.nPageCountMax 	= pMsgObj.nPageCountMax
			self.nItemCountMax 	= pMsgObj.nItemCountMax
			for i=1,#pMsgObj.tElectorList do
				table.insert(self.tElectorList,pMsgObj.tElectorList[i])
			end

			--列表数据
			if nPrevCount ~= #self.tElectorList then
				self.pListView:removeAllItems()
			    self.pListView:setItemCount(#self.tElectorList)
				self.pListView:reload()
			else
				self.pListView:notifyDataSetChange(true)
			end

			--移到最下面
			if self.nCurrPage > 1 then
				self.pListView:scrollToEnd()
			end

			--是否显示下一页点击
			if #self.tElectorList < self.nItemCountMax then
				if self.pFooterView then
					self.pListView:removeFooterView()
					self.pFooterView = nil
				end
			else
				if not self.pFooterView then
					self.pFooterView = ListViewFooter.new()
					self.pListView:addFooterView(self.pFooterView)
					self.pFooterView:setViewTouched(true)
					self.pFooterView:setIsPressedNeedScale(false)
					self.pFooterView:onMViewClicked(handler(self, self.reqWorldCityCandidate))
				end
			end
			if #self.tElectorList <=0 then
				self.pTxtNoTip:setVisible(true)
			else
				self.pTxtNoTip:setVisible(false)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--监听数据发生改变
function DlgCityOwnerCandidate:onDotChange( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.nSysCityId then
			if tViewDotMsg:getIsSysCityHasOwner() then
				--打开城池详情
				local tObject = {
				    nType = e_dlg_index.syscitydetail, --dlg类型
				    nSystemCityId = tViewDotMsg.nSystemCityId,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)

				--关闭自己
				self:closeDlg(false)
			end
		end
	end
end

function DlgCityOwnerCandidate:onClickCandidate(  )
	-- body
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
		-- --申请候选人命令
		-- SocketManager:sendMsg("reqWorldCityCandidate", {self.nSysCityId, 0})
		-- --关闭自己
		-- self:closeCommonDlg()
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

return DlgCityOwnerCandidate