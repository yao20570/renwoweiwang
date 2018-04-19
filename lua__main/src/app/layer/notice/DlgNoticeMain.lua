-- DlgNoticeMain.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-29 10:36:23 星期一
-- Description: 公告
-----------------------------------------------------
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgNotice = require("app.layer.notice.DlgNotice")
local DlgLevelPreview = require("app.layer.notice.DlgLevelPreview")

local func_idx = {
	notice 				= 1,		--公告
	levelpreview 		= 2,		--等级预告
}

local DlgNoticeMain = class("DlgNoticeMain", function()
	return DlgBase.new(e_dlg_index.dlgnoticemain)
end)

--分页索引_nIndex
function DlgNoticeMain:ctor()
	-- body
	self:myInit()
	self:setTitle(getConvertedStr(7, 10328))
	parseView("dlg_notice_main", handler(self, self.onParseViewCallback))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgNoticeMain",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgNoticeMain:myInit()
	self.items = {}
	self.classes = {DlgNotice, DlgLevelPreview}
 	self.tTitles = {getConvertedStr(7, 10005), getConvertedStr(7, 10329)}
end

--解析布局回调事件
function DlgNoticeMain:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层

end

--初始化控件
function DlgNoticeMain:setupViews( )
 	
 	self:updateTabHost()
end

 
--更新切换卡
function DlgNoticeMain:updateTabHost()
	if not self.pTComTabHost then
		self.pLyContent   = self.pView:findViewByName("ly_con")
		self.pTComTabHost = TCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.onIndexSelected),handler(self, self.onNotOpenSelected))
		self.pTabItems = self.pTComTabHost:getTabItems()
		self.pLyContent:addView(self.pTComTabHost, 10)
		self.pTComTabHost:removeLayTmp1()
		self.pTComTabHost:setDefaultIndex(func_idx.notice)
	end

	for i=1, #self.tTitles do
		if i == self.nSelect then
			if self.items[self.nSelect] then
				self.items[self.nSelect]:setVisible(true)
			else
				self.pContentLayer = self.pTComTabHost:getContentLayer()
				local pSelectItem = self.classes[self.nSelect].new(self.pContentLayer:getContentSize())
				self.pContentLayer:addView(pSelectItem, 2)
                self.items[self.nSelect] = pSelectItem
			end
		else
			if self.items[i] then
				self.items[i]:setVisible(false)
			end
		end
	end

end

--下标选择回调事件
function DlgNoticeMain:onIndexSelected( _index )
	if self.nSelect == _index then
		return
	end
	self.nSelect = _index --当前所选下标
	--刷新列表
	self:updateTabHost()

	if self.nSelect == func_idx.levelpreview then
		local pTabItem = self.pTabItems[func_idx.levelpreview]
		showRedTips(pTabItem:getRedNumLayer(), 0, 0, 2)
		Player:getNoticeData():setNoticeRedNums(nil)
		local tObject = {} 
		tObject.nType = e_index_itemrl.r_gg--对联类型
		tObject.nRedType = 0--红点类型
		tObject.nRedNums = Player:getNoticeData():getNoticeRedNums() --红点个数
		sendMsg(gud_refresh_homelr_red,tObject) --刷新公告上面的红点
	end
end

--未开启tab回调事件
function DlgNoticeMain:onNotOpenSelected(_index)
	getIsReachOpenCon(23)
end

-- 修改控件内容或者是刷新控件数据
function DlgNoticeMain:updateViews( )
	local pTabItem = self.pTabItems[func_idx.levelpreview]
	--等级预告是否开启
	local bOpen, sLockTip = getIsReachOpenCon(23, false)
	if bOpen then
		pTabItem:hideTabLock()
		pTabItem:setViewEnabled(true)
		self:onUpdateRedTip()
	else
		pTabItem:showTabLock()
		pTabItem:setViewEnabled(false)
		pTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	end
end

--红点提示
function DlgNoticeMain:onUpdateRedTip()
	local nNums = Player:getNoticeData():getLevelPreviewNums()
	if nNums then
		local pTabItem = self.pTabItems[func_idx.levelpreview]
		local tConfData = getLevelPreviewData()
		local nLv = Player:getPlayerInfo().nLv
		if nLv >= tConfData[1].level and nLv <= tConfData[table.nums(tConfData)].level then
			showRedTips(pTabItem:getRedNumLayer(), 0, 1, 2)
		end
	end
end

-- 析构方法
function DlgNoticeMain:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgNoticeMain:regMsgs( )
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	-- 注册主公等级变化消息
	regMsg(self, ghd_refresh_playerlv_msg, handler(self, self.onUpdateRedTip))
end

-- 注销消息
function DlgNoticeMain:unregMsgs( )
	unregMsg(self, gud_refresh_playerinfo)
	--注销等级变化消息
  	unregMsg(self, ghd_refresh_playerlv_msg)
end


--暂停方法
function DlgNoticeMain:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgNoticeMain:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgNoticeMain

