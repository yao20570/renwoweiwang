----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 区域地图对话框
-----------------------------------------------------
local CallInfo = require("app.layer.world.data.CallInfo")
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgCallPlayer = class("DlgCallPlayer", function()
	return DlgCommon.new(e_dlg_index.callplayer)
end)

function DlgCallPlayer:ctor(  )
	parseView("dlg_world_call_player", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCallPlayer:onParseViewCallback( pView )
	self:addContentView(pView, true) --加入内容层

	self:setTitle(getConvertedStr(3, 10163))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCallPlayer",handler(self, self.onDlgCallPlayerDestroy))
end

-- 析构方法
function DlgCallPlayer:onDlgCallPlayerDestroy(  )
    self:onPause()
end

function DlgCallPlayer:regMsgs(  )
	--我的召唤信息更新
	regMsg(self, gud_world_my_callinfo_refresh, handler(self, self.refreshData))
	--商品购买更新
	regMsg(self, ghd_shop_buy_success_msg, handler(self, self.refreshData))
	--国家数据刷新消息
	regMsg(self, gud_refresh_country_msg, handler(self, self.refreshData))
	--免费召唤活动数据刷新
	regMsg(self, ghd_refresh_actfreecall_msg, handler(self, self.refreshData))	
end

function DlgCallPlayer:unregMsgs(  )
	--我的召唤信息更新
	unregMsg(self, gud_world_my_callinfo_refresh)
	--商品购买更新
	unregMsg(self, ghd_shop_buy_success_msg)
	--国家数据刷新消息
	unregMsg(self, gud_refresh_country_msg)	
	--免费召唤活动数据刷新
	unregMsg(self, ghd_refresh_actfreecall_msg)	
end

function DlgCallPlayer:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.udpateBottomLays))
	self:updateViews()
end

function DlgCallPlayer:onPause()
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgCallPlayer:setupViews(  )
	--
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pTxtCallMember = self:findViewByName("txt_call_member")
	self.pTxtCallNum = self:findViewByName("txt_call_num")
	local pTxtDesc = self:findViewByName("txt_desc")
	self.pTxtDesc = pTxtDesc
	
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbTip = self:findViewByName("lb_tip")
	if self.pLayContent then
		self.pLayContent:setZOrder(10)
	end
end

--更新视图点
function DlgCallPlayer:updateViews(  )
	--更新官职
	self:updateOfficer()

	--更新底部层信息
	self:udpateBottomLays()
end

--更新底部层信息
function DlgCallPlayer:udpateBottomLays( )
	if not self.nOfficer then
		return
	end
	local tTransportData = getNationTransport(self.nOfficer)
	if not tTransportData then
		return
	end

	--状态显示与隐藏
	local pAct = Player:getActById(e_id_activity.freecall)--活动数据
	--首次免费
	local nCalledNum = Player:getCountryData():getCalledNumToday()
	local bIsFree = nCalledNum == 0

	--容错
	if not self.tViewDotMsg then
		return
	end
	--有召唤信息
	local tCallInfo = self.tViewDotMsg:getCallInfo()
	if tCallInfo and tCallInfo:getReCallCd() > 0 then
		--有效时间中						
		local nReCallCd = tCallInfo:getReCallCd()
		local sStr = {
			{text=getConvertedStr(3, 10167),color=_cc.white},
			{text=tostring(tCallInfo.nResponse),color=_cc.green},
			{text="/".. tostring(tTransportData.num),color=_cc.white},
			{text="    ",color=_cc.white},
			{text=formatTimeToMs(nReCallCd),color=_cc.red},
			{text=getConvertedStr(3, 10168),color=_cc.white},				
		}
		self.pLbTip:setString(sStr, false)

		--重发cd时间中
		local nCd = tCallInfo:getReCallMsgCd()
		if nCd > 0 then
			local pReCallBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10170)..string.format("(%s)", nCd))
			pReCallBtn:setBtnEnable(false)
		else
			local pReCallBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10170))
			pReCallBtn:onCommonBtnClicked(handler(self, self.onBtnRecallClicked))
			pReCallBtn:setBtnEnable(true)							
		end
		return
	else
		if (tTransportData.isfree == 0 and bIsFree) then--首次免费
			--首次免费
			self.pLbTip:setString(getConvertedStr(6, 10635))
			local pFreeBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10169))
			pFreeBtn:onCommonBtnClicked(handler(self, self.onBtnFreeClicked))
			--停止计时器
			unregUpdateControl(self)
			return
		elseif pAct and pAct:getActFreeCallTimes() > 0 and nCalledNum == 1 then--活动免费
			--活动免费
			local sStr = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10636)},
				{color=_cc.green, text=tostring(pAct.nFct)},
				{color=_cc.pwhite, text="/"..tostring(pAct.nTct)},
			}
			self.pLbTip:setString(sStr, false)
			local pFreeBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10169))
			pFreeBtn:onCommonBtnClicked(handler(self, self.onBtnFreeClicked))
			--停止计时器
			unregUpdateControl(self)
			return			
		else--非免费
			--召唤
			if self.nGoodsId then
				--当前数量
				local nCurrNum = getMyGoodsCnt(self.nGoodsId)
				local sColor = _cc.green
				if nCurrNum < self.nNeedNum then
					sColor = _cc.red
				end
				local sStr = {
					{color=_cc.pwhite, text=getConvertedStr(3, 10166)},
					{color=sColor, text=tostring(self.nNeedNum)},
					{color=_cc.white, text="/"..tostring(nCurrNum)},
				}
				self.pLbTip:setString(sStr, false)	
			end		
			local pBtnCall = self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10163))
			pBtnCall:onCommonBtnClicked(handler(self, self.onBtnCallClicked))
			--停止计时器
			unregUpdateControl(self)
			return
		end		
	end
end

--更新官职
function DlgCallPlayer:updateOfficer(  )
	--容错
	if not self.nOfficer then
		return
	end
	local tTransportData = getNationTransport(self.nOfficer)
	if not tTransportData then
		return
	end

	local sStr = string.format(getTipsByIndex(10049), math.ceil(tTransportData.countdown/60), tonumber(getCountryParam("summonMinLv")))
	local tStr = getTextColorByConfigure(sStr)
	self.pTxtDesc:setString(tStr)

	--官职
	local tStr = {
		{color = _cc.pwhite, text = getConvertedStr(3, 10199)},
		{color = _cc.blue, text = tostring(tTransportData.name)},
	}
	self.pTxtTitle:setString(tStr)

	--可召唤人数
	local tStr = {
		{color=_cc.pwhite,text=getConvertedStr(3, 10200)},
		{color=_cc.blue,text=tostring(tTransportData.num)},
	}
	self.pTxtCallMember:setString(tStr)

	local nActCallNum = 0 --已经使用的活动召唤次数
	local nActFree = 0 --活动免费召唤总次数

	--今天召唤次数
	local nCalledNum = Player:getCountryData():getCalledNumToday()
	local nOfficialNum = tonumber(tTransportData.times) --官员的免费次数
	local pAct = Player:getActById(e_id_activity.freecall)--活动数据
	local tStr = nil
	if pAct then
		nActCallNum = pAct.nFct
		nActFree = pAct.nTct
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10201)},
			{color=_cc.blue,text=tostring(nCalledNum + nActCallNum)},
			{color=_cc.pwhite,text="/"..tostring(nOfficialNum + nActFree)},
			{color=_cc.green,text=string.format(getConvertedStr(6, 10634), nActFree)},
		}
	else
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10201)},
			{color=_cc.blue,text=tostring(nCalledNum)},
			{color=_cc.pwhite,text="/"..tostring(nOfficialNum)},
		}
	end
	if tStr then
		self.pTxtCallNum:setString(tStr)
	end
	self.nGoodsId = nil --道具
	self.nNeedNum = 0 --需要消耗的数据
	local tCost = luaSplit(tTransportData.cost, ":")
	local nGoodsId = tonumber(tCost[1])
	local nNeedGoods = tonumber(tCost[2])
	if nNeedGoods and nGoodsId then
		local tGoods = getGoodsByTidFromDB(nGoodsId)
		if tGoods then
			getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods, TypeIconGoodsSize.L)
		end
		-- self.pBtnCall:setExTextLbCnCr(2, nNeedGoods, getC3B(sColor))
		-- self.pBtnCall:setExTextLbCnCr(3, "/"..tostring(nCurrNum))
		--记录消耗所需
		self.nGoodsId = nGoodsId
		self.nNeedNum = nNeedGoods
	end
	
end

--刷新数据
function DlgCallPlayer:refreshData(  )
	--获取自己的官职
	self.nOfficer = Player:getCountryData():getCountryDataVo().nOfficial
	self.tViewDotMsg = Player:getWorldData():getMyViewDotMsg()
	regUpdateControl(self, handler(self, self.udpateBottomLays))
	self:updateViews()
end

--还存在有效的召唤
function DlgCallPlayer:checkIsHasEffect( )
	--还存在有效的召唤
	if self.tViewDotMsg then
		local tCallInfo = self.tViewDotMsg:getCallInfo()
		if tCallInfo then
			if tCallInfo:getReCallCd() > 0 then
				TOAST(getTipsByIndex(588))
				return true
			end
		end
	end
	return false
end


--免费按钮
function DlgCallPlayer:onBtnFreeClicked( pView )
	--还存在有效的召唤
	if self:checkIsHasEffect() then
		return
	end
	
	SocketManager:sendMsg("reqWorldReqCall", {})
	--关闭
	closeDlgByType(e_dlg_index.callplayer, false)
end

--发送按钮
function DlgCallPlayer:onBtnCallClicked( pView )
	--还存在有效的召唤
	if self:checkIsHasEffect() then
		return
	end

	--容错
	if not self.nOfficer then
		return
	end
	local tTransportData = getNationTransport(self.nOfficer)
	if not tTransportData then
		return
	end

	--是否满足召唤次数
	local nCalledNum = Player:getCountryData():getCalledNumToday()
	if nCalledNum < tTransportData.times then
		local tGoods = getGoodsByTidFromDB(self.nGoodsId)
		if not tGoods then
			return
		end
		--对框话弹出
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    local tStr = {
	    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
	    	{color = _cc.blue, text = string.format("%s*%s", tGoods.sName,self.nNeedNum)},
	    	{color = _cc.pwhite, text = getConvertedStr(3, 10403)},
		}
	    pDlg:setContent(tStr)
	    pDlg:setRightHandler(function (  )
			local nCurrNum = getMyGoodsCnt(self.nGoodsId)
			local nNeedBuyNum = self.nNeedNum - nCurrNum
	    	--如果需求买的数量大于0,弹出商场购买流程
	    	if nNeedBuyNum > 0 then
	    		--如批量购买面板
	    		local data = getShopDataById(self.nGoodsId)	
				if not data then
					TOAST(getConvertedStr(6, 10438))
					return 
				end					
				local tObject = {
				    nType = e_dlg_index.shopbatchbuy, --dlg类型
				    tShopBase = data,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
	    	else
	    		SocketManager:sendMsg("reqWorldReqCall", {})
	    		--关闭
				closeDlgByType(e_dlg_index.callplayer, false)
	    	end
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	else
		TOAST(getConvertedStr(3, 10203))
	end
end

--重发按钮
function DlgCallPlayer:onBtnRecallClicked( pView )
	if not self.tViewDotMsg then
		return
	end
	local tCallInfo = self.tViewDotMsg:getCallInfo()
	if not tCallInfo then
		return
	end
	if tCallInfo:getReCallMsgCd() <= 0 then
		SocketManager:sendMsg("reqWorldReqCallNotice", {})
		--关闭
		closeDlgByType(e_dlg_index.callplayer, false)
	else
		TOAST(getConvertedStr(3, 10202))
	end
end

return DlgCallPlayer