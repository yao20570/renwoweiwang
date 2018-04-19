local LucyTurnConfVo = class("LucyTurnConfVo")

function LucyTurnConfVo:ctor( tData )
	self:update(tData)
end

function LucyTurnConfVo:update( tData )
	if not tData then
		return
	end

	self.nPos = tData.l or self.nPos --	Integer	位置
	self.tReward = tData.a or self.tReward --	Pair<Integer,Long>	获得奖励
end

return LucyTurnConfVo