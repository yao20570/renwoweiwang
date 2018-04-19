local TreasureTurnConfVo = class("TreasureTurnConfVo")

function TreasureTurnConfVo:ctor( tData )
	self:update(tData)
end

function TreasureTurnConfVo:update( tData )
	if not tData then
		return
	end

	self.nPos = tData.loc or self.nPos --	Integer	位置
	self.tReward = tData.p or self.tReward --	Pair<Integer,Long>	获得奖励
end

return TreasureTurnConfVo