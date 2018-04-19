----------------------------------------------------- 
-- DataFarmTroopsPlan.lua
-- Author: dengshulan
-- Date: 2017-08-07 15:38:45
-- 屯田计划数据
----------------------------------------------------- 
local Activity = require("app.data.activity.Activity")

local DataFarmTroopsPlan = class("DataFarmTroopsPlan", function()
	return Activity.new(e_id_activity.farmtroopsplan) 
end)


--计划类型
e_farmplan_type = {
	agricultural      = 1,   --农务
	military          = 2,   --军务
	business          = 3    --商务
}

--创建自己(方便管理)
tActivityDataList[e_id_activity.farmtroopsplan] = function (  )
	return DataFarmTroopsPlan.new()
end

-- _index
function DataFarmTroopsPlan:ctor()
	-- body
   self:myInit()
   self.nLastLoginTime = 0 --最后登陆的时间
end


function DataFarmTroopsPlan:myInit( )

	self.tPlans	       = {}       --Map<Integer,ProjectInfo>	 计划信息
	self.tGets	       = {}       --Map<Integer,Set<Integer>>    已领取的奖励
	self.nOpenDay      = nil
end


-- 读取服务器中的数据
function DataFarmTroopsPlan:refreshDatasByServer( _tData )
	-- dump(_tData,"屯田计划数据", 20)
	if not _tData then
	 	return
	end

	self.tPlans  = _tData.i   or self.tPlans                    --Map<Integer,ProjectInfo>	 计划信息
	self.tGets   = self:dealGotAwards(_tData.ob) or self.tGets  --Map<Integer,Set<Integer>> 已领取的奖励
	self.nOpenDay = _tData.day or self.nOpenDay                 --活动开启的第几天

	self:refreshActService(_tData)--刷新活动共有的数据

end

--整理已领取列表结构
function DataFarmTroopsPlan:dealGotAwards(tAwards)
	-- body
	if not tAwards or table.nums(tAwards) == 0 then return end
	local tTmpAwards = {}
	for k, v in pairs(tAwards) do
		tTmpAwards[v.t] = v.d
	end
	return tTmpAwards
end

--是否已购买计划
--_pType:计划类型
function DataFarmTroopsPlan:isBoughtPlan(_pType)
	-- body
	if table.nums(self.tGets) == 0 then
		return false
	end
	for k, v in pairs(self.tGets) do
		if k == _pType then
			return true
		end
	end
	return false
end

--是否可领取奖励
--_pType:计划类型
--返回的是可领取奖励的天数,不可领取则返回false
function DataFarmTroopsPlan:isCanGetAward(_pType)
	-- body
	if not self:isBoughtPlan(_pType) then
		return false
	end
	--计算今天是活动开始的第几天
	-- local fCurTime = getSystemTime(false)
	-- local nDay = math.ceil((fCurTime - self.nActivityOpenTime)/(24*60*60)/1000)
	local num = table.nums(self.tPlans[_pType].aw)
	for i = 1, num do
		if not self.tGets[_pType][i] and i <= self.nOpenDay then
			return i
		end
	end
	
	return false
end

--某类型的某天是否已领
function DataFarmTroopsPlan:hasGotAward(_pType, _nDay)
	-- body
	if not self.tGets[_pType] then
		return false
	end
	if self.tGets[_pType][_nDay] then
		return true
	else
		return false
	end
end

--获取奖励
--_pType:计划类型
--_nDay:第几天
function DataFarmTroopsPlan:getPlanAwards(_pType, _nDay)
	-- body
	for tp, info in pairs(self.tPlans) do
		if info.id == _pType then
			local tAwd = {}
			table.insert(tAwd, info.aw[_nDay])
			return tAwd
		end
	end
end

-- 获取红点方法
function DataFarmTroopsPlan:getRedNums()
	local nNums = 0
	for i = 1, 3 do
		if self:isCanGetAward(i) then
			nNums = 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums
	return nNums
end




return DataFarmTroopsPlan