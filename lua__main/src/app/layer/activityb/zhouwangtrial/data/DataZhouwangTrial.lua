----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-03-19 17:14:51
-- Description: 纣王试炼数据
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")
local DataRankPrize = require("app.layer.activitya.countryfight.DataRankPrize")
--AwakeRes
local DataZhouwangTrial = class("DataZhouwangTrial", function()
	return Activity.new(e_id_activity.zhouwangtrial) 
end)
--创建自己(方便管理) 
tActivityDataList[e_id_activity.zhouwangtrial] = function (  )
	return DataZhouwangTrial.new()
end

function DataZhouwangTrial:ctor()
   self:myInit()
end


function DataZhouwangTrial:myInit( )
	self.nRbt = 0 --rbt	Float	返还损兵比例
	self.tCa = {} --ca	List<Pair<Integer,Long>>	国家积分奖励
	self.tPras = {} --pras	List<PointRankAwardVo>	积分排行奖励
	self.nP = 0 --p	Long	我的积分
	self.tPs = {} --ps	List<Pair<Integer,Integer>>	国家积分排行
	self.nR = 0 --r	Integer	我的排名
	self.nRkt = 0 --rt	Integer	排行奖励状态 0没有领取 1已经领取
	self.nCt = 0 --ct	Integer	国家奖励状态 0没有领取 1已经领取
	self.nIsStart = 0 -- 
	self.nC = 0 --已获得的宝箱数量
	self.nN = 0 --玩家当前区域的纣王数量
end


-- 读取服务器中的数据
function DataZhouwangTrial:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	-- dump(_tData, "_tData 纣王试炼", 100)
	self.nRbt = _tData.rbt or self.nRbt --rbt	Float	返还损兵比例	
	self.nP = _tData.p or self.nP --p	Long	我的积分
	self.tPs = _tData.ps or self.tPs --ps	List<Pair<Integer,Integer>>	国家积分排行
	self.nR = _tData.r or self.nR --r	Integer	我的排名
	self.nRkt = _tData.rkt or self.nRkt --rt	Integer	排行奖励状态 0没有领取 1已经领取
	self.nCt = _tData.ct or self.nCt --ct	Integer	国家奖励状态 0没有领取 1已经领取
	self.nIsStart = _tData.z or self.nIsStart -- 
	self.nC = _tData.c or self.nC --宝箱数量
	self.nN = _tData.n or self.nN --玩家当前区域的纣王数量
	-- self.tPras = _tData.pras or self.tPras --pras	List<PointRankAwardVo>	积分排行奖励
	--奖励数据
	if _tData.pras and #_tData.pras > 0 then
		self.tPras = {}
		for k, v in pairs(_tData.pras) do
			if not self.tPras[v.g] then
				local pDataRankPrize = DataRankPrize.new()
				pDataRankPrize:refreshByServer2(v)
				self.tPras[v.g] = pDataRankPrize
			else
				self.tPras[v.g]:refreshByServer2(v)
			end
		end
	end	
	-- self.tCa = _tData.ca or self.tCa --ca	List<Pair<Integer,Long>>	国家积分奖励
	if _tData.ca then
		self.tCa = {}
		sortGoodsList(_tData.ca)
		--物品解析
		for i, v in pairs(_tData.ca) do
			local pitem = getGoodsByTidFromDB(v.k)
			if pitem then
				pitem.nCt = v.v
				self.tCa[i] = pitem
			end				
		end			
	end		

	self:updateRankPrizeStatus()

	self:refreshActService(_tData)--刷新活动共有的数据

	if _tData.n then
		sendMsg(ghd_kingzhou_num_change_msg)
	end
end

function DataZhouwangTrial:getCountryPrizeStatus( ... )
	-- body
	if self:isStartGetPrize(Index) == true then	
		if self:getCountryRank() == 1 then
			if self.nCt == 1 then
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

function DataZhouwangTrial:getCountryRank()
	-- body
	local nInfluence = Player:getPlayerInfo().nInfluence
	for i, v in pairs(self.tPs) do
		if v.k == nInfluence then
			return i
		end
	end
	return 0
end

function DataZhouwangTrial:updateRankPrizeStatus( )
	-- body
	for k, v in pairs(self.tPras) do
		v:updateStatus(self:getPrizeStatus(k))
	end
end

--获取奖品状态
function DataZhouwangTrial:getPrizeStatus( Index )
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

--是否开始领奖
function DataZhouwangTrial:isStartGetPrize(  )
	-- body
	if self.nIsStart == 1 then
		return true
	else 
		return false
	end 
end

--是否在奖励范围内
function DataZhouwangTrial:isInGetPrizeRange( _index )
	-- body
	if not _index or self.nR == 0 then
		return false
	end
	local myRank = self.nR
	if self.tPras[_index] then
		if myRank <= self.tPras[_index].nR and myRank >= self.tPras[_index].nL then
			return true
		end
	end
	return false
end

--是否已经领取奖励
function DataZhouwangTrial:isHaveGetPrize(_index)
	-- body
	if self.nRkt == 0 then
		return false	
	else
		return true
	end
end

-- 获取红点方法
function DataZhouwangTrial:getRedNums( )
	local nNum = 0
	if self:getCountryPrizeStatus() == en_get_state_type.canget then
		nNum = nNum + 1
	end
	for k, v in pairs(self.tPras) do
		if v.nStatus == en_get_state_type.canget then
			nNum = nNum + 1	
		end
	end
	return nNum
end
--获取当前纣王数量
function DataZhouwangTrial:getCurKingZhouNum( ... )
	-- body
	return self.nN
end

return DataZhouwangTrial
