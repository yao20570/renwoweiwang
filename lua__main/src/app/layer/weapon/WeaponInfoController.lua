-- WeaponInfoController.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-04-13 16:57:29 星期一
-- Description: 神兵信息控制类
-----------------------------------------------------

local WeaponData = require("app.layer.weapon.WeaponData")

e_weapon_id = {
	sword = 201, --天帝剑
}

--请求玩家的神兵数据回调
SocketManager:registerDataCallBack("loadAllWeaponData",function ( __type, __msg )
	-- dump(__msg.body, "神兵数据 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():onLoadAllWeaponInfo(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	end
end)

--请求打造神兵回调
SocketManager:registerDataCallBack("reqBuildWeapon", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
			local tAllPost = Player:getFuben():getAllPost()
			local tObject = {}
			for k, v in pairs(tAllPost) do
				if v.nType == 2 and tonumber(v.sTarget) == __oldMsg[1] then
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

--打造神兵完成(CD结束后请求)回调
SocketManager:registerDataCallBack("reqWeaponNewData", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body, "打造神兵完成 === ")
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--加速打造神兵回调
SocketManager:registerDataCallBack("reqSpeedBuilding", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--请求升级神兵回调
SocketManager:registerDataCallBack("reqWeaponLevelUp", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			--神兵暴击活动数据影响变化
			if __oldMsg then
				local nWeaponId = __oldMsg[1]
				local nActivtCrit = __oldMsg[2]
				if nWeaponId and nActivtCrit then
					Player:getWeaponInfo():setPreCriticalByActivity(nWeaponId, nActivtCrit)
				end
			end
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body, 1)
			sendMsg(gud_refresh_weaponInfo,{nActivtCrit = nActivtCrit}) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--请求进阶神兵回调
SocketManager:registerDataCallBack("reqWeaponAdvance", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--神兵进阶完成(CD结束后请求)回调
SocketManager:registerDataCallBack("reqAdvancedWeaponData", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body, 2)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--请求加速进阶神兵回调
SocketManager:registerDataCallBack("reqSpeedAdvance", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():refreshWeaponInfo(__msg.body, 2)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)

--神兵碎片推送回调
SocketManager:registerDataCallBack("refreshFragments", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():onRefreshFragments(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
		end
	end 
end)

--请求购买神兵碎片
SocketManager:registerDataCallBack("reqBuyFragments", function(__type, __msg, __oldMsg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getWeaponInfo():retBuyFragments(__msg.body)
			sendMsg(gud_refresh_weaponInfo) --通知刷新界面
			TOAST(getConvertedStr(7, 10135))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end 
end)


--获得神兵基础信息单例
function Player:getWeaponInfo()
	-- body
	if not Player.weaponInfos then
		self:initWeaponInfo()
	end
	return Player.weaponInfos
end

-- 初始化神兵基础数据
function Player:initWeaponInfo()
	if not Player.weaponInfos then
		Player.weaponInfos = WeaponData.new() --玩家的神兵基础信息表
	end
	return "Player.weaponInfos"
end

--释放神兵基础数据
function Player:releaseWeaponInfo()
	if Player.weaponInfos then
		Player.weaponInfos = nil --神兵基础信息
	end
	return "Player.weaponInfos"
end