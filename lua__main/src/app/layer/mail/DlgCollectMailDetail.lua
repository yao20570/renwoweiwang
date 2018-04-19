----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 采集邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailDetailGetItems = require("app.layer.mail.MailDetailGetItems")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local CollectMailBattle = require("app.layer.mail.CollectMailBattle")
local MailFunc = require("app.layer.mail.MailFunc")

-- 系统邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgCollectMailDetail = class("DlgCollectMailDetail", DlgMailDetail)


--tMailMsg 邮件数据
function DlgCollectMailDetail:ctor( tMailMsg, pMsgObj)
	DlgCollectMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetailcollect
	parseView("dlg_collect_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCollectMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCollectMailDetail",handler(self, self.onDlgCollectMailDetailDestroy))
end

-- 析构方法
function DlgCollectMailDetail:onDlgCollectMailDetailDestroy(  )
    self:onPause()
end

function DlgCollectMailDetail:regMsgs(  )
	DlgCollectMailDetail.super.regMsgs(self)
end

function DlgCollectMailDetail:unregMsgs(  )
	DlgCollectMailDetail.super.unregMsgs(self)
end

function DlgCollectMailDetail:onResume(  )
	self:regMsgs()
end

function DlgCollectMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgCollectMailDetail:setupViews(  )
	--按钮
	local pLayBtnShare = self:findViewByName("lay_btn_share")
	self:setShareBtn(pLayBtnShare)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setSaveBtn(pLayBtnSave)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	local pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(pLayBtnFind)


	--图标
	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon)

	--背景
	local pLayBg = self:findViewByName("lay_bg")
	local pSize = pLayBg:getContentSize()
	local nWidth, nHeight = pSize.width, pSize.height

	--加入内容子节点
	local function addContentChild( pNode )
		nHeight = nHeight - pNode:getContentSize().height
		pNode:setPosition(0, nHeight)
		pLayBg:addView(pNode)
	end
	-- dump(self.tMailMsg)

	-- if self.tMailMsg.

	--显示活动额外增收
	local tMineData=getWorldMineData(self.tMailMsg.nMine)
	if tMineData  and tMineData.type~=5  then
		local pTxtActTip=self:findViewByName("txt_act_tip")
		local tAct=Player:getActById(e_id_activity.doublecollect)
		if tAct and tAct:isOpen() then
			pTxtActTip:setVisible(true)
			setTextCCColor(pTxtActTip,_cc.green)
			pTxtActTip:setString(getConvertedStr(9,10022))
		else
			pTxtActTip:setVisible(false)
		end
	end
	--发送时间
	-- local pLaySendTime = self:findViewByName("lay_send_time")
	-- local pSnedTime = MailDetailSendTime.new(self.tMailMsg)
	-- pLaySendTime:addView(pSnedTime)
	-- nHeight = nHeight - pSnedTime:getContentSize().height

	--基本信息
	local pLayInfo = self:findViewByName("lay_info")
	pLayInfo:setOpacity(0.7*255)
	nHeight = nHeight - pLayInfo:getContentSize().height+20
	local pLayRichtextInfo = self:findViewByName("lay_richtext_info")
	local pTxtCollectTimeTitle = self:findViewByName("txt_collect_time_title")
	setTextCCColor(pTxtCollectTimeTitle, _cc.pwhite) 
	pTxtCollectTimeTitle:setString(getConvertedStr(3, 10219))
	local pTxtCollectTime = self:findViewByName("txt_collect_time")
	setTextCCColor(pTxtCollectTime, _cc.blue)
	pTxtCollectTime:setString(getTimeLongStr(self.tMailMsg.nCollectTime, false, true ))
	local pLayRichtextExp = self:findViewByName("lay_richtext_exp")
	local tHero = getHeroDataById(self.tMailMsg.nMineHeroId)
	if tHero then
		local tStr = {
			{color=_cc.white,text=string.format(getConvertedStr(3, 10251), tHero.sName, getLvString(self.tMailMsg.nMineHeroLv))},
			{color=_cc.green,text=getConvertedStr(3, 10252) .. self.tMailMsg.nMineHeroExp},
		}
		getRichLabelOfContainer(pLayRichtextExp,tStr)
	end


	--基本信息
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	getRichLabelOfContainer(pLayRichtextInfo,tStr)

	--采集横条
	local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
	local sTime={
		{sStr=sDelTime,nFontSize=18,sColor=_cc.red},
		{sStr=sSendTime,nFontSize=18,sColor=_cc.pwhite}
	}
	local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10217),sTime)
	addContentChild(pMailDetailBanner)

	local tMine =  getWorldMineData(self.tMailMsg.nMine)
	if tMine then
		--邮件详情领取奖励
		nHeight=nHeight-15
		local tItemList = {
			{k = tMine.output, v = self.tMailMsg.nMineNum }
		}
		local pMailDetailGetItems = MailDetailGetItems.new(tItemList,2)
		addContentChild(pMailDetailGetItems)
		nHeight = nHeight - 15 
	end

	--有攻击数据才加载
	if self.tMailMsg.tFightDetails and #self.tMailMsg.tFightDetails > 0 then
		--攻防横条
		local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()
		addContentChild(pMailDetailAtkDefBanner)
		--采集玩家战役
		local pCollectMailBattle = CollectMailBattle.new(cc.size(nWidth, nHeight), self.tMailMsg)
		addContentChild(pCollectMailBattle)
	end
end


function DlgCollectMailDetail:updateViews(  )
end

return DlgCollectMailDetail