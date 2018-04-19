-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 15:21:23 星期三
-- Description: 竞技场 竞技排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaRank = require("app.layer.arena.ItemArenaRank")
local ItemActCard = require("app.layer.activitya.ItemActCard")
local ArenaAthleticsRank = class("ArenaAthleticsRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaAthleticsRank:ctor()
	-- body
	self:myInit()
	parseView("lay_arena_athletics_rank", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaAthleticsRank:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaAthleticsRank",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaAthleticsRank:myInit()
	-- body
	self.tTitlePos = {48, 109, 238, 385, 539}

	self.tAwardItems = {}
end

--初始化控件
function ArenaAthleticsRank:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top")
	self.pLbPar1 		= 		self:findViewByName("lb_par_1")
	self.pLbPar2 		= 		self:findViewByName("lb_par_2")	
	self.pLayListTitle 	= 		self:findViewByName("lay_rank_titles")
	self.pLayList 		= 		self:findViewByName("lay_list")
	self.pLayBtn 		= 		self:findViewByName("lay_btn_share")	

	local tTitle = {
		getConvertedStr(3, 10483),
		getConvertedStr(6, 10243),
		getConvertedStr(3, 10484),
		getConvertedStr(6, 10343),
		getConvertedStr(6, 10813)}
	for i = 1, 5 do
		local pLabel = MUI.MLabel.new({
	        text=tTitle[i],
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tTitlePos[i], self.pLayListTitle:getHeight()/2)		
		self.pLayListTitle:addView(pLabel)
	end

	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_BLUE,getConvertedStr(6,10099))
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
    --左边按钮点击事件
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnShareClicked))
			    
	--排行经理说明		
	self.pLbPar2:setString(getConvertedStr(6, 10828), false)		    
end

-- 修改控件内容或者是刷新控件数据
function ArenaAthleticsRank:updateViews(  )
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

function ArenaAthleticsRank:updateListView(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end	
	self.tListData = pData:getArenaRankDatas()	
	local nItemCnt = table.nums(self.tListData)
	-- dump(self.tListData, "self.tListData", 100)
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
		self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		self:checkArenaRank(Player:getArenaData():getNextRankPage())
	    	end
	    end)	        
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else        
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	
	if not self.tRankTops then
		self.tRankTops = {}
	end
	for i = 1, 3 do 
		if not self.tRankTops[i] then
			local player = ItemActCard.new(i)
			player:setArenaClickHandler(handler(self, self.onRankItemClicked))
			if i == 1 then
				player:setPosition(245, 15)						
			elseif i == 2 then				
				player:setPosition(45, 5)
			elseif i == 3 then
				player:setPosition(445, 5)
			end
			self.pLayTopInfo:addView(player, 10)	
			self.tRankTops[i] = player
		end
		self.tRankTops[i]:setArenaData(self.tListData[i])
	end
end

function ArenaAthleticsRank:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaRank.new(2, 640, 56, self.tTitlePos)
		pView:setItemClickedHandler(handler(self, self.onRankItemClicked))
	end
	pView:setCurData(self.tListData[_index])	
	return pView
end

function ArenaAthleticsRank:onRankItemClicked( _tData )
	-- body
	if _tData then
		if _tData.isnpc and _tData.isnpc == 0 then
			local sPlayerId = _tData.id 
			SocketManager:sendMsg("checkArenaPlayer", {sPlayerId}) --刷新竞技场幸运列表	
		end
	end
end

function ArenaAthleticsRank:checkArenaRank( _nPage )
	-- body
	if not _nPage then
		return 
	end
	SocketManager:sendMsg("checkArenaRank", {_nPage, ARENA_RANK_PAGE_LENGTH}) --刷新排行奖励数据
end

--分享按钮
function ArenaAthleticsRank:onBtnShareClicked( pView )	
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end	
	openShare(pView, e_share_id.arena_rank, {pData.nMyRank})			
end

--析构方法
function ArenaAthleticsRank:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaAthleticsRank:regMsgs( )
	-- body
	--注册刷新排行榜
	regMsg(self, ghd_refresh_arena_rank_msg, handler(self, self.updateListView))

	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))		
end

-- 注销消息
function ArenaAthleticsRank:unregMsgs(  )
	-- body
	--注销刷新排行榜
	unregMsg(self, ghd_refresh_arena_rank_msg)

	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaAthleticsRank:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaAthleticsRank:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaAthleticsRank
