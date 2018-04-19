----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:32:11
-- Description: 驻守邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailGoHeroInfo = require("app.layer.mail.MailGoHeroInfo")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailFunc = require("app.layer.mail.MailFunc")

-- 驻守邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgGarrisonMailDetail = class("DlgGarrisonMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgGarrisonMailDetail:ctor( tMailMsg, pMsgObj)
	DlgGarrisonMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetailgarrison
	parseView("dlg_garrison_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgGarrisonMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgGarrisonMailDetail",handler(self, self.onDlgGarrisonMailDetailDestroy))
end

-- 析构方法
function DlgGarrisonMailDetail:onDlgGarrisonMailDetailDestroy(  )
    self:onPause()
end

function DlgGarrisonMailDetail:regMsgs(  )
	DlgGarrisonMailDetail.super.regMsgs(self)
end

function DlgGarrisonMailDetail:unregMsgs(  )
	DlgGarrisonMailDetail.super.unregMsgs(self)
end

function DlgGarrisonMailDetail:onResume(  )
	self:regMsgs()
end

function DlgGarrisonMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgGarrisonMailDetail:setupViews(  )
	--按钮

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setSaveBtn(pLayBtnSave)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	--按钮
	local pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(pLayBtnFind)

	--图标

	-- dump(self.tMailMsg)

	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon)

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



	--富文本内容
	local pLayRichtextInfo = self:findViewByName("lay_richtext_info")
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	getRichLabelOfContainer(pLayRichtextInfo,tStr)
	nHeight=nHeight+20
	--时间横条
	local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
	local sTime={
			{sStr=sDelTime,nFontSize=18,sColor=_cc.red},
			{sStr=sSendTime,nFontSize=18,sColor=_cc.pwhite}
	}
	local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10230),sTime)
	addContentChild(pMailDetailBanner)
	local tGoHeros = self.tMailMsg.tGoHeros
	if tGoHeros then
		--武将信息
		
		-- local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10230))
		-- addContentChild(pMailDetailBanner)

		--滚动武将列表
		local pMailGoHeroInfo = MailGoHeroInfo.new(cc.size(nWidht, nHeight), tGoHeros)
		addContentChild(pMailGoHeroInfo)
	end
end


function DlgGarrisonMailDetail:updateViews(  )
end

return DlgGarrisonMailDetail