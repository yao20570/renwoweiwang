-- Author: maheng
-- Date: 2017-06-28 13:55:17
-- 屯铁排行

local MCommonView = require("app.common.MCommonView")
local ItemActRankContent = require("app.layer.activitya.ItemActRankContent")

local ItemIronStore = class("ItemIronStore", function()
	return ItemActRankContent.new(e_id_activity.ironstore)
end)

--创建函数
function ItemIronStore:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemIronStore",handler(self, self.onDestroy))

end

--初始化参数
function ItemIronStore:myInit()
	self.pData = nil --数据
end

--初始化控件
function ItemIronStore:setupViews( )
	--self:setMHandler(handler(self, self.onClicked))
	--设置前三名的显示信息
	self:setRankCardDataIndex(getConvertedStr(6, 10507), "tt")
	--设置领奖回调
	self:setGetPrizeHandler(handler(self, self.onReqGetPrizeCallBack))
	--设置礼品列表
	--请求排行数据
	self:sendGetRankDataRequest()
end

-- 修改控件内容或者是刷新控件数据
function ItemIronStore:updateViews(  )
	-- body
	if self.pData then
		self:refreshRankPrize()--刷新界面奖励状态		
		self:setActTime()--时间更新函数
	end
end

--析构方法
function ItemIronStore:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemIronStore:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	--注册排行数据刷新消息
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankListView))
	--活动排行结算消息
	regMsg(self, ghd_rank_act_accounts_msg, handler(self, self.reReqRankInfo))	

end

-- 注销消息
function ItemIronStore:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	--注销排行数据刷新消息
	unregMsg(self, gud_refresh_rankinfo)
	--注销活动排行结算消息
	unregMsg(self, ghd_rank_act_accounts_msg)

end


--设置数据 _data
function ItemIronStore:setData(_tData)	
	if not _tData then
		return
	end

	--dump(_tData, "_tData", 100)
	self.pData = _tData or nil
	self:setCurData(self.pData)	
	self:updateViews()		
end

--刷新排行列表数据
function ItemIronStore:updateRankListView( )
	-- body
	self:refreshRankList()--刷新排行榜数据	
		--刷新我的排行数据
	self:refreshMyRankInfo()
end
--
--获取奖励
function ItemIronStore:onReqGetPrizeCallBack( tData )
	-- body
	if tData then
		SocketManager:sendMsg("reqTTRankPrize", {tData.nId}, function ( __msg )
			-- body
			--dump(__msg, "reqTTRankPrize", 100)
			if  __msg.head.state == SocketErrorType.success then 
				if __msg.head.type == MsgType.reqTTRankPrize.id then
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
return ItemIronStore