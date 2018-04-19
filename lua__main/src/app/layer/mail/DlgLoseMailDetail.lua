----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:32:11
-- Description: 目标丢失邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailGoHeroInfo = require("app.layer.mail.MailGoHeroInfo")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailFunc = require("app.layer.mail.MailFunc")
-- 目标丢失邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgLoseMailDetail = class("DlgLoseMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgLoseMailDetail:ctor( tMailMsg, pMsgObj)
	DlgLoseMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetaillose
	parseView("dlg_lose_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgLoseMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgLoseMailDetail",handler(self, self.onDlgLoseMailDetailDestroy))
end

-- 析构方法
function DlgLoseMailDetail:onDlgLoseMailDetailDestroy(  )
    self:onPause()
end

function DlgLoseMailDetail:regMsgs(  )
	DlgLoseMailDetail.super.regMsgs(self)
end

function DlgLoseMailDetail:unregMsgs(  )
	DlgLoseMailDetail.super.unregMsgs(self)
end

function DlgLoseMailDetail:onResume(  )
	self:regMsgs()
end

function DlgLoseMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgLoseMailDetail:setupViews(  )
	-- dump(self.tMailMsg)

	local tConf = getMailDataById(self.tMailMsg.nId)
	
	if not tConf.position then
		--按钮
		local pLayBtnSave = self:findViewByName("lay_btn_find")
		self:setSaveBtn(pLayBtnSave)

		local pLayBtnDel = self:findViewByName("lay_btn_del")
		self:setDelBtn(pLayBtnDel)
		local pLayBtnCenter = self:findViewByName("lay_btn_save")
		pLayBtnCenter:setVisible(false)
	else

		--按钮
		local pLayBtnFind = self:findViewByName("lay_btn_find")
		self:setFindBtn(pLayBtnFind)
		
		local pLayBtnSave = self:findViewByName("lay_btn_save")
		self:setSaveBtn(pLayBtnSave)

		local pLayBtnDel = self:findViewByName("lay_btn_del")
		self:setDelBtn(pLayBtnDel)

	end

	-- --按钮
	-- local pLayBtnSave = self:findViewByName("lay_btn_save")
	-- self:setSaveBtn(pLayBtnSave)

	-- local pLayBtnDel = self:findViewByName("lay_btn_del")
	-- self:setDelBtn(pLayBtnDel)

	--图标
	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon, true)
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

	-- --发送时间
	-- local pLaySendTime = self:findViewByName("lay_send_time")
	-- local pSnedTime = MailDetailSendTime.new(self.tMailMsg)
	-- pLaySendTime:addView(pSnedTime)
	-- nHeight = nHeight - pSnedTime:getContentSize().height


	--基本信息
	local pLayInfo = self:findViewByName("lay_info")
	pLayInfo:setOpacity(0.7*255)
	nHeight = nHeight - pLayInfo:getContentSize().height

	--时间横条
	local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
	local sTime={
		{sStr=sDelTime,nFontSize=18,sColor=_cc.red},
		{sStr=sSendTime,nFontSize=18,sColor=_cc.pwhite}
	}
	nHeight=nHeight+20
	local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10230),sTime)
	addContentChild(pMailDetailBanner)

	--富文本内容
	local pLayRichtextInfo = self:findViewByName("lay_richtext_info")
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	getRichLabelOfContainer(pLayRichtextInfo,tStr)
	local pTxtDesc = self:findViewByName("txt_desc")
	local tMailReport = getMailReport(self.tMailMsg.nId)
	if tMailReport then
		local tStr = MailFunc.analysisMailMsg(self.tMailMsg,tMailReport.sDesc)
		pTxtDesc:setString(tStr) 
		-- setTextCCColor(pTxtDesc, tMailReport.sDescColor)
	end
	
	local tGoHeros = self.tMailMsg.tGoHeros
	if tGoHeros and #tGoHeros>0 then
		--武将信息
		-- local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10230))
		-- addContentChild(pMailDetailBanner)

		--滚动武将列表
		local pMailGoHeroInfo = MailGoHeroInfo.new(cc.size(nWidht, nHeight), tGoHeros)
		addContentChild(pMailGoHeroInfo)
	end
end

function DlgLoseMailDetail:updateViews(  )
end


return DlgLoseMailDetail