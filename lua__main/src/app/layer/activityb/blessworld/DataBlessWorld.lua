--
-- Author: tanqian
-- Date: 2017-09-06 20:45:07
--活动福泽添加数据结构
local Activity = require("app.data.activity.Activity")

local DataBlessWorld = class("DataBlessWorld", function()
	return Activity.new(e_id_activity.blessworld) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.blessworld] = function (  )
	return DataBlessWorld.new()
end

function DataBlessWorld:ctor()
   self:myInit()
end


function DataBlessWorld:myInit( )
	self.tAllRewardInfo  			=	{}   	--	List<WealfareLandVipConfVo> vip奖励配置信息
	self.tGotReward					=	{} 		--	Set<Integer>	已领取奖励
	self.tVipNums					= 	{}		--  List<WealfareLandVipNumVo>  vip到达人数(里面VIP对应的人数)
end


-- 读取服务器中的数据
function DataBlessWorld:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	self.tAllRewardInfo  	=	_tData.confs	or self.tAllRewardInfo   
	self.tGotReward			=	_tData.gets   	or self.tGotReward 
	self.tVipNums			= 	_tData.nums 	or self.tVipNums

	--物品排序
	for i=1,#self.tAllRewardInfo do
		sortGoodsList(self.tAllRewardInfo[i].awards)
	end
	--

	self:refreshActService(_tData)--刷新活动共有的数据

	self:sortTheInfo(self.tAllRewardInfo)

end

function DataBlessWorld:sortTheInfo(_tAwd)
	-- body
	if table.nums(_tAwd or {}) == 0 then 
		return 
	end
	--把已领取的nGet置1,未领取为0
	for _, v in pairs(_tAwd) do
		--奖励是否可领
		if self:gtIsCanGet(v.vip) then
			v.nCanGet = 1
			
		else
			v.nCanGet = 0
		end

		if self:getIsGetReward(v.vip) then
			v.nHasGet = 1
		else
			v.nHasGet = 0
		end
		
    end
	--排序,已领取的置后
    table.sort(_tAwd, function(a, b)
    	if a.nCanGet == 1 and b.nCanGet ~= 1 then  --a可以领取
    		return true
    	end

    	if a.nCanGet ~= 1 and b.nCanGet == 1 then  --b可以领取
    		return false
    	end
    	if a.nCanGet == b.nCanGet and (a.nHasGet == 0 and b.nHasGet == 0) then  --未达到条件的
    		return a.vip < b.vip
    	end
    	if a.nHasGet == b.nHasGet then
    		return a.vip < b.vip
    	end
    	if a.nHasGet == 1 and b.nHasGet ~= 1 then  --a已领取
    		return false 
    	end

    	if b.nHasGet == 1 and a.nHasGet ~= 1 then  --b已领取
    		return true 
    	end


    end)

end

--获取当前VIP奖励需要的数量
function DataBlessWorld:getNeedNumByVipLv( _nVipLv )
	_nVipLv = _nVipLv or 0 
	for k,v in pairs(self.tAllRewardInfo) do
		if v and v.vip == _nVipLv then
			return v.num
		end
	end
	return 0
end

--判断奖励是否已经领取
function DataBlessWorld:getIsGetReward(_nVip)
	if not _nVip  then
		return  true
	end
	for k,v in pairs(self.tGotReward) do
		if v and v == _nVip then
			return true
		end
	end
	return false 
end

--判断奖励是否可领取
function DataBlessWorld:gtIsCanGet( _nVip )
	local bCan = false 
	local nNeed = self:getNeedNumByVipLv(_nVip)
	local nCur = self:getNumByVipLv(_nVip)
	local bHasGet = self:getIsGetReward(_nVip)
	if (nCur > 0 and nNeed > 0) and (nCur >= nNeed) and  (not bHasGet)  then
		bCan = true
	end
	return bCan

end


--根据VIP等级获取当前VIP等级的人数
function DataBlessWorld:getNumByVipLv(_nLv)
	local nNum = 0
	if not _nLv  then
		return nNum 
	end
	for k,v in pairs(self.tVipNums) do
		if v and v.vip == _nLv then
			nNum = v.num
			break
		end
	end
	return nNum
end

function DataBlessWorld:isGetAllReward(  )
	-- body

	for k,v in pairs(self.tAllRewardInfo) do
		local nCurNum = self:getNumByVipLv(v.vip)
		local bIsGet = self:getIsGetReward(v.vip)
		if v and (not bIsGet) and (nCurNum >= v.num) then
			return false
		elseif nCurNum < v.num then  --如果是因为未达到 也不能关闭
			return false
		end
	end

	return true
end

-- 获取红点方法
function DataBlessWorld:getRedNums()
	local nNums = 0

	for k,v in pairs(self.tAllRewardInfo) do
		local nCurNum = self:getNumByVipLv(v.vip)
		local bIsGet = self:getIsGetReward(v.vip)
		if v and (not bIsGet) and nCurNum >= v.num then
			nNums = nNums + 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataBlessWorld