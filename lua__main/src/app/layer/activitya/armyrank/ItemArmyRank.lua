-- Author: maheng
-- Date: 2017-06-28 13:55:17
-- 兵力排行

local MCommonView = require("app.common.MCommonView")
local ItemActRankContent = require("app.layer.activitya.ItemActRankContent")

local ItemArmyRank = class("ItemArmyRank", function()
	return ItemActRankContent.new(e_id_activity.armyrank)
end)


--创建函数
function ItemArmyRank:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemArmyRank",handler(self, self.onDestroy))
end

--初始化参数
function ItemArmyRank:myInit()
	self.pData = nil --数据
end

--初始化控件
function ItemArmyRank:setupViews( )
	--self:setMHandler(handler(self, self.onClicked))
	--设置前三名的显示信息
	self:setRankCardDataIndex(getConvertedStr(6, 10505), "bl")
	--设置领奖回调
	self:setGetPrizeHandler(handler(self, self.onReqGetPrizeCallBack))
	--设置礼品列表
	--请求排行数据
	self:sendGetRankDataRequest()
end

-- 修改控件内容或者是刷新控件数据
function ItemArmyRank:updateViews(  )
	-- body
	if self.pData then
		self:refreshRankPrize()--刷新界面奖励状态		
		self:setActTime()--时间更新函数
	end
end

--析构方法
function ItemArmyRank:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemArmyRank:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	--注册排行数据刷新消息
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankListView))
	--活动排行结算消息,重新请求排行数据
	regMsg(self, ghd_rank_act_accounts_msg, handler(self, self.reReqRankInfo))

end

-- 注销消息
function ItemArmyRank:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	--注销排行数据刷新消息
	unregMsg(self, gud_refresh_rankinfo)
	--注销活动排行结算消息
	unregMsg(self, ghd_rank_act_accounts_msg)

end


--设置数据 _data
function ItemArmyRank:setData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or nil
	self:setCurData(self.pData)	
	self:updateViews()		
end

--刷新排行列表数据
function ItemArmyRank:updateRankListView( )
	-- body
	--根据当前玩家当前排名刷新当前的活动奖励状态
	self:refreshRankList()--刷新排行榜数据
	--刷新我的排行数据
	self:refreshMyRankInfo()	
end
--
--获取奖励
function ItemArmyRank:onReqGetPrizeCallBack( tData )
	-- body
	if tData then
		SocketManager:sendMsg("reqBLRankPrize", {tData.nId}, function ( __msg )
			-- body
			--dump(__msg, "reqBLRankPrize", 100)
			if  __msg.head.state == SocketErrorType.success then 
				if __msg.head.type == MsgType.reqBLRankPrize.id then
					if __msg.body.ob then
						--获取物品效果
						showGetAllItems(__msg.body.ob)
					end					
				end
			else
		        TOAST(SocketManager:getErrorStr(__msg.head.state))
		    end
		end, -1)
	end
end
return ItemArmyRank