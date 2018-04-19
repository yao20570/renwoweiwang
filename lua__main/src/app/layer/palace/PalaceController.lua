-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-04 10:05:52 星期四
-- Description: 玩家内政资源信息控制类
-----------------------------------------------------

local ResourceData = require("app.layer.palace.ResourceData")


--请求玩家资源数据回调
SocketManager:registerDataCallBack("loadResource",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"加载loadResource=",100)	
		if 	__msg.body then
			--刷新玩家数据
			Player:getResourceData():refreshDatasByService(__msg.body)
			--发送消息刷新玩家界面
			sendMsg(gud_refresh_palace_resource)
		end
    end
end)

--推送玩家资源数据回调
SocketManager:registerDataCallBack("pushResource",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"推送loadResource=",100)
		if __msg.body then
			--刷新玩家数据
			Player:getResourceData():refreshDatasByService(__msg.body)
			--发送消息刷新玩家界面
			sendMsg(gud_refresh_palace_resource)
		end
	end
end)

e_hire_type = {
	official = 1,--文官
	researcher = 2, --研究员
	smith = 3,	--铁匠
}

--获得玩家资源信息单例
function Player:getResourceData()
	-- body
	if not Player.pResourceData then
		self:initResourceData()
	end
	return Player.pResourceData
end

-- 初始化玩家基础数据
function Player:initResourceData(  )
	if not Player.pResourceData then
		Player.pResourceData = ResourceData.new() --玩家的资源信息
	end
	return "Player.pResourceData"
end

--释放玩家资源数据
function Player:releaseResourceData(  )
	if Player.pResourceData then
		Player.pResourceData = nil --玩家的资源信息
	end
	return "Player.pResourceData"
end
