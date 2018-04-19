-----------------------------------------------------
-- Author: luwenjing
-- Date: 2017-10-31 10:38:41
-- Description: 免费宝箱数据控制类
-----------------------------------------------------

local DataDailyGift = require("app.layer.dailygift.DataDailyGift")

--获得数据单例
function Player:getDailyGiftData()
	-- body
	if not Player.pDataDailyGift then
		self:initDailyGiftData()
	end
	return Player.pDataDailyGift
end

-- 初始化数据
function Player:initDailyGiftData(  )
	if not Player.pDataDailyGift then
		Player.pDataDailyGift = DataDailyGift.new()
	end
	return "Player.pDataDailyGift"
end

--释放数据
function Player:releaseDailyGiftData(  )
	if Player.pDataDailyGift then
		Player.pDataDailyGift = nil
	end
	return "Player.pDataDailyGift"
end

--检查每日宝箱详细信息
SocketManager:registerDataCallBack("checkDailyGiftRes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getDailyGiftData():refreshDatasByServer(__msg.body)
		end
	end
end)

--每日宝箱获取奖励
SocketManager:registerDataCallBack("getDailyGiftRes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.getDailyGiftRes.id then
			Player:getDailyGiftData():refreshDatasByServer(__msg.body)
			showGetAllItems(__msg.body.ob)
			sendMsg(ghd_daily_gift_push)
		end
	end
end)

--每日宝箱信息推送
SocketManager:registerDataCallBack("updateDailyGiftPush",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getDailyGiftData():refreshDatasByServer(__msg.body)
			sendMsg(ghd_daily_gift_push)

			-- Player:getNoticeData():onLoadNotice(__msg.body)
			-- sendMsg(gud_refresh_notice) --通知刷新界面
		end
	end
end)
