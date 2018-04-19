----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-26 10:34:57
-- Description: 福星高照（奖励）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemLuckyStarReward = require("app.layer.activityb.luckystar.ItemLuckyStarReward")

local LuckyStarReward = class("LuckyStarReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LuckyStarReward:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lucky_star_reward", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LuckyStarReward:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LuckyStarReward", handler(self, self.onLuckyStarRewardDestroy))

end

-- 析构方法
function LuckyStarReward:onLuckyStarRewardDestroy(  )
    self:onPause()
end

function LuckyStarReward:regMsgs(  )
	-- regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function LuckyStarReward:unregMsgs(  )
	-- unregMsg(self, gud_refresh_activity)
end

function LuckyStarReward:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LuckyStarReward:onPause(  )
	self:unregMsgs()
end

function LuckyStarReward:setupViews(  )
	self.pLayList= self:findViewByName("lay_list")
	

end

function LuckyStarReward:updateViews(  )
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end

	local tList = tActData.tConfs

	-- --更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pLayList:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 20,
	            right  = 0,
	            top    = 0, 
	            bottom = 10}
	    }
	    self.pLayList:addView(self.pListView)
		local nCount = table.nums(tList)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemLuckyStarReward.new()
			end
			pTempView:setData(tList[_index])
		    return pTempView
		end)
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true)
	end


	

end


return LuckyStarReward



