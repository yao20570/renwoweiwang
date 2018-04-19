--
-- Author: luwenjing
-- Date: 2017-12-22 11:51:36
--充值签到数据结构
local Activity = require("app.data.activity.Activity")

local DataRechargeSign = class("DataRechargeSign", function()
	return Activity.new(e_id_activity.rechargesign) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.rechargesign] = function (  )
	return DataRechargeSign.new()
end

function DataRechargeSign:ctor()
	-- body
   self:myInit()
end


function DataRechargeSign:myInit( )
	self.tGs = {}		-- List<Integer> 已领取奖励天数 
	self.tSs = {} 		-- List<Integer> 已签到天数 
	self.nG = 0 		-- Integer 当天已充值黄金 
	self.nF = 0 		-- Integer 是否已领取免费物品 0:否 1:是 
	self.tSis = {}		-- List<SignInfoVO> 签到配置数据 
	self.tFi = {}		-- List<Pair<Integer,Long>> 配置免费获得的道具 
	self.nTd = 0		-- 要签到的那天 

end

-- 读取服务器中的数据
function DataRechargeSign:refreshDatasByServer( _tData )
	-- dump(_tData,"充值签到",100)
	if not _tData then
	 	return
	end
	self:refreshActService(_tData)                        --刷新活动共有的数据

	self.tGs = _tData.gs or self.tGs		-- List<Integer> 已领取奖励天数 
	self.tSs = _tData.ss or self.tSs 		-- List<Integer> 已签到天数 
	self.nG = _tData.g or self.nG 		-- Integer 当天已充值黄金 
	self.nF = _tData.f or self.nF 		-- Integer 是否已领取免费物品 0:否 1:是 
	self.tSis = _tData.sis or self.tSis		-- List<SignInfoVO> 签到配置数据 
	self.tFi = _tData.fi or self.tFi		-- List<Pair<Integer,Long>> 配置免费获得的道具 
	self.nTd = _tData.td or self.nTd		--要签到的天数

	-- --物品排序
	-- for i=1,#self.tAllAwdInfo do
	-- 	sortGoodsList(self.tAllAwdInfo[i].ad)
	-- end
	-- --
	-- self:sortAwards(self.tAllAwdInfo)

end
--获取奖励状态 return 4 -已领取 1-可领取 2 -当天要签到 3- 未开启 
function DataRechargeSign:getRewardState( _nDay )
 	-- body
 	for k,v in pairs(self.tGs) do
 		if _nDay == v then
 			return 4
 		end
 	end
 	for k,v in pairs(self.tSs) do
 		if _nDay == v then
 			return 1
 		end
 	end
 	if _nDay == self.nTd then
 		return 2
 	elseif _nDay > self.nTd then
 		return 3
 	-- elseif _nDay < self.nTd then 
 	-- 	return 5
 	end

 end 

 function DataRechargeSign:getFreeRewardState(  )
 	-- body
 	return self.nF
 end
--获得排序
function DataRechargeSign:resetSort()
	if not self.tSis then
       return
	end
	table.sort(self.tSis,function (a,b)
		local nState1=self:getRewardState(a.d)
		local nState2=self:getRewardState(b.d)
		if nState1 ~= nState2 then
			return nState1 < nState2
		else
			return a.d < b.d
		end
	end)

end


-- 获取红点方法
function DataRechargeSign:getRedNums()
	local nNums = 0
	for k, v in pairs(self.tSis) do
		if self:getRewardState(v.d) == 1 then
			nNums =  1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataRechargeSign