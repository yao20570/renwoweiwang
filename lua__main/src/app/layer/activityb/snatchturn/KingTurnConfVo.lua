local KingTurnConfVo = class("KingTurnConfVo")

function KingTurnConfVo:ctor( tData )
	self:update(tData)
end

function KingTurnConfVo:update( tData )
	if not tData then
		return
	end

	self.nPos = tData.l or self.nPos --	Integer	位置
	self.tReward = tData.a or self.tReward --	Pair<Integer,Long>	获得奖励
	self.tReplace = tData.r or self.tReplace --	Pair<Integer,Long>	替换奖励
	self.nRewardType = tData.t or self.nRewardType --	Integer	奖励类型 1.普通奖励 2.头像奖励 3.碎片奖励
end

function KingTurnConfVo:isHeadReward( )
	return self.nRewardType == 2
end

function KingTurnConfVo:isPieceReward( )
	return self.nRewardType == 3
end

return KingTurnConfVo