-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-11 15:17:10
-- Description: 城墙
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MCommonView = require("app.common.MCommonView")
local LayWallMain = require("app.layer.wall.LayWallMain")
local LayAlliedGarrison = require("app.layer.wall.LayAlliedGarrison")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local DlgWallMain = class("DlgWallMain", function()
	-- body
	return DlgBase.new(e_dlg_index.wall)
end)

function DlgWallMain:ctor()
	-- body
	self:myInit()
	--self:refreshData() --刷新数据
	--parseView("dlg_home_wall", handler(self, self.onParseViewCallback))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWallMain",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgWallMain:myInit()
	-- body
	self.pData = nil --城墙数据
end

--刷新数据
function DlgWallMain:refreshData()
	self.pData = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
end

--初始化控件
function DlgWallMain:setupViews( )
    self.pLayRoot = MUI.MFillLayer.new()
    self.pLayRoot:setViewTouched(false)
    self.pLayRoot:setLayoutSize(640, 1060)
    self:addContentView(self.pLayRoot)

	local tTitles = {getConvertedStr(5, 10071), getConvertedStr(5, 10074)}
	self.pTabHost = FCommonTabHost.new(self.pLayRoot,1,1,tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLayRoot:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLayRoot:addView(self.pTabHost, 10)
	self.pTabItems =  self.pTabHost:getTabItems()
	self.pTabHost:setDefaultIndex(1)	

	self.tTabItems = self.pTabHost:getTabItems()	
end

function DlgWallMain:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then --我的战报
		pLayer = LayWallMain.new(tSize)
		self.pWall = pLayer	
	elseif (_sKey == _tKeyTabLt[2] ) then--前十大神战报
		pLayer = LayAlliedGarrison.new(tSize)
		self.pAlliedGarrison = pLayer	
	end
	return pLayer
end

function DlgWallMain:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nCurIdx = 1
	
	elseif _sKey == "tabhost_key_2" then
		self.nCurIdx = 2	
		Player:getWorldData():setHaveNewHelpMsgs(false)--移除友军驻防红点
		local pRedLayer = self.tTabItems[2]:getRedNumLayer()
		if pRedLayer then
			showRedTips(pRedLayer,0,0,2)		
		end		
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgWallMain:updateViews()
	self:refreshData() --刷新数据
	if not self.pData then
		return
	end	
	local pData = self.pData
	self:setTitle(getConvertedStr(5, 10066).." Lv."..pData.nLv)
	self.tListData = Player:getWorldData():getHelpMsgs()
	local nItemCnt = #self.tListData
	local nNumT = 0	
	-- local pWall = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
	if pData and pData.nLv then
		if getWallBaseDataByLv(pData.nLv) then
			nNumT = getWallBaseDataByLv(pData.nLv).guardnum
		end
	end

	--是否满足驻防条件
	local nLimitLv = tonumber(getWallInitParam("guardLv")) 
	if pData.nLv < nLimitLv then
		self.tTabItems[2]:setTabTitle(getConvertedStr(5, 10074), false)	
		self.tTabItems[2]:setViewEnabled(false)
		self.tTabItems[2]:showTabLock()
		self.tTabItems[2]:onMViewDisabledClicked(handler(self, function (  )
			-- body
			TOAST(string.format(getConvertedStr(5, 10092),nLimitLv))
		end))		
	else
		self.tTabItems[2]:setViewEnabled(true)		
		self.tTabItems[2]:hideTabLock()
		if self.nCurIdx ~= 2 then--友军驻防红点
			local pRedLayer = self.tTabItems[2]:getRedNumLayer()
			if Player:getWorldData():getHaveNewHelpMsgs() then
				showRedTips( pRedLayer, 0, 1, 2)
			else
				showRedTips( pRedLayer, 0, 0, 2)
			end
		end
		--城防武将熟练
		local sStr1 = {
			{color=_cc.white,text=getConvertedStr(5, 10074)},
			{color=_cc.blue,text=nItemCnt},
			{color=_cc.white,text="/"..nNumT},
		}
		self.tTabItems[2]:setTabTitle(sStr1, false)		
	end


end

-- 析构方法
function DlgWallMain:onDestroy(  )
	-- body	
	self:onPause()
end

-- 注册消息
function DlgWallMain:regMsgs( )
	-- body
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_wall, handler(self, self.updateViews))
	
end

-- 注销消息
function DlgWallMain:unregMsgs(  )
	--注销英雄界面刷新
	unregMsg(self, gud_refresh_wall)
end


--暂停方法
function DlgWallMain:onPause( )
	self:unregMsgs()
end

--继续方法
function DlgWallMain:onResume( )	
	self:updateViews()
	self:regMsgs()
end

return DlgWallMain