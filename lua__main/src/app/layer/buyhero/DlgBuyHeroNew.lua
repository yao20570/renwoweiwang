-----------------------------------------------------
-- author: xiesite
-- Date: 2017-12-25 24:49:21
-- Description: 拜将台(整合)
-----------------------------------------------------
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgBuyHero = require("app.layer.buyhero.DlgBuyHero")
local DlgShogun = require("app.layer.shogun.DlgShogun")

local DlgBuyHeroNew = class("DlgBuyHeroNew", function()
	return DlgBase.new(e_dlg_index.buyhero)
end)

--分页索引_nIndex
function DlgBuyHeroNew:ctor()
	-- body
	self:myInit()
	self:setTitle(getConvertedStr(1, 10323))
	parseView("dlg_buy_hero_new", handler(self, self.onParseViewCallback))

	self:setupViews()
	self:onResume()

	-- --注册析构方法
	self:setDestroyHandler("DlgBuyHeroNew",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgBuyHeroNew:myInit()
	self.items = {}
	self.classes = {DlgBuyHero, DlgShogun}
 	self.tTitles = {getConvertedStr(5,10161),getConvertedStr(1,10322)}
end

--解析布局回调事件
function DlgBuyHeroNew:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层

end

--初始化控件
function DlgBuyHeroNew:setupViews( )
 	
 	self:updateTabHost()	
end

 
--更新切换卡
function DlgBuyHeroNew:updateTabHost()
	--创建类表中的英雄
	if not self.pTComTabHost then
		self.pLyContent   = self.pView:findViewByName("ly_list")
		self.pTComTabHost = TCommonTabHost.new(self.pLyContent,3,1,self.tTitles,handler(self, self.onIndexSelected),handler(self, self.onNotOpenSelected))
		self.pTabItems = self.pTComTabHost:getTabItems()
		self.pLyContent:addView(self.pTComTabHost,10)
		self.pTComTabHost:removeLayTmp1()
		--招募开启后就要
		if getIsReachOpenCon(18, false) then
			self.pTComTabHost:setDefaultIndex(1)
		else
			self.pTComTabHost:setDefaultIndex(2)
		end
	end

	for i=1, #self.tTitles do
		if i == self.nSelect then
			if self.items[self.nSelect] then
				self.items[self.nSelect]:setVisible(true)
			else
				local pSelectItem = self.classes[self.nSelect].new( self.pTComTabHost:getContentLayer():getContentSize() )
				self.pTComTabHost:getContentLayer():addView(pSelectItem, 2)

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
function DlgBuyHeroNew:onIndexSelected( _index )

	self.nSelect = _index --当前所选星级
	--刷新列表
	self:updateTabHost()
end

--未开启tab回调事件
function DlgBuyHeroNew:onNotOpenSelected(_index)
	getIsReachOpenCon(18)
end

-- 修改控件内容或者是刷新控件数据
function DlgBuyHeroNew:updateViews( )
	if getIsReachOpenCon(18, false) then
		self.pTComTabHost:setOpen(1)
		self.pTComTabHost:hideTabLock()
	else
		self.pTComTabHost:setNotOpen(1)
		self.pTComTabHost:showTabLock(1,cc.p(98,34))
	end
end

-- 析构方法
function DlgBuyHeroNew:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuyHeroNew:regMsgs( )
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
    regMsg(self, ghd_buy_hero_update_msg, handler(self, self.openBuyHero))
	
end

function DlgBuyHeroNew:openBuyHero()
	self.pTComTabHost:setTopTabState(1)
end

-- 注销消息
function DlgBuyHeroNew:unregMsgs( )
	unregMsg(self, gud_refresh_playerinfo)
	unregMsg(self, ghd_buy_hero_update_msg)
end


--暂停方法
function DlgBuyHeroNew:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyHeroNew:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgBuyHeroNew