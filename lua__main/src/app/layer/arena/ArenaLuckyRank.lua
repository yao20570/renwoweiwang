-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 16:40:23 星期三
-- Description: 竞技场 幸运排名
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaRank = require("app.layer.arena.ItemArenaRank")
local ArenaLuckyRank = class("ArenaLuckyRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function ArenaLuckyRank:ctor()
	-- body
	self:myInit()
	parseView("lay_arena_lucky_rank", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaLuckyRank:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaLuckyRank",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaLuckyRank:myInit()
	-- body
	self.tTitlePos = {120, 505}
	self.tAwardItems = {}	
end

--初始化控件
function ArenaLuckyRank:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top")
	self.pLbPar1 		= 		self:findViewByName("lb_par_1")
	self.pLayList 		= 		self:findViewByName("lay_list")
	self.pLayListTitle 	= 		self:findViewByName("lay_rank_titles")
	local tTitle = {
		getConvertedStr(6, 10799),
		getConvertedStr(6, 10808),
	}
	for i = 1, 2 do
		local pLabel = MUI.MLabel.new({
	        text=tTitle[i],
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tTitlePos[i], self.pLayListTitle:getHeight()/2)		
		self.pLayListTitle:addView(pLabel)
	end	
end

-- 修改控件内容或者是刷新控件数据
function ArenaLuckyRank:updateViews(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	--我的排行	
	local sStr = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10681)},
		{color=_cc.white,text=pData.nMyRank},
	}
	if pData:isRankLucky(pData.nMyRank) then
		table.insert(sStr, {color=_cc.purple,text=getConvertedStr(6, 10725)})
	end 
	self.pLbPar1:setString(sStr, false)	
end

function ArenaLuckyRank:updateListView(  )
	-- body
	self.tListData = Player:getArenaData():getArenaRankLuckys()
	-- dump(self.tListData, "self.tListData", 100)	
	local nItemCnt = table.nums(self.tListData)
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0 ,
            bottom = 0 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setPosition((self.pLayList:getWidth() - self.pListView:getWidth())/2, 0)
        self.pLayList:addView(self.pListView, 10)        
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else        
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	
end

function ArenaLuckyRank:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaRank.new(4, 640, 100, self.tTitlePos)
		pView:setItemClickedHandler(handler(self, self.onRankItemClicked))
	end
	pView:setCurData(self.tListData[_index])	
	return pView
end

function ArenaLuckyRank:onRankItemClicked( _tData )
	-- body
	--dump(_tData, "_tData", 100)
	if _tData then
		if _tData.isnpc and _tData.isnpc == 0 then
			local sPlayerId = _tData.id 
			SocketManager:sendMsg("checkArenaPlayer", {sPlayerId}) --刷新竞技场幸运列表	
		end
	end
end


--刷新幸运列表数据
function ArenaLuckyRank:refreshLuckyData(  )
	-- body
	SocketManager:sendMsg("checkArenaLuckyRank", {}) --刷新竞技场幸运列表
end
--析构方法
function ArenaLuckyRank:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaLuckyRank:regMsgs( )
	-- body
	--注册刷新幸运列表消息
	regMsg(self, ghd_refresh_arena_lucky_msg, handler(self, self.updateListView))	

	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))			
end

-- 注销消息
function ArenaLuckyRank:unregMsgs(  )
	-- body
	--注销刷新幸运列表消息
	unregMsg(self, ghd_refresh_arena_lucky_msg)

	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaLuckyRank:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaLuckyRank:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaLuckyRank
