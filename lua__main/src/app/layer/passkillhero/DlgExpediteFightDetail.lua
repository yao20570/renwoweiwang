
----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-3-19 18:17:15
-- Description: 过关斩将战报详情
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local ItemArenaBattlers = require("app.layer.arena.ItemArenaBattlers")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemMailRewardBanner = require("app.layer.mail.ItemMailRewardBanner")

local ScrollViewEx = require("app.common.listview.ScrollViewEx")

--tFightDetail 过关斩将战斗数据
local DlgExpediteFightDetail = class("DlgExpediteFightDetail", function()
	return DlgBase.new(e_dlg_index.expeditefightdetail)
end)

function DlgExpediteFightDetail:ctor( tFightDetail, _bShare )	
	self.bShare = _bShare or false
	self.tFightDetail = tFightDetail
	parseView("dlg_arena_fight_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgExpediteFightDetail:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:setContentView()

	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgExpediteFightDetail",handler(self, self.onDlgExpediteFightDetailDestroy))
end

-- 析构方法
function DlgExpediteFightDetail:onDlgExpediteFightDetailDestroy(  )
    self:onPause()
end

function DlgExpediteFightDetail:regMsgs(  )
end

function DlgExpediteFightDetail:unregMsgs(  )
end

function DlgExpediteFightDetail:onResume(  )
	self:regMsgs()
end

function DlgExpediteFightDetail:onPause(  )
	self:unregMsgs()
end

function DlgExpediteFightDetail:setupViews(  )
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

	--底部按钮
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_BLUE,getConvertedStr(3,10240))
	self.pBtn:onCommonBtnClicked(handler(self, self.onReplayClicked))

end

function DlgExpediteFightDetail:setContentView(  )
	-- body
	--攻战胜利（攻方是显示胜利，防守方显示失败，显示攻方收获）
	--攻战失败（攻方是显示失败，防守方显示胜利，不显示收获或损失）
	local bIsAtkWin = nil
	local bIsAtkLose = nil
	local nTYpe = 1
	if self.tFightDetail.nWin == 1 then --胜利
		bIsAtkWin = true
		nTYpe = 1
	else
		bIsAtkLose = true
		nTYpe = 2
	end

	self:setTitle(getConvertedStr(7, 10392 + nTYpe))

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
	-- local tData = Player:getPassKillHeroData()
	local tDefInfo = self.tFightDetail:getDefInfo()
	if tDefInfo then
		sStrTitle = {
			{text = getConvertedStr(7, 10395), color = _cc.pwhite},
			{text = self.tFightDetail.nOid, color = _cc.blue},
			{text = getConvertedStr(7, 10396), color = _cc.pwhite},
			{text = tDefInfo.sName..getLvString(tDefInfo.nLv), color = _cc.blue}
		}
	end
	self.tDefInfo = tDefInfo
	--我的攻击信息
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

	
	--回放层
	local pReplayView   = ItemArenaBattlers.new() 
	local bIconTouch = false
	pReplayView:setData(self.tFightDetail, 1, bIconTouch)
	pReplayView:setReplayHandler(handler(self,self.onReplayClicked))
	self.pSv:addScrollViewChild(pReplayView)

	--攻防横条
	local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()	
	self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)

	--武将
	local nAtkHeroCount = #self.tFightDetail.tAf-1
    local nDefHeroCount = #self.tFightDetail.tDf-1
    local nCount = math.max(nAtkHeroCount, nDefHeroCount) +1
    if nCount<=0 then
    	nCount=1
    end
    self.pBattleList=MUI.MLayer.new()
    self.pBattleList:setContentSize(pReplayView:getWidth(), pReplayView:getHeight() * nCount)
	self.pSv:addScrollViewChild(self.pBattleList)

    self.pSv:setListView(self.pBattleList,pReplayView:getWidth(),pReplayView:getHeight(),handler(self,self.moveContentCallback),pReplayView:getHeight())
    self.pSv:setListViewNum(self.pBattleList,nCount)

    self.pSv:refreshListViews()
    self.pSv:resetContentSize()

end

function DlgExpediteFightDetail:addBattleItem( )
	-- body

end

function DlgExpediteFightDetail:moveContentCallback( _pView,_nIndex)
	-- body
	
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemArenaBattlers.new() 
	end
	pTempView:setData(self.tFightDetail, _nIndex + 1)
	return pTempView
end

--分享
function DlgExpediteFightDetail:onShareClicked( pView )
	-- body
	local nTYpe = 1
	if self.tFightDetail.nWin == 1 then --胜利
		bIsAtkWin = true
		nTYpe = 1
	else
		bIsAtkLose = true
		nTYpe = 2
	end
	local nShareId = e_share_id.passhero_suc
	if nTYpe == 1  then
		nShareId = e_share_id.passhero_suc
	elseif nTYpe == 2  then
		nShareId = e_share_id.passhero_fail
	end
	-- openShare(pView, nShareId, self.tFightDetail:getShareData(), self.tFightDetail.nReportId)
	openShare(pView, nShareId, {"c^str_"..self.tDefInfo.sName}, self.tFightDetail.nReportId)
end

function DlgExpediteFightDetail:onReplayClicked(  )
	-- body
	if self.tFightDetail then
		SocketManager:sendMsg("reqMailFightReplay", {self.tFightDetail.nReportId})
	end
end

function DlgExpediteFightDetail:updateViews(  )
end

return DlgExpediteFightDetail