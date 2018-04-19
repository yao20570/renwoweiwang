----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-02-26 15:57:21  星期一
-- Description: 冥界入侵
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local MingjieAttk = require("app.layer.activityb.mingjie.MingjieAttk")
local MingjieExchange = require("app.layer.activityb.mingjie.MingjieExchange")
local MingjieShop = require("app.layer.activityb.mingjie.MingjieShop")

local DlgMingjie = class("DlgMingjie", function()
	return DlgBase.new(e_dlg_index.mingjie)
end)

function DlgMingjie:ctor( nTabIndex )
	-- if nTabIndex then
	-- 	self.nFirstTabIndex = nTabIndex 
	-- else
	-- 	self.nFirstTabIndex = tonumber(getLocalInfo( "mingjieTab" .. Player:getPlayerInfo().pid, "1"))
	-- end
	self.nFirstTabIndex = 1
	self.nCurTabIndex = self.nFirstTabIndex
	parseView("dlg_mingjie", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgMingjie:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgMingjie",handler(self, self.onDlgMingjieDestroy))
end

-- 析构方法
function DlgMingjie:onDlgMingjieDestroy(  )
    self:onPause()
end

function DlgMingjie:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.refreshView))

    -- regMsg(self, gud_refresh_baginfo, handler(self, self.refreshRedNum))

end

function DlgMingjie:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function DlgMingjie:onResume(  )
	self:regMsgs()
	self:updateViews()

	self:refreshRedNum()
end

function DlgMingjie:onPause(  )
	self:unregMsgs()

	-- saveLocalInfo("mingjieTab" .. Player:getPlayerInfo().pid, tostring(self.nCurTabIndex))
end

function DlgMingjie:setupViews(  )
	self.pLayInfoBtn = self:findViewByName("lay_info_btn")
	self.pLayInfoBtn:setVisible(false)
	-- self.pLayInfoBtn:setViewTouched(true)
	-- self.pLayInfoBtn:setIsPressedNeedScale(true)
	-- self.pLayInfoBtn:onMViewClicked(handler(self, self.onClickedInfo))

	self.pLayTime = self:findViewByName("lay_time")
	self.pLayAttr = self:findViewByName("lay_attr")

	self.pLbAttr1 = self:findViewByName("lb_attr1")
	self.pLbAttr2 = self:findViewByName("lb_attr2")
	local pLbAttr3 = self:findViewByName("lb_attr3")
	pLbAttr3:setVisible(false)

	local tStr1 = {
			{color=_cc.lgray, text=getConvertedStr(9,10159)},
			{color=_cc.green,text="+0"},
		}
	self.pLbAttr1:setString(tStr1)

	local tStr2 = {
			{color=_cc.lgray, text=getConvertedStr(9,10160)},
			{color=_cc.green,text="+0"},
		}
	self.pLbAttr2:setString(tStr2)
	-- local tStr3 = {
	-- 		{color=_cc.lgray, text=getConvertedStr(9,10161)},
	-- 		{color=_cc.green,text="+0"},
	-- 	}
	-- self.pLbAttr3:setString(tStr3)
	-- self.pLayTop = self:findViewByName("lay_top")

	--banner
	self.pLayBannerBg = self:findViewByName("lay_top")
	local pMBanner=setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_mjrq)
	pMBanner:setMBannerOpacity(255*0.5)
	
	self.pLayRedS={}

	--内容层
	self.tTitles = {
		getConvertedStr(9, 10149),
		getConvertedStr(9, 10151),
		getConvertedStr(9, 10152),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")
	self.pLyContent:setZOrder(10)
	--初始化红点
	local x = self.pLyContent:getPositionX()
	local nWidOff = self.pLyContent:getWidth()/3
	local y = self.pLyContent:getPositionY() + self.pLyContent:getHeight() - 35
	for i = 2, 3 do
		if not self.pLayRedS[i] then
			local pLayRed = MUI.MLayer.new(true)
			pLayRed:setLayoutSize(26, 26)		
			pLayRed:setPosition(x + nWidOff*i - 26, y)
            pLayRed:setIgnoreOtherHeight(true)
			self.pLyContent:addView(pLayRed, 100)
			self.pLayRedS[i] = pLayRed
		end
	end
	self:refreshRedNum()
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost,10)

	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)

	self.pLbTip=self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(9,10158))

end

function DlgMingjie:refreshView(  )
	-- body
	self:updateViews()
	self:refreshRedNum()
end

function DlgMingjie:refreshRedNum( )
	-- body
	
	--获取活动数据
	local tData = Player:getActById(e_id_activity.mingjie)
	if tData then
		

		-- tData:getRedNums()
		-- sendMsg(gud_refresh_activity)
		sendMsg(gud_refresh_act_red)
		if tData:isCanExchangeAttr() then
			showRedTips(self.pLayRedS[2], 0, 1)
		else
			showRedTips(self.pLayRedS[2], 0, 0)
		end
		if tData:isCanExchangePoint() then
			showRedTips(self.pLayRedS[3], 0, 1)
		else
			showRedTips(self.pLayRedS[3], 0, 0)
		end
	end

end

--通过key值获取内容层的layer
function DlgMingjie:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
	local pdata = {}

    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = MingjieAttk.new(tSize)	
		self.pMingjieAttk = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = MingjieExchange.new(tSize)
		self.pMingjieExchange = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = MingjieShop.new(tSize)
		self.pMingjieShop = pLayer
	end
	return pLayer
end

function DlgMingjie:onTabChanged( _sKey, _nType )
	self.pLayAttr:setVisible(false)
	local nId = nil
	local tData = Player:getActById(e_id_activity.mingjie)

	if _sKey == "tabhost_key_1" then
		self.nCurTabIndex=1
	elseif _sKey == "tabhost_key_2" then
		
		tData:setShopCheckState(1)
		self.nCurTabIndex=2
		self.pLayAttr:setVisible(true)
		nId = 100170
	elseif _sKey == "tabhost_key_3" then
		tData:setShopCheckState(2)
		
		self.nCurTabIndex=3
		nId = 100171 
	end
	if nId then
		local tItemData=Player:getBagInfo():getItemDataById(nId)
		
		if tItemData then	
			if tItemData.nRedNum>0 then
				tItemData:clearItemRed()
			end
		end
		self:refreshRedNum()
	end
end
--控件刷新
function DlgMingjie:updateViews()
	local tData = Player:getActById(e_id_activity.mingjie)
	-- if not tData then
	-- 	self:closeDlg(false)
	-- 	return
	-- end

	if tData then
		--设置标题
		self:setTitle(tData.sName)
		self.pLbTip:setVisible(true)
		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTime, tData, cc.p(0,0))
		else
			self.pActTime:setCurData(tData)
		end
		for i=1,#tData.tAtts do
			local tTemp = tData.tAtts[i]
			local nValue =math.ceil(tTemp.v * 100)
			if tTemp.k == 500 then
				
				local tStr = {
					{color=_cc.lgray, text=getConvertedStr(9,10160)},
					{color=_cc.green,text="+".. nValue .. "%"},
				}
				self.pLbAttr2:setString(tStr)
			elseif tTemp.k == 501 then
				local tStr = {
					{color=_cc.lgray, text=getConvertedStr(9,10159)},
					{color=_cc.green,text="+".. nValue .. "%"},
				}
				self.pLbAttr1:setString(tStr)
			-- elseif tTemp.k == 502 then
			-- 	local tStr = {
			-- 		{color=_cc.lgray, text=getConvertedStr(9,10161)},
			-- 		{color=_cc.green,text="+".. nValue .. "%"},
			-- 	}
			-- 	self.pLbAttr3:setString(tStr)
			
			end
		end
		self:setNoDataTabCallback(false)
	else
		self:setTitle(getConvertedStr(9,10149))
		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTime, {}, cc.p(0,0))
			
		end
		self.pActTime:setContent(getConvertedStr(9,10222))

		self.pLbAttr1:setVisible(false)
		self.pLbAttr2:setVisible(false)
		self.pLbTip:setVisible(false)

		self:setNoDataTabCallback(true)
	end

	-- --更新子面板(只有兑换才与活动相关)
	if self.pMingjieAttk then
		self.pMingjieAttk:updateViews()
	end

	if self.pMingjieExchange then
		self.pMingjieExchange:updateViews()
	end
	if self.pMingjieShop then
		self.pMingjieShop:updateViews()
	end
end

function DlgMingjie:setNoDataTabCallback( _bIsNoData )
	-- body
	local bIsNoData = _bIsNoData
	--符纸
	local pTabItem1 = self.pTabHost.tTabItems[2]
	if pTabItem1 then
		if bIsNoData then
			pTabItem1:showTabLock()
			pTabItem1:setViewEnabled(false)
			pTabItem1:onMViewDisabledClicked(handler(self, function (  )
			    -- body
		
			    TOAST(getConvertedStr(9,10223))
			end))
		else
			pTabItem1:setViewEnabled(true)             
			pTabItem1:hideTabLock()
		end
	end

	--积分
	local pTabItem2 = self.pTabHost.tTabItems[3]
	if pTabItem2 then
		if bIsNoData then
			pTabItem2:showTabLock()
			pTabItem2:setViewEnabled(false)
			pTabItem2:onMViewDisabledClicked(handler(self, function (  )
			    -- body
		
			    TOAST(getConvertedStr(9,10223))
			end))
		else
			pTabItem2:setViewEnabled(true)             
			pTabItem2:hideTabLock()
		end
	end

end

function DlgMingjie:onClickedInfo(  )
	-- body

 	local tObject = {}
	tObject.nType = e_dlg_index.dlgactivitydesc --dlg类型
	tObject.nActId = e_id_activity.mingjie --活动id
	tObject.nBtnType = 2
	sendMsg(ghd_show_dlg_by_type,tObject)

end


return DlgMingjie