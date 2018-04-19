----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:50:07
-- Description: 乱军邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailDetailGetItems = require("app.layer.mail.MailDetailGetItems")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local CCWarMailBattle = require("app.layer.mail.CCWarMailBattle")
local MailFunc = require("app.layer.mail.MailFunc")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")


-- 乱军邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgWildArmyMailDetail = class("DlgWildArmyMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgWildArmyMailDetail:ctor( tMailMsg, pMsgObj)
	DlgWildArmyMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	if pMsgObj then
		self.bShare = pMsgObj.bShare
	end
	self.eDlgType = e_dlg_index.maildetailwildarmy
	parseView("dlg_wild_army_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWildArmyMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:setContentView()
	self:updateViews()
	self:onResume()


	--注册析构方法
	self:setDestroyHandler("DlgWildArmyMailDetail",handler(self, self.onDlgWildArmyMailDetailDestroy))
end

-- 析构方法
function DlgWildArmyMailDetail:onDlgWildArmyMailDetailDestroy(  )
    self:onPause()
end

function DlgWildArmyMailDetail:regMsgs(  )
	DlgWildArmyMailDetail.super.regMsgs(self)
end

function DlgWildArmyMailDetail:unregMsgs(  )
	DlgWildArmyMailDetail.super.unregMsgs(self)
end

function DlgWildArmyMailDetail:onResume(  )
	self:regMsgs()
end

function DlgWildArmyMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgWildArmyMailDetail:setupViews(  )
	--按钮
	local pLayBtnShare = self:findViewByName("lay_btn_share")
	self:setReplayBtn(pLayBtnShare)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setDelBtn(pLayBtnSave)

	-- local pLayBtnDel = self:findViewByName("lay_btn_del")
	-- self:setDelBtn(pLayBtnDel)
	local pLayBtnReplay = self:findViewByName("lay_btn_replay")
	self:setFindBtn(pLayBtnReplay)

	--图标
	-- local pLayIcon = self:findViewByName("lay_icon")
	-- self:setIcon(pLayIcon)

	--背景
	self.pLayBg = self:findViewByName("lay_bg")

	self.pSv = ScrollViewEx.new( self.pLayBg:getWidth(), self.pLayBg:getHeight())
	self.pSv:setAnchorPoint(0,0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pSv:setUpAndDownArrow(pUpArrow, pDownArrow)		
	self.pLayBg:addView(self.pSv)

	self.pLayContent=MUI.MLayer.new()
    self.pLayContent:setContentSize(self.pLayBg:getWidth(), self.pLayBg:getHeight())

	self.pSv:addView(self.pLayContent)
	self.pLayContent:setPosition(0,0)

	self.pSv:setScrollViewContent(self.pLayContent)
	self:showReplayBtn()
end

function DlgWildArmyMailDetail:showReplayBtn(  )
	-- body
	--无产生战斗时不显示播放按钮
	if (not self.tMailMsg.tAtkHeros or not self.tMailMsg.tDefHeros or #self.tMailMsg.tAtkHeros<=0 or #self.tMailMsg.tDefHeros<=0) then
		self.pBtnReplay:setVisible(false)
	end
end

function DlgWildArmyMailDetail:setContentView(  )
	-- body
	-- local pSize = self.pLayContent:getContentSize()
	-- local nWidht, nHeight = pSize.width, pSize.height
	-- --加入内容子节点
	-- local function addContentChild( pNode )
	-- 	nHeight = nHeight - pNode:getContentSize().height
	-- 	pNode:setPosition(0, nHeight)
	-- 	self.pLayContent:addView(pNode)
	-- end
	-- dump(self.tMailMsg,"tMailMsg")

	-- --基本信息
	-- local pLayInfo = self.pLayContent:findViewByName("lay_info")
	--banner图
	local tMailReport = getMailReport(self.tMailMsg.nId)
	
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

	-- local tMailReport = getMailReport(self.tMailMsg.nId)
	-- if tMailReport and tMailReport.banner then
	-- 	pLayInfo:setBackgroundImage("#"..tMailReport.banner..".jpg")
	-- end

	-- nHeight = nHeight - pLayInfo:getContentSize().height
	
	local tInfo=MailFunc.getContentTextColor(self.tMailMsg)
	local pAtkInfo=ItemMailBattleInfoBanner.new(tInfo)
	self.pSv.nHeight=self.pSv.nHeight+120
	self.pSv:addScrollViewChild(pAtkInfo)
	-- nHeight=nHeight+120
	-- addContentChild(pAtkInfo)
	self.pSv.nHeight=self.pSv.nHeight-10

	-- nHeight=nHeight-10
	--时间分享层
	local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg, self.bShare)
	local pLayShareBtn=pTimeAndShare:getLayShareBtn()
	local pLaySaveBtn=pTimeAndShare:getLaySaveBtn()
	self:setSaveBtn(pLaySaveBtn)
	self:setShareBtn(pLayShareBtn)
	pTimeAndShare:scaleBtn(pLayShareBtn,self.pBtnShare)
	pTimeAndShare:scaleBtn(pLaySaveBtn,self.pBtnSave)

	-- addContentChild(pTimeAndShare)
	self.pSv:addScrollViewChild(pTimeAndShare)
	--回放层
	local pReplayView   = ItemCCWarMailBattle.new() 
	pReplayView:setData(self.tMailMsg, 1)
	pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
	-- addContentChild(pReplayView)
	self.pSv:addScrollViewChild(pReplayView)


	--有物品奖励时才显示
	if self.tMailMsg.tItemList and #self.tMailMsg.tItemList > 0 then
		local sExLabel = Player:getMailData():getAwardExtraStr(self.tMailMsg)
		local sStr = string.format(getConvertedStr(3,10212),getCountryShortName(Player.getPlayerInfo().nInfluence, true),Player.getPlayerInfo().sName,getLvString(Player.getPlayerInfo().nLv))
		local sRewardInfo = {
			{text = sStr, color = _cc.white},
			{text = sExLabel, color = _cc.green}
		}
		--城战横条
		local pMailDetailBanner = ItemMailRewardBanner.new(sRewardInfo)
		-- addContentChild(pMailDetailBanner)
		self.pSv:addScrollViewChild(pMailDetailBanner)

		--邮件详情领取奖励
		local nIndex=1
		local tTempItem1={}
		local tTempItem2={}
		--按品质排序
		-- table.sort(self.tMailMsg.tItemList,function(a,b )
	 --    -- body
	 --        local tGoodA=getGoodsByTidFromDB(a.k)
	 --        local tGoodB=getGoodsByTidFromDB(b.k)
	 --        if tGoodA and tGoodB then
	 --            return tGoodA.nQuality>tGoodB.nQuality
	 --        end
	 --    end )
	    -- dump(self.tMailMsg.tItemList,"itemlist--")
		--邮件详情领取奖励
		if #self.tMailMsg.tItemList >5 then
			for i=1,5 do
				table.insert(tTempItem1,self.tMailMsg.tItemList[i])
				nIndex=nIndex+1
			end
			for i=nIndex,#self.tMailMsg.tItemList do
				table.insert(tTempItem2,self.tMailMsg.tItemList[i])
			end
		else
			for i=1, #self.tMailMsg.tItemList do
				table.insert(tTempItem1,self.tMailMsg.tItemList[i])
			end
		end

		--邮件详情领取奖励
		self.pSv.nHeight=self.pSv.nHeight-15
		
		local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1)
		self.pSv:addScrollViewChild(pMailDetailGetItems1)

		-- addContentChild(pMailDetailGetItems1)
		if #tTempItem2 >0 then
			self.pSv.nHeight=self.pSv.nHeight-10
			
			local pMailDetailGetItems2 = MailDetailGetItems.new(tTempItem2)
			-- addContentChild(pMailDetailGetItems2)
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

	local nAtkHeroCount = #self.tMailMsg.tAtkHeros-1
    local nDefHeroCount = #self.tMailMsg.tDefHeros-1
    local nCount = math.max(nAtkHeroCount, nDefHeroCount) + 1
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

	-- local pBattleList=getMailBattleList(self.tMailMsg,self.pLayContent:getWidth())
	-- addContentChild(pBattleList)

	-- local pCCWarMailBattle = CCWarMailBattle.new(cc.size(nWidht, nHeight), self.tMailMsg)
	-- addContentChild(pCCWarMailBattle)

end

function DlgWildArmyMailDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemCCWarMailBattle.new() 
	end
	pTempView:setData(self.tMailMsg, _nIndex+1)
	return pTempView


end

function DlgWildArmyMailDetail:updateViews(  )
end

return DlgWildArmyMailDetail