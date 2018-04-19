--
-- Author: maheng
-- Date: 2017-10-30 11:30:29
-- 活动排行奖励行

local MCommonView = require("app.common.MCommonView")
local ItemActivityRank = require("app.layer.activitya.ItemActivityRank")
local ActivityRankNoneTip = require("app.layer.activitya.ActivityRankNoneTip")
local ActivityRankList = class("ActivityRankList", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--_bShowMy 是否显示自己的排行信息
function ActivityRankList:ctor( _bShowMy, nHeight, nItemHeight)
	-- body
	self:myInit(_bShowMy)
	self.nHeight = nHeight or 500
	self.nItemHeight = nItemHeight or 50
	parseView("lay_rank_list", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ActivityRankList",handler(self, self.onDestroy))
	
end

--初始化参数
function ActivityRankList:myInit(_bShowMy)
	self.tLbTitles = {}
	self.tListData = {}
	self.tMyData = nil
	self.tMyRankLbs = {}
	self.nHandlerGetPrize = nil
	self.nFooterHandler = nil
	self.bShowMy = _bShowMy or false

	self.nItemHandler = nil
	self.nRankCnt = 10
end

--解析布局回调事件
function ActivityRankList:onParseViewCallback( pView )	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:onResume()
end

--初始化控件
function ActivityRankList:setupViews( )
	--ly 	
	self.pLayRoot = self:findViewByName("lay_rank_list")
	self:setLayoutSize(self:getWidth(), self.nHeight)
	self.pLayRoot:setLayoutSize(self:getWidth(), self.nHeight)

	self.pLyTitle = self.pLayRoot:findViewByName("lay_top_title")
	self.pLyTitle:setPositionY(self.nHeight - self.pLyTitle:getHeight())

	self.pLayList = self.pLayRoot:findViewByName("lay_list")--玩家数据列表
	self.pLayBotInfo = self.pLayRoot:findViewByName("item_bot")--显示玩家人个排行数据
	self.pLayBotInfo:setVisible(self.bShowMy)


	local nListHeight = 0
	if self.bShowMy then
		nListHeight = self.pLayBotInfo:getHeight()
	end
	local pRect = nil
	if self.bShowMy == false then
		self.pLayList:setLayoutSize(self.pLayRoot:getWidth(), self.pLayRoot:getHeight() - self.pLyTitle:getHeight())
		self.pLayList:setPosition(0, 0)	
	else			
		
	end	
	local nListHeight = self.nHeight - self.pLyTitle:getHeight() - nListHeight
	self.pLayList:setLayoutSize(self.pLayRoot:getWidth(), nListHeight)
	self.pLayList:setPositionY(nListHeight)	
end

function ActivityRankList:updateListView(  )
	-- body		
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL or _direction ,--listView方向            
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemActivityRank.new(self.nItemHeight)  
		        pTempView:setIsPressedNeedScale(false)                      
		        pTempView:setViewTouched(true)
		        pTempView:setHandler(self.nItemHandler)
		    else
		    	
		    end   
		    if self.tListData then
		    	pTempView:setCurData(self.tListData[_index])
		    end
		    return pTempView
		end)	
		self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		if self.nFooterHandler then
	    			self.nFooterHandler()
	    		end
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

    if nCnt == 0 then
        if self.pRankNoneTip == nil then
           self.pRankNoneTip = ActivityRankNoneTip.new()
           self.pRankNoneTip:setPosition(0, self.pLayBotInfo:getHeight())
           self.pLayBotInfo:addView(self.pRankNoneTip)
        end
    else
        if self.pRankNoneTip ~= nil then
            self.pRankNoneTip:setVisible(false)
        end
    end
end
-- 修改控件内容或者是刷新控件数据
function ActivityRankList:updateViews(  )
	-- body
	if not self.nRankType then
		return
	end
	--标题刷新
	self:updateTitles()
	--排行列表刷新
	self:updateListView()
	--刷新我的排行信息
	self:updateMyInfo()
end
--刷新标题
function ActivityRankList:updateTitles(  )
	-- body
	local nwidth = self.pLyTitle:getWidth()
	local nheight = self.pLyTitle:getHeight()	
	local t1, t2 = getRankSetTypePos(self.nRankType)
	for i = 1, 5 do 
		if not self.tLbTitles[i] then
				local pLabel = MUI.MLabel.new({
		        text = "",
		        size = 20,
		        anchorpoint=cc.p(0.5, 0.5)
	        })
			pLabel:setViewTouched(false)
			self.pLyTitle:addView(pLabel, 100)
			pLabel:setPositionY(self.pLyTitle:getHeight()/2)
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


function ActivityRankList:setItemHandler( _nHandler )
	-- body
	self.nItemHandler = _nHandler
end
function ActivityRankList:updateMyInfo(  )
	-- body		
	if self.tMyData then
		--dump(self.tMyData, "self.tMyData", 10)
		--位置更新		
		local nwidth = self.pLayBotInfo:getWidth()
		local nheight = self.pLayBotInfo:getHeight()
		local rankdata = getRankData( self.nRankType )
		local ttypes = luaSplit(rankdata.sort, ";")
		local t1, t2 = getRankSetTypePos(self.nRankType)
		for i = 1, 5 do
			if not self.tMyRankLbs[i] then
				local pLabel = MUI.MLabel.new({
			        text = "",
			        size = 20,
			        anchorpoint=cc.p(0.5, 0.5)
		        })
		        self.pLayBotInfo:addView(pLabel, 10)
		        self.tMyRankLbs[i] = pLabel
			end
			self.tMyRankLbs[i]:setPosition(t1[i]*nwidth, nheight/2)
			setTextCCColor(self.tMyRankLbs[i], _cc.pwhite)
			if ttypes[i] then				
				self.tMyRankLbs[i]:setVisible(true)		
				if ttypes[i] == "c" then--国家
					setTextCCColor(self.tMyRankLbs[i], getColorByCountry(self.tMyData[ttypes[i]]))
					self.tMyRankLbs[i]:setString(getCountryName(self.tMyData[ttypes[i]]))
				elseif ttypes[i] == "ph" then					
					local value = getClassifyName(self.tMyData[ttypes[i]])
					setTextCCColor(self.tMyRankLbs[i], value.color)
					self.tMyRankLbs[i]:setString(value.text)
				else
					self.tMyRankLbs[i]:setString(self.tMyData[ttypes[i]])	
				end
			else
				self.tMyRankLbs[i]:setVisible(false)
			end	    
		end	 

	end
end

--析构方法
function ActivityRankList:onDestroy(  )
	-- body
	self:onPause()
end

function ActivityRankList:regMsgs(  )

end

function ActivityRankList:unregMsgs(  )

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function ActivityRankList:onResume( _bReshow )
	if _bReshow and self.pListView then
		self.pListView:scrollToBegin()	
	end
	self:updateViews()
	self:regMsgs()
end

--暂停方法
function ActivityRankList:onPause(  )
	self:unregMsgs()
end

function ActivityRankList:setRankType( _ntype )
	-- body
	self.nRankType = _ntype or nil
end

function ActivityRankList:setScrollToFooterHandler( _nHandler )
	-- body
	self.nFooterHandler = _nHandler or nil
end
--设置数据 _data
function ActivityRankList:setCurData(_tData)
	self.tListData = {}
	self.tMyData = nil	
	if _tData then
		if _tData.tListData then
			self.tListData = _tData.tListData
		end
		if _tData.tMyData then
			self.tMyData = _tData.tMyData
		end
		self.nRankType = _tData.nRankType or nil
	end
	self:updateViews()
end

function ActivityRankList:onGetPrizeBtnClick( pView )
	-- body	
	if self.nHandlerGetPrize then
		self.nHandlerGetPrize(self.pData)
	end
end

function ActivityRankList:setGetPrizeHandler( _handler )
	-- body
	self.nHandlerGetPrize = _handler
end

function ActivityRankList:getReqRankNum(  )
	-- body
	local nListHeight = self.pLayList:getHeight()
	return math.ceil(nListHeight/self.nItemHeight) 
end
return ActivityRankList