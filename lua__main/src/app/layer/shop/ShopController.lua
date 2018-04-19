----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-10 15:00:40
-- Description: 商店控制类
-----------------------------------------------------
local ShopData = require("app.layer.shop.data.ShopData")

--获取商店数据单例
function Player:getShopData(  )
	if not Player.shopData then
		self:initShopData()
	end
	return Player.shopData
end

--初始化商店数据
function Player:initShopData(  )
	if not Player.shopData then
		Player.shopData = ShopData.new()
	end
	return "Player.shopData"
end

--释放商店数据
function Player:releaseShopData()
	if Player.shopData then
		Player.shopData:release()
		Player.shopData = nil
	end
	return "Player.shopData"
end

--[8502]加载数据
SocketManager:registerDataCallBack("reqShopLoad",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqShopLoad=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqShopLoad.id then
			if __msg.body then
				Player:getShopData():onShopLoad(__msg.body)
				sendMsg(gud_shop_data_update_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[8503]珍宝阁翻牌
SocketManager:registerDataCallBack("reqTreasureShopFlip",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqTreasureShopFlip=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqTreasureShopFlip.id then
			if __msg.body then
				Player:getShopData():onTreasureShopFlip(__msg.body)
				local nExchangeId = __oldMsg[1]
				sendMsg(ghd_treasure_shop_flip_card_msg, nExchangeId)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[8504]购买珍宝阁物品
SocketManager:registerDataCallBack("reqTreasureShopBuy",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqTreasureShopBuy=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqTreasureShopBuy.id then
			if __msg.body then
				if __msg.body.o then
					showGetAllItems(__msg.body.o)
				end
				Player:getShopData():onTreasureShopBuy(__msg.body)
				sendMsg(gud_shop_data_update_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[8500]购买商店物品
SocketManager:registerDataCallBack("reqShopBuy",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqShopBuy=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqShopBuy.id then
			if __msg.body then
				showGetAllItems(__msg.body.o) -- o	List<Pair<Integer,Long>>	获得物品
				Player:getShopData():updateVipDiscount(__msg.body.discount) --discount	VipDiscount	VIP商店购买打折物品记录
				Player:getShopData():setDayFreeIds(__msg.body.fb) --fb Set<Integer>	VIP商店物品每天免费购买记录
				Player:getShopData():updateMaterialBuyNumVo(__msg.body.mo) -- mo	MaterialBuyNumVo	材料商店物品购买次数记录
				local nExchange = __oldMsg[1]
				sendMsg(ghd_shop_buy_success_msg, nExchange)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[8501]商店数据更新推送
SocketManager:registerDataCallBack("pushShopUpdate",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"pushShopUpdate=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushShopUpdate.id then
			if __msg.body then
				Player:getShopData():onShopUpdate(__msg.body)
				sendMsg(gud_shop_data_update_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[8506]商队兑换
SocketManager:registerDataCallBack("reqResExchange",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqResExchange.id then
			if __msg.body then
				Player:getShopData():onMerchantsExchange(__msg.body)
				sendMsg(gud_refresh_merchants)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)



--物品效果类型
e_exchange_id = {
	food		= 2,			--1h产量粮草
	coin 		= 3,			--1h产量银币
	wood 		= 4,			--1h产量木材
	iron        = 5, 			--1h产量铁矿
}
