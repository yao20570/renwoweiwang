-- Author: maheng
-- Date: 2017-06-28 13:54:12
-- 城战排行
local Activity = require("app.data.activity.Activity")
local DataRankPrize = require("app.layer.activitya.countryfight.DataRankPrize")


local DataCityFight = class("DataCityFight", function()
	return Activity.new(e_id_activity.cityfight) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.cityfight] = function (  )
	return DataCityFight.new()
end

function DataCityFight:ctor()
	-- body
   self:myInit()
end


function DataCityFight:myInit( )
 	self.tAs = {}				--已领取奖励			
 	self.tConfs = {}			--配置信息
 	self.nIsStart = 0 		--是否开始领奖
 	self.nFm = 0 				--玩家排行数据
 	self.nHz = 0 				--玩家历史最高排名
end

-- 读取服务器中的数据
function DataCityFight:refreshDatasByServer( _tData )
	--dump(_tData,"数据",20)
	if not _tData then
	 	return
	end
	
	self.tAs = _tData.al or self.tAs --	Set<Integer>	已领取的奖励

	local isSend = false
	if _tData.z and self.nIsStart and self.nIsStart ~= _tData.z then
		isSend = true
	end
	if _tData.hz and self.nHz and self.nHz ~= _tData.hz then--我的排名发生变化
		isSend = true
	end		
	self.nIsStart = _tData.z or self.nIsStart --Integer	--领奖结算时间
	self.nFm = _tData.m or self.nFm -- 洗练次数
	self.nHz = _tData.hz or self.nHz --玩家历史最高排行		
	--奖励数据
	if _tData.ras and #_tData.ras > 0 then		
		for k, v in pairs(_tData.ras) do
			if not self.tConfs[v.lv] then
				local pDataRankPrize = DataRankPrize.new()
				pDataRankPrize:refreshByServer3(v)
				self.tConfs[v.lv] = pDataRankPrize
			else
				self.tConfs[v.lv]:refreshByServer3(v)
			end
		end
	end	
	self:updateRankPrizeStatus()
	--只有公共部分
	self:refreshActService(_tData)--刷新活动共有的数据

	if isSend == true and self:isStartGetPrize() == true then
		sendMsg(ghd_rank_act_accounts_msg)		
	end	
end

-- 获取红点方法
function DataCityFight:getRedNums(_awardsTip)
	local nNums = 0
	for i= 1, #self.tConfs do
		if self:getPrizeStatus(i) == en_get_state_type.canget then
			nNums = nNums + 1
		end
	end
	if not _awardsTip then
		nNums = self.nLoginRedNums + nNums
	end
	return nNums
end

--获取奖励配置数据
function DataCityFight:getPrizeConfs(  )
	-- body
	return self.tConfs
end
--是否开始领奖
function DataCityFight:isStartGetPrize(  )
	-- body
	if self.nIsStart == 1 then
		return true
	else 
		return false
	end 
end

--获取奖励配置信息
function DataCityFight:getRankPrizeDatas(  )
	-- body
	local tTable = {}
	if self.tConfs and #self.tConfs then
		for k, v in pairs(self.tConfs) do
			table.insert(tTable, v) 
		end
		table.sort(tTable, function ( a, b )
			-- body
			return a.id < b.id--id升序
		end)
	end
end

--获取奖品状态
function DataCityFight:getPrizeStatus( Index )
	-- body
	if self:isStartGetPrize(Index) == true then
		if self:isInGetPrizeRange(Index) == true then
			if self:isHaveGetPrize(Index) == true then
				return en_get_state_type.haveget
			else
				return en_get_state_type.canget
			end
		else
			return en_get_state_type.cannotget
		end
	else
		return en_get_state_type.null
	end
end

function DataCityFight:updateRankPrizeStatus( )
	-- body
	for k, v in pairs(self.tConfs) do
		v:updateStatus(self:getPrizeStatus(k))
	end
end
--是否已经领取奖励
function DataCityFight:isHaveGetPrize(_index)
	-- body
	if not _index then
		return false
	end
	for k, v in pairs(self.tAs) do
		if v == _index then
			return true
		end
	end
	return false	
end
--是否在奖励范围内
function DataCityFight:isInGetPrizeRange( _index )
	-- body
	if not _index or self.nHz == 0 then
		return false
	end
	local myRank = self.nHz
	if self.tConfs[_index] then
		if myRank <= self.tConfs[_index].nR then
			return true
		end
	end
	return false
end

--根据排名确定等级
function DataCityFight:getClassifyByRank( _nRank )
	-- body
	if not _nRank or _nRank == 0 then
		return 0
	end	
	if self.tConfs then
		for k, v in pairs(self.tConfs) do
			if _nRank >= v.nL and _nRank <= v.nR then
				return v.nId
			end			
		end
	end
	return 0
end

--获取当前玩家的奖励档次
function DataCityFight:getMyPrizeClassify()
	-- body
	return self:getClassifyByRank(self.nHz) 
end

--活动结算时间
function DataCityFight:getBalanceTimeStr(  )
	-- body	
	local nTime = tonumber(self.nActivityOpenTime + 19*60*60*1000) 
    local tTime =  os.date("*t", nTime/1000)
    local sTime = string.format("%d",tTime.hour)..":"..string.format("%02d",tTime.min)..getConvertedStr(6, 10456)
    local sStr = {
    	{text=sTime, color=_cc.green}
	} 
    return sStr
end
return DataCityFight