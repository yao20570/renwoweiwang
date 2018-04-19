-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 16:40:23 星期三
-- Description: 竞技场 排名奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaRank = require("app.layer.arena.ItemArenaRank")

local ArenaLuckyReward = class("ArenaLuckyReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaLuckyReward:ctor()
	-- body
	self:myInit()
	parseView("lay_arena_lucky_reward", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaLuckyReward:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaLuckyReward",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaLuckyReward:myInit()
	-- body	
	self.tAwardItems = {}	
	self.tTitlePos = {80, 320, 530}
end

--初始化控件
function ArenaLuckyReward:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top")
	self.pLbPar1 		= 		self:findViewByName("lb_par_1")
	self.pLbPar2 		= 		self:findViewByName("lb_par_2")

	self.pLayTitles 	= 		self:findViewByName("lay_rank_titles")
	self.pLayBtnGet 	= 		self:findViewByName("lay_btn_get")
	self.pLayRewards 	= 		self:findViewByName("lay_rewards")

	self.pLayList 		= 		self:findViewByName("lay_list")


	self.pLbPar2:setString(getConvertedStr(6, 10805), false) 

	self.pBtn = getCommonButtonOfContainer(self.pLayBtnGet,TypeCommonBtn.M_YELLOW,getConvertedStr(6,10189))	    
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnGetClicked))

	local tTitle = {
		getConvertedStr(6, 10806),
		getConvertedStr(6, 10807),
		getConvertedStr(6, 10808),
	}
	for i = 1, 3 do
		local pLabel = MUI.MLabel.new({
	        text=tTitle[i],
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tTitlePos[i], self.pLayTitles:getHeight()/2)		
		self.pLayTitles:addView(pLabel)
	end	    
end

-- 修改控件内容或者是刷新控件数据
function ArenaLuckyReward:updateViews(  )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	--我的上期排名
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10810)},
		{color=_cc.blue, text=pData.nYr},
	}
	if pData:isLuckyPrevTime() then
		table.insert(sStr, {color=_cc.purple,text=getConvertedStr(6, 10725)})
	end 	
	self.pLbPar1:setString(sStr, false)

	if pData:isCanGetLuckyPrize() then	
		self.pBtn:setBtnEnable(true)
		self.pBtn:showLingTx()				
	else
		self.pBtn:setBtnEnable(false)
		self.pBtn:removeLingTx()
	end	

	self.tListData = pData:getLuckyListData()
	-- dump(self.tListData, "self.tListData")
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


function ArenaLuckyReward:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaRank.new(3, 640, 120, self.tTitlePos)
		pView:setItemClickedHandler(handler(self, self.onRankItemClicked))
	end
	pView:setCurData(self.tListData[_index])	
	return pView
end

function ArenaLuckyReward:onRankItemClicked( _tData )
	-- body
	if _tData then
		if _tData.isnpc and _tData.isnpc == 0 then
			local sPlayerId = _tData.id 
			SocketManager:sendMsg("checkArenaPlayer", {sPlayerId}) --刷新竞技场幸运列表	
		end
	end	
end

--领取按钮
function ArenaLuckyReward:onBtnGetClicked(  )
	-- body
	
	local pData = Player:getArenaData()
	if not pData then
		return
	end	
	if not pData:isCanGetLuckyPrize() then
		return
	end
	SocketManager:sendMsg("reqGetArenaLuckyPrize", {}, function ( __msg )
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
function ArenaLuckyReward:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaLuckyReward:regMsgs( )
	-- body	

	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))			
end

-- 注销消息
function ArenaLuckyReward:unregMsgs(  )
	-- body

	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaLuckyReward:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaLuckyReward:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaLuckyReward
