----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-26 17:12:51
-- Description: Boss战支援面板
-----------------------------------------------------
-- 城战支援面板
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgBossWarSendHelp = class("DlgBossWarSendHelp", function()
	return DlgCommon.new(e_dlg_index.bosswarhelp)
end)

function DlgBossWarSendHelp:ctor(  )
	parseView("dlg_city_war_send_help", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgBossWarSendHelp:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10043))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBossWarSendHelp",handler(self, self.onDlgBossWarSendHelpDestroy))
end

-- 析构方法
function DlgBossWarSendHelp:onDlgBossWarSendHelpDestroy(  )
    self:onPause()
end

function DlgBossWarSendHelp:regMsgs(  )
end

function DlgBossWarSendHelp:unregMsgs(  )
end

function DlgBossWarSendHelp:onResume(  )
	self:regMsgs()
end

function DlgBossWarSendHelp:onPause(  )
	self:unregMsgs()
end

function DlgBossWarSendHelp:setupViews(  )
	local pTxtTip = self:findViewByName("txt_tip")
	pTxtTip:setString(getConvertedStr(3, 10189))
	local pLayRichtextContent = self:findViewByName("lay_richtext_content")

	local pContentSize = pLayRichtextContent:getContentSize()
	self.pTxtContent = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    color = getC3B(_cc.gray),
		    dimensions = pContentSize,
		})
	pLayRichtextContent:addView(self.pTxtContent)
	centerInView(pLayRichtextContent, self.pTxtContent)

	local pLayBtnSupport = self:findViewByName("lay_btn_send")
	self.pBtnSupport = getCommonButtonOfContainer(pLayBtnSupport,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10043))
	self.pBtnSupport:onCommonBtnClicked(handler(self, self.onSupportClicked))
end

function DlgBossWarSendHelp:updateViews(  )
	if not self.tViewDotMsg then
		return
	end

	local tAwakeBoss = getAwakeBossData(self.tViewDotMsg.nBossLv)
	if tAwakeBoss then
		local tStr = {
			{color= _cc.gray, text = string.format(getConvertedStr(3, 10509), tAwakeBoss.name)},
		}
		self.pTxtContent:setString(tStr)
	end
	
	if not self.tBossWarVO then
		return
	end

	--最大值
	if not self.nMaxHelp then
		self.nMaxHelp = tAwakeBoss.sostime
		local tLabel = {
		 {getConvertedStr(3, 10130), getC3B(_cc.gray)},
		 {"0", getC3B(_cc.white)},
		 {"/"..self.nMaxHelp}
		}
		self.pBtnSupport:setBtnExText({tLabel = tLabel})
	end

	--可支持次数
	if self.nMaxHelp then
		local nCanSupportTimes = math.max(self.nMaxHelp - self.tBossWarVO.nSupport, 0)
		self.nCanSupportTimes = nCanSupportTimes
		if nCanSupportTimes > 0 then
			self.pBtnSupport:setExTextLbCnCr(2, nCanSupportTimes, getC3B(_cc.white))
			self.pBtnSupport:setToGray(false)
		else
			self.pBtnSupport:setExTextLbCnCr(2, nCanSupportTimes, getC3B(_cc.red))
			self.pBtnSupport:setToGray(true)
		end
	end
end

function DlgBossWarSendHelp:setData( tViewDotMsg, tBossWarVO)
	self.tViewDotMsg = tViewDotMsg
	self.tBossWarVO = tBossWarVO
	self:updateViews()
end

function DlgBossWarSendHelp:onSupportClicked( pView )
	if self.nCanSupportTimes <= 0 then
		TOAST(getConvertedStr(3, 10378))
		return
	end

	SocketManager:sendMsg("reqWorldBossSupport", {self.tViewDotMsg.nX, self.tViewDotMsg.nY,self.tViewDotMsg},function( __msg, __oldMsg )
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.reqWorldBossSupport.id then
				--更新次数扣一
				sendMsg(ghd_world_boss_war_support_used)

				-- TOAST(getTipsByIndex(10076))
			end
		else
	        TOAST(SocketManager:getErrorStr(__msg.head.state))
	    end	
	end)
	self:closeDlg(false)
end

return DlgBossWarSendHelp