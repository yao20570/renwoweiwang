-- Author: liangzhaowei
-- Date: 2017-06-19 19:47:45
-- 成长计划数据
local Activity = require("app.data.activity.Activity")

local DataGrowthFound = class("DataGrowthFound", function()
	return Activity.new(e_id_activity.growthfound) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.growthfound] = function (  )
	return DataGrowthFound.new()
end

-- _index
function DataGrowthFound:ctor()
	-- body
   self:myInit()
   self.nLastLoginTime = 0 --最后登陆的时间
end


function DataGrowthFound:myInit( )

	self.nVip	       = 0   --	vip等级限制
	self.tCost	       = {}   --List<Pair<Integer,Long>>	花费
	self.tAwards	   = {}   --List<GrowFundAwardVO>	奖励档次列表
	self.bOpen	       = false   --	是否已开通成长基金功能 0:未 1:是
	self.tGets	       = {}   --List<Integer>	已领取的等级奖励
	self.nBuyPeople    = 0
end


-- 读取服务器中的数据
function DataGrowthFound:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nVip	       = _tData.vip	     or self.nVip	   --	vip等级限制
	self.tCost	       = _tData.cost     or self.tCost	   --List<Pair<Integer,Long>>	花费
	self.tAwards	   = _tData.awards   or self.tAwards   --List<GrowFundAwardVO>	奖励档次列表
	self.bOpen	       = _tData.open == 1 or self.bOpen	   --	是否已开通成长基金功能 0:未 1:是
	self.tGets	       = _tData.gets     or self.tGets	   --List<Integer>	已领取的等级奖励
	self.nBuyPeople    = _tData.hb       or self.nBuyPeople--已购买基金人数
	-- dump(self.tGets)
	self:sortAwards(self.tAwards, self.tGets)
	-- dump(self.tAwards)
	self:refreshActService(_tData)--刷新活动共有的数据

end

function DataGrowthFound:sortAwards(tAwards, tGets)
	if table.nums(tAwards) == 0 then return end
	--把已领取的nGet置1,未领取为0
	for _, v in pairs(tAwards) do
		if table.nums(tGets) == 0 then
			v.nGet = 0
		else
			for i, id in pairs(tGets) do
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
    table.sort(tAwards, function(a, b)
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
function DataGrowthFound:hasGotAllAwards()
	-- body
	if table.nums(self.tGets) == table.nums(self.tAwards) then
		return true
	else
		return false
	end
end


-- 获取红点方法
function DataGrowthFound:getRedNums()
	local nNums = 0
	--玩家vip等级到达4级且没购买基金就一直显示红点
	local nVipLv = Player:getPlayerInfo().nVip
	if not self.bOpen then
		nNums = self.nLoginRedNums + nNums
		if nVipLv >= self.nVip then
			nNums = nNums + 1
		end
		return nNums
	end
	for k, v in pairs(self.tAwards) do
		if Player:getPlayerInfo().nLv >= v.lv and v.nGet == 0 then
			nNums = 1
			break
		end
	end
	
	nNums = self.nLoginRedNums + nNums
	return nNums
end




return DataGrowthFound