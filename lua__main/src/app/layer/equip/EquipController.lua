----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-27 11:16:38
-- Description: 装备相关控制类
-----------------------------------------------------
local EquipData = require("app.layer.equip.data.EquipData")

--获取装备数据单例
function Player:getEquipData(  )
	if not Player.equipData then
		self:initEquipData()
	end
	return Player.equipData
end

--初始化装备数据
function Player:initEquipData(  )
	if not Player.equipData then
		Player.equipData = EquipData.new()
	end
	return "Player.equipData"
end

--释放装备数据
function Player:releasEquipData()
	if Player.equipData then
		Player.equipData:release()
		Player.equipData = nil
	end
	return "Player.equipData"
end

--[7000]加载玩家装备数据
SocketManager:registerDataCallBack("reqEquipLoad",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipLoad=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipLoad.id then
			Player:getEquipData():onReqEquipLoad(__msg.body)
			sendMsg(gud_equip_hero_equip_change)
			sendMsg(gud_equip_makevo_change_msg)
			sendMsg(gud_equip_makevo_refresh_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-7001]装备数据变化推送
SocketManager:registerDataCallBack("pushEquipChange",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"pushEquipChange=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushEquipChange.id then
			Player:getEquipData():onPushEquipChange(__msg.body)
			sendMsg(gud_equip_hero_equip_change)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7002]装备恢复免费洗炼次数
SocketManager:registerDataCallBack("refreshEquipFreeTrain",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"refreshEquipFreeTrain=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.refreshEquipFreeTrain.id then
			Player:getEquipData():onRefreshEquipFreeTrain(__msg.body)
			sendMsg(gud_equip_refine_cd_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7003]装备洗炼
SocketManager:registerDataCallBack("reqEquipTrain",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipTrain=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipTrain.id then
			Player:getEquipData():onReqEquipTrain(__msg.body)
			sendMsg(gud_equip_refine_success_msg)
			-- sendMsg(gud_equip_hero_equip_change)
		end
	else
		sendMsg(gud_equip_refine_Fail_msg)
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[7004]装备高级洗炼
SocketManager:registerDataCallBack("reqEquipHighTrain",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipHighTrain=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipHighTrain.id then
			Player:getEquipData():onReqEquipHighTrain(__msg.body)
			sendMsg(gud_equip_refine_success_msg)
			-- sendMsg(gud_equip_hero_equip_change)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7005]穿上装备
SocketManager:registerDataCallBack("reqEquipWear",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipWear=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipWear.id then
			Player:getEquipData():onReqEquipWear(__msg.body)
			sendMsg(gud_equip_hero_equip_change)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7006]解下装备
SocketManager:registerDataCallBack("reqEquipTakeOff",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipTakeOff=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipTakeOff.id then
			Player:getEquipData():onReqEquipTakeOff(__msg.body)
			sendMsg(gud_equip_hero_equip_change)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7007]购买装备容量
SocketManager:registerDataCallBack("reqEquipCapacity",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipCapacity=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipCapacity.id then
			Player:getEquipData():onReqEquipCapacity(__msg.body)
			sendMsg(gud_refresh_baginfo)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7008]打造装备
SocketManager:registerDataCallBack("reqEquipMake",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipMake=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipMake.id then
			Player:getEquipData():onReqEquipMake(__msg.body)
			sendMsg(gud_equip_makevo_change_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7009]雇佣铁匠
SocketManager:registerDataCallBack("reqSmithHire",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqSmithHire=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqSmithHire.id then
			local smithId = __oldMsg[1]
			Player:getEquipData():setSmithId(smithId)
			Player:getEquipData():setSmithIsFree(__msg.body.sg)
			Player:getEquipData():onReqSmithHire(__msg.body)
			sendMsg(gud_equip_smith_hire_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7010]铁匠加速打造
SocketManager:registerDataCallBack("reqMakeQuick",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqMakeQuick=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMakeQuick.id then
			Player:getEquipData():onReqMakeQuick(__msg.body)
			sendMsg(gud_equip_makevo_change_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7011]金币加速完成装备打造
SocketManager:registerDataCallBack("reqMakeQuickByCoin",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqMakeQuickByCoin=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMakeQuickByCoin.id then
			Player:getEquipData():onReqMakeQuickByCoin(__msg.body)
			sendMsg(gud_equip_makevo_change_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7017]世界成员加速
SocketManager:registerDataCallBack("makevoupdatepush",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"makevoupdatepush=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.makevoupdatepush.id then
			Player:getEquipData():onReqMakeQuickByCoin(__msg.body)
			sendMsg(gud_equip_makevo_change_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[7012]领取打造的装备
SocketManager:registerDataCallBack("reqEquipGet",function ( __type, __msg, __oldMsg)
	-- dump(__msg,"reqEquipGet=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipGet.id then
			Player:getEquipData():onReqEquipGet()
			sendMsg(gud_equip_makevo_refresh_msg)
			--推送玩家物品数据
			Player:getEquipData():updateEquipById(__msg.body)
			sendMsg(gud_equip_hero_equip_change)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7013]分解装备
SocketManager:registerDataCallBack("reqEquipDecompose",function ( __type, __msg, __oldMsg)
	--dump(__msg,"reqEquipDecompose=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqEquipDecompose.id then
			local sUuid = __oldMsg[1]
			Player:getEquipData():onReqEquipDecompose(__msg.body, sUuid)
			sendMsg(gud_refresh_baginfo)
			if __msg.body.ds then
				showGetAllItems(__msg.body.ds)
			end 			
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7014]强化装备
SocketManager:registerDataCallBack("reqEquipStrengthen",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		-- dump(__msg.body,"reqEquipStrengthen=",100)
		if __msg.head.type == MsgType.reqEquipStrengthen.id then
			local sUuid = __oldMsg[1]
			Player:getEquipData():onReqEquipStrengthen(__msg.body, sUuid)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[7015]装备道具加速
SocketManager:registerDataCallBack("speedMakeEquip",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		Player:getEquipData():onReqEquipMake(__msg.body)
		sendMsg(gud_equip_makevo_change_msg)
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)