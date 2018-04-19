----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 系统邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local IconGoods = require("app.common.iconview.IconGoods")
local MCommonView = require("app.common.MCommonView")
local RichTextEx = require("app.common.richview.RichTextEx")
local MRichLabel = require("app.common.richview.MRichLabel")
local MailFunc = require("app.layer.mail.MailFunc")

-- 系统邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgSysMailDetail = class("DlgSysMailDetail", DlgMailDetail)


--tMailMsg 邮件数据
function DlgSysMailDetail:ctor( tMailMsg, pMsgObj)
	DlgSysMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetailsys
	parseView("dlg_sys_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgSysMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSysMailDetail",handler(self, self.onDlgSysMailDetailDestroy))
end

-- 析构方法
function DlgSysMailDetail:onDlgSysMailDetailDestroy(  )
    self:onPause()
end

function DlgSysMailDetail:regMsgs(  )
	DlgSysMailDetail.super.regMsgs(self)
end

function DlgSysMailDetail:unregMsgs(  )
	DlgSysMailDetail.super.unregMsgs(self)
end

function DlgSysMailDetail:onResume(  )
	self:regMsgs()
end

function DlgSysMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgSysMailDetail:setupViews(  )
	--背景
	local pLayBg = self:findViewByName("lay_bg")
	local pSize = pLayBg:getContentSize()
	local nWidht, nHeight = pSize.width, pSize.height

	--发送时间
	local pLaySendTime = self:findViewByName("lay_send_time")
	local pSnedTime = MailDetailSendTime.new(self.tMailMsg)
	pLaySendTime:addView(pSnedTime)
	nHeight = nHeight - pSnedTime:getContentSize().height

	--基本信息
	local pLayInfo = self:findViewByName("lay_info")
	local pTxtSender = self:findViewByName("txt_sender")
	setTextCCColor(pTxtSender, _cc.blue)
	local pTxtMailTitle = self:findViewByName("txt_mail_title")
	setTextCCColor(pTxtMailTitle, _cc.pwhite)
	nHeight = nHeight - pLayInfo:getContentSize().height

	--领取按钮
	local pLayBtnGet = self:findViewByName("lay_btn_get")
	self:setGetBtn(pLayBtnGet)
	
	if self.tMailMsg then
		local sSendName = ""
		local sTitle = ""
		local tStr = nil
		if self.tMailMsg.nId == nil or self.tMailMsg.nId == 0 then --没模板状态 --znftodo优化
			sSendName = self.tMailMsg.sCreatName
			sTitle = self.tMailMsg.sTitle or ""
			tStr = getTextColorByConfigure(self.tMailMsg.sContent)
		else
			local tMailData = getMailDataById(self.tMailMsg.nId)
			if tMailData then
				sSendName = tMailData.sendname or ""
				sTitle = tMailData.title or ""
			end
			tStr = MailFunc.getContentTextColor(self.tMailMsg)
		end
		--发送者
		pTxtSender:setString(getConvertedStr(3, 10247) .. sSendName)
		--标题
		pTxtMailTitle:setString(getConvertedStr(3, 10248) .. sTitle)

		--动态文字
--		local pRichLabel = MUI.MLabel.new({
--			text = "", 
--			size = 20, 
--		    anchorpoint = cc.p(0, 0),
--			align = cc.ui.TEXT_ALIGN_LEFT, 
--			valign = cc.ui.TEXT_VALIGN_TOP, 
--			dimensions = cc.size(530, 0)
--			})
--		pRichLabel:setString(tStr)

        local pRichLabel = RichTextEx.new({width = 530, autow = true})
        local tNewStr = clone(tStr) --为了不影响原数据
		-- tStr = removeSysEmoInTable(tNewStr)
		strRich = getTableParseEmo(tNewStr)
        pRichLabel:setString(strRich)



		--动态可领取商品面板
		local pLayItemsView = nil
		local tItemList = self.tMailMsg.tRewardItemList or {}

		--图标位置
		local nOffsetX, nOffsetY = 135, 160
		local nItemHeight = math.ceil(#tItemList/4) * nOffsetY
		local nWidth = 600

		--文字加商品面板
		local nInnerHeight = nItemHeight + pRichLabel:getContentSize().height + 20
		local pLayInnerView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
		pLayInnerView:setContentSize(nWidth, nInnerHeight)
		-- pLayInnerView:setBackgroundImage("#v1_img_kelashen10.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})
		pLayInnerView:setPositionX(20)

		--加入文字
		pLayInnerView:addView(pRichLabel)
		local nRichLabelY = nInnerHeight - pRichLabel:getContentSize().height - 10
		pRichLabel:setPosition(40, nRichLabelY)			

		--加入商品图标
		local nBeginX, nBeginY = 25, nRichLabelY
		local nW = nWidth / 4
		local nCount = #tItemList
		for i=1, nCount do
			local pIcon = IconGoods.new(TypeIconGoods.HADMORE)
			pIcon:setScale(0.8)
			local fX, fY
			if #tItemList <= 4 then
				local nOffX = (pIcon:getWidth()/2)*pIcon:getScale()
				if nCount == 1 then
					fX = (i + 1) *nW - nOffX
				elseif nCount == 2 then
					fX = i * nW + nW / 2 - nOffX
				elseif nCount == 3 then
					fX = i * nW - nOffX
				elseif nCount == 4 then
					fX = (i - 1) * nW + nW / 2 - nOffX
				end
			else
				local nCol = ((i-1) % 4)
				fX = nBeginX + nCol * nOffsetX
			end
			local nRow = math.ceil(i/4)
			fY = nBeginY - nRow * nOffsetY
			
			pIcon:setPosition(fX, fY)
			pLayInnerView:addView(pIcon)
			local pItemData = getGoodsByTidFromDB(tItemList[i].k)
            if pItemData then
				pIcon:setCurData(pItemData)
	            pIcon:setMoreText(pItemData.sName)
				pIcon:setMoreTextColor(getColorByQuality(pItemData.nQuality))
			end
			pIcon:setNumber(tItemList[i].v)
		end
		
			
		--滚动内容面板
		local pLayScrollInner = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
		local nLayScrollInnerHeight = math.max(nHeight, nInnerHeight)
		pLayScrollInner:setContentSize(nWidth, nLayScrollInnerHeight)
		pLayScrollInner:addView(pLayInnerView)
		pLayInnerView:setPositionY(nLayScrollInnerHeight - nInnerHeight)

		--生成垂直滚动层
		self.pScrollView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, nWidth, nHeight),
	        touchOnContent = false,
	        direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
	        bothSize=cc.size(nWidth, nLayScrollInnerHeight)
	        })
		pLayBg:addView(self.pScrollView)
		--加入文字商品层
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pScrollView:setUpAndDownArrow(pUpArrow, pDownArrow)	
		self.pScrollView:addView(pLayScrollInner)		
	end
end

function DlgSysMailDetail:updateViews(  )
end

return DlgSysMailDetail