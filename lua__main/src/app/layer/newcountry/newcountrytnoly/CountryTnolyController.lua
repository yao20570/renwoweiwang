-- CountryTnolyController.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-30 19:18:29 星期五
-- Description: 国家科技信息控制类
-----------------------------------------------------

local CountryTnolyData = require("app.layer.newcountry.newcountrytnoly.CountryTnolyData")


--[-5101]国家科技-加载科技
SocketManager:registerDataCallBack("loadCountryTnoly",function ( __type, __msg )
	-- dump(__msg.body, "国家科技数据 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadCountryTnoly.id then
			if __msg.body then
				Player:getCountryTnoly():refreshDatasByService(__msg.body)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--[-5102]国家科技-科技捐献
SocketManager:registerDataCallBack("reqTnolyDonate",function ( __type, __msg )
	-- dump(__msg.body, "科技捐献 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqTnolyDonate.id then
			if __msg.body then
				Player:getCountryTnoly():refreshDatasByService(__msg.body)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--[-5103]国家科技-恢复捐献
SocketManager:registerDataCallBack("reqDonateRecover",function ( __type, __msg )
	-- dump(__msg.body, "恢复捐献 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqDonateRecover.id then
			if __msg.body then
				Player:getCountryTnoly():refreshDatasByService(__msg.body)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--[-5104]国家科技-数据更新
SocketManager:registerDataCallBack("pushRefreshCountryTnoly",function ( __type, __msg )
	-- dump(__msg.body, "国家科技数据更新 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.pushRefreshCountryTnoly.id then
			if __msg.body then
				Player:getCountryTnoly():refreshDatasByService(__msg.body)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--[-5105]国家科技-科技推荐
SocketManager:registerDataCallBack("reqRecommendTnoly",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body, "科技推荐 ==")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqRecommendTnoly.id then
			if __msg.body then
				Player:getCountryTnoly():refreshDatasByService(__msg.body)
			end
			if __oldMsg[2] == 1 then
				TOAST(getConvertedStr(7, 10433)) --成功推荐
			elseif __oldMsg[2] == 2 then
				TOAST(getConvertedStr(7, 10434)) --取消推荐
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)


--获得国家科技基础信息单例
function Player:getCountryTnoly()
	-- body
	if not Player.countryTnolyInfo then
		self:initCountryTnoly()
	end
	return Player.countryTnolyInfo
end

-- 初始化国家科技基础数据
function Player:initCountryTnoly()
	if not Player.countryTnolyInfo then
		Player.countryTnolyInfo = CountryTnolyData.new() 
	end
	return "Player.countryTnolyInfo"
end

--释放国家科技基础数据
function Player:releaseCountryTnoly()
	if Player.countryTnolyInfo then
		Player.countryTnolyInfo = nil
	end
	return "Player.countryTnolyInfo"
end