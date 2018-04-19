-- Author: xiesite
-- Date: 2018-02-26 16:15:36
-- 周卡月卡数据
local Activity = require("app.data.activity.Activity")

local DataMonthWeekCard = class("DataMonthWeekCard", function()
	return Activity.new(e_id_activity.mothcard) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.monthweekcard] = function (  )
	return DataMonthWeekCard.new()
end

function DataMonthWeekCard:ctor()
    self:myInit()
end

function DataMonthWeekCard:myInit( )
	self.tCs = {}   --卡的配置
	self.tC  = {}	--已开启卡的CD时间 K:卡的唯一ID V:剩余的时间/秒
	self.tGets = {}  -- 当天已领取了奖励的卡
end

-- 读取服务器中的数据
function DataMonthWeekCard:refreshDatasByServer( _tData )
	-- dump(_tData, "寻访美人数据 ====")
	if not _tData then
	 	return
	end

	self.tCs = _tData.cs or self.tCs  --卡的配置
	if _tData.c then
		self.tC = _tData.c or self.tC 	----已开启卡的CD时间 K:卡的唯一ID V:剩余的时间/秒
		self.tLastTime = getSystemTime()
	end
	self.tGets = _tData.gets or self.tGets -- 当天已领取了奖励的卡

	self:refreshActService(_tData)--刷新活动共有的数据

end

function DataMonthWeekCard:getCdById(_id)
	local sPid = self:getPidById(_id)
	if _id and self.tC then
		for k , v in pairs(self.tC) do
			if v.k == sPid then
				return v.v
			end
		end
	end
	return nil
end

function DataMonthWeekCard:getCdLeft(_id)
	local cd = self:getCdById(_id)
	if not cd then
		return 0
	else
		local nLeft = cd - ( getSystemTime() - self.tLastTime )
		if nLeft > 0 then
			return nLeft
		else
			return 0
		end
	end
end

--是否有领取
function DataMonthWeekCard:haveGetCar(_id)
	--是否是已经购买了该卡，存在cd就是已经购买
	if self:getCdById(_id) and self.tGets then
		--今天是否已经领取
		local sPid = self:getPidById(_id)
		for k, v in ipairs(self.tGets) do
			--已经领取
			if sPid == v then
				return false	
			end
		end
		return true
	else
		return false
	end
end

--根据卡id获得充值pid
function DataMonthWeekCard:getPidById(_id)
	local sPid = ""
	if self.tCs then
		for k, v in ipairs(self.tCs) do
			if v.id == _id then
				sPid = v.pid
			end 
		end
	end
	return sPid
end

-- 获取红点方法
function DataMonthWeekCard:getRedNums()
	
	local nNums = 0
	if self.tCs then
		for k, v in ipairs(self.tCs) do
			if self:haveGetCar(v.id) then
				nNums = 1
				break
			end
		end
	end
	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataMonthWeekCard