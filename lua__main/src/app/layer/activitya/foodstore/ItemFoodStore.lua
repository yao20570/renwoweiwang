-- Author: maheng
-- Date: 2017-06-28 13:55:17
-- 锻造排行

local MCommonView = require("app.common.MCommonView")
local ItemActRankContent = require("app.layer.activitya.ItemActRankContent")

local ItemFoodStore = class("ItemFoodStore", function()
	return ItemActRankContent.new(e_id_activity.foodstore)
end)

--创建函数
function ItemFoodStore:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemFoodStore",handler(self, self.onDestroy))

end

--初始化参数
function ItemFoodStore:myInit()
	self.pData = nil --数据
end

--初始化控件
function ItemFoodStore:setupViews( )
	--self:setMHandler(handler(self, self.onClicked))
	--设置前三名的显示信息
	self:setRankCardDataIndex(getConvertedStr(6, 10506), "tl")
	--设置领奖回调
	self:setGetPrizeHandler(handler(self, self.onReqGetPrizeCallBack))
	--设置礼品列表			
	--请求排行数据
	self:sendGetRankDataRequest()
end

-- 修改控件内容或者是刷新控件数据
function ItemFoodStore:updateViews(  )
	-- body
	--按钮切换
	if self.pData then
		self:refreshRankPrize()--刷新界面奖励状态		
		--self:setActTime()--时间更新函数
	end
end

--析构方法
function ItemFoodStore:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemFoodStore:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	--注册排行数据刷新消息
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankListView))
	--活动排行结算消息
	regMsg(self, ghd_rank_act_accounts_msg, handler(self, self.reReqRankInfo))	

end

-- 注销消息
function ItemFoodStore:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	--注销排行数据刷新消息
	unregMsg(self, gud_refresh_rankinfo)
	--注销活动排行结算消息
	unregMsg(self, ghd_rank_act_accounts_msg)

end


--设置数据 _data
function ItemFoodStore:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or nil
	self:setCurData(self.pData)	
	self:updateViews()		
end

--刷新排行列表数据
function ItemFoodStore:updateRankListView( )
	-- body
	self:refreshRankList()--刷新排行榜数据
	--刷新我的排行数据
	self:refreshMyRankInfo()	
end
--
--获取奖励
function ItemFoodStore:onReqGetPrizeCallBack( tData )
	-- body
	if tData then
		SocketManager:sendMsg("reqTLRankPrize", {tData.nId}, function ( __msg )
			-- body
			--dump(__msg, "reqTLRankPrize", 100)
			if  __msg.head.state == SocketErrorType.success then 
				if __msg.head.type == MsgType.reqTLRankPrize.id then
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
return ItemFoodStore