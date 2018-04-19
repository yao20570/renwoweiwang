--
-- Author: tanqian
-- Date: 2017-09-05 16:51:37
--累计充值数据结构
local Activity = require("app.data.activity.Activity")

local DataTotalRecharge = class("DataTotalRecharge", function()
	return Activity.new(e_id_activity.totalrecharge) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.totalrecharge] = function (  )
	return DataTotalRecharge.new()
end

function DataTotalRecharge:ctor()
	-- body
   self:myInit()
end


function DataTotalRecharge:myInit( )
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tAllAwdInfo           = {}   --List<AwardInfo>    奖励配置信息
 	self.nRechargeNum           = 0    --Long               累计消费金币数
end

-- 读取服务器中的数据
function DataTotalRecharge:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	self:refreshActService(_tData)                        --刷新活动共有的数据
	self.tGotAwdList           = _tData.gs or self.tGotAwdList    --List<Long>      已经领取的奖励阶段
	self.tAllAwdInfo           = _tData.as or self.tAllAwdInfo    --List<AwardInfo> 奖励信息
	self.nRechargeNum	       = _tData.gd or self.nRechargeNum	  --Long            累计消费金币数
	--物品排序
	for i=1,#self.tAllAwdInfo do
		sortGoodsList(self.tAllAwdInfo[i].ad)
	end
	--
	self:sortAwards(self.tAllAwdInfo)

	


end

function DataTotalRecharge:sortAwards(_tAwd)
	-- body
	if table.nums(_tAwd) == 0 then return end
	--把已领取的nGet置1,未领取为0
	for _, v in pairs(_tAwd) do
		if self:getIsRewarded(v.g) then
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
    		r = a.g < b.g
    	else
    		r = a.nGet < b.nGet
    	end
    	return r
    end)

end

--未达到
function DataTotalRecharge:getNotReach(_goldnum)
	-- body
	return _goldnum > self.nRechargeNum
end

--该奖励是否可领
function DataTotalRecharge:getIsCanReward(_goldnum)
	-- body
	if _goldnum <= self.nRechargeNum and not self:getIsRewarded(_goldnum) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataTotalRecharge:getIsRewarded(_goldnum)
	for k, v in pairs(self.tGotAwdList) do
		if v == _goldnum then
			return true
		end
	end
	return false
end

--通过奖励阶段获取奖励
function DataTotalRecharge:getAwdByGoldType(_gold)
	-- body

	for k, v in pairs(self.tAllAwdInfo) do
		if v.g == _gold then
			return v.ad
		end
	end
end


-- 获取红点方法
function DataTotalRecharge:getRedNums()
	local nNums = 0
	--是否有奖励没领
	-- if table.nums(self.tCanAwdList) > 0 then
	-- 	nNums = 1
	-- end
	for k, v in pairs(self.tAllAwdInfo) do
		if self:getIsCanReward(v.g) then
			nNums = 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataTotalRecharge