----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-28 16:46:00
-- Description: 决战阿房宫战报详情
-----------------------------------------------------
local MailDetailAtkDefBanner = require("app.layer.mail.MailDetailAtkDefBanner")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")
local ItemMailBattleInfoBanner = require("app.layer.mail.ItemMailBattleInfoBanner")
local ItemEpwReportPlayer = require("app.layer.imperialwar.ItemEpwReportPlayer")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")

local DlgBase = require("app.common.dialog.DlgBase")
local DlgImperWarReport = class("DlgImperWarReport", function()
	return DlgBase.new(e_dlg_index.imperwarreport)
end)
--tData:tReplay
function DlgImperWarReport:ctor( tData, bIsShare )
	self.tData = tData
	self.bIsShare = bIsShare
	parseView("dlg_imper_war_report", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgImperWarReport:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:setTitle(getConvertedStr(3, 10967))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgImperWarReport",handler(self, self.onDlgImperWarReportDestroy))
end

-- 析构方法
function DlgImperWarReport:onDlgImperWarReportDestroy(  )
    self:onPause()
end

function DlgImperWarReport:regMsgs(  )
end

function DlgImperWarReport:unregMsgs(  )
end

function DlgImperWarReport:onResume(  )
	self:regMsgs()
end

function DlgImperWarReport:onPause(  )
	self:unregMsgs()
end

function DlgImperWarReport:setupViews(  )
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
	
	--按钮
	local pLayBtnReplay = self:findViewByName("lay_btn_replay")
	self.pBtnReplay = getCommonButtonOfContainer(pLayBtnReplay, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10240))
	self.pBtnReplay:onCommonBtnClicked(handler(self, self.onReplayClicked))
	setMCommonBtnScale(pLayBtnReplay, self.pBtnReplay, 0.9)
end

function DlgImperWarReport:updateViews(  )
	if not self.tData then
		return
	end
	
	--背景图
	local pLayInfo =MUI.MLayer.new()		
	local sBanner = nil
	if self.tData:getIsAtkWin() then
		sBanner = "v2_bg_shenglijiesuan"
	else
		sBanner = "v2_bg_shibaijiesuan"
	end
	--基本信息
	local pLayInfo =MUI.MLayer.new()
	local pBanner=MUI.MImage.new("ui/big_img_sep/"..sBanner..".jpg") 
	pLayInfo:setContentSize(pBanner:getWidth(),pBanner:getHeight())
	pBanner:setAnchorPoint(0,0)
	pLayInfo:addView(pBanner)
	self.pSv:addScrollViewChild(pLayInfo)

	local bIsMeJoin = false
	local tAtkHeros = {}
	local tDefHeros = {}
	self.nAtkCountry = nil
	self.nDefCountry = nil
	--Banner文字
	local tStr = {}
	local tFighterVO = self.tData:getAtk()
	if tFighterVO then
		tAtkHeros = tFighterVO:getFHero()
		if tFighterVO:getIsMe() then
			bIsMeJoin = true
		end
		local nCountry = tFighterVO:getCountry()
		self.nAtkCountry = nCountry
		table.insert(tStr, {color= getColorByCountry(nCountry) ,text=getCountryShortName(nCountry, true)})
		table.insert(tStr, {color= _cc.blue ,text=tFighterVO:getName()..getLvString(tFighterVO:getLv())})
	end
	table.insert(tStr, {color= _cc.white ,text=getConvertedStr(3, 10016)})
	local tFighterVO = self.tData:getDef()
	if tFighterVO then
		tDefHeros = tFighterVO:getFHero()
		if tFighterVO:getIsMe() then
			bIsMeJoin = true
		end
		local nCountry = tFighterVO:getCountry()
		self.nDefCountry = nCountry
		table.insert(tStr, {color= getColorByCountry(nCountry) ,text=getCountryShortName(nCountry, true)})
		table.insert(tStr, {color= _cc.blue ,text=tFighterVO:getName()..getLvString(tFighterVO:getLv())})
	end
	local pAtkInfo=ItemMailBattleInfoBanner.new(tStr)
	self.pSv.nHeight=self.pSv.nHeight+120
	self.pSv:addScrollViewChild(pAtkInfo)
	self.pSv.nHeight=self.pSv.nHeight-10

	--时间分享层
	local nSendTime = self.tData:getSendTime()
	local sTime={
        {sStr=formatTime(nSendTime or 0),nFontSize=18,sColor=_cc.white},        
    }
    local ItemMailSendTimeShare = require("app.layer.mail.ItemMailSendTimeShare")
    local pTimeAndShare=ItemMailSendTimeShare.new(sTime)
    if not self.bIsShare then --不是分享才
	    if bIsMeJoin then
			local pLayBtnShare=pTimeAndShare:getLayShareBtn()
			self.pBtnShare = getCommonButtonOfContainer(pLayBtnShare, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10003),false)
			self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
			setMCommonBtnScale(pLayBtnShare, self.pBtnShare, 0.7)
		end
	end
	self.pSv:addScrollViewChild(pTimeAndShare)

	
	--回放层
	local pReplayView   = ItemEpwReportPlayer.new() 
	pReplayView:setData(self.tData, 1)
	self.pSv:addScrollViewChild(pReplayView)

	--攻防横条
	local pMailDetailAtkDefBanner = MailDetailAtkDefBanner.new()
	self.pSv:addScrollViewChild(pMailDetailAtkDefBanner)

	--攻防战役
	self.tAtkHeros = tAtkHeros
	self.tDefHeros = tDefHeros
    local nCount = math.max(#tAtkHeros, #tDefHeros)
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

function DlgImperWarReport:moveContentCallback( _pView,_nIndex)
	local pTempView = _pView
	if pTempView == nil then
		pTempView   = ItemCCWarMailBattle.new() 
	end
	pTempView:setData2(self.tAtkHeros, self.tDefHeros, self.nAtkCountry, self.nDefCountry, _nIndex)
	return pTempView
end

function DlgImperWarReport:onReplayClicked(  )
	if not self.tData then
		return
	end
	SocketManager:sendMsg("reqMailFightReplay", {self.tData:getFightRid()})
end

function DlgImperWarReport:onShareClicked(  )
	if not self.tData then
		return
	end

	if not self.pBtnShare then
		return
	end
	  
	local nShareId = nil
	if self.tData:getIsAtkWin()  then
		nShareId = e_share_id.epw_state_win
	else
		nShareId = e_share_id.epw_state_lose
	end
	local tAtkFighterVO = self.tData:getAtk()
	local tDefFighterVO = self.tData:getDef()
	if tAtkFighterVO and tDefFighterVO then
		local sName1 = tAtkFighterVO:getName()
		local sName2 = tDefFighterVO:getName()
		if sName1 and sName2 then
			openShare(self.pBtnShare, nShareId, {"c^str_"..sName1, "c^str_"..sName2, self.tData:getCityId(), self.tData:getFightRid()})
		end
	end
end

return DlgImperWarReport