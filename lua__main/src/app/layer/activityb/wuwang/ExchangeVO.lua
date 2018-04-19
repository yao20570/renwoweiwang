local ExchangeVO = class("ExchangeVO")

function ExchangeVO:ctor( tData )
	self.tCost = {}
	self.tOb = {}
	self.nExchangeMax = 0
	self.nLv = 0
	self:update(tData)
end


function ExchangeVO:update( tData )
	self.nId  = tData.i or self.nId --	int	id
	self.tCost    = tData.cost or self.tCost -- List<Pair<Integer,Long>>	花费
	self.tOb      = tData.ob or self.tOb --	List<Pair<Integer,Long>>	获得
	self.nExchangeMax = tData.m or self.nExchangeMax --	int	最大兑换次数
	self.nLv     = tData.lv or self.nLv --	int	限制等级
end

function ExchangeVO:getCostGoods( )
	if self.tCost[1] then
		return self.tCost[1].k, self.tCost[1].v
	end
	return nil
end

function ExchangeVO:getExchangeGoods( )
	if self.tOb[1] then
		return self.tOb[1].k, self.tOb[1].v
	end
	return nil
end

--是否可以进行兑换
--返回bool 或 错误码
--错误码:nil:数据出错，1：等级不足，2：兑换次数已满，3，消耗品不足
function ExchangeVO:getIsCanExchange( )
	if Player:getPlayerInfo().nLv < self.nLv then
		return false, 1
	end

	local nExchanged = 0
	local tData = Player:getActById(e_id_activity.wuwang)
	if tData and tData.tExchangeMsg then
		nExchanged = tData.tExchangeMsg:getGoodsExchanged(self.nId)
	end
	if nExchanged >= self.nExchangeMax then
		return false, 2
	end

	local nCostGoodsId, nCostNum = self:getCostGoods()
	if nCostGoodsId then
		local nCurrNum = getMyGoodsCnt(nCostGoodsId)
		if nCurrNum < nCostNum then
			return false, 3
		end
	end

	return true

end


return ExchangeVO