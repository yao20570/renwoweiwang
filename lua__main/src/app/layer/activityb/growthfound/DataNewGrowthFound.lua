-- Author: dengshulan
-- Date: 2018-1-5 14:37:33 星期五
-- 新版成长基金数据
local Activity = require("app.data.activity.Activity")

local DataNewGrowthFound = class("DataNewGrowthFound", function()
	return Activity.new(e_id_activity.newgrowthfound) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.newgrowthfound] = function (  )
	return DataNewGrowthFound.new()
end

--vip类型
e_vip_type = 
{
	[1] = 2,
	[2] = 4,
}

-- _index
function DataNewGrowthFound:ctor()
	-- body
   self:myInit()
end


function DataNewGrowthFound:myInit( )

	self.tBuys	       = {}   --已经购买的基金
	self.nLimitCd	   = 0    --活动限购倒计时
	self.tAwardsConf   = {}   --成长基金配置
	self.tGets	       = {}   --List<Integer>	已领取的等级奖励

	self.tVipAwards 	= {}  --成长基金配置(Vip等级对应奖励)
end


-- 读取服务器中的数据
function DataNewGrowthFound:refreshDatasByServer( _tData )
	-- dump(_tData,"新版成长基金数据",20)
	if not _tData then
	 	return
	end

	self.tBuys			= _tData.buys 	or self.tBuys 		--Set<Integer> 已经购买的基金
	self.nLimitCd		= _tData.cd 	or self.nLimitCd 	--Long 活动限购倒计时
	self.tAwardsConf	= _tData.gfVOs	or self.tAwardsConf --List<GrowFundVO> 成长基金配置
	self.tGets 			= _tData.gis     or self.tGets	    --List<GetInfo>	已领取的奖励

	self.nGrowFoundLastLoadTime = getSystemTime()

	for k, conf in pairs(self.tAwardsConf) do
		local tGets = {}
		for i, v in pairs(self.tGets) do
			if v.vn == conf.vn then
				tGets = v.gets
				break
			end
		end
		self:sortAwards(conf.rewards, tGets)
		self.tVipAwards[conf.vn] = conf
	end

	self:refreshActService(_tData)--刷新活动共有的数据

end

--奖励排序
function DataNewGrowthFound:sortAwards(_tAwards, _tGets)
	if table.nums(_tAwards) == 0 then return end
	--把已领取的nGet置1,未领取为0
	for _, v in pairs(_tAwards) do
		if table.nums(_tGets) == 0 then
			v.nGet = 0
		else
			for i, id in pairs(_tGets) do
				if v.id == id then
					v.nGet = 1
					break
				else
	    			v.nGet = 0
				end
			end
		end
    end
    --排序,已领取的置后
    table.sort(_tAwards, function(a, b)
    	-- body
    	local r
    	if a.nGet == b.nGet then
    		r = a.lv < b.lv
    	else
    		r = a.nGet < b.nGet
    	end
    	return r
    end)
end

--奖励是否已全部领取
function DataNewGrowthFound:hasGotAllAwards()
	-- body
	local bHasGotAll = false

	local nBuyNum = table.nums(self.tBuys)
	if nBuyNum > 0 then
		--如果不在限购时间判断有没有领完已购买基金的所有奖励
		if not self:getIsDuringCd() then
			local nVipGot = 0 --领完奖励的基金个数
			for k, vip in pairs(self.tBuys) do
				for i, v in pairs(self.tGets) do
					if v.vn == vip and table.nums(v.gets) == table.nums(self.tVipAwards[vip].rewards) then
						nVipGot = nVipGot + 1
					end
				end
			end
			--如果购买基金的个数等于领完奖励的基金个数则领完所有奖励了
			if nBuyNum == nVipGot then
				bHasGotAll = true
			end
		else --有没有买所有的基金并领完所有的奖励
			local nVipGot = 0 --领完奖励的基金个数
			for k, vip in pairs(e_vip_type) do
				for i, v in pairs(self.tGets) do
					if v.vn == vip and table.nums(v.gets) == table.nums(self.tVipAwards[vip].rewards) then
						nVipGot = nVipGot + 1
					end
				end
			end
			--如果购买基金的个数等于领完奖励的基金个数则领完所有奖励了
			if nVipGot == table.nums(e_vip_type) then
				bHasGotAll = true
			end
		end
	else
		--如果没购买基金且不在限购时间内默认没奖励领了
		if not self:getIsDuringCd() then
			bHasGotAll = true
		end
	end

	return bHasGotAll
end

--根据vip类型获取是否该vip基金是否已购买
function DataNewGrowthFound:getIsOpenByVip(_vip)
	-- body
	for k, v in pairs(self.tBuys) do
		if v == _vip then
			return true
		end
	end
	return false
end

--根据vip类型获取是否有奖励可领
function DataNewGrowthFound:getIsAwardByVip(_vip)
	-- body
	local tData = self.tVipAwards[_vip]
	for k, v in pairs(tData.rewards) do
		if Player:getPlayerInfo().nLv >= v.lv and v.nGet == 0 then
			return true
		end
	end
	return false
end

--是否在限购时间内
function DataNewGrowthFound:getIsDuringCd()
	-- body
	return self:getGrowFoundLimitCd() > 0
end

--获取剩余限购时间
function DataNewGrowthFound:getGrowFoundLimitCd()
	-- body
	local nNowTime = getSystemTime()
	local nTime  = self.nLimitCd - (nNowTime - self.nGrowFoundLastLoadTime)
	return nTime
end

--根据vip基金获取红点显示
function DataNewGrowthFound:getRedNumsByVip(_vip)
	-- body
	local bInCd = self:getIsDuringCd()
	local nNums = 0
	if not _vip then
		return nNums
	end
	if bInCd then
		local nVipLv = Player:getPlayerInfo().nVip
		if not self:getIsOpenByVip(_vip) and nVipLv >= _vip then
			nNums = nNums + 1
		elseif self:getIsOpenByVip(_vip) then
			if self:getIsAwardByVip(_vip) then
				nNums = nNums + 1
			end
		end
	else
		if self:getIsOpenByVip(_vip) then
			if self:getIsAwardByVip(_vip) then
				nNums = nNums + 1
			end
		end
	end
	return nNums
end


-- 获取红点方法
function DataNewGrowthFound:getRedNums()
	local nNums = 0
	for k, vip in pairs(e_vip_type) do
		nNums = nNums + self:getRedNumsByVip(vip)
	end
	
	nNums = self.nLoginRedNums + nNums
	return nNums
end




return DataNewGrowthFound