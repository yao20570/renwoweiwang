----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-29 09:45:21
-- Description: 年兽来袭 排行奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemNianRankAward = require("app.layer.activityb.nianattack.ItemNianRankAward")

local NianRankAward = class("NianRankAward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function NianRankAward:ctor( _tSize )
	--解析文件
	self:setContentSize(_tSize)
	parseView("lay_nian_award", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NianRankAward:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NianRankAward", handler(self, self.onNianRankAwardDestroy))

end

-- 析构方法
function NianRankAward:onNianRankAwardDestroy(  )
    self:onPause()
end

function NianRankAward:regMsgs(  )
end

function NianRankAward:unregMsgs(  )
end

function NianRankAward:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function NianRankAward:onPause(  )
	self:unregMsgs()
end

function NianRankAward:setupViews(  )
	self.pLayList = self:findViewByName("lay_listview")
end


function NianRankAward:updateViews(  )
    self:updateListView()
end

function NianRankAward:updateListView(  )
	local tActData = Player:getActById(e_id_activity.nianattack)
	if not tActData then
		return
	end
	self.tListData = tActData:getRankAwardList()
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  10},
            direction = MUI.MScrollView.DIRECTION_VERTICAL,
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemNianRankAward.new()  
		    end   
		    pTempView:setCurData(self.tListData[_index])
		    return pTempView
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

return NianRankAward


