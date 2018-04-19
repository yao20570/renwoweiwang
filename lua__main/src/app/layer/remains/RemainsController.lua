-----------------------------------------------------
-- Author: maheng
-- Date: 2018-3-2 19:30:41
-- Description: 韬光养晦管理
-----------------------------------------------------
local DataRemains = require("app.layer.remains.DataRemains")

--获得数据单例
function Player:getRemainsData()
	-- body
	if not Player.remainsData then
		self:initRemainsData()
	end
	return Player.remainsData
end

-- 初始化数据
function Player:initRemainsData(  )
	if not Player.remainsData then
		Player.remainsData = DataRemains.new()
	end
	return "Player.remainsData"
end

--释放数据
function Player:releaseRemainsData(  )
	if Player.remainsData then
		Player.remainsData = nil
	end
	return "Player.remainsData"
end

--[3631]加载韬光养晦数据
SocketManager:registerDataCallBack("loadTGYHData",function ( __type, __msg )    
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.loadTGYHData.id then
            -- dump(__msg.body, "loadTGYHData __msg= ", 100)
            Player:getRemainsData():refreshDatasByService(__msg.body)
            sendMsg(ghd_remains_refresh_msg)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-3632]数据推送
SocketManager:registerDataCallBack("pushTGYHData",function ( __type, __msg )    
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.pushTGYHData.id then
            -- dump(__msg.body, "pushTGYHData __msg= ", 100)
            Player:getRemainsData():refreshDatasByService(__msg.body)
            sendMsg(ghd_remains_refresh_msg)            
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3633]领取任务奖励
SocketManager:registerDataCallBack("reqTGYHReward",function ( __type, __msg )    
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTGYHReward.id then
            -- dump(__msg.body, "reqTGYHReward __msg= ", 100)
            Player:getRemainsData():refreshDatasByService(__msg.body)
            sendMsg(ghd_remains_refresh_msg)            
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3634]领取免费奖励
SocketManager:registerDataCallBack("reqTGYHFreeReward",function ( __type, __msg )    
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTGYHFreeReward.id then
            -- dump(__msg.body, "reqTGYHFreeReward __msg= ", 100)
            Player:getRemainsData():refreshDatasByService(__msg.body)
            sendMsg(ghd_remains_refresh_msg)                       
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)