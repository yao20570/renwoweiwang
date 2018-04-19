----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 矿点邮件详细
-----------------------------------------------------
local MailDetailSendTime = require("app.layer.mail.MailDetailSendTime")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
local CCWarMailBattle = require("app.layer.mail.CCWarMailBattle")
local MailFunc = require("app.layer.mail.MailFunc")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")


-- 矿点邮件详细
local DlgMailDetail = require("app.layer.mail.DlgMailDetail")
local DlgMinesMailDetail = class("DlgMinesMailDetail", DlgMailDetail)

--tMailMsg 邮件数据
function DlgMinesMailDetail:ctor( tMailMsg, pMsgObj)
	DlgMinesMailDetail.super.ctor(self, tMailMsg, pMsgObj)
	if pMsgObj then
		self.bShare = pMsgObj.bShare
	end
	self.eDlgType = e_dlg_index.maildetailmine
	parseView("dlg_mines_mail_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgMinesMailDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:setContentView()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgMinesMailDetail",handler(self, self.onDlgMinesMailDetailDestroy))
end

-- 析构方法
function DlgMinesMailDetail:onDlgMinesMailDetailDestroy(  )
    self:onPause()
end

function DlgMinesMailDetail:regMsgs(  )
	DlgMinesMailDetail.super.regMsgs(self)
end

function DlgMinesMailDetail:unregMsgs(  )
	DlgMinesMailDetail.super.unregMsgs(self)
end

function DlgMinesMailDetail:onResume(  )
	self:regMsgs()
end

function DlgMinesMailDetail:onPause(  )
	self:unregMsgs()
end

function DlgMinesMailDetail:setupViews(  )
	--按钮
	local pLayBtnFind = self:findViewByName("lay_btn_find")
	self:setFindBtn(pLayBtnFind)

	local pLayBtnSave = self:findViewByName("lay_btn_save")
	self:setReplayBtn(pLayBtnSave)

	local pLayBtnChat = self:findViewByName("lay_btn_chat")
	self:setPrivateChatBtn(pLayBtnChat)

	local pLayBtnDel = self:findViewByName("lay_btn_del")
	self:setDelBtn(pLayBtnDel)

	--图标
	local pLayIcon = self:findViewByName("lay_icon")
	self:setIcon(pLayIcon)

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

	
end
function DlgMinesMailDetail:setContentView(  )
	-- -- body
	-- local pSize = pLayBg:getContentSize()
	-- local nWidht, nHeight = pSize.width, pSize.height
	--banner图

	local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
	local tMailReport = getMailReport(self.tMailMsg.nId)
	if tMailReport and tMailReport.banner then
		--基本信息
		local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
		local pBanner=MUI.MImage.new("ui/big_img_sep/"..tMailReport.banner..".jpg") 
		pLayInfo:setContentSize(pBanner:getWidth(),pBanner:getHeight())
		pBanner:setAnchorPoint(0,0)
		pLayInfo:addView(pBanner)
		self.pSv:addScrollViewChild(pLayInfo)
	end

	-- self.pLayInfoBg=self:findViewByName("lay_info")
	-- local tMailReport = getMailReport(self.tMailMsg.nId)
	-- if tMailReport and tMailReport.banner then
	-- 	self.pLayInfoBg:setBackgroundImage("#"..tMailReport.banner..".jpg")
	-- end

	-- --加入内容子节点
	-- local function addContentChild( pNode )
	-- 	nHeight = nHeight - pNode:getContentSize().height
	-- 	pNode:setPosition(0, nHeight)
	-- 	pLayBg:addView(pNode)
	-- end


	--基本信息
	-- local pLayInfo = self:findViewByName("lay_info")
	--我的攻击信息
	local tInfo=MailFunc.getContentTextColor(self.tMailMsg)
	local pAtkInfo=ItemMailBattleInfoBanner.new(tInfo)
	self.pSv.nHeight=self.pSv.nHeight+120

	-- nHeight=nHeight-pLayInfo:getContentSize().height+120
	-- addContentChild(pAtkInfo)
	self.pSv:addScrollViewChild(pAtkInfo)

	self.pSv.nHeight=self.pSv.nHeight-10

	-- nHeight=nHeight-10
	--时间分享层
	-- local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg,handler(self,self.onShareClicked), self.bShare)
	local pTimeAndShare=addMailSendAndShareBanner(self.tMailMsg, self.bShare)
	local pLayShareBtn=pTimeAndShare:getLayShareBtn()
	local pLaySaveBtn=pTimeAndShare:getLaySaveBtn()
	self:setSaveBtn(pLaySaveBtn)
	self:setShareBtn(pLayShareBtn)
	pTimeAndShare:scaleBtn(pLayShareBtn,self.pBtnShare)
	pTimeAndShare:scaleBtn(pLaySaveBtn,self.pBtnSave)
	
	-- addContentChild(pTimeAndShare)
	self.pSv:addScrollViewChild(pTimeAndShare)

	-- nHeight = nHeight -  pAtkInfo:getHeight()-- pLayInfo:getContentSize().height+80
	-- local pLayRichtextInfo = self:findViewByName("lay_richtext_info")
	-- local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	-- getRichLabelOfContainer(pLayRichtextInfo,tStr, nil, pLayRichtextInfo:getContentSize().width)

	--攻防战役
	if self.tMailMsg.tAtkHeros and self.tMailMsg.tDefHeros then
		--攻防战役 回放部分
		local pReplayView   = ItemCCWarMailBattle.new() 
		pReplayView:setData(self.tMailMsg, 1)
		pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
		-- addContentChild(pReplayView)
		self.pSv:addScrollViewChild(pReplayView)

		--攻防横条
		local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()
		-- addContentChild(pMailDetailAtkDefBanner)
		self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)

		--攻防战役列表
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

		-- local pCCWarMailBattle = CCWarMailBattle.new(cc.size(nWidht, nHeight), self.tMailMsg)
		-- addContentChild(pCCWarMailBattle)
		-- self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)
	end
end

function DlgMinesMailDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemCCWarMailBattle.new() 
	end
	pTempView:setData(self.tMailMsg, _nIndex+1)
	return pTempView


end

function DlgMinesMailDetail:updateViews(  )
end


return DlgMinesMailDetail