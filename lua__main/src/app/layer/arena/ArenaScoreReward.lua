-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 16:40:23 星期三
-- Description: 竞技场 积分奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaScoreReward = require("app.layer.arena.ItemArenaScoreReward")

local ArenaScoreReward = class("ArenaScoreReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaScoreReward:ctor()
	-- body
	self:myInit()
	parseView("lay_arena_score_reward", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaScoreReward:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaScoreReward",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaScoreReward:myInit()
	-- body
	-- self.tTitlePos = {58, 132, 250, 405, 559}
	self.tAwardItems = {}	
end

--初始化控件
function ArenaScoreReward:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top")
	self.pLbPar1 		= 		self:findViewByName("lb_par_1")
	self.pLbPar2 		= 		self:findViewByName("lb_par_2")
	self.pLbTitle 		= 		self:findViewByName("lb_title_1")
	self.pLbTip 		= 		self:findViewByName("lb_tip")

	self.pLayList 		= 		self:findViewByName("lay_list")

	self.pLbPar1:setString(getTextColorByConfigure(getConvertedStr(6, 10801)), false)
	self.pLbPar2:setString(getTextColorByConfigure(getConvertedStr(6, 10802)), false)
    self.pLbTip:setString(getConvertedStr(6, 10803), false) 

end

-- 修改控件内容或者是刷新控件数据
function ArenaScoreReward:updateViews(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	--我的积分
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10555)},
		{color=_cc.white, text=pData.nScore},
	}
	self.pLbTitle:setString(sStr, false)

	
	self.tListData = pData:getScoreAwardConfs()
	-- dump(self.tListData, "self.tListData", 100)
	-- self.tListData = {}
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


function ArenaScoreReward:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaScoreReward.new()
	end
	pView:setCurData(self.tListData[_index])	
	return pView
end

--析构方法
function ArenaScoreReward:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaScoreReward:regMsgs( )
	-- body	

	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))			
end

-- 注销消息
function ArenaScoreReward:unregMsgs(  )
	-- body

	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaScoreReward:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaScoreReward:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaScoreReward
