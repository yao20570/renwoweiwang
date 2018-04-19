----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 城战支援面板
-----------------------------------------------------
-- 城战支援面板
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgCityWarSendHelp = class("DlgCityWarSendHelp", function()
	return DlgCommon.new(e_dlg_index.citywarhelp)
end)

function DlgCityWarSendHelp:ctor( _nWarType )
	self.nWarType=_nWarType or 1
	parseView("dlg_city_war_send_help", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityWarSendHelp:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10043))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityWarSendHelp",handler(self, self.onDlgCityWarSendHelpDestroy))
end

-- 析构方法
function DlgCityWarSendHelp:onDlgCityWarSendHelpDestroy(  )
    self:onPause()
end

function DlgCityWarSendHelp:regMsgs(  )
end

function DlgCityWarSendHelp:unregMsgs(  )
end

function DlgCityWarSendHelp:onResume(  )
	self:regMsgs()
end

function DlgCityWarSendHelp:onPause(  )
	self:unregMsgs()
end

function DlgCityWarSendHelp:setupViews(  )
	local pTxtTip = self:findViewByName("txt_tip")
	pTxtTip:setString(getConvertedStr(3, 10189))
	self.pLayRichtextContent = self:findViewByName("lay_richtext_content")

	local pLayBtnSupport = self:findViewByName("lay_btn_send")
	self.pBtnSupport = getCommonButtonOfContainer(pLayBtnSupport,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10043))
	self.pBtnSupport:onCommonBtnClicked(handler(self, self.onSupportClicked))
	if self.nWarType == 1 then
		self.nMaxHelp = getWorldInitData("helpMaxLimit")
	elseif self.nWarType==2 then
		self.nMaxHelp = getWorldInitData("countryHelpLimit")
	elseif self.nWarType == 3 then
		self.nMaxHelp = getGhostInitData("sosTime")
	end
	local tLabel = {
	 {getConvertedStr(3, 10130)},
	 {"0", getC3B(_cc.green)},
	 {"/"..self.nMaxHelp}
	}
	self.pBtnSupport:setBtnExText({tLabel = tLabel})
end

function DlgCityWarSendHelp:updateViews(  )
	if not self.tViewDotMsg or not self.tCityWarMsg then
		return
	end

	if self.nWarType ==1 then

		--如果被打者是自己就
		local sColor = getColorByCountry(self.tViewDotMsg.nDotCountry)	
		if self.tViewDotMsg:getIsMe() then
			local tStr = {
				{color=sColor,text=string.format("[%s]", getCountryShortName(self.tCityWarMsg.nSenderCountry))},
				{color=_cc.blue,text=string.format("%s %s", self.tCityWarMsg.sSenderName, getLvString(self.tCityWarMsg.nSenderCityLv))},
				{color=_cc.green,text=string.format("[%s]", getWorldPosString(self.tCityWarMsg.nSenderX, self.tCityWarMsg.nSenderY))},
				{color=_cc.pwhite,text=getConvertedStr(3, 10401)},
			}
			getRichLabelOfContainer(self.pLayRichtextContent, tStr, nil, self.pLayRichtextContent:getContentSize().width)--只执行一次就行
		else
			local tStr = {
				{color=_cc.white,text= getConvertedStr(3, 10190)},
				{color=sColor,text=string.format("[%s]", getCountryShortName(self.tViewDotMsg.nDotCountry))},
				{color=_cc.blue,text=string.format("%s %s", self.tViewDotMsg.sName, getLvString(self.tViewDotMsg.nLevel))},
				{color=_cc.green,text=string.format("[%s]", getWorldPosString(self.tViewDotMsg.nX, self.tViewDotMsg.nY))},
				{color=_cc.pwhite,text=getConvertedStr(3, 10191)},
			}
			getRichLabelOfContainer(self.pLayRichtextContent, tStr, nil, self.pLayRichtextContent:getContentSize().width)--只执行一次就行
		end
	elseif self.nWarType == 2 then
		local sColor = getColorByCountry(self.tCityWarMsg.nDefCountry)	
		local tStr = {
				{color=_cc.white,text= getConvertedStr(3, 10190)},
				{color=sColor,text=string.format("[%s]", getCountryShortName(self.tCityWarMsg.nDefCountry))},
				{color=_cc.blue,text=string.format("%s", self.tViewDotMsg.sDotName)},
				{color=_cc.green,text=string.format("[%s]", getWorldPosString(self.tViewDotMsg.nX, self.tViewDotMsg.nY))},
				{color=_cc.pwhite,text=getConvertedStr(9, 10037)},
			}
		getRichLabelOfContainer(self.pLayRichtextContent, tStr, nil, self.pLayRichtextContent:getContentSize().width)--只执行一次就行
	elseif self.nWarType == 3 then   --冥界入侵
		local tStr = {
				{color=_cc.white,text= getConvertedStr(9, 10178)},
				{color=_cc.red,text=string.format(getConvertedStr(9,10179),self.tCityWarMsg.sSenderName,self.tCityWarMsg.nSeq,self.tCityWarMsg.nBossLv)},
				{color=_cc.white,text=getConvertedStr(9, 10180)},
			}
		getRichLabelOfContainer(self.pLayRichtextContent, tStr, nil, self.pLayRichtextContent:getContentSize().width)--只执行一次就行
	end

	--可支持次数
	local nCanSupportTimes = math.max(self.nMaxHelp - self.tCityWarMsg.nSupport, 0)
	self.nCanSupportTimes = nCanSupportTimes
	if nCanSupportTimes > 0 then
		self.pBtnSupport:setExTextLbCnCr(2, nCanSupportTimes, getC3B(_cc.green))
		self.pBtnSupport:setToGray(false)
	else
		self.pBtnSupport:setExTextLbCnCr(2, nCanSupportTimes, getC3B(_cc.red))
		self.pBtnSupport:setToGray(true)
	end

end

function DlgCityWarSendHelp:setData( tViewDotMsg, tCityWarMsg)
	self.tViewDotMsg = tViewDotMsg
	self.tCityWarMsg = tCityWarMsg
	self:updateViews()
end

function DlgCityWarSendHelp:onSupportClicked( pView )
	if self.nCanSupportTimes <= 0 then
		TOAST(getConvertedStr(3, 10378))
		return
	end
	if self.nWarType == 1 then  --城战求援
		-- dump({self.tViewDotMsg.nCityId, self.tCityWarMsg.sWarId})
		SocketManager:sendMsg("reqCityWarSupport", {self.tViewDotMsg.nCityId, self.tCityWarMsg.sWarId ,self.tViewDotMsg,self.tCityWarMsg},handler(self, self.onSupportCallback))
	elseif self.nWarType==2 then  		--国战求援
		SocketManager:sendMsg("reqCountryWarSupport", {self.tCityWarMsg.nId, self.tCityWarMsg.nAtkCountry,self.tViewDotMsg,self.tCityWarMsg},handler(self, self.onCountryWarSupportCallback))
	elseif self.nWarType == 3 then  --冥界求援
		SocketManager:sendMsg("reqGhostdomWarSupport", {self.tViewDotMsg,self.tCityWarMsg},handler(self, self.onGhostWarSupportCallback))

	end
	
end

function DlgCityWarSendHelp:onSupportCallback(__msg, __oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqCityWarSupport.id then


			local sWarId = __oldMsg[2]--更新次数
			sendMsg(ghd_world_city_war_support_used, sWarId)

			-- TOAST(getTipsByIndex(10076))
		end
	else
	    TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
	self:closeDlg(false)
end
function DlgCityWarSendHelp:onCountryWarSupportCallback(__msg, __oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqCountryWarSupport.id then


			local nCityId = __oldMsg[1]--更新次数
			sendMsg(ghd_world_country_war_support_used, nCityId)

			-- TOAST(getTipsByIndex(10076))
		end
	else
	    TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
	self:closeDlg(false)
end
function DlgCityWarSendHelp:onGhostWarSupportCallback(__msg, __oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
			local tObject ={gid=__oldMsg[2].sGid}
			sendMsg(ghd_world_city_war_support_used,tObject)
			sendMsg(ghd_ghost_war_support_used)

			-- TOAST(getTipsByIndex(10076))
	else
	    TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
	self:closeDlg(false)
end
return DlgCityWarSendHelp