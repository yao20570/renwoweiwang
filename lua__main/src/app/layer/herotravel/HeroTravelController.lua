-----------------------------------------------------
-- Author: luwenjing
-- Date: 2017-12-07 21:18:41
-- Description: 武将游历数据控制类
-----------------------------------------------------

local DataHeroTravel = require("app.layer.herotravel.DataHeroTravel")
local DataHero = require("app.layer.hero.data.DataHero")

--获得数据单例
function Player:getHeroTravelData()
	-- body
	if not Player.pDataHeroTravel then
		self:initHeroTravelData()
	end
	return Player.pDataHeroTravel
end

-- 初始化数据
function Player:initHeroTravelData(  )
	if not Player.pDataHeroTravel then
		Player.pDataHeroTravel = DataHeroTravel.new()
	end
	return "Player.pDataHeroTravel"
end

--释放数据
function Player:releaseHeroTravelData(  )
	if Player.pDataHeroTravel then
		Player.pDataHeroTravel = nil
	end
	return "Player.pDataHeroTravel"
end


--获取武将游历数据
SocketManager:registerDataCallBack("heroTravelRes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"travel",100)
			Player:getHeroTravelData():refreshDatasByServer(__msg.body)
		end
	end
end)

--开始武将游历
SocketManager:registerDataCallBack("startHeroTravel",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"travel222",100)
			-- local tTraveData=Player:getHeroTravelData():getTraveDataByQId(__msg.body.qid)
			-- if tTraveData then

			-- end
			Player:getHeroTravelData():refreshTravelData(__msg.body)
			local tObject={}
			tObject.nQid = __msg.body.qid
			sendMsg(ghd_hero_travel_update,tObject)

			TOAST(getConvertedStr(9,10047))
		end
	end
end)

--结束武将游历
SocketManager:registerDataCallBack("HeroTravelFinish",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"travel111",100)
			if __msg.body.ob then
				showGetAllItems(__msg.body.ob)
			end
			Player:getHeroTravelData():refreshTravelData(__msg.body)
			local tObject={}
			tObject.nQid = __msg.body.qid
			sendMsg(ghd_hero_travel_update,tObject)

		end
	end
end)

--武将游历数据推送
SocketManager:registerDataCallBack("HeroTravelDataPush",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body,"travel",100)
			Player:getHeroTravelData():refreshDatasByServer(__msg.body)
			sendMsg(ghd_hero_travel_push)

		end
	end
end)
