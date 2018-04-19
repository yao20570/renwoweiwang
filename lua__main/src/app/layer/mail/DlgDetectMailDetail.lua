----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:32:11
-- Description: 侦查邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local DetectMailCityAttrs = require("app.layer.mail.DetectMailCityAttrs")
local DetectMailCityHero = require("app.layer.mail.DetectMailCityHero")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailDetailGetItems = require("app.layer.mail.MailDetailGetItems")
local MailFunc = require("app.layer.mail.MailFunc")
-- 侦查邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgDetectMailDetail = class("DlgDetectMailDetail", DlgMailDetail)
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")
local ItemDetectMailCityHero = require("app.layer.mail.ItemDetectMailCityHero")

local ScrollViewEx = require("app.common.listview.ScrollViewEx")

--tMailMsg 邮件数据
function DlgDetectMailDetail:ctor( tMailMsg, pMsgObj)
	DlgDetectMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	self.eDlgType = e_dlg_index.maildetaildetect
	parseView("dlg_detect_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgDetectMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgDetectMailDetail",handler(self, self.onDlgDetectMailDetailDestroy))
end

-- 析构方法
function DlgDetectMailDetail:onDlgDetectMailDetailDestroy(  )
    self:onPause()
end

function DlgDetectMailDetail:regMsgs(  )
	DlgDetectMailDetail.super.regMsgs(self)
end

function DlgDetectMailDetail:unregMsgs(  )
	DlgDetectMailDetail.super.unregMsgs(self)
end

function DlgDetectMailDetail:onResume(  )
	self:regMsgs()
end

function DlgDetectMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgDetectMailDetail:setupViews(  )
	--按钮
	local pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(pLayBtnFind,true)

	local pLayBtnShare = self:findViewByName("lay_btn_share")
	self:setShareBtn(pLayBtnShare)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setSaveBtn(pLayBtnSave)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	--侦查邮件的分享也要显示查找按钮
	if self.bShare then
		pLayBtnFind:setPositionX((self:getWidth()-pLayBtnFind:getWidth())/2)
	end
	

	--背景
	self.pLayBg = self:findViewByName("lay_bg")
	self.pSv = ScrollViewEx.new( self.pLayBg:getWidth(), self.pLayBg:getHeight())
	self.pSv:setAnchorPoint(0,0)
	self.pLayBg:addView(self.pSv)

	self.pLayContent=MUI.MLayer.new()
    self.pLayContent:setContentSize(self.pLayBg:getWidth(), self.pLayBg:getHeight())
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pSv:setUpAndDownArrow(pUpArrow, pDownArrow)	
	self.pSv:addView(self.pLayContent)
	self.pLayContent:setPosition(0,0)

	self.pSv:setScrollViewContent(self.pLayContent)

	local pSize = self.pLayBg:getContentSize()
	local nWidht, nHeight = pSize.width, pSize.height

	--加入内容子节点
	-- local nZoder = 1
	-- local function addContentChild( pNode )
	-- 	nHeight = nHeight - pNode:getContentSize().height
	-- 	pNode:setPositionY(0)
	-- 	self.pLayBg:addView(pNode,nZoder)
	-- 	nZoder = nZoder + 1
	-- end

	local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
	local pBanner=MUI.MImage.new("ui/big_img_sep/v2_bg_caijibeijing.jpg") 
	pBanner:setOpacity(0.7*255)
	pLayInfo:setContentSize(pBanner:getWidth(),pBanner:getHeight())
	pBanner:setAnchorPoint(0,0)
	pLayInfo:addView(pBanner)
	self.pSv:addScrollViewChild(pLayInfo)

	-- --图标
	local pLayIcon = MUI.MLayer.new()
	pLayIcon:setContentSize(cc.size(150, 150))
	self:setIcon(pLayIcon)

	pLayIcon:setViewTouched(true)
	pLayIcon:setIsPressedNeedScale(false)
	pLayIcon:onMViewClicked(handler(self, self.onFindClicked))
	pLayIcon:setPosition(pLayInfo:getWidth() - pLayIcon:getWidth() - 30,30)
	pLayInfo:addView(pLayIcon,5)

	-- nHeight = nHeight - pLayInfo:getContentSize().height
	
	local pRichtextInfo = MUI.MLabel.new({text = "", size = 20,anchorpoint = cc.p(0, 0.5),})
	-- --基本信息
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	pRichtextInfo:setString(tStr)
	pRichtextInfo:setPosition(20, 133)
	pLayInfo:addView(pRichtextInfo,5)
	-- --人口数量
	local pTxtPersonTitle = MUI.MLabel.new({text = "", size = 20,anchorpoint = cc.p(0, 0.5),})
	pTxtPersonTitle:setPosition(20, 100)
	pLayInfo:addView(pTxtPersonTitle,5)
	-- local pTxtPersonTitle = self:findViewByName("txt_person_title")
	-- --人口数量
	local pTxtPersion = MUI.MLabel.new({text = "", size = 20,anchorpoint = cc.p(0, 0.5),})
	pTxtPersion:setPosition(20, 100)
	pLayInfo:addView(pTxtPersion,5)
	setTextCCColor(pTxtPersion, _cc.green)
	

	--时间横条
	local sSendTime,sDelTime=getMailSendTime(self.tMailMsg)
	local sTime={
		{sStr=sDelTime,nFontSize=18,sColor=_cc.red},
		{sStr=sSendTime,nFontSize=18,sColor=_cc.pwhite}
	}
	nHeight=nHeight+20
	local pMailDetailBanner = MailDetailBanner.new(getConvertedStr(3, 10228),sTime)
	self.pSv:addScrollViewChild(pMailDetailBanner)

	local bIsShowTip = true
	--侦查失败 --znftodo以后优化
	if self.tMailMsg.nId == 17 then
		pTxtPersonTitle:setString(getConvertedStr(3, 10232))
		setTextCCColor(pTxtPersonTitle, _cc.red)
		pTxtPersion:setVisible(false)

		--显示提示
	if bIsShowTip then

		local pLayer1 = self:getNothingTip(nWidht)
		self.pSv:addScrollViewChild(pLayer1)
		
		--城池信息条
		local pMailDetailBanner = ItemMailRewardBanner.new(getConvertedStr(3, 10229))
		self.pSv:addScrollViewChild(pMailDetailBanner)

		local pLayer2 = self:getNothingTip(nWidht)
		self.pSv:addScrollViewChild(pLayer2)


		--武将信息条
		local pMailDetailBanner3 = ItemMailRewardBanner.new(getConvertedStr(3, 10230))
		self.pSv:addScrollViewChild(pMailDetailBanner3)


		local pLayer3 = self:getNothingTip(nWidht)
		self.pSv:addScrollViewChild(pLayer3)


	end

	else--侦查成功
		local tScoutResult = self.tMailMsg.tScoutResult
		if tScoutResult then
			pTxtPersonTitle:setString(getConvertedStr(3, 10231))
			pTxtPersion:setString("+"..tScoutResult.nCityPerson)
			pTxtPersion:setPositionX(pTxtPersonTitle:getPositionX() + pTxtPersonTitle:getWidth() )
			
			--邮件详情领取奖励
			local nCoinId = 3 -- 银币
			local nWoodId = 4 -- 木材
			local nFoodId = 2 -- 粮草

			local tItemList = {}
			if tScoutResult.nSliver and tScoutResult.nSliver>0 then
				local tTemp={k = nCoinId, v = tScoutResult.nSliver }
				table.insert(tItemList,tTemp)
			end

			if tScoutResult.nWood and tScoutResult.nWood>0 then
				local tTemp={k = nWoodId, v = tScoutResult.nWood}
				table.insert(tItemList,tTemp)
			end
			if tScoutResult.nFood and tScoutResult.nFood>0 then
				local tTemp={k = nFoodId, v = tScoutResult.nFood}
				table.insert(tItemList,tTemp)
			end
			
			local pLayer = MUI.MLayer.new()
			pLayer:setLayoutSize(nWidht,130)

			local pMailDetailGetItems = MailDetailGetItems.new(tItemList)
			pLayer:addView(pMailDetailGetItems,1)
			centerInView(pLayer,pMailDetailGetItems)
			-- addContentChild(pLayer)
			self.pSv:addScrollViewChild(pLayer)

			
			--显示part2
			--城池信息条
			local pMailDetailBanner = ItemMailRewardBanner.new(getConvertedStr(3, 10229))
			self.pSv:addScrollViewChild(pMailDetailBanner)

			if tScoutResult.nType >= 2 then

				--城池信息
				local pDetectMailCityAttrs = DetectMailCityAttrs.new(tScoutResult)
			self.pSv:addScrollViewChild(pDetectMailCityAttrs)

			else
				local pLayer1 = self:getNothingTip(nWidht)
			self.pSv:addScrollViewChild(pLayer1)

			end

			--显示part3
			--武将信息条
			local pMailDetailBanner3 = ItemMailRewardBanner.new(getConvertedStr(3, 10230))
			self.pSv:addScrollViewChild(pMailDetailBanner3)

			if tScoutResult.nType >= 3 then
				bIsShowTip = false
				--滚动武将列表
				self.tScoutHeroInfos=tScoutResult.tScoutHeroInfos

				self.pHeroList=MUI.MLayer.new()
			    self.pHeroList:setContentSize(640, 130 * #self.tScoutHeroInfos)
				self.pSv:addScrollViewChild(self.pHeroList)

			    self.pSv:setListView(self.pHeroList,640,130,handler(self,self.addHeroItemListCallback),130)
			    self.pSv:setListViewNum(self.pHeroList,#self.tScoutHeroInfos)

			    self.pSv:refreshListViews()
			    self.pSv:resetContentSize()

			else
				local pLayer2 = self:getNothingTip(nWidht)
				self.pSv:addScrollViewChild(pLayer2)

			end
		end
	end


end
--获得无侦查物品的提示
function DlgDetectMailDetail:getNothingTip( _nWidth )
	-- body
	local pLayer = MUI.MLayer.new()
	pLayer:setLayoutSize(_nWidth,100)
	local pTxtTip = MUI.MLabel.new({
		text = getConvertedStr(3, 10238),
		size = 20,
		align = cc.ui.TEXT_ALIGN_LEFT,
		valign = cc.ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(570, 100),
		})
	setTextCCColor(pTxtTip, _cc.pwhite)
	
	centerInView(pLayer,pTxtTip)
	pLayer:addView(pTxtTip)
	return pLayer
end

function DlgDetectMailDetail:updateViews(  )
end

function DlgDetectMailDetail:addHeroItemListCallback( _pView,_nIndex  )
	-- body
	local pTempView = _pView
	local pTempData = self.tScoutHeroInfos[_nIndex]
	if pTempView == nil then
		pTempView   = ItemDetectMailCityHero.new()
	end
	pTempView:setData(pTempData)
	return pTempView
end

return DlgDetectMailDetail