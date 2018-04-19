--
-- Author: liangzhaowei
-- Date: 2017-04-12 20:14:56
-- Description: 副本数据操作类
-----------------------------------------------------



local DataFunbenData = require("app.layer.fuben.DataFunbenData")

--请求副本章节数据回调
SocketManager:registerDataCallBack("loadFubenData",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		-- dump(__msg.body, "副本数据==")
		if __msg.body then
			Player:refreshFubenDatasByService( __msg.body )
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)


--请求玩家基础数据回调
SocketManager:registerDataCallBack("loadFubenSectionData",function ( __type, __msg )
	if __msg.body then
		Player:refreshFubenDatasByService( __msg.body )
	end
end)

--挑战副本关卡数据回调
SocketManager:registerDataCallBack("challengeFubenLevel",function ( __type, __msg, __oldMsg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:refreshFubenDatasByService( __msg.body )
			if __oldMsg then
				Player:getFuben():saveChanllengeId(__oldMsg[1], __oldMsg[2])
			end
			Player:getFuben():saveChanllengeType(1)
			if __msg.body.filed then
				--通知刷新主城郊外资源建筑有图纸掉落
				sendMsg(gud_refresh_suburb_draws)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--扫荡副本关卡数据回调
SocketManager:registerDataCallBack("sweepFubenLevel",function ( __type, __msg, __oldMsg )
	if __msg.head.state == SocketErrorType.success then
		-- dump(__msg.body, "扫荡副本关卡数据==")
		if __msg.body then
			--扫荡结果强制全部显示3星
			__msg.body.star = 3
			Player:refreshFubenDatasByService( __msg.body )
			if __oldMsg then
				Player:getFuben():saveChanllengeId(__oldMsg[1], __oldMsg[3])
			end
			Player:getFuben():saveChanllengeType(2)
			if __msg.body.filed then
				--通知刷新主城郊外资源建筑有图纸掉落
				sendMsg(gud_refresh_suburb_draws)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--购买装备图纸
SocketManager:registerDataCallBack("buyFubenEquip",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:refreshFubenDatasByService( __msg.body )
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)


--副本招募英雄
SocketManager:registerDataCallBack("fubenConscribeHero",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"__msg.body")
			Player:refreshFubenDatasByService( __msg.body )
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--军资补给
SocketManager:registerDataCallBack("fubenSupplyRes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"__msg.body")
			Player:refreshFubenDatasByService( __msg.body )
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--购买军资补给
SocketManager:registerDataCallBack("buyFubenSupplyRes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"__msg.body")
			Player:refreshFubenDatasByService( __msg.body )
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--开启资源田
SocketManager:registerDataCallBack("openresbuild",function ( __type, __msg, __oldMsg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"__msg.body")
			Player:refreshFubenDatasByService( __msg.body )
			local tAllPost = Player:getFuben():getAllPost()
			local tObject = {}
			for k, v in pairs(tAllPost) do
				if v.nType == 5 and tonumber(v.nId) == __oldMsg[1] then
					tObject.nId = v.nId
					if v.closeSpLv then
						v:closeSpLv()
					end
				end
			end
			sendMsg(ghd_refresh_special_level, tObject) --通知刷新特殊关卡
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--副本关卡数据推送
SocketManager:registerDataCallBack("refreshFbLevelData",function ( __type, __msg )
	if __msg.body then
		-- dump(__msg.body,"__msg.body")
		Player:refreshFubenDatasByService( __msg.body )
	end
end)

--副本数据更新推送
SocketManager:registerDataCallBack("pushFbNewData",function ( __type, __msg )
	if __msg.body then
		-- dump(__msg.body,"副本数据更新推送 100==")
		Player:refreshFubenDatasByService( __msg.body )
	end
end)


-- 获得的数据
function Player:getFuben()
	if (not Player.pFubenData) then
		self:initFubenData()
	end
	return Player.pFubenData
end

-- 初始副本数据
function Player:initFubenData()
	if (not Player.pFubenData) then
		Player.pFubenData = DataFunbenData.new()
	end

	return "initFubenData"
end

-- 移除副本数据
function Player:removeFubenData()
	Player.pFubenData = nil
	return "initFubenData"
end

-- 根据服务器数据刷副本数据
function Player:refreshFubenDatasByService( _tData )
	-- dump(_tData, "加载副本数据", 20)
	--刷新副本数据
	Player:getFuben():refreshDatasByService(_tData)

end

