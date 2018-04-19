-- Author: maheng
-- Date: 2018-2-4 14:30:36
-- 新王权征收
local Activity = require("app.data.activity.Activity")

local DataNewRoyaltyCollect = class("DataNewRoyaltyCollect", function()
	return Activity.new(e_id_activity.newroyaltycollect) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.newroyaltycollect] = function (  )
	return DataNewRoyaltyCollect.new()
end

function DataNewRoyaltyCollect:ctor()
    self:myInit()
end


function DataNewRoyaltyCollect:myInit( )
	self.nDays 		= 		0 	--已经登录的天数
	self.tGets 		= 		{}	--已经领取的奖励
	self.tConfs 	= 		{}	--奖励配置
	self.nBy 		= 		0   --是否购买了王权征收 0没买,1买了
end


-- 读取服务器中的数据
function DataNewRoyaltyCollect:refreshDatasByServer( _tData )
	-- dump(_tData, "新王权征收数据 ====", 100)
	if not _tData then
	 	return
	end

	self.nDays  	=	_tData.days	or self.nDays   --days	Integer	已经登录的天数
	self.tGets		=	_tData.gets or self.tGets 	--gets	Set<Integer>	已经领取的奖励
	self.tConfs 	= 	_tData.conf or self.tConfs  --conf	List<ScepterLevyVo>	奖励配置
	self.nBy 		=   _tData.by   or self.nBy     --Integer	是否购买了王权征收 0没买,1买了
	self:refreshActService(_tData)--刷新活动共有的数据
end

function DataNewRoyaltyCollect:isHaveGetPrize( _nDay )
	-- body
	if not _nDay then
		return false
	end
	for k, v in pairs(self.tGets) do
		if v == _nDay then
			return true
		end
	end
	return false
end

function DataNewRoyaltyCollect:isCanGetPrize( _nDay )
	-- body
	if not _nDay then
		return false
	end
	return self.nDays >= _nDay
end

-- 获取红点方法
function DataNewRoyaltyCollect:getRedNums()
	local nNums = 0
	-- if self.nT == 1 then
	-- 	nNums =  1
	-- end

	-- nNums = self.nLoginRedNums + nNums

	return nNums
end


function DataNewRoyaltyCollect:isHavePrize(  )
	-- body

	local nNums = 0
	if Player:getPlayerInfo().nVip > 0 then
		for i = 1, self.nDays do
			if self:isHaveGetPrize(i) == false then

				nNums = nNums + 1
			end
		end
	end
	return nNums > 0
end

function DataNewRoyaltyCollect:isHaveGetAll(  )
	-- body
	if self.tGets and #self.tGets >= 5 then
		return true
	else
		return false
	end
end


return DataNewRoyaltyCollect