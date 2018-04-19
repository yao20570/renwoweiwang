
----------------------------------------------------- 
-- Author: luwenjing
-- Date: 2018-01-25 11:33:45  星期四
-- 福星高照数据
----------------------------------------------------- 
local Activity = require("app.data.activity.Activity")
local DataRankPrize = require("app.layer.activitya.countryfight.DataRankPrize")
local DataLuckyStar = class("DataLuckyStar", function()
	return Activity.new(e_id_activity.luckystar) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.luckystar] = function (  )
	return DataLuckyStar.new()
end

-- _index
function DataLuckyStar:ctor()
	-- body
   self:myInit()
   -- self.nLastLoginTime = 0 --最后登陆的时间
end


function DataLuckyStar:myInit( )

	self.nLo = 0        -- Integer 连开时开启的红包个数 
	self.sOa = ""       -- String 开启红包奖励[数量-奖品|数量-奖品] 
	self.nRg = 0        -- Integer 购买红包花费元宝 
	-- self.tRas = {}      --List<RankAwardVo> 排名奖励数据 
	self.nOc = 0		--Integer 开启红包数量 
	self.nF = 0 		-- Long 福气值 
	self.tToa = {}		--List<Integer> 已经领取的开启奖励 
	self.tConfs = {} 	--List<RankAwardVo> 排名奖励数据
end


-- 读取服务器中的数据
function DataLuckyStar:refreshDatasByServer( _tData )
	-- dump(_tData,"，福星高照数据", 20)
	if not _tData then
	 	return
	end
	self.nLo = _tData.lo or self.nLo        -- Integer 连开时开启的红包个数 
	self.sOa = _tData.oa or self.sOa       -- String 开启红包奖励[数量-奖品|数量-奖品] 
	self.nRg = _tData.rg or self.nRg        -- Integer 购买红包花费元宝 
	-- self.tRas = _tData.ras or self.tRas      --List<RankAwardVo> 排名奖励数据 
	self.nOc = _tData.oc or self.nOc		--Integer 开启红包数量 
	self.nF = _tData.f or self.nF 		-- Long 福气值 
	self.tToa = _tData.toa or self.tToa		--List<Integer> 已经领取的开启奖励 

	--奖励数据
	if _tData.ras and #_tData.ras > 0 then		
		for k, v in pairs(_tData.ras) do
			if not self.tConfs[v.g] then
				local pDataRankPrize = DataRankPrize.new()
				pDataRankPrize:refreshByServer2(v)
				self.tConfs[v.g] = pDataRankPrize
			else
				self.tConfs[v.g]:refreshByServer2(v)
			end
		end
	end	

	self:refreshActService(_tData)--刷新活动共有的数据

end
--state 1 未达到 、state 2 未领取、3 已领取
function DataLuckyStar:getRewardState( _nNum )
	-- body
	
	if _nNum <= self.nOc then
		for i=1,#self.tToa do
			if self.tToa[i] == _nNum then   --已领取
				return 3
			end
		end
		return 2
	else
		return 1
	end

end

-- 获取红点方法
function DataLuckyStar:getRedNums()
	local nNum = 0
	local tL1 =luaSplit(self.sOa ,"|")
	for i=1, #tL1 do
		local tTemp1 = luaSplit(tL1[i],"-")
		if tTemp1 and #tTemp1 == 2 then
			local nPoint=tonumber(tTemp1[1])
			if self:getRewardState(nPoint) == 2 then
				nNum = nNum + 1
			end
		end
	end
	nNum = self.nLoginRedNums + nNum
	return nNum
end



return DataLuckyStar