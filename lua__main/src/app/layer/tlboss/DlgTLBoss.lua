----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:35:00
-- Description: 限时Boss
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local TLBossCome = require("app.layer.tlboss.TLBossCome")
local TLBossRank = require("app.layer.tlboss.TLBossRank")
local TLBossAwardNew = require("app.layer.tlboss.TLBossAwardNew")
local e_type_tab = {
	harm = 1,
	num = 2,
}

local DlgTLBoss = class("DlgTLBoss", function()
	return DlgBase.new(e_dlg_index.tlboss)
end)

function DlgTLBoss:ctor( nTabIndex )
	self.nFirstTabIndex = nTabIndex 
	parseView("dlg_tlboss", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgTLBoss:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)

	self:setTitle(getConvertedStr(3, 10830))
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTLBoss",handler(self, self.onDlgTLBossDestroy))
end

-- 析构方法
function DlgTLBoss:onDlgTLBossDestroy(  )
    self:onPause()
end

function DlgTLBoss:regMsgs(  )
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.refreshSubView))
end

function DlgTLBoss:unregMsgs(  )
	unregMsg(self, gud_tlboss_data_refresh)
end

function DlgTLBoss:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgTLBoss:onPause(  )
	self:unregMsgs()
end

function DlgTLBoss:setupViews(  )
	local pImgTitle = self:findViewByName("img_title")
	pImgTitle:setCurrentImage("#v2_fonts_shijiebosswenan.png")

	local pLayTime = self:findViewByName("lay_time")
	--刷新cd
	local TLBossCd = require("app.layer.tlboss.TLBossCd")
    local pTLBossCd = TLBossCd.new()
    pLayTime:addView(pTLBossCd,10)
    self.pTLBossCd = pTLBossCd

	self.pLayBannerBg = self:findViewByName("lay_top")
	local pMBanner=setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_wwfz)
	pMBanner:setMBannerOpacity(255*0.5)
	
	self.pLayRedS={}

	--内容层
	self.tTitles = {
		getConvertedStr(3, 10830),
		getConvertedStr(3, 10812),
		getConvertedStr(3, 10835),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")
	-- self.pLyContent:setZOrder(10)
	-- --初始化红点
	-- local x = self.pLyContent:getPositionX()
	-- local nWidOff = self.pLyContent:getWidth()/4
	-- local y = self.pLyContent:getPositionY() + self.pLyContent:getHeight() - 35
	-- for i = 2, 3 do
	-- 	if not self.pLayRedS[i] then
	-- 		local pLayRed = MUI.MLayer.new(true)
	-- 		pLayRed:setLayoutSize(26, 26)		
	-- 		pLayRed:setPosition(x + nWidOff*i - 26, y)
 --            pLayRed:setIgnoreOtherHeight(true)
	-- 		self.pLyContent:addView(pLayRed, 100)
	-- 		self.pLayRedS[i] = pLayRed
	-- 	end
	-- end

	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost,10)
	self.pTabItems = self.pTabHost:getTabItems()
	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)
end

--通过key值获取内容层的layer
function DlgTLBoss:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = TLBossCome.new(tSize)
		self.pTLBossCome = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = TLBossAwardNew.new(tSize, e_type_tab.harm)
		self.pTLBossAwardHarm = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = TLBossAwardNew.new(tSize, e_type_tab.num)
		self.pTLBossAwardNum = pLayer
	end
	return pLayer
end

function DlgTLBoss:onTabChanged( _sKey, _nType )
	local bIsBossCome = false
	if _sKey == "tabhost_key_1" then
		self.pCurrLayer = self.pTLBossCome
		self.pCurrLayer:updateViews()
		bIsBossCome = true
	elseif _sKey == "tabhost_key_2" then
		self.pCurrLayer = self.pTLBossAwardHarm
		self.pCurrLayer:updateViews()
	elseif _sKey == "tabhost_key_3" then
		self.pCurrLayer = self.pTLBossAwardNum
		self.pCurrLayer:updateViews()
	end
	self.pTLBossCome:setCanShowGetItem(bIsBossCome)
end

--控件刷新
function DlgTLBoss:updateViews()
	self:updateRedNum()
end

--刷新当前子界面
function DlgTLBoss:refreshSubView( )
	if self.pTLBossCd then
		self.pTLBossCd:updateViews()
	end
	if self.pCurrLayer then
		self.pCurrLayer:updateViews()
	end
	self:updateRedNum()
end

function DlgTLBoss:updateRedNum( )
	local nNum = 0
	local nState = Player:getTLBossData():getTk()
	local nState2 = Player:getTLBossData():getTh()
	if nState == e_tlboss_award.get or nState2 == e_tlboss_award.get then
		nNum = 1
	end
	local pTabItem2 = self.pTabItems[2]
	if pTabItem2 then
		showRedTips(pTabItem2:getRedNumLayer(), 0, nNum, 2)
	end

	local nNum = 0
	local nState = Player:getTLBossData():getTf()
	if nState == e_tlboss_award.get then
		nNum = 1
	end
	local pTabItem3 = self.pTabItems[3]
	if pTabItem3 then
		showRedTips(pTabItem3:getRedNumLayer(), 0, nNum, 2)
	end
end

return DlgTLBoss