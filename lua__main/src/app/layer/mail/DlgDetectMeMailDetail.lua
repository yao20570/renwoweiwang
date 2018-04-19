----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:32:11
-- Description: 遭到侦查邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailFunc = require("app.layer.mail.MailFunc")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")

-- 遭到侦查邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgDetectMeMailDetail = class("DlgDetectMeMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgDetectMeMailDetail:ctor( tMailMsg, pMsgObj)
	DlgDetectMeMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetaildetectme
	parseView("dlg_detect_me_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgDetectMeMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgDetectMeMailDetail",handler(self, self.onDlgDetectMeMailDetailDestroy))
end

-- 析构方法
function DlgDetectMeMailDetail:onDlgDetectMeMailDetailDestroy(  )
    self:onPause()
end

function DlgDetectMeMailDetail:regMsgs(  )
	DlgDetectMeMailDetail.super.regMsgs(self)
end

function DlgDetectMeMailDetail:unregMsgs(  )
	DlgDetectMeMailDetail.super.unregMsgs(self)
end

function DlgDetectMeMailDetail:onResume(  )
	self:regMsgs()
end

function DlgDetectMeMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgDetectMeMailDetail:setupViews(  )
	--侦查邮件的分享也要显示查找按钮
	if self.bShare then
		--按钮
		local pLayBtnFind = self:findViewByName("lay_btn_find")
		self:setFindBtn(pLayBtnFind, true, getConvertedStr(9, 10020))
		pLayBtnFind:setPositionX((self:getWidth()-pLayBtnFind:getWidth())/2)
	else
		local pLayBtnFind = self:findViewByName("lay_btn_find")
		self:setFindBtn(pLayBtnFind, true)
	end
	
	local pLayBtnShare = self:findViewByName("lay_btn_share")
	self:setShareBtn(pLayBtnShare)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setSaveBtn(pLayBtnSave)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	
	
	--图标
	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon)

	pLayIcon:setViewTouched(true)
	pLayIcon:setIsPressedNeedScale(false)
	pLayIcon:onMViewClicked(handler(self, self.onFindClicked))

	--背景
	local pLayBg = self:findViewByName("lay_bg")
	local pSize = pLayBg:getContentSize()
	local nWidht, nHeight = pSize.width, pSize.height

	--加入内容子节点
	local function addContentChild( pNode )
		nHeight = nHeight - pNode:getContentSize().height
		pNode:setPosition(0, nHeight)
		pLayBg:addView(pNode)
	end

	--发送时间
	-- local pLaySendTime = self:findViewByName("lay_send_time")
	-- local pSnedTime = MailDetailSendTime.new(self.tMailMsg)
	-- pLaySendTime:addView(pSnedTime)
	-- nHeight = nHeight - pSnedTime:getContentSize().height

	--基本信息
	local pLayInfo = self:findViewByName("lay_info")
	nHeight = nHeight - pLayInfo:getContentSize().height
	--富文本内容
	local pLayRichtextInfo = self:findViewByName("lay_richtext_info")
	--基本信息
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	getRichLabelOfContainer(pLayRichtextInfo, tStr, nil, pLayRichtextInfo:getContentSize().width)

	--时间横条
	local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
	local sTime={
		{sStr=sDelTime,nFontSize=18,sColor=_cc.red},
		{sStr=sSendTime,nFontSize=18,sColor=_cc.pwhite}
	}
	nHeight=nHeight+20
	local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(9, 10064),sTime)
	--addContentChild(pMailDetailBanner)
    pMailDetailBanner:setPosition(0, -pMailDetailBanner:getContentSize().height)
	pLayBg:addView(pMailDetailBanner)
end


function DlgDetectMeMailDetail:updateViews(  )
end

return DlgDetectMeMailDetail