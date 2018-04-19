---------------------------------------------
-- Author: maheng
-- Date: 2017-11-23 10:54:32
-- 红包馈赠
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataRedPacket = class("DataRedPacket", function()
	return Activity.new(e_id_activity.redpacket) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.redpacket] = function (  )
	return DataRedPacket.new()
end

function DataRedPacket:ctor()
	-- body
   self:myInit()
end


function DataRedPacket:myInit( )
	self.tCanAwdList	       = {}   --List<Long>	       可以领取的奖励阶段
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tAllAwdInfo           = {}   --List<AwardInfo>    奖励信息
 	self.nGoldNum              = 0    --Long               当前充值金额
end

-- 读取服务器中的数据
function DataRedPacket:refreshDatasByServer( _tData )
	--dump(_tData,"红包馈赠数据",20)
	if not _tData then
	 	return
	end
	self.tCanAwdList	       = _tData.re or self.tCanAwdList    --List<Long>	    可以领取的奖励阶段
	self.tGotAwdList           = _tData.gs or self.tGotAwdList    --List<Long>      已经领取的奖励阶段
	self.tAllAwdInfo           = _tData.aw or self.tAllAwdInfo    --List<AwardInfo> 奖励信息
	self.nGoldNum	       	   = _tData.tc or self.nGoldNum	  --Long            累计消费金币数

	--物品排序
	for i=1,#self.tAllAwdInfo do
		sortGoodsList(self.tAllAwdInfo[i].i)
	end
	--
	self:sortAwards(self.tAllAwdInfo)

	self:refreshActService(_tData)                        --刷新活动共有的数据


end

function DataRedPacket:sortAwards(_tAwd)
	-- body
	if table.nums(_tAwd) == 0 then return end
	--把已领取的nGet置1,未领取为0
	for _, v in pairs(_tAwd) do
		if self:getIsRewarded(v.t) then
			v.nGet = 1
		else
			v.nGet = 0
		end
    end
	--排序,已领取的置后
    table.sort(_tAwd, function(a, b)
    	-- body
    	local r
    	if a.nGet == b.nGet then
    		r = a.t < b.t
    	else
    		r = a.nGet < b.nGet
    	end
    	return r
    end)

end

--未达到
function DataRedPacket:getNotReach(_goldnum)
	-- body
	return _goldnum > self.nGoldNum
end

--该奖励是否可领
function DataRedPacket:getIsCanReward(_goldnum)
	-- body
	if _goldnum <= self.nGoldNum and not self:getIsRewarded(_goldnum) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataRedPacket:getIsRewarded(_goldnum)
	for k, v in pairs(self.tGotAwdList) do
		if v == _goldnum then
			return true
		end
	end
	return false
end

--通过奖励阶段获取奖励
function DataRedPacket:getAwdByGoldType(_gold)
	-- body
	for k, v in pairs(self.tAllAwdInfo) do
		if v.t == _gold then
			return v.i
		end
	end
end


-- 获取红点方法
function DataRedPacket:getRedNums()
	local nNums = 0
	--是否有奖励没领
	-- if table.nums(self.tCanAwdList) > 0 then
	-- 	nNums = 1
	-- end
	for k, v in pairs(self.tAllAwdInfo) do
		if self:getIsCanReward(v.t) then
			nNums = 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataRedPacket