local ExchangeMsg = class("ExchangeMsg")

function ExchangeMsg:ctor( tData )
	self.tExchangeVos = {}
	self.tExchangedDict = {}
	self:update(tData)
end


function ExchangeMsg:update( tData )
	if tData.exs then --	List<ExchangeVO>	兑换列表
		self.tExchangeVos = {}
		local ExchangeVO = require("app.layer.activityb.wuwang.ExchangeVO")
		for i=1,#tData.exs do
			local tExchageVo = ExchangeVO.new(tData.exs[i])
			table.insert(self.tExchangeVos, tExchageVo) 
		end
	end
	if tData.is then --List<Pair<Integer,Integer>>	已兑换详情
		for i=1,#tData.is do
			local nKey = tData.is[i].k
			local nValue = tData.is[i].v
			self.tExchangedDict[nKey] = nValue
		end
	end
end

--获取物品已兑换
--nId: 兑换id
function ExchangeMsg:getGoodsExchanged( nId )
	return self.tExchangedDict[nId] or 0
end

--更新单个已兑换次数
function ExchangeMsg:setExchanged( nId, nExchanged )
	if not nId then
		return
	end
	if not nExchanged then
		return
	end
	self.tExchangedDict[nId] = nExchanged
end


return ExchangeMsg