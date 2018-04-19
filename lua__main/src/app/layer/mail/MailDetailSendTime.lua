----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local MailDetailSendTime = class("MailDetailSendTime", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function MailDetailSendTime:ctor( tMailMsg )
	self.tMailMsg = tMailMsg
	--解析文件
	parseView("lay_mail_send_time", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MailDetailSendTime:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MailDetailSendTime",handler(self, self.onMailDetailSendTimeDestroy))
end

-- 析构方法
function MailDetailSendTime:onMailDetailSendTimeDestroy(  )
    self:onPause()
end

function MailDetailSendTime:regMsgs(  )
end

function MailDetailSendTime:unregMsgs(  )
end

function MailDetailSendTime:onResume(  )
	self:regMsgs()
end

function MailDetailSendTime:onPause(  )
	self:unregMsgs()
end

function MailDetailSendTime:setupViews(  )
	local pTxtSendTime = self:findViewByName("txt_send_time")
	local pTxtDelTime = self:findViewByName("txt_del_time")
	setTextCCColor(pTxtDelTime, _cc.red)

	--毫秒级别保存上限
	-- local nSaveTime = 0
	-- if self.tMailMsg.nCategory == e_type_mail.saved then
	-- 	nSaveTime = getMailInitData("retentionTime") * 1000
	-- else
	-- 	nSaveTime = getMailInitData("mailTime") * 1000
	-- end
	-- --当前时间-修改时间-保存相关保存类别的上限时间 = 剩余时间(毫秒)
	-- local nSubTime = math.max(nSaveTime - (getSystemTime(false) - self.tMailMsg.nLmt),0)
	-- --毫秒转天数
	-- local nDay = math.ceil(nSubTime/1000/60/60/24)
	-- pTxtDelTime:setString(string.format(getConvertedStr(3, 10242), nDay))
	
	--显示发送时间
	if self.tMailMsg then
		local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
		pTxtSendTime:setString(sSendTime)
		pTxtDelTime:setString(sDelTime)
	end
end

function MailDetailSendTime:updateViews(  )
end

return MailDetailSendTime


