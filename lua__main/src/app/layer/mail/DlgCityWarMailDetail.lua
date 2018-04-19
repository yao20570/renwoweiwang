----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:20:15
-- Description: 城战邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailDetailGetItems = require("app.layer.mail.MailDetailGetItems")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local CCWarMailBattle = require("app.layer.mail.CCWarMailBattle")
local MailFunc = require("app.layer.mail.MailFunc")
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
-- 城战邮件详细
local DlgCityWarMailDetail = class("DlgCityWarMailDetail", DlgMailDetail)
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")

local ScrollViewEx = require("app.common.listview.ScrollViewEx")

--tMailMsg 邮件数据
function DlgCityWarMailDetail:ctor( tMailMsg, pMsgObj )
	DlgCityWarMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	if pMsgObj then
		self.bShare = pMsgObj.bShare
	end
	self.eDlgType = e_dlg_index.maildetailcitywar
	parseView("dlg_city_war_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityWarMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:setContentView()


	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityWarMailDetail",handler(self, self.onDlgCityWarMailDetailDestroy))
end

-- 析构方法
function DlgCityWarMailDetail:onDlgCityWarMailDetailDestroy(  )
    self:onPause()
end

function DlgCityWarMailDetail:regMsgs(  )
	DlgCityWarMailDetail.super.regMsgs(self)
end

function DlgCityWarMailDetail:unregMsgs(  )
	DlgCityWarMailDetail.super.unregMsgs(self)
end

function DlgCityWarMailDetail:onResume(  )
	self:regMsgs()
end

function DlgCityWarMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgCityWarMailDetail:setupViews(  )
	

	--按钮
	self.pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(self.pLayBtnFind)

	self.pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setReplayBtn(self.pLayBtnSave)

	self.pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(self.pLayBtnDel)

	self.pLayBtnChat = self:findViewByName("lay_btn_chat")
	self:setPrivateChatBtn(self.pLayBtnChat)


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

end

function DlgCityWarMailDetail:setContentView(  )
	-- body
	--攻战胜利（攻方是显示胜利，防守方显示失败，显示攻方收获）
	--防守失败（攻方是显示胜利，防守方显示失败，显示防守方损失）
	--攻战失败（攻方是显示失败，防守方显示胜利，不显示收获或损失）
	--防守胜利（攻方是显示失败，防守方显示胜利，不显示收获或损失）
	local bIsAtkWin = nil
	local bIsDefLose = nil
	local bIsAtkLose = nil
	local bIsDefWin = nil
	local tMailReport = getMailReport(self.tMailMsg.nId)
	if tMailReport then
		if tMailReport.id == 1 then
			bIsAtkWin = true
		elseif tMailReport.id == 2 then
			bIsDefLose = true
		elseif tMailReport.id == 3 then
			bIsAtkLose = true
		elseif tMailReport.id == 4 then
			bIsDefWin = true
		end
	end

	--banner图

	local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
	if tMailReport and tMailReport.banner then
		--基本信息
		local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
		local pBanner=MUI.MImage.new("ui/big_img_sep/"..tMailReport.banner..".jpg") 
		pLayInfo:setContentSize(pBanner:getWidth(),pBanner:getHeight())
		pBanner:setAnchorPoint(0,0)
		pLayInfo:addView(pBanner)
		self.pSv:addScrollViewChild(pLayInfo)
	end

	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	if not self.pMultiText then
		self.pMultiText = MUI.MLabel.new({
			text = "",
			size = 20,
			align = cc.ui.TEXT_ALIGN_LEFT,
			valign = cc.ui.TEXT_VALIGN_TOP,
			dimensions = cc.size(380, 0),
			})
		pLayInfo:addView(self.pMultiText, 10)
		self.pMultiText:setAnchorPoint(cc.p(0, 1))
		self.pMultiText:setPosition(12, 105)
	end
	local pStr = {}
	for k, v in pairs(tStr) do
		if v.text ~= "" then
			table.insert(pStr, {text = v.text, color = getC3B(v.color)})
		end
	end

	--城战横条
	local tItemList = nil
	if bIsAtkWin or bIsAtkLose then
		tInfo={
			{sStr=getConvertedStr(9,10011),nFontSize=18,sColor=_cc.pwhite},
			{sStr=sStr,nFontSize=20,sColor=_cc.pwhite},
			{sStr=getConvertedStr(9,10014),nFontSize=18,sColor=_cc.pwhite},
		}
		if self.tMailMsg.tItemList then
			tItemList = self.tMailMsg.tItemList
		end
	elseif bIsDefLose or bIsDefWin then
		tInfo={
			{sStr=getConvertedStr(9,10015),nFontSize=18,sColor=_cc.pwhite},
			{sStr=sStr,nFontSize=20,sColor=_cc.pwhite},
			{sStr=getConvertedStr(9,10016),nFontSize=18,sColor=_cc.pwhite},
		}
		if self.tMailMsg.tLoseItemList then
			tItemList = self.tMailMsg.tLoseItemList
		end
	end

	--我的攻击信息
	-- local tInfo=MailFunc.getAtkInfo(self.tMailMsg)
	local sStr1=MailFunc.getContentTextColor(self.tMailMsg)
	local pAtkInfo=ItemMailBattleInfoBanner.new(sStr1)
	-- local nHeight=self.pSv:getCurContentHeight()
	self.pSv.nHeight=self.pSv.nHeight+120
	self.pSv:addScrollViewChild(pAtkInfo)

	self.pSv.nHeight=self.pSv.nHeight-10
	--时间分享层
	--时间
	local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg, self.bShare)
	local pLayShareBtn=pTimeAndShare:getLayShareBtn()
	local pLaySaveBtn=pTimeAndShare:getLaySaveBtn()
	self:setSaveBtn(pLaySaveBtn)
	self:setShareBtn(pLayShareBtn)
	pTimeAndShare:scaleBtn(pLayShareBtn,self.pBtnShare)
	pTimeAndShare:scaleBtn(pLaySaveBtn,self.pBtnSave)
	
	self.pSv:addScrollViewChild(pTimeAndShare)

	
	--回放层
	local pReplayView   = ItemCCWarMailBattle.new() 
	pReplayView:setData(self.tMailMsg, 1)
	pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
	-- addContentChild(pReplayView)
	self.pSv:addScrollViewChild(pReplayView)

	if tItemList and bIsAtkWin or bIsDefLose then
		--邮件详细横条
		local sRewardInfo = ""
		if bIsAtkWin then
			local sExLabel = Player:getMailData():getAwardExtraStr(self.tMailMsg)
			local sStr = string.format(getConvertedStr(9, 10013), getCountryShortName(self.tMailMsg.nAtkCountry, true), self.tMailMsg.sAtkName, getLvString(self.tMailMsg.nAtkLv))
			sRewardInfo = {
				{text = sStr..getConvertedStr(9,10019), color = _cc.white},
				{text = sExLabel, color = _cc.green},
			}
		else
			local sStr = string.format(getConvertedStr(9, 10013), getCountryShortName(self.tMailMsg.nDefCountry, true), self.tMailMsg.sDefName, getLvString(self.tMailMsg.nDefLv))
			sRewardInfo=sStr..getConvertedStr(9,10023)
		end
		local pMailDetailBanner = ItemMailRewardBanner.new(sRewardInfo)
		self.pSv:addScrollViewChild(pMailDetailBanner)

		local nIndex=1
		local tTempItem1={}
		local tTempItem2={}
		--按品质排序
		-- table.sort(tItemList,function(a,b )
	 --    -- body
	 --        local tGoodA=getGoodsByTidFromDB(a.k)
	 --        local tGoodB=getGoodsByTidFromDB(b.k)
	 --        if tGoodA and tGoodB then
	 --            return tGoodA.nQuality>tGoodB.nQuality
	 --        end
	 --    end )
		
		if #tItemList >5 then
			for i=1,5 do
				table.insert(tTempItem1,tItemList[i])
				nIndex=nIndex+1
			end
			for i=nIndex,#tItemList do
				table.insert(tTempItem2,tItemList[i])
			end
		else
			for i=1,#tItemList do
				table.insert(tTempItem1,tItemList[i])
				nIndex=nIndex+1
			end
		end
		--邮件详情领取奖励
		self.pSv.nHeight=self.pSv.nHeight-15

		-- nHeight=nHeight-29
		local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1)
		self.pSv:addScrollViewChild(pMailDetailGetItems1)

		if #tTempItem2 >0 then
			self.pSv.nHeight=self.pSv.nHeight-10
			-- nHeight=nHeight-15
			local pMailDetailGetItems2 = MailDetailGetItems.new(tTempItem2)
			self.pSv:addScrollViewChild(pMailDetailGetItems2)

		end
		self.pSv.nHeight=self.pSv.nHeight-15

		-- nHeight=nHeight-29

	end


	--攻防横条
	local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()
	-- addContentChild(pMailDetailAtkDefBanner)
	self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)

	--攻防战役
	-- self.tMailMsg.tAtkHeros={}
	-- self.tMailMsg.tDefHeros={}
	--先设置内容层的高度
	-- local temp={}
	-- table.insert(temp,self.tMailMsg.tAtkHeros[1])
	-- table.insert(temp,self.tMailMsg.tAtkHeros[2])
	-- self.tMailMsg.tAtkHeros=temp
	-- local temp2={}
	-- for i=1, 10 do 
	-- 	table.insert(self.tMailMsg.tAtkHeros,self.tMailMsg.tAtkHeros[1])
	-- end
	-- for i=1, 10 do 
	-- 	table.insert(self.tMailMsg.tAtkHeros,self.tMailMsg.tAtkHeros[2])
	-- end
	-- table.insert(self.tMailMsg.tAtkHeros,self.tMailMsg.tAtkHeros[2])
	local nAtkHeroCount =#self.tMailMsg.tAtkHeros-1
    local nDefHeroCount = #self.tMailMsg.tDefHeros-1
    local nCount = math.max(nAtkHeroCount, nDefHeroCount) +1
    if nCount<=0 then
    	nCount=1
    end
    self.pBattleList=MUI.MLayer.new()
    self.pBattleList:setContentSize(pReplayView:getWidth(), pReplayView:getHeight() * nCount)
    -- addContentChild(self.pBattleList)
	self.pSv:addScrollViewChild(self.pBattleList)

    self.pSv:setListView(self.pBattleList,pReplayView:getWidth(),pReplayView:getHeight(),handler(self,self.moveContentCallback),pReplayView:getHeight())
    self.pSv:setListViewNum(self.pBattleList,nCount)

    self.pSv:refreshListViews()
    self.pSv:resetContentSize()
    self:showReplayBtn()

end
function DlgCityWarMailDetail:showReplayBtn(  )
	-- body
	--无产生战斗时不显示播放按钮
	if (not self.tMailMsg.tAtkHeros or not self.tMailMsg.tDefHeros or #self.tMailMsg.tAtkHeros<=0 or #self.tMailMsg.tDefHeros<=0) then
		self.pBtnReplay:setVisible(false)
		self.pLayBtnSave:setVisible(false)
		self.pLayBtnFind:setPositionX(0)
		self.pLayBtnChat:setPositionX(221)
		self.pLayBtnDel:setPositionX(442)
	end
end

function DlgCityWarMailDetail:addBattleItem( )
	-- body

end

function DlgCityWarMailDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemCCWarMailBattle.new() 
	end
	pTempView:setData(self.tMailMsg, _nIndex+1)
	return pTempView


end

function DlgCityWarMailDetail:updateViews(  )
end

return DlgCityWarMailDetail