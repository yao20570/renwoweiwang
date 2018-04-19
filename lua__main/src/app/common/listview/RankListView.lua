----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 排行榜列表类
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local RankListView = class("RankListView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function RankListView:ctor( tSize )
	self:setContentSize(tSize)
	self:onParseViewCallback()
end

--解析界面回调
function RankListView:onParseViewCallback(  )
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("RankListView", handler(self, self.onRankListViewDestroy))
end

-- 析构方法
function RankListView:onRankListViewDestroy(  )
    self:onPause()
    sendMsg(ghd_clear_rankinfo_msg)
end

function RankListView:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateViews))
end

function RankListView:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
end

function RankListView:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function RankListView:onPause(  )
	self:unregMsgs()
end

--nCreateFunc:创建子节点的方法
function RankListView:setData( nRankType, nCreateFunc )
	self.nRankType = nRankType
	self.nCreateFunc = nCreateFunc
	self:updateViews()
end

function RankListView:setupViews(  )
end

function RankListView:updateViews(  )
	self:updateListView()
end

function RankListView:updateListView(  )
	if not self.nCreateFunc then
		return
	end
	self.tListData = Player:getRankInfo():getRankDataList()
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
	if not self.pListView then
		local pSize = self:getContentSize()
	    self.pListView = MUI.MListView.new {
	        bgColor = cc.c4b(255, 255, 255, 250),
	        viewRect = cc.rect(0, 0, pSize.width, pSize.height),
	        itemMargin = {left =  0,
	        right =  0,
	        top = 0,
	        bottom =  0},
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,--listView方向            
	    }
	    self:addView(self.pListView)   
	    self.pListView:setItemCallback(function ( _index, _pView )          
	        local pTempView = _pView
	        if pTempView == nil then
	            pTempView = self.nCreateFunc()
	        end
	        if pTempView.setData then
	        	pTempView:setData(self.tListData[_index])
	        else
	        	print("未实现setData方法")
	        end
	        return pTempView
	    end)    
	    self.pListView:onScroll(function ( event )
	        if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		local nnextPage = Player:getRankInfo().nCurrPage + 1
	    		self:reqMoreListData(nnextPage)
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
	self:setDefInfo(nCnt <= 0)

	-- if nCnt == 0 then
	--     if self.pRankNoneTip == nil then
	--     	local ActivityRankNoneTip = require("app.layer.activitya.ActivityRankNoneTip")
	--        self.pRankNoneTip = ActivityRankNoneTip.new()
	--        self.pRankNoneTip:setPosition(0, self.pLayBotInfo:getHeight())
	--        self.pLayBotInfo:addView(self.pRankNoneTip)
	--     end
	-- else
	--     if self.pRankNoneTip ~= nil then
	--         self.pRankNoneTip:setVisible(false)
	--     end
	-- end
end

function RankListView:setDefInfo( _bShow )
	local bShow = _bShow or false
	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	if not self.pNullUi then
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self:addView(pNullUi)
		centerInView(self, pNullUi)
		self.pNullUi = pNullUi
	end
	self.pNullUi:setVisible(bShow)
end

function RankListView:reqMoreListData( npage )
	local nCurtype = self.nRankType
    local npag = npage or 1
    local iscanask = Player:getRankInfo():isCanAskForNextPag(nCurtype)
    if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
        return
    end
    self.bIsAskingData = true
    SocketManager:sendMsg("getRankData", {nCurtype, npag, 15}, handler(self, self.getRankRequestCakkBack))
end

--网络请求回到
function RankListView:getRankRequestCakkBack(__msg)
    self.bIsAskingData = false--请求返回，结束正在请求的状态
    if __msg.head.state == SocketErrorType.success  then                
        --请求成功
    else        
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


return RankListView


