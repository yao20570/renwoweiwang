-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-1-13 11:55:23 星期六
-- Description: 竞技场
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local ArenaLayer = require("app.layer.arena.ArenaLayer")--竞技场
local ArenaLineUpLayer = require("app.layer.arena.ArenaLineUpLayer")--阵容
local ArenaShopLayer = require("app.layer.arena.ArenaShopLayer")--商店
local ArenaRankLayer = require("app.layer.arena.ArenaRankLayer")--排行
local ArenaRewardLayer = require("app.layer.arena.ArenaRewardLayer")--奖励

local DlgArena = class("DlgArena", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgarena)
end)

function DlgArena:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_arena", handler(self, self.onParseViewCallback))
	
end

function DlgArena:myInit(  )
	-- body	
	self.nCurIndex 	= -1
	self.pTabArena 	= nil
	self.pTabRank 	= nil
	self.pTabShop 	= nil
	self.pTabReward = nil
end

--解析布局回调事件
function DlgArena:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(6,10676))
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgArena",handler(self, self.onDlgRankDestroy))
end

--控件刷新
function DlgArena:updateViews(  )
	self.nCurIndex = 1
	if not self.pTabHost then
		local pLayTab 			= 		self:findViewByName("lay_tab")
		local tTitles = {getConvertedStr(6, 10684), --挑战
						getConvertedStr(6, 10791), --阵容
						getConvertedStr(3, 10318),--商店
						getConvertedStr(3, 10483),--排行
						getConvertedStr(6, 10416),--奖励
					}

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

	--刷新挑战奖励红点
	local pArena = Player:getArenaData()
	local pScorePrizePag = self.tTabItems[5]
	local pHeroRedLayer = self.tTabItems[2]
	if pArena then
		if pScorePrizePag then
			local nNum = pArena:getScroeRedNum() + pArena:getRankRedNum() + pArena:getLuckyRedNum()
			showRedTips(pScorePrizePag:getRedNumLayer(), 0, nNum, 2)
		end
		
		if pHeroRedLayer then
			local nNum = pArena:getArenaHeroRedNum()
			showRedTips(pHeroRedLayer:getRedNumLayer(), 0, nNum, 2)
		end
	end
end

function DlgArena:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then --挑战
		pLayer = ArenaLayer.new(tSize)	
		self.pTabArena = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then--阵容
		pLayer = ArenaLineUpLayer.new(tSize)
		self.pTabLineUp = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then--商店
		pLayer = ArenaShopLayer.new(tSize)
		self.pTabShop = pLayer		
	elseif (_sKey == _tKeyTabLt[4] ) then--排行
		pLayer = ArenaRankLayer.new(tSize)
		self.pTabRank = pLayer		
	elseif (_sKey == _tKeyTabLt[5] ) then--奖励		
		pLayer = ArenaRewardLayer.new(tSize)
		self.pTabReward = pLayer			
	end
	return pLayer
end

function DlgArena:onTabChanged( _sKey, _nType )
	-- if self.nCurIndex == 2 and _sKey ~= "tabhost_key_2" then
	-- 	if self.pTabLineUp then
	-- 		self.pTabLineUp:showArenaLineUpTip()
	-- 	end
	-- end
	if _sKey == "tabhost_key_1" then
		self.nCurIndex = 1
		self:refreshArenaView()	
	elseif _sKey == "tabhost_key_2" then
		self.nCurIndex = 2
		if self.pTabLineUp then
			self.pTabLineUp:updateViews()
		end		
	elseif _sKey == "tabhost_key_3" then
		self.nCurIndex = 3
	elseif _sKey == "tabhost_key_4" then
		self.nCurIndex = 4
		if self.pTabRank then
			self.pTabRank:enterArenaRank() --显示竞技排行
		end		
	elseif _sKey == "tabhost_key_5" then
		self.nCurIndex = 5
		if self.pTabReward then
			self.pTabReward:enterArenaRank(_nSecPag)--显示奖励
		end					
	end
end


function DlgArena:setGuideParam( _nFirshPag, _nSecPag )
	-- body
	if _nFirshPag and _nFirshPag >= 1 and _nFirshPag <= 5 then
		self.pTabHost:setDefaultIndex(_nFirshPag)
		if _nFirshPag == 4 then
			self.pTabRank:enterArenaRank(_nSecPag)
		elseif _nFirshPag == 5 then
			self.pTabReward:enterArenaRank(_nSecPag)
		end
	end
	
end

function DlgArena:refreshArenaView(  )
	-- body
	SocketManager:sendMsg("loadArenaView", {}) --刷新竞技场视图数据
end

--析构方法
function DlgArena:onDlgRankDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgArena:regMsgs(  )
	-- body
	--注册竞技场视图数据刷新消息
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))		

	regMsg(self, ghd_arena_viewdata_refresh_msg, handler(self, self.refreshArenaView))

	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
end
--注销消息
function DlgArena:unregMsgs( )
	-- body
	--注销竞技场视图数据刷新消息
	unregMsg(self, gud_refresh_arena_msg)
	--竞技场挑战之后重新请求页面数据
	unregMsg(self, ghd_arena_viewdata_refresh_msg)
	--竞技场武将红点
	unregMsg(self, gud_refresh_hero)
end

--暂停方法
function DlgArena:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgArena:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgArena