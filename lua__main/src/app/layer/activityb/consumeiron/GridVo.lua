local GridVo = class("GridVo")

function GridVo:ctor( tData )
	self.nGrid = 0
	self.nGoodsId = 0
	self.nGoodsCnt = 0
	self:update(tData)
end

function GridVo:update( tData )
	if not tData then
		return
	end

	self.nGrid = tData.g or self.nGrid  --Integer	格子数
	self.nGoodsId = tData.i or self.nGoodsId	--Integer	物品
	self.nGoodsCnt = tData.n or self.nGoodsCnt --	Integer	数量
end

return GridVo