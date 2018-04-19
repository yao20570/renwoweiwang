-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题排行榜子项
-----------------------------------------------------
local ItemExamScore = require("app.layer.activityb.exam.ItemExamScore")
local ActivityRankList = require("app.layer.activitya.ActivityRankList")
local ItemActivityRank = require("app.layer.activitya.ItemActivityRank")

local MCommonView = require("app.common.MCommonView")
local ItemExamRank = class("ItemExamRank", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end )

function ItemExamRank:ctor(_tSize)
    self:setContentSize(_tSize)
    -- 解析文件
    parseView("layout_exam_rank", handler(self, self.onParseViewCallback))
    --self:onParseViewCallback()
    --self:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})

    --请求排行榜信息
	--self:sendGetRankDataRequest(1)
end

-- 解析界面回调
function ItemExamRank:onParseViewCallback(pView)
--    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)
    self:init()
    self:setupViews()
    self:onResume()

    -- 注册析构方法
    self:setDestroyHandler("ItemExamRank", handler(self, self.onItemExamRankDestroy))
end

function ItemExamRank:init()
    self.nCurrPage = 0
    self.tLbTitles = {}
end

-- 析构方法
function ItemExamRank:onItemExamRankDestroy()
    self:onPause()
end

function ItemExamRank:regMsgs()
    regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankInfo))		
end

function ItemExamRank:unregMsgs()    
    unregMsg(self, gud_refresh_rankinfo)		
end

function ItemExamRank:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamRank:onPause()
    self:unregMsgs()
end

function ItemExamRank:setupViews()
    self.pLayMain = self:findViewByName("lay_main")
    self.pLayBottom = self:findViewByName("lay_bottom")
    self.pLayTitle = self:findViewByName("lay_title")

    --标题刷新
	self:updateTitles()
end

function ItemExamRank:updateViews()
    self:updateRankInfo()
end

function ItemExamRank:updateRankInfo()
    self.tCurData = Player:getExamRankInfo():getRankDataList()
	if not self.tCurData then
		self.tCurData = {}
	end	

    if not self.pListView then
        local tSize = self:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, tSize.width, tSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }	
		self.pLayMain:addView(self.pListView)
		self.pListView:setBounceable(true) --是否回弹
		self.pListView:setItemCallback(handler(self, self.onSetListItem))
        --self.pListView:onScroll(handler(self, self.onSrollEndCallback))		

		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(#self.tCurData)		
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, #self.tCurData)		
	end

    if not self.pItemExamScore then
        self.pItemExamScore = ItemExamScore.new(e_exam_score_type.rank)
        self.pLayBottom:addView(self.pItemExamScore)                
    end
end

function ItemExamRank:onSetListItem( _index, _pView )
	-- body
 	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemActivityRank.new(60, 640, true)  
        pTempView:setRankType(e_rank_type.exam)                      
        pTempView:setViewTouched(false)
    end   
    if self.tCurData then
    	pTempView:setCurData(self.tCurData[_index])
    end
    return pTempView
end

-- 当列表滑动到底部的时候启动申请请求
function ItemExamRank:onSrollEndCallback(event)
    if event.name == "scrollToFooter" then
        local nNextPage = Player:getExamRankInfo().nCurrPage + 1
        self:getRankRequestCallBack(nNextPage)
    end
end

--发送获取下排行数据请求
function ItemExamRank:sendGetRankDataRequest(nPage)

    --判断是否正在请求数据
    local iscanask = Player:getExamRankInfo():isCanAskForNextPag(e_rank_type.exam)
    if self.bIsAskingData == true or iscanask == false then
        myprint("The last request hasn't come back")
		return
	end
            
    self.bIsAskingData = true

	SocketManager:sendMsg("getRankData", {e_rank_type.world, nPage, 20}, handler(self, self.getRankRequestCallBack))
end

--网络请求回到
function ItemExamRank:getRankRequestCallBack(__msg)
	-- body
	self.bIsAskingData = false--请求返回，结束正在请求的状态
	if __msg.head.state == SocketErrorType.success	then				
		--请求成功
		--self:updateRankInfo()
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

--刷新标题
function ItemExamRank:updateTitles(  )
	-- body
	local nwidth = self.pLayTitle:getWidth()
	local nheight = self.pLayTitle:getHeight()	
	local t1, t2 = getRankSetTypePos(e_rank_type.exam)

	for i = 1, 5 do 
		if not self.tLbTitles[i] then
				local pLabel = MUI.MLabel.new({
		        text = "",
		        size = 20,
		        anchorpoint=cc.p(0.5, 0.5)
	        })
			pLabel:setViewTouched(false)
			self.pLayTitle:addView(pLabel, 100)
			pLabel:setPositionY(self.pLayTitle:getHeight()/2)
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


return ItemExamRank


