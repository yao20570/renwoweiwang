----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-04-8 10:01:00
-- Description: 新国家系统，国家城池
-----------------------------------------------------
local CountryCityData = require("app.layer.newcountry.countrycity.data.CountryCityData")

--获取国家城池数据单例
function Player:getCountryCityData(  )
	if not Player.countryCityData then
		self:initCountryCityData()
	end
	return Player.countryCityData
end

--初始化国家城池数据
function Player:initCountryCityData(  )
	if not Player.countryCityData then
		Player.countryCityData = CountryCityData.new()
	end
	return "Player.countryCityData"
end

--释放国家城池数据
function Player:releaseCountryCityData()
	if Player.countryCityData then
		Player.countryCityData:release()
		Player.countryCityData = nil
	end
	return "Player.countryCityData"
end

--[5107]国家城池-加载数据
SocketManager:registerDataCallBack("reqCountryCity",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqCountryCity=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqCountryCity.id then
			if __msg.body then
				Player:getCountryCityData():setMyCountryCitys(__msg.body.cs)
				sendMsg(gud_countrycity_data_refresh)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-5108]国家城池-更新数据
SocketManager:registerDataCallBack("pushCountryCityNew",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"pushCountryCityNew=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushCountryCityNew.id then
			if __msg.body then
				Player:getCountryCityData():updateMyCountryCitys(__msg.body.us)
				Player:getCountryCityData():delMyCountryCitys(__msg.body.rs)
				sendMsg(gud_countrycity_data_refresh)
			end
		end
	end
end)

