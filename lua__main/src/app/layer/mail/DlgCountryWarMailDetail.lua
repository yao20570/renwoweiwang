----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 11:50:07
-- Description: 国战邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailDetailBanner = require("app.layer.mail.MailDetailBanner")
local MailDetailGetItems = require("app.layer.mail.MailDetailGetItems")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local CCWarMailBattle = require("app.layer.mail.CCWarMailBattle")
local MailFunc = require("app.layer.mail.MailFunc")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")

local ScrollViewEx = require("app.common.listview.ScrollViewEx")

-- 国战邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgCountryWarMailDetail = class("DlgCountryWarMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgCountryWarMailDetail:ctor( tMailMsg, pMsgObj)
	DlgCountryWarMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	if pMsgObj then
		self.bShare = pMsgObj.bShare
	end
	self.eDlgType = e_dlg_index.maildetailcountrywar
	parseView("dlg_country_war_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCountryWarMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryWarMailDetail",handler(self, self.onDlgCountryWarMailDetailDestroy))
end

function DlgCountryWarMailDetail:onParseContentViewCallback( pView )
	-- body
	local pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLayBg:getWidth(), self.pLayBg:getHeight()),
		touchOnContent = false,
		direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
	pSv:setAnchorPoint(0,0)
	self.pLayBg:addView(pSv)

	self.pLayContent=pView

	pSv:addView(self.pLayContent)
	self.pLayContent:setPosition(0,0)
	-- self.pLayBg:addView(pView)
	-- self.pLayContent=pView
	self:setContentView()
	

end

-- 析构方法
function DlgCountryWarMailDetail:onDlgCountryWarMailDetailDestroy(  )
    self:onPause()
end

function DlgCountryWarMailDetail:regMsgs(  )
	DlgCountryWarMailDetail.super.regMsgs(self)
	--国战战斗列表请求
	regMsg(self, gud_mail_country_war_battle_req_msg, handler(self, self.onReqMailBattle))
end

function DlgCountryWarMailDetail:unregMsgs(  )
	DlgCountryWarMailDetail.super.unregMsgs(self)
	--国战战斗列表请求
	unregMsg(self, gud_mail_country_war_battle_req_msg)
end

function DlgCountryWarMailDetail:onResume(  )
	self:regMsgs()
end

function DlgCountryWarMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgCountryWarMailDetail:setupViews(  )
	--按钮
	local pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(pLayBtnFind)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setReplayBtn(pLayBtnSave)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	--图标
	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon, true)

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


	-- local pSize = pLayBg:getContentSize()
	-- local nWidht, nHeight = pSize.width, pSize.height
	-- self.nWidht = nWidht
	-- self.nHeight = nHeight
	-- self.pLayBg = pLayBg

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

	-- self.nHeight = self.nHeight - pLayInfo:getContentSize().height
	--我的攻击信息
	local tInfo=MailFunc.getContentTextColor(self.tMailMsg)
	local pAtkInfo=ItemMailBattleInfoBanner.new(tInfo)
	self.pSv.nHeight=self.pSv.nHeight+120
	-- self:addContentChild(pAtkInfo)
	self.pSv:addScrollViewChild(pAtkInfo)


	-- self.nHeight=self.nHeight-10
	self.pSv.nHeight=self.pSv.nHeight-10

	--时间分享层
	--时间
	-- local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg,handler(self,self.onShareClicked), self.bShare)
	local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg, self.bShare)
	local pLayShareBtn=pTimeAndShare:getLayShareBtn()
	local pLaySaveBtn=pTimeAndShare:getLaySaveBtn()
	self:setSaveBtn(pLaySaveBtn)
	self:setShareBtn(pLayShareBtn)
	pTimeAndShare:scaleBtn(pLayShareBtn,self.pBtnShare)
	pTimeAndShare:scaleBtn(pLaySaveBtn,self.pBtnSave)

	-- self:addContentChild(pTimeAndShare)
	self.pSv:addScrollViewChild(pTimeAndShare)

	--回放层
	self.pReplayView   = ItemCCWarMailBattle.new() 
	self.pReplayView:setData(self.tMailMsg, 1)
	self.pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
	-- self:addContentChild(self.pReplayView)
	self.pSv:addScrollViewChild(self.pReplayView)

	local sStr = string.format(getConvertedStr(3, 10212), getCountryShortName(Player:getPlayerInfo().nInfluence, true), tostring(self.tMailMsg.sReceiverName), getLvString(self.tMailMsg.nReceiverLv))
	if self.tMailMsg.tItemList and #self.tMailMsg.tItemList > 0 then
		local sExLabel = Player:getMailData():getAwardExtraStr(self.tMailMsg)
		local sRewardInfo = {
			{text = sStr, color = _cc.white},
			{text = sExLabel, color = _cc.green}
		}
		--邮件详细横条
		local pMailDetailBanner = ItemMailRewardBanner.new(sRewardInfo)
		self.pSv:addScrollViewChild(pMailDetailBanner)

		-- self:addContentChild(pMailDetailBanner)
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
			for i=1,#self.tMailMsg.tItemList do
				table.insert(tTempItem1,self.tMailMsg.tItemList[i])
				nIndex=nIndex+1
			end
		end
		--邮件详情领取奖励
		self.pSv.nHeight=self.pSv.nHeight-15

		-- self.nHeight=self.nHeight-29
		-- local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1,3)
		local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1,3)

		self.pSv:addScrollViewChild(pMailDetailGetItems1)
		-- self:addContentChild(pMailDetailGetItems1)
		if #tTempItem2 >0 then
			-- self.nHeight=self.nHeight-15
			self.pSv.nHeight=self.pSv.nHeight-10

			local pMailDetailGetItems2 = MailDetailGetItems.new(tTempItem2,3)
			self.pSv:addScrollViewChild(pMailDetailGetItems2)

			-- self:addContentChild(pMailDetailGetItems2)
		end
		self.pSv.nHeight=self.pSv.nHeight-15

		-- self.nHeight=self.nHeight-29
	elseif self.tMailMsg.nWin == 1 then  		--国战进攻胜利时 没获得奖励也要显示提示
		--邮件详情领取奖励
		self.pSv.nHeight=self.pSv.nHeight-15

		-- self.nHeight=self.nHeight-29
		-- local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1,3)
		local tTempItem1={}
		local pMailDetailGetItems1 = MailDetailGetItems.new(tTempItem1,3)

		self.pSv:addScrollViewChild(pMailDetailGetItems1)
		self.pSv.nHeight=self.pSv.nHeight-15

	end

	--从分享打开的邮件要请求数据 
	if self.bShare then
		SocketManager:sendMsg("reqMailBattle", {self.tMailMsg.sFightRid}, handler(self, self.onReqMailBattleInShare))
	else
		--是否存在已有的战斗列表数据
		local bIsReq = Player:getMailData():getIsReqCountryWarBattle(self.tMailMsg.sFightRid)
		if bIsReq then
			self:addCCWarMailBattle()
		else
			SocketManager:sendMsg("reqMailBattle", {self.tMailMsg.sFightRid})
		end
	end
end

function DlgCountryWarMailDetail:setContentView( )
	-- body

end

-- --加入内容子节点
-- function DlgCountryWarMailDetail:addContentChild( pNode )
-- 	self.nHeight = self.nHeight - pNode:getContentSize().height
-- 	pNode:setPosition(0, self.nHeight)
-- 	self.pLayBg:addView(pNode)
-- end

--添加国战战斗列表内容
function DlgCountryWarMailDetail:addCCWarMailBattle(  )
	--攻防横条(防止重复加载)
	if not self.pMailDetailAtkDefBanner then
		self.pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()
		self.pSv:addScrollViewChild(self.pMailDetailAtkDefBanner)

		-- self:addContentChild(self.pMailDetailAtkDefBanner)
	end

	--攻防战役(防止重复加载)
	if not self.pBattleList then
		local nAtkHeroCount = 0
		if self.tMailMsg.tAtkHeros then
			nAtkHeroCount = #self.tMailMsg.tAtkHeros-1
		end
	    local nDefHeroCount = 0
	    if self.tMailMsg.tDefHeros then
			nDefHeroCount = #self.tMailMsg.tDefHeros-1
		end
	    local nCount = math.max(nAtkHeroCount, nDefHeroCount) + 1
	    if nCount<=0 then
	    	nCount=1
	    end
	    self.pBattleList=MUI.MLayer.new()
	    self.pBattleList:setContentSize(self.pReplayView:getWidth(), self.pReplayView:getHeight() * nCount)
	    -- addContentChild(self.pBattleList)
		self.pSv:addScrollViewChild(self.pBattleList)

	    self.pSv:setListView(self.pBattleList,self.pReplayView:getWidth(),self.pReplayView:getHeight(),handler(self,self.moveContentCallback),self.pReplayView:getHeight())
	    self.pSv:setListViewNum(self.pBattleList,nCount)

	    self.pSv:refreshListViews()
	    self.pSv:resetContentSize()

		-- self.pCCWarMailBattle = CCWarMailBattle.new(cc.size(self.nWidht, self.nHeight), self.tMailMsg)
		-- self:addContentChild(self.pCCWarMailBattle)

		if (not self.tMailMsg.tAtkHeros or not self.tMailMsg.tDefHeros or #self.tMailMsg.tAtkHeros<=0 or #self.tMailMsg.tDefHeros<=0)then
			self.pReplayView:hideReplayBtn()
			self.pBtnReplay:setVisible(false)
		else
			self.pReplayView:showReplayBtn()
			self.pBtnReplay:setVisible(true)

		end
	end
end

function DlgCountryWarMailDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemCCWarMailBattle.new() 
	end
	pTempView:setData(self.tMailMsg, _nIndex+1)
	return pTempView


end

--国战战斗列表请求
function DlgCountryWarMailDetail:onReqMailBattle(  )
	--刷新信息
	local tMailMsg = Player:getMailData():getMailMsg(self.tMailMsg.sPid, self.tMailMsg.nCategory)
	if tMailMsg then
		self.tMailMsg = tMailMsg
		self:addCCWarMailBattle()
	end
end
	
--国战战斗列表请求分享
function DlgCountryWarMailDetail:onReqMailBattleInShare( __msg )
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailBattle.id then
			Player:getMailData():setCountryWarBattleInMail(self.tMailMsg, __msg.body)
			self:addCCWarMailBattle()
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

function DlgCountryWarMailDetail:updateViews(  )
end

return DlgCountryWarMailDetail