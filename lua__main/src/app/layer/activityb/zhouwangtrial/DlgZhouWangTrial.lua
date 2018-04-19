-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-1-13 11:55:23 星期六
-- Description: 竞技场
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local LayZhouWangTrialMain = require("app.layer.activityb.zhouwangtrial.LayZhouWangTrialMain")
local LayZhouWangTrialPrize = require("app.layer.activityb.zhouwangtrial.LayZhouWangTrialPrize")
local LayZhouWangTrialRank = require("app.layer.activityb.zhouwangtrial.LayZhouWangTrialRank")

local DlgZhouWangTrial = class("DlgZhouWangTrial", function()
	-- body
	return DlgBase.new(e_dlg_index.zhouwangtrial)
end)

function DlgZhouWangTrial:ctor(  )
	-- body
	self:myInit()
    self.pLayRoot = MUI.MFillLayer.new()
    self.pLayRoot:setViewTouched(false)
    self.pLayRoot:setLayoutSize(640, 1060)
    self:addContentView(self.pLayRoot)
	--设置标题
	self:setTitle(getConvertedStr(6,10784))
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgZhouWangTrial",handler(self, self.onDestroy))
	
end

function DlgZhouWangTrial:myInit(  )
	-- body	
	self.nCurIndex 	= -1
	self.tPages = {}
end

--控件刷新
function DlgZhouWangTrial:updateViews(  )
	self.nCurIndex = 1
	if not self.pTabHost then
		local pLayTab 			= 		self.pLayRoot
		local tTitles = {getConvertedStr(6, 10784), getConvertedStr(6, 10785), getConvertedStr(6, 10677)}

		self.pTabHost = FCommonTabHost.new(pLayTab,1,1,tTitles,handler(self, self.getLayerByKey), 1)
		self.pTabHost:setLayoutSize(pLayTab:getLayoutSize())
		self.pTabHost:removeLayTmp1()
		self.pTabHost:removeLayTmp2()
		self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
		pLayTab:addView(self.pTabHost,10)
		self.pTabMgr = self.pTabHost.pTabManager
		self.pTabMgr:setImgBag("#v1_btn_selected_biaoqian.png", "#v1_btn_biaoqian.png")
		self.pTabHost:setDefaultIndex(self.nCurIndex)
		self.tTabItems = self.pTabHost:getTabItems()
	end	
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	if not pData then
		return
	end	
	local pLayer = self.tTabItems[3]
	if pLayer then
		showRedTips(pLayer:getRedNumLayer(), 1, pData:getRedNums(), 2)
	end
		
end

function DlgZhouWangTrial:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()	
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = LayZhouWangTrialMain.new(tSize)	
		self.tPages[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = LayZhouWangTrialRank.new(tSize)
		self.tPages[2] = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = LayZhouWangTrialPrize.new(tSize)
		self.tPages[3] = pLayer
	end
	return pLayer
end

function DlgZhouWangTrial:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		
	elseif _sKey == "tabhost_key_2" then
		if self.tPages[2] then
			self.tPages[2]:reqRankInfo()
		end 
	elseif _sKey == "tabhost_key_3" then
		
	end
end

function DlgZhouWangTrial:getCurTabLayer(  )
	-- body
	if self.nCurIndex == 1 then
		
	elseif self.nCurIndex == 2 then
		
	elseif self.nCurIndex == 3 then
		
	end
	return nil
end


--析构方法
function DlgZhouWangTrial:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgZhouWangTrial:regMsgs(  )
	-- body
	--注册活动数据刷新消息
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))		
end
--注销消息
function DlgZhouWangTrial:unregMsgs( )
	-- body
	--注销活动数据刷新消息
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgZhouWangTrial:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgZhouWangTrial:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgZhouWangTrial