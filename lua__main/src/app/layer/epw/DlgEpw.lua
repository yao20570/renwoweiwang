----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:35:00
-- Description: 限时Boss
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local EpwDetail = require("app.layer.epw.EpwDetail")
local EpwRank = require("app.layer.epw.EpwRank")
local EpwAward = require("app.layer.epw.EpwAward")

local e_type_tab = {
	harm = 1,
	num = 2,
}

local DlgEpw = class("DlgEpw", function()
	return DlgBase.new(e_dlg_index.eqw)
end)

function DlgEpw:ctor( nTabIndex )
	self.nFirstTabIndex = nTabIndex 
	parseView("dlg_epw", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgEpw:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)

	self:setTitle(getConvertedStr(3, 10959))
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgEpw",handler(self, self.onDlgEpwDestroy))
end

-- 析构方法
function DlgEpw:onDlgEpwDestroy(  )
    self:onPause()
end

function DlgEpw:regMsgs(  )
	regMsg(self, ghd_imperialwar_open_state, handler(self, self.refreshSubView))
	regMsg(self, ghd_refresh_epw_award_state, handler(self, self.refershAwardState))
end

function DlgEpw:unregMsgs(  )
	unregMsg(self, ghd_imperialwar_open_state)
	unregMsg(self, ghd_refresh_epw_award_state)
end

function DlgEpw:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgEpw:onPause(  )
	self:unregMsgs()
end

function DlgEpw:setupViews(  )
	local pLayTime = self:findViewByName("lay_time")
	--刷新cd
	local EpwCd = require("app.layer.epw.EpwCd")
    local pEpwCd = EpwCd.new()
    pLayTime:addView(pEpwCd,10)
    self.pEpwCd = pEpwCd

	self.pLayBannerBg = self:findViewByName("lay_top")
	local pMBanner=setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_wwfz)
	pMBanner:setMBannerOpacity(255*0.5)
	
	self.pLayRedS={}

	--内容层
	self.tTitles = {
		getConvertedStr(3, 10006),
		getConvertedStr(3, 10960),
		getConvertedStr(3, 10486),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")

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
function DlgEpw:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = EpwDetail.new(tSize)
		self.pEpwDetail = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = EpwRank.new(tSize)
		self.pEpwRank = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = EpwAward.new(tSize, e_type_tab.num)
		self.pEpwAward = pLayer
	end
	return pLayer
end

function DlgEpw:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
    elseif _sKey == "tabhost_key_2" then
    	if self.pEpwRank then
    		sendMsg(ghd_clear_rankinfo_msg)
    		self.pEpwRank:reqNewData()
    	end
    elseif _sKey == "tabhost_key_3" then
    	if self.pEpwAward then
    		sendMsg(ghd_clear_rankinfo_msg)
    		self.pEpwAward:reqNewData()
    	end
    end
end

--控件刷新
function DlgEpw:updateViews()
	self:refershAwardState()
end

--刷新当前子界面
function DlgEpw:refreshSubView( )
	if self.pEpwCd then
		self.pEpwCd:updateViews()
	end
	if self.pCurrLayer then
		self.pCurrLayer:updateViews()
	end
end

function DlgEpw:refershAwardState(  )
	local pTabItem = self.pTabItems[3]
	if pTabItem then
		local bCan1 = Player:getImperWarData():getIsRankAward()
		local bCan2 = Player:getImperWarData():getIsStageAward()
		if bCan1 or bCan2 then
			showRedTips(pTabItem:getRedNumLayer(), 0, 1, 2)
		else
			showRedTips(pTabItem:getRedNumLayer(), 0, 0, 2)
		end
	end
end

return DlgEpw