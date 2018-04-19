----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 15:23:51
-- Description: 武王伐纣数据
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

--AwakeRes
local DataWuWang = class("DataWuWang", function()
	return Activity.new(e_id_activity.wuwang) 
end)
--创建自己(方便管理) 
tActivityDataList[e_id_activity.wuwang] = function (  )
	return DataWuWang.new()
end

function DataWuWang:ctor()
   self:myInit()
end


function DataWuWang:myInit( )
	self.nDiff = 1
	self.bIsZeroPush = false
end


-- 读取服务器中的数据
function DataWuWang:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	if _tData.ex then --ex	ExchangeMsg	兑换数据
		local ExchangeMsg = require("app.layer.activityb.wuwang.ExchangeMsg")
		self.tExchangeMsg = ExchangeMsg.new(_tData.ex)
	end

	self.nDiff = _tData.d or self.nDiff --	Integer	活动难度
	self.nCountryReward = _tData.cr or self.nCountryReward	--List<Pair<Integer,Long>>	国家排行奖励
	if _tData.rvos then
		self.nRangeAwardVos = {}
		for i=1,#_tData.rvos do --List<RangeAwardVO>	国内排行奖励
			local RangeAwardVO = require("app.layer.activityb.wuwang.RangeAwardVO")
			local tRangeAwardVO = RangeAwardVO.new(_tData.rvos[i])
			table.insert(self.nRangeAwardVos, tRangeAwardVO)
		end
	end
	self:refreshActService(_tData)--刷新活动共有的数据
end

--获取根据国内排行奖励
--nRank 指定排行
function DataWuWang:getRangeAwardVo( nRank )
	if self.nRangeAwardVos then
		for i=1,#self.nRangeAwardVos do
			if self.nRangeAwardVos[i].nStart <= nRank and nRank <= self.nRangeAwardVos[i].nEnd then
				return self.nRangeAwardVos[i]
			end
		end
	end
	return nil
end

--获取交换列表
function DataWuWang:getExchangeVos( )
	if self.tExchangeMsg then
		return self.tExchangeMsg.tExchangeVos
	end
	return {}
end

--判断是否能兑换物品
function DataWuWang:isCanExchange( ... )
	-- body
	local nNums = 0
	-- local nNums2=0
	--b.	有奖励可兑换时有红点提示·这个可以考虑根据可兑换的物品兑换种类数，做数量红点提示						
	if self.tExchangeMsg then
		for i=1,#self.tExchangeMsg.tExchangeVos do
			local tExchangeVo = self.tExchangeMsg.tExchangeVos[i]
			local bIsCan, _ = tExchangeVo:getIsCanExchange()
			if bIsCan then
				nNums = 1
				break
			end
		end
	end
	return nNums
end

function DataWuWang:isHaveNewExchange()
	local nNums = 0
	if self:isCanExchange() <=0 then
		return nNums
	end
	if self.tExchangeMsg then
		local tExchangeVo = self.tExchangeMsg.tExchangeVos[1]
		if tExchangeVo then
			local nItemId =self:getExchangeId()
			if nItemId then
				local tItemData=Player:getBagInfo():getItemDataById(nItemId)
				if tItemData.nRedNum>0 then
					nNums=1
					return nNums
				end
			end
		end
	end
	return 0
end
function DataWuWang:getExchangeId()
	if self.tExchangeMsg then
		local tExchangeVo = self.tExchangeMsg.tExchangeVos[1]
		if tExchangeVo then
			local nItemId =tExchangeVo:getCostGoods()
			return nItemId 
		end
	end
	
end

--判断是否有新获得的召唤券
function DataWuWang:isHaveNewZhq( ... )
	-- body
	local nNums = 0
	local tItemData1=Player:getBagInfo():getItemDataById(100154)
	local tItemData2=Player:getBagInfo():getItemDataById(100155)

	if tItemData1 then	
		if tItemData1.nRedNum>0 then
			nNums=1
		end
	end
	if tItemData2 then
		if(tItemData2.nRedNum>0) then
			nNums=1
		end
	end

	return nNums

end

function DataWuWang:setZeroPush( _bIsZero )
	-- body
	self.bIsZeroPush = _bIsZero or false
end

-- 获取红点方法
function DataWuWang:getRedNums( )
	-- local nNums=self:isCanExchange()
	
	-- if nNums>0 then return nNums end

	-- return self:isHaveNewZhq()

	if self.bIsZeroPush then
		return 1
	end
	local nNum = self:isHaveNewExchange()
	return nNum
end


return DataWuWang
