----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:20:15
-- Description: 邮件详细基类
-----------------------------------------------------
local MailFunc = require("app.layer.mail.MailFunc")

local MCommonView = require("app.common.MCommonView")
-- 城战邮件详细
local DlgBase = require("app.common.dialog.DlgBase")
local DlgMailDetail = class("DlgMailDetail", function()
	return DlgBase.new()
end)

--tMailMsg 邮件数据
function DlgMailDetail:ctor( tMailMsg, pMsgObj )
	self.tMailMsg = tMailMsg
	self.bCanClick = true
	if pMsgObj then
		self.bShare = pMsgObj.bShare
	end

	--标题
	if self.tMailMsg.nCategory == e_type_mail.system then
		if self.tMailMsg.nId == nil or self.tMailMsg.nId == 0 then --znftodo以后优化
			self:setTitle(self.tMailMsg.sTitle)
		else
			local tMailSystem = getMailDataById(self.tMailMsg.nId)
			if tMailSystem then
				self:setTitle(tMailSystem.sendname)
			end
		end
		self:setTitleColor(_cc.blue)
	else
		local tMailReport = getMailReport(self.tMailMsg.nId)
		if tMailReport then
			self:setTitle(tMailReport.sTitle)
			self:setTitleColor(tMailReport.sColor)
		end
	end

	--单个邮件已读请求
	if not self.tMailMsg.bIsReaded then
		SocketManager:sendMsg("reqMailReaded", {self.tMailMsg.nCategory, self.tMailMsg.sPid})
	end
end

function DlgMailDetail:regMsgs(  )
	regMsg(self, gud_mail_save_success_msg, handler(self, self.onMailSaveSuccess))
	regMsg(self, gud_mail_save_cancel_success_msg, handler(self, self.onMailSaveCancelSuccess))
	regMsg(self, gud_mail_get_succeess_msg, handler(self, self.updateGetBtn))
	-- print("DlgMailDetail:regMsgs")
end

function DlgMailDetail:unregMsgs(  )
	unregMsg(self, gud_mail_save_success_msg)
	unregMsg(self, gud_mail_save_cancel_success_msg)
	unregMsg(self, gud_mail_get_succeess_msg)
	-- print("DlgMailDetail:unregMsgs")
end

--设置图标
function DlgMailDetail:setIcon( pLayIcon, bIsFixScale )
	if not pLayIcon then
		return
	end
	local sImgPath = MailFunc.getMailDetailIcon(self.tMailMsg)
	if sImgPath then
		if not self.pIcon then
			self.pIcon = MUI.MImage.new(sImgPath)
			pLayIcon:addView(self.pIcon)
			centerInView(pLayIcon, self.pIcon)
		else
			self.pIcon:setCurrentImage(sImgPath)
		end
		if bIsFixScale then
			WorldFunc.fixScaleToContent(pLayIcon, self.pIcon)
		else
			self.pIcon:setScale(1)
		end
	end
end

--设置分享按钮
function DlgMailDetail:setShareBtn( pLayBtnShare )
	if self.bShare then
		return
	end
	self.pBtnShare = getCommonButtonOfContainer(pLayBtnShare, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10003),false)
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(pLayBtnShare, self.pBtnShare, 0.9)
end

--设置保存按钮
function DlgMailDetail:setSaveBtn( pLayBtnSave )
	if self.bShare then
		return
	end
	self.pBtnSave = getCommonButtonOfContainer(pLayBtnSave, TypeCommonBtn.L_BLUE,nil,false)
	setMCommonBtnScale(pLayBtnSave, self.pBtnSave, 0.9)
	self.pBtnSave:onCommonBtnClicked(handler(self, self.onSaveClicked))
	self:updateSaveBtn()
end

--设置删除按钮
function DlgMailDetail:setDelBtn( pLayBtnDel )
	if self.bShare then
		return
	end
	local pBtnDel = getCommonButtonOfContainer(pLayBtnDel, TypeCommonBtn.L_RED, getConvertedStr(3, 10161))
	pBtnDel:onCommonBtnClicked(handler(self, self.onDelClicked))
	setMCommonBtnScale(pLayBtnDel, pBtnDel, 0.9)
end

--设置战报回放按钮
function DlgMailDetail:setReplayBtn( pLayBtnReplay )
	self.pBtnReplay = getCommonButtonOfContainer(pLayBtnReplay, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10240))
	self.pBtnReplay:onCommonBtnClicked(handler(self, self.onReplayClicked))
	setMCommonBtnScale(pLayBtnReplay, self.pBtnReplay, 0.9)
	--如果是从分享打开的话战报按妞居中
	if self.bShare then
		pLayBtnReplay:setPositionX((self:getWidth() - pLayBtnReplay:getWidth())/2)
	end
end


--设置查找按钮
function DlgMailDetail:setFindBtn( pLayFind ,bIsDetect, _sBtnStr)
	--从分享打开的不显示
	if self.bShare and not bIsDetect then
		return
	end
	local sBtnStr = getConvertedStr(9, 10020) --查找
	local tMailReport = getMailReport(self.tMailMsg.nId)
	if tMailReport.counterattack and tMailReport.counterattack == 1 then
		sBtnStr = getConvertedStr(7, 10300)  --反击
	end
	if _sBtnStr then
		sBtnStr = _sBtnStr
	end
	local pBtnFind = getCommonButtonOfContainer(pLayFind, TypeCommonBtn.L_BLUE, sBtnStr)
	pBtnFind:onCommonBtnClicked(handler(self, self.onFindClicked))
	setMCommonBtnScale(pLayFind, pBtnFind, 0.9)
end

--设置私聊按钮
function DlgMailDetail:setPrivateChatBtn( pLayPrivateChat )
	--从分享打开的不显示
	if self.bShare then
		return
	end
	local pBtnPrivateChat = getCommonButtonOfContainer(pLayPrivateChat, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10008))
	pBtnPrivateChat:onCommonBtnClicked(handler(self, self.onPrivateChatClicked))
	setMCommonBtnScale(pLayPrivateChat, pBtnPrivateChat, 0.9)
end

--设置领取
function DlgMailDetail:setGetBtn( pLayBtnGet )
	if self.bShare then
		return
	end
	self.pBtnGet = getCommonButtonOfContainer(pLayBtnGet, TypeCommonBtn.L_YELLOW)
	local tLabel = {
	 	{getConvertedStr(3, 10214), getC3B(_cc.white)}
	 }
	self.pBtnGet:setBtnExText({tLabel = tLabel})
	setMCommonBtnScale(pLayBtnGet, self.pBtnGet, 1)
	self:updateGetBtn()
end

--点击分享回调
function DlgMailDetail:onShareClicked( pView)
	local tMailReport = getMailReport(self.tMailMsg.nId)
	local tShareData=getChatCommonNotice(tMailReport.shareid)
	local _, sTable = MailFunc.analysisMailMsg( self.tMailMsg ,tShareData.noticecontent or nil)
	
	openShare(pView, tMailReport.shareid, sTable,self.tMailMsg.sPid,self.tMailMsg.nCategory)

end

--点击删除回调
function DlgMailDetail:onDelClicked( pView )
	if not self.tMailMsg then
		return
	end
	SocketManager:sendMsg("reqMailDel", {self.tMailMsg.nCategory, self.tMailMsg.sPid})
	self:closeDlg(false)
end

--点击重新播放回调
function DlgMailDetail:onReplayClicked( pView )
	if not self.tMailMsg then
		return
	end
	SocketManager:sendMsg("reqMailFightReplay", {self.tMailMsg.sFightRid})
end

--点击领取回调
function DlgMailDetail:onGetClicked( pView )
	if not self.tMailMsg then
		return
	end
	SocketManager:sendMsg("reqMailGet", {self.tMailMsg.nCategory, self.tMailMsg.sPid})
end

--点击保存回调
function DlgMailDetail:onSaveClicked( pView )
	if not self.tMailMsg then
		return
	end
	if not self.bCanClick then return end
	if self.tMailMsg.nCategory == e_type_mail.saved then
		self.bCanClick = false
		SocketManager:sendMsg("reqMailSaveCancel", {self.tMailMsg.sPid})
	else
		local nHasSave = Player:getMailData():getMailPageItemMax(e_type_mail.saved) or 0
		if nHasSave < getMailInitData("retentionNum") then
			self.bCanClick = false
			SocketManager:sendMsg("reqMailSave", {self.tMailMsg.nCategory, self.tMailMsg.sPid})
		else
			TOAST(getConvertedStr(7, 10136))
		end
	end
end

--查找
function DlgMailDetail:onFindClicked( pView )
	if not self.tMailMsg then
		return
	end
	local tConf = getMailDataById(self.tMailMsg.nId)
	if not tConf then
		return
	end
	if not tConf.position then
		return
	end
	local tKey = luaSplit(tConf.position, ";")
	if tKey and #tKey == 2 then
		local nX, nY = self.tMailMsg[tKey[1]], self.tMailMsg[tKey[2]]
		if nX and nY then
			local fX, fY = WorldFunc.getMapPosByDotPosEx(nX, nY)
			sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
			-- self:closeDlg(false)
			--关闭所有邮件详情界面
			closeMailDetail()
			closeDlgByType(e_dlg_index.mail,false)
			closeDlgByType(e_dlg_index.dlgchat,false)
		end
	end
end

--私聊
function DlgMailDetail:onPrivateChatClicked( pView )
	if not self.tMailMsg then
		return
	end
	local tConf = getMailDataById(self.tMailMsg.nId)
	if not tConf then
		return
	end

	-- local tObject = {} 
	-- tObject.nType = e_dlg_index.dlgchat --dlg类型
	-- tObject.nChatType = e_lt_type.sl --聊天类型
	-- tObject.tPChatInfo = {
	-- 	sPlayerName = self.tMailMsg[tConf.chat],
	-- }
	-- sendMsg(ghd_show_dlg_by_type,tObject)
	--
	local sPlayerName = self.tMailMsg[tConf.chat]
	--特殊处理
	if tConf.id == 14 or tConf.id == 15 then
		if self.tMailMsg.tDefHeros then
			if self.tMailMsg.tDefHeros[1] then
				sPlayerName = self.tMailMsg.tDefHeros[1].sPlayerName
			end
		end
	end

	local pMsgObj = {}
	pMsgObj.splayerName =sPlayerName
	pMsgObj.bToChat = true
	pMsgObj.nCloseHandler = function ()
		-- body
		closeMailDetail()
	end
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end

--保存成功
function DlgMailDetail:onMailSaveSuccess(  )
	local tMailMsg = Player:getMailData():getMailMsg(self.tMailMsg.sPid)
	if tMailMsg then
		TOAST(getTipsByIndex(10084))
		self.tMailMsg = tMailMsg
		self:updateSaveBtn()
		self.bCanClick = true
	end
end

--注销保存成功
function DlgMailDetail:onMailSaveCancelSuccess(  )
	local tMailMsg = Player:getMailData():getMailMsg(self.tMailMsg.sPid)
	if tMailMsg then
		TOAST(getTipsByIndex(10085))
		self.tMailMsg = tMailMsg
		self:updateSaveBtn()
		self.bCanClick = true
	end
end

--更改保存按钮文字
function DlgMailDetail:updateSaveBtn(  )
	if not self.pBtnSave then
		return
	end
	if self.tMailMsg.nCategory == e_type_mail.saved then
		self.pBtnSave:updateBtnText(getConvertedStr(3, 10210))
	else
		self.pBtnSave:updateBtnText(getConvertedStr(3, 10218))
	end
end

--更改领取按钮
function DlgMailDetail:updateGetBtn(  )
	if not self.pBtnGet then
		return
	end
	local tMailMsg = Player:getMailData():getMailMsg(self.tMailMsg.sPid)
	if tMailMsg then
		self.tMailMsg = tMailMsg
		local tItemList = self.tMailMsg.tRewardItemList or {}
		if #tItemList > 0 then
			if self.tMailMsg.bIsGot then
				self.pBtnGet:setExTextVisiable(true)
				self.pBtnGet:setButton(TypeCommonBtn.L_RED, getConvertedStr(3, 10161))
				self.pBtnGet:onCommonBtnClicked(handler(self, self.onDelClicked))
			else
				self.pBtnGet:setExTextVisiable(false)
				self.pBtnGet:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10213))
				self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
			end
		else
			self.pBtnGet:setExTextVisiable(false)
			self.pBtnGet:setButton(TypeCommonBtn.L_RED, getConvertedStr(3, 10161))
			self.pBtnGet:onCommonBtnClicked(handler(self, self.onDelClicked))
		end
	end
end

-- @fill_layout
return DlgMailDetail