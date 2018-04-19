----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-19 14:43:11
-- Description: 吃鸡
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

e_eat_state = {
	no = 0 ,--没到时间
	eat = 1,--可以吃鸡
	fill = 2, --可以补鸡
	eated = 3, --吃过鸡
}

local DataEatChicken = class("DataEatChicken", function()
	return Activity.new(e_id_activity.eatchicken) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.eatchicken] = function (  )
	return DataEatChicken.new()
end

function DataEatChicken:ctor()
   self:myInit()
end


function DataEatChicken:myInit( )
	self.nEatState = e_eat_state.no
	self.tEatTimeStr = {}
	self.nFillCost = 0
	self.nEnergy = 0
end


-- 读取服务器中的数据
function DataEatChicken:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	--dump(_tData, "吃鸡_tData", 100)
	self.nEatState = _tData.ck or self.nEatState	--Integer	鸡chicken[0没到时间 1可以吃鸡 2可以补鸡]
	if _tData.et then--String	吃鸡时间 eatTime[开始-结束;开始-结束]
		local tStrList = {
			getConvertedStr(3, 10464),
			getConvertedStr(3, 10465),
		}
		local tTimeStr = luaSplitMuilt(_tData.et, ";", "-")
		self.tEatTimeStr = {}
		for i=1,#tTimeStr do
			if tStrList[i] then
				if #tTimeStr[i] == 2 then
					local sStr = string.format(tStrList[i], tTimeStr[i][1], tTimeStr[i][2])
					table.insert(self.tEatTimeStr, sStr)
				end
			end
		end
	end
	self.nFillCost = _tData.c or self.nFillCost	--Integer	补鸡花费 cost
	self.nEnergy = _tData.e or self.nEnergy	--Integer	吃鸡体力 energy
	-- o	--List<Pair<Integer,Long>>	领取获得的奖励

	self:refreshActService(_tData)--刷新活动共有的数据

end

-- 获取红点方法
function DataEatChicken:getRedNums()
	local nRedNum = 0
	if self.nEatState == e_eat_state.eat then
		nRedNum = nRedNum + 1
	end
	if self.nEatState == e_eat_state.fill then
		nRedNum = nRedNum + self:getEatChickenFillRed()		
	end	
	return nRedNum
end

function DataEatChicken:getEatChickenFillRed(  )
	-- body
	--当前时间
	local time = os.date("*t", getSystemTime())
	local nCurDay = time.day
	local nCurHour = time.hour
	--dump(time, "time", 100)	
	if nCurHour >= 14 and nCurHour < 18 then
		--本地记录
		local sLocal = getLocalInfo("EatChicken1"..Player:getPlayerInfo().pid, tostring(nCurDay).."-1")	
		--dump(sLocal, "sLocal", 100)
		local tParam = luaSplit(sLocal, "-")
		local nDay = tonumber(tParam[1] or 0)
		local nRedNums = tonumber(tParam[2] or 0)

		if nCurDay == nDay then--
			return nRedNums
		else
			saveLocalInfo("EatChicken1"..Player:getPlayerInfo().pid, tostring(nCurDay).."-1")
			return 1
		end	
	elseif nCurHour >= 20 then
		--本地记录
		local sLocal = getLocalInfo("EatChicken2"..Player:getPlayerInfo().pid, tostring(nCurDay).."-1")	
		--dump(sLocal, "sLocal", 100)
		local tParam = luaSplit(sLocal, "-")
		local nDay = tonumber(tParam[1] or 0)
		local nRedNums = tonumber(tParam[2] or 0)

		if nCurDay == nDay then--
			return nRedNums
		else
			saveLocalInfo("EatChicken2"..Player:getPlayerInfo().pid, tostring(nCurDay).."-1")
			return 1
		end	
	end
	return 0
end

function DataEatChicken:clearFillRed(  )
	-- body
	if self.nEatState == e_eat_state.fill then
		--当前时间
		local time = os.date("*t", getSystemTime())
		local nCurDay = time.day
		local nCurHour = time.hour
		if nCurHour >= 14 and nCurHour < 18 then
			saveLocalInfo("EatChicken1"..Player:getPlayerInfo().pid,tostring(nCurDay).."-0")			
		elseif nCurHour >= 20 then	
			saveLocalInfo("EatChicken2"..Player:getPlayerInfo().pid,tostring(nCurDay).."-0")			
		end	
		sendMsg(gud_refresh_activity) 
	end	
end
return DataEatChicken