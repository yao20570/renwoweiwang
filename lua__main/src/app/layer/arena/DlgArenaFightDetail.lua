
----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-1-23 14:46:15
-- Description: 竞技场战报详情
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local ItemArenaBattlers = require("app.layer.arena.ItemArenaBattlers")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")

local ScrollViewEx = require("app.common.listview.ScrollViewEx")

--tFightDetail 竞技场战斗数据
local DlgArenaFightDetail = class("DlgArenaFightDetail", function()
	return DlgBase.new(e_dlg_index.arenafightdetail)
end)

function DlgArenaFightDetail:ctor( tFightDetail, _bShare )	
	self.bShare = _bShare or false
	self.tFightDetail = tFightDetail
	parseView("dlg_arena_fight_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgArenaFightDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:setContentView()

	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgArenaFightDetail",handler(self, self.onDlgArenaFightDetailDestroy))
end

-- 析构方法
function DlgArenaFightDetail:onDlgArenaFightDetailDestroy(  )
    self:onPause()
end

function DlgArenaFightDetail:regMsgs(  )
	--DlgArenaFightDetail.super.regMsgs(self)
end

function DlgArenaFightDetail:unregMsgs(  )
	--DlgArenaFightDetail.super.unregMsgs(self)
end

function DlgArenaFightDetail:onResume(  )
	self:regMsgs()
end

function DlgArenaFightDetail:onPause(  )
	self:unregMsgs()
end

function DlgArenaFightDetail:setupViews(  )
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

function DlgArenaFightDetail:setContentView(  )
	-- body
	--攻战胜利（攻方是显示胜利，防守方显示失败，显示攻方收获）
	--防守失败（攻方是显示胜利，防守方显示失败，显示防守方损失）
	--攻战失败（攻方是显示失败，防守方显示胜利，不显示收获或损失）
	--防守胜利（攻方是显示失败，防守方显示胜利，不显示收获或损失）
	local bIsAtkWin = nil
	local bIsDefLose = nil
	local bIsAtkLose = nil
	local bIsDefWin = nil

	--dump(self.tFightDetail, "self.tFightDetail", 100)
	local nTYpe = self.tFightDetail:getReportType()
	if nTYpe == 1  then
		bIsAtkWin = true
	elseif nTYpe == 2  then
		bIsDefLose = true
	elseif nTYpe == 3  then
		bIsAtkLose = true
	elseif nTYpe == 4  then
		bIsDefWin = true
	end

	self:setTitle(getConvertedStr(6, 10711 + nTYpe))

	--banner图
	local sBannerPath = nil
	if bIsAtkWin or bIsDefWin then
		sBannerPath = "ui/big_img_sep/v2_bg_shenglijiesuan.jpg"
	else
		sBannerPath = "ui/big_img_sep/v2_bg_shibaijiesuan.jpg"
	end
	local pLayInfo =MUI.MLayer.new()		-- MUI.MLayer.new() 		-- self.pLayContent:findViewByName("lay_info")
	if self.tFightDetail and sBannerPath then
		--基本信息		
		local pBanner=MUI.MImage.new(sBannerPath) 
		pLayInfo:setContentSize(pBanner:getWidth(),pBanner:getHeight())
		pBanner:setAnchorPoint(0,0)
		pLayInfo:addView(pBanner)
		self.pSv:addScrollViewChild(pLayInfo)
	end

	local sStrTitle = ""
	local tOtherPlayer = self.tFightDetail:getOtherPlayerInfo()
	if self.tFightDetail:isAttacker() and tOtherPlayer then--进攻方
		sStrTitle = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10716)},
			{color=_cc.white,text=tOtherPlayer:getFightTitle()},
		}
	else 									--防守方
		sStrTitle = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10717)},
			{color=_cc.white,text=tOtherPlayer:getFightTitle()},
			{color=_cc.pwhite,text=getConvertedStr(6, 10684)}
		}
	end
	-- --我的攻击信息
	local pAtkInfo=ItemMailBattleInfoBanner.new(sStrTitle)
	self.pSv.nHeight=self.pSv.nHeight+120
	self.pSv:addScrollViewChild(pAtkInfo)

	self.pSv.nHeight=self.pSv.nHeight-10
	--时间分享层
	--时间	
	local sTime={{sStr=formatTime(self.tFightDetail.nOt),nFontSize=18,sColor=_cc.pwhite}}
	local pTimeAndShare=addFightTimeAndShareBanner(sTime, self.bShare)
	local pLayShareBtn=pTimeAndShare:getLayShareBtn()
	self.pBtnShare = getCommonButtonOfContainer(pLayShareBtn, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10003),false)
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(pLayShareBtn, self.pBtnShare, 0.6)

	self.pSv:addScrollViewChild(pTimeAndShare)

	
	-- --回放层
	local pReplayView   = ItemArenaBattlers.new() 
	pReplayView:setData(self.tFightDetail, 1)
	pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
	-- addContentChild(pReplayView)
	self.pSv:addScrollViewChild(pReplayView)

	--攻防横条
	local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()	
	self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)

	--武将
	local nAtkHeroCount =#self.tFightDetail.tAf-1
    local nDefHeroCount = #self.tFightDetail.tDf-1
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

end

function DlgArenaFightDetail:addBattleItem( )
	-- body

end

function DlgArenaFightDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemArenaBattlers.new() 
	end
	pTempView:setData(self.tFightDetail, _nIndex + 1)
	return pTempView
end

function DlgArenaFightDetail:onShareClicked( pView )
	-- body
	print("分享")
	local nTYpe = self.tFightDetail:getReportType()
	local nShareId = e_share_id.arena_aw
	if nTYpe == 1  then
		nShareId = e_share_id.arena_aw
	elseif nTYpe == 2  then
		bIsDefLose = true
		nShareId = e_share_id.arena_dl
	elseif nTYpe == 3  then
		bIsAtkLose = true
		nShareId = e_share_id.arena_al
	elseif nTYpe == 4  then
		bIsDefWin = true
		nShareId = e_share_id.arena_dw
	end
	openShare(pView, nShareId, self.tFightDetail:getShareData(), self.tFightDetail.nReportId)
end

function DlgArenaFightDetail:onReplayClicked(  )
	-- body
	if self.tFightDetail then
		SocketManager:sendMsg("reqMailFightReplay", {self.tFightDetail.nReportId})
	end
end

function DlgArenaFightDetail:updateViews(  )
end

return DlgArenaFightDetail