-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 16:40:23 星期三
-- Description: 竞技场 排名奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaRank = require("app.layer.arena.ItemArenaRank")

local ArenaRankReward = class("ArenaRankReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaRankReward:ctor()
	-- body
	self:myInit()
	parseView("lay_arena_rank_reward", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaRankReward:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaRankReward",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaRankReward:myInit()
	-- body	
	self.tAwardItems = {}	
end

--初始化控件
function ArenaRankReward:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top")
	self.pLbPar1 		= 		self:findViewByName("lb_par_1")		
	self.pLbTip 		= 		self:findViewByName("lb_tip")
	self.pLayBtnGet 	= 		self:findViewByName("lay_btn_get")
	self.pLayRewards 	= 		self:findViewByName("lay_rewards")

	self.pLayList 		= 		self:findViewByName("lay_list")

	self.pLbTip:setString(getConvertedStr(6, 10804), false) 
	self.pBtn = getCommonButtonOfContainer(self.pLayBtnGet,TypeCommonBtn.M_YELLOW,getConvertedStr(6,10189))	    
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnGetClicked))

	self.pLayRewards:setPositionX(140)
end

-- 修改控件内容或者是刷新控件数据
function ArenaRankReward:updateViews(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	--我的排名
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10810)},
		{color=_cc.blue, text=pData.nYr},
	}
	if pData:isLuckyPrevTime() then
		table.insert(sStr, {color=_cc.purple,text=getConvertedStr(6, 10725)})
	end 	
	self.pLbPar1:setString(sStr, false)

	local tRewards = pData:getMyRankRewards()	
	local pFreeList = gRefreshHorizontalList(self.pLayRewards, tRewards)
	if pFreeList then
		pFreeList:setIsCanScroll(false)	 
	end	
	if pData:isCanGetRankPrize() then	
		self.pBtn:setBtnEnable(true)
		self.pBtn:showLingTx()
	else		
		self.pBtn:setBtnEnable(false)
		self.pBtn:removeLingTx()
	end	

	self.tListData = getArenaAwards()
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


function ArenaRankReward:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaRank.new(1, 640, 120)
		-- pView:setItemClickedHandler(handler(self, self.onRankItemClicked))
	end
	pView:setCurData(self.tListData[_index])	
	return pView
end

--领取按钮
function ArenaRankReward:onBtnGetClicked(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end	
	if not pData:isCanGetRankPrize() then
		return
	end
	SocketManager:sendMsg("reqGetArenaRankPrize", {}, function ( __msg )
		if  __msg.head.state == SocketErrorType.success then 
           	if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
			end	
        else
            TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
	end)		
end

--析构方法
function ArenaRankReward:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaRankReward:regMsgs( )
	-- body	

	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))			
end

-- 注销消息
function ArenaRankReward:unregMsgs(  )
	-- body

	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaRankReward:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaRankReward:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaRankReward
