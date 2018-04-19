----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-18 11:18:23
-- Description: buff系统
-----------------------------------------------------
local BuffData = require("app.layer.buff.data.BuffData")

--获取buff数据单例
function Player:getBuffData(  )
	if not Player.buffData then
		self:initBuffData()
	end
	return Player.buffData
end

--初始化buff数据
function Player:initBuffData(  )
	if not Player.buffData then
		Player.buffData = BuffData.new()
	end
	return "Player.buffData"
end

--释放buff数据
function Player:releaseBuffData()
	if Player.buffData then
		Player.buffData:release()
		Player.buffData = nil
	end
	return "Player.buffData"
end

--[8300]加载buff数据
SocketManager:registerDataCallBack("reqBuffLoad",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqBuffLoad=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqBuffLoad.id then
			if __msg.body then
				Player:getBuffData():onBuffLoad(__msg.body)
				sendMsg(gud_buff_update_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

e_buff_ids = {
	cityprotect = 33001,--主城保护
}

--作用效果key
e_buff_key = {
	army_speed_tnoly_add 				= 2, 			 --百分比提升行军基础速度(科技)
	army_speed_item_add 				= 3, 			 --百分比提升行军基础速度(物品)
	countryhelp_time_plus 				= 13, 			 --国家帮助减少的时间（秒）
	countryhelp_count_add 				= 14, 			 --国家帮助的次数增加
	technology_time_plus 				= 15, 			 --缩短科研时间
	attack_army_add 					= 16, 			 --攻打乱军加攻击力
	battle_food_cost_plus 				= 17, 			 --部队出征消耗粮草降低
}