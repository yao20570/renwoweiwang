-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-14 11:57:23 星期三
-- Description: 纣王试炼积分排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActivityRank = require("app.layer.activitya.ItemActivityRank")
local LayZhouWangTrialRank = class("LayZhouWangTrialRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayZhouWangTrialRank:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_zhouwang_trial_rank", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayZhouWangTrialRank:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayZhouWangTrialRank",handler(self, self.onDestroy))
end

-- --初始化参数
function LayZhouWangTrialRank:myInit()
	-- body
	self.tLbTitles = {}
end

--初始化控件
function LayZhouWangTrialRank:setupViews( )
	-- body	
	self.pLayRoot 	= 	self:findViewByName("lay_main")
	self.pLbPar1 	= 	self:findViewByName("lb_par_1")
	self.pLbPar2 	= 	self:findViewByName("lb_par_2")
	self.pLbPar3 	= 	self:findViewByName("lb_par_3")

	self.pLayRankTitle = self:findViewByName("lay_rank_title")
	self.pLayRankList = self:findViewByName("lay_list")
	self.pLbTip = self:findViewByName("lb_tip_bot")
	self.tLbCountrys = {}
	self.tLbScores = {}
	self.tLbNul = {}
	for i = 1, 3 do
		local pLb = self:findViewByName("img_country_"..i)
		self.tLbCountrys[i] = pLb
		local pLbScore = self:findViewByName("lb_score_"..i)
		self.tLbScores[i] = pLbScore
		local pLbNull = self:findViewByName("lb_null_"..i)
	    pLbNull:setString(getConvertedStr(10, 90003))
	    pLbNull:setVisible(false)		
		self.tLbNul[i] = pLbNull
	end	
	self.pLbTip:setString(getConvertedStr(6, 10469), false)
	self.pLbPar1:setString(getTipsByIndex(20144)) --配表
	--初始化排行榜标题
	self:initRankTitles()	
end

--初始化排行榜标题
function LayZhouWangTrialRank:initRankTitles(  )
	-- body
	-- self.pLayRankTitle
	local nwidth = self.pLayRankTitle:getWidth()
	local nheight = self.pLayRankTitle:getHeight()	
	local t1, t2 = getRankSetTypePos(e_rank_type.zhouwangtrial)
	for i = 1, 5 do 
		if not self.tLbTitles[i] then
				local pLabel = MUI.MLabel.new({
		        text = "",
		        size = 20,
		        anchorpoint=cc.p(0.5, 0.5)
	        })
			pLabel:setViewTouched(false)
			self.pLayRankTitle:addView(pLabel, 100)
			pLabel:setPositionY(self.pLayRankTitle:getHeight()/2)
			self.tLbTitles[i] = pLabel
		end
		if t2[i] and t1[i] then				
			self.tLbTitles[i]:setVisible(true)
			self.tLbTitles[i]:setString(t2[i])
			self.tLbTitles[i]:setPositionX(t1[i]*nwidth)
		else
			self.tLbTitles[i]:setVisible(false)
		end
	end
end

function LayZhouWangTrialRank:updateListView(  )
	self.tListData = Player:getRankInfo():getRankDataList()
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayRankList:getWidth(), self.pLayRankList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL or _direction ,--listView方向            
        }
        self.pLayRankList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemActivityRank.new(60, 640, true)  
		        pTempView:setHandler(handler(self, self.onRankItemClick))
		    end
		    pTempView:setCurData(self.tListData[_index])
		    return pTempView
		end)	
		self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		local nnextPage = Player:getRankInfo().nCurrPage + 1
		    	self:refreshRankData(e_rank_type.zhouwangtrial, nnextPage, handler(self, self.updateListView))
	    	end
	    end)		
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nCnt)
		self.pListView:reload(false)		
	else
		self.pListView:notifyDataSetChange(false, nCnt)		
	end
end

-- 修改控件内容或者是刷新控件数据
function LayZhouWangTrialRank:updateViews(  )
	-- body
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	if not pData then
		return
	end	
	--国家排名国家积分
	local tPs = pData.tPs--国家积分排行
	for i, data in pairs(tPs) do
		self.tLbCountrys[i]:setCurrentImage(getCountryShortImg(data.k))		
		local sStr = {
			{color=_cc.pwhite, text=getConvertedStr(3, 10494)},
			{color=_cc.white, text=data.v}
		}
		self.tLbScores[i]:setString(sStr, false)
		self.tLbCountrys[i]:setVisible(data.v > 0)
		self.tLbScores[i]:setVisible(data.v > 0)
		self.tLbNul[i]:setVisible(data.v <= 0)
	end
	--我的排名
	local sMyRank = getConvertedStr(6, 10452)
	if pData.nR == 0 then
		sMyRank = getConvertedStr(6, 10452)
	elseif pData.nR > 0 then
		sMyRank = pData.nR
	end
	local sStr2 = {
		{color=_cc.pwhite, text=getConvertedStr(3, 10495)},
		{color=_cc.blue, text=sMyRank}
	}
	self.pLbPar2:setString(sStr2, false)
	--我的积分
	local sStr3 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10555)},
		{color=_cc.blue, text=pData.nP}
	}
	self.pLbPar3:setString(sStr3, false)
end

function LayZhouWangTrialRank:reqRankInfo(  )
	--刷新国家排行数据
	SocketManager:sendMsg("reqZhouwangCountryRank", {})
	--刷新排行榜
	self:refreshRankData(e_rank_type.zhouwangtrial, 1, handler(self, self.updateListView))
end

function LayZhouWangTrialRank:refreshRankData( _nType, _npag, handler )
	-- body
 	local nCurRank = Player:getRankInfo().nRankType
	local iscanask = Player:getRankInfo():isCanAskForNextPag(_nType)
	local nPage = _npag or 1
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		if nPage == 1 and nCurRank == _nType and handler then--当前已有数据且不翻页的情况下直接刷新数据
			handler()
		end
		return
	end
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {_nType, nPage, 20}, function ( __msg )
		if handler then
			handler()
		end		
		self.bIsAskingData = false
	end)
	-- end
end

--析构方法
function LayZhouWangTrialRank:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayZhouWangTrialRank:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function LayZhouWangTrialRank:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end
--暂停方法
function LayZhouWangTrialRank:onPause( )
	-- body
	self:unregMsgs()
	sendMsg(ghd_clear_rankinfo_msg)
end

--继续方法
function LayZhouWangTrialRank:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayZhouWangTrialRank
